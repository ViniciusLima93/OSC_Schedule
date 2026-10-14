import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/remote_content.dart';
import 'booking_screen.dart';

class ActionDetailScreen extends StatelessWidget {
  const ActionDetailScreen({super.key, required this.actionId});

  final int actionId;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final action = appState.actionById(actionId);
    if (action == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Ação não encontrada.')),
      );
    }
    final myAppointment = appState.myAppointmentFor(actionId);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(action.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(action.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          _InfoRow(icon: Icons.location_on, label: 'Local', value: action.location),
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Data',
            value: dateFormat.format(action.dateTime),
          ),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Organizador',
            value: action.organizerName,
          ),
          _InfoRow(
            icon: Icons.event_seat,
            label: 'Vagas',
            value: '${action.bookedSlots}/${action.totalSlots} ocupadas',
          ),
          const SizedBox(height: 24),
          const Text(
            'Documentos necessários (Verificação de documentos)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (action.requiredDocuments.isEmpty)
            const Text('Nenhum documento exigido.'),
          ...action.requiredDocuments.map(
            (doc) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(doc),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: myAppointment != null
              ? OutlinedButton.icon(
                  onPressed: () => _cancel(context, myAppointment.id),
                  icon: const Icon(Icons.event_busy),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Cancelar agendamento'),
                  ),
                )
              : FilledButton.icon(
                  onPressed: action.isFull
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(actionId: action.id),
                            ),
                          );
                        },
                  icon: const Icon(Icons.event_available),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                        action.isFull ? 'Vagas esgotadas' : 'Realizar agendamento'),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, int appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar agendamento'),
        content: const Text('Deseja mesmo cancelar sua inscrição nesta ação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    try {
      await context.read<AppState>().cancelAppointment(appointmentId);
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
