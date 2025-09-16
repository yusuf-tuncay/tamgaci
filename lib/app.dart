import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/routes/routes.dart';
import 'package:tamgaci/core/theme/app_theme.dart';
import 'package:tamgaci/core/providers/theme_provider.dart';
import 'package:tamgaci/features/splash/presentation/pages/splash_page.dart';
import 'package:tamgaci/shared/pages/not_found_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tamgaci/l10n/generated/app_localizations.dart';

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
      theme: AppTheme.lightTheme,

      /// Koyu tema
      darkTheme: AppTheme.darkTheme,

      /// Tema modu (provider'dan al)
      themeMode: ref.watch(themeProvider),
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
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /// Desteklenen diller
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
        Locale('ru', 'RU'),
        Locale('bg', 'BG'),
        Locale('ar', 'SA'),
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
