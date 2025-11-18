import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tamgaci/features/auth/data/models/user_model.dart';
import 'package:tamgaci/features/auth/domain/entities/user.dart';
import 'package:tamgaci/core/errors/failures.dart';
import 'package:tamgaci/features/accounts/data/services/account_initialization_service.dart';

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
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthFirebaseDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
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

      // Firestore'dan kullanıcı bilgilerini getir (izin yoksa Auth bilgileri ile fallback)
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          // Son giriş tarihini güncelle (best-effort)
          _updateLastLogin(credential.user!.uid);
          return userModel;
        }
      } catch (_) {
        // ignore and fallback to auth data
      }

      // Fallback: yalnızca Auth bilgisinden UserModel üret
      final fb = credential.user!;
      return UserModel(
        id: fb.uid,
        email: fb.email ?? '',
        name: fb.displayName?.split(' ').firstOrNull ?? '',
        surname: fb.displayName != null && fb.displayName!.contains(' ')
            ? fb.displayName!.split(' ').skip(1).join(' ')
            : '',
        phone: fb.phoneNumber,
        phoneE164: fb.phoneNumber,
        phoneCountry: null,
        phoneDialCode: null,
        role: UserRole.user,
        status: UserStatus.active,
        createdAt: fb.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: fb.emailVerified,
        isTwoFactorEnabled: false,
        taxId: null,
        taxOffice: null,
        billingAddress: null,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthenticationFailure(
          'Giriş yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp(
      String email, String password, String name, String surname) async {
    firebase_auth.UserCredential? credential;
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthenticationFailure('Kayıt olunamadı');
      }

      // Tenant ID oluştur (şirket adından veya default)
      final tenantId = 'default_tenant_${credential.user!.uid.substring(0, 8)}';

      // Firestore'da kullanıcı bilgilerini oluştur (best-effort)
      final now = DateTime.now();
      final trialEnd = DateTime(now.year, now.month + 1, now.day);
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        surname: surname,
        phone: null,
        phoneE164: null,
        phoneCountry: null,
        phoneDialCode: null,
        role: UserRole.user,
        status: UserStatus.active,
        tenantId: tenantId, // Otomatik oluşturulan tenantId
        createdAt: now,
        updatedAt: now,
        isEmailVerified: false,
        isTwoFactorEnabled: false,
        taxId: null,
        taxOffice: null,
        billingAddress: null,
        subscriptionStatus: SubscriptionStatus.trial,
        subscriptionPlan: SubscriptionPlan.none,
        trialStartAt: now,
        trialEndAt: trialEnd,
        subscriptionStartAt: null,
        subscriptionEndAt: null,
      );

      try {
        // Kullanıcı dokümanını oluştur
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());

        // Tenant dokümanını oluştur
        await _firestore.collection('tenants').doc(tenantId).set({
          'id': tenantId,
          'name': 'Default Company',
          'ownerId': credential.user!.uid,
          'memberIds': [credential.user!.uid],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        // Varsayılan hesapları oluştur (best-effort, hata olsa bile kayıt devam eder)
        try {
          final accountService = AccountInitializationService();
          await accountService.initializeDefaultAccounts();
          debugPrint('✅ Varsayılan hesaplar oluşturuldu');
        } catch (e) {
          debugPrint('⚠️ Varsayılan hesaplar oluşturulamadı (kayıt devam ediyor): $e');
        }
      } on FirebaseException catch (_) {
        // Firestore izni yoksa kayıt Auth tarafında tamamlanmıştır.
      }

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      // Firestore permission veya diğer hatalarda, Auth kullanıcı oluşturulduysa fallback dön
      if (credential?.user != null) {
        final fb = credential!.user!;
        final now = DateTime.now();
        final trialEnd = DateTime(now.year, now.month + 1, now.day);
        return UserModel(
          id: fb.uid,
          email: email,
          name: name,
          surname: surname,
          phone: fb.phoneNumber,
          phoneE164: fb.phoneNumber,
          phoneCountry: null,
          phoneDialCode: null,
          role: UserRole.user,
          status: UserStatus.active,
          createdAt: fb.metadata.creationTime ?? now,
          updatedAt: now,
          isEmailVerified: fb.emailVerified,
          isTwoFactorEnabled: false,
          taxId: null,
          taxOffice: null,
          billingAddress: null,
          subscriptionStatus: SubscriptionStatus.trial,
          subscriptionPlan: SubscriptionPlan.none,
          trialStartAt: now,
          trialEndAt: trialEnd,
          subscriptionStartAt: null,
          subscriptionEndAt: null,
        );
      }
      throw AuthenticationFailure(
          'Kayıt olurken bir hata oluştu: ${e.message ?? e.code}');
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

      // Best practice: Use cache with fallback to server
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get(const GetOptions(source: Source.cache))
          .catchError((_) => _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get(const GetOptions(source: Source.server)));

      if (!userDoc.exists) {
        // Best practice: Create user document if missing but Auth user exists
        return await _createMissingUserDocument(firebaseUser);
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseException catch (e) {
      throw AuthenticationFailure(
          'Firebase kullanıcı verisi alınamadı: ${e.message ?? e.code}');
    } catch (e) {
      throw AuthenticationFailure(
          'Kullanıcı bilgileri alınırken hata: ${e.toString()}');
    }
  }

  /// Create missing user document from Firebase Auth data
  Future<UserModel> _createMissingUserDocument(
      firebase_auth.User firebaseUser) async {
    final now = DateTime.now();
    final trialEnd = DateTime(now.year, now.month + 1, now.day);

    // Tenant ID oluştur
    final tenantId = 'default_tenant_${firebaseUser.uid.substring(0, 8)}';

    final userModel = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName?.split(' ').first ?? 'Kullanıcı',
      surname: firebaseUser.displayName?.contains(' ') == true
          ? firebaseUser.displayName!.split(' ').skip(1).join(' ')
          : '',
      phone: firebaseUser.phoneNumber,
      phoneE164: firebaseUser.phoneNumber,
      phoneCountry: null,
      phoneDialCode: null,
      role: UserRole.user,
      status: UserStatus.active,
      tenantId: tenantId, // Otomatik oluşturulan tenantId
      createdAt: firebaseUser.metadata.creationTime ?? now,
      updatedAt: now,
      isEmailVerified: firebaseUser.emailVerified,
      isTwoFactorEnabled: false,
      taxId: null,
      taxOffice: null,
      billingAddress: null,
      subscriptionStatus: SubscriptionStatus.trial,
      subscriptionPlan: SubscriptionPlan.none,
      trialStartAt: now,
      trialEndAt: trialEnd,
      subscriptionStartAt: null,
      subscriptionEndAt: null,
    );

    try {
      // Kullanıcı dokümanını oluştur
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toFirestore());

      // Tenant dokümanını oluştur
      await _firestore.collection('tenants').doc(tenantId).set({
        'id': tenantId,
        'name': 'Default Company',
        'ownerId': firebaseUser.uid,
        'memberIds': [firebaseUser.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Varsayılan hesapları oluştur (best-effort, hata olsa bile işlem devam eder)
      try {
        final accountService = AccountInitializationService();
        await accountService.initializeDefaultAccounts();
        debugPrint('✅ Varsayılan hesaplar oluşturuldu');
      } catch (e) {
        debugPrint('⚠️ Varsayılan hesaplar oluşturulamadı: $e');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to create missing user document: $e');
    }

    return userModel;
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
    } on firebase_auth.FirebaseAuthException catch (e) {
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
    } on firebase_auth.FirebaseAuthException catch (e) {
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
      // Best practice: Use batch writes for atomic updates
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(user.id);

      // Update only mutable/profile fields to comply with common security rules
      final Map<String, dynamic> updates = {
        'name': user.name,
        'surname': user.surname,
        'phone': user.phone,
        'phoneE164': user.phoneE164,
        'phoneCountry': user.phoneCountry,
        'phoneDialCode': user.phoneDialCode,
        'settings': user.settings,
        // Best practice: Profile image with path + metadata
        'profileImageUrl': user.profileImageUrl, // Cache for performance
        'profileImagePath': user.profileImagePath,
        'profileImageMetadata': user.profileImageMetadata,
        // Company name at root level for easy access
        'companyName': user.settings?['companyName'],
        'businessName': user.settings?['businessName'], // Alternative field
        'company': user.settings?['companyName'], // Backward compatibility
        // Persist registration fields captured on register page
        'taxId': user.taxId,
        'taxOffice': user.taxOffice,
        'billingAddress': user.billingAddress,
        // Subscription fields
        'subscriptionStatus': user.subscriptionStatus.value,
        'subscriptionPlan': user.subscriptionPlan.value,
        'trialStartAt': user.trialStartAt != null
            ? Timestamp.fromDate(user.trialStartAt!)
            : null,
        'trialEndAt': user.trialEndAt != null
            ? Timestamp.fromDate(user.trialEndAt!)
            : null,
        'subscriptionStartAt': user.subscriptionStartAt != null
            ? Timestamp.fromDate(user.subscriptionStartAt!)
            : null,
        'subscriptionEndAt': user.subscriptionEndAt != null
            ? Timestamp.fromDate(user.subscriptionEndAt!)
            : null,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // Add debug logging for company data
      final companyName = user.settings?['companyName'];
      debugPrint(
          '💾 Firestore Update - Company: $companyName, ProfileURL: ${user.profileImageUrl}');

      // Remove null values to avoid overwriting with nulls
      updates.removeWhere((key, value) => value == null);

      // Best practice: Use merge option to avoid overwriting entire document
      batch.set(userRef, updates, SetOptions(merge: true));

      // Execute batch operation
      await batch.commit();
    } on FirebaseException catch (e) {
      throw AuthenticationFailure(
          'Kullanıcı profili güncellenirken Firebase hatası: ${e.message ?? e.code}');
    } catch (e) {
      throw AuthenticationFailure(
          'Kullanıcı güncellenirken beklenmeyen hata: ${e.toString()}');
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
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Yeni şifreyi ayarla
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
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
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Firestore'dan kullanıcı bilgilerini sil
      await _firestore.collection('users').doc(user.uid).delete();

      // Firebase Auth'dan kullanıcıyı sil
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
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
        // Kullanıcı token'ını yenile
        await firebaseUser.reload();
        final refreshedUser = _firebaseAuth.currentUser;

        if (refreshedUser == null) {
          return null;
        }

        final userDoc =
            await _firestore.collection('users').doc(refreshedUser.uid).get();

        if (!userDoc.exists) {
          return null;
        }

        return UserModel.fromFirestore(userDoc);
      } catch (e) {
        // Auth hatası durumunda null döndür
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
  /// Best practice: Non-blocking background update with retry
  Future<void> _updateLastLogin(String userId) async {
    // Fire and forget approach - don't block user flow
    _performBackgroundUpdate(() async {
      try {
        final now = DateTime.now();
        await _firestore.collection('users').doc(userId).set({
          'lastLoginAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        }, SetOptions(merge: true));
      } catch (e) {
        // Log error but don't throw - non-critical operation
        debugPrint('⚠️ Failed to update last login time: $e');
      }
    });
  }

  /// Perform background update with timeout
  Future<void> _performBackgroundUpdate(
      Future<void> Function() operation) async {
    try {
      await operation().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ Background update timed out');
        },
      );
    } catch (e) {
      debugPrint('⚠️ Background update failed: $e');
    }
  }

  /// Firebase Auth exception'larını handle eder
  Failure _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
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
