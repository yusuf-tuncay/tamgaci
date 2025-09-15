import 'package:tamgaci/features/auth/domain/entities/user.dart';
import 'package:tamgaci/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamgaci/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:tamgaci/features/auth/data/models/user_model.dart';

/// Auth repository implementasyonu
/// Firebase Authentication ve Firestore işlemleri için repository
class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _dataSource;

  AuthRepositoryImpl({
    required AuthFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<User> signIn(String email, String password) async {
    final userModel = await _dataSource.signIn(email, password);
    return userModel.toEntity();
  }

  @override
  Future<User> signUp(
      String email, String password, String name, String surname) async {
    final userModel = await _dataSource.signUp(email, password, name, surname);
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await _dataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<bool> isSignedIn() async {
    return await _dataSource.isSignedIn();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _dataSource.resetPassword(email);
  }

  @override
  Future<void> sendEmailVerification(String email) async {
    await _dataSource.sendEmailVerification(email);
  }

  @override
  Future<bool> isEmailVerified() async {
    return await _dataSource.isEmailVerified();
  }

  @override
  Future<void> updateUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await _dataSource.updateUser(userModel);
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _dataSource.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> deleteAccount(String password) async {
    await _dataSource.deleteAccount(password);
  }

  @override
  Future<void> enableTwoFactorAuth() async {
    await _dataSource.enableTwoFactorAuth();
  }

  @override
  Future<void> disableTwoFactorAuth() async {
    await _dataSource.disableTwoFactorAuth();
  }

  @override
  Future<bool> verifyTwoFactorCode(String code) async {
    return await _dataSource.verifyTwoFactorCode(code);
  }

  @override
  Stream<User?> get authStateChanges {
    return _dataSource.authStateChanges
        .map((userModel) => userModel?.toEntity());
  }

  @override
  Future<String> getIdToken() async {
    return await _dataSource.getIdToken();
  }

  @override
  Future<String> refreshIdToken() async {
    return await _dataSource.refreshIdToken();
  }
}
