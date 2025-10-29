import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/routing/app_router.dart';
import 'package:tamgaci/core/theme/app_theme.dart';
import 'package:tamgaci/core/providers/theme_provider.dart';
import 'package:tamgaci/core/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tamgaci/l10n/generated/app_localizations.dart';

class TamgaciApp extends ConsumerWidget {
  const TamgaciApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider'ları watch et ama hata durumunda varsayılan değerler kullan
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
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
      themeMode: themeMode,

      /// Dil (provider'dan al)
      locale: locale,

      // ========== GO ROUTER AYARLARI ==========

      /// Go Router configuration
      routerConfig: AppRouter.router,

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

      /// Dil çözümleme callback'i
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },

      // ========== PERFORMANS AYARLARI ==========

      /// Scaffold messenger key
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
    );
  }
}
