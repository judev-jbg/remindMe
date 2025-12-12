// lib/features/events/domain/entities/evento.dart

import 'package:equatable/equatable.dart';

/// Entidad de dominio para un Evento
class Evento extends Equatable {
  // === IDENTIFICACIÓN ===
  final String id;
  final String nombre;
  final DateTime fecha;

  // === CLASIFICACIÓN ===
  final TipoEvento tipo;
  final String? notas;
  final DateTime? horaEvento; // Solo para tipo "otro"

  // === CONTROL DE RECORDATORIOS ===
  final bool tieneRecordatorio;
  final EstadoEvento estado;

  // === CONFIGURACIÓN DE RECORDATORIOS ===
  final DateTime? fechaHoraInicialRecordatorio;
  final TipoRecurrencia? tipoRecurrencia;
  final int? intervalo;
  final List<int>? diasSemana;
  final DateTime? fechaFinalizacion;
  final int? maxOcurrencias;

  // === METADATA ===
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  const Evento({
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
    required this.fechaActualizacion,
  });

  // === VALIDACIONES ===

  /// Valida que el evento tenga datos coherentes
  bool esValido() {
    // Si tiene recordatorio, debe tener configuración
    if (tieneRecordatorio) {
      if (fechaHoraInicialRecordatorio == null) return false;
      if (tipoRecurrencia == null) return false;

      // Tipos con recurrencia deben tener intervalo
      if (tipoRecurrencia != TipoRecurrencia.ninguna && intervalo == null) {
        return false;
      }

      // Tipo semanal debe tener días seleccionados
      if (tipoRecurrencia == TipoRecurrencia.semanal) {
        if (diasSemana == null || diasSemana!.isEmpty) return false;
      }
    }

    // Tipo "otro" debe tener horaEvento
    if (tipo == TipoEvento.otro && horaEvento == null) {
      return false;
    }

    return true;
  }

  // === MÉTODOS DE COPIA ===

  Evento copyWith({
    String? id,
    String? nombre,
    DateTime? fecha,
    TipoEvento? tipo,
    String? notas,
    DateTime? horaEvento,
    bool? tieneRecordatorio,
    EstadoEvento? estado,
    DateTime? fechaHoraInicialRecordatorio,
    TipoRecurrencia? tipoRecurrencia,
    int? intervalo,
    List<int>? diasSemana,
    DateTime? fechaFinalizacion,
    int? maxOcurrencias,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Evento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      notas: notas ?? this.notas,
      horaEvento: horaEvento ?? this.horaEvento,
      tieneRecordatorio: tieneRecordatorio ?? this.tieneRecordatorio,
      estado: estado ?? this.estado,
      fechaHoraInicialRecordatorio:
          fechaHoraInicialRecordatorio ?? this.fechaHoraInicialRecordatorio,
      tipoRecurrencia: tipoRecurrencia ?? this.tipoRecurrencia,
      intervalo: intervalo ?? this.intervalo,
      diasSemana: diasSemana ?? this.diasSemana,
      fechaFinalizacion: fechaFinalizacion ?? this.fechaFinalizacion,
      maxOcurrencias: maxOcurrencias ?? this.maxOcurrencias,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    fecha,
    tipo,
    notas,
    horaEvento,
    tieneRecordatorio,
    estado,
    fechaHoraInicialRecordatorio,
    tipoRecurrencia,
    intervalo,
    diasSemana,
    fechaFinalizacion,
    maxOcurrencias,
    fechaCreacion,
    fechaActualizacion,
  ];
}

// === ENUMS ===

enum TipoEvento {
  cumpleanos('Cumpleaños'),
  mesario('Mesario'),
  aniversario('Aniversario'),
  otro('Otro');

  final String displayName;
  const TipoEvento(this.displayName);
}

enum EstadoEvento {
  habilitado('Habilitado'),
  deshabilitado('Deshabilitado');

  final String displayName;
  const EstadoEvento(this.displayName);
}

enum TipoRecurrencia {
  ninguna('Sin repetición'),
  diaria('Diaria'),
  semanal('Semanal'),
  mensual('Mensual'),
  anual('Anual');

  final String displayName;
  const TipoRecurrencia(this.displayName);
}
