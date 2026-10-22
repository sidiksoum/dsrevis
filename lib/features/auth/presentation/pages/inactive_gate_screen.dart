import 'package:dsrevis/features/auth/presentation/pages/auth_screen.dart';
import 'package:dsrevis/features/home/presentation/pages/main_shell.dart';
import 'package:dsrevis/features/shared/data/sample_data.dart';
import 'package:dsrevis/core/services/database_helper.dart'; 
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isCheckingLocalSession = true;

  @override
  void initState() {
    super.initState();
    _checkOfflineSession();
  }

  void _checkOfflineSession() async {
    final localUser = await DatabaseHelper.instance.getUserSession();
    if (localUser != null) {
      currentUser = localUser;
    }
    setState(() => _isCheckingLocalSession = false);
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLocalSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentUser == null) {
      return AuthScreen(
        onContinue: () {
          currentUser = AppUser(name: "Invité INFAS", email: "guest@infas.com", level: "Licence 1", filiere: "IDE", premium: false, isActive: true);
          _rebuild();
        },
        onLoggedIn: (user) {
          currentUser = user;
          _rebuild();
        },
      );
    }

    return MainShell(
      onLogout: () async {
        currentUser = null;
        _rebuild();
      },
    );
  }
}