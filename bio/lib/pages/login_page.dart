import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  Future<void> _authenticate() async {
    try {
      _isAuthenticated = await auth.authenticate(
        localizedReason: 'Use sua impressão digital para autenticar',
        options: const AuthenticationOptions(
          biometricOnly: true, // Esse é o parâmetro atualizado
        ),
      );
      if (_isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _authenticate,
              child: Text('Autenticar com Impressão Digital'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Entrar com senha'),
            ),
          ],
        ),
      ),
    );
  }
}
