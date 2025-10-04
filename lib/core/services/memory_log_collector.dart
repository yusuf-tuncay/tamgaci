// ========== MEMORY LOG COLLECTOR ==========
// lib/core/services/memory_log_collector.dart

import 'package:tamgaci/core/utils/logger.dart';
import 'colorized_logger_service.dart';
import 'dart:convert';

/// Memory / Session Log Collector
/// Son 50 hata, Export özelliği, UI'dan okunabilir dump
class MemoryLogCollector {
  static bool _isInitialized = false;
  static final List<LogEntry> _logEntries = [];
  static const int _maxLogEntries = 50;
  static String _sessionId = '';
  static DateTime _sessionStartTime = DateTime.now();

  /// Memory log collector'ı başlat
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _sessionStartTime = DateTime.now();
    _isInitialized = true;

    AppLogger.info('Memory log collector initialized');
    ColorizedLoggerService.info('Memory log collector initialized',
        category: 'MemoryLogCollector');
  }

  /// Log entry ekle
  static void addLogEntry({
    required String level,
    required String message,
    String? category,
    String? context,
    Map<String, dynamic>? customData,
    StackTrace? stackTrace,
  }) {
    if (!_isInitialized) {
      AppLogger.warning(
          'Memory log collector not initialized. Log not collected: $message');
      return;
    }

    try {
      final logEntry = LogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        level: level,
        message: message,
        category: category,
        context: context,
        timestamp: DateTime.now(),
        customData: customData ?? {},
        stackTrace: stackTrace?.toString(),
        sessionId: _sessionId,
      );

      _logEntries.add(logEntry);

      // Maksimum log sayısını kontrol et
      if (_logEntries.length > _maxLogEntries) {
        _logEntries.removeAt(0);
      }

      AppLogger.info('Log entry added: $level - $message');
      ColorizedLoggerService.info('Log entry added: $level - $message',
          category: 'MemoryLogCollector');
    } catch (e) {
      AppLogger.error('Failed to add log entry: $e');
    }
  }

  /// Son N hata al
  static List<LogEntry> getLastErrors(int count) {
    return _logEntries
        .where((entry) => entry.level == 'ERROR' || entry.level == 'CRITICAL')
        .take(count)
        .toList();
  }

  /// Tüm logları al
  static List<LogEntry> getAllLogs() {
    return List.from(_logEntries);
  }

  /// Kategoriye göre logları al
  static List<LogEntry> getLogsByCategory(String category) {
    return _logEntries.where((entry) => entry.category == category).toList();
  }

  /// Seviyeye göre logları al
  static List<LogEntry> getLogsByLevel(String level) {
    return _logEntries.where((entry) => entry.level == level).toList();
  }

  /// Logları temizle
  static void clearLogs() {
    _logEntries.clear();
    AppLogger.info('Memory logs cleared');
    ColorizedLoggerService.info('Memory logs cleared',
        category: 'MemoryLogCollector');
  }

  /// Session bilgilerini al
  static Map<String, dynamic> getSessionInfo() {
    return {
      'sessionId': _sessionId,
      'sessionStartTime': _sessionStartTime.toIso8601String(),
      'sessionDuration': DateTime.now().difference(_sessionStartTime).inSeconds,
      'totalLogs': _logEntries.length,
      'errorCount': _logEntries.where((entry) => entry.level == 'ERROR').length,
      'warningCount':
          _logEntries.where((entry) => entry.level == 'WARNING').length,
      'infoCount': _logEntries.where((entry) => entry.level == 'INFO').length,
      'debugCount': _logEntries.where((entry) => entry.level == 'DEBUG').length,
    };
  }

  /// Logları export et
  static String exportLogs() {
    try {
      final exportData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'sessionInfo': getSessionInfo(),
        'totalLogs': _logEntries.length,
        'logs': _logEntries.map((entry) => entry.toJson()).toList(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      AppLogger.error('Failed to export logs: $e');
      return '{}';
    }
  }

  /// Logları JSON formatında al
  static String getLogsAsJson() {
    try {
      return jsonEncode(_logEntries.map((entry) => entry.toJson()).toList());
    } catch (e) {
      AppLogger.error('Failed to get logs as JSON: $e');
      return '[]';
    }
  }

  /// Logları UI'da okunabilir format'ta al
  static String getLogsAsReadableText() {
    try {
      final buffer = StringBuffer();
      buffer.writeln('=== MEMORY LOG COLLECTOR DUMP ===');
      buffer.writeln('Session ID: $_sessionId');
      buffer.writeln('Session Start: ${_sessionStartTime.toIso8601String()}');
      buffer.writeln(
          'Session Duration: ${DateTime.now().difference(_sessionStartTime).inSeconds} seconds');
      buffer.writeln('Total Logs: ${_logEntries.length}');
      buffer.writeln('Max Logs: $_maxLogEntries');
      buffer.writeln('');

      for (final entry in _logEntries) {
        buffer.writeln('--- Log Entry ---');
        buffer.writeln('ID: ${entry.id}');
        buffer.writeln('Level: ${entry.level}');
        buffer.writeln('Message: ${entry.message}');
        buffer.writeln('Category: ${entry.category}');
        buffer.writeln('Context: ${entry.context}');
        buffer.writeln('Timestamp: ${entry.timestamp.toIso8601String()}');
        buffer.writeln('Session ID: ${entry.sessionId}');
        if (entry.customData.isNotEmpty) {
          buffer.writeln('Custom Data: ${jsonEncode(entry.customData)}');
        }
        if (entry.stackTrace != null) {
          buffer.writeln('Stack Trace: ${entry.stackTrace}');
        }
        buffer.writeln('');
      }

      return buffer.toString();
    } catch (e) {
      AppLogger.error('Failed to get logs as readable text: $e');
      return 'Failed to generate readable log dump';
    }
  }

  /// Logları filtrele
  static List<LogEntry> filterLogs({
    String? level,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return _logEntries.where((entry) {
      if (level != null && entry.level != level) return false;
      if (category != null && entry.category != category) return false;
      if (startTime != null && entry.timestamp.isBefore(startTime)) {
        return false;
      }
      if (endTime != null && entry.timestamp.isAfter(endTime)) return false;
      return true;
    }).toList();
  }

  /// Log istatistikleri
  static Map<String, dynamic> getLogStatistics() {
    final stats = <String, int>{};
    for (final entry in _logEntries) {
      stats[entry.level] = (stats[entry.level] ?? 0) + 1;
    }

    return {
      'totalLogs': _logEntries.length,
      'maxLogs': _maxLogEntries,
      'levelStats': stats,
      'sessionDuration': DateTime.now().difference(_sessionStartTime).inSeconds,
      'averageLogsPerMinute': _logEntries.length /
          (DateTime.now().difference(_sessionStartTime).inMinutes + 1),
    };
  }

  /// Service durumunu kontrol et
  static bool get isInitialized => _isInitialized;
  static String get sessionId => _sessionId;
  static DateTime get sessionStartTime => _sessionStartTime;
  static int get logCount => _logEntries.length;
  static int get maxLogEntries => _maxLogEntries;
}

/// Log entry modeli
class LogEntry {
  final String id;
  final String level;
  final String message;
  final String? category;
  final String? context;
  final DateTime timestamp;
  final Map<String, dynamic> customData;
  final String? stackTrace;
  final String sessionId;

  LogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.category,
    this.context,
    required this.timestamp,
    required this.customData,
    this.stackTrace,
    required this.sessionId,
  });

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'message': message,
      'category': category,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'customData': customData,
      'stackTrace': stackTrace,
      'sessionId': sessionId,
    };
  }

  /// JSON'dan oluştur
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      level: json['level'] as String,
      message: json['message'] as String,
      category: json['category'] as String?,
      context: json['context'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      customData: Map<String, dynamic>.from(json['customData'] as Map),
      stackTrace: json['stackTrace'] as String?,
      sessionId: json['sessionId'] as String,
    );
  }
}
