// ========== FIREBASE AUTH SERVICE ==========
// lib/core/services/firebase_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Authentication servisi
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mevcut kullanıcıyı al
  static User? get currentUser => _auth.currentUser;

  /// Kullanıcı durumu stream'i
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// E-posta ile kayıt ol
  static Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? companyName,
    String? phoneNumber,
  }) async {
    try {
      // Firebase Auth ile kullanıcı oluştur
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı profilini güncelle
      await userCredential.user?.updateDisplayName(fullName);

      // Tenant ID oluştur (şirket adından)
      final tenantId = companyName?.isNotEmpty == true
          ? companyName!
              .toLowerCase()
              .replaceAll(' ', '_')
              .replaceAll(RegExp(r'[^a-z0-9_]'), '')
          : 'default_tenant_${userCredential.user!.uid.substring(0, 8)}';

      // Firestore'da kullanıcı dokümanı oluştur
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'companyName': companyName ?? '',
        'phoneNumber': phoneNumber ?? '',
        'tenantId': tenantId, // Multi-tenant için tenantId ekle
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'user',
        'settings': {
          'theme': 'light',
          'language': 'tr',
          'currency': 'TRY',
          'timezone': 'Europe/Istanbul',
        },
      });

      // Tenant dokümanı oluştur
      await _firestore.collection('tenants').doc(tenantId).set({
        'id': tenantId,
        'name': companyName ?? 'Default Company',
        'ownerId': userCredential.user!.uid,
        'memberIds': [userCredential.user!.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// E-posta ile giriş yap
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Şifre sıfırlama e-postası gönder
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Çıkış yap
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Kullanıcı profilini güncelle
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Kullanıcı e-postasını güncelle
  static Future<void> updateUserEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);

      // Firestore'da da e-postayı güncelle
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Kullanıcı şifresini güncelle
  static Future<void> updateUserPassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Kullanıcı hesabını sil
  static Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Firestore'dan kullanıcı verilerini sil
        await _firestore.collection('users').doc(user.uid).delete();

        // Firebase Auth'dan kullanıcıyı sil
        await user.delete();
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Kullanıcı bilgilerini Firestore'dan al
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error getting user data', e);
      }
      return null;
    }
  }

  /// Kullanıcı ayarlarını güncelle
  static Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'settings': settings,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Kullanıcı ayarlarını al
  static Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        return data?['settings'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error getting user settings', e);
      }
      return null;
    }
  }

  /// E-posta doğrulama durumunu kontrol et
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// E-posta doğrulama e-postası gönder
  static Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Auth hatalarını Türkçe'ye çevir
  static String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Hatalı şifre girdiniz.';
        case 'email-already-in-use':
          return 'Bu e-posta adresi zaten kullanımda.';
        case 'weak-password':
          return 'Şifre çok zayıf. En az 6 karakter kullanın.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi.';
        case 'user-disabled':
          return 'Bu hesap devre dışı bırakılmış.';
        case 'too-many-requests':
          return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
        case 'operation-not-allowed':
          return 'Bu işlem şu anda desteklenmiyor.';
        case 'network-request-failed':
          return 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
        default:
          return 'Bir hata oluştu: ${error.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu.';
  }

  /// Kullanıcının oturum açıp açmadığını kontrol et
  static bool get isSignedIn => _auth.currentUser != null;

  /// Kullanıcı ID'sini al
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Kullanıcı e-postasını al
  static String? get currentUserEmail => _auth.currentUser?.email;

  /// Kullanıcı adını al
  static String? get currentUserDisplayName => _auth.currentUser?.displayName;

  /// Mevcut kullanıcı için tenantId oluştur (migration için)
  static Future<void> createTenantIdForCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;

      // Eğer tenantId zaten varsa, işlem yapma
      if (userData['tenantId'] != null) return;

      // Tenant ID oluştur
      final companyName = userData['companyName'] as String? ?? '';
      final tenantId = companyName.isNotEmpty
          ? companyName
              .toLowerCase()
              .replaceAll(' ', '_')
              .replaceAll(RegExp(r'[^a-z0-9_]'), '')
          : 'default_tenant_${user.uid.substring(0, 8)}';

      // Kullanıcı dokümanını güncelle
      await _firestore.collection('users').doc(user.uid).update({
        'tenantId': tenantId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Tenant dokümanı oluştur
      await _firestore.collection('tenants').doc(tenantId).set({
        'id': tenantId,
        'name': companyName.isNotEmpty ? companyName : 'Default Company',
        'ownerId': user.uid,
        'memberIds': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      AppLogger.info('Tenant ID created for user: $tenantId');
    } catch (e) {
      AppLogger.error('Error creating tenant ID for current user', e);
    }
  }
}
