import 'package:bioo/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart'; // Para hash seguro da senha e biometria
import 'dart:convert'; // Para converter a senha em bytes para o hash

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _cadastrar() async {
    try {
      String nome = _nomeController.text.trim();
      String cpf = _cpfController.text.trim();
      String senha = _senhaController.text.trim();

      if (cpf.isEmpty || senha.isEmpty || nome.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, preencha todos os campos')),
        );
        return;
      }

      // Criar hash seguro da senha usando SHA-256
      String senhaHash = sha256.convert(utf8.encode(senha)).toString();

      // Criando o usuário no Firebase Auth usando o CPF como e-mail (Firebase exige formato de e-mail válido)
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
          // Simular um hash da biometria (no caso real, usar um identificador seguro gerado pelo sistema)
          String digitalHash = sha256.convert(utf8.encode('simulacao_digital_$cpf')).toString();

          // Armazenar os dados no Firestore
          await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
            'nome': nome,
            'cpf': cpf,
            'senha_hash': senhaHash, // Armazenando a senha como hash
            'digital_hash': digitalHash, // Armazenar o identificador da biometria (simulado)
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
