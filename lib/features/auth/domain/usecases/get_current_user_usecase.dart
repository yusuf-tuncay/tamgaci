import 'package:tamgaci/features/auth/domain/entities/user.dart';
import 'package:tamgaci/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamgaci/core/errors/failures.dart';

/// Get current user use case
/// Mevcut kullanıcıyı getirme işlemi için use case
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// Mevcut kullanıcıyı getirir
  /// Returns: User entity veya null
  /// Throws: Failure if get current user fails
  Future<User?> call() async {
    try {
      return await _repository.getCurrentUser();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw AuthenticationFailure(
          'Kullanıcı bilgileri alınırken bir hata oluştu: ${e.toString()}');
    }
  }
}
