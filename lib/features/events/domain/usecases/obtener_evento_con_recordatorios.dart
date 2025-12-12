// lib/features/events/domain/usecases/obtener_evento_con_recordatorios.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/evento.dart';
import '../repositories/eventos_repository.dart';
import '../services/recordatorio_calculator.dart';

/// Caso de uso para obtener un evento con información de recordatorios calculada
class ObtenerEventoConRecordatorios {
  final EventosRepository repository;

  ObtenerEventoConRecordatorios(this.repository);

  Future<Either<Failure, EventoConRecordatorios>> call(String eventoId) async {
    try {
      // Obtener el evento
      final eventoResult = await repository.obtenerEvento(eventoId);

      return eventoResult.fold((failure) => Left(failure), (evento) async {
        // Obtener último recordatorio
        final ultimoResult = await repository.obtenerUltimoRecordatorio(
          eventoId,
        );

        final ultimoRecordatorio = ultimoResult.fold(
          (failure) => null,
          (recordatorio) => recordatorio?.fechaHoraEnviado,
        );

        // Contar ocurrencias
        final countResult = await repository.contarOcurrenciasEnviadas(
          eventoId,
        );

        final ocurrencias = countResult.fold((failure) => 0, (count) => count);

        // Calcular próximo recordatorio
        final proximoRecordatorio =
            RecordatorioCalculator.calcularProximoRecordatorio(
              evento,
              ocurrencias,
            );

        return Right(
          EventoConRecordatorios(
            evento: evento,
            ultimoRecordatorio: ultimoRecordatorio,
            proximoRecordatorio: proximoRecordatorio,
            ocurrenciasEnviadas: ocurrencias,
          ),
        );
      });
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }
}

/// Evento con información de recordatorios calculada
class EventoConRecordatorios {
  final Evento evento;
  final DateTime? ultimoRecordatorio;
  final DateTime? proximoRecordatorio;
  final int ocurrenciasEnviadas;

  const EventoConRecordatorios({
    required this.evento,
    this.ultimoRecordatorio,
    this.proximoRecordatorio,
    required this.ocurrenciasEnviadas,
  });
}
