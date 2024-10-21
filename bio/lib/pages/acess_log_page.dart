import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccessLogPage extends StatefulWidget {
  @override
  _AccessLogPageState createState() => _AccessLogPageState();
}

class _AccessLogPageState extends State<AccessLogPage> {
  // Função para buscar logs de acessos do Firestore
  Stream<QuerySnapshot> _getAccessLogs() {
    return FirebaseFirestore.instance
        .collection('access_logs')
        .orderBy('timestamp', descending: true) // Ordenando pelos mais recentes
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros de Acesso'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getAccessLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Mostra um loading enquanto carrega
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum registro de acesso encontrado.'));
          }

          // Listando os registros
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
              String user = data['user'] ?? 'Usuário desconhecido';
              String location = data['location'] ?? 'Localização não informada';

              return ListTile(
                title: Text(user),
                subtitle: Text('Local: $location\nData: $timestamp'),
                leading: Icon(Icons.access_time),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
