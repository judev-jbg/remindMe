// lib/features/notifications/domain/usecases/crear_notificacion_log.dart

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notificacion_log.dart';
import '../repositories/notificaciones_repository.dart';

/// Caso de uso para crear una notificación en el log
class CrearNotificacionLog {
  final NotificacionesRepository repository;
  final Uuid uuid = const Uuid();

  CrearNotificacionLog(this.repository);

  Future<Either<Failure, void>> call(CrearNotificacionParams params) async {
    try {
      final notificacion = NotificacionLog(
        id: uuid.v4(),
        tipo: params.tipo,
        titulo: params.titulo,
        detalle: params.detalle,
        fechaHora: DateTime.now(),
        marcada: false,
      );

      return await repository.crearNotificacion(notificacion);
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }
}

/// Parámetros para crear una notificación
class CrearNotificacionParams {
  final TipoAccion tipo;
  final String titulo;
  final String detalle;

  const CrearNotificacionParams({
    required this.tipo,
    required this.titulo,
    required this.detalle,
  });
}
