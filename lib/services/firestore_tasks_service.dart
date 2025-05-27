// lib/services/firestore_tasks_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/models/task.dart';
import 'package:planify/services/firestore_service.dart';
import 'package:flutter/foundation.dart';

class FirestoreTasksService extends FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userId; // Agora o userId é uma variável de instância

  // Construtor que aceita o userId
  FirestoreTasksService({required String userId}) : _userId = userId;

  Future<void> createUserTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? priority,
  }) async {
    final newTask = Task(
      id: '',
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      status: 'pending',
      createdAt: DateTime.now(),
      userId: _userId, // Use o userId da instância
    );

    // ADICIONE ESTA LINHA:
    debugPrint(
        "DEBUG: Dados da tarefa sendo enviados ao Firestore: ${newTask.toFirestore()}");

    await _db.collection('tasks').add(newTask.toFirestore());
    print("DEBUG: Tarefa '$title' criada para o usuário '$_userId'.");
  }

  Future<List<Task>> listUserTasks({String? filter}) async {
    Query query = _db
        .collection('tasks')
        .where('userId', isEqualTo: _userId); // Use o userId da instância

    if (filter != null) {
      if (filter == 'concluídas') {
        query = query.where('status', isEqualTo: 'completed');
      } else if (filter == 'pendentes') {
        query = query.where('status', isEqualTo: 'pending');
      } else if (filter == 'hoje') {
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        query = query
            .where('dueDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
            .where('dueDate',
                isLessThanOrEqualTo: Timestamp.fromDate(endOfToday));
      } else if (filter == 'futuras') {
        final now = DateTime.now();
        final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
        query = query.where('dueDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfTomorrow));
      }
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();
    print(
        "DEBUG: Listando tarefas para o usuário '$_userId'. Encontradas ${snapshot.docs.length}.");
    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<Task?> findTaskByTitle(String title) async {
    final snapshot = await _db
        .collection('tasks')
        .where('userId', isEqualTo: _userId) // Use o userId da instância
        .where('title', isEqualTo: title)
        .limit(1) // Pega apenas o primeiro que encontrar
        .get();

    if (snapshot.docs.isNotEmpty) {
      print("DEBUG: Tarefa '$title' encontrada para o usuário '$_userId'.");
      return Task.fromFirestore(snapshot.docs.first);
    }
    print("DEBUG: Tarefa '$title' NÃO encontrada para o usuário '$_userId'.");
    return null;
  }

  // MÉTODO updateTask - ADICIONE ESTE!
  Future<void> updateUserTask({
    required String taskId,
    String? newTitle,
    DateTime? newDueDate,
    String? newPriority,
    bool? isCompleted,
  }) async {
    final Map<String, dynamic> updates = {};
    if (newTitle != null) updates['title'] = newTitle;
    if (newDueDate != null) {
      updates['dueDate'] = Timestamp.fromDate(newDueDate);
    } else if (newDueDate == null && updates.containsKey('dueDate')) {
      // Pequena correção aqui, a chave é 'dueDate'
      updates['dueDate'] =
          FieldValue.delete(); // Permite remover a data de vencimento
    }
    if (newPriority != null) updates['priority'] = newPriority;
    if (isCompleted != null) {
      updates['status'] = isCompleted ? 'completed' : 'pending';
    }

    if (updates.isNotEmpty) {
      await _db.collection('tasks').doc(taskId).update(updates);
      print(
          "DEBUG: Tarefa com ID '$taskId' atualizada para o usuário '$_userId'.");
    }
  }

  // MÉTODO deleteTask - ADICIONE ESTE!
  Future<void> deleteTask({required String taskId}) async {
    await _db.collection('tasks').doc(taskId).delete();
    print("DEBUG: Tarefa com ID '$taskId' deletada para o usuário '$_userId'.");
  }

  // Método para adicionar uma tarefa a um projeto (exemplo, precisa de coleção 'projects')
  @override // Removi o override se você não está sobrescrevendo de uma interface
  Future<void> addProjectTask(
      String projectId, String taskTitle, String userId) async {
    // Você pode usar o _userId da instância aqui, ou o userId passado se for o caso
    // Para consistência, recomendo usar o _userId da instância para operações relacionadas ao usuário autenticado.
    print(
        "DEBUG: Adicionando tarefa '$taskTitle' ao projeto '$projectId' para o usuário '$userId'.");
    // Sua lógica de adicionar a tarefa ao projeto aqui.
    // Exemplo: await _db.collection('projects').doc(projectId).collection('project_tasks').add({ 'title': taskTitle, 'userId': _userId });
  }
}
