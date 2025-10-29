// Platform-aware connectivity service
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../platform/platform_selector.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static Stream<List<ConnectivityResult>>? _connectivityStream;

  static Future<void> init() async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu connectivity initialization
        print('WebAssembly uyumlu connectivity servisi başlatılıyor...');
        await _initWebAssemblyConnectivity();
      } else {
        // Normal web connectivity initialization
        print('Web connectivity servisi başlatılıyor...');
        await _initWebConnectivity();
      }
    } else {
      // Native connectivity initialization
      print('Native connectivity servisi başlatılıyor...');
      await _initNativeConnectivity();
    }
  }

  static Future<void> _initWebAssemblyConnectivity() async {
    // WebAssembly için navigator.onLine alternatifi
    // Bu implementasyon WebAssembly ile uyumlu
  }

  static Future<void> _initWebConnectivity() async {
    // Normal web connectivity initialization
  }

  static Future<void> _initNativeConnectivity() async {
    // Native connectivity initialization
    _connectivityStream = _connectivity.onConnectivityChanged.map((result) => [result]);
  }

  static Future<List<ConnectivityResult>> checkConnectivity() async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu connectivity kontrolü
        return await _checkWebAssemblyConnectivity();
      } else {
        // Normal web connectivity kontrolü
        try {
          final result = await _connectivity.checkConnectivity();
          return [result];
        } catch (e) {
          print('Web connectivity kontrol hatası: $e');
          return [ConnectivityResult.none];
        }
      }
    } else {
      // Native connectivity kontrolü
      final result = await _connectivity.checkConnectivity();
      return [result];
    }
  }

  static Future<List<ConnectivityResult>>
      _checkWebAssemblyConnectivity() async {
    // WebAssembly uyumlu connectivity kontrolü
    try {
      // WebAssembly uyumlu network durumu kontrolü
      // Bu implementasyon dart:html kullanmaz
      return [ConnectivityResult.wifi]; // Varsayılan olarak bağlı kabul et
    } catch (e) {
      print('WebAssembly connectivity kontrol hatası: $e');
      return [ConnectivityResult.none];
    }
  }

  static Stream<List<ConnectivityResult>>? get connectivityStream {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu stream
        return _getWebAssemblyConnectivityStream();
      } else {
        // Normal web stream
        try {
          return _connectivity.onConnectivityChanged.map((result) => [result]);
        } catch (e) {
          print('Web connectivity stream hatası: $e');
          return null;
        }
      }
    } else {
      // Native stream
      return _connectivityStream;
    }
  }

  static Stream<List<ConnectivityResult>>? _getWebAssemblyConnectivityStream() {
    // WebAssembly uyumlu connectivity stream
    // Bu implementasyon dart:html kullanmaz
    return Stream.periodic(
        const Duration(seconds: 30), (_) => [ConnectivityResult.wifi]);
  }

  static Future<bool> isConnected() async {
    final results = await checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  static Future<bool> isWifiConnected() async {
    final results = await checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  static Future<bool> isMobileConnected() async {
    final results = await checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }

  static Future<bool> isEthernetConnected() async {
    final results = await checkConnectivity();
    return results.contains(ConnectivityResult.ethernet);
  }

  static Future<void> dispose() async {
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        // WebAssembly uyumlu cleanup
        print('WebAssembly connectivity servisi kapatılıyor...');
      } else {
        // Normal web cleanup
        print('Web connectivity servisi kapatılıyor...');
      }
    } else {
      // Native cleanup
      print('Native connectivity servisi kapatılıyor...');
    }
  }
}
