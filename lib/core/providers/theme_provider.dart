import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  bool _isInitialized = false;

  ThemeNotifier() : super(ThemeMode.system) {
    // Constructor'da async işlem yapma - lazy initialization kullan
    _initializeAsync();
  }

  // Async initialization - non-blocking
  void _initializeAsync() {
    Future.microtask(() async {
      if (!_isInitialized) {
        await _loadTheme();
        _isInitialized = true;
      }
    });
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      if (mounted) {
        state = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      // Varsayılan tema kullan - hata logla ama state'i varsayılanda bırak
      if (mounted) {
        state = ThemeMode.system;
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
