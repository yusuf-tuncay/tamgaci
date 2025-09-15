import 'package:tamgaci/features/settings/domain/entities/user_profile.dart';
import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';

/// Kullanıcı profili güncelleme use case'i
class UpdateUserProfileUseCase {
  final SettingsRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  /// Kullanıcı profilini günceller
  /// [userProfile]: Güncellenecek kullanıcı profili
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> call(UserProfile userProfile) async {
    final updatedProfile = userProfile.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateUserProfile(updatedProfile);
  }

  /// Kullanıcı profil fotoğrafını günceller
  /// [userId]: Kullanıcı ID'si
  /// [photoUrl]: Yeni fotoğraf URL'si
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateProfilePhoto(String userId, String photoUrl) async {
    return await _repository.updateProfilePhoto(userId, photoUrl);
  }

  /// İki faktörlü kimlik doğrulamayı etkinleştirir/devre dışı bırakır
  /// [userId]: Kullanıcı ID'si
  /// [enabled]: Etkin durumu
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateTwoFactorAuth(String userId, bool enabled) async {
    return await _repository.updateTwoFactorAuth(userId, enabled);
  }

  /// Email doğrulamasını onaylar
  /// [userId]: Kullanıcı ID'si
  /// [code]: Doğrulama kodu
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> verifyEmail(String userId, String code) async {
    return await _repository.verifyEmail(userId, code);
  }

  /// Telefon doğrulamasını onaylar
  /// [userId]: Kullanıcı ID'si
  /// [code]: Doğrulama kodu
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> verifyPhone(String userId, String code) async {
    return await _repository.verifyPhone(userId, code);
  }

  /// Kullanıcı izinlerini günceller
  /// [userId]: Kullanıcı ID'si
  /// [permissions]: Yeni izinler
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updatePermissions(
      String userId, List<String> permissions) async {
    return await _repository.updateUserPermissions(userId, permissions);
  }

  /// Kullanıcı rolünü günceller
  /// [userId]: Kullanıcı ID'si
  /// [role]: Yeni rol
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateRole(String userId, UserRole role) async {
    return await _repository.updateUserRole(userId, role);
  }

  /// Kullanıcı durumunu günceller
  /// [userId]: Kullanıcı ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateStatus(String userId, UserStatus status) async {
    return await _repository.updateUserStatus(userId, status);
  }

  /// Son giriş bilgilerini günceller
  /// [userId]: Kullanıcı ID'si
  /// [loginTime]: Giriş zamanı
  /// [ipAddress]: IP adresi
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updateLastLogin(
      String userId, DateTime loginTime, String ipAddress) async {
    return await _repository.updateLastLogin(userId, loginTime, ipAddress);
  }

  /// Kullanıcı tercihlerini günceller
  /// [userId]: Kullanıcı ID'si
  /// [preferences]: Yeni tercihler
  /// Returns: Güncellenmiş kullanıcı profili
  Future<UserProfile> updatePreferences(
      String userId, Map<String, dynamic> preferences) async {
    return await _repository.updateUserPreferences(userId, preferences);
  }
}
