// ========== NOTIFICATION SERVICE (IO) ==========
// Uses flutter_local_notifications for mobile/desktop. Excluded on Web.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tamgaci/core/utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);
      AppLogger.info('Notification service initialized');
    } catch (e) {
      AppLogger.error('Error initializing notification service', e);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'tamgaci_channel',
        'Tamgaci Notifications',
        channelDescription: 'Tamgaci uygulama bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
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

      AppLogger.info('Notification sent: $title');
    } catch (e) {
      AppLogger.error('Error showing notification', e);
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'tamgaci_scheduled',
        'Tamgaci Scheduled Notifications',
        channelDescription: 'Tamgaci zamanlanmış bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
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

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      AppLogger.info('Scheduled notification: $title at $scheduledDate');
    } catch (e) {
      AppLogger.error('Error scheduling notification', e);
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      AppLogger.info('Notification cancelled: $id');
    } catch (e) {
      AppLogger.error('Error cancelling notification', e);
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      AppLogger.info('All notifications cancelled');
    } catch (e) {
      AppLogger.error('Error cancelling all notifications', e);
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      AppLogger.error('Error getting pending notifications', e);
      return [];
    }
  }
}
