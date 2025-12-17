// lib/core/services/alarm_service.dart

import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import 'notification_service.dart';

/// Servicio para gestionar alarmas exactas con android_alarm_manager_plus
/// Este servicio garantiza que las notificaciones se disparen en el momento exacto
@pragma('vm:entry-point')
class AlarmService {
  static const String _portName = 'remindme_alarm_port';

  /// Inicializa el servicio de alarmas
  @pragma('vm:entry-point')
  static Future<bool> initialize() async {
    try {
      final result = await AndroidAlarmManager.initialize();
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Programa una alarma para mostrar una notificación
  @pragma('vm:entry-point')
  static Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final ahora = DateTime.now();

      // Verificar que la fecha sea futura
      if (scheduledDate.isBefore(ahora)) {
        return false;
      }

      // Programar la alarma exacta
      final success = await AndroidAlarmManager.oneShotAt(
        scheduledDate,
        id,
        _alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {
          'id': id,
          'title': title,
          'body': body,
          'payload': payload,
        },
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Cancela una alarma específica
  @pragma('vm:entry-point')
  static Future<bool> cancelAlarm(int id) async {
    try {
      await AndroidAlarmManager.cancel(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Callback que se ejecuta cuando la alarma se dispara
  /// IMPORTANTE: Este método se ejecuta en un isolate separado
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback(int id, Map<String, dynamic> params) async {
    // Enviar mensaje al isolate principal
    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send?.send(params);

    try {
      // 1. Mostrar la notificación
      final notificationService = NotificationService();
      await notificationService.initialize();

      await notificationService.showImmediateNotification(
        id: params['id'] as int,
        title: params['title'] as String,
        body: params['body'] as String,
        payload: params['payload'] as String?,
      );

      // 2. Registrar en la base de datos
      await _registrarNotificacionEnLog(
        params['title'] as String,
        params['body'] as String,
      );
    } catch (e) {
      // Error silencioso en producción
    }
  }

  /// Registra la notificación en la tabla de logs
  @pragma('vm:entry-point')
  static Future<void> _registrarNotificacionEnLog(
    String titulo,
    String detalle,
  ) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;

      const uuid = Uuid();
      final notificacion = {
        'id': uuid.v4(),
        'tipo': 'recordatorioEnviado',
        'titulo': titulo,
        'detalle': detalle,
        'fecha_hora': DateTime.now().millisecondsSinceEpoch,
        'marcada': 0,
      };

      await db.insert(
        DatabaseHelper.tableNotificacionesLog,
        notificacion,
      );
    } catch (e) {
      // Error silencioso en producción
    }
  }

  /// Registra el puerto para comunicación entre isolates
  @pragma('vm:entry-point')
  static void registerPort() {
    final ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((dynamic data) {
      // Mensaje recibido del callback
    });
  }

  /// Desregistra el puerto
  @pragma('vm:entry-point')
  static void unregisterPort() {
    IsolateNameServer.removePortNameMapping(_portName);
  }
}
