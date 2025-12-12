// lib/features/events/data/models/evento_model.dart

import 'dart:convert';
import '../../domain/entities/evento.dart';

/// Modelo de datos para Evento (mapea a SQLite)
class EventoModel extends Evento {
  const EventoModel({
    required super.id,
    required super.nombre,
    required super.fecha,
    required super.tipo,
    super.notas,
    super.horaEvento,
    required super.tieneRecordatorio,
    required super.estado,
    super.fechaHoraInicialRecordatorio,
    super.tipoRecurrencia,
    super.intervalo,
    super.diasSemana,
    super.fechaFinalizacion,
    super.maxOcurrencias,
    required super.fechaCreacion,
    required super.fechaActualizacion,
  });

  /// Convierte la entidad de dominio a modelo
  factory EventoModel.fromEntity(Evento evento) {
    return EventoModel(
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
      fechaActualizacion: evento.fechaActualizacion,
    );
  }

  /// Convierte desde un Map de SQLite
  factory EventoModel.fromMap(Map<String, dynamic> map) {
    return EventoModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha'] as int),
      tipo: _tipoEventoFromString(map['tipo'] as String),
      notas: map['notas'] as String?,
      horaEvento: map['hora_evento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['hora_evento'] as int)
          : null,
      tieneRecordatorio: (map['tiene_recordatorio'] as int) == 1,
      estado: _estadoEventoFromString(map['estado'] as String),
      fechaHoraInicialRecordatorio:
          map['fecha_hora_inicial_recordatorio'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['fecha_hora_inicial_recordatorio'] as int,
            )
          : null,
      tipoRecurrencia: map['tipo_recurrencia'] != null
          ? _tipoRecurrenciaFromString(map['tipo_recurrencia'] as String)
          : null,
      intervalo: map['intervalo'] as int?,
      diasSemana: map['dias_semana'] != null
          ? List<int>.from(jsonDecode(map['dias_semana'] as String))
          : null,
      fechaFinalizacion: map['fecha_finalizacion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['fecha_finalizacion'] as int,
            )
          : null,
      maxOcurrencias: map['max_ocurrencias'] as int?,
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(
        map['fecha_creacion'] as int,
      ),
      fechaActualizacion: DateTime.fromMillisecondsSinceEpoch(
        map['fecha_actualizacion'] as int,
      ),
    );
  }

  /// Convierte a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'fecha': fecha.millisecondsSinceEpoch,
      'tipo': _tipoEventoToString(tipo),
      'notas': notas,
      'hora_evento': horaEvento?.millisecondsSinceEpoch,
      'tiene_recordatorio': tieneRecordatorio ? 1 : 0,
      'estado': _estadoEventoToString(estado),
      'fecha_hora_inicial_recordatorio':
          fechaHoraInicialRecordatorio?.millisecondsSinceEpoch,
      'tipo_recurrencia': tipoRecurrencia != null
          ? _tipoRecurrenciaToString(tipoRecurrencia!)
          : null,
      'intervalo': intervalo,
      'dias_semana': diasSemana != null ? jsonEncode(diasSemana) : null,
      'fecha_finalizacion': fechaFinalizacion?.millisecondsSinceEpoch,
      'max_ocurrencias': maxOcurrencias,
      'fecha_creacion': fechaCreacion.millisecondsSinceEpoch,
      'fecha_actualizacion': fechaActualizacion.millisecondsSinceEpoch,
    };
  }

  /// Convierte el modelo a entidad de dominio
  Evento toEntity() {
    return Evento(
      id: id,
      nombre: nombre,
      fecha: fecha,
      tipo: tipo,
      notas: notas,
      horaEvento: horaEvento,
      tieneRecordatorio: tieneRecordatorio,
      estado: estado,
      fechaHoraInicialRecordatorio: fechaHoraInicialRecordatorio,
      tipoRecurrencia: tipoRecurrencia,
      intervalo: intervalo,
      diasSemana: diasSemana,
      fechaFinalizacion: fechaFinalizacion,
      maxOcurrencias: maxOcurrencias,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion,
    );
  }

  // === HELPERS DE CONVERSIÓN DE ENUMS ===

  static TipoEvento _tipoEventoFromString(String value) {
    switch (value) {
      case 'cumpleanos':
        return TipoEvento.cumpleanos;
      case 'mesario':
        return TipoEvento.mesario;
      case 'aniversario':
        return TipoEvento.aniversario;
      case 'otro':
        return TipoEvento.otro;
      default:
        throw ArgumentError('TipoEvento desconocido: $value');
    }
  }

  static String _tipoEventoToString(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.cumpleanos:
        return 'cumpleanos';
      case TipoEvento.mesario:
        return 'mesario';
      case TipoEvento.aniversario:
        return 'aniversario';
      case TipoEvento.otro:
        return 'otro';
    }
  }

  static EstadoEvento _estadoEventoFromString(String value) {
    switch (value) {
      case 'habilitado':
        return EstadoEvento.habilitado;
      case 'deshabilitado':
        return EstadoEvento.deshabilitado;
      default:
        throw ArgumentError('EstadoEvento desconocido: $value');
    }
  }

  static String _estadoEventoToString(EstadoEvento estado) {
    switch (estado) {
      case EstadoEvento.habilitado:
        return 'habilitado';
      case EstadoEvento.deshabilitado:
        return 'deshabilitado';
    }
  }

  static TipoRecurrencia _tipoRecurrenciaFromString(String value) {
    switch (value) {
      case 'ninguna':
        return TipoRecurrencia.ninguna;
      case 'diaria':
        return TipoRecurrencia.diaria;
      case 'semanal':
        return TipoRecurrencia.semanal;
      case 'mensual':
        return TipoRecurrencia.mensual;
      case 'anual':
        return TipoRecurrencia.anual;
      default:
        throw ArgumentError('TipoRecurrencia desconocido: $value');
    }
  }

  static String _tipoRecurrenciaToString(TipoRecurrencia tipo) {
    switch (tipo) {
      case TipoRecurrencia.ninguna:
        return 'ninguna';
      case TipoRecurrencia.diaria:
        return 'diaria';
      case TipoRecurrencia.semanal:
        return 'semanal';
      case TipoRecurrencia.mensual:
        return 'mensual';
      case TipoRecurrencia.anual:
        return 'anual';
    }
  }
}
