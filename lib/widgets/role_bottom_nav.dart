import 'package:flutter/material.dart';
import '../models/user_model.dart';

class RoleBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserRole role;

  const RoleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.agent:
        return _buildAgentNav();
      case UserRole.br:
        return _buildBrNav();
      case UserRole.legal:
        return _buildLegalNav(); 
      case UserRole.manager:
        return _buildManagerNav();
      default:
        return _buildDefaultNav();
    }
  }

  // ================== LEGAL BOTTOM NAV ==================
  BottomNavigationBar _buildLegalNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description),
          label: 'Dokumen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_outlined),
          activeIcon: Icon(Icons.task),
          label: 'Tugas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Sistem',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  // Agent Nav
  BottomNavigationBar _buildAgentNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Listing'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }

  // BR Nav
  BottomNavigationBar _buildBrNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'MOU'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Stock'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Report'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }

  // Manager & Default (bisa diubah nanti)
  BottomNavigationBar _buildManagerNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Sales',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description),
          label: 'MOUS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Properties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  BottomNavigationBar _buildDefaultNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E88E5),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}