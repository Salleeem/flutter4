import 'package:bioo/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  double _raioZonaSegura = 50.0;

  Future<void> _login() async {
  try {
    String cpf = _cpfController.text.trim();
    String senha = _senhaController.text.trim();
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: '$cpf@gmail.com',
      password: senha,
    );

    // Recupera o documento do usuário no Firestore
    DocumentSnapshot userDoc = await _firestore
        .collection('usuarios')
        .doc(userCredential.user!.uid)
        .get();

    if (userDoc.exists) {
      String nome = userDoc['nome']; // Aqui você busca o nome do usuário

      // Restante do código para verificar a zona segura e biometria
      Position localizacaoAtual = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (userDoc['zona_segura'] is Map) {
        // Código existente para verificar a zona segura
        var zonaSeguraFirestore = userDoc['zona_segura'];
        LatLng zonaSegura = LatLng(
          zonaSeguraFirestore['latitude'],
          zonaSeguraFirestore['longitude'],
        );

        double distancia = Geolocator.distanceBetween(
          localizacaoAtual.latitude,
          localizacaoAtual.longitude,
          zonaSegura.latitude,
          zonaSegura.longitude,
        );

        if (distancia <= _raioZonaSegura) {
          bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
          if (canCheckBiometrics) {
            bool authenticated = await _localAuth.authenticate(
              localizedReason:
                  'Por favor, autentique-se com sua digital para acessar sua conta.',
              options: const AuthenticationOptions(
                useErrorDialogs: true,
                stickyAuth: true,
              ),
            );

            if (authenticated) {
              await _firestore.collection('logins').add({
                'cpf': cpf,
                'data': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                'horario': DateFormat('HH:mm:ss').format(DateTime.now()),
                'localizacao': {
                  'latitude': localizacaoAtual.latitude,
                  'longitude': localizacaoAtual.longitude,
                },
              });

              // Passa o nome do usuário para a DashboardPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(nome: nome), // Aqui
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Falha na autenticação da digital.'),
              ));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Biometria não disponível no dispositivo.'),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Você está fora da zona segura.'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Não foi possível recuperar a zona segura.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Usuário não encontrado.'),
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Erro ao realizar login: $e'),
    ));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF579EC2),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF579EC2),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: Image.asset('assets/img/logopes2.png'),
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
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9A5071),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFF5D5D4),
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