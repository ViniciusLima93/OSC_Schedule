import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/social_action.dart';
import '../../state/app_state.dart';
import '../../widgets/remote_content.dart';
import 'action_detail_screen.dart';

class ActionsListScreen extends StatelessWidget {
  const ActionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final actions = appState.actions.where((a) => !a.isPast).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ações Sociais'),
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
        emptyMessage: 'Nenhuma ação social disponível.',
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: actions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _ActionCard(
              action: action,
              booked: appState.myAppointmentFor(action.id) != null,
            );
          },
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.booked});

  final SocialAction action;
  final bool booked;

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
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(DateFormat('dd/MM/yyyy HH:mm').format(action.dateTime),
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
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
                  if (booked)
                    const Chip(
                      avatar: Icon(Icons.check_circle, size: 18),
                      label: Text('Inscrito'),
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
