import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import 'booking_screen.dart';

class ActionDetailScreen extends StatelessWidget {
  const ActionDetailScreen({super.key, required this.actionId});

  final String actionId;

  @override
  Widget build(BuildContext context) {
    final action = context.watch<AppState>().actionById(actionId);
    final dateFormat = DateFormat('dd/MM/yyyy');

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
          child: FilledButton.icon(
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
              child: Text(action.isFull ? 'Vagas esgotadas' : 'Realizar agendamento'),
            ),
          ),
        ),
      ),
    );
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
