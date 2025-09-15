// ========== SETTINGS PROVIDERS ==========
// lib/features/settings/presentation/providers/settings_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/datasources/settings_firebase_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Settings repository provider
final settingsRepositoryProvider = Provider<SettingsRepositoryImpl>((ref) {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final ds = SettingsFirebaseDataSource(firestore, auth);
  return SettingsRepositoryImpl(dataSource: ds);
});

/// Settings state notifier
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsRepositoryImpl _repository;
  static const String _defaultUserId = 'default_user';

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  /// Ayarları yükle
  Future<void> _loadSettings() async {
    try {
      state = const AsyncValue.loading();
      final settings = await _repository.getAppSettings(_defaultUserId);
      if (settings != null) {
        state = AsyncValue.data(settings);
      } else {
        // Create default settings if missing
        final newSettings = AppSettings(
          id: _defaultUserId,
          userId: _defaultUserId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final created = await _repository.createAppSettings(newSettings);
        state = AsyncValue.data(created);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Tema ayarlarını güncelle
  Future<void> updateThemeSettings(ThemeMode theme) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      final updatedSettings = await _repository.updateThemeMode(
        currentSettings.userId,
        theme,
      );
      state = AsyncValue.data(updatedSettings.copyWith(
        updatedAt: DateTime.now(),
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings(bool enabled) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      final updated = await _repository.updateNotificationSettings(
          currentSettings.userId, enabled);
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Genel ayarları güncelle
  Future<void> updateLanguage(Language language) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      final updated =
          await _repository.updateLanguage(currentSettings.userId, language);
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Güvenlik ayarlarını güncelle
  Future<void> updateBiometric(bool enabled) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      final updated = await _repository.updateBiometricSettings(
          currentSettings.userId, enabled);
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Veri ayarlarını güncelle
  Future<void> updateBackup(
      {required bool enableDataBackup,
      required bool enableAutoBackup,
      required int frequency}) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      final updated = await _repository.updateBackupSettings(
        currentSettings.userId,
        enableDataBackup,
        enableAutoBackup,
        frequency,
      );
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Ayarları sıfırla
  Future<void> resetSettings() async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;
      await _repository.deleteAppSettings(currentSettings.userId);
      await _loadSettings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Ayarları yenile
  Future<void> refreshSettings() async {
    await _loadSettings();
  }
}

/// Settings provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

/// Tema ayarları provider
final themeSettingsProvider = Provider<ThemeMode>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});

/// Bildirim ayarları provider
final notificationSettingsProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.enableNotifications,
    loading: () => true,
    error: (_, __) => true,
  );
});

/// Genel ayarlar provider
final generalSettingsProvider = Provider<Language>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.language,
    loading: () => Language.tr,
    error: (_, __) => Language.tr,
  );
});

/// Güvenlik ayarları provider
final securitySettingsProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.enableBiometric,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Veri ayarları provider
final dataSettingsProvider = Provider<int>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.backupFrequency,
    loading: () => 7,
    error: (_, __) => 7,
  );
});

/// Karanlık tema provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeSettings = ref.watch(themeSettingsProvider);
  return themeSettings == ThemeMode.dark;
});

/// Bildirimler aktif provider
final notificationsEnabledProvider = Provider<bool>((ref) {
  final notificationSettings = ref.watch(notificationSettingsProvider);
  return notificationSettings;
});

/// Dil provider
final languageProvider = Provider<String>((ref) {
  final lang = ref.watch(generalSettingsProvider);
  return lang.name;
});

/// Para birimi provider
final currencyProvider = Provider<String>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (s) => s.currency.name,
    loading: () => 'tl',
    error: (_, __) => 'tl',
  );
});
