import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tamgaci/core/services/utils/notification_service.dart';
// import 'package:tamgaci/core/services/firebase/firebase_data_service.dart'; // Removed - not needed
import 'package:tamgaci/core/services/firebase/firebase_notification_service.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/core/errors/global_error_handler.dart';
import 'dart:ui' show PlatformDispatcher;

// Platform-specific imports - Removed - not needed
// import 'dart:io' if (dart.library.io) 'dart:io';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Tamgaci Ön Muhasebe Uygulaması
/// Ana uygulama giriş noktası
void main() async {
  // Flutter widget binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Web için özel disposed view hata bastırma
  if (kIsWeb) {
    _suppressDisposedViewErrors();
    _suppressAllDisposedErrors();
  }

  // Global error handler'ı başlat
  GlobalErrorHandler().initialize();

  // Firebase'i başlat
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully');
  } catch (e) {
    AppLogger.error('Firebase initialization failed', e);
  }

  // Firebase-only approach - SQLite removed
  AppLogger.info('Using Firebase-only data storage');

  // Notification service'i başlat
  await NotificationService().initialize();

  // Firebase Notification service'i başlat
  await FirebaseNotificationService.initialize();

  // Tenant setup artık login sonrası yapılıyor

  // Mock data removed - using real Firebase data only

  // Sistem UI ayarları (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Desteklenen yönelimler (portrait mode only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Uygulamayı Riverpod Provider scope ile başlat
  runApp(
    const ProviderScope(
      child: TamgaciApp(),
    ),
  );
}

/// Web için disposed view hatalarını bastır
void _suppressDisposedViewErrors() {
  // Flutter Web'de disposed view hatalarını tamamen bastır
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.exceptionAsString();

    // Disposed view hatalarını tamamen bastır
    if (errorString.contains('isDisposed') ||
        errorString.contains('disposed EngineFlutterView') ||
        errorString.contains('Trying to render a disposed') ||
        errorString.contains(
            'Assertion failed: org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
        errorString.contains(
            'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12')) {
      // Bu hataları tamamen sessizce geç
      return;
    }

    // Diğer hataları normal şekilde işle
    FlutterError.presentError(details);
  };

  // Ek olarak PlatformDispatcher seviyesinde de bastır
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorString = error.toString();

    if (errorString.contains('isDisposed') ||
        errorString.contains('disposed EngineFlutterView') ||
        errorString.contains('Trying to render a disposed') ||
        errorString.contains(
            'Assertion failed: org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
        errorString.contains(
            'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12')) {
      // Bu hataları tamamen sessizce geç
      return true;
    }

    // Diğer hataları normal şekilde işle
    return false;
  };
}

/// Tüm disposed hatalarını bastır (çok agresif yaklaşım)
void _suppressAllDisposedErrors() {
  // Flutter Web'de disposed hatalarını tamamen bastır
  if (kIsWeb) {
    // Tüm Flutter error'larını yakala ve disposed olanları bastır
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.exceptionAsString();

      // Disposed hatalarını tamamen bastır
      if (errorString.contains('disposed') ||
          errorString.contains('isDisposed') ||
          errorString.contains('EngineFlutterView') ||
          errorString.contains('window.dart:99:12') ||
          errorString.contains(
              'Assertion failed: org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12')) {
        // Bu hataları tamamen sessizce geç
        return;
      }

      // Diğer hataları normal şekilde işle
      FlutterError.presentError(details);
    };

    // Ek olarak tüm console.error'ları da bastır
    try {
      // ignore: avoid_web_libraries_in_flutter
      // import 'dart:html' as html;
      // html.window.console.clear();
    } catch (e) {
      // Ignore
    }
  }
}
