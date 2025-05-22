import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePermissions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verifica se o usuario pode editar e adicionar as tasks ao projeto (nao mexer!!)
  Future<bool> canUserEdit(String projectId, String userId) async {
    DocumentSnapshot doc =
        await _firestore
            .collection('permissions')
            .doc('${projectId}_$userId')
            .get();
    return doc.exists && doc['canEdit'] == true;
  }
}
