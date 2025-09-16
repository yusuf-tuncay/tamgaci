import 'package:equatable/equatable.dart';

/// Tema modu
enum ThemeMode {
  light('Açık Tema'),
  dark('Koyu Tema'),
  system('Sistem');

  const ThemeMode(this.displayName);
  final String displayName;
}

/// Dil seçeneği
enum Language {
  tr('Türkçe'),
  en('English');

  const Language(this.displayName);
  final String displayName;
}

/// Para birimi
enum Currency {
  tl('Türk Lirası', '₺'),
  usd('Amerikan Doları', '\$'),
  eur('Euro', '€');

  const Currency(this.displayName, this.symbol);
  final String displayName;
  final String symbol;
}

/// Bildirim türü
enum NotificationType {
  sales('Satış Bildirimleri'),
  purchases('Alış Bildirimleri'),
  inventory('Envanter Bildirimleri'),
  reports('Rapor Bildirimleri'),
  system('Sistem Bildirimleri');

  const NotificationType(this.displayName);
  final String displayName;
}

/// Uygulama ayarları entity'si
class AppSettings extends Equatable {
  final String id;
  final String userId;
  final ThemeMode themeMode;
  final Language language;
  final Currency currency;
  final String timeZone;
  final String dateFormat;
  final String timeFormat;
  final String numberFormat;
  final bool enableNotifications;
  final Map<NotificationType, bool> notificationSettings;
  final bool enableSounds;
  final bool enableVibration;
  final bool enableBiometric;
  final bool enableAutoLock;
  final int autoLockDuration;
  final bool enableDataBackup;
  final bool enableAutoBackup;
  final int backupFrequency;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enablePerformanceMonitoring;
  final Map<String, dynamic> customSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppSettings({
    required this.id,
    required this.userId,
    this.themeMode = ThemeMode.system,
    this.language = Language.tr,
    this.currency = Currency.tl,
    this.timeZone = 'Europe/Istanbul',
    this.dateFormat = 'dd.MM.yyyy',
    this.timeFormat = 'HH:mm',
    this.numberFormat = '#,##0.00',
    this.enableNotifications = true,
    this.notificationSettings = const {},
    this.enableSounds = true,
    this.enableVibration = true,
    this.enableBiometric = false,
    this.enableAutoLock = false,
    this.autoLockDuration = 300, // 5 dakika
    this.enableDataBackup = true,
    this.enableAutoBackup = false,
    this.backupFrequency = 7, // 7 gün
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.enablePerformanceMonitoring = true,
    this.customSettings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  AppSettings copyWith({
    String? id,
    String? userId,
    ThemeMode? themeMode,
    Language? language,
    Currency? currency,
    String? timeZone,
    String? dateFormat,
    String? timeFormat,
    String? numberFormat,
    bool? enableNotifications,
    Map<NotificationType, bool>? notificationSettings,
    bool? enableSounds,
    bool? enableVibration,
    bool? enableBiometric,
    bool? enableAutoLock,
    int? autoLockDuration,
    bool? enableDataBackup,
    bool? enableAutoBackup,
    int? backupFrequency,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? enablePerformanceMonitoring,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      timeZone: timeZone ?? this.timeZone,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      enableSounds: enableSounds ?? this.enableSounds,
      enableVibration: enableVibration ?? this.enableVibration,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      enableAutoLock: enableAutoLock ?? this.enableAutoLock,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
      enableDataBackup: enableDataBackup ?? this.enableDataBackup,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enablePerformanceMonitoring:
          enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'themeMode': themeMode.name,
      'language': language.name,
      'currency': currency.name,
      'timeZone': timeZone,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'numberFormat': numberFormat,
      'enableNotifications': enableNotifications,
      'notificationSettings':
          notificationSettings.map((key, value) => MapEntry(key.name, value)),
      'enableSounds': enableSounds,
      'enableVibration': enableVibration,
      'enableBiometric': enableBiometric,
      'enableAutoLock': enableAutoLock,
      'autoLockDuration': autoLockDuration,
      'enableDataBackup': enableDataBackup,
      'enableAutoBackup': enableAutoBackup,
      'backupFrequency': backupFrequency,
      'enableAnalytics': enableAnalytics,
      'enableCrashReporting': enableCrashReporting,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'customSettings': customSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final notificationSettingsMap =
        Map<String, dynamic>.from(json['notificationSettings'] ?? {});
    final notificationSettings = <NotificationType, bool>{};

    for (final entry in notificationSettingsMap.entries) {
      final type = NotificationType.values.firstWhere(
        (e) => e.name == entry.key,
        orElse: () => NotificationType.system,
      );
      notificationSettings[type] = entry.value as bool;
    }

    return AppSettings(
      id: json['id'] as String,
      userId: json['userId'] as String,
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      language: Language.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => Language.tr,
      ),
      currency: Currency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => Currency.tl,
      ),
      timeZone: json['timeZone'] as String? ?? 'Europe/Istanbul',
      dateFormat: json['dateFormat'] as String? ?? 'dd.MM.yyyy',
      timeFormat: json['timeFormat'] as String? ?? 'HH:mm',
      numberFormat: json['numberFormat'] as String? ?? '#,##0.00',
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      notificationSettings: notificationSettings,
      enableSounds: json['enableSounds'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? true,
      enableBiometric: json['enableBiometric'] as bool? ?? false,
      enableAutoLock: json['enableAutoLock'] as bool? ?? false,
      autoLockDuration: json['autoLockDuration'] as int? ?? 300,
      enableDataBackup: json['enableDataBackup'] as bool? ?? true,
      enableAutoBackup: json['enableAutoBackup'] as bool? ?? false,
      backupFrequency: json['backupFrequency'] as int? ?? 7,
      enableAnalytics: json['enableAnalytics'] as bool? ?? true,
      enableCrashReporting: json['enableCrashReporting'] as bool? ?? true,
      enablePerformanceMonitoring:
          json['enablePerformanceMonitoring'] as bool? ?? true,
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        themeMode,
    language,
    currency,
        timeZone,
    dateFormat,
    timeFormat,
        numberFormat,
        enableNotifications,
        notificationSettings,
        enableSounds,
        enableVibration,
        enableBiometric,
        enableAutoLock,
        autoLockDuration,
        enableDataBackup,
        enableAutoBackup,
    backupFrequency,
        enableAnalytics,
        enableCrashReporting,
        enablePerformanceMonitoring,
        customSettings,
        createdAt,
        updatedAt,
      ];
}
