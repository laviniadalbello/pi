import 'package:firebase_auth/firebase_auth.dart';
import '../models/invite_model.dart';
import '../repositories/invite_repository.dart';

class InviteService {
  final InviteRepository _repository;
  final FirebaseAuth _auth;

  InviteService(this._repository, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  // Método para enviar convite
  Future<void> sendProjectInvite({
    required String projectId,
    required String email,
    required bool canEditTasks,
    required bool canEditEvents,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Usuário não autenticado');

    final invite = Invite(
      id: '',
      projectId: projectId,
      inviteeEmail: email,
      inviterId: currentUser.uid,
      status: 'pending',
      permissions: {
        'editTasks': canEditTasks,
        'editEvents': canEditEvents,
      },
      createdAt: DateTime.now(),
    );
    
    await _repository.sendInvite(invite);
  }

  // Método para obter convites pendentes
  Stream<List<Invite>> watchPendingInvites() {
    final email = _auth.currentUser?.email;
    return email != null 
        ? _repository.getPendingInvites(email)
        : const Stream.empty();
  }

  // ADICIONE ESTE NOVO MÉTODO PARA ACEITAR CONVITE
  Future<void> acceptInvite(String inviteId) async {
    try {
      await _repository.acceptInvite(inviteId);
    } catch (e) {
      throw Exception('Falha ao aceitar convite: $e');
    }
  }
}