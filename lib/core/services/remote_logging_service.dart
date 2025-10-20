import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'colorized_logger_service.dart';

/// Remote logging service - Firebase Crashlytics entegrasyonu
class RemoteLoggingService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static bool _isInitialized = false;

  /// Remote logging'i başlat
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Web platformunda Crashlytics'i devre dışı bırak (desktop platformları destekle)
      if (kIsWeb) {
        AppLogger.info('Remote logging disabled on web platform');
        ColorizedLoggerService.remote('Remote logging disabled on web platform',
            category: 'RemoteLogging');
        _isInitialized = true;
        return;
      }

      // Firebase henüz başlatılmadıysa beklemeden çık (main içinde init sonrası tekrar çağrılabilir)
      if (Firebase.apps.isEmpty) {
        AppLogger.error(
            'Failed to initialize remote logging: [core/no-app] Firebase not initialized yet.');
        _isInitialized = true; // Bir daha çağrılırsa yeniden denenecekse main akışında çağrılır
        return;
      }

      // Firebase Crashlytics'i başlat (sadece mobile platformlarda)
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Flutter framework hatalarını yakala
      FlutterError.onError = (FlutterErrorDetails details) {
        _crashlytics.recordFlutterFatalError(details);
      };

      // Platform hatalarını yakala
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      _isInitialized = true;
      AppLogger.info('Remote logging service initialized');
      ColorizedLoggerService.remote('Remote logging service initialized',
          category: 'RemoteLogging');
    } catch (e) {
      AppLogger.error('Failed to initialize remote logging: $e');
      // Hata durumunda da initialized olarak işaretle
      _isInitialized = true;
    }
  }

  /// Error'ı remote'a logla
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? customKeys,
  }) async {
    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('Error logging skipped on web platform: $error');
      return;
    }

    try {
      // Custom keys ekle
      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }

      // Reason ekle
      if (reason != null) {
        await _crashlytics.setCustomKey('reason', reason);
      }

      // Error'ı kaydet
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: fatal,
        information: [
          'Logged by Smart Error Suppressor',
          'Timestamp: ${DateTime.now().toIso8601String()}',
        ],
      );

      AppLogger.info('Error logged to remote: $error');
      ColorizedLoggerService.remote('Error logged to remote: $error',
          category: 'RemoteLogging');
    } catch (e) {
      AppLogger.error('Failed to log error to remote: $e');
    }
  }

  /// Suppressed error'ı remote'a logla (kritik olmayan)
  static Future<void> logSuppressedError(
    dynamic error,
    StackTrace? stackTrace, {
    String? category,
    String? reason,
  }) async {
    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info(
          'Suppressed error logging skipped on web platform: $error');
      return;
    }

    try {
      // Suppressed error olarak işaretle
      await _crashlytics.setCustomKey('suppressed', true);
      await _crashlytics.setCustomKey('category', category ?? 'unknown');
      await _crashlytics.setCustomKey('reason', reason ?? 'Smart suppression');

      // Non-fatal olarak kaydet
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: false,
        information: [
          'Suppressed by Smart Error Suppressor',
          'Category: $category',
          'Reason: $reason',
          'Timestamp: ${DateTime.now().toIso8601String()}',
        ],
      );

      if (kDebugMode) {
        AppLogger.info('Suppressed error logged to remote: $error');
        ColorizedLoggerService.suppressed(
            'Suppressed error logged to remote: $error',
            category: 'RemoteLogging');
      }
    } catch (e) {
      AppLogger.error('Failed to log suppressed error to remote: $e');
    }
  }

  /// User context ekle
  static Future<void> setUserContext({
    String? userId,
    String? userEmail,
    String? tenantId,
  }) async {
    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('User context setting skipped on web platform');
      return;
    }

    try {
      if (userId != null) {
        await _crashlytics.setUserIdentifier(userId);
      }

      await _crashlytics.setCustomKey('user_email', userEmail ?? 'unknown');
      await _crashlytics.setCustomKey('tenant_id', tenantId ?? 'unknown');

      AppLogger.info('User context set for remote logging');
    } catch (e) {
      AppLogger.error('Failed to set user context: $e');
    }
  }

  /// Custom key ekle
  static Future<void> setCustomKey(String key, dynamic value) async {
    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('Custom key setting skipped on web platform: $key');
      return;
    }

    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      AppLogger.error('Failed to set custom key: $e');
    }
  }

  /// Breadcrumb ekle
  static Future<void> addBreadcrumb(String message) async {
    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('Breadcrumb skipped on web platform: $message');
      return;
    }

    try {
      await _crashlytics.log(message);
    } catch (e) {
      AppLogger.error('Failed to add breadcrumb: $e');
    }
  }

  /// Test crash (sadece debug modda)
  static Future<void> testCrash() async {
    if (kDebugMode) {
      _crashlytics.crash();
    }
  }
}
