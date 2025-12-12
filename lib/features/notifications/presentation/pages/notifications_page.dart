// lib/features/notifications/presentation/pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/bottom_modal.dart';
import '../cubit/notificaciones_cubit.dart';
import '../../domain/usecases/obtener_notificaciones_filtradas.dart';
import 'dart:convert';

/// Página de notificaciones con filtros y sistema de marcado
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificacionesCubit, NotificacionesState>(
      listener: (context, state) {
        if (state is NotificacionesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildFilterChips(context, state),
            Expanded(child: _buildContent(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context, NotificacionesState state) {
    final theme = Theme.of(context);
    final filtroActual = state is NotificacionesLoaded
        ? state.filtroActual
        : FiltroNotificacion.todas;

    final filters = [
      {'label': 'Todo', 'filtro': FiltroNotificacion.todas},
      {'label': 'Visto', 'filtro': FiltroNotificacion.vistas},
      {'label': 'No Visto', 'filtro': FiltroNotificacion.noVistas},
    ];

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
                          label: Text(filter['label'].toString()),
                          labelPadding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
                          selected: filtroActual == filter['filtro'],
                          onSelected: (selected) {
                            context.read<NotificacionesCubit>().cambiarFiltro(
                              filter['filtro'] as FiltroNotificacion,
                            );
                          },
                          side: filtroActual == filter['filtro']
                              ? null
                              : const BorderSide(color: Colors.transparent),
                          backgroundColor: theme.colorScheme.surfaceContainer,
                          selectedColor: theme.colorScheme.primary.withOpacity(
                            0.2,
                          ),
                          checkmarkColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: filtroActual == filter['filtro']
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
            onPressed: () {
              context.read<NotificacionesCubit>().marcarTodas();
            },
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text(
              'Marcar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificacionesState state) {
    if (state is NotificacionesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NotificacionesError) {
      return _buildErrorState(context, state.message);
    }

    if (state is NotificacionesLoaded) {
      if (state.notificaciones.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () async {
          await context.read<NotificacionesCubit>().cargarNotificaciones();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          itemCount: state.notificaciones.length,
          itemBuilder: (context, index) {
            final notificacion = state.notificaciones[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: GradientCard(
                borderRadius: 0,
                gradient: LinearGradient(
                  colors: notificacion.marcada
                      ? [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surface,
                        ]
                      : [
                          Theme.of(context).colorScheme.tertiary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                ),
                onTap: () {
                  _showNotificationDetail(
                    context,
                    notificacion.id,
                    notificacion.titulo,
                    notificacion.detalle,
                  );

                  // Marcar como leída si no lo está
                  if (!notificacion.marcada) {
                    context.read<NotificacionesCubit>().marcar(
                      notificacion.id,
                      true,
                    );
                  }
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (!notificacion.marcada) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: notificacion.marcada
                                        ? Colors.transparent
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  notificacion.titulo,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: notificacion.marcada
                                            ? FontWeight.normal
                                            : FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.only(
                              left: notificacion.marcada ? 0 : 14,
                            ),
                            child: Text(
                              _getSubtitleFromDetalle(notificacion.detalle),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(notificacion.fechaHora),
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
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Error', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<NotificacionesCubit>().cargarNotificaciones();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetail(
    BuildContext context,
    String id,
    String titulo,
    String detalleJson,
  ) {
    final theme = Theme.of(context);

    // Parsear el JSON del detalle
    Map<String, dynamic> detalle = {};
    try {
      detalle = jsonDecode(detalleJson);
    } catch (e) {
      detalle = {'raw': detalleJson};
    }

    BottomModal.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titulo, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...detalle.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getSubtitleFromDetalle(String detalleJson) {
    try {
      final detalle = jsonDecode(detalleJson);
      if (detalle is Map) {
        if (detalle.containsKey('nombre')) {
          return detalle['nombre'];
        }
        return detalle.values.first.toString();
      }
      return detalleJson;
    } catch (e) {
      return detalleJson;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hace instantes';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} hrs';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    }
  }
}
