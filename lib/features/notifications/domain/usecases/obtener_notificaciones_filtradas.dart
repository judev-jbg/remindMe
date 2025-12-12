// lib/features/notifications/domain/usecases/obtener_notificaciones_filtradas.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notificacion_log.dart';
import '../repositories/notificaciones_repository.dart';

/// Caso de uso para obtener notificaciones filtradas
class ObtenerNotificacionesFiltradas {
  final NotificacionesRepository repository;

  ObtenerNotificacionesFiltradas(this.repository);

  Future<Either<Failure, List<NotificacionLog>>> call({
    FiltroNotificacion filtro = FiltroNotificacion.todas,
    int limite = 20,
  }) async {
    bool? soloMarcadas;

    switch (filtro) {
      case FiltroNotificacion.todas:
        soloMarcadas = null;
        break;
      case FiltroNotificacion.vistas:
        soloMarcadas = true;
        break;
      case FiltroNotificacion.noVistas:
        soloMarcadas = false;
        break;
    }

    return await repository.obtenerNotificacionesFiltradas(
      soloMarcadas: soloMarcadas,
      limite: limite,
    );
  }
}

enum FiltroNotificacion { todas, vistas, noVistas }
