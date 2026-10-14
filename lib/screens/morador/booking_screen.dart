import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/remote_content.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.actionId});

  final int actionId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final Set<String> _confirmedDocuments = {};
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final action = appState.actionById(widget.actionId);
    if (action == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Ação não encontrada.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Realizar agendamento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(action.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Morador',
              border: OutlineInputBorder(),
            ),
            child: Text(appState.currentUser?.name ?? ''),
          ),
          const SizedBox(height: 24),
          const Text(
            'Verificar documentos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            action.requiredDocuments.isEmpty
                ? 'Esta ação não exige documentos.'
                : 'Confirme que você possui os documentos abaixo para concluir o agendamento.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...action.requiredDocuments.map(
            (doc) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(doc),
              value: _confirmedDocuments.contains(doc),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _confirmedDocuments.add(doc);
                  } else {
                    _confirmedDocuments.remove(doc);
                  }
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _submitting ? null : () => _submit(context, appState),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmar agendamento'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, AppState appState) async {
    setState(() => _submitting = true);
    final bool confirmed;
    try {
      confirmed = await appState.bookAppointment(
        actionId: widget.actionId,
        documentIds: _confirmedDocuments.toList(),
      );
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
      return;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(confirmed ? 'Agendamento confirmado' : 'Documentos pendentes'),
        content: Text(
          confirmed
              ? 'Seu agendamento foi realizado com sucesso!'
              : 'É necessário confirmar todos os documentos obrigatórios para concluir o agendamento.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (confirmed) {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
