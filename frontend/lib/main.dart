import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/design_system.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: DelhiveryApp()));
}

class DelhiveryApp extends StatelessWidget {
  const DelhiveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delhivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: DesignSystem.primary,
        scaffoldBackgroundColor: DesignSystem.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DesignSystem.primary,
          primary: DesignSystem.primary,
          secondary: DesignSystem.accent,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
