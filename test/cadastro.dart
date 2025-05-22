import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planify/src/pages/cadastro.dart';



class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('CadastroPage', () {
    late MockHttpClient mockHttpClient;
    late CadastroPage cadastroPage;

    setUp(() {
      mockHttpClient = MockHttpClient();
      cadastroPage = const CadastroPage(); 
    });

    testWidgets('Valida a tela de cadastro com dados válidos', (WidgetTester tester) async {
      // Encontra os campos e o botão
      await tester.pumpWidget(MaterialApp(home: cadastroPage));
      
      final nameField = find.byType(TextFormField).first;
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final submitButton = find.text('SIGN UP');


      await tester.enterText(nameField, 'João Silva');
      await tester.enterText(emailField, 'joao.silva@example.com');
      await tester.enterText(passwordField, 'Senha123');

      
      await tester.tap(submitButton);

  
      await tester.pump();


      verify(mockHttpClient.post(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
        headers: {'Content-Type': 'application/json'},
        body: '{"name":"João Silva","email":"joao.silva@example.com","password":"Senha123"}',
      )).called(1);


      expect(find.text('Cadastro realizado com sucesso!'), findsOneWidget);
    });

    testWidgets('Valida a tela de cadastro com dados inválidos', (WidgetTester tester) async {
      // Encontra os campos e o botão
      await tester.pumpWidget(MaterialApp(home: cadastroPage));
      
      final nameField = find.byType(TextFormField).first;
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final submitButton = find.text('SIGN UP');


      await tester.enterText(nameField, 'João Silva');
      await tester.enterText(emailField, 'joao.silva@example.com');
      await tester.enterText(passwordField, '');

      await tester.tap(submitButton);

      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
