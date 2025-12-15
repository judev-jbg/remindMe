// lib/features/events/domain/services/recordatorio_calculator.dart

import '../entities/evento.dart';

/// Servicio para calcular fechas de recordatorios
class RecordatorioCalculator {
  /// Calcula la fecha y hora inicial del recordatorio según el tipo de evento
  static DateTime calcularFechaHoraInicial(Evento evento) {
    switch (evento.tipo) {
      case TipoEvento.cumpleanos:
      case TipoEvento.aniversario:
        // Mismo día a las 8:00 AM
        return DateTime(
          evento.fecha.year,
          evento.fecha.month,
          evento.fecha.day,
          8,
          0,
          0,
        );

      case TipoEvento.mesario:
        // Un mes después a las 8:00 AM
        final unMesDespues = DateTime(
          evento.fecha.year,
          evento.fecha.month + 1,
          evento.fecha.day,
          8,
          0,
          0,
        );
        return unMesDespues;

      case TipoEvento.otro:
        // Usar tiempo personalizado si está definido, o 1 hora antes por defecto
        if (evento.horaEvento == null) {
          // Usar 8:00 AM del mismo día como fallback
          return DateTime(
            evento.fecha.year,
            evento.fecha.month,
            evento.fecha.day,
            8,
            0,
            0,
          );
        }

        // Usar el tiempo personalizado si está definido
        final tiempoAntes = evento.tiempoAvisoAntes?.duration ?? const Duration(hours: 1);
        return evento.horaEvento!.subtract(tiempoAntes);
    }
  }

  /// Obtiene la configuración de recurrencia por defecto según tipo
  static RecordatorioConfig obtenerConfiguracionPorDefecto(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.cumpleanos:
      case TipoEvento.aniversario:
        return RecordatorioConfig(
          tipoRecurrencia: TipoRecurrencia.anual,
          intervalo: 1,
        );

      case TipoEvento.mesario:
        return RecordatorioConfig(
          tipoRecurrencia: TipoRecurrencia.mensual,
          intervalo: 1,
        );

      case TipoEvento.otro:
        return RecordatorioConfig(
          tipoRecurrencia: TipoRecurrencia.ninguna,
          intervalo: null,
        );
    }
  }

  /// Calcula el próximo recordatorio desde ahora
  static DateTime? calcularProximoRecordatorio(
    Evento evento,
    int ocurrenciasEnviadas,
  ) {
    if (!evento.tieneRecordatorio ||
        evento.estado == EstadoEvento.deshabilitado) {
      return null;
    }

    if (evento.fechaHoraInicialRecordatorio == null) {
      return null;
    }

    final ahora = DateTime.now();
    DateTime? proximo = evento.fechaHoraInicialRecordatorio;

    // Si el recordatorio inicial ya pasó, calcular siguiente según recurrencia
    while (proximo != null && proximo.isBefore(ahora)) {
      proximo = _calcularSiguienteOcurrencia(evento, proximo);

      if (proximo == null) break;

      // Verificar límites de finalización
      if (evento.fechaFinalizacion != null &&
          proximo.isAfter(evento.fechaFinalizacion!)) {
        return null;
      }

      if (evento.maxOcurrencias != null &&
          ocurrenciasEnviadas >= evento.maxOcurrencias!) {
        return null;
      }
    }

    return proximo;
  }

  /// Calcula la siguiente ocurrencia del recordatorio
  static DateTime? _calcularSiguienteOcurrencia(
    Evento evento,
    DateTime fechaActual,
  ) {
    if (evento.tipoRecurrencia == null || evento.intervalo == null) {
      return null;
    }

    switch (evento.tipoRecurrencia!) {
      case TipoRecurrencia.ninguna:
        return null; // Sin repetición

      case TipoRecurrencia.diaria:
        return fechaActual.add(Duration(days: evento.intervalo!));

      case TipoRecurrencia.semanal:
        // Avanzar X semanas
        final siguienteSemana = fechaActual.add(
          Duration(days: 7 * evento.intervalo!),
        );

        // TODO: Implementar lógica de diasSemana para filtrar días específicos
        return siguienteSemana;

      case TipoRecurrencia.mensual:
        return DateTime(
          fechaActual.year,
          fechaActual.month + evento.intervalo!,
          fechaActual.day,
          fechaActual.hour,
          fechaActual.minute,
        );

      case TipoRecurrencia.anual:
        return DateTime(
          fechaActual.year + evento.intervalo!,
          fechaActual.month,
          fechaActual.day,
          fechaActual.hour,
          fechaActual.minute,
        );
    }
  }

  /// Verifica si dos fechas son del mismo día
  static bool esMismoDia(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }
}

/// Configuración de recordatorio por defecto
class RecordatorioConfig {
  final TipoRecurrencia tipoRecurrencia;
  final int? intervalo;

  const RecordatorioConfig({required this.tipoRecurrencia, this.intervalo});
}
