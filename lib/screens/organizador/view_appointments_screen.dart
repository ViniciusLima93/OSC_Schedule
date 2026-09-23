import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../state/app_state.dart';

class ViewAppointmentsScreen extends StatelessWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final appointments = appState.appointments.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Visualizar agendamentos')),
      body: appointments.isEmpty
          ? const Center(child: Text('Nenhum agendamento realizado ainda.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final action = appState.actionById(appointment.actionId);
                return Card(
                  child: ListTile(
                    title: Text(appointment.moradorName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(action.title),
                        Text(dateFormat.format(appointment.createdAt),
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: _StatusChip(status: appointment.status),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    switch (status) {
      case AppointmentStatus.confirmed:
        label = 'Confirmado';
        color = Colors.teal;
        break;
      case AppointmentStatus.pending:
        label = 'Pendente';
        color = Colors.orange;
        break;
      case AppointmentStatus.cancelled:
        label = 'Cancelado';
        color = Colors.red;
        break;
    }
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}
