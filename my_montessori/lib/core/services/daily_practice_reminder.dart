import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class DailyPracticeReminder {
  DailyPracticeReminder._();

  static const int _notificationId = 1900;
  static const int _reminderHour = 16;
  static const int _reminderMinute = 0;

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeAndSchedule() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    tz_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    final initialized = await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('app_notification_logo'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    if (initialized != true) {
      throw StateError('No se pudo inicializar el servicio de notificaciones.');
    }

    final permissionGranted = await _requestNotificationPermission();
    if (!permissionGranted) return;

    await _scheduleDailyReminder();
  }

  static Future<bool> _requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidNotifications?.requestNotificationsPermission() ??
          false;
    }

    final iosNotifications = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await iosNotifications?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  static Future<void> _scheduleDailyReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _reminderHour,
      _reminderMinute,
    );
    if (!scheduledTime.isAfter(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _notificationId,
      '¡Bee, bee! Es hora de practicar 🐝',
      'Un ratito de práctica en Mi Montessori.',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_practice_reminder',
          'Recordatorio de práctica',
          channelDescription: 'Un recordatorio diario para practicar.',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('bee_bee'),
          largeIcon: DrawableResourceAndroidBitmap('app_notification_logo'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: 'bee_bee.wav',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
