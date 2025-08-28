// ========== APP SETTINGS ENTITY ==========
// lib/features/settings/domain/entities/app_settings.dart

/// Uygulama ayarları entity'si
class AppSettings {
  /// Kullanıcı ID'si
  final String userId;

  /// Tema ayarları
  final ThemeSettings theme;

  /// Bildirim ayarları
  final NotificationSettings notifications;

  /// Genel ayarlar
  final GeneralSettings general;

  /// Güvenlik ayarları
  final SecuritySettings security;

  /// Veri yönetimi ayarları
  final DataSettings data;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const AppSettings({
    required this.userId,
    required this.theme,
    required this.notifications,
    required this.general,
    required this.security,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Kopyalama metodu
  AppSettings copyWith({
    String? userId,
    ThemeSettings? theme,
    NotificationSettings? notifications,
    GeneralSettings? general,
    SecuritySettings? security,
    DataSettings? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      general: general ?? this.general,
      security: security ?? this.security,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.userId == userId &&
        other.theme == theme &&
        other.notifications == notifications &&
        other.general == general &&
        other.security == security &&
        other.data == data;
  }

  @override
  int get hashCode {
    return Object.hash(userId, theme, notifications, general, security, data);
  }
}

/// Tema ayarları
class ThemeSettings {
  /// Karanlık tema aktif mi
  final bool isDarkMode;

  /// Sistem temasını takip et
  final bool followSystem;

  /// Özel tema rengi
  final String? customColor;

  const ThemeSettings({
    this.isDarkMode = false,
    this.followSystem = true,
    this.customColor,
  });

  ThemeSettings copyWith({
    bool? isDarkMode,
    bool? followSystem,
    String? customColor,
  }) {
    return ThemeSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      followSystem: followSystem ?? this.followSystem,
      customColor: customColor ?? this.customColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeSettings &&
        other.isDarkMode == isDarkMode &&
        other.followSystem == followSystem &&
        other.customColor == customColor;
  }

  @override
  int get hashCode => Object.hash(isDarkMode, followSystem, customColor);
}

/// Bildirim ayarları
class NotificationSettings {
  /// Genel bildirimler aktif mi
  final bool isEnabled;

  /// Fatura hatırlatıcıları
  final bool invoiceReminders;

  /// Ödeme hatırlatıcıları
  final bool paymentReminders;

  /// Stok uyarıları
  final bool stockAlerts;

  /// Ses bildirimleri
  final bool soundEnabled;

  /// Titreşim bildirimleri
  final bool vibrationEnabled;

  const NotificationSettings({
    this.isEnabled = true,
    this.invoiceReminders = true,
    this.paymentReminders = true,
    this.stockAlerts = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationSettings copyWith({
    bool? isEnabled,
    bool? invoiceReminders,
    bool? paymentReminders,
    bool? stockAlerts,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      invoiceReminders: invoiceReminders ?? this.invoiceReminders,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      stockAlerts: stockAlerts ?? this.stockAlerts,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.isEnabled == isEnabled &&
        other.invoiceReminders == invoiceReminders &&
        other.paymentReminders == paymentReminders &&
        other.stockAlerts == stockAlerts &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled;
  }

  @override
  int get hashCode => Object.hash(
    isEnabled,
    invoiceReminders,
    paymentReminders,
    stockAlerts,
    soundEnabled,
    vibrationEnabled,
  );
}

/// Genel ayarlar
class GeneralSettings {
  /// Dil
  final String language;

  /// Para birimi
  final String currency;

  /// Tarih formatı
  final String dateFormat;

  /// Saat formatı
  final String timeFormat;

  /// Otomatik kaydetme
  final bool autoSave;

  /// Otomatik yedekleme
  final bool autoBackup;

  const GeneralSettings({
    this.language = 'tr',
    this.currency = 'TRY',
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'HH:mm',
    this.autoSave = true,
    this.autoBackup = true,
  });

  GeneralSettings copyWith({
    String? language,
    String? currency,
    String? dateFormat,
    String? timeFormat,
    bool? autoSave,
    bool? autoBackup,
  }) {
    return GeneralSettings(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      autoSave: autoSave ?? this.autoSave,
      autoBackup: autoBackup ?? this.autoBackup,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneralSettings &&
        other.language == language &&
        other.currency == currency &&
        other.dateFormat == dateFormat &&
        other.timeFormat == timeFormat &&
        other.autoSave == autoSave &&
        other.autoBackup == autoBackup;
  }

  @override
  int get hashCode => Object.hash(
    language,
    currency,
    dateFormat,
    timeFormat,
    autoSave,
    autoBackup,
  );
}

/// Güvenlik ayarları
class SecuritySettings {
  /// Biometrik giriş aktif mi
  final bool biometricEnabled;

  /// İki faktörlü doğrulama
  final bool twoFactorEnabled;

  /// Otomatik kilitlenme süresi (dakika)
  final int autoLockTimeout;

  /// Şifre karmaşıklığı
  final bool strongPassword;

  const SecuritySettings({
    this.biometricEnabled = false,
    this.twoFactorEnabled = false,
    this.autoLockTimeout = 5,
    this.strongPassword = true,
  });

  SecuritySettings copyWith({
    bool? biometricEnabled,
    bool? twoFactorEnabled,
    int? autoLockTimeout,
    bool? strongPassword,
  }) {
    return SecuritySettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      strongPassword: strongPassword ?? this.strongPassword,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecuritySettings &&
        other.biometricEnabled == biometricEnabled &&
        other.twoFactorEnabled == twoFactorEnabled &&
        other.autoLockTimeout == autoLockTimeout &&
        other.strongPassword == strongPassword;
  }

  @override
  int get hashCode => Object.hash(
    biometricEnabled,
    twoFactorEnabled,
    autoLockTimeout,
    strongPassword,
  );
}

/// Veri yönetimi ayarları
class DataSettings {
  /// Yedekleme sıklığı (gün)
  final int backupFrequency;

  /// Yedekleme tutma süresi (gün)
  final int backupRetention;

  /// Bulut yedekleme aktif mi
  final bool cloudBackup;

  /// Veri şifreleme
  final bool dataEncryption;

  /// Otomatik temizlik
  final bool autoCleanup;

  const DataSettings({
    this.backupFrequency = 7,
    this.backupRetention = 30,
    this.cloudBackup = false,
    this.dataEncryption = true,
    this.autoCleanup = false,
  });

  DataSettings copyWith({
    int? backupFrequency,
    int? backupRetention,
    bool? cloudBackup,
    bool? dataEncryption,
    bool? autoCleanup,
  }) {
    return DataSettings(
      backupFrequency: backupFrequency ?? this.backupFrequency,
      backupRetention: backupRetention ?? this.backupRetention,
      cloudBackup: cloudBackup ?? this.cloudBackup,
      dataEncryption: dataEncryption ?? this.dataEncryption,
      autoCleanup: autoCleanup ?? this.autoCleanup,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataSettings &&
        other.backupFrequency == backupFrequency &&
        other.backupRetention == backupRetention &&
        other.cloudBackup == cloudBackup &&
        other.dataEncryption == dataEncryption &&
        other.autoCleanup == autoCleanup;
  }

  @override
  int get hashCode => Object.hash(
    backupFrequency,
    backupRetention,
    cloudBackup,
    dataEncryption,
    autoCleanup,
  );
}
