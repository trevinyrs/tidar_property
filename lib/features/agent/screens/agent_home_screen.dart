import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidar_property/models/user_model.dart';
import '../../../core/providers/user_provider.dart';
import '../../../widgets/role_bottom_nav.dart';
import 'property_list_screen.dart';
import 'agent_profile_screen.dart';
import 'agent_favorite_screen.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PropertyListScreen(),           // Marketplace Utama
    const AgentFavoriteScreen(),          // Favorit
    const AgentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: RoleBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        role: UserRole.agent,
      ),
    );
  }
}