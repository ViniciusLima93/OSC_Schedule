import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../state/app_state.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.actionId});

  final String actionId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Set<String> _confirmedDocuments;

  @override
  void initState() {
    super.initState();
    _confirmedDocuments = {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final action = appState.actionById(widget.actionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Realizar agendamento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(action.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Informe seu nome' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Verificar documentos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Confirme que você possui os documentos abaixo para concluir o agendamento.',
              style: TextStyle(color: Colors.grey),
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => _submit(context, appState, action.requiredDocuments),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Confirmar agendamento'),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context, AppState appState, List<String> required) {
    if (!_formKey.currentState!.validate()) return;

    final appointment = appState.bookAppointment(
      actionId: widget.actionId,
      moradorName: _nameController.text.trim(),
      documentIds: _confirmedDocuments.toList(),
    );

    final confirmed = appointment.status == AppointmentStatus.confirmed;

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
