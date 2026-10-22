import 'package:dsrevis/core/theme/app_theme.dart';
import 'package:dsrevis/features/auth/presentation/pages/auth_gate.dart';
import 'package:dsrevis/features/shared/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'D.S Revis',
      theme: AppTheme.lightTheme, // Applique votre charte graphique uniforme
      home: _showSplash
          ? SplashScreen(onFinished: () => setState(() => _showSplash = false))
          : const AuthGate(), // Redirige directement vers l'AuthGate (Vérification SQLite locale)
    );
  }
}