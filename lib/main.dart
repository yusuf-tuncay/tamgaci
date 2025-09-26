import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/app.dart';
// import 'package:flutter/foundation.dart' show kIsWeb; // Removed - not needed
import 'package:tamgaci/core/services/utils/notification_service.dart';
// import 'package:tamgaci/core/services/firebase/firebase_data_service.dart'; // Removed - not needed
import 'package:tamgaci/core/services/firebase/firebase_notification_service.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/core/errors/global_error_handler.dart';

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
