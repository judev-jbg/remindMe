// lib/core/navigation/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/timeline/presentation/pages/timeline_page.dart';
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import 'bottom_navigation_shell.dart';

/// Configuración de rutas de la aplicación usando go_router
/// Implementa navegación con bottom navigation bar
class AppRouter {
  static const String timeline = '/';
  static const String events = '/events';
  static const String notifications = '/notifications';

  static final GoRouter router = GoRouter(
    initialLocation: timeline,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Página Principal (Timeline)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: timeline,
                name: 'timeline',
                builder: (context, state) => const TimelinePage(),
              ),
            ],
          ),

          // Mis Eventos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: events,
                name: 'events',
                builder: (context, state) => const EventsPage(),
              ),
            ],
          ),

          // Notificaciones
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: notifications,
                name: 'notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _ErrorPage(),
  );
}

/// Página de error personalizada
class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La página que buscas no existe',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go(AppRouter.timeline),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
