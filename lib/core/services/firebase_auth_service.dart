// ========== FIREBASE AUTH SERVICE ==========
// lib/core/services/firebase_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Authentication servisi
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Auth state değişikliklerini dinle
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Mevcut kullanıcı
  static User? get currentUser => _auth.currentUser;

  /// Email ve şifre ile kayıt ol
  static Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.info('User registered successfully: ${credential.user?.email}');
      return credential;
    } catch (e) {
      AppLogger.error('Registration failed', e);
      rethrow;
    }
  }

  /// Email ve şifre ile giriş yap
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.info('User signed in successfully: ${credential.user?.email}');
      return credential;
    } catch (e) {
      AppLogger.error('Sign in failed', e);
      rethrow;
    }
  }

  /// Şifre sıfırlama emaili gönder
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent to: $email');
    } catch (e) {
      AppLogger.error('Password reset email failed', e);
      rethrow;
    }
  }

  /// Çıkış yap
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      rethrow;
    }
  }

  /// Kullanıcı profilini güncelle
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        AppLogger.info('User profile updated successfully');
      }
    } catch (e) {
      AppLogger.error('Profile update failed', e);
      rethrow;
    }
  }

  /// Email adresini güncelle
  static Future<void> updateUserEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        AppLogger.info('User email updated successfully');
      }
    } catch (e) {
      AppLogger.error('Email update failed', e);
      rethrow;
    }
  }

  /// Şifreyi güncelle
  static Future<void> updateUserPassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        AppLogger.info('User password updated successfully');
      }
    } catch (e) {
      AppLogger.error('Password update failed', e);
      rethrow;
    }
  }

  /// Kullanıcı hesabını sil
  static Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        AppLogger.info('User account deleted successfully');
      }
    } catch (e) {
      AppLogger.error('Account deletion failed', e);
      rethrow;
    }
  }

  /// Email doğrulama gönder
  static Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        AppLogger.info('Email verification sent successfully');
      }
    } catch (e) {
      AppLogger.error('Email verification failed', e);
      rethrow;
    }
  }
}
