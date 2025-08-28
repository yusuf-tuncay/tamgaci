// ========== USER PROFILE REPOSITORY INTERFACE ==========
// lib/features/user_profile/domain/repositories/user_profile_repository.dart

import '../entities/user_profile.dart';

/// Kullanıcı profil repository abstract sınıfı
abstract class UserProfileRepository {
  /// Kullanıcı profilini getir
  Future<UserProfile> getUserProfile(String userId);

  /// Kullanıcı profilini kaydet
  Future<void> saveUserProfile(UserProfile profile);

  /// Kullanıcı profilini güncelle
  Future<void> updateUserProfile(UserProfile profile);

  /// Profil fotoğrafını yükle
  Future<String> uploadProfilePhoto(String userId, String filePath);

  /// Profil fotoğrafını sil
  Future<void> deleteProfilePhoto(String userId);

  /// E-posta adresinin benzersiz olup olmadığını kontrol et
  Future<bool> isEmailUnique(String email, {String? excludeUserId});

  /// Telefon numarasının benzersiz olup olmadığını kontrol et
  Future<bool> isPhoneUnique(String phone, {String? excludeUserId});

  /// Varsayılan kullanıcı profilini oluştur
  Future<UserProfile> createDefaultProfile(String userId);
}
