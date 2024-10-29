import 'package:flutter/material.dart';
import 'calendariopage.dart';
import 'todopage.dart';

class DashboardPage extends StatelessWidget {
  final String nome;

  DashboardPage({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove a seta de voltar
        backgroundColor: const Color(0xFF579EC2), // Tom de azul para a navbar
        title: Row(
          children: [
            Image.asset(
              'assets/img/pitica.png', // Caminho da logo pequena
              height: 40, // Altura da logo ajustada
            ),
            const SizedBox(width: 10),
            const Text('Dashboard'),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF5D5D4), // Cor de fundo pêssego claro
        padding: const EdgeInsets.all(16.0),
        child: Center( // Centraliza os elementos vertical e horizontalmente
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
            crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
            children: [
              Text(
                'Bem-vinda, $nome!',
                style: const TextStyle(fontSize: 24, color: Colors.black), // Tamanho do texto aumentado
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A5071), // Tom de rosa
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(200, 60), // Define tamanho fixo
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.calendar_today, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Ir para o Calendário',
                      style: TextStyle(color: Colors.white), // Texto em branco
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TodoListPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A5071), // Tom de rosa
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(200, 60), // Define tamanho fixo
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.note, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Ir para as Anotações',
                      style: TextStyle(color: Colors.white), // Texto em branco
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Função de logout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A5071), // Cor do botão de logout
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white), // Texto em branco
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF579EC2), // Cor do rodapé azul
        height: 60, // Altura do rodapé
      ),
    );
  }
}
