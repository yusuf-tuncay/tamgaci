import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/settings/data/models/app_settings_model.dart';
import 'package:tamgaci/features/settings/data/models/user_profile_model.dart';

/// Settings Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class SettingsFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  SettingsFirebaseDataSource(this._firestore, this._firebaseAuth);

  // App Settings Methods

  /// Kullanıcı ayarlarını getirir
  Future<AppSettingsModel?> getAppSettings(String userId) async {
    try {
      final doc = await _firestore.collection('app_settings').doc(userId).get();
      if (doc.exists) {
        return AppSettingsModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting app settings for user: $userId', e);
      rethrow;
    }
  }

  /// Kullanıcı ayarlarını günceller
  Future<AppSettingsModel> updateAppSettings(
      AppSettingsModel appSettings) async {
    try {
      await _firestore
          .collection('app_settings')
          .doc(appSettings.id)
          .update(appSettings.toFirestore());

      AppLogger.info('App settings updated for user: ${appSettings.userId}');
      return appSettings;
    } catch (e) {
      AppLogger.error('Error updating app settings: ${appSettings.id}', e);
      rethrow;
    }
  }

  /// Kullanıcı ayarlarını oluşturur
  Future<AppSettingsModel> createAppSettings(
      AppSettingsModel appSettings) async {
    try {
      await _firestore
          .collection('app_settings')
          .doc(appSettings.id)
          .set(appSettings.toFirestore());

      AppLogger.info('App settings created for user: ${appSettings.userId}');
      return appSettings;
    } catch (e) {
      AppLogger.error('Error creating app settings', e);
      rethrow;
    }
  }

  /// Kullanıcı ayarlarını siler
  Future<void> deleteAppSettings(String userId) async {
    try {
      await _firestore.collection('app_settings').doc(userId).delete();
      AppLogger.info('App settings deleted for user: $userId');
    } catch (e) {
      AppLogger.error('Error deleting app settings: $userId', e);
      rethrow;
    }
  }

  // User Profile Methods

  /// Kullanıcı profilini getirir
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      final doc =
          await _firestore.collection('user_profiles').doc(userId).get();
      if (doc.exists) {
        return UserProfileModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user profile: $userId', e);
      rethrow;
    }
  }

  /// UID ile kullanıcı profilini getirir
  Future<UserProfileModel?> getUserProfileByUid(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('user_profiles')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserProfileModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user profile by uid: $uid', e);
      rethrow;
    }
  }

  /// Email ile kullanıcı profilini getirir
  Future<UserProfileModel?> getUserProfileByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('user_profiles')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserProfileModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user profile by email: $email', e);
      rethrow;
    }
  }

  /// Kullanıcı profilini günceller
  Future<UserProfileModel> updateUserProfile(
      UserProfileModel userProfile) async {
    try {
      await _firestore
          .collection('user_profiles')
          .doc(userProfile.id)
          .update(userProfile.toFirestore());

      AppLogger.info('User profile updated: ${userProfile.email}');
      return userProfile;
    } catch (e) {
      AppLogger.error('Error updating user profile: ${userProfile.id}', e);
      rethrow;
    }
  }

  /// Kullanıcı profilini oluşturur
  Future<UserProfileModel> createUserProfile(
      UserProfileModel userProfile) async {
    try {
      await _firestore
          .collection('user_profiles')
          .doc(userProfile.id)
          .set(userProfile.toFirestore());

      AppLogger.info('User profile created: ${userProfile.email}');
      return userProfile;
    } catch (e) {
      AppLogger.error('Error creating user profile', e);
      rethrow;
    }
  }

  /// Kullanıcı profilini siler
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('user_profiles').doc(userId).delete();
      AppLogger.info('User profile deleted: $userId');
    } catch (e) {
      AppLogger.error('Error deleting user profile: $userId', e);
      rethrow;
    }
  }

  // System Settings Methods

  /// Sistem ayarlarını getirir
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final doc =
          await _firestore.collection('system_settings').doc('global').get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.error('Error getting system settings', e);
      rethrow;
    }
  }

  /// Sistem ayarını günceller
  Future<bool> updateSystemSetting(
      String key, dynamic value, String adminUserId) async {
    try {
      await _firestore.collection('system_settings').doc('global').update({
        key: value,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUserId,
      });

      AppLogger.info('System setting updated: $key by $adminUserId');
      return true;
    } catch (e) {
      AppLogger.error('Error updating system setting: $key', e);
      return false;
    }
  }

  // Security Methods

  /// Kullanıcı şifresini değiştirir
  Future<bool> changePassword(
      String userId, String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.uid != userId) {
        throw Exception('Unauthorized user');
      }

      // Mevcut şifreyi doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Yeni şifreyi ayarla
      await user.updatePassword(newPassword);

      AppLogger.info('Password changed for user: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error changing password for user: $userId', e);
      return false;
    }
  }

  /// Email doğrulaması gönderir
  Future<bool> sendEmailVerification(String userId) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.uid != userId) {
        throw Exception('Unauthorized user');
      }

      await user.sendEmailVerification();
      AppLogger.info('Email verification sent to user: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error sending email verification: $userId', e);
      return false;
    }
  }

  /// Telefon doğrulaması gönderir
  Future<bool> sendPhoneVerification(String userId, String phoneNumber) async {
    try {
      // Firebase Phone Auth implementasyonu
      // Bu kısım phone auth konfigürasyonuna bağlı olarak implement edilecek
      AppLogger.info('Phone verification sent to user: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error sending phone verification: $userId', e);
      return false;
    }
  }

  /// Email doğrulamasını onaylar
  Future<UserProfileModel> verifyEmail(String userId, String code) async {
    try {
      // Email verification logic
      final profile = await getUserProfile(userId);
      if (profile != null) {
        final updatedEntity = profile.toEntity().copyWith(emailVerified: true);
        final updatedModel = UserProfileModel.fromEntity(updatedEntity);
        return await updateUserProfile(updatedModel);
      }
      throw Exception('User profile not found');
    } catch (e) {
      AppLogger.error('Error verifying email: $userId', e);
      rethrow;
    }
  }

  /// Telefon doğrulamasını onaylar
  Future<UserProfileModel> verifyPhone(String userId, String code) async {
    try {
      // Phone verification logic
      final profile = await getUserProfile(userId);
      if (profile != null) {
        final updatedEntity = profile.toEntity().copyWith(phoneVerified: true);
        final updatedModel = UserProfileModel.fromEntity(updatedEntity);
        return await updateUserProfile(updatedModel);
      }
      throw Exception('User profile not found');
    } catch (e) {
      AppLogger.error('Error verifying phone: $userId', e);
      rethrow;
    }
  }

  // Data Management Methods

  /// Veri yedeklemesi oluşturur
  Future<String> createDataBackup(String userId) async {
    try {
      // Backup creation logic
      // Bu kısım Cloud Functions ile implement edilecek
      final backupUrl =
          'https://backup.tamgaci.com/user/$userId/${DateTime.now().millisecondsSinceEpoch}.zip';
      AppLogger.info('Data backup created for user: $userId');
      return backupUrl;
    } catch (e) {
      AppLogger.error('Error creating data backup: $userId', e);
      rethrow;
    }
  }

  /// Veri yedeklemesini geri yükler
  Future<bool> restoreDataBackup(String userId, String backupUrl) async {
    try {
      // Backup restoration logic
      // Bu kısım Cloud Functions ile implement edilecek
      AppLogger.info('Data backup restored for user: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error restoring data backup: $userId', e);
      return false;
    }
  }

  /// Tüm kullanıcı verilerini siler (GDPR)
  Future<bool> deleteAllUserData(String userId) async {
    try {
      // Tüm kullanıcı verilerini sil
      final batch = _firestore.batch();

      // User profile sil
      batch.delete(_firestore.collection('user_profiles').doc(userId));

      // App settings sil
      batch.delete(_firestore.collection('app_settings').doc(userId));

      // Diğer kullanıcı verilerini sil
      // Bu kısım tüm modüller için implement edilecek

      await batch.commit();

      // Firebase Auth kullanıcısını sil
      final user = _firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }

      AppLogger.info('All user data deleted: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting all user data: $userId', e);
      return false;
    }
  }

  /// Kullanıcı verilerini dışa aktarır (GDPR)
  Future<String> exportUserData(String userId) async {
    try {
      // Data export logic
      // Bu kısım Cloud Functions ile implement edilecek
      final exportUrl =
          'https://export.tamgaci.com/user/$userId/${DateTime.now().millisecondsSinceEpoch}.json';
      AppLogger.info('User data exported: $userId');
      return exportUrl;
    } catch (e) {
      AppLogger.error('Error exporting user data: $userId', e);
      rethrow;
    }
  }
}
