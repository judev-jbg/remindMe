// lib/features/events/data/models/recordatorio_enviado_model.dart

import '../../domain/entities/recordatorio_enviado.dart';

/// Modelo de datos para RecordatorioEnviado (mapea a SQLite)
class RecordatorioEnviadoModel extends RecordatorioEnviado {
  const RecordatorioEnviadoModel({
    required super.id,
    required super.eventoId,
    required super.fechaHoraEnviado,
    required super.fueVisto,
    required super.tipo,
  });

  /// Convierte la entidad de dominio a modelo
  factory RecordatorioEnviadoModel.fromEntity(
    RecordatorioEnviado recordatorio,
  ) {
    return RecordatorioEnviadoModel(
      id: recordatorio.id,
      eventoId: recordatorio.eventoId,
      fechaHoraEnviado: recordatorio.fechaHoraEnviado,
      fueVisto: recordatorio.fueVisto,
      tipo: recordatorio.tipo,
    );
  }

  /// Convierte desde un Map de SQLite
  factory RecordatorioEnviadoModel.fromMap(Map<String, dynamic> map) {
    return RecordatorioEnviadoModel(
      id: map['id'] as String,
      eventoId: map['evento_id'] as String,
      fechaHoraEnviado: DateTime.fromMillisecondsSinceEpoch(
        map['fecha_hora_enviado'] as int,
      ),
      fueVisto: (map['fue_visto'] as int) == 1,
      tipo: _tipoNotificacionFromString(map['tipo'] as String),
    );
  }

  /// Convierte a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'fecha_hora_enviado': fechaHoraEnviado.millisecondsSinceEpoch,
      'fue_visto': fueVisto ? 1 : 0,
      'tipo': _tipoNotificacionToString(tipo),
    };
  }

  /// Convierte el modelo a entidad de dominio
  RecordatorioEnviado toEntity() {
    return RecordatorioEnviado(
      id: id,
      eventoId: eventoId,
      fechaHoraEnviado: fechaHoraEnviado,
      fueVisto: fueVisto,
      tipo: tipo,
    );
  }

  // === HELPERS DE CONVERSIÓN ===

  static TipoNotificacion _tipoNotificacionFromString(String value) {
    switch (value) {
      case 'push':
        return TipoNotificacion.push;
      case 'local':
        return TipoNotificacion.local;
      default:
        throw ArgumentError('TipoNotificacion desconocido: $value');
    }
  }

  static String _tipoNotificacionToString(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.push:
        return 'push';
      case TipoNotificacion.local:
        return 'local';
    }
  }
}
