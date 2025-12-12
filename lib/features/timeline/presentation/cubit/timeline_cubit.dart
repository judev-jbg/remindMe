// lib/features/timeline/presentation/cubit/timeline_cubit.dart

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../events/domain/entities/evento.dart';
import '../../../events/domain/usecases/obtener_todos_los_eventos.dart';
import '../../../events/domain/services/recordatorio_calculator.dart';
import '../../../notifications/domain/usecases/crear_notificacion_log.dart';
import '../../../notifications/domain/entities/notificacion_log.dart';

/// Cubit para gestionar el estado del timeline
class TimelineCubit extends Cubit<TimelineState> {
  final ObtenerTodosLosEventos obtenerTodosLosEventos;
  final CrearNotificacionLog crearNotificacionLog;

  TimelineCubit({
    required this.obtenerTodosLosEventos,
    required this.crearNotificacionLog,
  }) : super(TimelineInitial());

  /// Carga el timeline de 7 slots
  Future<void> cargarTimeline() async {
    emit(TimelineLoading());

    final result = await obtenerTodosLosEventos();

    result.fold((failure) => emit(TimelineError(failure.message)), (eventos) {
      final timeline = _generarTimeline(eventos);

      // Registrar notificación del timeline generado
      // _registrarTimelineGenerado(timeline);

      emit(TimelineLoaded(timeline));
    });
  }

  /// Genera el timeline de 7 slots según la lógica definida
  List<TimelineSlot> _generarTimeline(List<Evento> todosLosEventos) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    // Determinar fecha relevante de cada evento (aniversario del mes)
    final eventosConFecha = todosLosEventos.map((evento) {
      DateTime fechaRelevante;

      // Calcular la fecha de aniversario dentro del mes actual
      fechaRelevante = _calcularFechaAniversarioDelMes(evento, ahora);

      return EventoConFechaRelevante(evento, fechaRelevante);
    }).toList();

    // Separar en pasados, hoy y futuros
    final pasados =
        eventosConFecha.where((e) => e.fechaRelevante.isBefore(hoy)).toList()
          ..sort((a, b) => b.fechaRelevante.compareTo(a.fechaRelevante));

    final hoyEventos = eventosConFecha
        .where((e) => RecordatorioCalculator.esMismoDia(e.fechaRelevante, hoy))
        .toList();

    final futuros =
        eventosConFecha.where((e) => e.fechaRelevante.isAfter(hoy)).toList()
          ..sort((a, b) => a.fechaRelevante.compareTo(b.fechaRelevante));

    // Construir los 7 slots
    return [
      _construirSlot(0, pasados.length > 2 ? pasados[2] : null),
      _construirSlot(1, pasados.length > 1 ? pasados[1] : null),
      _construirSlot(2, pasados.length > 0 ? pasados[0] : null),
      _construirSlotHoy(hoyEventos),
      _construirSlot(4, futuros.length > 0 ? futuros[0] : null),
      _construirSlot(5, futuros.length > 1 ? futuros[1] : null),
      _construirSlot(6, futuros.length > 2 ? futuros[2] : null),
    ];
  }

  /// Calcula la fecha de aniversario del evento dentro del año actual
  DateTime _calcularFechaAniversarioDelMes(Evento evento, DateTime referencia) {
    switch (evento.tipo) {
      case TipoEvento.cumpleanos:
      case TipoEvento.aniversario:
        // Para cumpleaños y aniversarios: mismo día y mes, año actual
        return DateTime(
          referencia.year,
          evento.fecha.month,
          evento.fecha.day,
        );

      case TipoEvento.mesario:
        // Para mesarios: mostrar el mesario del MES ACTUAL (se repite cada mes)
        final fechaOriginal = evento.fecha;
        final diaDelMes = fechaOriginal.day;

        // Calcular el mesario del mes actual
        // Ejemplo: si el evento es 9 nov 2021 y hoy es 12 dic 2025, mostrar 9 dic 2025
        return DateTime(
          referencia.year,
          referencia.month, // Usar el mes actual, no el mes original
          diaDelMes,
        );

      case TipoEvento.otro:
        // Para eventos de tipo "otro": usar la fecha del evento tal cual
        return evento.fecha;
    }
  }

  TimelineSlot _construirSlot(int index, EventoConFechaRelevante? evento) {
    if (evento == null) {
      return TimelineSlot(index: index, visible: false);
    }

    return TimelineSlot(
      index: index,
      visible: true,
      eventos: [evento.evento],
      fecha: evento.fechaRelevante,
      fechasRelevantes: {evento.evento.id: evento.fechaRelevante},
    );
  }

  TimelineSlot _construirSlotHoy(List<EventoConFechaRelevante> hoyEventos) {
    if (hoyEventos.isEmpty) {
      return TimelineSlot(
        index: 3,
        visible: true,
        esHoy: true,
        mensajeVacio: "No hay eventos para hoy",
      );
    }

    return TimelineSlot(
      index: 3,
      visible: true,
      esHoy: true,
      eventos: hoyEventos.map((e) => e.evento).toList(),
      fecha: DateTime.now(),
      fechasRelevantes: Map.fromEntries(
        hoyEventos.map((e) => MapEntry(e.evento.id, e.fechaRelevante)),
      ),
    );
  }

  /// Registra notificación del timeline generado
  Future<void> _registrarTimelineGenerado(List<TimelineSlot> timeline) async {
    final eventosVisibles = timeline
        .where((slot) => slot.visible && slot.eventos != null)
        .expand((slot) => slot.eventos!)
        .toList();

    final params = CrearNotificacionParams(
      tipo: TipoAccion.timelineGenerado,
      titulo: 'Timeline actualizado',
      detalle: jsonEncode({
        'fecha': DateTime.now().toIso8601String(),
        'eventos_visibles': eventosVisibles.length,
      }),
    );

    await crearNotificacionLog(params);
  }
}

// ============================================
// ESTADOS
// ============================================

abstract class TimelineState extends Equatable {
  const TimelineState();

  @override
  List<Object?> get props => [];
}

class TimelineInitial extends TimelineState {}

class TimelineLoading extends TimelineState {}

class TimelineLoaded extends TimelineState {
  final List<TimelineSlot> timeline;

  const TimelineLoaded(this.timeline);

  @override
  List<Object?> get props => [timeline];
}

class TimelineError extends TimelineState {
  final String message;

  const TimelineError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================
// MODELOS AUXILIARES
// ============================================

class TimelineSlot extends Equatable {
  final int index;
  final bool visible;
  final bool esHoy;
  final List<Evento>? eventos;
  final DateTime? fecha;
  final String? mensajeVacio;
  final Map<String, DateTime>? fechasRelevantes; // Map de eventoId -> fechaRelevante

  const TimelineSlot({
    required this.index,
    required this.visible,
    this.esHoy = false,
    this.eventos,
    this.fecha,
    this.mensajeVacio,
    this.fechasRelevantes,
  });

  @override
  List<Object?> get props => [
    index,
    visible,
    esHoy,
    eventos,
    fecha,
    mensajeVacio,
    fechasRelevantes,
  ];
}

class EventoConFechaRelevante extends Equatable {
  final Evento evento;
  final DateTime fechaRelevante;

  const EventoConFechaRelevante(this.evento, this.fechaRelevante);

  @override
  List<Object?> get props => [evento, fechaRelevante];
}
