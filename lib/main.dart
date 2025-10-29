import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/app.dart';
import 'package:tamgaci/core/utils/logger.dart';

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

  // Uygulamayı Riverpod Provider scope ile başlat
  runApp(
    const ProviderScope(
      child: TamgaciApp(),
    ),
  );
}
