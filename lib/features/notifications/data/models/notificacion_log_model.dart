// lib/features/notifications/data/models/notificacion_log_model.dart

import '../../domain/entities/notificacion_log.dart';

/// Modelo de datos para NotificacionLog (mapea a SQLite)
class NotificacionLogModel extends NotificacionLog {
  const NotificacionLogModel({
    required super.id,
    required super.tipo,
    required super.titulo,
    required super.detalle,
    required super.fechaHora,
    required super.marcada,
  });

  /// Convierte la entidad de dominio a modelo
  factory NotificacionLogModel.fromEntity(NotificacionLog notificacion) {
    return NotificacionLogModel(
      id: notificacion.id,
      tipo: notificacion.tipo,
      titulo: notificacion.titulo,
      detalle: notificacion.detalle,
      fechaHora: notificacion.fechaHora,
      marcada: notificacion.marcada,
    );
  }

  /// Convierte desde un Map de SQLite
  factory NotificacionLogModel.fromMap(Map<String, dynamic> map) {
    return NotificacionLogModel(
      id: map['id'] as String,
      tipo: _tipoAccionFromString(map['tipo'] as String),
      titulo: map['titulo'] as String,
      detalle: map['detalle'] as String,
      fechaHora: DateTime.fromMillisecondsSinceEpoch(map['fecha_hora'] as int),
      marcada: (map['marcada'] as int) == 1,
    );
  }

  /// Convierte a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': _tipoAccionToString(tipo),
      'titulo': titulo,
      'detalle': detalle,
      'fecha_hora': fechaHora.millisecondsSinceEpoch,
      'marcada': marcada ? 1 : 0,
    };
  }

  /// Convierte el modelo a entidad de dominio
  NotificacionLog toEntity() {
    return NotificacionLog(
      id: id,
      tipo: tipo,
      titulo: titulo,
      detalle: detalle,
      fechaHora: fechaHora,
      marcada: marcada,
    );
  }

  // === HELPERS DE CONVERSIÓN ===

  static TipoAccion _tipoAccionFromString(String value) {
    switch (value) {
      case 'eventoCreado':
        return TipoAccion.eventoCreado;
      case 'eventoEditado':
        return TipoAccion.eventoEditado;
      case 'eventoEliminado':
        return TipoAccion.eventoEliminado;
      case 'recordatorioEnviado':
        return TipoAccion.recordatorioEnviado;
      case 'timelineGenerado':
        return TipoAccion.timelineGenerado;
      default:
        throw ArgumentError('TipoAccion desconocido: $value');
    }
  }

  static String _tipoAccionToString(TipoAccion tipo) {
    switch (tipo) {
      case TipoAccion.eventoCreado:
        return 'eventoCreado';
      case TipoAccion.eventoEditado:
        return 'eventoEditado';
      case TipoAccion.eventoEliminado:
        return 'eventoEliminado';
      case TipoAccion.recordatorioEnviado:
        return 'recordatorioEnviado';
      case TipoAccion.timelineGenerado:
        return 'timelineGenerado';
    }
  }
}
