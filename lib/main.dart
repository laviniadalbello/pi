import 'package:flutter/material.dart';
import 'inicial.dart';
import 'login.dart'; // <-- Importa a tela de login


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // <-- Define a rota inicial
      routes: {
        '/': (context) => Inicial(),
        '/login': (context) => const LoginPage(), // <-- Define a tela de login
        // '/cadastro': (context) => CadastroPage(), // se quiser também
      },
    );
  }
}