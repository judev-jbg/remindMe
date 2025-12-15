// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio para gestionar notificaciones locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar zonas horarias
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/La_Paz')); // Ajustar según tu zona

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Maneja el tap en una notificación
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navegar a la pantalla del evento
    print('Notification tapped: ${response.payload}');
  }

  /// Solicita permisos de notificación (especialmente para iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true; // En Android siempre retorna true
  }

  /// Programa una notificación para una fecha y hora específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    final ahora = DateTime.now();
    print('⏰ Programando notificación:');
    print('   ID: $id');
    print('   Título: $title');
    print('   Fecha programada: $scheduledDate');
    print('   Fecha actual: $ahora');
    print('   Diferencia: ${scheduledDate.difference(ahora).inMinutes} minutos');

    // Verificar que la fecha sea futura
    if (scheduledDate.isBefore(ahora)) {
      print('❌ Cannot schedule notification in the past: $scheduledDate');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'remindme_channel', // Channel ID
      'Recordatorios', // Channel name
      channelDescription: 'Notificaciones de recordatorios de eventos',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      print('   TZ Scheduled Date: $tzScheduledDate');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      print('✅ Notification scheduled: $title at $scheduledDate');

      // Verificar notificaciones pendientes
      final pending = await _notifications.pendingNotificationRequests();
      print('📋 Total notificaciones pendientes: ${pending.length}');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      print('   Stack trace: ${StackTrace.current}');
    }
  }

  /// Programa múltiples notificaciones (para recordatorios recurrentes)
  Future<void> scheduleRecurringNotifications({
    required String eventId,
    required String title,
    required String body,
    required List<DateTime> dates,
  }) async {
    for (int i = 0; i < dates.length; i++) {
      final notificationId = _generateNotificationId(eventId, i);
      await scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: dates[i],
        payload: eventId,
      );
    }
  }

  /// Cancela una notificación específica
  Future<void> cancelNotification(int id) async {
    if (!_initialized) await initialize();
    await _notifications.cancel(id);
  }

  /// Cancela todas las notificaciones de un evento
  Future<void> cancelEventNotifications(String eventId) async {
    if (!_initialized) await initialize();

    // Cancelar hasta 50 posibles notificaciones del evento
    for (int i = 0; i < 50; i++) {
      final notificationId = _generateNotificationId(eventId, i);
      await _notifications.cancel(notificationId);
    }
  }

  /// Cancela todas las notificaciones programadas
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _notifications.cancelAll();
  }

  /// Obtiene las notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _notifications.pendingNotificationRequests();
  }

  /// Genera un ID único para una notificación basado en el eventId
  int _generateNotificationId(String eventId, int index) {
    // Usar hash del eventId más el índice para generar un ID único
    final hash = eventId.hashCode;
    return (hash + index).abs() % 2147483647; // Max int32
  }

  /// Muestra una notificación inmediata (para testing)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'remindme_channel',
      'Recordatorios',
      channelDescription: 'Notificaciones de recordatorios de eventos',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
