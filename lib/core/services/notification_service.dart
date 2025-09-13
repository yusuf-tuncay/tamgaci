import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/currency_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Notification servisini başlatır
  Future<void> initialize() async {
    // Web platformunda local notifications desteklenmez
    if (kIsWeb) {
      return;
    }

    try {
      // Timezone'u başlat
      tz_data.initializeTimeZones();

      // Local notifications ayarları
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Notification service initialization failed: $e');
    }
  }

  /// Local notification gösterir
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationImportance importance =
        NotificationImportance.defaultImportance,
  }) async {
    // Web platformunda local notifications desteklenmez
    if (kIsWeb) {
      return;
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'tamgaci_channel',
        'Tamgaci Bildirimleri',
        channelDescription: 'Tamgaci uygulama bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show local notification: $e');
    }
  }

  /// Scheduled notification gösterir
  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'tamgaci_scheduled_channel',
        'Tamgaci Zamanlanmış Bildirimler',
        channelDescription: 'Tamgaci zamanlanmış bildirimler',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // DateTime'ı TZDateTime'a çevir
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show scheduled notification: $e');
    }
  }

  /// Bildirimi iptal eder
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }

  /// Tüm bildirimleri iptal eder
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Local notification tap handler
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
  }

  /// Bildirim ayarlarını kontrol eder
  Future<bool> areNotificationsEnabled() async {
    try {
      final bool? result = await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return result ?? false;
    } catch (e) {
      debugPrint('Failed to check notification settings: $e');
      return false;
    }
  }

  /// Bildirim ayarlarını açar
  Future<void> openNotificationSettings() async {
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Failed to open notification settings: $e');
    }
  }

  /// Para birimi değişikliği bildirimi gösterir
  Future<void> showCurrencyChangeNotification({
    required String oldCurrency,
    required String newCurrency,
    required double exchangeRate,
  }) async {
    final oldSymbol = CurrencyHelper.getCurrencySymbol(oldCurrency);
    final newSymbol = CurrencyHelper.getCurrencySymbol(newCurrency);

    await showLocalNotification(
      id: 1001, // Para birimi değişikliği için özel ID
      title: 'Para Birimi Değişikliği',
      body: "Varsayılan para birimi $oldSymbol'den $newSymbol'e değiştirildi. "
          'Kur: 1 $oldSymbol = ${exchangeRate.toStringAsFixed(4)} $newSymbol',
      importance: NotificationImportance.high,
    );
  }

  /// Kur güncelleme bildirimi gösterir
  Future<void> showExchangeRateUpdateNotification({
    required String currency,
    required double oldRate,
    required double newRate,
  }) async {
    final symbol = CurrencyHelper.getCurrencySymbol(currency);
    final changePercent = ((newRate - oldRate) / oldRate * 100);
    final changeDirection = changePercent >= 0 ? 'artış' : 'azalış';

    await showLocalNotification(
      id: 1002, // Kur güncelleme için özel ID
      title: '$symbol Kuru Güncellendi',
      body:
          '$symbol kuru %${changePercent.abs().toStringAsFixed(2)} $changeDirection gösterdi. '
          'Yeni kur: ${newRate.toStringAsFixed(4)} TRY',
      importance: NotificationImportance.defaultImportance,
    );
  }
}

/// Notification importance enum
enum NotificationImportance {
  low,
  defaultImportance,
  high,
  max,
}
