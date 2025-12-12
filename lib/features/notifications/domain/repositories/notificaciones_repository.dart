// lib/features/notifications/domain/repositories/notificaciones_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notificacion_log.dart';

/// Contrato del repositorio de notificaciones
abstract class NotificacionesRepository {
  /// Crea una nueva notificación en el log
  Future<Either<Failure, void>> crearNotificacion(NotificacionLog notificacion);

  /// Obtiene las últimas N notificaciones
  Future<Either<Failure, List<NotificacionLog>>> obtenerUltimasNotificaciones(
    int limite,
  );

  /// Obtiene notificaciones filtradas por estado
  Future<Either<Failure, List<NotificacionLog>>>
  obtenerNotificacionesFiltradas({bool? soloMarcadas, int limite = 20});

  /// Marca una notificación como leída
  Future<Either<Failure, void>> marcarNotificacion(String id, bool marcada);

  /// Marca todas las notificaciones como leídas
  Future<Either<Failure, void>> marcarTodasComoLeidas();

  /// Limpia notificaciones antiguas (últimos 15 días o máximo 50)
  Future<Either<Failure, void>> limpiarNotificacionesAntiguas();
}
