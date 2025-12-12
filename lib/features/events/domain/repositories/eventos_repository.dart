// lib/features/events/domain/repositories/eventos_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/evento.dart';
import '../entities/recordatorio_enviado.dart';

/// Contrato del repositorio de eventos
abstract class EventosRepository {
  // === CRUD EVENTOS ===

  /// Crea un nuevo evento
  Future<Either<Failure, Evento>> crearEvento(Evento evento);

  /// Obtiene un evento por ID
  Future<Either<Failure, Evento>> obtenerEvento(String id);

  /// Obtiene todos los eventos
  Future<Either<Failure, List<Evento>>> obtenerTodosLosEventos();

  /// Actualiza un evento existente
  Future<Either<Failure, Evento>> actualizarEvento(Evento evento);

  /// Elimina un evento por ID
  Future<Either<Failure, void>> eliminarEvento(String id);

  // === RECORDATORIOS ENVIADOS ===

  /// Registra que un recordatorio fue enviado
  Future<Either<Failure, void>> registrarRecordatorioEnviado(
    RecordatorioEnviado recordatorio,
  );

  /// Obtiene el último recordatorio enviado de un evento
  Future<Either<Failure, RecordatorioEnviado?>> obtenerUltimoRecordatorio(
    String eventoId,
  );

  /// Cuenta las ocurrencias enviadas de un evento
  Future<Either<Failure, int>> contarOcurrenciasEnviadas(String eventoId);

  /// Obtiene todos los recordatorios de un evento
  Future<Either<Failure, List<RecordatorioEnviado>>>
  obtenerRecordatoriosDeEvento(String eventoId);
}
