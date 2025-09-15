import 'package:tamgaci/features/settings/domain/entities/app_settings.dart';
import 'package:tamgaci/features/settings/domain/entities/user_profile.dart';

/// Settings Repository Interface
/// Bu interface, ayarlar ile ilgili tüm veri işlemlerini tanımlar.
abstract class SettingsRepository {
  /// Kullanıcı ayarlarını getirir
  /// [userId]: Kullanıcı ID'si
  /// Returns: Uygulama ayarları veya null
  Future<AppSettings?> getAppSettings(String userId);

  /// Kullanıcı ayarlarını günceller
  /// [appSettings]: Güncellenecek uygulama ayarları
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateAppSettings(AppSettings appSettings);

  /// Kullanıcı ayarlarını oluşturur
  /// [appSettings]: Oluşturulacak uygulama ayarları
  /// Returns: Oluşturulan uygulama ayarları
  Future<AppSettings> createAppSettings(AppSettings appSettings);

  /// Kullanıcı ayarlarını siler
  /// [userId]: Kullanıcı ID'si
  Future<void> deleteAppSettings(String userId);

  /// Kullanıcı profilini getirir
  /// [userId]: Kullanıcı ID'si
  /// Returns: Kullanıcı profili veya null
  Future<UserProfile?> getUserProfile(String userId);

  /// UID ile kullanıcı profilini getirir
  /// [uid]: Firebase Auth UID
  /// Returns: Kullanıcı profili veya null
  Future<UserProfile?> getUserProfileByUid(String uid);

  /// Email ile kullanıcı profilini getirir
  /// [email]: Email adresi
  /// Returns: Kullanıcı profili veya null
  Future<UserProfile?> getUserProfileByEmail(String email);

  /// Kullanıcı profilini günceller
  /// [userProfile]: Güncellenecek kullanıcı profili
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateUserProfile(UserProfile userProfile);

  /// Kullanıcı profilini oluşturur
  /// [userProfile]: Oluşturulacak kullanıcı profili
  /// Returns: Oluşturulan kullanıcı profili
  Future<UserProfile> createUserProfile(UserProfile userProfile);

  /// Kullanıcı profilini siler
  /// [userId]: Kullanıcı ID'si
  Future<void> deleteUserProfile(String userId);

  /// Tema modunu günceller
  /// [userId]: Kullanıcı ID'si
  /// [themeMode]: Yeni tema modu
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateThemeMode(String userId, ThemeMode themeMode);

  /// Dili günceller
  /// [userId]: Kullanıcı ID'si
  /// [language]: Yeni dil
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateLanguage(String userId, Language language);

  /// Para birimini günceller
  /// [userId]: Kullanıcı ID'si
  /// [currency]: Yeni para birimi
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateCurrency(String userId, Currency currency);

  /// Bildirim ayarlarını günceller
  /// [userId]: Kullanıcı ID'si
  /// [enableNotifications]: Bildirimleri etkinleştir
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateNotificationSettings(
      String userId, bool enableNotifications);

  /// Belirli bildirim türünü günceller
  /// [userId]: Kullanıcı ID'si
  /// [type]: Bildirim türü
  /// [enabled]: Etkin durumu
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateNotificationType(
      String userId, NotificationType type, bool enabled);

  /// Biyometrik ayarını günceller
  /// [userId]: Kullanıcı ID'si
  /// [enableBiometric]: Biyometrik kimlik doğrulamayı etkinleştir
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateBiometricSettings(
      String userId, bool enableBiometric);

