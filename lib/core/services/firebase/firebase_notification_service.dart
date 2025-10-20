// ========== FIREBASE NOTIFICATION SERVICE ==========
// lib/core/services/firebase/firebase_notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase bildirim servisi
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool get _isMessagingSupported {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return true; // Tüm desktop platformları destekle
      default:
        return false;
    }
  }

  /// Firebase bildirim servisini başlat
  static Future<void> initialize() async {
    try {
      final service = FirebaseNotificationService();
      await service._initialize();
      AppLogger.info('Firebase notification service initialized');
    } catch (e) {
      AppLogger.error('Error initializing Firebase notification service', e);
    }
  }

  /// Servisi başlat (asenkron - izin beklemeden)
  Future<void> _initialize() async {
    try {
      // Web için service worker'ı önce kaydet
      if (kIsWeb) {
        await _registerServiceWorker();
      }

      // Mobil/Web dışı platformlarda FCM'i atla
      if (!_isMessagingSupported) {
        AppLogger.info('Firebase Messaging not supported on this platform');
        return;
      }

      // İzin iste (asenkron - beklemeden). Sadece desteklenen platformlarda
      _requestPermission();

      // Token al (asenkron)
      _getToken();

      // Mesaj dinleyicilerini ayarla
      _setupMessageHandlers();

      AppLogger.info('Firebase notification service setup completed');
    } catch (e) {
      AppLogger.error('Error setting up Firebase notification service', e);
    }
  }

  /// Bildirim izni iste (asenkron)
  Future<void> _requestPermission() async {
    if (!_isMessagingSupported) return;
    // Asenkron olarak arka planda çalıştır
    Future.microtask(() async {
      try {
        // Web için özel permission handling
        if (kIsWeb) {
          // Web'de service worker'ı kaydet
          await _registerServiceWorker();
        }

        final settings = await _messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        AppLogger.info(
            'Notification permission status: ${settings.authorizationStatus}');
      } catch (e) {
        AppLogger.error('Error requesting notification permission', e);
      }
    });
  }

  /// Web için service worker kaydet
  Future<void> _registerServiceWorker() async {
    if (kIsWeb) {
      try {
        // Service worker'ı kaydet
        await _messaging.getToken();
        AppLogger.info('Service worker registered for web notifications');
      } catch (e) {
        AppLogger.warning(
            'Service worker registration failed (non-critical): $e');
        // Service worker hatası kritik değil, uygulama çalışmaya devam eder
      }
    }
  }

  /// FCM token al
  Future<String?> _getToken() async {
    if (!_isMessagingSupported) {
      AppLogger.info('Skipping FCM token on unsupported platform');
      return null;
    }
    try {
      String? token;
      // Tüm platformlar için normal token al
      token = await _messaging.getToken();
      AppLogger.info('FCM Token: $token');
      return token;
    } catch (e) {
      AppLogger.error('Error getting FCM token', e);
      return null;
    }
  }

  /// Mesaj dinleyicilerini ayarla
  void _setupMessageHandlers() {
    if (!_isMessagingSupported) return;
    // Foreground mesajları
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background mesajları
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Uygulama kapalıyken gelen mesajlar
    _handleInitialMessage();
  }

  /// Foreground mesaj işleme
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      AppLogger.info('Foreground message received: ${message.messageId}');

      // Mesaj içeriğini logla
      AppLogger.info('Message data: ${message.data}');
      AppLogger.info('Message notification: ${message.notification?.title}');

      // Burada bildirim gösterilebilir
      // NotificationService().showNotification(...)
    } catch (e) {
      AppLogger.error('Error handling foreground message', e);
    }
  }

  /// Background mesaj işleme
  void _handleBackgroundMessage(RemoteMessage message) {
    try {
      AppLogger.info('Background message received: ${message.messageId}');

      // Mesaj içeriğini logla
      AppLogger.info('Message data: ${message.data}');
      AppLogger.info('Message notification: ${message.notification?.title}');

      // Burada gerekli işlemler yapılabilir
    } catch (e) {
      AppLogger.error('Error handling background message', e);
    }
  }

  /// İlk mesaj işleme (uygulama kapalıyken gelen)
  Future<void> _handleInitialMessage() async {
    if (!_isMessagingSupported) return;
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.info('Initial message received: ${initialMessage.messageId}');
        _handleBackgroundMessage(initialMessage);
      }
    } catch (e) {
      AppLogger.error('Error handling initial message', e);
    }
  }

  /// Token yenileme dinleyicisi
  void listenToTokenRefresh() {
    if (!_isMessagingSupported) return;
    _messaging.onTokenRefresh.listen((token) {
      AppLogger.info('FCM Token refreshed: $token');
      // Burada yeni token'ı sunucuya gönderebilirsiniz
    });
  }

  /// Topic'e abone ol
  Future<void> subscribeToTopic(String topic) async {
    if (!_isMessagingSupported) return;
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.info('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Error subscribing to topic: $topic', e);
    }
  }

  /// Topic'ten çık
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isMessagingSupported) return;
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic: $topic', e);
    }
  }

  /// Mevcut token'ı al
  Future<String?> getCurrentToken() async {
    try {
      if (!_isMessagingSupported) return null;
      if (kIsWeb) {
        // Web için VAPID key ile token al
        return await _messaging.getToken(
            vapidKey:
                "BEl62iUYgUivxIkv69yViEuiBIa40HI8lF7vVfHhf4KEyXpgQXr5lUI3kI8yP9OfLQcAbP6eg2SWg1-2tpg4o");
      } else {
        // Mobile için normal token al
        return await _messaging.getToken();
      }
    } catch (e) {
      AppLogger.error('Error getting current token', e);
      return null;
    }
  }

  /// Bildirim ayarlarını al
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      if (!_isMessagingSupported) {
        // Desteklenmeyen platformlarda varsayılan yetkiler
        return const NotificationSettings(
          authorizationStatus: AuthorizationStatus.denied,
          alert: AppleNotificationSetting.notSupported,
          announcement: AppleNotificationSetting.notSupported,
          badge: AppleNotificationSetting.notSupported,
          carPlay: AppleNotificationSetting.notSupported,
          criticalAlert: AppleNotificationSetting.notSupported,
          lockScreen: AppleNotificationSetting.notSupported,
          notificationCenter: AppleNotificationSetting.notSupported,
          showPreviews: AppleShowPreviewSetting.always,
          sound: AppleNotificationSetting.notSupported,
          timeSensitive: AppleNotificationSetting.notSupported,
          providesAppNotificationSettings: AppleNotificationSetting.notSupported,
        );
      }
      return await _messaging.getNotificationSettings();
    } catch (e) {
      AppLogger.error('Error getting notification settings', e);
      rethrow;
    }
  }
}

/// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    AppLogger.info('Background message handler: ${message.messageId}');

    // Mesaj içeriğini logla
    AppLogger.info('Message data: ${message.data}');
    AppLogger.info('Message notification: ${message.notification?.title}');

    // Burada gerekli işlemler yapılabilir
  } catch (e) {
    AppLogger.error('Error in background message handler', e);
  }
}
