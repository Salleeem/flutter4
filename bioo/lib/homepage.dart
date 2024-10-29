import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'login.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5D5D4), // Fundo rosa claro pastel
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Navbar
            Container(
              color: const Color(0xFF579EC2), // Cor da NavBar
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Image.asset(
                      'assets/img/pitica.png',
                      height: 55, // Ajuste a altura conforme necessário
                    ),
                  ),
                ],
              ),
            ),
            // Logo centralizada acima dos botões, com tamanho aumentado
            Center(
              child: Image.asset(
                'assets/img/logomeio2.png', // Caminho da logo grande
                height: 200,
              ),
            ),
            // Botões centralizados
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CadastroPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9A5071), // Cor dos botões
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fixedSize: const Size(200, 60), 
                    ),
                    child: const Text(
                      'Cadastro',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFF5D5D4), // Cor do texto igual ao fundo
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9A5071), // Cor dos botões
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fixedSize: const Size(200, 60), // Define o tamanho fixo dos botões
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFF5D5D4), // Cor do texto igual ao fundo
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Rodapé
            Container(
              color: const Color(0xFF579EC2), // Cor do rodapé igual à NavBar
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ],
        ),
      ),
    );
  }
}
