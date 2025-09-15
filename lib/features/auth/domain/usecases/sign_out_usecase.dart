import 'package:tamgaci/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamgaci/core/errors/failures.dart';

/// Sign out use case
/// Kullanıcı çıkış işlemi için use case
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  /// Kullanıcı çıkış yapar
  /// Throws: Failure if sign out fails
  Future<void> call() async {
    try {
      await _repository.signOut();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw AuthenticationFailure(
          'Çıkış yapılırken bir hata oluştu: ${e.toString()}');
    }
  }
}
