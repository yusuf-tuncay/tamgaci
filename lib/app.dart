import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/routes/routes.dart';
import 'package:tamgaci/core/theme/theme.dart';
import 'package:tamgaci/features/splash/presentation/pages/splash_page.dart';
import 'package:tamgaci/shared/pages/not_found_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tamgaci/core/database/tamgaci_database.dart';
import 'package:tamgaci/features/directory/data/datasources/contact_dao.dart';
import 'package:tamgaci/features/directory/presentation/providers/contact_providers.dart';

class TamgaciApp extends ConsumerWidget {
  const TamgaciApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // ========== UYGULAMA AYARLARI ==========

      /// Uygulama başlığı
      title: 'Tamgaci',

      /// Debug banner'ını kaldır
      debugShowCheckedModeBanner: false,

      // ========== TEMA AYARLARI ==========

      /// Açık tema
      theme: TamgaciTheme.getLightTheme(),

      /// Koyu tema (gelecek kullanım için)
      darkTheme: TamgaciTheme.getDarkTheme(),

      /// Tema modu (sistem ayarını takip et)
      themeMode: ThemeMode.light, // Şimdilik sadece açık tema
      // ========== NAVİGASYON AYARLARI ==========

      /// İlk açılacak sayfa
      home: const SplashPage(),

      /// Route generator
      onGenerateRoute: TamgaciRoutes.generateRoute,

      /// Bilinmeyen route handler
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (context) => const NotFoundPage()),

      /// İlk route
      initialRoute: TamgaciRoutes.splash,

      // ========== LOKALİZASYON AYARLARI ==========
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /// Desteklenen diller
      supportedLocales: const [
        Locale('tr', 'TR'), // Türkçe
        Locale('en', 'US'), // İngilizce (gelecek için)
      ],

      /// Varsayılan dil
      locale: const Locale('tr', 'TR'),

      // ========== PERFORMANS AYARLARI ==========

      /// Scaffold messenger key
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),

      /// Navigator key
      navigatorKey: GlobalKey<NavigatorState>(),
    );
  }
}
