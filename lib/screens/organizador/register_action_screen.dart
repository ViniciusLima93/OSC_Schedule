import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';

class RegisterActionScreen extends StatefulWidget {
  const RegisterActionScreen({super.key});

  @override
  State<RegisterActionScreen> createState() => _RegisterActionScreenState();
}

class _RegisterActionScreenState extends State<RegisterActionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _slotsController = TextEditingController();
  final _documentsController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _slotsController.dispose();
    _documentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar ação social')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Local',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o local' : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null ? 'Selecionar data' : dateFormat.format(_selectedDate!),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _slotsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade de vagas',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Informe um número válido de vagas';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _documentsController,
              decoration: const InputDecoration(
                labelText: 'Documentos exigidos (separados por vírgula)',
                hintText: 'Ex: RG, CPF, Comprovante de residência',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe ao menos um documento' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _submit(context),
              icon: const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Cadastrar ação social'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma data para a ação social')),
      );
      return;
    }

    final documents = _documentsController.text
        .split(',')
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toList();

    context.read<AppState>().registerAction(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          dateTime: _selectedDate!,
          totalSlots: int.parse(_slotsController.text),
          requiredDocuments: documents,
        );

    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _slotsController.clear();
    _documentsController.clear();
    setState(() => _selectedDate = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ação social cadastrada com sucesso!')),
    );
  }
}
