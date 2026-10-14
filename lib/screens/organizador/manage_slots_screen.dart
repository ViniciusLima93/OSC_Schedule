import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/social_action.dart';
import '../../state/app_state.dart';
import '../../widgets/remote_content.dart';

class ManageSlotsScreen extends StatelessWidget {
  const ManageSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final actions = appState.myActions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar vagas'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: appState.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RemoteContent(
        isEmpty: actions.isEmpty,
        emptyMessage: 'Nenhuma ação social cadastrada.',
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: actions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _SlotsCard(action: actions[index]),
        ),
      ),
    );
  }
}

class _SlotsCard extends StatelessWidget {
  const _SlotsCard({required this.action});

  final SocialAction action;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    Future<void> update(int total) async {
      try {
        await appState.updateSlots(action.id, total);
      } catch (e) {
        if (context.mounted) showErrorSnackBar(context, e);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${action.bookedSlots} ocupada(s) de ${action.totalSlots} vaga(s)'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total de vagas', style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: action.totalSlots <= action.bookedSlots ||
                              action.totalSlots <= 1
                          ? null
                          : () => update(action.totalSlots - 1),
                    ),
                    Text('${action.totalSlots}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => update(action.totalSlots + 1),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
