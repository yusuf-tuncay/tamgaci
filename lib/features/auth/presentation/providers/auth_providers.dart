// ========== AUTH PROVIDERS ==========
// lib/features/auth/presentation/providers/auth_providers.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_auth_service.dart';

// ========== AUTH STATE ==========

/// Auth durumu
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isEmailVerified;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isEmailVerified = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isEmailVerified,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  /// Kullanıcının oturum açıp açmadığını kontrol et
  bool get isSignedIn => user != null;

  /// Kullanıcı ID'sini al
  String? get userId => user?.uid;

  /// Kullanıcı e-postasını al
  String? get userEmail => user?.email;

  /// Kullanıcı adını al
  String? get userDisplayName => user?.displayName;
}

// ========== AUTH NOTIFIER ==========

/// Auth durumunu yöneten Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    // Firebase Auth durumu değişikliklerini dinle
    _authStateSubscription = FirebaseAuthService.authStateChanges.listen(
      (User? user) {
        state = state.copyWith(
          user: user,
          isEmailVerified: user?.emailVerified ?? false,
          error: null,
        );
      },
    );
  }

  StreamSubscription<User?>? _authStateSubscription;

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// E-posta ile kayıt ol
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? companyName,
    String? phoneNumber,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        companyName: companyName,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// E-posta ile giriş yap
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Şifre sıfırlama e-postası gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.sendPasswordResetEmail(email);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.signOut();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Kullanıcı profilini güncelle
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Kullanıcı e-postasını güncelle
  Future<void> updateUserEmail(String newEmail) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.updateUserEmail(newEmail);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Kullanıcı şifresini güncelle
  Future<void> updateUserPassword(String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.updateUserPassword(newPassword);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Kullanıcı hesabını sil
  Future<void> deleteUserAccount() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.deleteUserAccount();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// E-posta doğrulama e-postası gönder
  Future<void> sendEmailVerification() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await FirebaseAuthService.sendEmailVerification();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Loading durumunu güncelle
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

// ========== PROVIDERS ==========

/// Auth provider'ı
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Mevcut kullanıcı provider'ı
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Kullanıcının oturum açıp açmadığını kontrol eden provider
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isSignedIn;
});

/// Loading durumu provider'ı
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Hata mesajı provider'ı
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

/// E-posta doğrulama durumu provider'ı
final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isEmailVerified;
});

/// Kullanıcı ID provider'ı
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});

/// Kullanıcı e-posta provider'ı
final userEmailProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userEmail;
});

/// Kullanıcı adı provider'ı
final userDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userDisplayName;
});
