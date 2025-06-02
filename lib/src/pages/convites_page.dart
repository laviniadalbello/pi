import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

class ConvitesPage extends StatefulWidget {
  const ConvitesPage({Key? key}) : super(key: key);

  @override
  State<ConvitesPage> createState() => _ConvitesPageState();
}

class _ConvitesPageState extends State<ConvitesPage> {
  final user = FirebaseAuth.instance.currentUser!;

  final List<String> _emailsConvidados = [];

  Future<void> aceitarConvite(String invitationId, String projectId) async {
    final userId = user.uid;
    // Atualiza status do convite
    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(invitationId)
        .update({'status': 'accepted'});

    // Adiciona userId aos membros do projeto
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .update({
      'members': FieldValue.arrayUnion([userId]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Convite aceito!')),
    );
    setState(() {}); // Atualiza a lista
  }

  Future<void> enviarConvite(String projetoId, String email) async {
    final fromUserId = FirebaseAuth.instance.currentUser!.uid;
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userSnap.docs.isEmpty) {
      print('Usuário não encontrado: $email');
      return;
    }

    print(
        'fromUserId: $fromUserId, auth.uid: ${FirebaseAuth.instance.currentUser!.uid}');
    await FirebaseFirestore.instance.collection('invitations').add({
      'projectId': projetoId,
      'fromUserId': fromUserId,
      'toUserEmail': email,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _enviarConvites(String projetoId, String fromUserId) async {
    for (final email in _emailsConvidados) {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnap.docs.isEmpty) {
        print('Usuário não encontrado: $email');
        continue;
      }

      await FirebaseFirestore.instance.collection('invitations').add({
        'projectId': projetoId,
        'fromUserId': fromUserId,
        'toUserEmail': email,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkPrimaryBg, // Deixa igual às outras telas
      appBar: AppBar(
        backgroundColor: kDarkSurface,
        elevation: 0,
        title: const Text(
          'Convites Pendentes',
          style: TextStyle(
            color: Colors.white, // Branco
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily:
                'Montserrat', // Troque para a fonte que preferir e que esteja no seu projeto
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invitations')
            .where('toUserEmail', isEqualTo: user.email)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum convite pendente.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final convite = docs[index];
              return Card(
                color: kDarkSurface,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    'Projeto: ${convite['projectId']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Convidado por: ${convite['fromUserId']}',
                    style: TextStyle(
                      color: kDarkTextSecondary,
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () =>
                        aceitarConvite(convite.id, convite['projectId']),
                    child: const Text('Aceitar'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
