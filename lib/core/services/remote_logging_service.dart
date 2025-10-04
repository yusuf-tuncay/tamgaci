import 'package:flutter/foundation.dart';
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
      // Firebase Crashlytics'i başlat
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
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      AppLogger.error('Failed to set custom key: $e');
    }
  }

  /// Breadcrumb ekle
  static Future<void> addBreadcrumb(String message) async {
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
