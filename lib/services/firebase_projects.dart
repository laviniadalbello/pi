import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProjects {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cria projeto 
  Future<void> createProject(String name, String adminId) async {
    await _firestore.collection('projects').add({
      'name': name,
      'admin': adminId,
      'members': [adminId],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Lista projetos dos usuarios/times ("Stream" em tempo real) n editar!!
  Stream<QuerySnapshot> getUserProjects(String userId) {

    return _firestore
        .collection('projects')
        .where('members', arrayContains: userId)
        .snapshots();
  }
}
