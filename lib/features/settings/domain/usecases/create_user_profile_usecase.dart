import 'package:tamgaci/features/settings/domain/entities/user_profile.dart';
import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';

/// Kullanıcı profili oluşturma use case'i
class CreateUserProfileUseCase {
  final SettingsRepository _repository;

  CreateUserProfileUseCase(this._repository);

  /// Yeni kullanıcı profili oluşturur
  /// [userProfile]: Oluşturulacak kullanıcı profili
  /// Returns: Oluşturulan kullanıcı profili
  Future<UserProfile> call(UserProfile userProfile) async {
    final newProfile = userProfile.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createUserProfile(newProfile);
  }

  /// Firebase Auth bilgileriyle yeni kullanıcı profili oluşturur
  /// [uid]: Firebase Auth UID
  /// [email]: Email adresi
  /// [displayName]: Görünen ad (opsiyonel)
  /// [photoUrl]: Profil fotoğrafı URL'si (opsiyonel)
  /// Returns: Oluşturulan kullanıcı profili
  Future<UserProfile> createFromAuth({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    final now = DateTime.now();

    final profile = UserProfile(
      id: uid, // ID olarak UID kullanıyoruz
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.createUserProfile(profile);
  }
}
