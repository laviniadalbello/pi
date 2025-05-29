import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invite_model.dart';
import '../../services/invite_service.dart';

class InviteCard extends StatelessWidget {
  final Invite invite;
  
  const InviteCard({super.key, required this.invite});

  @override
  Widget build(BuildContext context) {
    final inviteService = Provider.of<InviteService>(context, listen: false);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Convite para o Projeto:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('ID do Projeto: ${invite.projectId}'),
            Text('De: ${invite.inviterId}'),
            const SizedBox(height: 12),
            const Text('Permissões:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Editar tarefas: ${invite.permissions['editTasks'] == true ? 'Sim' : 'Não'}'),
            Text('• Editar eventos: ${invite.permissions['editEvents'] == true ? 'Sim' : 'Não'}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _rejectInvite(context, inviteService),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Recusar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _acceptInvite(context, inviteService),
                  child: const Text('Aceitar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptInvite(BuildContext context, InviteService service) async {
    try {
      await service.acceptInvite(invite.id);
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite aceito com sucesso!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aceitar: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectInvite(BuildContext context, InviteService service) async {
    try {
      // Implemente a lógica de rejeição aqui
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite recusado')),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao recusar: ${e.toString()}')),
      );
    }
  }
}