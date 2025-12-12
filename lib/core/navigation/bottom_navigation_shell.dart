// lib/core/navigation/bottom_navigation_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_gradients.dart';
import '../widgets/theme_dropdown.dart';
import '../constants/app_colors.dart';
import '../../features/timeline/presentation/cubit/timeline_cubit.dart';
import '../../features/events/presentation/cubit/eventos_cubit.dart';
import '../../features/notifications/presentation/cubit/notificaciones_cubit.dart';

/// Shell de navegación inferior con diseño moderno
/// Header fijo con gradiente y bottom navigation integrado
class BottomNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header fijo con gradiente y esquina inferior izquierda redondeada
          _buildFixedHeader(context),

          // Contenido con esquinas redondeadas
          Expanded(
            child: Stack(
              children: [
                // Capa 1: Fondo con gradiente (sin borderRadius)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppGradients.primary.colors.first,
                        AppGradients.primary.colors[1],
                      ],
                      stops: [0.5, 0.5],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                // Capa 2: Contenido con borderRadius y color del tema
                Container(
                  padding: EdgeInsets.only(
                    top: navigationShell.currentIndex == 2 ? 10 : 40,
                    bottom: navigationShell.currentIndex == 2 ? 40 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topRight: navigationShell.currentIndex == 0
                          ? Radius.circular(60)
                          : Radius.circular(0),
                      bottomLeft:
                          (navigationShell.currentIndex == 0 ||
                              navigationShell.currentIndex == 1)
                          ? Radius.circular(0)
                          : Radius.circular(40),
                      bottomRight:
                          (navigationShell.currentIndex == 0 ||
                              navigationShell.currentIndex == 1)
                          ? Radius.circular(0)
                          : Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Contenido scrolleable
                      Expanded(child: navigationShell),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation como overlay
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildFixedHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: navigationShell.currentIndex == 2
            ? Theme.of(context).scaffoldBackgroundColor
            : null,
        gradient: navigationShell.currentIndex == 2
            ? null
            : AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: navigationShell.currentIndex == 0
              ? Radius.circular(60)
              : Radius.circular(50),
          bottomRight: navigationShell.currentIndex == 0
              ? Radius.circular(0)
              : Radius.circular(50),
        ),
      ),
      padding: navigationShell.currentIndex == 2
          ? EdgeInsets.fromLTRB(30, 50, 40, 0)
          : EdgeInsets.fromLTRB(40, 50, 40, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con ThemeDropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getPageTitle(navigationShell.currentIndex),
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: navigationShell.currentIndex == 2
                      ? theme.colorScheme.onSurface
                      : AppColors.onStaticPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ThemeDropdown(currentIndex: navigationShell.currentIndex),
            ],
          ),
          // Saludo
          if (navigationShell.currentIndex == 0) ...[
            const SizedBox(height: 24),
            Text(
              '¡Hola! 👋',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: navigationShell.currentIndex == 2
                    ? theme.colorScheme.onSurface
                    : AppColors.onStaticPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (navigationShell.currentIndex < 2) ...[
            const SizedBox(height: 8),
            Text(
              _getPageSubtitle(navigationShell.currentIndex),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: navigationShell.currentIndex == 2
                    ? theme.colorScheme.onSurface.withOpacity(0.9)
                    : AppColors.onStaticPrimary.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: navigationShell.currentIndex > 1
          ? BoxDecoration(gradient: AppGradients.primary)
          : BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: navigationShell.currentIndex == 1 ? 15 : 30,
          bottom: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              0,
              Icons.home_outlined,
              Icons.home,
              'Inicio',
            ),
            _buildNavItem(
              context,
              1,
              Icons.event_outlined,
              Icons.event,
              'Eventos',
            ),
            _buildNavItem(
              context,
              2,
              Icons.notifications_outlined,
              Icons.notifications,
              'Notificaciones',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = navigationShell.currentIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(context, index),
        splashColor: Colors.white.withOpacity(0.9), // Efecto visual opcional
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: navigationShell.currentIndex == 2
                    ? AppColors.onStaticPrimary.withOpacity(
                        isSelected ? 1.0 : 0.6,
                      )
                    : theme.colorScheme.onSurface.withOpacity(
                        isSelected ? 1.0 : 0.6,
                      ),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                isSelected ? label : "",
                style: TextStyle(
                  color: navigationShell.currentIndex == 2
                      ? AppColors.onStaticPrimary.withOpacity(
                          isSelected ? 1.0 : 0.6,
                        )
                      : theme.colorScheme.onSurface.withOpacity(
                          isSelected ? 1.0 : 0.6,
                        ),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    if (index == 0) {
      // Timeline - Recargar para mostrar eventos nuevos
      context.read<TimelineCubit>().cargarTimeline();
    } else if (index == 1) {
      // Eventos
      context.read<EventosCubit>().cargarEventos();
    } else if (index == 2) {
      // Notificaciones
      context.read<NotificacionesCubit>().cargarNotificaciones();
    }
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'RemindMe';
      case 1:
        return 'Eventos';
      case 2:
        return 'Notificaciones';
      default:
        return 'RemindMe';
    }
  }

  String _getPageSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Esta es la cronologia de tus eventos';
      case 1:
        return 'Gestiona tus eventos';
      case 2:
        return 'Mantente informado';
      default:
        return 'Esta en la cronologia de tus eventos';
    }
  }
}
