import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServiceAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para registrar um novo usuário
  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Criar um novo usuário com email e senha
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualizar o nome do usuário
      await userCredential.user?.updateDisplayName(name);

      return userCredential.user;
    } catch (e) {
      print('Erro ao registrar usuário: $e');
      return null;
    }
  }

  // Função para fazer login de um usuário
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }

  // Função para sair da conta do usuário
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Função para checar se o usuário está autenticado
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
