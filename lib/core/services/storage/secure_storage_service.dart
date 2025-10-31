// Platform-aware secure storage service with conditional imports
// ignore_for_file: undefined_function
import 'package:flutter/foundation.dart';
import '../../platform/platform_selector.dart';
import 'secure_storage_interface.dart';

// Conditional imports for different platforms
// Stub (default) -> Native (dart:io) -> Web (dart:html)
import 'secure_storage_stub.dart'
    if (dart.library.io) 'secure_storage_native.dart'
    if (dart.library.html) 'secure_storage_web.dart' as storage_impl;

// WebAssembly için ayrı import (dart:html kullanmaz)
import 'secure_storage_wasm.dart';

// Helper functions for conditional imports
SecureStorageInterface _createWebStorage() {
  // ignore: undefined_function
  return storage_impl.SecureStorageWeb() as SecureStorageInterface;
}

SecureStorageInterface _createNativeStorage() {
  // ignore: undefined_function
  return storage_impl.SecureStorageNative() as SecureStorageInterface;
}

/// Platform-aware secure storage service
/// WebAssembly uyumluluğu için conditional imports kullanır
class SecureStorageService {
  // Platform-specific storage implementation
  static SecureStorageInterface? _storage;

  static void _initializeStorage() {
    if (_storage != null) return;

    if (kIsWeb) {
      // Web için kontrol: WASM veya HTML renderer
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu storage (dart:html kullanmaz)
        _storage = SecureStorageWasm();
      } else {
        // HTML renderer için normal web storage
        try {
          _storage = _createWebStorage();
        } catch (e) {
          debugPrint('Web storage init hatası, WASM fallback kullanılıyor: $e');
          _storage = SecureStorageWasm();
        }
      }
    } else {
      // Native platform (Android, iOS, Desktop)
      _storage = _createNativeStorage();
    }
  }

  static Future<void> init() async {
    _initializeStorage();
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        debugPrint('WebAssembly uyumlu storage başlatılıyor...');
      } else {
        debugPrint('Web storage başlatılıyor...');
      }
    } else {
      debugPrint('Native storage başlatılıyor...');
    }
  }

  static Future<String?> read(String key) async {
    _initializeStorage();
    try {
      return await _storage?.read(key);
    } catch (e) {
      debugPrint('Storage okuma hatası: $e');
      return null;
    }
  }

  static Future<void> write(String key, String value) async {
    _initializeStorage();
    try {
      await _storage?.write(key, value);
    } catch (e) {
      debugPrint('Storage yazma hatası: $e');
    }
  }

  static Future<void> delete(String key) async {
    _initializeStorage();
    try {
      await _storage?.delete(key);
    } catch (e) {
      debugPrint('Storage silme hatası: $e');
    }
  }

  static Future<void> deleteAll() async {
    _initializeStorage();
    try {
      await _storage?.deleteAll();
    } catch (e) {
      debugPrint('Storage tümünü silme hatası: $e');
    }
  }

  static Future<Map<String, String>> readAll() async {
    _initializeStorage();
    try {
      return await _storage?.readAll() ?? {};
    } catch (e) {
      debugPrint('Storage tümünü okuma hatası: $e');
      return {};
    }
  }
}
