import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/social_action.dart';
import '../../state/app_state.dart';
import 'action_detail_screen.dart';

class ActionsListScreen extends StatelessWidget {
  const ActionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<AppState>().actions;

    return Scaffold(
      appBar: AppBar(title: const Text('Ações Sociais')),
      body: actions.isEmpty
          ? const Center(child: Text('Nenhuma ação social disponível.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: actions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final action = actions[index];
                return _ActionCard(action: action);
              },
            ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final SocialAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ActionDetailScreen(actionId: action.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(action.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(action.location,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Chip(
                    label: Text(
                      action.isFull
                          ? 'Vagas esgotadas'
                          : '${action.availableSlots} vaga(s) disponível(is)',
                    ),
                    backgroundColor:
                        action.isFull ? Colors.red.shade50 : Colors.teal.shade50,
                    labelStyle: TextStyle(
                      color: action.isFull ? Colors.red.shade700 : Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
