import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/role_selector_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'OSC Schedule',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const RoleSelectorScreen(),
      ),
    );
  }
}
