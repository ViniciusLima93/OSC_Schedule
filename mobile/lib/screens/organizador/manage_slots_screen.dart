import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/social_action.dart';
import '../../state/app_state.dart';

class ManageSlotsScreen extends StatelessWidget {
  const ManageSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<AppState>().actions;

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar vagas')),
      body: actions.isEmpty
          ? const Center(child: Text('Nenhuma ação social cadastrada.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: actions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _SlotsCard(action: actions[index]),
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
                      onPressed: action.totalSlots <= action.bookedSlots
                          ? null
                          : () => appState.updateSlots(action.id, action.totalSlots - 1),
                    ),
                    Text('${action.totalSlots}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => appState.updateSlots(action.id, action.totalSlots + 1),
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
