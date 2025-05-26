import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      await _db.collection('tasks').add(taskData);
      print('Tarefa adicionada com sucesso no Firestore!');
      // Poderia retornar um ID ou um objeto de sucesso se necessário
    } catch (e) {
      print('Erro ao adicionar tarefa no Firestore: $e');
      // É importante relançar o erro para que a UI possa lidar com ele
      rethrow;
    }
  }

  // Adicione aqui outros métodos CRUD (Create, Read, Update, Delete) para tarefas,
  // ou para quaisquer outras coleções que seu aplicativo precise gerenciar.
  // Ex:
  // Future<List<Map<String, dynamic>>> getTasks() async { ... }
  // Future<void> updateTask(String taskId, Map<String, dynamic> newData) async { ... }
  // Future<void> deleteTask(String taskId) async { ... }
}