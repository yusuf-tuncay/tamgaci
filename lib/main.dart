import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/app.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'dart:async';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// WebView platform implementation (conditional)
import 'package:tamgaci/shared/platform/webview_platform.dart';

// Platform-aware services for WebAssembly compatibility
import 'package:tamgaci/core/platform/platform_selector.dart';

/// Tamgaci Ön Muhasebe Uygulaması
/// Ana uygulama giriş noktası
void main() async {
  // Uygulamayı Zone içinde başlat - tüm senkron/async hataları yakala
  await runZonedGuarded<Future<void>>(() async {
    // Flutter widget binding'lerini başlat (Zone içinde)
  WidgetsFlutterBinding.ensureInitialized();

  // Global error yakalama - release'ta da konsola yazsın
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.exceptionAsString();
    
    // Disposed view hatalarını filtrele - bunlar zararsızdır ve sessizce geçilebilir
    if (errorString.contains('isDisposed') ||
        errorString.contains('disposed EngineFlutterView') ||
        errorString.contains('Trying to render a disposed') ||
        errorString.contains('!isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('window.dart:99:12') ||
        (errorString.contains('Assertion failed') && 
         errorString.contains('org-dartlang-sdk:///lib/_engine/engine/window.dart'))) {
      // Disposed view hatalarını sessizce geç
      return;
    }
    
    debugPrint('FLUTTER_ERROR: $errorString');
    AppLogger.error(
      'Flutter Error: $errorString',
      details.exception,
      details.stack,
    );
  };

  // WebView platform implementation'ını ayarla (yalnız web)
  const WebViewPlatformConfigurer().configure();

  // Platform-aware servisleri başlat (WebAssembly uyumluluğu için)
  await PlatformSelector.initializePlatformServices();

  // Firebase'i başlat
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully');
  } catch (e) {
    AppLogger.error('Firebase initialization failed', e);
  }

  AppLogger.info('Using Firebase-only data storage');

  // Web engine hazır senkronizasyonu için kısa bekleme
  await Future<void>.delayed(const Duration(milliseconds: 120));

    // Uygulamayı başlat
    runApp(
      const ProviderScope(
        child: TamgaciApp(),
      ),
    );
  }, (Object error, StackTrace stack) {
    AppLogger.error('Uncaught exception', error, stack);
  });
}
