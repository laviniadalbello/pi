// lib/services/firestore_tasks_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/models/task.dart'; // Certifique-se que esta importação está correta

class FirestoreTasksService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para criar uma nova tarefa
  Future<void> createUserTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? priority,
  }) async {
    // Substitua 'test_user_id' pelo ID do usuário logado REAL
    // Isso é crucial para que cada usuário veja apenas suas tarefas.
    final userId =
        'test_user_id'; // <--- Substitua pelo ID do usuário autenticado!

    final newTask = Task(
      id: '', // Firestore gerará o ID
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      status: 'pending',
      createdAt: DateTime.now(),
      userId: userId,
    );

    await _db.collection('tasks').add(newTask.toFirestore());
  }

  // Método para listar tarefas
  Future<List<Task>> listUserTasks({String? filter}) async {
    // Substitua 'test_user_id' pelo ID do usuário logado REAL
    final userId =
        'test_user_id'; // <--- Substitua pelo ID do usuário autenticado!

    Query query = _db.collection('tasks').where('userId', isEqualTo: userId);

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
      // Adicione outros filtros conforme necessário
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => Task.fromFirestore(doc))
        .toList(); // <-- CORREÇÃO AQUI
  }

  // Método para encontrar tarefa por título (usado pelo Gemini se não houver ID)
  Future<Task?> findTaskByTitle(String title) async {
    // Substitua 'test_user_id' pelo ID do usuário logado REAL
    final userId =
        'test_user_id'; // <--- Substitua pelo ID do usuário autenticado!

    final snapshot = await _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('title', isEqualTo: title)
        .limit(1) // Pega apenas o primeiro que encontrar
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Task.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  // Método para atualizar uma tarefa
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
    } else if (newDueDate == null && updates.containsKey('newDueDate')) {
      updates['dueDate'] =
          FieldValue.delete(); // Permite remover a data de vencimento
    }
    if (newPriority != null) updates['priority'] = newPriority;
    if (isCompleted != null) {
      updates['status'] = isCompleted ? 'completed' : 'pending';
    }

    if (updates.isNotEmpty) {
      await _db.collection('tasks').doc(taskId).update(updates);
    }
  }

  // Método para deletar uma tarefa
  Future<void> deleteTask({required String taskId}) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  // Método para adicionar uma tarefa a um projeto (exemplo, precisa de coleção 'projects')
  Future<void> addProjectTask(
      String projectId, String taskTitle, String userId) async {
    // Isso é apenas um exemplo de como seria.
    // Você precisaria de uma estrutura para projetos no seu Firestore.
    // Por exemplo: collection('projects').doc(projectId).collection('project_tasks').add(...)
    print(
        "Adicionando tarefa '$taskTitle' ao projeto '$projectId' para o usuário '$userId'");
    // Aqui você faria a lógica de adicionar a tarefa ao projeto
    // Por agora, apenas simulando a adição.
  }
}
