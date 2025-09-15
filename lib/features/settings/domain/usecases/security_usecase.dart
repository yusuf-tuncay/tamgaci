import 'package:tamgaci/features/settings/domain/repositories/settings_repository.dart';

/// Güvenlik işlemleri use case'i
class SecurityUseCase {
  final SettingsRepository _repository;

  SecurityUseCase(this._repository);

  /// Kullanıcı şifresini değiştirir
  /// [userId]: Kullanıcı ID'si
  /// [currentPassword]: Mevcut şifre
  /// [newPassword]: Yeni şifre
  /// Returns: İşlem başarılı mı
  Future<bool> changePassword(
      String userId, String currentPassword, String newPassword) async {
    return await _repository.changePassword(
        userId, currentPassword, newPassword);
  }

  /// Email doğrulaması gönderir
  /// [userId]: Kullanıcı ID'si
  /// Returns: İşlem başarılı mı
  Future<bool> sendEmailVerification(String userId) async {
    return await _repository.sendEmailVerification(userId);
  }

  /// Telefon doğrulaması gönderir
  /// [userId]: Kullanıcı ID'si
  /// [phoneNumber]: Telefon numarası
  /// Returns: İşlem başarılı mı
  Future<bool> sendPhoneVerification(String userId, String phoneNumber) async {
    return await _repository.sendPhoneVerification(userId, phoneNumber);
  }
}
