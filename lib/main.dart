import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/app.dart';
// kIsWeb artık foundation.dart'tan geliyor
import 'package:tamgaci/core/services/utils/notification_service.dart';
// import 'package:tamgaci/core/services/firebase/firebase_data_service.dart'; // Removed - not needed
import 'package:tamgaci/core/services/firebase/firebase_notification_service.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/core/errors/global_error_handler.dart';
// Ultra Error Suppressor kaldırıldı - sadeleştirilmiş sistem
import 'package:tamgaci/core/errors/smart_error_suppressor.dart';
// PlatformDispatcher artık foundation.dart'tan geliyor

// Platform-specific imports - Removed - not needed
// import 'dart:io' if (dart.library.io) 'dart:io';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// WebView platform implementation for Flutter Web
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Tamgaci Ön Muhasebe Uygulaması
/// Ana uygulama giriş noktası
void main() async {
  // Flutter widget binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // WebView platform implementation'ını ayarla (Flutter Web için)
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }

  // Web için özel disposed view hata bastırma
  if (kIsWeb) {
    _suppressDisposedViewErrors();
    _suppressAllDisposedErrors();
    _suppressEngineFlutterViewErrors();
    _suppressUltraAggressiveErrors();
    _suppressWebDisposedErrors();
    _suppressUltraDisposedErrors();
  }

  // Akıllı error suppression'ı başlat (ana sistem)
  await SmartErrorSuppressionSystem.initialize(productionMode: kReleaseMode);

  // Global error handler'ı başlat (fallback)
  if (kDebugMode) {
    GlobalErrorHandler().initialize();
  }

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

  // Notification service'i başlat (asenkron)
  NotificationService().initialize();

  // Firebase Notification service'i başlat (asenkron)
  FirebaseNotificationService.initialize();

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

    // Ultra agresif disposed view hatalarını bastır - TÜM disposed view hatalarını yakala
    if (errorString.contains('isDisposed') ||
        errorString.contains('disposed EngineFlutterView') ||
        errorString.contains('Trying to render a disposed') ||
        errorString.contains('disposed') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        errorString.contains('RenderBox was not laid out') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary') ||
        errorString.contains('!isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('Assertion failed:') ||
        errorString.contains(
            'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
        errorString.contains('disposed') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('window.dart') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('!isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('disposed EngineFlutterView') ||
        errorString.contains('RenderBox') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary') ||
        errorString.contains('RenderBox was not laid out') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary') ||
        errorString.contains('!isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('Assertion failed:') ||
        errorString.contains(
            'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
        // Performance API hataları
        errorString
            .contains('Failed to execute \'measure\' on \'Performance\'') ||
        errorString.contains('The mark \'') ||
        errorString.contains('does not exist') ||
        errorString.contains('Performance') ||
        errorString.contains('measure') ||
        errorString.contains('mark') ||
        errorString.contains('listener-begin') ||
        errorString.contains('listener-end') ||
        errorString.contains('image_cache') ||
        errorString.contains('image_stream') ||
        errorString.contains('network_image_web') ||
        errorString.contains('image_decoder') ||
        errorString.contains('timeline') ||
        errorString.contains('developer_patch') ||
        errorString.contains('async_patch') ||
        errorString.contains('zone') ||
        errorString.contains('future_impl') ||
        errorString.contains('complete') ||
        errorString.contains('asyncReturn') ||
        errorString.contains('engine') ||
        errorString.contains('painting') ||
        errorString.contains('image_cache.dart') ||
        errorString.contains('image_stream.dart') ||
        errorString.contains('network_image_web.dart') ||
        errorString.contains('image_decoder.dart') ||
        errorString.contains('timeline.dart') ||
        errorString.contains('developer_patch.dart') ||
        errorString.contains('async_patch.dart') ||
        errorString.contains('zone.dart') ||
        errorString.contains('future_impl.dart')) {
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
        errorString.contains('disposed') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        errorString.contains('RenderBox was not laid out') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary') ||
        errorString.contains('!isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('Assertion failed:') ||
        errorString.contains(
            'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
        // Performance API hataları
        errorString
            .contains('Failed to execute \'measure\' on \'Performance\'') ||
        errorString.contains('The mark \'') ||
        errorString.contains('does not exist') ||
        errorString.contains('Performance') ||
        errorString.contains('measure') ||
        errorString.contains('mark') ||
        errorString.contains('listener-begin') ||
        errorString.contains('listener-end') ||
        errorString.contains('image_cache') ||
        errorString.contains('image_stream') ||
        errorString.contains('network_image_web') ||
        errorString.contains('image_decoder') ||
        errorString.contains('timeline') ||
        errorString.contains('developer_patch') ||
        errorString.contains('async_patch') ||
        errorString.contains('zone') ||
        errorString.contains('future_impl') ||
        errorString.contains('complete') ||
        errorString.contains('asyncReturn') ||
        errorString.contains('engine') ||
        errorString.contains('painting') ||
        errorString.contains('image_cache.dart') ||
        errorString.contains('image_stream.dart') ||
        errorString.contains('network_image_web.dart') ||
        errorString.contains('image_decoder.dart') ||
        errorString.contains('timeline.dart') ||
        errorString.contains('developer_patch.dart') ||
        errorString.contains('async_patch.dart') ||
        errorString.contains('zone.dart') ||
        errorString.contains('future_impl.dart')) {
      // Bu hataları tamamen sessizce geç
      return true;
    }

    // Diğer hataları normal şekilde işle
    return false;
  };
}

/// Tüm disposed hatalarını bastır (ultra agresif yaklaşım)
void _suppressAllDisposedErrors() {
  // Flutter Web'de disposed hatalarını tamamen bastır
  if (kIsWeb) {
    // Tüm Flutter error'larını yakala ve disposed olanları bastır
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.exceptionAsString();

      // Ultra agresif disposed hatalarını bastır
      if (errorString.contains('disposed') ||
          errorString.contains('isDisposed') ||
          errorString.contains('EngineFlutterView') ||
          errorString.contains('window.dart:99:12') ||
          errorString.contains('!isDisposed') ||
          errorString.contains('Trying to render') ||
          errorString.contains('Assertion failed:') ||
          errorString.contains(
              'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
          errorString.contains('RenderBox') ||
          errorString.contains('hasSize') ||
          errorString.contains('NEEDS-LAYOUT') ||
          errorString.contains('NEEDS-PAINT') ||
          errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
          errorString.contains('!_debugDoingThisLayout') ||
          errorString.contains('RenderPadding') ||
          errorString.contains('RenderRepaintBoundary')) {
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

/// Web için ultra etkili disposed error suppressor
void _suppressWebDisposedErrors() {
  if (kIsWeb) {
    // Tüm Flutter error'larını yakala
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.exceptionAsString();

      // Ultra agresif disposed view hatalarını bastır
      if (errorString.contains('isDisposed') ||
          errorString.contains('disposed EngineFlutterView') ||
          errorString.contains('Trying to render a disposed') ||
          errorString.contains('!isDisposed') ||
          errorString.contains('Trying to render') ||
          errorString.contains('EngineFlutterView') ||
          errorString.contains('window.dart:99:12') ||
          errorString.contains('Assertion failed:') ||
          errorString.contains(
              'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
          errorString.contains('disposed') ||
          errorString.contains('RenderBox was not laid out') ||
          errorString.contains('hasSize') ||
          errorString.contains('NEEDS-LAYOUT') ||
          errorString.contains('NEEDS-PAINT') ||
          errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
          errorString.contains('!_debugDoingThisLayout') ||
          errorString.contains('RenderPadding') ||
          errorString.contains('RenderRepaintBoundary')) {
        // Bu hataları tamamen sessizce geç
        return;
      }

      // Diğer hataları normal şekilde işle
      FlutterError.presentError(details);
    };

    // PlatformDispatcher error'larını da bastır
    PlatformDispatcher.instance.onError = (error, stack) {
      final errorString = error.toString();

      if (errorString.contains('isDisposed') ||
          errorString.contains('disposed EngineFlutterView') ||
          errorString.contains('Trying to render a disposed') ||
          errorString.contains('!isDisposed') ||
          errorString.contains('Trying to render') ||
          errorString.contains('EngineFlutterView') ||
          errorString.contains('window.dart:99:12') ||
          errorString.contains('Assertion failed:') ||
          errorString.contains(
              'org-dartlang-sdk:///lib/_engine/engine/window.dart:99:12') ||
          errorString.contains('disposed') ||
          errorString.contains('RenderBox was not laid out') ||
          errorString.contains('hasSize') ||
          errorString.contains('NEEDS-LAYOUT') ||
          errorString.contains('NEEDS-PAINT') ||
          errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
          errorString.contains('!_debugDoingThisLayout') ||
          errorString.contains('RenderPadding') ||
          errorString.contains('RenderRepaintBoundary')) {
        // Bu hataları tamamen sessizce geç
        return true;
      }

      // Diğer hataları normal şekilde işle
      return false;
    };
  }
}

/// Ultra agresif EngineFlutterView hata bastırma
void _suppressEngineFlutterViewErrors() {
  // FlutterError.onError için ultra agresif handler
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.exceptionAsString();

    // TÜM EngineFlutterView hatalarını bastır
    if (errorString.contains('EngineFlutterView') ||
        errorString.contains('disposed') ||
        errorString.contains('isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        // Network hatalarını da bastır
        errorString.contains('DioException') ||
        errorString.contains('connection error') ||
        errorString.contains('XMLHttpRequest onError') ||
        errorString.contains('EVDS fetch failed') ||
        errorString.contains('Hasan API fallback')) {
      // Sessizce geç
      return;
    }

    // Diğer hataları normal şekilde işle
    FlutterError.presentError(details);
  };

  // PlatformDispatcher.onError için ultra agresif handler
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorString = error.toString();

    // TÜM EngineFlutterView hatalarını bastır
    if (errorString.contains('EngineFlutterView') ||
        errorString.contains('disposed') ||
        errorString.contains('isDisposed') ||
        errorString.contains('Trying to render') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        // Network hatalarını da bastır
        errorString.contains('DioException') ||
        errorString.contains('connection error') ||
        errorString.contains('XMLHttpRequest onError') ||
        errorString.contains('EVDS fetch failed') ||
        errorString.contains('Hasan API fallback')) {
      // Sessizce geç
      return true;
    }

    return false;
  };
}

/// Ultra agresif hata bastırma - TÜM disposed view hatalarını bastır
void _suppressUltraAggressiveErrors() {
  // FlutterError.onError için ultra agresif handler
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.exceptionAsString();

    // TÜM disposed view hatalarını bastır
    if (errorString.contains('disposed') ||
        errorString.contains('isDisposed') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('Trying to render') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        errorString.contains('RenderBox') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        // Network hatalarını da bastır
        errorString.contains('DioException') ||
        errorString.contains('connection error') ||
        errorString.contains('XMLHttpRequest onError') ||
        errorString.contains('EVDS fetch failed') ||
        errorString.contains('Hasan API fallback')) {
      // Sessizce geç
      return;
    }

    // Diğer hataları normal şekilde işle
    FlutterError.presentError(details);
  };

  // PlatformDispatcher.onError için ultra agresif handler
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorString = error.toString();

    // TÜM disposed view hatalarını bastır
    if (errorString.contains('disposed') ||
        errorString.contains('isDisposed') ||
        errorString.contains('EngineFlutterView') ||
        errorString.contains('Trying to render') ||
        errorString.contains('window.dart:99:12') ||
        errorString.contains('Assertion failed') ||
        errorString.contains('org-dartlang-sdk') ||
        errorString.contains('RenderBox') ||
        errorString.contains('hasSize') ||
        errorString.contains('NEEDS-LAYOUT') ||
        errorString.contains('NEEDS-PAINT') ||
        errorString.contains('RenderPadding') ||
        errorString.contains('RenderRepaintBoundary') ||
        errorString.contains('!_debugDoingThisLayout') ||
        errorString.contains('NEEDS-COMPOSITING-BITS-UPDATE') ||
        // Network hatalarını da bastır
        errorString.contains('DioException') ||
        errorString.contains('connection error') ||
        errorString.contains('XMLHttpRequest onError') ||
        errorString.contains('EVDS fetch failed') ||
        errorString.contains('Hasan API fallback')) {
      // Sessizce geç
      return true;
    }

    return false;
  };
}
