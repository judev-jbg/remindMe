// lib/features/timeline/presentation/pages/timeline_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/bottom_modal.dart';
import '../cubit/timeline_cubit.dart';
import '../../../events/domain/entities/evento.dart';
import '../../../events/domain/services/recordatorio_calculator.dart';

/// Página principal que muestra el timeline de 7 eventos
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // No mantener el estado

  @override
  void initState() {
    super.initState();
    // Cargar timeline al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimelineCubit>().cargarTimeline();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    return BlocConsumer<TimelineCubit, TimelineState>(
      listener: (context, state) {
        if (state is TimelineError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is TimelineLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TimelineError) {
          return _buildErrorState(context, state.message);
        }

        if (state is TimelineLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<TimelineCubit>().cargarTimeline();
            },
            child: CustomScrollView(
              slivers: [
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
                        child: _buildTimelineCard(
                          context,
                          state.timeline[index],
                          index,
                        ),
                      ),
                      childCount: state.timeline.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
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
              context.read<TimelineCubit>().cargarTimeline();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    TimelineSlot slot,
    int index,
  ) {
    if (!slot.visible) {
      return const SizedBox.shrink();
    }

    final isToday = slot.esHoy;
    final isPast = index < 3; // Índices 0,1,2 son pasados

    // Si no hay eventos, mostrar mensaje
    if (slot.mensajeVacio != null) {
      return _buildEmptyDayCard(context, slot.mensajeVacio!, isToday, isPast);
    }

    // Si hay un solo evento
    if (slot.eventos!.length == 1) {
      final evento = slot.eventos!.first;
      final fechaRelevante = slot.fechasRelevantes?[evento.id];
      return _buildSingleEventCard(
        context,
        evento,
        isToday,
        isPast,
        fechaRelevante,
      );
    }

    // Si hay múltiples eventos
    return _buildMultipleEventsCard(
      context,
      slot.eventos!,
      slot.fecha!,
      isToday,
      isPast,
      slot.fechasRelevantes,
    );
  }

  Widget _buildEmptyDayCard(
    BuildContext context,
    String message,
    bool isToday,
    bool isPast,
  ) {
    final theme = Theme.of(context);

    // Determinar color de fondo según el estado
    Color backgroundColor;
    if (isToday) {
      backgroundColor = theme.colorScheme.tertiaryContainer;
    } else if (isPast) {
      backgroundColor = theme.colorScheme.surfaceContainerLow;
    } else {
      backgroundColor =
          theme.cardTheme.color ?? theme.colorScheme.surfaceContainer;
    }

    return GestureDetector(
      onDoubleTap: () {
        // Doble tap no hace nada en días vacíos
      },
      child: GradientCard(
        gradient: LinearGradient(colors: [backgroundColor, backgroundColor]),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.colorScheme.primary
                        : isPast
                        ? theme.colorScheme.outline.withValues(alpha: 0.3)
                        : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? theme.colorScheme.primary
                          : isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                _formatDate(DateTime.now()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isPast
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleEventCard(
    BuildContext context,
    Evento evento,
    bool isToday,
    bool isPast,
    DateTime? fechaRelevante,
  ) {
    final theme = Theme.of(context);

    // Determinar color de fondo según el estado
    Color backgroundColor;
    if (isToday) {
      backgroundColor = theme.colorScheme.tertiaryContainer;
    } else if (isPast) {
      backgroundColor = theme.colorScheme.surfaceContainerLow;
    } else {
      backgroundColor =
          theme.cardTheme.color ?? theme.colorScheme.surfaceContainer;
    }

    return GestureDetector(
      onTap: () {
        _showEventDetailModal(context, evento, fechaRelevante);
      },
      child: GradientCard(
        gradient: LinearGradient(colors: [backgroundColor, backgroundColor]),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.colorScheme.primary
                        : isPast
                        ? theme.colorScheme.outline.withValues(alpha: 0.3)
                        : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    evento.nombre,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? theme.colorScheme.primary
                          : isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(fechaRelevante ?? evento.fecha),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (evento.tipo != TipoEvento.otro) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getIconForTipo(evento.tipo),
                          size: 16,
                          color: isPast
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          evento.tipo.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isPast
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleEventsCard(
    BuildContext context,
    List<Evento> eventos,
    DateTime fecha,
    bool isToday,
    bool isPast,
    Map<String, DateTime>? fechasRelevantes,
  ) {
    final theme = Theme.of(context);

    // Determinar color de fondo según el estado
    Color backgroundColor;
    if (isToday) {
      backgroundColor = theme.colorScheme.tertiaryContainer;
    } else if (isPast) {
      backgroundColor = theme.colorScheme.surfaceContainerLow;
    } else {
      backgroundColor =
          theme.cardTheme.color ?? theme.colorScheme.surfaceContainer;
    }

    return GestureDetector(
      onTap: () {
        _showMultipleEventsModal(context, eventos, fecha, fechasRelevantes);
      },
      child: GradientCard(
        gradient: LinearGradient(colors: [backgroundColor, backgroundColor]),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.colorScheme.primary
                        : isPast
                        ? theme.colorScheme.outline.withValues(alpha: 0.3)
                        : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${eventos.length} eventos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? theme.colorScheme.primary
                          : isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(fecha),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...eventos
                      .take(2)
                      .map(
                        (evento) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: isPast
                                    ? theme.colorScheme.onSurface.withValues(
                                        alpha: 0.2,
                                      )
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  evento.nombre,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isPast
                                        ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.2)
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (eventos.length > 2)
                    Text(
                      '+${eventos.length - 2} más',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPast
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetailModal(
    BuildContext context,
    Evento evento,
    DateTime? fechaRelevante,
  ) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('EEE. dd \'de\' MMMM \'de\' yyyy', 'es_ES');
    final ahora = DateTime.now();

    // Calcular años cumplidos solo para cumpleaños y aniversarios
    int? anosCumplidos;
    if (evento.tipo == TipoEvento.cumpleanos ||
        evento.tipo == TipoEvento.aniversario) {
      final fechaBase = fechaRelevante ?? evento.fecha;
      anosCumplidos = fechaBase.year - evento.fecha.year;
    }

    // Calcular próximo recordatorio
    DateTime? proximoRecordatorio;
    if (evento.tieneRecordatorio && evento.estado == EstadoEvento.habilitado) {
      proximoRecordatorio = RecordatorioCalculator.calcularProximoRecordatorio(
        evento,
        0, // TODO: Obtener ocurrencias reales
      );
      // Solo mostrar si es mayor a hoy
      if (proximoRecordatorio != null &&
          !proximoRecordatorio.isAfter(ahora)) {
        proximoRecordatorio = null;
      }
    }

    // Verificar si la fecha relevante es diferente de la original
    final mostrarFechaDelMes = fechaRelevante != null &&
        !RecordatorioCalculator.esMismoDia(fechaRelevante, evento.fecha);

    BottomModal.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nombre del evento
            Row(
              children: [
                Icon(_getIconForTipo(evento.tipo), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    evento.nombre,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fecha original
            _buildDetailRow(
              context,
              'Fecha original',
              dateFormatter.format(evento.fecha),
              Icons.calendar_today_outlined,
            ),

            // Fecha del mes (solo si es diferente)
            if (mostrarFechaDelMes) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                'Fecha del mes',
                dateFormatter.format(fechaRelevante),
                Icons.event_outlined,
              ),
            ],

            // Años cumplidos (solo para cumpleaños y aniversarios)
            if (anosCumplidos != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                'Años cumplidos',
                '$anosCumplidos ${anosCumplidos == 1 ? 'año' : 'años'}',
                Icons.cake_outlined,
              ),
            ],

            // Fecha de próximo recordatorio
            if (proximoRecordatorio != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                'Próximo recordatorio',
                dateFormatter.format(proximoRecordatorio),
                Icons.notifications_active_outlined,
              ),
            ],

            // Notas (solo si no está vacío)
            if (evento.notas != null && evento.notas!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Notas:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  evento.notas!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotesModal(BuildContext context, String titulo, String notas) {
    BottomModal.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(
              'Notas:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(notas, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _showMultipleEventsModal(
    BuildContext context,
    List<Evento> eventos,
    DateTime fecha,
    Map<String, DateTime>? fechasRelevantes,
  ) {
    final theme = Theme.of(context);

    BottomModal.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Eventos del día', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _formatDate(fecha),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: eventos.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final evento = eventos[index];
                  final fechaRelevante = fechasRelevantes?[evento.id];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_getIconForTipo(evento.tipo)),
                    title: Text(evento.nombre),
                    subtitle: evento.notas != null
                        ? Text(
                            evento.notas!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _showEventDetailModal(context, evento, fechaRelevante);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == yesterday) {
      return 'Ayer';
    } else if (dateOnly == tomorrow) {
      return 'Mañana';
    } else {
      final formatter = DateFormat('EEE. dd \'de\' MMMM \'de\' yyyy', 'es_ES');
      return formatter.format(date);
    }
  }

  IconData _getIconForTipo(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.cumpleanos:
        return Icons.cake_outlined;
      case TipoEvento.mesario:
        return Icons.favorite_outline;
      case TipoEvento.aniversario:
        return Icons.celebration_outlined;
      case TipoEvento.otro:
        return Icons.event_outlined;
    }
  }
}
