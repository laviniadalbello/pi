import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:crypto/crypto.dart';
import '../database/conexao.dart';

Future<Response> registerHandler(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);

  final name = data['name'];
  final email = data['email'];
  final password = data['password'];

  if (name == null || email == null || password == null) {
    return Response.badRequest(body: 'Missing fields');
  }

  final conn = await Database.connect();

  try {
    // Verificar se email já existe
    var result = await conn.query('SELECT id FROM usuarios WHERE email = ?', [email]);
    if (result.isNotEmpty) {
      return Response(409, body: 'Email already registered');
    }

    // Criptografar senha
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    // Inserir novo usuário
    await conn.query(
      'INSERT INTO usuarios (name, email, password) VALUES (?, ?, ?)',
      [name, email, hashedPassword],
    );

    return Response.ok('User registered successfully');
  } catch (e) {
    print('Erro ao cadastrar: $e');
    return Response.internalServerError(body: 'Internal error');
  } finally {
    await conn.close();
  }
}
