// lib/features/notifications/domain/entities/notificacion_log.dart

import 'package:equatable/equatable.dart';

/// Entidad para el log de notificaciones
class NotificacionLog extends Equatable {
  final String id;
  final TipoAccion tipo;
  final String titulo;
  final String detalle; // JSON string
  final DateTime fechaHora;
  final bool marcada;

  const NotificacionLog({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.detalle,
    required this.fechaHora,
    required this.marcada,
  });

  NotificacionLog copyWith({
    String? id,
    TipoAccion? tipo,
    String? titulo,
    String? detalle,
    DateTime? fechaHora,
    bool? marcada,
  }) {
    return NotificacionLog(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      detalle: detalle ?? this.detalle,
      fechaHora: fechaHora ?? this.fechaHora,
      marcada: marcada ?? this.marcada,
    );
  }

  @override
  List<Object?> get props => [id, tipo, titulo, detalle, fechaHora, marcada];
}

enum TipoAccion {
  eventoCreado('Evento creado'),
  eventoEditado('Evento editado'),
  eventoEliminado('Evento eliminado'),
  recordatorioEnviado('Recordatorio enviado'),
  timelineGenerado('Timeline generado');

  final String displayName;
  const TipoAccion(this.displayName);
}
