import 'package:flutter/material.dart';
import 'src/pages/inicial.dart';
import 'src/pages/login.dart'; // <-- Importa a tela de login
import 'package:firebase_core/firebase_core.dart';
import 'core/infrastructure/firebase_options.dart';

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
      initialRoute: '/', // <-- Define a rota inicial
      routes: {
        '/': (context) => Inicial(),
        '/login': (context) => const LoginPage(), // <-- Define a tela de login
        // '/cadastro': (context) => CadastroPage(), // se quiser também
      },
    );
  }
}

