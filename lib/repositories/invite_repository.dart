import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invite_model.dart';

class InviteRepository {
  final FirebaseFirestore _firestore;

  InviteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> sendInvite(Invite invite) async {
    await _firestore.collection('invites').add(invite.toMap());
  }

  Stream<List<Invite>> getPendingInvites(String email) {
    return _firestore
        .collection('invites')
        .where('inviteeEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Invite.fromFirestore).toList());
  }

  Future<void> acceptInvite(String inviteId) async {
    await _firestore.collection('invites').doc(inviteId).update({
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}