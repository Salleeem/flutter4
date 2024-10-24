import 'package:bioo/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // Para formatar a data e hora

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

  LatLng? _zonaSegura; // Para armazenar a localização da zona segura
  double _raioZonaSegura = 200.0; // Raio da zona segura em metros

  Future<void> _login() async {
    try {
      String cpf = _cpfController.text.trim();
      String senha = _senhaController.text.trim();

      // 1. Tenta fazer o login com email e senha
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: '$cpf@gmail.com',
        password: senha,
      );

      // 2. Obter localização atual
      Position localizacaoAtual = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Recuperar a zona segura do Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      // Verifique se o documento existe e se a 'zona_segura' é um GeoPoint
      if (userDoc.exists && userDoc['zona_segura'] is Map) {
        var zonaSeguraFirestore = userDoc['zona_segura'];
        LatLng zonaSegura = LatLng(zonaSeguraFirestore['latitude'], zonaSeguraFirestore['longitude']);

        // 4. Calcular a distância entre a localização atual e a zona segura
        double distancia = Geolocator.distanceBetween(
          localizacaoAtual.latitude,
          localizacaoAtual.longitude,
          zonaSegura.latitude,
          zonaSegura.longitude,
        );

        // 5. Verificar se a distância está dentro do raio permitido
        if (distancia <= _raioZonaSegura) {
          // 6. Verificar se a biometria é suportada e disponível
          bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
          if (canCheckBiometrics) {
            // Autenticar digital
            bool authenticated = await _localAuth.authenticate(
              localizedReason:
                  'Por favor, autentique-se com sua digital para acessar sua conta.',
              options: const AuthenticationOptions(
                useErrorDialogs: true,
                stickyAuth: true,
              ),
            );

            if (authenticated) {
              // Gravar o login no Firestore na coleção "logins"
              await _firestore.collection('logins').add({
                'cpf': cpf,
                'data': DateFormat('dd/MM/yyyy').format(DateTime.now()), // Data formatada
                'horario': DateFormat('HH:mm:ss').format(DateTime.now()), // Horário formatado
                'localizacao': {
                  'latitude': localizacaoAtual.latitude,
                  'longitude': localizacaoAtual.longitude,
                },
              });

              // Navegar para a Dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardPage(
                          nome: '', // Substitua por um nome real, se necessário
                        )),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao realizar login: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
