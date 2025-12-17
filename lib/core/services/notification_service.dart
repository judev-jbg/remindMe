// lib/core/services/notification_service.dart

import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'alarm_service.dart';

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
    tz.setLocalLocation(
      tz.getLocation('Europe/Madrid'),
    ); // Ajustar según tu zona

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

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

    // CRITICAL: Crear el canal de notificaciones explícitamente para Android 8.0+
    const androidChannel = AndroidNotificationChannel(
      'remindme_channel', // ID debe coincidir con el usado en las notificaciones
      'Recordatorios', // Nombre visible para el usuario
      description: 'Notificaciones de recordatorios de eventos',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Registrar el canal en Android
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Notification channel created successfully
    _initialized = true;
  }

  /// Maneja el tap en una notificación
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navegar a la pantalla del evento
    // Error silencioso en producción - notification tap detected
  }

  /// Solicita permisos de notificación
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // Solicitar permisos para iOS
    final iosResult = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Solicitar permisos para Android 13+
    final androidNotif = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final androidResult = await androidNotif?.requestNotificationsPermission();

    // Solicitar permiso para alarmas exactas (Android 12+)
    final exactAlarmPermission = await androidNotif?.requestExactAlarmsPermission();

    // Verificar si las alarmas exactas están permitidas
    final canScheduleExact = await androidNotif?.canScheduleExactNotifications();

    // Error silencioso en producción - notification permissions requested
    // iOS: ${iosResult ?? "N/A"}
    // Android Notif: ${androidResult ?? "N/A"}
    // Android Exact Alarms: $exactAlarmPermission
    // Can Schedule Exact: ${canScheduleExact ?? "N/A"}

    return (iosResult ?? androidResult) ?? true;
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
    // Error silencioso en producción - scheduling notification
    // ID: $id
    // Título: $title
    // Fecha programada: $scheduledDate
    // Fecha actual: $ahora
    // Diferencia: ${scheduledDate.difference(ahora).inMinutes} minutos

    // Verificar que la fecha sea futura
    if (scheduledDate.isBefore(ahora)) {
      // Error silencioso en producción - cannot schedule notification in the past
      return;
    }

    // En Android, usar AlarmService para alarmas exactas más confiables
    if (Platform.isAndroid) {
      // Error silencioso en producción - using AlarmService for Android
      final success = await AlarmService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
      );

      if (success) {
        // Error silencioso en producción - notification scheduled with AlarmService
      } else {
        // Error silencioso en producción - AlarmService failed, fallback to flutter_local_notifications
        await _scheduleWithFlutterLocalNotifications(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: payload,
        );
      }
    } else {
      // En iOS, usar flutter_local_notifications
      await _scheduleWithFlutterLocalNotifications(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
      );
    }
  }

  /// Programa una notificación usando flutter_local_notifications (fallback o iOS)
  Future<void> _scheduleWithFlutterLocalNotifications({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
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
      // Convertir correctamente a TZDateTime preservando la hora local
      final tzScheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledDate.hour,
        scheduledDate.minute,
        scheduledDate.second,
      );
      // Error silencioso en producción - TZ Scheduled Date: $tzScheduledDate

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      // Error silencioso en producción - notification scheduled successfully

      // Verificar notificaciones pendientes
      final pending = await _notifications.pendingNotificationRequests();
      // Error silencioso en producción - total pending notifications: ${pending.length}
    } catch (e) {
      // Error silencioso en producción - error scheduling notification
      // Stack trace available in debug mode
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

    // Error silencioso en producción - showing immediate notification
    // ID: $id
    // Título: $title
    // Cuerpo: $body

    const androidDetails = AndroidNotificationDetails(
      'remindme_channel',
      'Recordatorios',
      channelDescription: 'Notificaciones de recordatorios de eventos',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
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
      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      // Error silencioso en producción - immediate notification shown successfully
    } catch (e) {
      // Error silencioso en producción - error showing immediate notification
    }
  }
}
