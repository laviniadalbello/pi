import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart'; // Para CombineLatestStream
import 'package:planify/models/events_model.dart';
import 'package:planify/models/task.dart';
import 'package:planify/services/firestore_service.dart'; // Importa a interface
import 'package:flutter/foundation.dart'; // Para debugPrint

class FirestorePlannerService implements FirestoreService {
  @override
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestorePlannerService({required this.userId});

  // Implementação dos métodos abstratos de FirestoreService

  @override
  Stream<List<dynamic>> getEventsAndTasksForSelectedDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // ATENÇÃO: Consultando coleções de nível superior 'events' e 'tasks'
    // e filtrando por userId.
    final eventsStream = _firestore
        .collection('events') // <--- CAMINHO AJUSTADO
        .where('userId', isEqualTo: userId) // <--- FILTRANDO POR USER ID
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());

    final tasksStream = _firestore
        .collection('tasks') // <--- CAMINHO AJUSTADO
        .where('userId', isEqualTo: userId) // <--- FILTRANDO POR USER ID
        .where('dueDate', isGreaterThanOrEqualTo: startOfDay)
        .where('dueDate', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());

    return Rx.combineLatest2(
      eventsStream,
      tasksStream,
      (List<Event> events, List<Task> tasks) {
        return [...events, ...tasks];
      },
    );
  }

  @override
  Future<void> updateEventCompletion(String eventId, bool isCompleted) async {
    await _firestore
        .collection('events') // <--- CAMINHO AJUSTADO
        .doc(eventId)
        .update({'isCompleted': isCompleted});
    debugPrint("DEBUG: Evento com ID '$eventId' status atualizado para o usuário '$userId'.");
  }

  @override
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore
        .collection('tasks') // <--- CAMINHO AJUSTADO
        .doc(taskId)
        .update({'status': isCompleted ? 'completed' : 'pending'});
    debugPrint("DEBUG: Tarefa com ID '$taskId' status atualizado para o usuário '$userId'.");
  }

  @override
  Future<void> createTask(Map<String, dynamic> taskData) async {
    // Implementação concreta do createTask para FirestorePlannerService
    // ATENÇÃO: Esta função AGORA salva na coleção de nível superior 'tasks'.
    try {
      await _firestore
          .collection('tasks') // <--- CAMINHO AJUSTADO
          .add(taskData);
      debugPrint('DEBUG: Tarefa adicionada com sucesso no Firestore para o usuário $userId!');
    } catch (e) {
      debugPrint('DEBUG: Erro ao adicionar tarefa no Firestore para o usuário $userId: $e');
      rethrow;
    }
  }

  // Você pode adicionar outros métodos específicos do Planner aqui, se necessário
  // Por exemplo, métodos para adicionar/atualizar eventos, projetos, etc.
  // Se você tiver um método para criar eventos, ele também precisará ser ajustado
  // para salvar na coleção 'events' de nível superior.
}
