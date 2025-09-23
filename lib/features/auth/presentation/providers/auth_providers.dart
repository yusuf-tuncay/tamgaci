import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/auth/domain/entities/user.dart';
import 'package:tamgaci/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamgaci/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tamgaci/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:tamgaci/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:tamgaci/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:tamgaci/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:tamgaci/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tamgaci/features/auth/domain/usecases/reset_password_usecase.dart';

// ========== DEPENDENCY INJECTION ==========

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

/// Firebase Firestore instance provider
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Auth Firebase datasource provider
final authFirebaseDataSourceProvider = Provider<AuthFirebaseDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AuthFirebaseDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authFirebaseDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
});

/// Use cases providers
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

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
  String? get userId => user?.id;

  /// Kullanıcı e-postasını al
  String? get userEmail => user?.email;

  /// Kullanıcı adını al
  String? get userDisplayName => user?.fullName;
}

// ========== AUTH NOTIFIER ==========

/// Auth durumunu yöneten Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _initializeAuthState();
  }

  /// Auth state'i başlat
  void _initializeAuthState() {
    // Firebase Auth durumu değişikliklerini dinle
    _authStateSubscription = _repository.authStateChanges.listen(
      (User? user) {
        state = state.copyWith(
          user: user,
          isEmailVerified: user?.isEmailVerified ?? false,
          error: null,
        );
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// E-posta ile giriş yap
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.signIn(email, password);
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

  /// E-posta ile kayıt ol
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.signUp(email, password, name, surname);
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

      await _repository.resetPassword(email);
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

      await _repository.signOut();
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
  Future<void> updateUserProfile(User user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.updateUser(user);

      // ✅ CRITICAL: Update local state with new user data
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Kullanıcı şifresini güncelle
  Future<void> updateUserPassword(
      String currentPassword, String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.changePassword(currentPassword, newPassword);
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
  Future<void> deleteUserAccount(String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.deleteAccount(password);
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

      final user = state.user;
      if (user != null) {
        await _repository.sendEmailVerification(user.email);
      }
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
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
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
