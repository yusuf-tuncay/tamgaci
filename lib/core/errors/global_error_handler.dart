import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Global error handler for the application
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  /// Initialize global error handling
  void initialize() {
    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Platform errors (Android/iOS)
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // Zone errors
    runZonedGuarded(
      () {
        // App initialization code here
      },
      (error, stack) {
        _handleZoneError(error, stack);
      },
    );
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter Error: ${details.exception}',
      details.exception,
      details.stack,
    );

    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      // In production, log the error and show user-friendly message
      _showErrorDialog('Bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  /// Handle platform errors
  void _handlePlatformError(Object error, StackTrace stack) {
    AppLogger.error(
      'Platform Error: $error',
      error,
      stack,
    );

    if (!kDebugMode) {
      _showErrorDialog('Sistem hatası oluştu. Uygulama yeniden başlatılacak.');
    }
  }

  /// Handle zone errors
  void _handleZoneError(Object error, StackTrace stack) {
    AppLogger.error(
      'Zone Error: $error',
      error,
      stack,
    );

    if (!kDebugMode) {
      _showErrorDialog('Beklenmeyen bir hata oluştu.');
    }
  }

  /// Show error dialog to user
  void _showErrorDialog(String message) {
    // This would be called from a context-aware location
    // For now, just log the message
    AppLogger.warning('User Error Dialog: $message');
  }

  /// Handle business logic errors
  static void handleBusinessError(String message,
      {Object? error, StackTrace? stackTrace}) {
    AppLogger.error(message, error, stackTrace);

    if (!kDebugMode) {
      // Show user-friendly error message
      AppLogger.warning('Business Error: $message');
    }
  }

  /// Handle network errors
  static void handleNetworkError(String message,
      {Object? error, StackTrace? stackTrace}) {
    AppLogger.error('Network Error: $message', error, stackTrace);

    if (!kDebugMode) {
      AppLogger.warning('Network Error: İnternet bağlantınızı kontrol edin.');
    }
  }

  /// Handle Firebase errors
  static void handleFirebaseError(String message,
      {Object? error, StackTrace? stackTrace}) {
    AppLogger.error('Firebase Error: $message', error, stackTrace);

    if (!kDebugMode) {
      AppLogger.warning('Firebase Error: Veri işleme hatası oluştu.');
    }
  }

  /// Handle validation errors
  static void handleValidationError(String message,
      {Object? error, StackTrace? stackTrace}) {
    AppLogger.warning('Validation Error: $message', error, stackTrace);
  }

  /// Handle permission errors
  static void handlePermissionError(String message,
      {Object? error, StackTrace? stackTrace}) {
    AppLogger.warning('Permission Error: $message', error, stackTrace);

    if (!kDebugMode) {
      AppLogger.warning('Permission Error: Gerekli izinler verilmedi.');
    }
  }
}
