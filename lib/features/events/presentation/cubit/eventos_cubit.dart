// lib/features/events/presentation/cubit/eventos_cubit.dart

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/evento.dart';
import '../../domain/usecases/crear_evento.dart';
import '../../domain/usecases/obtener_todos_los_eventos.dart';
import '../../domain/usecases/actualizar_evento.dart';
import '../../domain/usecases/eliminar_evento.dart';
import '../../domain/usecases/obtener_evento_con_recordatorios.dart';
import '../../domain/usecases/programar_notificaciones_evento.dart';
import '../../../notifications/domain/usecases/crear_notificacion_log.dart';
import '../../../notifications/domain/entities/notificacion_log.dart';
import '../../../../core/services/notification_service.dart';

/// Cubit para gestionar el estado de los eventos
class EventosCubit extends Cubit<EventosState> {
  final CrearEvento crearEvento;
  final ObtenerTodosLosEventos obtenerTodosLosEventos;
  final ActualizarEvento actualizarEvento;
  final EliminarEvento eliminarEvento;
  final ObtenerEventoConRecordatorios obtenerEventoConRecordatorios;
  final CrearNotificacionLog crearNotificacionLog;
  final ProgramarNotificacionesEvento programarNotificacionesEvento;
  final NotificationService notificationService;

  EventosCubit({
    required this.crearEvento,
    required this.obtenerTodosLosEventos,
    required this.actualizarEvento,
    required this.eliminarEvento,
    required this.obtenerEventoConRecordatorios,
    required this.crearNotificacionLog,
    required this.programarNotificacionesEvento,
    required this.notificationService,
  }) : super(EventosInitial());

  /// Carga todos los eventos
  Future<void> cargarEventos() async {
    emit(EventosLoading());

    final result = await obtenerTodosLosEventos();

    result.fold(
      (failure) => emit(EventosError(failure.message)),
      (eventos) => emit(EventosLoaded(eventos)),
    );
  }

  /// Crea un nuevo evento
  Future<void> crear({
    required String nombre,
    required DateTime fecha,
    required TipoEvento tipo,
    String? notas,
    DateTime? horaEvento,
    bool tieneRecordatorio = false,
  }) async {
    emit(EventosLoading());

    final params = CrearEventoParams(
      nombre: nombre,
      fecha: fecha,
      tipo: tipo,
      notas: notas,
      horaEvento: horaEvento,
      tieneRecordatorio: tieneRecordatorio,
    );

    final result = await crearEvento(params);

    await result.fold(
      (failure) async {
        emit(EventosError(failure.message));
      },
      (evento) async {
        // Registrar notificación
        await _registrarNotificacion(
          tipo: TipoAccion.eventoCreado,
          titulo: 'Evento creado',
          detalle: jsonEncode({
            'id': evento.id,
            'nombre': evento.nombre,
            'fecha': evento.fecha.toIso8601String(),
            'tipo': evento.tipo.name,
          }),
        );

        // Programar notificaciones si el evento tiene recordatorio
        if (evento.tieneRecordatorio) {
          await programarNotificacionesEvento(evento);
        }

        // Emitir estado de creación primero para el listener
        emit(EventoCreado(evento));

        // Recargar eventos para actualizar la UI
        await cargarEventos();
      },
    );
  }

