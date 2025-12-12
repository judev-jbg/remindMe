// lib/features/events/domain/usecases/actualizar_evento.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/evento.dart';
import '../repositories/eventos_repository.dart';
import '../services/recordatorio_calculator.dart';

/// Caso de uso para actualizar un evento existente
class ActualizarEvento {
  final EventosRepository repository;

  ActualizarEvento(this.repository);

  Future<Either<Failure, Evento>> call(ActualizarEventoParams params) async {
    try {
      // Validar datos básicos
      if (params.nombre.trim().isEmpty) {
        return const Left(ValidationFailure('El nombre no puede estar vacío'));
      }

      // Si es tipo "otro" debe tener hora
      if (params.tipo == TipoEvento.otro && params.horaEvento == null) {
        return const Left(
          ValidationFailure('Los eventos tipo "Otro" requieren hora'),
        );
      }

      DateTime? fechaHoraInicialRecordatorio =
          params.fechaHoraInicialRecordatorio;
      TipoRecurrencia? tipoRecurrencia = params.tipoRecurrencia;
      int? intervalo = params.intervalo;

      // Si tiene recordatorio y no tiene configuración, calcularla
      if (params.tieneRecordatorio) {
        if (fechaHoraInicialRecordatorio == null) {
          // Crear evento temporal para cálculos
          final eventoTemp = Evento(
            id: params.id,
            nombre: params.nombre,
            fecha: params.fecha,
            tipo: params.tipo,
            horaEvento: params.horaEvento,
            tieneRecordatorio: true,
            estado: params.estado,
            fechaCreacion: params.fechaCreacion,
            fechaActualizacion: DateTime.now(),
          );

          fechaHoraInicialRecordatorio =
              RecordatorioCalculator.calcularFechaHoraInicial(eventoTemp);

          // Obtener configuración por defecto
          final config = RecordatorioCalculator.obtenerConfiguracionPorDefecto(
            params.tipo,
          );
          tipoRecurrencia = config.tipoRecurrencia;
          intervalo = config.intervalo;
        }
      } else {
        // Si no tiene recordatorio, limpiar configuración
        fechaHoraInicialRecordatorio = null;
        tipoRecurrencia = null;
        intervalo = null;
      }

      // Crear evento actualizado
      final eventoActualizado = Evento(
        id: params.id,
        nombre: params.nombre.trim(),
        fecha: params.fecha,
        tipo: params.tipo,
        notas: params.notas?.trim(),
        horaEvento: params.horaEvento,
        tieneRecordatorio: params.tieneRecordatorio,
        estado: params.estado,
        fechaHoraInicialRecordatorio: fechaHoraInicialRecordatorio,
        tipoRecurrencia: tipoRecurrencia,
        intervalo: intervalo,
        diasSemana: params.diasSemana,
        fechaFinalizacion: params.fechaFinalizacion,
        maxOcurrencias: params.maxOcurrencias,
        fechaCreacion: params.fechaCreacion,
        fechaActualizacion: DateTime.now(),
      );

      // Validar coherencia
      if (!eventoActualizado.esValido()) {
        return const Left(
          ValidationFailure('El evento tiene datos incoherentes'),
        );
      }

      // Actualizar en el repositorio
      return await repository.actualizarEvento(eventoActualizado);
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }
}

/// Parámetros para actualizar un evento
class ActualizarEventoParams {
  final String id;
  final String nombre;
  final DateTime fecha;
  final TipoEvento tipo;
  final String? notas;
  final DateTime? horaEvento;
  final bool tieneRecordatorio;
  final EstadoEvento estado;
  final DateTime? fechaHoraInicialRecordatorio;
  final TipoRecurrencia? tipoRecurrencia;
  final int? intervalo;
  final List<int>? diasSemana;
  final DateTime? fechaFinalizacion;
  final int? maxOcurrencias;
  final DateTime fechaCreacion;

  const ActualizarEventoParams({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.tipo,
    this.notas,
    this.horaEvento,
    required this.tieneRecordatorio,
    required this.estado,
    this.fechaHoraInicialRecordatorio,
    this.tipoRecurrencia,
    this.intervalo,
    this.diasSemana,
    this.fechaFinalizacion,
    this.maxOcurrencias,
    required this.fechaCreacion,
  });

  /// Crea parámetros desde una entidad existente
  factory ActualizarEventoParams.fromEvento(Evento evento) {
    return ActualizarEventoParams(
      id: evento.id,
      nombre: evento.nombre,
      fecha: evento.fecha,
      tipo: evento.tipo,
      notas: evento.notas,
      horaEvento: evento.horaEvento,
      tieneRecordatorio: evento.tieneRecordatorio,
      estado: evento.estado,
      fechaHoraInicialRecordatorio: evento.fechaHoraInicialRecordatorio,
      tipoRecurrencia: evento.tipoRecurrencia,
      intervalo: evento.intervalo,
      diasSemana: evento.diasSemana,
      fechaFinalizacion: evento.fechaFinalizacion,
      maxOcurrencias: evento.maxOcurrencias,
      fechaCreacion: evento.fechaCreacion,
    );
  }
}
