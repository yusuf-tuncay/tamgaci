// ========== SETTINGS REPOSITORY IMPLEMENTATION ==========
// lib/features/settings/data/repositories/settings_repository_impl.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/app_settings.dart';

/// Settings repository implementation
class SettingsRepositoryImpl implements SettingsRepository {
  static const String _settingsKey = 'app_settings';
  static const String _themeKey = 'theme_settings';
  static const String _notificationsKey = 'notification_settings';
  static const String _generalKey = 'general_settings';
  static const String _securityKey = 'security_settings';
  static const String _dataKey = 'data_settings';

  @override
  Future<AppSettings> getSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Eğer ayarlar yoksa varsayılan ayarları oluştur
      if (!prefs.containsKey('${_settingsKey}_$userId')) {
        return await createDefaultSettings(userId);
      }

      final settingsJson = prefs.getString('${_settingsKey}_$userId');
      if (settingsJson == null) {
        return await createDefaultSettings(userId);
      }

      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return _fromJson(settingsMap);
    } catch (e) {
      // Hata durumunda varsayılan ayarları döndür
      return await createDefaultSettings(userId);
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_toJson(settings));
      await prefs.setString('${_settingsKey}_${settings.userId}', settingsJson);
    } catch (e) {
      throw Exception('Ayarlar kaydedilemedi: $e');
    }
  }

  @override
  Future<void> updateThemeSettings(String userId, ThemeSettings theme) async {
    try {
      final settings = await getSettings(userId);
      final updatedSettings = settings.copyWith(
        theme: theme,
        updatedAt: DateTime.now(),
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Tema ayarları güncellenemedi: $e');
    }
  }

  @override
  Future<void> updateNotificationSettings(
    String userId,
    NotificationSettings notifications,
  ) async {
    try {
      final settings = await getSettings(userId);
      final updatedSettings = settings.copyWith(
        notifications: notifications,
        updatedAt: DateTime.now(),
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Bildirim ayarları güncellenemedi: $e');
    }
  }

  @override
  Future<void> updateGeneralSettings(
    String userId,
    GeneralSettings general,
  ) async {
    try {
      final settings = await getSettings(userId);
      final updatedSettings = settings.copyWith(
        general: general,
        updatedAt: DateTime.now(),
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Genel ayarlar güncellenemedi: $e');
    }
  }

  @override
  Future<void> updateSecuritySettings(
    String userId,
    SecuritySettings security,
  ) async {
    try {
      final settings = await getSettings(userId);
      final updatedSettings = settings.copyWith(
        security: security,
        updatedAt: DateTime.now(),
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Güvenlik ayarları güncellenemedi: $e');
    }
  }

  @override
  Future<void> updateDataSettings(String userId, DataSettings data) async {
    try {
      final settings = await getSettings(userId);
      final updatedSettings = settings.copyWith(
        data: data,
        updatedAt: DateTime.now(),
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Veri ayarları güncellenemedi: $e');
    }
  }

  @override
  Future<void> resetSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_settingsKey}_$userId');
      await prefs.remove('${_themeKey}_$userId');
      await prefs.remove('${_notificationsKey}_$userId');
      await prefs.remove('${_generalKey}_$userId');
      await prefs.remove('${_securityKey}_$userId');
      await prefs.remove('${_dataKey}_$userId');
    } catch (e) {
      throw Exception('Ayarlar sıfırlanamadı: $e');
    }
  }

  @override
  Future<AppSettings> createDefaultSettings(String userId) async {
    final defaultSettings = AppSettings(
      userId: userId,
      theme: const ThemeSettings(),
      notifications: const NotificationSettings(),
      general: const GeneralSettings(),
      security: const SecuritySettings(),
      data: const DataSettings(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  // JSON dönüşüm metodları
  Map<String, dynamic> _toJson(AppSettings settings) {
    return {
      'userId': settings.userId,
      'theme': {
        'isDarkMode': settings.theme.isDarkMode,
        'followSystem': settings.theme.followSystem,
        'customColor': settings.theme.customColor,
      },
      'notifications': {
        'isEnabled': settings.notifications.isEnabled,
        'invoiceReminders': settings.notifications.invoiceReminders,
        'paymentReminders': settings.notifications.paymentReminders,
        'stockAlerts': settings.notifications.stockAlerts,
        'soundEnabled': settings.notifications.soundEnabled,
        'vibrationEnabled': settings.notifications.vibrationEnabled,
      },
      'general': {
        'language': settings.general.language,
        'currency': settings.general.currency,
        'dateFormat': settings.general.dateFormat,
        'timeFormat': settings.general.timeFormat,
        'autoSave': settings.general.autoSave,
        'autoBackup': settings.general.autoBackup,
      },
      'security': {
        'biometricEnabled': settings.security.biometricEnabled,
        'twoFactorEnabled': settings.security.twoFactorEnabled,
        'autoLockTimeout': settings.security.autoLockTimeout,
        'strongPassword': settings.security.strongPassword,
      },
      'data': {
        'backupFrequency': settings.data.backupFrequency,
        'backupRetention': settings.data.backupRetention,
        'cloudBackup': settings.data.cloudBackup,
        'dataEncryption': settings.data.dataEncryption,
        'autoCleanup': settings.data.autoCleanup,
      },
      'createdAt': settings.createdAt.toIso8601String(),
      'updatedAt': settings.updatedAt.toIso8601String(),
    };
  }

  AppSettings _fromJson(Map<String, dynamic> json) {
    return AppSettings(
      userId: json['userId'] as String,
      theme: ThemeSettings(
        isDarkMode: json['theme']['isDarkMode'] as bool? ?? false,
        followSystem: json['theme']['followSystem'] as bool? ?? true,
        customColor: json['theme']['customColor'] as String?,
      ),
      notifications: NotificationSettings(
        isEnabled: json['notifications']['isEnabled'] as bool? ?? true,
        invoiceReminders:
            json['notifications']['invoiceReminders'] as bool? ?? true,
        paymentReminders:
            json['notifications']['paymentReminders'] as bool? ?? true,
        stockAlerts: json['notifications']['stockAlerts'] as bool? ?? true,
        soundEnabled: json['notifications']['soundEnabled'] as bool? ?? true,
        vibrationEnabled:
            json['notifications']['vibrationEnabled'] as bool? ?? true,
      ),
      general: GeneralSettings(
        language: json['general']['language'] as String? ?? 'tr',
        currency: json['general']['currency'] as String? ?? 'TRY',
        dateFormat: json['general']['dateFormat'] as String? ?? 'dd/MM/yyyy',
        timeFormat: json['general']['timeFormat'] as String? ?? 'HH:mm',
        autoSave: json['general']['autoSave'] as bool? ?? true,
        autoBackup: json['general']['autoBackup'] as bool? ?? true,
      ),
      security: SecuritySettings(
        biometricEnabled:
            json['security']['biometricEnabled'] as bool? ?? false,
        twoFactorEnabled:
            json['security']['twoFactorEnabled'] as bool? ?? false,
        autoLockTimeout: json['security']['autoLockTimeout'] as int? ?? 5,
        strongPassword: json['security']['strongPassword'] as bool? ?? true,
      ),
      data: DataSettings(
        backupFrequency: json['data']['backupFrequency'] as int? ?? 7,
        backupRetention: json['data']['backupRetention'] as int? ?? 30,
        cloudBackup: json['data']['cloudBackup'] as bool? ?? false,
        dataEncryption: json['data']['dataEncryption'] as bool? ?? true,
        autoCleanup: json['data']['autoCleanup'] as bool? ?? false,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
