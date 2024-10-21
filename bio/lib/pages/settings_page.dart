import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Configurações do Controle de Acesso'),
            SwitchListTile(
              title: Text('Autenticação por Impressão Digital'),
              value: true, // Aqui você pode usar um estado para gerenciar a ativação
              onChanged: (bool value) {
                // Lógica para ativar/desativar autenticação
              },
            ),
          ],
        ),
      ),
    );
  }
}
