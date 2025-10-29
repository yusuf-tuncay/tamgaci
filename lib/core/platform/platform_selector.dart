// Platform seçici - WebAssembly uyumluluğu için
import 'package:flutter/foundation.dart';

class PlatformSelector {
  static bool get isWeb => kIsWeb;
  static bool get isWasmSupported => false; // Şimdilik basit çözüm
  
  static Future<void> initializePlatformServices() async {
    if (kIsWeb) {
      // Web servisleri başlatma
      print('Web servisleri başlatılıyor...');
    } else {
      // Mobil/desktop servisleri başlatma
      print('Native servisler başlatılıyor...');
    }
  }
  
  static Future<void> disposePlatformServices() async {
    if (kIsWeb) {
      print('Web servisleri kapatılıyor...');
    }
  }
}
