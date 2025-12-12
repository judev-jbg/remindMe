// lib/features/notifications/presentation/cubit/notificaciones_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/notificacion_log.dart';
import '../../domain/usecases/obtener_notificaciones_filtradas.dart';
import '../../domain/usecases/marcar_notificacion.dart';
import '../../domain/usecases/marcar_todas_como_leidas.dart';

/// Cubit para gestionar el estado de las notificaciones
class NotificacionesCubit extends Cubit<NotificacionesState> {
  final ObtenerNotificacionesFiltradas obtenerNotificacionesFiltradas;
  final MarcarNotificacion marcarNotificacion;
  final MarcarTodasComoLeidas marcarTodasComoLeidas;

  NotificacionesCubit({
    required this.obtenerNotificacionesFiltradas,
    required this.marcarNotificacion,
    required this.marcarTodasComoLeidas,
  }) : super(NotificacionesInitial());

  FiltroNotificacion _filtroActual = FiltroNotificacion.todas;

  /// Carga las notificaciones con el filtro actual
  Future<void> cargarNotificaciones({FiltroNotificacion? filtro}) async {
    if (filtro != null) {
      _filtroActual = filtro;
    }

    emit(NotificacionesLoading());

    final result = await obtenerNotificacionesFiltradas(
      filtro: _filtroActual,
      limite: 20,
    );

    result.fold(
      (failure) => emit(NotificacionesError(failure.message)),
      (notificaciones) =>
          emit(NotificacionesLoaded(notificaciones, _filtroActual)),
    );
  }

  /// Marca una notificación como leída/no leída
  Future<void> marcar(String notificacionId, bool marcada) async {
    final result = await marcarNotificacion(notificacionId, marcada);

    await result.fold(
      (failure) async {
        emit(NotificacionesError(failure.message));
      },
      (_) async {
        // Recargar notificaciones
        await cargarNotificaciones();
      },
    );
  }

  /// Marca todas las notificaciones como leídas
  Future<void> marcarTodas() async {
    final result = await marcarTodasComoLeidas();

    await result.fold(
      (failure) async {
        emit(NotificacionesError(failure.message));
      },
      (_) async {
        // Recargar notificaciones
        await cargarNotificaciones();
      },
    );
  }

  /// Cambia el filtro de notificaciones
  Future<void> cambiarFiltro(FiltroNotificacion filtro) async {
    await cargarNotificaciones(filtro: filtro);
  }
}

// ============================================
// ESTADOS
// ============================================

abstract class NotificacionesState extends Equatable {
  const NotificacionesState();

  @override
  List<Object?> get props => [];
}

class NotificacionesInitial extends NotificacionesState {}

class NotificacionesLoading extends NotificacionesState {}

class NotificacionesLoaded extends NotificacionesState {
  final List<NotificacionLog> notificaciones;
  final FiltroNotificacion filtroActual;

  const NotificacionesLoaded(this.notificaciones, this.filtroActual);

  @override
  List<Object?> get props => [notificaciones, filtroActual];
}

class NotificacionesError extends NotificacionesState {
  final String message;

  const NotificacionesError(this.message);

  @override
  List<Object?> get props => [message];
}
