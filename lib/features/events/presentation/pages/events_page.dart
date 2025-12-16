// lib/features/events/presentation/pages/events_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/animated_snackbar.dart';
import '../../../../core/widgets/bottom_modal.dart';
import '../cubit/eventos_cubit.dart';
import '../../domain/entities/evento.dart';
import '../widgets/evento_form.dart';

/// Página de gestión de eventos con funcionalidades CRUD
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventosCubit, EventosState>(
      listener: (context, state) {
        if (state is EventosError) {
          AnimatedSnackbar.showError(context: context, message: state.message);
        }

        if (state is EventoCreado) {
          AnimatedSnackbar.showSuccess(
            context: context,
            message: 'Evento creado correctamente',
          );
        }

        if (state is EventoActualizado) {
          AnimatedSnackbar.showSuccess(
            context: context,
            message: 'Evento actualizado correctamente',
          );
        }

        if (state is EventoEliminado) {
          AnimatedSnackbar.showSuccess(
            context: context,
            message: 'Evento eliminado correctamente',
          );
        }
      },
      builder: (context, state) {
        if (state is EventosLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EventosError) {
          return _buildErrorState(context, state.message);
        }

        if (state is EventosLoaded) {
          if (state.eventos.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildEventsList(context, state.eventos);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('No tienes eventos', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer evento tocando el botón +',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Align(
          alignment: Alignment.centerRight,
          child: FloatingActionButton(
            onPressed: () => _showCreateEventModal(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add),
          ),
        ),
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
              context.read<EventosCubit>().cargarEventos();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, List<Evento> eventos) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(eventos[index].id),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return await _showDeleteConfirmation(context, eventos[index]);
                } else if (direction == DismissDirection.endToStart) {
                  _showEditModal(context, eventos[index]);
                  return false;
                }
                return false;
              },
              background: _buildDismissBackground(
                color: Colors.red,
                icon: Icons.delete,
                alignment: Alignment.centerLeft,
              ),
              secondaryBackground: _buildDismissBackground(
                color: Colors.orange,
                icon: Icons.edit,
                alignment: Alignment.centerRight,
              ),
              child: _buildEventCard(context, eventos[index], index),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Align(
          alignment: Alignment.centerRight,
          child: FloatingActionButton(
            onPressed: () => _showCreateEventModal(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Evento evento, int index) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat(
      'EEE. dd \'de\' MMMM \'de\' yyyy',
      'es_ES',
    );

    return GradientCard(
      onTap: () => _showEventDetailsBottomSheet(context, evento),
      gradient: AppGradients.getEventCardGradient(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fila 1: Nombre y tipo de evento
          Row(
            children: [
              Expanded(
                child: Text(
                  evento.nombre,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForTipo(evento.tipo),
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      evento.tipo.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 2: Fecha con icono de recordatorio a la derecha
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateFormatter.format(evento.fecha),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              if (evento.tieneRecordatorio)
                Icon(
                  evento.estado == EstadoEvento.habilitado
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  size: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
            ],
          ),
          // Fila 3: Hora del evento (solo para tipo Otro)
          if (evento.tipo == TipoEvento.otro && evento.horaEvento != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('HH:mm').format(evento.horaEvento!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
          // Fila 4: Años/Meses transcurridos (solo para Aniversario/Cumpleaños/Mesario)
          if (evento.tipo != TipoEvento.otro) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.history_outlined,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  _calcularTiempoTranscurrido(evento),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _calcularTiempoTranscurrido(Evento evento) {
    final ahora = DateTime.now();
    final desde = evento.fecha;

    if (evento.tipo == TipoEvento.mesario) {
      // Calcular meses
      final meses = (ahora.year - desde.year) * 12 + (ahora.month - desde.month);
      return meses == 1 ? 'Ha pasado 1 mes' : 'Han pasado $meses meses';
    } else {
      // Calcular años y meses para Aniversario y Cumpleaños
      int anios = ahora.year - desde.year;
      int meses = ahora.month - desde.month;

      if (meses < 0) {
        anios--;
        meses += 12;
      }

      final aniosTexto = anios == 1 ? '1 año' : '$anios años';
      final mesesTexto = meses == 1 ? '1 mes' : '$meses meses';

      if (anios > 0 && meses > 0) {
        return 'Han pasado $aniosTexto y $mesesTexto';
      } else if (anios > 0) {
        return 'Han pasado $aniosTexto';
      } else {
        return 'Han pasado $mesesTexto';
      }
    }
  }

  Widget _buildDismissBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    Evento evento,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${evento.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (context.mounted) {
        await context.read<EventosCubit>().eliminar(evento.id, evento.nombre);
      }
    }

    return false; // No eliminamos aquí, lo hace el cubit
  }

  void _showEditModal(BuildContext context, Evento evento) {
    BottomModal.show(
      context: context,
      child: EventoForm(
        modo: EventoFormMode.editar,
        eventoExistente: evento,
        onGuardar: (data) async {
          await context.read<EventosCubit>().actualizar(
            id: evento.id,
            nombre: data['nombre'],
            fecha: data['fecha'],
            tipo: data['tipo'],
            notas: data['notas'],
            horaEvento: data['horaEvento'],
            tieneRecordatorio: data['tieneRecordatorio'],
            estado: data['estado'],
            fechaHoraInicialRecordatorio: data['fechaHoraInicialRecordatorio'],
            tipoRecurrencia: data['tipoRecurrencia'],
            intervalo: data['intervalo'],
            diasSemana: data['diasSemana'],
            fechaFinalizacion: data['fechaFinalizacion'],
            maxOcurrencias: data['maxOcurrencias'],
            fechaCreacion: evento.fechaCreacion,
          );

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showCreateEventModal(BuildContext context) {
    BottomModal.show(
      context: context,
      child: EventoForm(
        modo: EventoFormMode.crear,
        onGuardar: (data) async {
          await context.read<EventosCubit>().crear(
            nombre: data['nombre'],
            fecha: data['fecha'],
            tipo: data['tipo'],
            notas: data['notas'],
            horaEvento: data['horaEvento'],
            tieneRecordatorio: data['tieneRecordatorio'],
            tiempoAvisoAntes: data['tiempoAvisoAntes'],
          );

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showEventDetailsBottomSheet(BuildContext context, Evento evento) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd/MM/yyyy \'a las\' HH:mm', 'es_ES');

    BottomModal.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del evento
            Row(
              children: [
                Icon(
                  _getIconForTipo(evento.tipo),
                  color: theme.colorScheme.primary,
                ),
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
            const SizedBox(height: 24),

            // Notas
            if (evento.notas != null && evento.notas!.isNotEmpty) ...[
              Text(
                'Notas',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  evento.notas!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Próximo recordatorio
            if (evento.tieneRecordatorio &&
                evento.estado == EstadoEvento.habilitado &&
                evento.fechaHoraInicialRecordatorio != null) ...[
              Text(
                'Próximo recordatorio',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dateFormatter.format(evento.fechaHoraInicialRecordatorio!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
