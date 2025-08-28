// ========== SETTINGS PROVIDERS ==========
// lib/features/settings/presentation/providers/settings_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import '../../data/repositories/settings_repository_impl.dart';

/// Settings repository provider
final settingsRepositoryProvider = Provider<SettingsRepositoryImpl>((ref) {
  return SettingsRepositoryImpl();
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
      final settings = await _repository.getSettings(_defaultUserId);
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Tema ayarlarını güncelle
  Future<void> updateThemeSettings(ThemeSettings theme) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      await _repository.updateThemeSettings(currentSettings.userId, theme);
      final updatedSettings = currentSettings.copyWith(
        theme: theme,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings(
    NotificationSettings notifications,
  ) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      await _repository.updateNotificationSettings(
        currentSettings.userId,
        notifications,
      );
      final updatedSettings = currentSettings.copyWith(
        notifications: notifications,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Genel ayarları güncelle
  Future<void> updateGeneralSettings(GeneralSettings general) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      await _repository.updateGeneralSettings(currentSettings.userId, general);
      final updatedSettings = currentSettings.copyWith(
        general: general,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Güvenlik ayarlarını güncelle
  Future<void> updateSecuritySettings(SecuritySettings security) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      await _repository.updateSecuritySettings(
        currentSettings.userId,
        security,
      );
      final updatedSettings = currentSettings.copyWith(
        security: security,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Veri ayarlarını güncelle
  Future<void> updateDataSettings(DataSettings data) async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      await _repository.updateDataSettings(currentSettings.userId, data);
      final updatedSettings = currentSettings.copyWith(
        data: data,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Ayarları sıfırla
  Future<void> resetSettings() async {
    try {
      final currentSettings = state.value;
      if (currentSettings == null) return;

      await _repository.resetSettings(currentSettings.userId);
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
final themeSettingsProvider = Provider<ThemeSettings>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.theme,
    loading: () => const ThemeSettings(),
    error: (_, __) => const ThemeSettings(),
  );
});

/// Bildirim ayarları provider
final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.notifications,
    loading: () => const NotificationSettings(),
    error: (_, __) => const NotificationSettings(),
  );
});

/// Genel ayarlar provider
final generalSettingsProvider = Provider<GeneralSettings>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.general,
    loading: () => const GeneralSettings(),
    error: (_, __) => const GeneralSettings(),
  );
});

/// Güvenlik ayarları provider
final securitySettingsProvider = Provider<SecuritySettings>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.security,
    loading: () => const SecuritySettings(),
    error: (_, __) => const SecuritySettings(),
  );
});

/// Veri ayarları provider
final dataSettingsProvider = Provider<DataSettings>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.data,
    loading: () => const DataSettings(),
    error: (_, __) => const DataSettings(),
  );
});

/// Karanlık tema provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeSettings = ref.watch(themeSettingsProvider);
  return themeSettings.isDarkMode;
});

/// Bildirimler aktif provider
final notificationsEnabledProvider = Provider<bool>((ref) {
  final notificationSettings = ref.watch(notificationSettingsProvider);
  return notificationSettings.isEnabled;
});

/// Dil provider
final languageProvider = Provider<String>((ref) {
  final generalSettings = ref.watch(generalSettingsProvider);
  return generalSettings.language;
});

/// Para birimi provider
final currencyProvider = Provider<String>((ref) {
  final generalSettings = ref.watch(generalSettingsProvider);
  return generalSettings.currency;
});
