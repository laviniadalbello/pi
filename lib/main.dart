import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './src/pages/inicial.dart';
import './src/pages/login.dart'; // <-- Importa a tela de login


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Inicial(),
        '/login': (context) => const LoginPage(),
        // '/cadastro': (context) => CadastroPage(),
      },
    );
  }
}