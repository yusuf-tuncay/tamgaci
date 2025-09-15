import 'package:tamgaci/features/auth/domain/entities/user.dart';
import 'package:tamgaci/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamgaci/core/errors/failures.dart';

/// Sign in use case
/// Kullanıcı giriş işlemi için use case
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  /// Kullanıcı giriş yapar
  /// [email] - Kullanıcı email adresi
  /// [password] - Kullanıcı şifresi
  /// Returns: User entity
  /// Throws: Failure if sign in fails
  Future<User> call(String email, String password) async {
    try {
      // Input validation
      if (email.isEmpty) {
        throw ValidationFailure('Email adresi boş olamaz');
      }
      if (password.isEmpty) {
        throw ValidationFailure('Şifre boş olamaz');
      }
      if (!_isValidEmail(email)) {
        throw ValidationFailure('Geçerli bir email adresi giriniz');
      }
      if (password.length < 6) {
        throw ValidationFailure('Şifre en az 6 karakter olmalıdır');
      }

      // Sign in
      final user = await _repository.signIn(email, password);
      return user;
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw AuthenticationFailure(
          'Giriş yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  /// Email formatını kontrol eder
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
