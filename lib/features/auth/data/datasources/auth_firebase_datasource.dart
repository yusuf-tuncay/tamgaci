import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/auth/data/models/user_model.dart';
import 'package:tamgaci/features/auth/domain/entities/user.dart';
import 'package:tamgaci/core/errors/failures.dart';

/// Auth Firebase datasource
/// Firebase Authentication ve Firestore işlemleri için datasource
abstract class AuthFirebaseDataSource {
  /// Kullanıcı giriş yapar
  Future<UserModel> signIn(String email, String password);

  /// Kullanıcı kayıt olur
  Future<UserModel> signUp(
      String email, String password, String name, String surname);

  /// Kullanıcı çıkış yapar
  Future<void> signOut();

  /// Mevcut kullanıcıyı getirir
  Future<UserModel?> getCurrentUser();

  /// Kullanıcının giriş yapıp yapmadığını kontrol eder
  Future<bool> isSignedIn();

  /// Şifre sıfırlama emaili gönderir
  Future<void> resetPassword(String email);

  /// Email doğrulama linki gönderir
  Future<void> sendEmailVerification(String email);

  /// Email doğrulama durumunu kontrol eder
  Future<bool> isEmailVerified();

  /// Kullanıcı profilini günceller
  Future<void> updateUser(UserModel user);

  /// Kullanıcı şifresini değiştirir
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Kullanıcı hesabını siler
  Future<void> deleteAccount(String password);

  /// İki faktörlü kimlik doğrulamayı etkinleştirir
  Future<void> enableTwoFactorAuth();

  /// İki faktörlü kimlik doğrulamayı devre dışı bırakır
  Future<void> disableTwoFactorAuth();

  /// İki faktörlü kimlik doğrulama kodunu doğrular
  Future<bool> verifyTwoFactorCode(String code);

  /// Kullanıcı oturum durumunu kontrol eder
  Stream<UserModel?> get authStateChanges;

  /// Kullanıcı ID token'ını getirir
  Future<String> getIdToken();

  /// Kullanıcı ID token'ını yeniler
  Future<String> refreshIdToken();
}

/// Auth Firebase datasource implementasyonu
class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthFirebaseDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthenticationFailure('Giriş yapılamadı');
      }

      // Firestore'dan kullanıcı bilgilerini getir
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        throw AuthenticationFailure('Kullanıcı bilgileri bulunamadı');
      }

      final userModel = UserModel.fromFirestore(userDoc);

      // Son giriş tarihini güncelle
      await _updateLastLogin(credential.user!.uid);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthenticationFailure(
          'Giriş yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp(
      String email, String password, String name, String surname) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthenticationFailure('Kayıt olunamadı');
      }

      // Firestore'da kullanıcı bilgilerini oluştur
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        surname: surname,
        role: UserRole.user,
        status: UserStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: false,
        isTwoFactorEnabled: false,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthenticationFailure(
          'Kayıt olurken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthenticationFailure(
          'Çıkış yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw AuthenticationFailure(
          'Kullanıcı bilgileri alınırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      throw AuthenticationFailure(
          'Giriş durumu kontrol edilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthenticationFailure(
          'Şifre sıfırlama emaili gönderilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification(String email) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure('Kullanıcı bulunamadı');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthenticationFailure(
          'Email doğrulama linki gönderilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      return user?.emailVerified ?? false;
    } catch (e) {
      throw AuthenticationFailure(
          'Email doğrulama durumu kontrol edilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw AuthenticationFailure(
          'Kullanıcı güncellenirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure('Kullanıcı bulunamadı');
      }

      // Mevcut şifreyi doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Yeni şifreyi ayarla
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthenticationFailure(
          'Şifre değiştirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure('Kullanıcı bulunamadı');
      }

      // Şifreyi doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Firestore'dan kullanıcı bilgilerini sil
      await _firestore.collection('users').doc(user.uid).delete();

      // Firebase Auth'dan kullanıcıyı sil
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthenticationFailure(
          'Hesap silinirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> enableTwoFactorAuth() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure('Kullanıcı bulunamadı');
      }

      // TODO: Implement two-factor authentication
      // Bu özellik Firebase Auth'da doğrudan desteklenmiyor
      // Üçüncü parti çözümler kullanılmalı
      throw AuthenticationFailure(
          'İki faktörlü kimlik doğrulama henüz desteklenmiyor');
    } catch (e) {
      if (e is AuthenticationFailure) {
        rethrow;
      }
      throw AuthenticationFailure(
          'İki faktörlü kimlik doğrulama etkinleştirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> disableTwoFactorAuth() async {
    try {
      // TODO: Implement two-factor authentication
      throw AuthenticationFailure(
          'İki faktörlü kimlik doğrulama henüz desteklenmiyor');
    } catch (e) {
      if (e is AuthenticationFailure) {
        rethrow;
      }
      throw AuthenticationFailure(
          'İki faktörlü kimlik doğrulama devre dışı bırakılırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyTwoFactorCode(String code) async {
    try {
      // TODO: Implement two-factor authentication
      throw AuthenticationFailure(
          'İki faktörlü kimlik doğrulama henüz desteklenmiyor');
    } catch (e) {
      if (e is AuthenticationFailure) {
        rethrow;
      }
      throw AuthenticationFailure(
          'İki faktörlü kimlik doğrulama kodu doğrulanırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (!userDoc.exists) {
          return null;
        }

        return UserModel.fromFirestore(userDoc);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<String> getIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure('Kullanıcı bulunamadı');
      }
      final token = await user.getIdToken();
      if (token == null) {
        throw AuthenticationFailure('ID token alınamadı');
      }
      return token;
    } catch (e) {
      throw AuthenticationFailure(
          'ID token alınırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<String> refreshIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure('Kullanıcı bulunamadı');
      }
      final token = await user.getIdToken(true);
      if (token == null) {
        throw AuthenticationFailure('ID token yenilenemedi');
      }
      return token;
    } catch (e) {
      throw AuthenticationFailure(
          'ID token yenilenirken bir hata oluştu: ${e.toString()}');
    }
  }

  /// Son giriş tarihini günceller
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // Son giriş tarihi güncellenemezse hata fırlatma
      // Bu kritik bir işlem değil
    }
  }

  /// Firebase Auth exception'larını handle eder
  Failure _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthenticationFailure('Kullanıcı bulunamadı');
      case 'wrong-password':
        return AuthenticationFailure('Hatalı şifre');
      case 'email-already-in-use':
        return AuthenticationFailure('Bu email adresi zaten kullanılıyor');
      case 'weak-password':
        return AuthenticationFailure('Şifre çok zayıf');
      case 'invalid-email':
        return AuthenticationFailure('Geçersiz email adresi');
      case 'user-disabled':
        return AuthenticationFailure('Kullanıcı hesabı devre dışı bırakılmış');
      case 'too-many-requests':
        return AuthenticationFailure(
            'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin');
      case 'operation-not-allowed':
        return AuthenticationFailure('Bu işlem izin verilmiyor');
      case 'requires-recent-login':
        return AuthenticationFailure(
            'Bu işlem için tekrar giriş yapmanız gerekiyor');
      default:
        return AuthenticationFailure('Kimlik doğrulama hatası: ${e.message}');
    }
  }
}
