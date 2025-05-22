import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTasks {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adicionar tasks ao projeto (nao mexer!!)
  Future<void> addProjectTask(
    String projectId,
    String title,
    String userId,
  ) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .add({
          'title': title,
          'createdBy': userId,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Listar tasks individuais do usuario (nao mexer!!)
  Stream<QuerySnapshot> getUserTasks(String userId) {
    return _firestore
        .collection('user_tasks')
        .doc(userId)
        .collection('tasks')
        .snapshots();
  }
}
