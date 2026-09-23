import 'package:flutter/material.dart';

import 'manage_slots_screen.dart';
import 'register_action_screen.dart';
import 'view_appointments_screen.dart';

class OrganizadorHomeScreen extends StatefulWidget {
  const OrganizadorHomeScreen({super.key});

  @override
  State<OrganizadorHomeScreen> createState() => _OrganizadorHomeScreenState();
}

class _OrganizadorHomeScreenState extends State<OrganizadorHomeScreen> {
  int _currentIndex = 0;

  static const _screens = [
    RegisterActionScreen(),
    ManageSlotsScreen(),
    ViewAppointmentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Cadastrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_seat_outlined),
            selectedIcon: Icon(Icons.event_seat),
            label: 'Vagas',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Agendamentos',
          ),
        ],
      ),
    );
  }
}
