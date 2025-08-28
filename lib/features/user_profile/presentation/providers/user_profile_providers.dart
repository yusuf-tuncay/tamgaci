// ========== USER PROFILE PROVIDERS ==========
// lib/features/user_profile/presentation/providers/user_profile_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/repositories/user_profile_repository_impl.dart';

/// User profile repository provider
final userProfileRepositoryProvider = Provider<UserProfileRepositoryImpl>((ref) {
  return UserProfileRepositoryImpl();
});

/// User profile state notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final UserProfileRepositoryImpl _repository;
  static const String _defaultUserId = 'default_user';

  UserProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  /// Profil verilerini yükle
  Future<void> _loadProfile() async {
    try {
      state = const AsyncValue.loading();
      final profile = await _repository.getUserProfile(_defaultUserId);
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Profil bilgilerini güncelle
  Future<void> updateProfile(UserProfile profile) async {
    try {
      state = const AsyncValue.loading();
      await _repository.updateUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Profil fotoğrafını yükle
  Future<void> uploadProfilePhoto(String filePath) async {
    try {
      final currentProfile = state.value;
      if (currentProfile == null) return;

      final photoUrl = await _repository.uploadProfilePhoto(
        currentProfile.id,
        filePath,
      );

      final updatedProfile = currentProfile.copyWith(
        profilePhotoUrl: photoUrl,
        updatedAt: DateTime.now(),
      );

      await _repository.updateUserProfile(updatedProfile);
      state = AsyncValue.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Profil fotoğrafını sil
  Future<void> deleteProfilePhoto() async {
    try {
      final currentProfile = state.value;
      if (currentProfile == null) return;

      await _repository.deleteProfilePhoto(currentProfile.id);

      final updatedProfile = currentProfile.copyWith(
        profilePhotoUrl: null,
        updatedAt: DateTime.now(),
      );

      state = AsyncValue.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// E-posta benzersizlik kontrolü
  Future<bool> isEmailUnique(String email) async {
    try {
      final currentProfile = state.value;
      return await _repository.isEmailUnique(
        email,
        excludeUserId: currentProfile?.id,
      );
    } catch (error) {
      return false;
    }
  }

  /// Telefon benzersizlik kontrolü
  Future<bool> isPhoneUnique(String phone) async {
    try {
      final currentProfile = state.value;
      return await _repository.isPhoneUnique(
        phone,
        excludeUserId: currentProfile?.id,
      );
    } catch (error) {
      return false;
    }
  }

  /// Profili yenile
  Future<void> refreshProfile() async {
    await _loadProfile();
  }
}

/// User profile provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UserProfileNotifier(repository);
});

/// Kullanıcı adı provider
final userNameProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.fullName,
    loading: () => 'Kullanıcı',
    error: (_, __) => 'Kullanıcı',
  );
});

/// Kullanıcı e-posta provider
final userEmailProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.email,
    loading: () => 'kullanici@tamgaci.com',
    error: (_, __) => 'kullanici@tamgaci.com',
  );
});

/// Kullanıcı şirket provider
final userCompanyProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.company ?? 'Tamgaci',
    loading: () => 'Tamgaci',
    error: (_, __) => 'Tamgaci',
  );
});

/// Kullanıcı rol provider
final userRoleProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.role,
    loading: () => 'Kullanıcı',
    error: (_, __) => 'Kullanıcı',
  );
});

/// Kullanıcı profil fotoğrafı provider
final userProfilePhotoProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.profilePhotoUrl,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Kullanıcı baş harfleri provider
final userInitialsProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.initials,
    loading: () => 'KU',
    error: (_, __) => 'KU',
  );
});
