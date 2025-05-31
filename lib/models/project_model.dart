// lib/models/project.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String color;
  final String userId;
  final String status;
  final List<dynamic> members;
  final Timestamp createdAt;
  final String? priority;
  final String? dueDate;
  final int? progressPercentage;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.userId,
    required this.status,
    required this.members,
    required this.createdAt,
    this.priority,
    this.dueDate,
    this.progressPercentage,
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '', // Usar 'name'
      description: data['description'] ?? '',
      color: data['color'] ?? 'FFCCCCCC',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'ativo',
      members: List<dynamic>.from(data['members'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      priority: data['priority'],
      dueDate: data['dueDate'],
      progressPercentage: (data['progressPercentage'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name, // Usar 'name'
      'description': description,
      'color': color,
      'userId': userId,
      'status': status,
      'members': members,
      'createdAt': createdAt,
      'priority': priority,
      'dueDate': dueDate,
      'progressPercentage': progressPercentage,
    };
  }
}