import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tamgaci/core/database/tamgaci_database.dart';
import 'package:tamgaci/core/services/notification_service.dart';
import 'package:tamgaci/core/services/firebase_data_service.dart';
import 'package:tamgaci/core/services/firebase_notification_service.dart';
import 'package:tamgaci/core/utils/logger.dart';

// Platform-specific imports
import 'dart:io' if (dart.library.io) 'dart:io';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Tamgaci Ön Muhasebe Uygulaması
/// Ana uygulama giriş noktası
void main() async {
  // Flutter widget binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully');

    // Web platformunda mock veri ekle
    if (kIsWeb) {
      await FirebaseDataService.addAllMockData();
    }
  } catch (e) {
    AppLogger.error('Firebase initialization failed', e);
  }

  // SQLite ayarları
  if (!kIsWeb) {
    try {
      // Android için normal SQLite, diğer platformlar için FFI
      try {
        // dart:io import'u sadece io platformlarında mevcut
        final isAndroid = Platform.isAndroid;
        if (isAndroid) {
          // Android için varsayılan database factory kullan
          AppLogger.info('Android platform detected. Using default SQLite.');
        } else {
          // Diğer platformlar için FFI kullan
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          AppLogger.info('Non-Android platform detected. Using SQLite FFI.');
        }
      } catch (e) {
        // Web platformunda Platform sınıfı mevcut değil
        AppLogger.info('Platform detection failed, using default SQLite.');
      }
    } catch (e) {
      AppLogger.error('SQLite initialization failed', e);
      // Fallback to default database factory
    }
  } else {
    // Web platformu için uyarı
    AppLogger.warning(
        'Web platform detected. Database functionality is limited.');
  }

  // Database'i başlat
  if (!kIsWeb) {
    try {
      await DatabaseHelper.getDatabase();
    } catch (e) {
      AppLogger.error('Database initialization failed', e);
    }
  }

  // Notification service'i başlat
  await NotificationService().initialize();

  // Firebase Notification service'i başlat
  await FirebaseNotificationService.initialize();

  // Test verilerini yükle (database başlatıldıktan sonra)
  // Bu işlem uygulama başladıktan sonra yapılacak

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
