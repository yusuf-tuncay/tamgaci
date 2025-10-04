// ========== LOG LEVEL STORAGE SERVICE ==========
// lib/core/services/log_level_storage_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'colorized_logger_service.dart';
import 'dart:convert';
import 'dart:io';

/// Log level bazlı storage service
/// Debug: Konsol + Local, Prod: File/Remote only, Error: Her zaman kayıt
class LogLevelStorageService {
  static bool _isInitialized = false;
  static bool _isProductionMode = false;
  static String _storageMode = 'debug'; // debug, production, error
  static SharedPreferences? _prefs;
  static final List<Map<String, dynamic>> _localLogs = [];
  static const int _maxLocalLogs = 1000;

  /// Log level storage'ı başlat
  static Future<void> initialize({
    bool productionMode = false,
    String storageMode = 'debug',
  }) async {
    if (_isInitialized) return;

    _isProductionMode = productionMode;
    _storageMode = storageMode;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;

      AppLogger.info('Log level storage service initialized');
      ColorizedLoggerService.info('Log level storage service initialized',
          category: 'LogLevelStorage');
    } catch (e) {
      AppLogger.error('Failed to initialize log level storage: $e');
    }
  }

  /// Log'u storage'a kaydet
  static Future<void> storeLog({
    required String level,
    required String message,
    String? category,
    String? context,
    Map<String, dynamic>? customData,
  }) async {
    if (!_isInitialized) {
      AppLogger.warning(
          'Log level storage service not initialized. Log not stored: $message');
      return;
    }

    try {
      final logEntry = {
        'level': level,
        'message': message,
        'category': category,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        'customData': customData ?? {},
        'platform': kIsWeb ? 'Web' : Platform.operatingSystem,
        'productionMode': _isProductionMode,
      };

      // Storage mode'a göre kaydet
      switch (_storageMode) {
        case 'debug':
          await _storeDebugLog(logEntry);
          break;
        case 'production':
          await _storeProductionLog(logEntry);
          break;
        case 'error':
          await _storeErrorLog(logEntry);
          break;
      }

      AppLogger.info('Log stored: $level - $message');
      ColorizedLoggerService.info('Log stored: $level - $message',
          category: 'LogLevelStorage');
    } catch (e) {
      AppLogger.error('Failed to store log: $e');
    }
  }

  /// Debug mode: Konsol + Local storage
  static Future<void> _storeDebugLog(Map<String, dynamic> logEntry) async {
    // Konsol'a yazdır
    ColorizedLoggerService.log(
      logEntry['level'],
      logEntry['message'],
      category: logEntry['category'],
      context: logEntry['context'],
    );

    // Local storage'a kaydet
    _localLogs.add(logEntry);
    if (_localLogs.length > _maxLocalLogs) {
      _localLogs.removeAt(0);
    }

    // SharedPreferences'a kaydet
    if (_prefs != null) {
      final logsJson = _localLogs.map((log) => jsonEncode(log)).toList();
      await _prefs!.setStringList('local_logs', logsJson);
    }
  }

  /// Production mode: File/Remote only
  static Future<void> _storeProductionLog(Map<String, dynamic> logEntry) async {
    // Sadece ERROR ve CRITICAL logları kaydet
    if (logEntry['level'] == 'ERROR' || logEntry['level'] == 'CRITICAL') {
      // Remote logging'e gönder
      // Bu kısım AdvancedRemoteLoggingService ile entegre edilecek
      AppLogger.info(
          'Production log stored: ${logEntry['level']} - ${logEntry['message']}');
    }
  }

  /// Error mode: Her zaman kayıt
  static Future<void> _storeErrorLog(Map<String, dynamic> logEntry) async {
    // Her log'u kaydet
    _localLogs.add(logEntry);
    if (_localLogs.length > _maxLocalLogs) {
      _localLogs.removeAt(0);
    }

    // SharedPreferences'a kaydet
    if (_prefs != null) {
      final logsJson = _localLogs.map((log) => jsonEncode(log)).toList();
      await _prefs!.setStringList('local_logs', logsJson);
    }

    // Konsol'a yazdır
    ColorizedLoggerService.log(
      logEntry['level'],
      logEntry['message'],
      category: logEntry['category'],
      context: logEntry['context'],
    );
  }

  /// Local logları al
  static List<Map<String, dynamic>> getLocalLogs() {
    return List.from(_localLogs);
  }

  /// Local logları temizle
  static Future<void> clearLocalLogs() async {
    _localLogs.clear();
    if (_prefs != null) {
      await _prefs!.remove('local_logs');
    }
    AppLogger.info('Local logs cleared');
    ColorizedLoggerService.info('Local logs cleared',
        category: 'LogLevelStorage');
  }

  /// Logları export et
  static Future<String> exportLogs() async {
    try {
      final logs = getLocalLogs();
      final exportData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'totalLogs': logs.length,
        'storageMode': _storageMode,
        'productionMode': _isProductionMode,
        'logs': logs,
      };

      return jsonEncode(exportData);
    } catch (e) {
      AppLogger.error('Failed to export logs: $e');
      return '{}';
    }
  }

  /// Logları import et
  static Future<void> importLogs(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final logs = (data['logs'] as List).cast<Map<String, dynamic>>();

      _localLogs.clear();
      _localLogs.addAll(logs);

      if (_prefs != null) {
        final logsJson = _localLogs.map((log) => jsonEncode(log)).toList();
        await _prefs!.setStringList('local_logs', logsJson);
      }

      AppLogger.info('Logs imported: ${logs.length} entries');
      ColorizedLoggerService.info('Logs imported: ${logs.length} entries',
          category: 'LogLevelStorage');
    } catch (e) {
      AppLogger.error('Failed to import logs: $e');
    }
  }

  /// Storage mode'u değiştir
  static Future<void> setStorageMode(String mode) async {
    _storageMode = mode;
    AppLogger.info('Storage mode changed to: $mode');
    ColorizedLoggerService.info('Storage mode changed to: $mode',
        category: 'LogLevelStorage');
  }

  /// Service durumunu kontrol et
  static bool get isInitialized => _isInitialized;
  static bool get isProductionMode => _isProductionMode;
  static String get storageMode => _storageMode;
  static int get localLogCount => _localLogs.length;
  static int get maxLocalLogs => _maxLocalLogs;
}
