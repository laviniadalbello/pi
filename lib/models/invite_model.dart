import 'package:cloud_firestore/cloud_firestore.dart';

class Invite {
  final String id;
  final String projectId;
  final String inviteeEmail;
  final String inviterId;
  final String status;
  final Map<String, bool> permissions;
  final DateTime createdAt;

  Invite({
    required this.id,
    required this.projectId,
    required this.inviteeEmail,
    required this.inviterId,
    required this.status,
    required this.permissions,
    required this.createdAt,
  });

  factory Invite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invite(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      inviteeEmail: data['inviteeEmail'] ?? '',
      inviterId: data['inviterId'] ?? '',
      status: data['status'] ?? 'pending',
      permissions: Map<String, bool>.from(data['permissions'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Adicione este método para converter o objeto em Map
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'inviteeEmail': inviteeEmail,
      'inviterId': inviterId,
      'status': status,
      'permissions': permissions,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}