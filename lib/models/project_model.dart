import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String color;
  final String userId;
  final String status;
  final List<dynamic> members; // Pode ser uma lista de Map<String, dynamic> para membros
  final Timestamp createdAt;
  final String? priority; // Adicionado do Firestore
  final String? dueDate; // Adicionado do Firestore
  final int? progressPercentage; // Adicionado do Firestore

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
    this.progressPercentage, // Adicionado ao construtor
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['title'] ?? '', // Alterado de 'name' para 'title' com base na imagem do Firestore
      description: data['description'] ?? '',
      color: data['color'] ?? 'FFCCCCCC', // Cor padrão cinza claro se não existir
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'ativo',
      members: data['members'] ?? [],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      priority: data['priority'],
      dueDate: data['dueDate'],
      progressPercentage: data['progressPercentage'], // Mapeia o campo do Firestore
    );
  }

  // Opcional: Método para converter o objeto Project de volta para um Map (útil para salvar/atualizar no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'title': name, // Usar 'title' para o campo no Firestore
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