import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../state/app_state.dart';
import '../../widgets/remote_content.dart';

class ViewAppointmentsScreen extends StatelessWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final appointments = appState.appointments.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar agendamentos'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: appState.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RemoteContent(
        isEmpty: appointments.isEmpty,
        emptyMessage: 'Nenhum agendamento realizado ainda.',
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Card(
              child: ListTile(
                title: Text(appointment.moradorName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.actionTitle),
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
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AppointmentStatus.confirmed => ('Confirmado', Colors.teal),
      AppointmentStatus.cancelled => ('Cancelado', Colors.red),
    };
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}
