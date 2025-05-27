// lib/models/task.dart
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final bool isCompleted; // <--- ADICIONAR ESTE CAMPO
  final String? projectId; // <--- ADICIONAR ESTE CAMPO (se usado)
  final DateTime? reminderTime; // <--- ADICIONAR ESTE CAMPO
  final String? estimatedTime; // <--- ADICIONAR ESTE CAMPO
  final String? timeSpent; // <--- ADICIONAR ESTE CAMPO
  final int?
      progressPercentage; // <--- ADICIONAR ESTE CAMPO (assumindo int para 'number')

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.status = 'pending',
    required this.createdAt,
    required this.userId,
    this.isCompleted = false, // <--- ADICIONAR COM VALOR DEFAULT
    this.projectId, // <--- ADICIONAR
    this.reminderTime, // <--- ADICIONAR
    this.estimatedTime, // <--- ADICIONAR
    this.timeSpent, // <--- ADICIONAR
    this.progressPercentage, // <--- ADICIONAR
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
      isCompleted: data['isCompleted'] ?? false, // <--- LER ESTE CAMPO
      projectId: data['projectId'], // <--- LER ESTE CAMPO
      reminderTime:
          (data['reminderTime'] as Timestamp?)?.toDate(), // <--- LER ESTE CAMPO
      estimatedTime: data['estimatedTime'], // <--- LER ESTE CAMPO
      timeSpent: data['timeSpent'], // <--- LER ESTE CAMPO
      progressPercentage: (data['progressPercentage'] as num?)
          ?.toInt(), // <--- LER ESTE CAMPO (cast para int)
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
      'isCompleted': isCompleted, // <--- ENVIAR ESTE CAMPO
      'projectId': projectId, // <--- ENVIAR ESTE CAMPO
      'reminderTime': reminderTime != null
          ? Timestamp.fromDate(reminderTime!)
          : null, // <--- ENVIAR ESTE CAMPO
      'estimatedTime': estimatedTime, // <--- ENVIAR ESTE CAMPO
      'timeSpent': timeSpent, // <--- ENVIAR ESTE CAMPO
      'progressPercentage': progressPercentage, // <--- ENVIAR ESTE CAMPO
    };
  }
}
