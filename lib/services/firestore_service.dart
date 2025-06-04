import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String userId;

  FirestoreService({required this.userId});

  Stream<List<dynamic>> getEventsAndTasksForSelectedDay(DateTime date);
  Future<void> updateEventCompletion(String eventId, bool isCompleted);
  Future<void> updateTaskCompletion(String taskId, bool isCompleted);

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
}
