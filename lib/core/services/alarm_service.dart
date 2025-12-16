// lib/core/services/alarm_service.dart

import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
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
      print('✅ AlarmService inicializado: $result');
      return result;
    } catch (e) {
      print('❌ Error inicializando AlarmService: $e');
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
        print('❌ Cannot schedule alarm in the past: $scheduledDate');
        return false;
      }

      print('⏰ AlarmService: Programando alarma exacta:');
      print('   ID: $id');
      print('   Título: $title');
      print('   Fecha programada: $scheduledDate');
      print('   Fecha actual: $ahora');
      print('   Diferencia: ${scheduledDate.difference(ahora).inMinutes} minutos');

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

      if (success) {
        print('✅ AlarmService: Alarma programada exitosamente');
      } else {
        print('❌ AlarmService: Error programando alarma');
      }

      return success;
    } catch (e) {
      print('❌ AlarmService: Error al programar alarma: $e');
      return false;
    }
  }

  /// Cancela una alarma específica
  @pragma('vm:entry-point')
  static Future<bool> cancelAlarm(int id) async {
    try {
      await AndroidAlarmManager.cancel(id);
      print('✅ AlarmService: Alarma $id cancelada');
      return true;
    } catch (e) {
      print('❌ AlarmService: Error cancelando alarma $id: $e');
      return false;
    }
  }

  /// Callback que se ejecuta cuando la alarma se dispara
  /// IMPORTANTE: Este método se ejecuta en un isolate separado
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback(int id, Map<String, dynamic> params) async {
    print('🔔 AlarmService: Alarma disparada - ID: $id');
    print('   Params: $params');

    // Enviar mensaje al isolate principal
    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send?.send(params);

    // Mostrar la notificación directamente
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      await notificationService.showImmediateNotification(
        id: params['id'] as int,
        title: params['title'] as String,
        body: params['body'] as String,
        payload: params['payload'] as String?,
      );

      print('✅ AlarmService: Notificación mostrada');
    } catch (e) {
      print('❌ AlarmService: Error mostrando notificación: $e');
    }
  }

  /// Registra el puerto para comunicación entre isolates
  @pragma('vm:entry-point')
  static void registerPort() {
    final ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((dynamic data) {
      print('📬 AlarmService: Mensaje recibido del callback: $data');
    });
  }

  /// Desregistra el puerto
  @pragma('vm:entry-point')
  static void unregisterPort() {
    IsolateNameServer.removePortNameMapping(_portName);
  }
}
