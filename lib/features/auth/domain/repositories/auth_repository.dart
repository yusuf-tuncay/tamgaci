import 'package:tamgaci/features/auth/domain/entities/user.dart';

/// Auth repository interface
/// Authentication işlemleri için repository pattern
abstract class AuthRepository {
  /// Kullanıcı giriş yapar
  /// [email] - Kullanıcı email adresi
  /// [password] - Kullanıcı şifresi
  /// Returns: User entity
  Future<User> signIn(String email, String password);

  /// Kullanıcı kayıt olur
  /// [email] - Kullanıcı email adresi
  /// [password] - Kullanıcı şifresi
  /// [name] - Kullanıcı adı
  /// [surname] - Kullanıcı soyadı
  /// Returns: User entity
  Future<User> signUp(
      String email, String password, String name, String surname);

  /// Kullanıcı çıkış yapar
  Future<void> signOut();

  /// Mevcut kullanıcıyı getirir
  /// Returns: User entity veya null
  Future<User?> getCurrentUser();

  /// Kullanıcının giriş yapıp yapmadığını kontrol eder
  /// Returns: true eğer kullanıcı giriş yapmışsa
  Future<bool> isSignedIn();

  /// Şifre sıfırlama emaili gönderir
  /// [email] - Kullanıcı email adresi
  Future<void> resetPassword(String email);

  /// Email doğrulama linki gönderir
  /// [email] - Kullanıcı email adresi
  Future<void> sendEmailVerification(String email);

  /// Email doğrulama durumunu kontrol eder
  /// Returns: true eğer email doğrulanmışsa
  Future<bool> isEmailVerified();

  /// Kullanıcı profilini günceller
  /// [user] - Güncellenecek kullanıcı
  Future<void> updateUser(User user);

  /// Kullanıcı şifresini değiştirir
  /// [currentPassword] - Mevcut şifre
  /// [newPassword] - Yeni şifre
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Kullanıcı hesabını siler
  /// [password] - Kullanıcı şifresi (doğrulama için)
  Future<void> deleteAccount(String password);

  /// İki faktörlü kimlik doğrulamayı etkinleştirir
  Future<void> enableTwoFactorAuth();

  /// İki faktörlü kimlik doğrulamayı devre dışı bırakır
  Future<void> disableTwoFactorAuth();

  /// İki faktörlü kimlik doğrulama kodunu doğrular
  /// [code] - Doğrulama kodu
  /// Returns: true eğer kod doğruysa
  Future<bool> verifyTwoFactorCode(String code);

  /// Kullanıcı oturum durumunu kontrol eder
  /// Returns: Stream<User?> - Kullanıcı durumu değişikliklerini dinler
  Stream<User?> get authStateChanges;

  /// Kullanıcı ID token'ını getirir
  /// Returns: String - ID token
  Future<String> getIdToken();

  /// Kullanıcı ID token'ını yeniler
  /// Returns: String - Yeni ID token
  Future<String> refreshIdToken();
}
