import 'package:bioo/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  LatLng? _zonaSegura; // Para armazenar a localização da zona segura
  Position? _localizacaoAtual; // Para armazenar a localização atual

  Future<void> _obterLocalizacaoAtual() async {
    try {
      _localizacaoAtual = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _zonaSegura = LatLng(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }

  Future<void> _cadastrar() async {
    try {
      String nome = _nomeController.text.trim();
      String cpf = _cpfController.text.trim();
      String senha = _senhaController.text.trim();

      if (cpf.isEmpty || senha.isEmpty || nome.isEmpty || _zonaSegura == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, preencha todos os campos e selecione uma zona segura.')),
        );
        return;
      }

      // Criar hash seguro da senha usando SHA-256
      String senhaHash = sha256.convert(utf8.encode(senha)).toString();

      // Criando o usuário no Firebase Auth usando o CPF como e-mail
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: '$cpf@gmail.com',
        password: senha,
      );

      // Verificar se a biometria é suportada e está disponível
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (canCheckBiometrics) {
        // Autenticar digital
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Por favor, autentique-se com sua digital para concluir o cadastro',
        );

        if (authenticated) {
          // Simular um hash da biometria
          String digitalHash = sha256.convert(utf8.encode('simulacao_digital_$cpf')).toString();

          // Armazenar os dados no Firestore
          await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
            'nome': nome,
            'cpf': cpf,
            'senha_hash': senhaHash,
            'digital_hash': digitalHash,
            'zona_segura': {
              'latitude': _zonaSegura!.latitude,
              'longitude': _zonaSegura!.longitude,
              'raio': 200, // Raio de 200 metros
            },
          });

          // Navegar para a dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage(nome: nome)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha na autenticação da digital.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometria não disponível no dispositivo.')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _cpfController,
              decoration: const InputDecoration(labelText: 'CPF'),
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Campo para exibir a zona segura selecionada
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Zona Segura: ${_zonaSegura != null ? "${_zonaSegura!.latitude}, ${_zonaSegura!.longitude}" : "Selecione uma zona"}',
              ),
            ),
            ElevatedButton(
              onPressed: _obterLocalizacaoAtual, // Obter localização atual
              child: const Text('Selecionar Zona Segura'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cadastrar,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
