import 'package:flutter/material.dart';
import 'inicial.dart'; // Certifique-se de importar o arquivo corretamente

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Inicial(), // Define Inicial como a primeira tela
    );
  }
}
