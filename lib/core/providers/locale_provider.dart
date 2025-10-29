import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  static const Locale _defaultLocale = Locale('tr', 'TR');
  bool _isInitialized = false;

  LocaleNotifier() : super(_defaultLocale) {
    // Constructor'da async işlem yapma - lazy initialization kullan
    _initializeAsync();
  }

  // Async initialization - non-blocking
  void _initializeAsync() {
    Future.microtask(() async {
      if (!_isInitialized) {
        await _loadLocale();
        _isInitialized = true;
      }
    });
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null && mounted) {
        final parts = localeCode.split('_');
        if (parts.length == 2) {
          state = Locale(parts[0], parts[1]);
        } else {
          state = Locale(parts[0]);
        }
      }
    } catch (e) {
      // Varsayılan dil kullan - hata durumunda sessizce devam et
      if (mounted) {
        state = _defaultLocale;
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
