import 'package:bioo/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String nome; // Adicionando o parâmetro 'nome'

  // Construtor atualizado para receber o nome do usuário
  DashboardPage({required this.nome});

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Bem-vindo, $nome!'), // Exibindo o nome do usuário
      ),
    );
  }
}
