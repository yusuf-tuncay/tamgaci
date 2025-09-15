import 'package:tamgaci/features/settings/domain/entities/app_settings.dart';
import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';

/// Uygulama ayarlarını güncelleme use case'i
class UpdateAppSettingsUseCase {
  final SettingsRepository _repository;

  UpdateAppSettingsUseCase(this._repository);

  /// Uygulama ayarlarını günceller
  /// [appSettings]: Güncellenecek uygulama ayarları
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> call(AppSettings appSettings) async {
    final updatedSettings = appSettings.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateAppSettings(updatedSettings);
  }

  /// Tema modunu günceller
  /// [userId]: Kullanıcı ID'si
  /// [themeMode]: Yeni tema modu
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateThemeMode(
      String userId, ThemeMode themeMode) async {
    return await _repository.updateThemeMode(userId, themeMode);
  }

  /// Dili günceller
  /// [userId]: Kullanıcı ID'si
  /// [language]: Yeni dil
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateLanguage(String userId, Language language) async {
    return await _repository.updateLanguage(userId, language);
  }

  /// Para birimini günceller
  /// [userId]: Kullanıcı ID'si
  /// [currency]: Yeni para birimi
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateCurrency(String userId, Currency currency) async {
    return await _repository.updateCurrency(userId, currency);
  }

  /// Bildirim ayarlarını günceller
  /// [userId]: Kullanıcı ID'si
  /// [enableNotifications]: Bildirimleri etkinleştir
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateNotificationSettings(
      String userId, bool enableNotifications) async {
    return await _repository.updateNotificationSettings(
        userId, enableNotifications);
  }

  /// Belirli bildirim türünü günceller
  /// [userId]: Kullanıcı ID'si
  /// [type]: Bildirim türü
  /// [enabled]: Etkin durumu
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateNotificationType(
      String userId, NotificationType type, bool enabled) async {
    return await _repository.updateNotificationType(userId, type, enabled);
  }

  /// Biyometrik ayarını günceller
  /// [userId]: Kullanıcı ID'si
  /// [enableBiometric]: Biyometrik kimlik doğrulamayı etkinleştir
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateBiometricSettings(
      String userId, bool enableBiometric) async {
    return await _repository.updateBiometricSettings(userId, enableBiometric);
  }

  /// Otomatik kilit ayarını günceller
  /// [userId]: Kullanıcı ID'si
  /// [enableAutoLock]: Otomatik kilidi etkinleştir
  /// [duration]: Kilit süresi (saniye)
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateAutoLockSettings(
      String userId, bool enableAutoLock, int duration) async {
    return await _repository.updateAutoLockSettings(
        userId, enableAutoLock, duration);
  }

  /// Yedekleme ayarlarını günceller
  /// [userId]: Kullanıcı ID'si
  /// [enableDataBackup]: Veri yedeklemeyi etkinleştir
  /// [enableAutoBackup]: Otomatik yedeklemeyi etkinleştir
  /// [frequency]: Yedekleme sıklığı (gün)
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateBackupSettings(
    String userId,
    bool enableDataBackup,
    bool enableAutoBackup,
    int frequency,
  ) async {
    return await _repository.updateBackupSettings(
      userId,
      enableDataBackup,
      enableAutoBackup,
      frequency,
    );
  }

  /// Analitik ayarlarını günceller
  /// [userId]: Kullanıcı ID'si
  /// [enableAnalytics]: Analitikleri etkinleştir
  /// [enableCrashReporting]: Çökme raporlamasını etkinleştir
  /// [enablePerformanceMonitoring]: Performans izlemeyi etkinleştir
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateAnalyticsSettings(
    String userId,
    bool enableAnalytics,
    bool enableCrashReporting,
    bool enablePerformanceMonitoring,
  ) async {
    return await _repository.updateAnalyticsSettings(
      userId,
      enableAnalytics,
      enableCrashReporting,
      enablePerformanceMonitoring,
    );
  }

  /// Özel ayar günceller
  /// [userId]: Kullanıcı ID'si
  /// [key]: Ayar anahtarı
  /// [value]: Ayar değeri
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateCustomSetting(
      String userId, String key, dynamic value) async {
    return await _repository.updateCustomSetting(userId, key, value);
  }
}