  /// Actualiza un evento existente
  Future<void> actualizar({
    required String id,
    required String nombre,
    required DateTime fecha,
    required TipoEvento tipo,
    String? notas,
    DateTime? horaEvento,
    required bool tieneRecordatorio,
    required EstadoEvento estado,
    DateTime? fechaHoraInicialRecordatorio,
    TipoRecurrencia? tipoRecurrencia,
    int? intervalo,
    List<int>? diasSemana,
    DateTime? fechaFinalizacion,
    int? maxOcurrencias,
    required DateTime fechaCreacion,
  }) async {
    emit(EventosLoading());

    final params = ActualizarEventoParams(
      id: id,
      nombre: nombre,
      fecha: fecha,
      tipo: tipo,
      notas: notas,
      horaEvento: horaEvento,
      tieneRecordatorio: tieneRecordatorio,
      estado: estado,
      fechaHoraInicialRecordatorio: fechaHoraInicialRecordatorio,
      tipoRecurrencia: tipoRecurrencia,
      intervalo: intervalo,
      diasSemana: diasSemana,
      fechaFinalizacion: fechaFinalizacion,
      maxOcurrencias: maxOcurrencias,
      fechaCreacion: fechaCreacion,
    );

    final result = await actualizarEvento(params);

    await result.fold(
      (failure) async {
        emit(EventosError(failure.message));
      },
      (evento) async {
        // Registrar notificación
        await _registrarNotificacion(
          tipo: TipoAccion.eventoEditado,
          titulo: 'Evento actualizado',
          detalle: jsonEncode({
            'id': evento.id,
            'nombre': evento.nombre,
            'fecha': evento.fecha.toIso8601String(),
          }),
        );

        // Reprogramar notificaciones (cancelar anteriores y crear nuevas)
        await programarNotificacionesEvento(evento);

        // Emitir estado de actualización primero para el listener
        emit(EventoActualizado(evento));

        // Recargar eventos para actualizar la UI
        await cargarEventos();
      },
    );
  }

  /// Elimina un evento
  Future<void> eliminar(String eventoId, String nombreEvento) async {
    emit(EventosLoading());

    final result = await eliminarEvento(eventoId);

    await result.fold(
      (failure) async {
        emit(EventosError(failure.message));
      },
      (_) async {
        // Cancelar todas las notificaciones del evento eliminado
        await notificationService.cancelEventNotifications(eventoId);

        // Registrar notificación
        await _registrarNotificacion(
          tipo: TipoAccion.eventoEliminado,
          titulo: 'Evento eliminado',
          detalle: jsonEncode({'id': eventoId, 'nombre': nombreEvento}),
        );

        // Emitir estado de eliminación primero para el listener
        emit(EventoEliminado(eventoId));

        // Recargar eventos para actualizar la UI
        await cargarEventos();
      },
    );
  }

  /// Obtiene un evento con información de recordatorios
  Future<void> obtenerConRecordatorios(String eventoId) async {
    emit(EventosLoading());

    final result = await obtenerEventoConRecordatorios(eventoId);

    result.fold(
      (failure) => emit(EventosError(failure.message)),
      (eventoConRecordatorios) =>
          emit(EventoConRecordatoriosLoaded(eventoConRecordatorios)),
    );
  }

  /// Helper para registrar notificaciones
  Future<void> _registrarNotificacion({
    required TipoAccion tipo,
    required String titulo,
    required String detalle,
  }) async {
    final params = CrearNotificacionParams(
      tipo: tipo,
      titulo: titulo,
      detalle: detalle,
    );

    await crearNotificacionLog(params);
  }
}

// ============================================
// ESTADOS
// ============================================

abstract class EventosState extends Equatable {
  const EventosState();

  @override
  List<Object?> get props => [];
}

class EventosInitial extends EventosState {}

class EventosLoading extends EventosState {}

class EventosLoaded extends EventosState {
  final List<Evento> eventos;

  const EventosLoaded(this.eventos);

  @override
  List<Object?> get props => [eventos];
}

class EventoCreado extends EventosState {
  final Evento evento;

  const EventoCreado(this.evento);

  @override
  List<Object?> get props => [evento];
}

class EventoActualizado extends EventosState {
  final Evento evento;

  const EventoActualizado(this.evento);

  @override
  List<Object?> get props => [evento];
}

class EventoEliminado extends EventosState {
  final String eventoId;

  const EventoEliminado(this.eventoId);

  @override
  List<Object?> get props => [eventoId];
}

class EventoConRecordatoriosLoaded extends EventosState {
  final EventoConRecordatorios eventoConRecordatorios;

  const EventoConRecordatoriosLoaded(this.eventoConRecordatorios);

  @override
  List<Object?> get props => [eventoConRecordatorios];
}

class EventosError extends EventosState {
  final String message;

  const EventosError(this.message);

  @override
  List<Object?> get props => [message];
}
