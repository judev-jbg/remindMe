// lib/features/timeline/presentation/pages/timeline_page.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/gradient_card.dart';

/// Página principal que muestra el timeline de 7 eventos
/// Diseñada para trabajar con el header fijo del BottomNavigationShell
class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Timeline de 7 cards con padding adecuado
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 10,
            bottom: 10,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildTimelineCard(context, index),
              ),
              childCount: 7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isToday = index == 3; // El índice 3 siempre es "hoy"
    final isPast = index < 3;

    // Colores especiales para diferentes tipos de cards
    Color backgroundColor;
    if (isToday) {
      backgroundColor = theme.brightness == Brightness.light
          ? const Color(0xFFE8F4FD)
          : const Color(0xFF1A365D);
    } else if (isPast) {
      backgroundColor = theme.brightness == Brightness.light
          ? const Color(0xFFF8F9FA)
          : const Color(0xFF2D2D2D);
    } else {
      backgroundColor = theme.colorScheme.surface;
    }

    return GradientCard(
      gradient: LinearGradient(colors: [backgroundColor, backgroundColor]),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getCardTitle(index),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'HOY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getCardDate(index),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getCardTitle(int index) {
    final titles = [
      'Evento Pasado 3',
      'Evento Pasado 2',
      'Evento Pasado 1',
      'Evento de Hoy',
      'Evento Futuro 1',
      'Evento Futuro 2',
      'Evento Futuro 3',
    ];
    return titles[index];
  }

  String _getCardDate(int index) {
    final dates = [
      'Hace 3 días',
      'Hace 2 días',
      'Ayer',
      'Hoy',
      'Mañana',
      'En 2 días',
      'En 3 días',
    ];
    return dates[index];
  }
}
