import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import 'actions_list_screen.dart';
import 'notifications_screen.dart';

class MoradorHomeScreen extends StatefulWidget {
  const MoradorHomeScreen({super.key});

  @override
  State<MoradorHomeScreen> createState() => _MoradorHomeScreenState();
}

class _MoradorHomeScreenState extends State<MoradorHomeScreen> {
  int _currentIndex = 0;

  static const _screens = [
    ActionsListScreen(),
    NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<AppState>().unreadNotificationsCount;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'Ações Sociais',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Notificações',
          ),
        ],
      ),
    );
  }
}
