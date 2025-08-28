import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:tamgaci/core/database/tamgaci_database.dart';
import 'package:tamgaci/features/directory/data/datasources/contact_dao.dart';
import 'package:tamgaci/features/directory/presentation/providers/contact_providers.dart';

/// Tamgaci Ön Muhasebe Uygulaması
/// Ana uygulama giriş noktası
void main() async {
  // Flutter widget binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite ayarları
  if (!kIsWeb) {
    try {
      // Android için normal SQLite, diğer platformlar için FFI
      if (Platform.isAndroid) {
        // Android için varsayılan database factory kullan
        // ignore: avoid_print
        print('Android platform detected. Using default SQLite.');
      } else {
        // Diğer platformlar için FFI kullan
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        // ignore: avoid_print
        print('Non-Android platform detected. Using SQLite FFI.');
      }
    } catch (e) {
      // ignore: avoid_print
      print('SQLite initialization failed: $e');
      // Fallback to default database factory
    }
  } else {
    // Web platformu için uyarı
    // ignore: avoid_print
    print('Web platform detected. Database functionality is limited.');
  }

  // Database'i başlat
  TamgaciDatabase? database;
  if (!kIsWeb) {
    try {
      database = await DatabaseHelper.getDatabase();
    } catch (e) {
      // ignore: avoid_print
      print('Database initialization failed: $e');
    }
  }

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
    ProviderScope(
      overrides: [
        // Contact DAO provider override
        if (database != null)
          contactDaoProvider.overrideWith((ref) => database!.contactDao),
      ],
      child: const TamgaciApp(),
    ),
  );
}
