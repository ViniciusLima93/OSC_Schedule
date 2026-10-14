import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../state/app_state.dart';
import 'morador/morador_home_screen.dart';
import 'organizador/organizador_home_screen.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.volunteer_activism, size: 72, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                'OSC Schedule',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplicativo de Agendamento Social',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              const Text(
                'Entrar como:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _chooseUser(context, UserRole.morador),
                icon: const Icon(Icons.person),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Morador'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _chooseUser(context, UserRole.organizador),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Organizador'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseUser(BuildContext context, UserRole role) async {
    final appState = context.read<AppState>();
    appState.loadUsers();

    final user = await showModalBottomSheet<AppUser>(
      context: context,
      showDragHandle: true,
      builder: (_) => _UserPicker(role: role),
    );
    if (user == null || !context.mounted) return;

    appState.login(user);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => role == UserRole.morador
            ? const MoradorHomeScreen()
            : const OrganizadorHomeScreen(),
      ),
    );
  }
}

class _UserPicker extends StatelessWidget {
  const _UserPicker({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final users = appState.users.where((u) => u.role == role).toList();
    final label = role == UserRole.morador ? 'morador' : 'organizador';

    Widget body;
    if (appState.loading && users.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (appState.error != null) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(appState.error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: appState.loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      );
    } else if (users.isEmpty) {
      body = Text('Nenhum $label cadastrado.');
    } else {
      body = ListView(
        shrinkWrap: true,
        children: users
            .map((u) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(u.name),
                  subtitle: Text(u.email),
                  onTap: () => Navigator.of(context).pop(u),
                ))
            .toList(),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecione o $label',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Flexible(child: body),
          ],
        ),
      ),
    );
  }
}
