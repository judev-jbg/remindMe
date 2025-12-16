// lib/features/events/domain/usecases/programar_notificaciones_evento.dart

import '../../../../core/services/notification_service.dart';
import '../entities/evento.dart';
import '../services/recordatorio_calculator.dart';

/// Caso de uso para programar las notificaciones de un evento
class ProgramarNotificacionesEvento {
  final NotificationService _notificationService;

  ProgramarNotificacionesEvento(this._notificationService);

  /// Programa las notificaciones para un evento
  Future<void> call(Evento evento) async {
    // Si el evento no tiene recordatorio o está deshabilitado, no programar nada
    if (!evento.tieneRecordatorio ||
        evento.estado == EstadoEvento.deshabilitado) {
      return;
    }

    // Cancelar notificaciones previas del evento
    await _notificationService.cancelEventNotifications(evento.id);

    // Calcular las próximas notificaciones a programar
    final fechasNotificaciones = _calcularFechasNotificaciones(evento);

    if (fechasNotificaciones.isEmpty) {
      return;
    }

    // Preparar el título y cuerpo de la notificación
    final title = _generarTituloNotificacion(evento);
    final body = _generarCuerpoNotificacion(evento);

    // Programar las notificaciones
    await _notificationService.scheduleRecurringNotifications(
      eventId: evento.id,
      title: title,
      body: body,
      dates: fechasNotificaciones,
    );
  }

  /// Calcula las fechas para las próximas notificaciones
  List<DateTime> _calcularFechasNotificaciones(Evento evento) {
    final List<DateTime> fechas = [];
    final ahora = DateTime.now();

    // Para eventos sin recurrencia (tipo "Otro"), usar la fecha inicial directamente
    if (evento.tipoRecurrencia == TipoRecurrencia.ninguna) {
      if (evento.fechaHoraInicialRecordatorio != null &&
          evento.fechaHoraInicialRecordatorio!.isAfter(ahora)) {
        fechas.add(evento.fechaHoraInicialRecordatorio!);
        print('📅 Notificación única programada para: ${evento.fechaHoraInicialRecordatorio}');
      } else {
        // Si el recordatorio calculado está en el pasado, usar la hora del evento como fallback
        print('⚠️ Fecha de recordatorio no es futura: ${evento.fechaHoraInicialRecordatorio}');

        if (evento.horaEvento != null && evento.horaEvento!.isAfter(ahora)) {
          fechas.add(evento.horaEvento!);
          print('✅ Programando recordatorio en la hora del evento: ${evento.horaEvento}');
        } else {
          print('❌ La hora del evento también está en el pasado: ${evento.horaEvento}');
        }
      }
      return fechas;
    }

    // Para eventos recurrentes, calcular múltiples ocurrencias
    DateTime? proximaFecha =
        RecordatorioCalculator.calcularProximoRecordatorio(evento, 0);

    int ocurrenciasCalculadas = 0;
    const maxOcurrencias = 50;

    while (proximaFecha != null && ocurrenciasCalculadas < maxOcurrencias) {
      // Solo agregar si es futura
      if (proximaFecha.isAfter(ahora)) {
        fechas.add(proximaFecha);
      }

      // Calcular siguiente ocurrencia
      ocurrenciasCalculadas++;

      // Si hay límite de ocurrencias, verificar
      if (evento.maxOcurrencias != null &&
          ocurrenciasCalculadas >= evento.maxOcurrencias!) {
        break;
      }

      // Si hay fecha de finalización, verificar
      if (evento.fechaFinalizacion != null &&
          proximaFecha.isAfter(evento.fechaFinalizacion!)) {
        break;
      }

      // Calcular la siguiente fecha
      proximaFecha = RecordatorioCalculator.calcularProximoRecordatorio(
        evento,
        ocurrenciasCalculadas,
      );
    }

    return fechas;
  }

  /// Genera el título de la notificación según el tipo de evento
  String _generarTituloNotificacion(Evento evento) {
    switch (evento.tipo) {
      case TipoEvento.cumpleanos:
        return '🎂 ¡Cumpleaños hoy!';
      case TipoEvento.aniversario:
        return '💝 ¡Aniversario hoy!';
      case TipoEvento.mesario:
        return '💕 ¡Mesario hoy!';
      case TipoEvento.otro:
        return '📅 Recordatorio';
    }
  }

  /// Genera el cuerpo de la notificación
  String _generarCuerpoNotificacion(Evento evento) {
    final nombre = evento.nombre;

    switch (evento.tipo) {
      case TipoEvento.cumpleanos:
        final edad = DateTime.now().year - evento.fecha.year;
        return '$nombre cumple $edad años';
      case TipoEvento.aniversario:
        final anos = DateTime.now().year - evento.fecha.year;
        return '$nombre - $anos ${anos == 1 ? 'año' : 'años'}';
      case TipoEvento.mesario:
        final meses = _calcularMesesDesde(evento.fecha);
        return '$nombre - $meses ${meses == 1 ? 'mes' : 'meses'}';
      case TipoEvento.otro:
        return nombre;
    }
  }

  /// Calcula los meses desde una fecha
  int _calcularMesesDesde(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia =
        (ahora.year - fecha.year) * 12 + (ahora.month - fecha.month);
    return diferencia;
  }
}
