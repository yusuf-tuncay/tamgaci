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
  // Flutter widget binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Global error yakalama - release'ta da konsola yazsın
  FlutterError.onError = (FlutterErrorDetails details) {
    // ignore: avoid_print
    debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}');
    // ignore: avoid_print
    if (details.stack != null) {
      print(details.stack);
    }
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

  // Uygulamayı Zone içinde başlat - tüm senkron/async hataları yakala
  await runZonedGuarded<Future<void>>(() async {
    runApp(
      const ProviderScope(
        child: TamgaciApp(),
      ),
    );
  }, (Object error, StackTrace stack) {
    // ignore: avoid_print
    print('UNCAUGHT: $error');
    // ignore: avoid_print
    print(stack);
  });
}
