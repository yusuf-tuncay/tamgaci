import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  static const Locale _defaultLocale = Locale('tr', 'TR');
  bool _isInitialized = false;

  LocaleNotifier() : super(_defaultLocale) {
    // Web'de SharedPreferences initialization'ı gecikmeli yap
    // Constructor'da async işlem yapma - lazy initialization kullan
    if (kIsWeb) {
      // Web için biraz daha gecikmeli başlat (DOM hazır olana kadar bekle)
      Future.delayed(const Duration(milliseconds: 100), () {
        _initializeAsync();
      });
    } else {
      _initializeAsync();
    }
  }

  // Async initialization - non-blocking
  void _initializeAsync() {
    Future.microtask(() async {
      if (!_isInitialized && mounted) {
        try {
          await _loadLocale();
        } catch (e) {
          debugPrint('Locale load error: $e');
          // Hata durumunda varsayılan locale kullan
          if (mounted) {
            state = _defaultLocale;
          }
        } finally {
          _isInitialized = true;
        }
      }
    });
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2), onTimeout: () {
        debugPrint('SharedPreferences timeout on web');
        throw TimeoutException('SharedPreferences timeout', const Duration(seconds: 2));
      });
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null && localeCode.isNotEmpty && mounted) {
        final parts = localeCode.split('_');
        if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
          state = Locale(parts[0], parts[1]);
        } else if (parts.length >= 1 && parts[0].isNotEmpty) {
          state = Locale(parts[0]);
        }
      }
    } catch (e) {
      debugPrint('Locale load error: $e');
      // Varsayılan dil kullan - hata durumunda sessizce devam et
      if (mounted) {
        state = _defaultLocale;
      }
      // Web'de hata fırlatma - sadece log
      if (!kIsWeb) {
        rethrow;
      }
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _localeKey, '${locale.languageCode}_${locale.countryCode}');
      state = locale;
    } catch (e) {
      // Hata durumunda state'i güncelleme
    }
  }

  List<Locale> get supportedLocales => [
        const Locale('tr', 'TR'),
        const Locale('en', 'US'),
        const Locale('ru', 'RU'),
        const Locale('bg', 'BG'),
        const Locale('ar', 'SA'),
      ];

  String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'bg':
        return 'Български';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode;
    }
  }

  String getLocaleFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      case 'bg':
        return '🇧🇬';
      case 'ar':
        return '🇸🇦';
      default:
        return '🌐';
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
