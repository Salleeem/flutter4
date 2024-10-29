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

  LatLng? _zonaSegura;
  Position? _localizacaoAtual;

  Future<void> _obterLocalizacaoAtual() async {
    try {
      _localizacaoAtual = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _zonaSegura =
            LatLng(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude);
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
          const SnackBar(
              content: Text(
                  'Por favor, preencha todos os campos e selecione uma zona segura.')),
        );
        return;
      }

      String senhaHash = sha256.convert(utf8.encode(senha)).toString();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: '$cpf@gmail.com',
        password: senha,
      );

      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (canCheckBiometrics) {
        bool authenticated = await _localAuth.authenticate(
          localizedReason:
              'Por favor, autentique-se com sua digital para concluir o cadastro',
        );

        if (authenticated) {
          String digitalHash =
              sha256.convert(utf8.encode('simulacao_digital_$cpf')).toString();

          await _firestore
              .collection('usuarios')
              .doc(userCredential.user!.uid)
              .set({
            'nome': nome,
            'cpf': cpf,
            'senha_hash': senhaHash,
            'digital_hash': digitalHash,
            'zona_segura': {
              'latitude': _zonaSegura!.latitude,
              'longitude': _zonaSegura!.longitude,
              'raio': 200,
            },
          });

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
          const SnackBar(
              content: Text('Biometria não disponível no dispositivo.')),
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
      backgroundColor: const Color(0xFF579EC2),
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: const Color(0xFF579EC2),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Exibe a imagem acima do formulário
                Container(
                  width: 200,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Image.asset(
                      'assets/img/logopes2.png'), // Carrega a imagem do logo
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5D5D4),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Cadastro',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText:
                              'Zona Segura: ${_zonaSegura != null ? "${_zonaSegura!.latitude}, ${_zonaSegura!.longitude}" : ""}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _obterLocalizacaoAtual,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9A5071),
                        ),
                        child: const Text(
                          'Selecionar',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFF5D5D4),
                          )
                          ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width:
                              200, // Largura fixa igual à definida na HomePage
                          height:
                              60, // Altura fixa igual à definida na HomePage
                          child: ElevatedButton(
                            onPressed: _cadastrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF9A5071), // Cor do botão
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Bordas arredondadas
                              ),
                            ),
                            child: const Text(
                              'Cadastrar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(
                                    0xFFF5D5D4), // Texto na cor de fundo igual
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
