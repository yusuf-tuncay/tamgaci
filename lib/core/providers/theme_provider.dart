import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  bool _isInitialized = false;

  ThemeNotifier() : super(ThemeMode.system) {
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
          await _loadTheme();
        } catch (e) {
          debugPrint('Theme load error: $e');
          // Hata durumunda varsayılan tema kullan
          if (mounted) {
            state = ThemeMode.system;
          }
        } finally {
          _isInitialized = true;
        }
      }
    });
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2), onTimeout: () {
        debugPrint('SharedPreferences timeout on web');
        throw TimeoutException('SharedPreferences timeout', const Duration(seconds: 2));
      });
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length && mounted) {
        state = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      debugPrint('Theme load error: $e');
      // Varsayılan tema kullan - hata durumunda sessizce devam et
      if (mounted) {
        state = ThemeMode.system;
      }
      // Web'de hata fırlatma - sadece log
      if (!kIsWeb) {
        rethrow;
      }
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
      state = themeMode;
    } catch (e) {
      // Hata durumunda state'i güncelleme
    }
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setTheme(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setTheme(ThemeMode.system);
        break;
      case ThemeMode.system:
        setTheme(ThemeMode.light);
        break;
    }
  }

  String getThemeName() {
    switch (state) {
      case ThemeMode.light:
        return 'Açık';
      case ThemeMode.dark:
        return 'Koyu';
      case ThemeMode.system:
        return 'Sistem';
    }
  }

  IconData getThemeIcon() {
    switch (state) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
