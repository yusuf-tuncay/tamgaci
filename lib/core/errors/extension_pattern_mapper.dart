// ========== EXTENSION PATTERN MAPPER ==========
// lib/core/errors/extension_pattern_mapper.dart

import 'package:flutter/foundation.dart';

/// Extension pattern haritası
/// Smart Suppressor için extension pattern'ları yönetir
class ExtensionPatternMapper {
  /// Extension pattern'ları
  static final Map<String, List<String>> _extensionPatterns = {
    // Camera extensions
    'camera': [
      'CameraException',
      'CameraAccessDenied',
      'CameraPermission',
      'Camera not available',
      'Camera initialization failed',
      'CameraController',
      'Camera preview',
      'Camera permission',
      'Camera access',
      'Camera error',
      'Camera failed',
      'Camera unavailable',
      'Camera denied',
      'Camera blocked',
      'Camera restricted',
    ],

    // Map extensions
    'map': [
      'MapController',
      'GoogleMap',
      'MapView',
      'LocationService',
      'Geolocator',
      'Map initialization',
      'Map rendering',
      'Map tiles',
      'Map error',
      'Map failed',
      'Map unavailable',
      'Map permission',
      'Map access',
      'Map denied',
      'Map blocked',
      'Map restricted',
      'Location permission',
      'Location access',
      'Location denied',
      'Location blocked',
      'Location restricted',
    ],

    // WebView extensions
    'webview': [
      'WebView',
      'WebViewController',
      'WebView initialization',
      'WebView loading',
      'WebView navigation',
      'WebView JavaScript',
      'WebView security',
      'WebView error',
      'WebView failed',
      'WebView unavailable',
      'WebView permission',
      'WebView access',
      'WebView denied',
      'WebView blocked',
      'WebView restricted',
      'WebView timeout',
      'WebView connection',
      'WebView network',
      'WebView SSL',
      'WebView certificate',
    ],

    // Network extensions
    'network': [
      'NetworkException',
      'ConnectionException',
      'TimeoutException',
      'SocketException',
      'HttpException',
      'Network error',
      'Connection error',
      'Timeout error',
      'Socket error',
      'HTTP error',
      'Network unavailable',
      'Connection failed',
      'Timeout occurred',
      'Socket failed',
      'HTTP failed',
    ],

    // Database extensions
    'database': [
      'DatabaseException',
      'SQLException',
      'Database error',
      'SQL error',
      'Database unavailable',
      'Database failed',
      'Database connection',
      'Database timeout',
      'Database locked',
      'Database corrupted',
      'Database permission',
      'Database access',
      'Database denied',
      'Database blocked',
      'Database restricted',
    ],

    // File system extensions
    'filesystem': [
      'FileSystemException',
      'FileException',
      'DirectoryException',
      'File system error',
      'File error',
      'Directory error',
      'File system unavailable',
      'File unavailable',
      'Directory unavailable',
      'File system failed',
      'File failed',
      'Directory failed',
      'File system permission',
      'File permission',
      'Directory permission',
      'File system access',
      'File access',
      'Directory access',
      'File system denied',
      'File denied',
      'Directory denied',
      'File system blocked',
      'File blocked',
      'Directory blocked',
      'File system restricted',
      'File restricted',
      'Directory restricted',
    ],

    // Permission extensions
    'permission': [
      'PermissionException',
      'Permission denied',
      'Permission blocked',
      'Permission restricted',
      'Permission unavailable',
      'Permission failed',
      'Permission error',
      'Permission access',
      'Permission denied by user',
      'Permission denied by system',
      'Permission denied by policy',
      'Permission denied by security',
      'Permission denied by privacy',
      'Permission denied by settings',
      'Permission denied by configuration',
    ],

    // Security extensions
    'security': [
      'SecurityException',
      'Security error',
      'Security failed',
      'Security unavailable',
      'Security denied',
      'Security blocked',
      'Security restricted',
      'Security access',
      'Security permission',
      'Security violation',
      'Security breach',
      'Security threat',
      'Security risk',
      'Security vulnerability',
      'Security exploit',
    ],
  };

  /// Extension pattern'ları al
  static List<String> getExtensionPatterns(String extension) {
    return _extensionPatterns[extension] ?? [];
  }

  /// Tüm extension pattern'ları al
  static Map<String, List<String>> getAllExtensionPatterns() {
    return Map.from(_extensionPatterns);
  }

  /// Extension pattern ekle
  static void addExtensionPattern(String extension, List<String> patterns) {
    _extensionPatterns[extension] = patterns;
  }

  /// Extension pattern güncelle
  static void updateExtensionPattern(String extension, List<String> patterns) {
    _extensionPatterns[extension] = patterns;
  }

  /// Extension pattern sil
  static void removeExtensionPattern(String extension) {
    _extensionPatterns.remove(extension);
  }

  /// Extension pattern'ı kontrol et
  static bool hasExtensionPattern(String extension) {
    return _extensionPatterns.containsKey(extension);
  }

  /// Extension pattern'ları filtrele
  static List<String> filterExtensionPatterns(String query) {
    final List<String> results = [];
    for (final entry in _extensionPatterns.entries) {
      if (entry.key.toLowerCase().contains(query.toLowerCase()) ||
          entry.value.any((pattern) =>
              pattern.toLowerCase().contains(query.toLowerCase()))) {
        results.add(entry.key);
      }
    }
    return results;
  }

  /// Extension pattern'ları arama
  static List<String> searchExtensionPatterns(String query) {
    final List<String> results = [];
    for (final entry in _extensionPatterns.entries) {
      for (final pattern in entry.value) {
        if (pattern.toLowerCase().contains(query.toLowerCase())) {
          results.add('${entry.key}: $pattern');
        }
      }
    }
    return results;
  }

  /// Extension pattern'ları say
  static int getExtensionPatternCount(String extension) {
    return _extensionPatterns[extension]?.length ?? 0;
  }

  /// Toplam extension pattern sayısı
  static int getTotalExtensionPatternCount() {
    return _extensionPatterns.values
        .fold(0, (sum, patterns) => sum + patterns.length);
  }

  /// Extension pattern'ları debug modda yazdır
  static void debugPrintExtensionPatterns() {
    if (kDebugMode) {
      print('🔍 Extension Pattern Mapper Debug:');
      for (final entry in _extensionPatterns.entries) {
        print('  📁 ${entry.key}: ${entry.value.length} patterns');
        for (final pattern in entry.value) {
          print('    - $pattern');
        }
      }
      print('  📊 Total: ${getTotalExtensionPatternCount()} patterns');
    }
  }
}
