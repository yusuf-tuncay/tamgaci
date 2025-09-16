import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Enhanced error logger with different log levels and contexts
class ErrorLogger {
  static final ErrorLogger _instance = ErrorLogger._internal();
  factory ErrorLogger() => _instance;
  ErrorLogger._internal();

  final Logger _logger = Logger();

  /// Log error with context
  static void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorLogger = ErrorLogger();
    errorLogger._logError(message, error, stackTrace, context, additionalData);
  }

  /// Log warning with context
  static void logWarning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorLogger = ErrorLogger();
    errorLogger._logWarning(
        message, error, stackTrace, context, additionalData);
  }

  /// Log info with context
  static void logInfo(
    String message, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorLogger = ErrorLogger();
    errorLogger._logInfo(message, context, additionalData);
  }

  /// Log debug with context
  static void logDebug(
    String message, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    if (kDebugMode) {
      final errorLogger = ErrorLogger();
      errorLogger._logDebug(message, context, additionalData);
    }
  }

  /// Log performance metrics
  static void logPerformance(
    String operation, {
    required Duration duration,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorLogger = ErrorLogger();
    errorLogger._logPerformance(operation, duration, context, additionalData);
  }

  /// Log user actions
  static void logUserAction(
    String action, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorLogger = ErrorLogger();
    errorLogger._logUserAction(action, context, additionalData);
  }

  /// Log API calls
  static void logApiCall(
    String endpoint, {
    required String method,
    int? statusCode,
    Duration? duration,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorLogger = ErrorLogger();
    errorLogger._logApiCall(
        endpoint, method, statusCode, duration, context, additionalData);
  }

  /// Log Firebase operations
  static void logFirebaseOperation(
    String operation, {
    String? collection,
    String? documentId,
    bool? success,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorLogger = ErrorLogger();
    errorLogger._logFirebaseOperation(
        operation, collection, documentId, success, context, additionalData);
  }

  void _logError(
    String message,
    Object? error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // final logData = _buildLogData(context, additionalData);

    _logger.e(
      'ERROR${context != null ? ' [$context]' : ''}: $message',
      error: error,
      stackTrace: stackTrace,
    );

    // Also log to developer console in debug mode
    if (kDebugMode) {
      developer.log(
        'ERROR${context != null ? ' [$context]' : ''}: $message',
        name: 'TamgaciApp',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Log to AppLogger for consistency
    AppLogger.error(message, error, stackTrace);
  }

  void _logWarning(
    String message,
    Object? error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // final logData = _buildLogData(context, additionalData);

    _logger.w(
      'WARNING${context != null ? ' [$context]' : ''}: $message',
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      developer.log(
        'WARNING${context != null ? ' [$context]' : ''}: $message',
        name: 'TamgaciApp',
        error: error,
        stackTrace: stackTrace,
      );
    }

    AppLogger.warning(message, error, stackTrace);
  }

  void _logInfo(
    String message,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // final logData = _buildLogData(context, additionalData);

    _logger.i('INFO${context != null ? ' [$context]' : ''}: $message');

    if (kDebugMode) {
      developer.log(
        'INFO${context != null ? ' [$context]' : ''}: $message',
        name: 'TamgaciApp',
      );
    }

    AppLogger.info(message);
  }

  void _logDebug(
    String message,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // final logData = _buildLogData(context, additionalData);

    _logger.d('DEBUG${context != null ? ' [$context]' : ''}: $message');

    developer.log(
      'DEBUG${context != null ? ' [$context]' : ''}: $message',
      name: 'TamgaciApp',
    );
  }

  void _logPerformance(
    String operation,
    Duration duration,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // metadata omitted to avoid unused variable warnings

    _logger.i(
        'PERFORMANCE${context != null ? ' [$context]' : ''}: $operation took ${duration.inMilliseconds}ms');

    if (kDebugMode) {
      developer.log(
        'PERFORMANCE${context != null ? ' [$context]' : ''}: $operation took ${duration.inMilliseconds}ms',
        name: 'TamgaciApp',
      );
    }
  }

  void _logUserAction(
    String action,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // metadata omitted to avoid unused variable warnings

    _logger.i('USER_ACTION${context != null ? ' [$context]' : ''}: $action');

    if (kDebugMode) {
      developer.log(
        'USER_ACTION${context != null ? ' [$context]' : ''}: $action',
        name: 'TamgaciApp',
      );
    }
  }

  void _logApiCall(
    String endpoint,
    String method,
    int? statusCode,
    Duration? duration,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // metadata omitted to avoid unused variable warnings

    final status = statusCode != null ? ' [$statusCode]' : '';
    final time = duration != null ? ' (${duration.inMilliseconds}ms)' : '';

    _logger.i(
        'API_CALL${context != null ? ' [$context]' : ''}: $method $endpoint$status$time');

    if (kDebugMode) {
      developer.log(
        'API_CALL${context != null ? ' [$context]' : ''}: $method $endpoint$status$time',
        name: 'TamgaciApp',
      );
    }
  }

  void _logFirebaseOperation(
    String operation,
    String? collection,
    String? documentId,
    bool? success,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // metadata omitted to avoid unused variable warnings

    final successStr =
        success != null ? (success ? ' [SUCCESS]' : ' [FAILED]') : '';
    final collectionStr = collection != null ? ' on $collection' : '';

    _logger.i(
        'FIREBASE${context != null ? ' [$context]' : ''}: $operation$collectionStr$successStr');

    if (kDebugMode) {
      developer.log(
        'FIREBASE${context != null ? ' [$context]' : ''}: $operation$collectionStr$successStr',
        name: 'TamgaciApp',
      );
    }
  }

  // ignore: unused_element
  Map<String, dynamic> _buildLogData(
      String? context, Map<String, dynamic>? additionalData) {
    final logData = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
    };

    if (additionalData != null) {
      logData.addAll(additionalData);
    }

    return logData;
  }
}
