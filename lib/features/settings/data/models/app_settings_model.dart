import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/settings/domain/entities/app_settings.dart';

/// AppSettings model for Firebase integration
class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.id,
    required super.userId,
    super.themeMode,
    super.language,
    super.currency,
    super.timeZone,
    super.dateFormat,
    super.timeFormat,
    super.numberFormat,
    super.enableNotifications,
    super.notificationSettings,
    super.enableSounds,
    super.enableVibration,
    super.enableBiometric,
    super.enableAutoLock,
    super.autoLockDuration,
    super.enableDataBackup,
    super.enableAutoBackup,
    super.backupFrequency,
    super.enableAnalytics,
    super.enableCrashReporting,
    super.enablePerformanceMonitoring,
    super.customSettings,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Firestore DocumentSnapshot'tan AppSettingsModel oluşturur
  factory AppSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final notificationSettingsMap =
        Map<String, dynamic>.from(data['notificationSettings'] ?? {});
    final notificationSettings = <NotificationType, bool>{};

    for (final entry in notificationSettingsMap.entries) {
      final type = NotificationType.values.firstWhere(
        (e) => e.name == entry.key,
        orElse: () => NotificationType.system,
      );
      notificationSettings[type] = entry.value as bool;
    }

    return AppSettingsModel(
      id: doc.id,
      userId: data['userId'] as String,
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == data['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      language: Language.values.firstWhere(
        (e) => e.name == data['language'],
        orElse: () => Language.tr,
      ),
      currency: Currency.values.firstWhere(
        (e) => e.name == data['currency'],
        orElse: () => Currency.tl,
      ),
      timeZone: data['timeZone'] as String? ?? 'Europe/Istanbul',
      dateFormat: data['dateFormat'] as String? ?? 'dd.MM.yyyy',
      timeFormat: data['timeFormat'] as String? ?? 'HH:mm',
      numberFormat: data['numberFormat'] as String? ?? '#,##0.00',
      enableNotifications: data['enableNotifications'] as bool? ?? true,
      notificationSettings: notificationSettings,
      enableSounds: data['enableSounds'] as bool? ?? true,
      enableVibration: data['enableVibration'] as bool? ?? true,
      enableBiometric: data['enableBiometric'] as bool? ?? false,
      enableAutoLock: data['enableAutoLock'] as bool? ?? false,
      autoLockDuration: data['autoLockDuration'] as int? ?? 300,
      enableDataBackup: data['enableDataBackup'] as bool? ?? true,
      enableAutoBackup: data['enableAutoBackup'] as bool? ?? false,
      backupFrequency: data['backupFrequency'] as int? ?? 7,
      enableAnalytics: data['enableAnalytics'] as bool? ?? true,
      enableCrashReporting: data['enableCrashReporting'] as bool? ?? true,
      enablePerformanceMonitoring:
          data['enablePerformanceMonitoring'] as bool? ?? true,
      customSettings: Map<String, dynamic>.from(data['customSettings'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// AppSettingsModel'i Firestore'a uygun Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// AppSettingsModel'i AppSettings entity'sine dönüştürür
  AppSettings toEntity() {
    return AppSettings(
      id: id,
      userId: userId,
      themeMode: themeMode,
      language: language,
      currency: currency,
      timeZone: timeZone,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      numberFormat: numberFormat,
      enableNotifications: enableNotifications,
      notificationSettings: notificationSettings,
      enableSounds: enableSounds,
      enableVibration: enableVibration,
      enableBiometric: enableBiometric,
      enableAutoLock: enableAutoLock,
      autoLockDuration: autoLockDuration,
      enableDataBackup: enableDataBackup,
      enableAutoBackup: enableAutoBackup,
      backupFrequency: backupFrequency,
      enableAnalytics: enableAnalytics,
      enableCrashReporting: enableCrashReporting,
      enablePerformanceMonitoring: enablePerformanceMonitoring,
      customSettings: customSettings,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// AppSettings entity'sinden AppSettingsModel oluşturur
  factory AppSettingsModel.fromEntity(AppSettings appSettings) {
    return AppSettingsModel(
      id: appSettings.id,
      userId: appSettings.userId,
      themeMode: appSettings.themeMode,
      language: appSettings.language,
      currency: appSettings.currency,
      timeZone: appSettings.timeZone,
      dateFormat: appSettings.dateFormat,
      timeFormat: appSettings.timeFormat,
      numberFormat: appSettings.numberFormat,
      enableNotifications: appSettings.enableNotifications,
      notificationSettings: appSettings.notificationSettings,
      enableSounds: appSettings.enableSounds,
      enableVibration: appSettings.enableVibration,
      enableBiometric: appSettings.enableBiometric,
      enableAutoLock: appSettings.enableAutoLock,
      autoLockDuration: appSettings.autoLockDuration,
      enableDataBackup: appSettings.enableDataBackup,
      enableAutoBackup: appSettings.enableAutoBackup,
      backupFrequency: appSettings.backupFrequency,
      enableAnalytics: appSettings.enableAnalytics,
      enableCrashReporting: appSettings.enableCrashReporting,
      enablePerformanceMonitoring: appSettings.enablePerformanceMonitoring,
      customSettings: appSettings.customSettings,
      createdAt: appSettings.createdAt,
      updatedAt: appSettings.updatedAt,
    );
  }
}
