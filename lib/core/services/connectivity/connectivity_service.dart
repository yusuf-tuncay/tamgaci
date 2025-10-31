// Platform-aware connectivity service with conditional imports
// ignore_for_file: undefined_function
import 'package:flutter/foundation.dart';
import '../../platform/platform_selector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'connectivity_interface.dart';

// Conditional imports
import 'connectivity_stub.dart'
    if (dart.library.io) 'connectivity_native.dart'
    if (dart.library.html) 'connectivity_web.dart' as connectivity_impl;

// WebAssembly için ayrı import
import 'connectivity_wasm.dart';

class ConnectivityService {
  static ConnectivityInterface? _connectivity;
  static Stream<List<ConnectivityResult>>? _connectivityStream;

  static void _initializeConnectivity() {
    if (_connectivity != null) return;

    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        _connectivity = ConnectivityWasm();
      } else {
        try {
          _connectivity =
              connectivity_impl.ConnectivityWeb() as ConnectivityInterface;
        } catch (e) {
          debugPrint(
              'Web connectivity init hatası, WASM fallback kullanılıyor: $e');
          _connectivity = ConnectivityWasm();
        }
      }
    } else {
      _connectivity =
          connectivity_impl.ConnectivityNative() as ConnectivityInterface;
    }
  }

  static Future<void> init() async {
    _initializeConnectivity();
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        debugPrint('WebAssembly uyumlu connectivity servisi başlatılıyor...');
      } else {
        debugPrint('Web connectivity servisi başlatılıyor...');
      }
    } else {
      debugPrint('Native connectivity servisi başlatılıyor...');
      if (_connectivity != null) {
        _connectivityStream =
            _connectivity!.onConnectivityChanged.map((result) => [result]);
      }
    }
  }

  static Future<List<ConnectivityResult>> checkConnectivity() async {
    _initializeConnectivity();
    try {
      final result = await _connectivity?.checkConnectivity();
      return result != null ? [result] : [ConnectivityResult.none];
    } catch (e) {
      debugPrint('Connectivity kontrol hatası: $e');
      return [ConnectivityResult.none];
    }
  }

  static Stream<List<ConnectivityResult>>? get connectivityStream {
    _initializeConnectivity();
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        return _connectivity?.onConnectivityChanged.map((result) => [result]);
      } else {
        try {
          return _connectivity?.onConnectivityChanged.map((result) => [result]);
        } catch (e) {
          debugPrint('Web connectivity stream hatası: $e');
          return null;
        }
      }
    } else {
      return _connectivityStream;
    }
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
        debugPrint('WebAssembly connectivity servisi kapatılıyor...');
      } else {
        debugPrint('Web connectivity servisi kapatılıyor...');
      }
    } else {
      debugPrint('Native connectivity servisi kapatılıyor...');
      _connectivityStream = null;
    }
  }
}
