// lib/core/navigation/bottom_navigation_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/theme_dropdown.dart';

/// Shell de navegación inferior con diseño moderno
/// Integra el dropdown de temas en el AppBar
class BottomNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(navigationShell.currentIndex)),
        centerTitle: false,
        actions: [const ThemeDropdown(), const SizedBox(width: 8)],
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => _onTap(context, index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_outlined),
                  selectedIcon: Icon(Icons.event),
                  label: 'Eventos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: 'Notificaciones',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      // Si estamos en la misma página, hacer scroll to top
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'RemindMe';
      case 1:
        return 'Mis Eventos';
      case 2:
        return 'Notificaciones';
      default:
        return 'RemindMe';
    }
  }
}
