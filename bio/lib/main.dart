import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/acess_log_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Acesso',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/access-log': (context) => AccessLogPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
