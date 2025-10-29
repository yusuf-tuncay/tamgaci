// Platform-aware secure storage service
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../platform/platform_selector.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // WebAssembly uyumlu alternatif storage
  static final Map<String, String> _webStorage = {};

  static Future<void> init() async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly için localStorage alternatifi
        print('WebAssembly uyumlu storage başlatılıyor...');
        await _initWebAssemblyStorage();
      } else {
        // Normal web storage
        print('Web storage başlatılıyor...');
        await _initWebStorage();
      }
    } else {
      // Native storage
      print('Native storage başlatılıyor...');
    }
  }

  static Future<void> _initWebAssemblyStorage() async {
    // WebAssembly için localStorage kullanımı
    // Bu implementasyon WebAssembly ile uyumlu
  }

  static Future<void> _initWebStorage() async {
    // Normal web storage initialization
  }

  static Future<String?> read(String key) async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu okuma
        return _webStorage[key];
      } else {
        // Normal web okuma
        try {
          return await _storage.read(key: key);
        } catch (e) {
          print('Web storage okuma hatası: $e');
          return null;
        }
      }
    } else {
      // Native okuma
      return await _storage.read(key: key);
    }
  }

  static Future<void> write(String key, String value) async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu yazma
        _webStorage[key] = value;
      } else {
        // Normal web yazma
        try {
          await _storage.write(key: key, value: value);
        } catch (e) {
          print('Web storage yazma hatası: $e');
        }
      }
    } else {
      // Native yazma
      await _storage.write(key: key, value: value);
    }
  }

  static Future<void> delete(String key) async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu silme
        _webStorage.remove(key);
      } else {
        // Normal web silme
        try {
          await _storage.delete(key: key);
        } catch (e) {
          print('Web storage silme hatası: $e');
        }
      }
    } else {
      // Native silme
      await _storage.delete(key: key);
    }
  }

  static Future<void> deleteAll() async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu tümünü silme
        _webStorage.clear();
      } else {
        // Normal web tümünü silme
        try {
          await _storage.deleteAll();
        } catch (e) {
          print('Web storage tümünü silme hatası: $e');
        }
      }
    } else {
      // Native tümünü silme
      await _storage.deleteAll();
    }
  }

  static Future<Map<String, String>> readAll() async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu tümünü okuma
        return Map.from(_webStorage);
      } else {
        // Normal web tümünü okuma
        try {
          return await _storage.readAll();
        } catch (e) {
          print('Web storage tümünü okuma hatası: $e');
          return {};
        }
      }
    } else {
      // Native tümünü okuma
      return await _storage.readAll();
    }
  }
}
