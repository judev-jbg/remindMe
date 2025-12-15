// lib/features/events/domain/usecases/crear_evento.dart

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../entities/evento.dart';
import '../repositories/eventos_repository.dart';
import '../services/recordatorio_calculator.dart';

/// Caso de uso para crear un nuevo evento
class CrearEvento {
  final EventosRepository repository;
  final Uuid uuid = const Uuid();

  CrearEvento(this.repository);

  Future<Either<Failure, Evento>> call(CrearEventoParams params) async {
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

      final ahora = DateTime.now();
      DateTime? fechaHoraInicialRecordatorio;
      TipoRecurrencia? tipoRecurrencia;
      int? intervalo;

      // Si tiene recordatorio, calcular configuración
      if (params.tieneRecordatorio) {
        // Crear evento temporal para cálculos
        final eventoTemp = Evento(
          id: 'temp',
          nombre: params.nombre,
          fecha: params.fecha,
          tipo: params.tipo,
          horaEvento: params.horaEvento,
          tieneRecordatorio: true,
          estado: EstadoEvento.habilitado,
          tiempoAvisoAntes: params.tiempoAvisoAntes,
          fechaCreacion: ahora,
          fechaActualizacion: ahora,
        );

        // Calcular fecha y hora inicial del recordatorio
        fechaHoraInicialRecordatorio =
            RecordatorioCalculator.calcularFechaHoraInicial(eventoTemp);

        // Obtener configuración por defecto según tipo
        final config = RecordatorioCalculator.obtenerConfiguracionPorDefecto(
          params.tipo,
        );
        tipoRecurrencia = config.tipoRecurrencia;
        intervalo = config.intervalo;
      }

      // Crear el evento
      final evento = Evento(
        id: uuid.v4(),
        nombre: params.nombre.trim(),
        fecha: params.fecha,
        tipo: params.tipo,
        notas: params.notas?.trim(),
        horaEvento: params.horaEvento,
        tieneRecordatorio: params.tieneRecordatorio,
        estado: EstadoEvento.habilitado,
        tiempoAvisoAntes: params.tiempoAvisoAntes,
        fechaHoraInicialRecordatorio: fechaHoraInicialRecordatorio,
        tipoRecurrencia: tipoRecurrencia,
        intervalo: intervalo,
        diasSemana: null,
        fechaFinalizacion: null,
        maxOcurrencias: null,
        fechaCreacion: ahora,
        fechaActualizacion: ahora,
      );

      // Validar coherencia
      if (!evento.esValido()) {
        return const Left(
          ValidationFailure('El evento tiene datos incoherentes'),
        );
      }

      // Guardar en el repositorio
      return await repository.crearEvento(evento);
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }
}

/// Parámetros para crear un evento
class CrearEventoParams {
  final String nombre;
  final DateTime fecha;
  final TipoEvento tipo;
  final String? notas;
  final DateTime? horaEvento;
  final bool tieneRecordatorio;
  final TiempoAvisoAntes? tiempoAvisoAntes;

  const CrearEventoParams({
    required this.nombre,
    required this.fecha,
    required this.tipo,
    this.notas,
    this.horaEvento,
    this.tieneRecordatorio = false,
    this.tiempoAvisoAntes,
  });
}
