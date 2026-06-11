import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart'; // nanti kita buat
import '../../models/user_model.dart';
import '../../core/services/auth_service.dart';

// Home Screen tiap role (nanti kita buat)
import '../../features/agent/screens/agent_home_screen.dart';
import '../../features/br/screens/br_home_screen.dart';
import '../../features/legal/screens/legal_home_screen.dart';
import '../../features/manager/screens/manager_home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: AuthService().userStream,   // ← pakai yang sudah kita buat di auth_service
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Belum login
        if (user == null) {
          return const LoginScreen();
        }

        // Redirect berdasarkan role
        switch (user.role) {
          case UserRole.agent:
            return const AgentHomeScreen();
          case UserRole.br:
            return const BrHomeScreen();
          case UserRole.legal:
            return const LegalHomeScreen();
          case UserRole.manager:
            return const ManagerHomeScreen();
        }
      },
    );
  }
}