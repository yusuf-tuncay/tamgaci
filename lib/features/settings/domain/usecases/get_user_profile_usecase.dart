import 'package:tamgaci/features/settings/domain/entities/user_profile.dart';
import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';

/// Kullanıcı profili getirme use case'i
class GetUserProfileUseCase {
  final SettingsRepository _repository;

  GetUserProfileUseCase(this._repository);

  /// Kullanıcı profilini getirir
  /// [userId]: Kullanıcı ID'si
  /// Returns: Kullanıcı profili veya null
  Future<UserProfile?> call(String userId) async {
    return await _repository.getUserProfile(userId);
  }

  /// UID ile kullanıcı profilini getirir
  /// [uid]: Firebase Auth UID
  /// Returns: Kullanıcı profili veya null
  Future<UserProfile?> getByUid(String uid) async {
    return await _repository.getUserProfileByUid(uid);
  }

  /// Email ile kullanıcı profilini getirir
  /// [email]: Email adresi
  /// Returns: Kullanıcı profili veya null
  Future<UserProfile?> getByEmail(String email) async {
    return await _repository.getUserProfileByEmail(email);
  }
}
