// ========== SETTINGS REPOSITORY INTERFACE ==========
// lib/features/settings/domain/repositories/settings_repository.dart

import '../entities/app_settings.dart';

/// Settings repository abstract sınıfı
abstract class SettingsRepository {
  /// Kullanıcının ayarlarını getir
  Future<AppSettings> getSettings(String userId);

  /// Ayarları kaydet
  Future<void> saveSettings(AppSettings settings);

  /// Tema ayarlarını güncelle
  Future<void> updateThemeSettings(String userId, ThemeSettings theme);

  /// Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings(
    String userId,
    NotificationSettings notifications,
  );

  /// Genel ayarları güncelle
  Future<void> updateGeneralSettings(String userId, GeneralSettings general);

  /// Güvenlik ayarlarını güncelle
  Future<void> updateSecuritySettings(String userId, SecuritySettings security);

  /// Veri ayarlarını güncelle
  Future<void> updateDataSettings(String userId, DataSettings data);

  /// Ayarları sıfırla
  Future<void> resetSettings(String userId);

  /// Varsayılan ayarları oluştur
  Future<AppSettings> createDefaultSettings(String userId);
}
