// ========== FIREBASE NOTIFICATION SERVICE ==========
// lib/core/services/firebase_notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_auth_service.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Push Notification servisi
class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// FCM token'ı
  static String? _fcmToken;

  /// FCM token'ını al
  static String? get fcmToken => _fcmToken;

  /// Notification servisini başlat
  static Future<void> initialize() async {
    try {
      // FCM izinlerini iste
      await _requestPermissions();

      // FCM token'ını al
      await _getFCMToken();

      // Local notification'ları başlat (web'de desteklenmez)
      if (!kIsWeb) {
        await _initializeLocalNotifications();
      }

      // Foreground message handler'ını ayarla
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Background message handler'ını ayarla
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Notification tıklama handler'ını ayarla
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // App açıkken notification tıklama handler'ını ayarla
      _messaging.getInitialMessage().then(_handleInitialMessage);

      if (kDebugMode) {
        AppLogger.info(
            'Firebase Notification Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error(
            'Firebase Notification Service initialization failed', e);
      }
    }
  }

  /// FCM izinlerini iste
  static Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        AppLogger.info(
            'User granted permission: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Permission request failed', e);
      }
    }
  }

  /// FCM token'ını al
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      if (_fcmToken != null) {
        // Token'ı Firestore'a kaydet
        await _saveTokenToFirestore(_fcmToken!);

        if (kDebugMode) {
          AppLogger.info('FCM Token: $_fcmToken');
        }
      }

      // Token yenilendiğinde
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        await _saveTokenToFirestore(newToken);

        if (kDebugMode) {
          AppLogger.info('FCM Token refreshed: $newToken');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to get FCM token', e);
      }
    }
  }

  /// Token'ı Firestore'a kaydet
  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuthService.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to save token to Firestore', e);
      }
    }
  }

  /// Local notification'ları başlat
  static Future<void> _initializeLocalNotifications() async {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to initialize local notifications', e);
      }
    }
  }

  /// Foreground message handler
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      AppLogger.info('Got a message whilst in the foreground!');
      AppLogger.info('Message data: ${message.data}');

      if (message.notification != null) {
        AppLogger.info(
            'Message also contained a notification: ${message.notification}');
      }
    }

    // Local notification göster
    _showLocalNotification(message);
  }

  /// Background message handler
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      AppLogger.info('Handling a background message: ${message.messageId}');
    }

    // Background'da local notification göster
    await _showLocalNotification(message);
  }

  /// Notification tıklama handler
  static void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      AppLogger.info('Notification tapped: ${message.data}');
    }

    // Notification'a tıklandığında yapılacak işlemler
    _handleNotificationAction(message.data);
  }

  /// App açıkken notification tıklama handler
  static void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      if (kDebugMode) {
        AppLogger.info('App opened from notification: ${message.data}');
      }
      _handleNotificationAction(message.data);
    }
  }

  /// Local notification tıklama handler
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      AppLogger.info('Local notification tapped: ${response.payload}');
    }

    // Payload'dan data'yı parse et
    if (response.payload != null) {
      // TODO: Payload'dan data'yı parse et ve action'ı handle et
    }
  }

  /// Local notification göster
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'tamgaci_channel',
        'Tamgaci Notifications',
        channelDescription: 'Tamgaci uygulama bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
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
        message.hashCode,
        message.notification?.title ?? 'Tamgaci',
        message.notification?.body ?? '',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to show local notification', e);
      }
    }
  }

  /// Notification action'ını handle et
  static void _handleNotificationAction(Map<String, dynamic> data) {
    // Notification tipine göre farklı action'lar
    final type = data['type'];

    switch (type) {
      case 'invoice':
        // Fatura bildirimi
        break;
      case 'expense':
        // Gider bildirimi
        break;
      case 'income':
        // Gelir bildirimi
        break;
      case 'reminder':
        // Hatırlatma bildirimi
        break;
      default:
        // Genel bildirim
        break;
    }
  }

  /// Topic'e abone ol
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        AppLogger.info('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to subscribe to topic', e);
      }
    }
  }

  /// Topic'ten çık
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        AppLogger.info('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to unsubscribe from topic', e);
      }
    }
  }

  /// Tüm notification'ları temizle
  static Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      if (kDebugMode) {
        AppLogger.info('All notifications cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to clear notifications', e);
      }
    }
  }

  /// Belirli bir notification'ı temizle
  static Future<void> clearNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      if (kDebugMode) {
        AppLogger.info('Notification cleared: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to clear notification', e);
      }
    }
  }

  /// Notification ayarlarını kontrol et
  static Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to check notification settings', e);
      }
      return false;
    }
  }

  /// Notification ayarlarını aç
  static Future<void> openNotificationSettings() async {
    try {
      await _messaging.requestPermission();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to open notification settings', e);
      }
    }
  }
}
