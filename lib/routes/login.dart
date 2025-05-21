import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:mysql1/mysql1.dart';
import '../database/conexao.dart'; // Importando a classe Database

Future<Response> loginHandler(Request req) async {
  try {
    final body = await req.readAsString();
    final data = jsonDecode(body);

    final email = data['email'];
    final senha = data['senha'];

    if (email == null || senha == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Email e senha são obrigatórios'}));
    }

    // Aqui, usamos a função Database.connect() para obter a conexão
    final conn = await Database.connect();

    // Consulta o usuário pelo email
    final results = await conn.query(
      'SELECT * FROM usuarios WHERE email = ?',
      [email],
    );

    await conn.close();

    if (results.isEmpty) {
      return Response.forbidden(jsonEncode({'error': 'Email ou senha incorretos'}));
    }

    final user = results.first;
    final senhaCriptografada = user['senha'];

    // Verifica a senha
    final senhaBytes = utf8.encode(senha);
    final senhaHash = sha256.convert(senhaBytes).toString();

    if (senhaHash != senhaCriptografada) {
      return Response.forbidden(jsonEncode({'error': 'Email ou senha incorretos'}));
    }

    // Se chegou aqui, login deu certo
    return Response.ok(jsonEncode({
      'message': 'Login bem-sucedido',
      'user': {
        'id': user['id'],
        'nome': user['nome'],
        'email': user['email'],
      }
    }));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': 'Erro no servidor: $e'}));
  }
}
