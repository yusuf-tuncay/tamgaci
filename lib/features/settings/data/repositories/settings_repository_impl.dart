import 'package:tamgaci/features/settings/domain/entities/app_settings.dart';
import 'package:tamgaci/features/settings/domain/entities/user_profile.dart';
import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';
import 'package:tamgaci/features/settings/data/datasources/settings_firebase_datasource.dart';
import 'package:tamgaci/features/settings/data/models/app_settings_model.dart';
import 'package:tamgaci/features/settings/data/models/user_profile_model.dart';

/// Settings repository implementasyonu
/// Firebase Firestore işlemleri için repository
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsFirebaseDataSource _dataSource;

  SettingsRepositoryImpl({
    required SettingsFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  // App Settings Methods

  @override
  Future<AppSettings?> getAppSettings(String userId) async {
    final appSettingsModel = await _dataSource.getAppSettings(userId);
    return appSettingsModel?.toEntity();
  }

  @override
  Future<AppSettings> updateAppSettings(AppSettings appSettings) async {
    final appSettingsModel = AppSettingsModel.fromEntity(appSettings);
    final updatedAppSettingsModel =
        await _dataSource.updateAppSettings(appSettingsModel);
    return updatedAppSettingsModel.toEntity();
  }

  @override
  Future<AppSettings> createAppSettings(AppSettings appSettings) async {
    final appSettingsModel = AppSettingsModel.fromEntity(appSettings);
    final createdAppSettingsModel =
        await _dataSource.createAppSettings(appSettingsModel);
    return createdAppSettingsModel.toEntity();
  }

  @override
  Future<void> deleteAppSettings(String userId) async {
    await _dataSource.deleteAppSettings(userId);
  }

  // User Profile Methods

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final userProfileModel = await _dataSource.getUserProfile(userId);
    return userProfileModel?.toEntity();
  }

  @override
  Future<UserProfile?> getUserProfileByUid(String uid) async {
    final userProfileModel = await _dataSource.getUserProfileByUid(uid);
    return userProfileModel?.toEntity();
  }

  @override
  Future<UserProfile?> getUserProfileByEmail(String email) async {
    final userProfileModel = await _dataSource.getUserProfileByEmail(email);
    return userProfileModel?.toEntity();
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile userProfile) async {
    final userProfileModel = UserProfileModel.fromEntity(userProfile);
    final updatedUserProfileModel =
        await _dataSource.updateUserProfile(userProfileModel);
    return updatedUserProfileModel.toEntity();
  }

  @override
  Future<UserProfile> createUserProfile(UserProfile userProfile) async {
    final userProfileModel = UserProfileModel.fromEntity(userProfile);
    final createdUserProfileModel =
        await _dataSource.createUserProfile(userProfileModel);
    return createdUserProfileModel.toEntity();
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    await _dataSource.deleteUserProfile(userId);
  }

  // Settings Update Methods

  @override
  Future<AppSettings> updateThemeMode(
      String userId, ThemeMode themeMode) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final updatedSettings = currentSettings.copyWith(
      themeMode: themeMode,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateLanguage(String userId, Language language) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final updatedSettings = currentSettings.copyWith(
      language: language,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateCurrency(String userId, Currency currency) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final updatedSettings = currentSettings.copyWith(
      currency: currency,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateNotificationSettings(
      String userId, bool enableNotifications) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final updatedSettings = currentSettings.copyWith(
      enableNotifications: enableNotifications,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateNotificationType(
      String userId, NotificationType type, bool enabled) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final newNotificationSettings =
        Map<NotificationType, bool>.from(currentSettings.notificationSettings);
    newNotificationSettings[type] = enabled;

    final updatedSettings = currentSettings.copyWith(
      notificationSettings: newNotificationSettings,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateBiometricSettings(
      String userId, bool enableBiometric) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final updatedSettings = currentSettings.copyWith(
      enableBiometric: enableBiometric,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateAutoLockSettings(
      String userId, bool enableAutoLock, int duration) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final updatedSettings = currentSettings.copyWith(
      enableAutoLock: enableAutoLock,
      autoLockDuration: duration,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateBackupSettings(
    String userId,
    bool enableDataBackup,
    bool enableAutoBackup,
    int frequency,
  ) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final updatedSettings = currentSettings.copyWith(
      enableDataBackup: enableDataBackup,
      enableAutoBackup: enableAutoBackup,
      backupFrequency: frequency,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateAnalyticsSettings(
    String userId,
    bool enableAnalytics,
    bool enableCrashReporting,
    bool enablePerformanceMonitoring,
  ) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final updatedSettings = currentSettings.copyWith(
      enableAnalytics: enableAnalytics,
      enableCrashReporting: enableCrashReporting,
      enablePerformanceMonitoring: enablePerformanceMonitoring,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  @override
  Future<AppSettings> updateCustomSetting(
      String userId, String key, dynamic value) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) {
      throw Exception('App settings not found for user: $userId');
    }

    final newCustomSettings =
        Map<String, dynamic>.from(currentSettings.customSettings);
    newCustomSettings[key] = value;

    final updatedSettings = currentSettings.copyWith(
      customSettings: newCustomSettings,
      updatedAt: DateTime.now(),
    );

    return await updateAppSettings(updatedSettings);
  }

  // User Profile Update Methods

  @override
  Future<UserProfile> updateProfilePhoto(String userId, String photoUrl) async {
    final currentProfile = await getUserProfile(userId);
    if (currentProfile == null) {
      throw Exception('User profile not found: $userId');
    }

    final updatedProfile = currentProfile.copyWith(
      photoUrl: photoUrl,
      updatedAt: DateTime.now(),
    );

    return await updateUserProfile(updatedProfile);
  }

  @override
  Future<UserProfile> updateTwoFactorAuth(String userId, bool enabled) async {
    final currentProfile = await getUserProfile(userId);
    if (currentProfile == null) {
      throw Exception('User profile not found: $userId');
    }

    final updatedProfile = currentProfile.copyWith(
      twoFactorEnabled: enabled,
      updatedAt: DateTime.now(),
    );

    return await updateUserProfile(updatedProfile);
  }

  @override
  Future<UserProfile> updateUserPermissions(
      String userId, List<String> permissions) async {
    final currentProfile = await getUserProfile(userId);
    if (currentProfile == null) {
      throw Exception('User profile not found: $userId');
    }

    final updatedProfile = currentProfile.copyWith(
      permissions: permissions,
      updatedAt: DateTime.now(),
    );

    return await updateUserProfile(updatedProfile);
  }

  @override
  Future<UserProfile> updateUserRole(String userId, UserRole role) async {
    final currentProfile = await getUserProfile(userId);
    if (currentProfile == null) {
      throw Exception('User profile not found: $userId');
    }

    final updatedProfile = currentProfile.copyWith(
      role: role,
      updatedAt: DateTime.now(),
    );

    return await updateUserProfile(updatedProfile);
  }

  @override
  Future<UserProfile> updateUserStatus(String userId, UserStatus status) async {
    final currentProfile = await getUserProfile(userId);
    if (currentProfile == null) {
      throw Exception('User profile not found: $userId');
    }

    final updatedProfile = currentProfile.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    return await updateUserProfile(updatedProfile);
  }

  @override
  Future<UserProfile> updateLastLogin(
      String userId, DateTime loginTime, String ipAddress) async {
    final currentProfile = await getUserProfile(userId);
    if (currentProfile == null) {
      throw Exception('User profile not found: $userId');
    }

    final updatedProfile = currentProfile.copyWith(
      lastLoginAt: loginTime,
      lastLoginIp: ipAddress,
      updatedAt: DateTime.now(),
    );

    return await updateUserProfile(updatedProfile);
  }

  @override
  Future<UserProfile> updateUserPreferences(
      String userId, Map<String, dynamic> preferences) async {
    final currentProfile = await getUserProfile(userId);
    if (currentProfile == null) {
      throw Exception('User profile not found: $userId');
    }

    final updatedProfile = currentProfile.copyWith(
      preferences: preferences,
      updatedAt: DateTime.now(),
    );

    return await updateUserProfile(updatedProfile);
  }

  // Security Methods

  @override
  Future<bool> changePassword(
      String userId, String currentPassword, String newPassword) async {
    return await _dataSource.changePassword(
        userId, currentPassword, newPassword);
  }

  @override
  Future<bool> sendEmailVerification(String userId) async {
    return await _dataSource.sendEmailVerification(userId);
  }

  @override
  Future<bool> sendPhoneVerification(String userId, String phoneNumber) async {
    return await _dataSource.sendPhoneVerification(userId, phoneNumber);
  }

  @override
  Future<UserProfile> verifyEmail(String userId, String code) async {
    final userProfileModel = await _dataSource.verifyEmail(userId, code);
    return userProfileModel.toEntity();
  }

  @override
  Future<UserProfile> verifyPhone(String userId, String code) async {
    final userProfileModel = await _dataSource.verifyPhone(userId, code);
    return userProfileModel.toEntity();
  }

  // Data Management Methods

  @override
  Future<String> createDataBackup(String userId) async {
    return await _dataSource.createDataBackup(userId);
  }

  @override
  Future<bool> restoreDataBackup(String userId, String backupUrl) async {
    return await _dataSource.restoreDataBackup(userId, backupUrl);
  }

  @override
  Future<bool> deleteAllUserData(String userId) async {
    return await _dataSource.deleteAllUserData(userId);
  }

  @override
  Future<String> exportUserData(String userId) async {
    return await _dataSource.exportUserData(userId);
  }

  // System Settings Methods

  @override
  Future<Map<String, dynamic>> getSystemSettings() async {
    return await _dataSource.getSystemSettings();
  }

  @override
  Future<bool> updateSystemSetting(
      String key, dynamic value, String adminUserId) async {
    return await _dataSource.updateSystemSetting(key, value, adminUserId);
  }
}
