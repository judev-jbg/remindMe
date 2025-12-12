// lib/features/notifications/data/repositories/notificaciones_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notificacion_log.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../datasources/notificaciones_local_data_source.dart';
import '../models/notificacion_log_model.dart';

/// Implementación del repositorio de notificaciones
/// Maneja errores y convierte excepciones en objetos Failure
class NotificacionesRepositoryImpl implements NotificacionesRepository {
  final NotificacionesLocalDataSource localDataSource;

  NotificacionesRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, void>> crearNotificacion(
    NotificacionLog notificacion,
  ) async {
    try {
      final notificacionModel = NotificacionLogModel.fromEntity(notificacion);
      await localDataSource.crearNotificacion(notificacionModel);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure('Error al crear notificación: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<NotificacionLog>>> obtenerUltimasNotificaciones(
    int limite,
  ) async {
    try {
      final resultados = await localDataSource.obtenerUltimasNotificaciones(
        limite,
      );
      final notificaciones = resultados.map((m) => m.toEntity()).toList();
      return Right(notificaciones);
    } catch (e) {
      return Left(
        DatabaseFailure('Error al obtener notificaciones: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<NotificacionLog>>>
  obtenerNotificacionesFiltradas({bool? soloMarcadas, int limite = 20}) async {
    try {
      final resultados = await localDataSource.obtenerNotificacionesFiltradas(
        soloMarcadas: soloMarcadas,
        limite: limite,
      );
      final notificaciones = resultados.map((m) => m.toEntity()).toList();
      return Right(notificaciones);
    } catch (e) {
      return Left(
        DatabaseFailure(
          'Error al obtener notificaciones filtradas: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> marcarNotificacion(
    String id,
    bool marcada,
  ) async {
    try {
      await localDataSource.marcarNotificacion(id, marcada);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure('Error al marcar notificación: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> marcarTodasComoLeidas() async {
    try {
      await localDataSource.marcarTodasComoLeidas();
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure('Error al marcar todas como leídas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> limpiarNotificacionesAntiguas() async {
    try {
      await localDataSource.limpiarNotificacionesAntiguas();
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          'Error al limpiar notificaciones antiguas: ${e.toString()}',
        ),
      );
    }
  }
}
