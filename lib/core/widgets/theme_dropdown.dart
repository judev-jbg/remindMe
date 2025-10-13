// lib/core/widgets/theme_dropdown.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/cubit/theme_cubit.dart';
import '../constants/app_colors.dart';

/// Dropdown para selección de tema con diseño moderno
/// Permite cambiar entre automático, claro y oscuro
class ThemeDropdown extends StatelessWidget {
  const ThemeDropdown({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return PopupMenuButton<ThemeMode>(
          icon: Icon(
            Icons.palette_outlined,
            color: currentIndex == 2
                ? theme.colorScheme.onSurface
                : AppColors.onStaticPrimary,
          ),
          tooltip: 'Cambiar tema',
          onSelected: (ThemeMode mode) {
            context.read<ThemeCubit>().changeTheme(mode);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ThemeMode.system,
              child: _ThemeMenuItem(
                icon: Icons.brightness_auto_outlined,
                title: 'Automático',
                subtitle: 'Según el sistema',
                isSelected: state.themeMode == ThemeMode.system,
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.light,
              child: _ThemeMenuItem(
                icon: Icons.light_mode_outlined,
                title: 'Claro',
                subtitle: 'Tema claro',
                isSelected: state.themeMode == ThemeMode.light,
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: _ThemeMenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'Oscuro',
                subtitle: 'Tema oscuro',
                isSelected: state.themeMode == ThemeMode.dark,
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

class _ThemeMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;

  const _ThemeMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}