  /// Otomatik kilit ayarını günceller
  /// [userId]: Kullanıcı ID'si
  /// [enableAutoLock]: Otomatik kilidi etkinleştir
  /// [duration]: Kilit süresi (saniye)
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateAutoLockSettings(
      String userId, bool enableAutoLock, int duration);

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
  );

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
  );

  /// Özel ayar günceller
  /// [userId]: Kullanıcı ID'si
  /// [key]: Ayar anahtarı
  /// [value]: Ayar değeri
  /// Returns: Güncellenmiş uygulama ayarları
  Future<AppSettings> updateCustomSetting(
      String userId, String key, dynamic value);

  /// Kullanıcı profil fotoğrafını günceller
  /// [userId]: Kullanıcı ID'si
  /// [photoUrl]: Yeni fotoğraf URL'si
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateProfilePhoto(String userId, String photoUrl);

  /// Kullanıcı şifresini değiştirir
  /// [userId]: Kullanıcı ID'si
  /// [currentPassword]: Mevcut şifre
  /// [newPassword]: Yeni şifre
  /// Returns: İşlem başarılı mı
  Future<bool> changePassword(
      String userId, String currentPassword, String newPassword);

  /// İki faktörlü kimlik doğrulamayı etkinleştirir/devre dışı bırakır
  /// [userId]: Kullanıcı ID'si
  /// [enabled]: Etkin durumu
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateTwoFactorAuth(String userId, bool enabled);

  /// Email doğrulaması gönderir
  /// [userId]: Kullanıcı ID'si
  /// Returns: İşlem başarılı mı
  Future<bool> sendEmailVerification(String userId);

  /// Telefon doğrulaması gönderir
  /// [userId]: Kullanıcı ID'si
  /// [phoneNumber]: Telefon numarası
  /// Returns: İşlem başarılı mı
  Future<bool> sendPhoneVerification(String userId, String phoneNumber);

  /// Email doğrulamasını onaylar
  /// [userId]: Kullanıcı ID'si
  /// [code]: Doğrulama kodu
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> verifyEmail(String userId, String code);

  /// Telefon doğrulamasını onaylar
  /// [userId]: Kullanıcı ID'si
  /// [code]: Doğrulama kodu
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> verifyPhone(String userId, String code);

  /// Kullanıcı izinlerini günceller
  /// [userId]: Kullanıcı ID'si
  /// [permissions]: Yeni izinler
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateUserPermissions(
      String userId, List<String> permissions);

  /// Kullanıcı rolünü günceller
  /// [userId]: Kullanıcı ID'si
  /// [role]: Yeni rol
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateUserRole(String userId, UserRole role);

  /// Kullanıcı durumunu günceller
  /// [userId]: Kullanıcı ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateUserStatus(String userId, UserStatus status);

  /// Son giriş bilgilerini günceller
  /// [userId]: Kullanıcı ID'si
  /// [loginTime]: Giriş zamanı
  /// [ipAddress]: IP adresi
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateLastLogin(
      String userId, DateTime loginTime, String ipAddress);

  /// Kullanıcı tercihlerini günceller
  /// [userId]: Kullanıcı ID'si
  /// [preferences]: Yeni tercihler
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateUserPreferences(
      String userId, Map<String, dynamic> preferences);

  /// Veri yedeklemesi oluşturur
  /// [userId]: Kullanıcı ID'si
  /// Returns: Yedekleme dosyası URL'si
  Future<String> createDataBackup(String userId);

  /// Veri yedeklemesini geri yükler
  /// [userId]: Kullanıcı ID'si
  /// [backupUrl]: Yedekleme dosyası URL'si
  /// Returns: İşlem başarılı mı
  Future<bool> restoreDataBackup(String userId, String backupUrl);

  /// Tüm kullanıcı verilerini siler (GDPR)
  /// [userId]: Kullanıcı ID'si
  /// Returns: İşlem başarılı mı
  Future<bool> deleteAllUserData(String userId);

  /// Kullanıcı verilerini dışa aktarır (GDPR)
  /// [userId]: Kullanıcı ID'si
  /// Returns: Veri dosyası URL'si
  Future<String> exportUserData(String userId);

  /// Sistem ayarlarını getirir
  /// Returns: Sistem ayarları
  Future<Map<String, dynamic>> getSystemSettings();

  /// Sistem ayarını günceller (sadece admin)
  /// [key]: Ayar anahtarı
  /// [value]: Ayar değeri
  /// [adminUserId]: Admin kullanıcı ID'si
  /// Returns: İşlem başarılı mı
  Future<bool> updateSystemSetting(
      String key, dynamic value, String adminUserId);
}
