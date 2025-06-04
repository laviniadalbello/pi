import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/models/task.dart';
import 'package:planify/services/firestore_service.dart'; // Importa a interface FirestoreService
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:rxdart/rxdart.dart'; // Para Stream.value e CombineLatestStream

// ATENÇÃO: Se FirestoreTasksService é para ser uma implementação completa de FirestoreService,
// ela deve implementar todos os métodos. Se for apenas para tarefas,
// talvez não devesse estender FirestoreService diretamente, ou FirestoreService deveria ser mais granular.
// Para resolver o erro e manter a estrutura atual, implementaremos todos os métodos.
class FirestoreTasksService extends FirestoreService { // Agora é uma classe concreta
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Construtor que aceita o userId e o passa para a superclasse
  FirestoreTasksService({required String userId}) : super(userId: userId);

  // Implementação dos métodos abstratos de FirestoreService

  @override
  Stream<List<dynamic>> getEventsAndTasksForSelectedDay(DateTime date) {
    // Este serviço é focado em tarefas. Se você precisa de eventos também,
    // o FirestorePlannerService é mais adequado.
    // Retornando apenas as tarefas para a data selecionada.
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _db
        .collection('artifacts')
        .doc('planify') // Substitua pelo seu ID de aplicativo real, se diferente
        .collection('users')
        .doc(userId) // Usando userId da superclasse
        .collection('tasks')
        .where('dueDate', isGreaterThanOrEqualTo: startOfDay)
        .where('dueDate', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  @override
  Future<void> updateEventCompletion(String eventId, bool isCompleted) async {
    // Este método não é diretamente relevante para um serviço focado apenas em tarefas.
    // Se você precisar atualizar eventos, use FirestorePlannerService ou um serviço de eventos dedicado.
    debugPrint('DEBUG: updateEventCompletion chamado no FirestoreTasksService, que é focado em tarefas. Nenhuma ação realizada para o Evento ID: $eventId.');
  }

  @override
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    // Implementação para atualizar o status de conclusão de uma tarefa
    await _db
        .collection('artifacts')
        .doc('planify')
        .collection('users')
        .doc(userId) // Usando userId da superclasse
        .collection('tasks')
        .doc(taskId)
        .update({'status': isCompleted ? 'completed' : 'pending'});
    debugPrint("DEBUG: Tarefa com ID '$taskId' status atualizado para o usuário '$userId'.");
  }

  // Seus métodos existentes para tarefas:

  Future<void> createUserTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? time, // Adicionado o campo time
    String? projectId, // Adicionado o campo projectId
  }) async {
    final newTask = Task(
      id: '', // O ID será gerado pelo Firestore
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      status: 'pending',
      createdAt: DateTime.now(),
      userId: userId, // Use o userId da superclasse
      time: time, // Passando o campo time
      projectId: projectId, // Passando o campo projectId
    );

    debugPrint("DEBUG: Dados da tarefa sendo enviados ao Firestore: ${newTask.toFirestore()}");

    await _db
        .collection('artifacts')
        .doc('planify')
        .collection('users')
        .doc(userId) // Use o userId da superclasse
        .collection('tasks')
        .add(newTask.toFirestore());
    debugPrint("DEBUG: Tarefa '$title' criada para o usuário '$userId'.");
  }

  Future<List<Task>> listUserTasks({String? filter}) async {
    Query query = _db
        .collection('artifacts')
        .doc('planify')
        .collection('users')
        .doc(userId) // Use o userId da superclasse
        .collection('tasks');

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
            .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
            .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday));
      } else if (filter == 'futuras') {
        final now = DateTime.now();
        final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
        query = query.where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfTomorrow));
      }
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();
    debugPrint("DEBUG: Listando tarefas para o usuário '$userId'. Encontradas ${snapshot.docs.length}.");
    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<Task?> findTaskByTitle(String title) async {
    final snapshot = await _db
        .collection('artifacts')
        .doc('planify')
        .collection('users')
        .doc(userId) // Use o userId da superclasse
        .collection('tasks')
        .where('title', isEqualTo: title)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint("DEBUG: Tarefa '$title' encontrada para o usuário '$userId'.");
      return Task.fromFirestore(snapshot.docs.first);
    }
    debugPrint("DEBUG: Tarefa '$title' NÃO encontrada para o usuário '$userId'.");
    return null;
  }

  Future<void> updateUserTask({
    required String taskId,
    String? newTitle,
    DateTime? newDueDate,
    String? newPriority,
    bool? isCompleted,
    String? newTime, // Adicionado para permitir atualização do campo time
    String? newDescription, // Adicionado para permitir atualização da descrição
    String? newProjectId, // Adicionado para permitir atualização do projectId
  }) async {
    final Map<String, dynamic> updates = {};
    if (newTitle != null) updates['title'] = newTitle;
    if (newDueDate != null) {
      updates['dueDate'] = Timestamp.fromDate(newDueDate);
    } else if (newDueDate == null && updates.containsKey('dueDate')) {
      updates['dueDate'] = FieldValue.delete(); // Permite remover a data de vencimento
    }
    if (newPriority != null) updates['priority'] = newPriority;
    if (isCompleted != null) {
      updates['status'] = isCompleted ? 'completed' : 'pending';
    }
    if (newTime != null) updates['time'] = newTime; // Adicionado
    if (newDescription != null) updates['description'] = newDescription; // Adicionado
    if (newProjectId != null) updates['projectId'] = newProjectId; // Adicionado

    if (updates.isNotEmpty) {
      await _db
          .collection('artifacts')
          .doc('planify')
          .collection('users')
          .doc(userId) // Use o userId da superclasse
          .collection('tasks')
          .doc(taskId)
          .update(updates);
      debugPrint("DEBUG: Tarefa com ID '$taskId' atualizada para o usuário '$userId'.");
    }
  }

  Future<void> deleteTask({required String taskId}) async {
    await _db
        .collection('artifacts')
        .doc('planify')
        .collection('users')
        .doc(userId) // Use o userId da superclasse
        .collection('tasks')
        .doc(taskId)
        .delete();
    debugPrint("DEBUG: Tarefa com ID '$taskId' deletada para o usuário '$userId'.");
  }

  // Método para adicionar uma tarefa a um projeto (exemplo, precisa de coleção 'projects')
  Future<void> addProjectTask(
      String projectId, String taskTitle, String userId) async {
    // Este método é específico e não faz parte da interface FirestoreService.
    // Você pode usar o userId da instância aqui, ou o userId passado se for o caso
    // Para consistência, recomendo usar o userId da instância para operações relacionadas ao usuário autenticado.
    debugPrint("DEBUG: Adicionando tarefa '$taskTitle' ao projeto '$projectId' para o usuário '$userId'.");
    // Sua lógica de adicionar a tarefa ao projeto aqui.
    // Exemplo: await _db.collection('projects').doc(projectId).collection('project_tasks').add({ 'title': taskTitle, 'userId': userId });
  }
}
