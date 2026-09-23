import 'package:flutter/material.dart';

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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MoradorHomeScreen()),
                  );
                },
                icon: const Icon(Icons.person),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Morador'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrganizadorHomeScreen()),
                  );
                },
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
}
