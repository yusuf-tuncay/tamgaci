// ========== LOGGER OUTPUT FORMATTER ==========
// lib/core/services/logger_output_formatter.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Logger output format standardizasyonu
/// Tüm log çıktılarını standart formatta düzenler
class LoggerOutputFormatter {
  /// Log format tipleri
  static const String _defaultFormat =
      '[{timestamp}] {level} [{category}]{context} {message}';
  static const String _compactFormat = '{level} {message}';
  static const String _detailedFormat =
      '[{timestamp}] {level} [{category}]{context} {message}\n{stackTrace}';
  static const String _jsonFormat =
      '{"timestamp":"{timestamp}","level":"{level}","category":"{category}","context":"{context}","message":"{message}","stackTrace":"{stackTrace}"}';

  /// Timestamp formatı
  static const String _timestampFormat = 'yyyy-MM-dd HH:mm:ss.SSS';

  /// Log format'ı
  static String _currentFormat = _defaultFormat;

  /// Log format'ını ayarla
  static void setFormat(String format) {
    _currentFormat = format;
  }

  /// Log format'ını al
  static String getFormat() {
    return _currentFormat;
  }

  /// Default format'ı kullan
  static void useDefaultFormat() {
    _currentFormat = _defaultFormat;
  }

  /// Compact format'ı kullan
  static void useCompactFormat() {
    _currentFormat = _compactFormat;
  }

  /// Detailed format'ı kullan
  static void useDetailedFormat() {
    _currentFormat = _detailedFormat;
  }

  /// JSON format'ı kullan
  static void useJsonFormat() {
    _currentFormat = _jsonFormat;
  }

  /// Log mesajını formatla
  static String formatLog({
    required String level,
    required String message,
    String? category,
    String? context,
    String? stackTrace,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final formattedTimestamp = DateFormat(_timestampFormat).format(now);

    return _currentFormat
        .replaceAll('{timestamp}', formattedTimestamp)
        .replaceAll('{level}', level)
        .replaceAll('{category}', category ?? '')
        .replaceAll('{context}', context != null ? '($context)' : '')
        .replaceAll('{message}', message)
        .replaceAll('{stackTrace}', stackTrace ?? '');
  }

  /// Log mesajını formatla (basit)
  static String formatSimpleLog({
    required String level,
    required String message,
    String? category,
    String? context,
  }) {
    return formatLog(
      level: level,
      message: message,
      category: category,
      context: context,
    );
  }

  /// Log mesajını formatla (detaylı)
  static String formatDetailedLog({
    required String level,
    required String message,
    String? category,
    String? context,
    String? stackTrace,
    DateTime? timestamp,
  }) {
    return formatLog(
      level: level,
      message: message,
      category: category,
      context: context,
      stackTrace: stackTrace,
      timestamp: timestamp,
    );
  }

  /// JSON log mesajını formatla
  static String formatJsonLog({
    required String level,
    required String message,
    String? category,
    String? context,
    String? stackTrace,
    DateTime? timestamp,
  }) {
    return formatLog(
      level: level,
      message: message,
      category: category,
      context: context,
      stackTrace: stackTrace,
      timestamp: timestamp,
    );
  }

  /// Log mesajını parse et
  static Map<String, String> parseLog(String logMessage) {
    final Map<String, String> result = {};

    // Timestamp parse et
    final timestampMatch =
        RegExp(r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})\]')
            .firstMatch(logMessage);
    if (timestampMatch != null) {
      result['timestamp'] = timestampMatch.group(1)!;
    }

    // Level parse et
    final levelMatch = RegExp(r'(\w+)\s+').firstMatch(logMessage);
    if (levelMatch != null) {
      result['level'] = levelMatch.group(1)!;
    }

    // Category parse et
    final categoryMatch = RegExp(r'\[([^\]]+)\]').firstMatch(logMessage);
    if (categoryMatch != null) {
      result['category'] = categoryMatch.group(1)!;
    }

    // Context parse et
    final contextMatch = RegExp(r'\(([^)]+)\)').firstMatch(logMessage);
    if (contextMatch != null) {
      result['context'] = contextMatch.group(1)!;
    }

    // Message parse et
    final messageMatch = RegExp(r'\]\s+(.+)$').firstMatch(logMessage);
    if (messageMatch != null) {
      result['message'] = messageMatch.group(1)!;
    }

    return result;
  }

  /// Log mesajını validate et
  static bool validateLog(String logMessage) {
    // Temel log format kontrolü
    if (logMessage.isEmpty) return false;

    // Timestamp kontrolü
    final hasTimestamp =
        RegExp(r'\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}\]')
            .hasMatch(logMessage);

    // Level kontrolü
    final hasLevel = RegExp(
            r'\b(ERROR|WARNING|INFO|DEBUG|SUPPRESSED|REMOTE|PERFORMANCE|SUCCESS)\b')
        .hasMatch(logMessage);

    // Message kontrolü
    final hasMessage = logMessage.length > 10;

    return hasTimestamp && hasLevel && hasMessage;
  }

  /// Log mesajını temizle
  static String cleanLog(String logMessage) {
    return logMessage
        .replaceAll(RegExp(r'\x1B\[[0-9;]*[mK]'), '') // ANSI escape codes
        .replaceAll(RegExp(r'\r\n|\r|\n'), ' ') // Newlines
        .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces
        .trim();
  }

  /// Log mesajını renklendir
  static String colorizeLog(String logMessage, String level) {
    // ANSI color codes
    const String red = '\x1B[31m';
    const String yellow = '\x1B[33m';
    const String blue = '\x1B[34m';
    const String green = '\x1B[32m';
    const String magenta = '\x1B[35m';
    const String cyan = '\x1B[36m';
    const String white = '\x1B[37m';
    const String reset = '\x1B[0m';

    String color = reset;
    switch (level.toUpperCase()) {
      case 'ERROR':
        color = red;
        break;
      case 'WARNING':
        color = yellow;
        break;
      case 'INFO':
        color = blue;
        break;
      case 'DEBUG':
        color = green;
        break;
      case 'SUPPRESSED':
        color = white;
        break;
      case 'REMOTE':
        color = magenta;
        break;
      case 'PERFORMANCE':
        color = cyan;
        break;
      case 'SUCCESS':
        color = green;
        break;
    }

    return '$color$logMessage$reset';
  }

  /// Log mesajını debug modda yazdır
  static void debugPrintLog(String logMessage) {
    if (kDebugMode) {
      print('🔍 Logger Output Formatter Debug:');
      print('  📝 Format: $_currentFormat');
      print('  📄 Message: $logMessage');
      print('  ✅ Valid: ${validateLog(logMessage)}');
      print('  🧹 Clean: ${cleanLog(logMessage)}');
    }
  }
}
