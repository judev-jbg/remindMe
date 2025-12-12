// lib/features/notifications/domain/usecases/marcar_notificacion.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notificaciones_repository.dart';

/// Caso de uso para marcar una notificación como leída/no leída
class MarcarNotificacion {
  final NotificacionesRepository repository;

  MarcarNotificacion(this.repository);

  Future<Either<Failure, void>> call(
    String notificacionId,
    bool marcada,
  ) async {
    if (notificacionId.trim().isEmpty) {
      return const Left(ValidationFailure('ID de notificación inválido'));
    }

    return await repository.marcarNotificacion(notificacionId, marcada);
  }
}
