import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? priority; // 'low', 'medium', 'high'
  final String status; // 'pending', 'completed'
  final DateTime createdAt;
  final String userId; // Adicionado para identificar o usuário

  // Novos campos adicionados (ou já existentes que não estavam no toFirestore)
  final bool isCompleted;
  final String? projectId;
  final DateTime? reminderTime;
  final String? estimatedTime;
  final String? timeSpent;
  final int? progressPercentage;
  final String? time; // <--- ADICIONADO: Campo para a hora específica da tarefa

  String get displayTime {
    if (estimatedTime != null && estimatedTime!.isNotEmpty) {
      return 'Est: $estimatedTime';
    }
    if (timeSpent != null && timeSpent!.isNotEmpty) {
      return 'Gasto: $timeSpent';
    }
    // Se a tarefa tiver um horário específico
    if (time != null && time!.isNotEmpty) {
      return 'Hora: $time';
    }
    // Se você quiser exibir a data de vencimento formatada
    if (dueDate != null) {
      return 'Vence: ${DateFormat('dd/MM').format(dueDate!)}';
    }
    // Se você quiser exibir "X minutos/horas/dias atrás"
    final Duration diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays} dias atrás';
    if (diff.inHours > 0) return '${diff.inHours} horas atrás';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min atrás';
    return 'Recém-criada'; // Default se nenhuma condição for atendida
  }

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority,
    required this.status,
    required this.createdAt,
    required this.userId,
    this.isCompleted = false,
    this.projectId,
    this.reminderTime,
    this.estimatedTime,
    this.timeSpent,
    this.progressPercentage,
    this.time, // <--- ADICIONADO ao construtor
  });

  // Construtor para criar uma Task a partir de um DocumentSnapshot do Firestore
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      priority: data['priority'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      projectId: data['projectId'],
      reminderTime: (data['reminderTime'] as Timestamp?)?.toDate(),
      estimatedTime: data['estimatedTime'],
      timeSpent: data['timeSpent'],
      progressPercentage: (data['progressPercentage'] as num?)?.toInt(),
      time: data['time'], // <--- LER ESTE CAMPO
    );
  }

  // Método para converter a Task para um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'isCompleted': isCompleted,
      'projectId': projectId,
      'reminderTime': reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'estimatedTime': estimatedTime,
      'timeSpent': timeSpent,
      'progressPercentage': progressPercentage,
      'time': time, // <--- ENVIAR ESTE CAMPO
    };
  }
}