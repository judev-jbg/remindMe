// lib/features/events/data/repositories/eventos_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/recordatorio_enviado.dart';
import '../../domain/repositories/eventos_repository.dart';
import '../datasources/eventos_local_data_source.dart';
import '../models/evento_model.dart';
import '../models/recordatorio_enviado_model.dart';

/// Implementación del repositorio de eventos
/// Maneja errores y convierte excepciones en objetos Failure
class EventosRepositoryImpl implements EventosRepository {
  final EventosLocalDataSource localDataSource;

  EventosRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, Evento>> crearEvento(Evento evento) async {
    try {
      final eventoModel = EventoModel.fromEntity(evento);
      final resultado = await localDataSource.crearEvento(eventoModel);
      return Right(resultado.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Error al crear evento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Evento>> obtenerEvento(String id) async {
    try {
      final resultado = await localDataSource.obtenerEvento(id);
      return Right(resultado.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener evento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Evento>>> obtenerTodosLosEventos() async {
    try {
      final resultados = await localDataSource.obtenerTodosLosEventos();
      final eventos = resultados.map((modelo) => modelo.toEntity()).toList();
      return Right(eventos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener eventos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Evento>> actualizarEvento(Evento evento) async {
    try {
      final eventoModel = EventoModel.fromEntity(evento);
      final resultado = await localDataSource.actualizarEvento(eventoModel);
      return Right(resultado.toEntity());
    } catch (e) {
      return Left(
        DatabaseFailure('Error al actualizar evento: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> eliminarEvento(String id) async {
    try {
      await localDataSource.eliminarEvento(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Error al eliminar evento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> registrarRecordatorioEnviado(
    RecordatorioEnviado recordatorio,
  ) async {
    try {
      final recordatorioModel = RecordatorioEnviadoModel.fromEntity(
        recordatorio,
      );
      await localDataSource.registrarRecordatorioEnviado(recordatorioModel);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          'Error al registrar recordatorio enviado: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RecordatorioEnviado?>> obtenerUltimoRecordatorio(
    String eventoId,
  ) async {
    try {
      final resultado = await localDataSource.obtenerUltimoRecordatorio(
        eventoId,
      );
      return Right(resultado?.toEntity());
    } catch (e) {
      return Left(
        DatabaseFailure(
          'Error al obtener último recordatorio: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> contarOcurrenciasEnviadas(
    String eventoId,
  ) async {
    try {
      final count = await localDataSource.contarOcurrenciasEnviadas(eventoId);
      return Right(count);
    } catch (e) {
      return Left(
        DatabaseFailure('Error al contar ocurrencias: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<RecordatorioEnviado>>>
  obtenerRecordatoriosDeEvento(String eventoId) async {
    try {
      final resultados = await localDataSource.obtenerRecordatoriosDeEvento(
        eventoId,
      );
      final recordatorios = resultados.map((m) => m.toEntity()).toList();
      return Right(recordatorios);
    } catch (e) {
      return Left(
        DatabaseFailure(
          'Error al obtener recordatorios del evento: ${e.toString()}',
        ),
      );
    }
  }
}
