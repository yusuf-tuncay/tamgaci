// Platform-aware share service with conditional imports
// ignore_for_file: undefined_function
import 'package:flutter/foundation.dart';
import '../../platform/platform_selector.dart';
import 'package:share_plus/share_plus.dart' show XFile;
import 'share_interface.dart';

// Conditional imports
import 'share_stub.dart'
    if (dart.library.io) 'share_native.dart'
    if (dart.library.html) 'share_web.dart' as share_impl;

// WebAssembly için ayrı import
import 'share_wasm.dart';

class ShareService {
  static ShareInterface? _shareImpl;

  static void _initializeShare() {
    if (_shareImpl != null) return;

    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        _shareImpl = ShareWasm();
      } else {
        try {
          // Conditional import'dan gelen class'ı kullan
          _shareImpl = share_impl.ShareWeb() as ShareInterface;
        } catch (e) {
          debugPrint('Web share init hatası, WASM fallback kullanılıyor: $e');
          _shareImpl = ShareWasm();
        }
      }
    } else {
      // Native için conditional import'dan gelen class'ı kullan
      _shareImpl = share_impl.ShareNative() as ShareInterface;
    }
  }

  static Future<void> init() async {
    _initializeShare();
    if (kIsWeb) {
      if (PlatformSelector.isWasmSupported) {
        debugPrint('WebAssembly uyumlu share servisi başlatılıyor...');
      } else {
        debugPrint('Web share servisi başlatılıyor...');
      }
    } else {
      debugPrint('Native share servisi başlatılıyor...');
    }
  }

  static Future<void> shareText(String text) async {
    _initializeShare();
    try {
      await _shareImpl?.share(text);
    } catch (e) {
      debugPrint('Share hatası: $e');
    }
  }

  static Future<void> shareFile(String filePath, {String? text}) async {
    _initializeShare();
    try {
      if (kIsWeb && PlatformSelector.isWasmSupported) {
        await _shareImpl?.shareXFiles([filePath], text: text);
      } else {
        // Web veya Native için XFile'a dönüştür
        final xFile = XFile(filePath);
        await _shareImpl?.shareXFiles([xFile], text: text);
      }
    } catch (e) {
      debugPrint('File share hatası: $e');
    }
  }
}
