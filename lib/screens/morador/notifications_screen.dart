import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final notifications = appState.notifications;
    final dateFormat = DateFormat('dd/MM HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (appState.unreadNotificationsCount > 0)
            TextButton(
              onPressed: appState.markAllNotificationsRead,
              child: const Text('Marcar todas como lidas'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('Nenhuma notificação por enquanto.'))
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: Icon(
                    notification.read
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: notification.read ? Colors.grey : Colors.teal,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notification.message),
                  trailing: Text(
                    dateFormat.format(notification.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () => appState.markNotificationRead(notification.id),
                );
              },
            ),
    );
  }
}
