import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Mostra carregamento/erro da última sincronização com o servidor e
/// permite puxar para atualizar. Quando há dados, exibe [child].
class RemoteContent extends StatelessWidget {
  const RemoteContent({
    super.key,
    required this.isEmpty,
    required this.emptyMessage,
    required this.child,
  });

  final bool isEmpty;
  final String emptyMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (isEmpty && appState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isEmpty && appState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(appState.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: appState.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: appState.refresh,
      child: isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 160),
                Center(child: Text(emptyMessage)),
              ],
            )
          : child,
    );
  }
}

/// Exibe a mensagem de erro de uma operação no servidor.
void showErrorSnackBar(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red.shade700,
    ),
  );
}
