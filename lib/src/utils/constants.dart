import 'package:flutter/material.dart';

class Constants {

  static const Color corErro = Color.fromARGB(255, 122, 100, 182);
  static const Color corSuccess = Color.fromARGB(255, 204, 205, 255);
  static const Color corBranco = Color(0xFFFFFFFF);
  static const Color corPrimaria = Color(0xFF6200EE); 

  // --- Firebase (adicione conforme necessário) ---
  static const String firebaseUsersCollection = "users"; // Nome da coleção no Firestore
  static const String firebaseStorageBucket = "seus-arquivos.appspot.com"; // Bucket do Storage
  static const String firebaseAuthErrorMessage = "Erro de autenticação"; 

  static const double paddingPadrao = 16.0;
  static const String appName = "Planify";
}