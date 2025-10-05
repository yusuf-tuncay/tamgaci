// ========== ADVANCED REMOTE LOGGING SERVICE ==========
// lib/core/services/advanced_remote_logging_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'colorized_logger_service.dart';
import 'dart:convert';

/// Gelişmiş remote logging service
/// JSON formatında, kategori bazlı, otomatik gönderim
class AdvancedRemoteLoggingService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static bool _isInitialized = false;
  static bool _isProductionMode = false;
  static String _appVersion = '1.0.0';
  static String _platform = 'Flutter Web';

  /// Gelişmiş remote logging'i başlat
  static Future<void> initialize({
    bool productionMode = false,
    String appVersion = '1.0.0',
    String platform = 'Flutter Web',
  }) async {
    if (_isInitialized) return;

    _isProductionMode = productionMode;
    _appVersion = appVersion;
    _platform = platform;

    try {
      // Web platformunda Crashlytics'i devre dışı bırak
      if (kIsWeb) {
        AppLogger.info('Advanced remote logging disabled on web platform');
        ColorizedLoggerService.remote(
            'Advanced remote logging disabled on web platform',
            category: 'AdvancedRemoteLogging');
        _isInitialized = true;
        return;
      }

      // Crashlytics'i başlat (sadece mobile platformlarda)
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Production modda sadece kritik hataları gönder
      if (productionMode) {
        await _crashlytics.setCrashlyticsCollectionEnabled(true);
      }

      _isInitialized = true;
      AppLogger.info('Advanced remote logging service initialized');
      ColorizedLoggerService.remote(
          'Advanced remote logging service initialized',
          category: 'AdvancedRemoteLogging');
    } catch (e) {
      AppLogger.error('Failed to initialize advanced remote logging: $e');
      // Hata durumunda da initialized olarak işaretle
      _isInitialized = true;
    }
  }

  /// Kritik hata logla (JSON formatında)
  static Future<void> logCriticalError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
    String? category,
    String? severity = 'CRITICAL',
    Map<String, dynamic>? customKeys,
  }) async {
    if (!_isInitialized) {
      AppLogger.warning(
          'Advanced remote logging service not initialized. Critical error not logged: $error');
      return;
    }

    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('Critical error logging skipped on web platform: $error');
      return;
    }

    try {
      // JSON formatında log data oluştur
      final logData = {
        'error': error.toString(),
        'reason': reason,
        'category': category,
        'severity': severity,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': _platform,
        'version': _appVersion,
        'productionMode': _isProductionMode,
        'customKeys': customKeys ?? {},
        'stackTrace': stack?.toString(),
      };

      // Custom keys ekle
      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Category ve severity ekle
      if (category != null) {
        await _crashlytics.setCustomKey('category', category);
      }
      await _crashlytics.setCustomKey('severity', severity.toString());

      // JSON data'yı information olarak ekle
      await _crashlytics.recordError(
        error,
        stack,
        reason: reason,
        information: [
          'Advanced Remote Logging',
          'Timestamp: ${DateTime.now().toIso8601String()}',
          'Category: $category',
          'Severity: $severity',
          'JSON Data: ${jsonEncode(logData)}',
        ],
      );

      AppLogger.info('Critical error logged to remote: $error');
      ColorizedLoggerService.remote('Critical error logged to remote: $error',
          category: 'AdvancedRemoteLogging');
    } catch (e) {
      AppLogger.error('Failed to log critical error to remote: $e');
    }
  }

  /// Warning logla (JSON formatında)
  static Future<void> logWarning(
    dynamic error,
    StackTrace? stack, {
    String? reason,
    String? category,
    String? severity = 'WARNING',
    Map<String, dynamic>? customKeys,
  }) async {
    if (!_isInitialized) return;

    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('Warning logging skipped on web platform: $error');
      return;
    }

    try {
      // Production modda sadece kritik hataları gönder
      if (_isProductionMode && severity != 'CRITICAL') {
        return;
      }

      final logData = {
        'error': error.toString(),
        'reason': reason,
        'category': category,
        'severity': severity,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': _platform,
        'version': _appVersion,
        'productionMode': _isProductionMode,
        'customKeys': customKeys ?? {},
        'stackTrace': stack?.toString(),
      };

      // Custom keys ekle
      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Category ve severity ekle
      if (category != null) {
        await _crashlytics.setCustomKey('category', category);
      }
      await _crashlytics.setCustomKey('severity', severity.toString());

      // Warning olarak kaydet
      await _crashlytics.recordError(
        error,
        stack,
        reason: reason,
        information: [
          'Advanced Remote Logging - Warning',
          'Timestamp: ${DateTime.now().toIso8601String()}',
          'Category: $category',
          'Severity: $severity',
          'JSON Data: ${jsonEncode(logData)}',
        ],
      );

      AppLogger.info('Warning logged to remote: $error');
      ColorizedLoggerService.remote('Warning logged to remote: $error',
          category: 'AdvancedRemoteLogging');
    } catch (e) {
      AppLogger.error('Failed to log warning to remote: $e');
    }
  }

  /// Info logla (JSON formatında)
  static Future<void> logInfo(
    String message, {
    String? category,
    String? severity = 'INFO',
    Map<String, dynamic>? customKeys,
  }) async {
    if (!_isInitialized) return;

    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('Info logging skipped on web platform: $message');
      return;
    }

    try {
      // Production modda sadece kritik hataları gönder
      if (_isProductionMode && severity != 'CRITICAL') {
        return;
      }

      final logData = {
        'message': message,
        'category': category,
        'severity': severity,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': _platform,
        'version': _appVersion,
        'productionMode': _isProductionMode,
        'customKeys': customKeys ?? {},
      };

      // Custom keys ekle
      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Category ve severity ekle
      if (category != null) {
        await _crashlytics.setCustomKey('category', category);
      }
      await _crashlytics.setCustomKey('severity', severity.toString());

      // Info olarak kaydet
      await _crashlytics.recordError(
        message,
        StackTrace.current,
        reason: 'Info Log',
        information: [
          'Advanced Remote Logging - Info',
          'Timestamp: ${DateTime.now().toIso8601String()}',
          'Category: $category',
          'Severity: $severity',
          'JSON Data: ${jsonEncode(logData)}',
        ],
      );

      AppLogger.info('Info logged to remote: $message');
      ColorizedLoggerService.remote('Info logged to remote: $message',
          category: 'AdvancedRemoteLogging');
    } catch (e) {
      AppLogger.error('Failed to log info to remote: $e');
    }
  }

  /// Kullanıcı bilgilerini ayarla
  static Future<void> setUserInfo({
    String? userId,
    String? userEmail,
    String? userName,
    Map<String, dynamic>? customAttributes,
  }) async {
    if (!_isInitialized) return;

    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('User info setting skipped on web platform');
      return;
    }

    try {
      if (userId != null) {
        await _crashlytics.setUserIdentifier(userId);
      }

      if (userEmail != null) {
        await _crashlytics.setCustomKey('userEmail', userEmail);
      }

      if (userName != null) {
        await _crashlytics.setCustomKey('userName', userName);
      }

      if (customAttributes != null) {
        for (final entry in customAttributes.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      AppLogger.info('User info set for remote logging');
      ColorizedLoggerService.remote('User info set for remote logging',
          category: 'AdvancedRemoteLogging');
    } catch (e) {
      AppLogger.error('Failed to set user info for remote logging: $e');
    }
  }

  /// Breadcrumb ekle
  static void addBreadcrumb(
    String message, {
    String? category,
    String? context,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return;

    // Web platformunda devre dışı
    if (kIsWeb) {
      AppLogger.info('Breadcrumb skipped on web platform: $message');
      return;
    }

    try {
      final breadcrumbData = {
        'message': message,
        'category': category,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data ?? {},
      };

      _crashlytics.log('[$category] $context: $message');
      _crashlytics.setCustomKey('lastBreadcrumb', jsonEncode(breadcrumbData));

      AppLogger.info('Breadcrumb added: $message');
      ColorizedLoggerService.remote('Breadcrumb added: $message',
          category: 'AdvancedRemoteLogging');
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

  /// Service durumunu kontrol et
  static bool get isInitialized => _isInitialized;
  static bool get isProductionMode => _isProductionMode;
  static String get appVersion => _appVersion;
  static String get platform => _platform;
}
