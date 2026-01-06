import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

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

    _initialized = true;
    print('✅ Servicio de notificaciones inicializado');
  }

  /// Solicitar permisos de notificaciones
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Mostrar notificación de solicitud aprobada
  Future<void> showApprovedNotification({
    required String mascotaNombre,
    required String refugioNombre,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'solicitud_aprobada',
      'Solicitudes Aprobadas',
      channelDescription: 'Notificaciones cuando una solicitud es aprobada',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🎉 ¡Solicitud Aprobada!',
      '¡Felicidades! Tu solicitud para adoptar a $mascotaNombre ha sido aprobada por $refugioNombre.',
      details,
      payload: 'approved',
    );
  }

  /// Mostrar notificación de solicitud rechazada
  Future<void> showRejectedNotification({
    required String mascotaNombre,
    required String refugioNombre,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'solicitud_rechazada',
      'Solicitudes Rechazadas',
      channelDescription: 'Notificaciones cuando una solicitud es rechazada',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFF44336),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '❌ Solicitud Rechazada',
      'Tu solicitud para adoptar a $mascotaNombre no fue aprobada por $refugioNombre.',
      details,
      payload: 'rejected',
    );
  }

  /// Callback cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notificación tocada: ${response.payload}');
    // Aquí puedes navegar a la pantalla correspondiente
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
