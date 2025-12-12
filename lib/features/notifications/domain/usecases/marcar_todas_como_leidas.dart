// lib/features/notifications/domain/usecases/marcar_todas_como_leidas.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notificaciones_repository.dart';

/// Caso de uso para marcar todas las notificaciones como leídas
class MarcarTodasComoLeidas {
  final NotificacionesRepository repository;

  MarcarTodasComoLeidas(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.marcarTodasComoLeidas();
  }
}
