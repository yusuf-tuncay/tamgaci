import 'package:tamgaci/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamgaci/core/errors/failures.dart';

/// Reset password use case
/// Şifre sıfırlama işlemi için use case
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  /// Şifre sıfırlama emaili gönderir
  /// [email] - Kullanıcı email adresi
  /// Throws: Failure if reset password fails
  Future<void> call(String email) async {
    try {
      // Input validation
      if (email.isEmpty) {
        throw ValidationFailure('Email adresi boş olamaz');
      }
      if (!_isValidEmail(email)) {
        throw ValidationFailure('Geçerli bir email adresi giriniz');
      }

      await _repository.resetPassword(email);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw AuthenticationFailure(
          'Şifre sıfırlama emaili gönderilirken bir hata oluştu: ${e.toString()}');
    }
  }

  /// Email formatını kontrol eder
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
