import 'package:tamgaci/features/auth/domain/entities/user.dart';
import 'package:tamgaci/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamgaci/core/errors/failures.dart';

/// Sign up use case
/// Kullanıcı kayıt işlemi için use case
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  /// Kullanıcı kayıt olur
  /// [email] - Kullanıcı email adresi
  /// [password] - Kullanıcı şifresi
  /// [name] - Kullanıcı adı
  /// [surname] - Kullanıcı soyadı
  /// Returns: User entity
  /// Throws: Failure if sign up fails
  Future<User> call(
      String email, String password, String name, String surname) async {
    try {
      // Input validation
      if (email.isEmpty) {
        throw ValidationFailure('Email adresi boş olamaz');
      }
      if (password.isEmpty) {
        throw ValidationFailure('Şifre boş olamaz');
      }
      if (name.isEmpty) {
        throw ValidationFailure('Ad boş olamaz');
      }
      if (surname.isEmpty) {
        throw ValidationFailure('Soyad boş olamaz');
      }
      if (!_isValidEmail(email)) {
        throw ValidationFailure('Geçerli bir email adresi giriniz');
      }
      if (password.length < 6) {
        throw ValidationFailure('Şifre en az 6 karakter olmalıdır');
      }
      if (name.length < 2) {
        throw ValidationFailure('Ad en az 2 karakter olmalıdır');
      }
      if (surname.length < 2) {
        throw ValidationFailure('Soyad en az 2 karakter olmalıdır');
      }

      // Sign up
      final user = await _repository.signUp(email, password, name, surname);
      return user;
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw AuthenticationFailure(
          'Kayıt olurken bir hata oluştu: ${e.toString()}');
    }
  }

  /// Email formatını kontrol eder
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
