import 'package:bioo/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart'; // Importando o pacote local_auth

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication(); // Instância do LocalAuthentication
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _login() async {
    try {
      String cpf = _cpfController.text;
      String senha = _senhaController.text;

      // 1. Tenta fazer o login com email e senha
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: '$cpf@gmail.com', // Use CPF como email
        password: senha,
      );

      // 2. Autenticação biométrica
      bool isAuthenticated = await _authenticateWithBiometrics();

      if (isAuthenticated) {
        // 3. Se autenticado com sucesso, navegue para a Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage(nome: '',)),
        );
      } else {
        // Se a autenticação falhar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Autenticação biométrica falhou!'),
        ));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao fazer login: $e'),
      ));
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para acessar sua conta.',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print(e);
      return false; // Retorna false se houver um erro na autenticação
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cpfController,
              decoration: InputDecoration(labelText: 'CPF'),
            ),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
