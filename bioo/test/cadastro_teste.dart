import 'package:bioo/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bioo/cadastro.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockLocalAuth extends Mock implements LocalAuthentication {}

void main() {
  testWidgets('CadastroPage displays fields and buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: CadastroPage(),
      ),
    );

    // Verify if widgets are displayed
    expect(find.text('Cadastro'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3)); // Nome, CPF, Senha
    expect(find.byType(ElevatedButton), findsNWidgets(2)); // Botão de Selecionar e Cadastrar
  });

  testWidgets('CadastroPage handles empty fields', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      MaterialApp(
        home: CadastroPage(),
      ),
    );

    // Tap the Cadastrar button
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    // Verify if the snackbar is shown for empty fields
    expect(find.text('Por favor, preencha todos os campos e selecione uma zona segura.'), findsOneWidget);
  });

  testWidgets('CadastroPage handles valid registration', (WidgetTester tester) async {


    // Build our app
    await tester.pumpWidget(
      MaterialApp(
        home: CadastroPage(),
      ),
    );

    // Fill in the fields
    await tester.enterText(find.byType(TextField).at(0), 'Nome de Teste'); // Nome
    await tester.enterText(find.byType(TextField).at(1), '12345678900'); // CPF
    await tester.enterText(find.byType(TextField).at(2), 'senha123'); // Senha

    // Simulate selecting a safe zone
    await tester.tap(find.text('Selecionar'));
    await tester.pump();

    // Tap the Cadastrar button
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    // Verify if the registration process is triggered and the Snackbar is not shown
    // Adjust this based on how you handle the navigation in your `_cadastrar` method
    // This is a placeholder for checking if the next page is displayed
    expect(find.byType(DashboardPage), findsOneWidget);
  });
}
