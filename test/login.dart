import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planify/src/pages/login.dart'; 
void main() {
  testWidgets('Teste da tela de Login', (WidgetTester tester) async {

    await tester.pumpWidget(const MaterialApp(
      home: LoginPage(),  
    ));

 
    expect(find.text('Welcome Back'), findsOneWidget);  
    expect(find.text('Dear Friend'), findsOneWidget);  

    expect(find.byType(TextField), findsNWidgets(2)); 
    expect(find.text('LOGIN'), findsOneWidget); 

    expect(find.text('Forgot Password ?'), findsOneWidget);

   
    await tester.enterText(find.byType(TextField).at(0), 'joao.silva@example.com');  
    await tester.enterText(find.byType(TextField).at(1), 'Senha123');  

    await tester.tap(find.text('LOGIN'));
    await tester.pump();  // Rebuild após o clique

 
  });
}
