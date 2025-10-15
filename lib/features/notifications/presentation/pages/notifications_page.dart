// lib/features/notifications/presentation/pages/notifications_page.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/gradient_card.dart';

/// Página de notificaciones con filtros y sistema de marcado
/// Placeholder temporal hasta implementar la funcionalidad completa
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedFilter = 'Todo';

  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'Evento creado',
      subtitle: 'Se creó "Cumpleaños de María"',
      time: 'hace 2 min',
      isRead: false,
    ),
    _NotificationItem(
      title: 'Recordatorio programado',
      subtitle: 'Reunión de trabajo mañana',
      time: 'hace 1 hora',
      isRead: true,
    ),
    _NotificationItem(
      title: 'Evento editado',
      subtitle: 'Se actualizó "Cita médica"',
      time: 'hace 3 horas',
      isRead: false,
    ),
    _NotificationItem(
      title: 'Evento eliminado',
      subtitle: 'Se eliminó "Evento de prueba"',
      time: 'hace 1 día',
      isRead: true,
    ),
    _NotificationItem(
      title: 'Evento eliminado',
      subtitle: 'Se eliminó "Evento de prueba"',
      time: 'hace 1 día',
      isRead: true,
    ),
    _NotificationItem(
      title: 'Evento eliminado',
      subtitle: 'Se eliminó "Evento de prueba"',
      time: 'hace 1 día',
      isRead: true,
    ),
    _NotificationItem(
      title: 'Evento eliminado',
      subtitle: 'Se eliminó "Evento de prueba"',
      time: 'hace 1 día',
      isRead: true,
    ),
    _NotificationItem(
      title: 'Evento eliminado',
      subtitle: 'Se eliminó "Evento de prueba"',
      time: 'hace 1 día',
      isRead: true,
    ),
  ];

  List<_NotificationItem> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Visto':
        return _notifications.where((n) => n.isRead).toList();
      case 'No Visto':
        return _notifications.where((n) => !n.isRead).toList();
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    final filters = ['Todo', 'Visto', 'No Visto'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          labelPadding: EdgeInsets.fromLTRB(4, 1, 4, 1),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          side: _selectedFilter == filter
                              ? null
                              : BorderSide(color: Colors.transparent),
                          backgroundColor: theme.colorScheme.surfaceContainer,
                          selectedColor: theme.colorScheme.primary.withOpacity(
                            0.2,
                          ),
                          checkmarkColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter
                                ? theme.colorScheme.onBackground
                                : theme.colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, size: 18),
            label: Text(
              'Marcar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('No hay notificaciones', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Las notificaciones aparecerán aquí',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: GradientCard(
            borderRadius: 0,
            gradient: LinearGradient(
              colors: notification.isRead
                  ? [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface,
                    ]
                  : [
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
            ),
            onTap: () => _markAsRead(index),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!notification.isRead) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: notification.isRead
                                    ? Colors.transparent
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  notification.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _markAsRead(int index) {
    final globalIndex = _notifications.indexOf(_filteredNotifications[index]);
    setState(() {
      _notifications[globalIndex].isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }
}

class _NotificationItem {
  final String title;
  final String subtitle;
  final String time;
  bool isRead;

  _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
  });
}
