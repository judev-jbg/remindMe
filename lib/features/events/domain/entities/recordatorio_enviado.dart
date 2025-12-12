// lib/features/events/domain/entities/recordatorio_enviado.dart

import 'package:equatable/equatable.dart';

/// Entidad para registrar recordatorios que han sido enviados
class RecordatorioEnviado extends Equatable {
  final String id;
  final String eventoId;
  final DateTime fechaHoraEnviado;
  final bool fueVisto;
  final TipoNotificacion tipo;

  const RecordatorioEnviado({
    required this.id,
    required this.eventoId,
    required this.fechaHoraEnviado,
    required this.fueVisto,
    required this.tipo,
  });

  RecordatorioEnviado copyWith({
    String? id,
    String? eventoId,
    DateTime? fechaHoraEnviado,
    bool? fueVisto,
    TipoNotificacion? tipo,
  }) {
    return RecordatorioEnviado(
      id: id ?? this.id,
      eventoId: eventoId ?? this.eventoId,
      fechaHoraEnviado: fechaHoraEnviado ?? this.fechaHoraEnviado,
      fueVisto: fueVisto ?? this.fueVisto,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  List<Object?> get props => [id, eventoId, fechaHoraEnviado, fueVisto, tipo];
}

enum TipoNotificacion {
  push('Push'),
  local('Local');

  final String displayName;
  const TipoNotificacion(this.displayName);
}
