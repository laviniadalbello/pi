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

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.status = 'pending', // Padrão
    required this.createdAt,
    required this.userId,
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
    };
  }
}