// ========== USER PROFILE PROVIDERS ==========
// lib/features/user_profile/presentation/providers/user_profile_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../../../core/services/firebase/firebase_auth_service.dart';

/// User profile repository provider
final userProfileRepositoryProvider =
    Provider<UserProfileRepositoryImpl>((ref) {
  return UserProfileRepositoryImpl();
});

/// User profile state notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final UserProfileRepositoryImpl _repository;
  static const String _defaultUserId = 'default_user';

  UserProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadProfile();
    // Auth değişimlerini dinle ve profili yenile
    FirebaseAuthService.authStateChanges.listen((_) {
      _loadProfile();
    });
  }

  /// Profil verilerini yükle
  Future<void> _loadProfile() async {
    try {
      state = const AsyncValue.loading();

      // 1) Firebase oturum açık ise Firestore'dan çek
      final uid = FirebaseAuthService.currentUserId;
      if (uid != null) {
        final data = await FirebaseAuthService.getUserData(uid);
        if (data != null) {
          // Get name and surname
          final String firstName = (data['name'] as String?) ?? '';
          final String lastName = (data['surname'] as String?) ?? '';

          // Fallback to fullName if name/surname not available
          String name = firstName;
          String surname = lastName;

          if (name.isEmpty && surname.isEmpty) {
            final String fullName = (data['fullName'] as String?)?.trim() ??
                FirebaseAuthService.currentUserDisplayName ??
                '';
            final parts = fullName.trim().split(' ');
            name = parts.isNotEmpty ? parts.first : 'Kullanıcı';
            surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';
          }

          final String email = (data['email'] as String?) ??
              (FirebaseAuthService.currentUserEmail ?? 'kullanici@tamgaci.com');
          final Map<String, dynamic>? settings =
              data['settings'] as Map<String, dynamic>?;
          // Get company name from multiple possible sources
          String? company = data['companyName'] as String?;
          if (company == null || company.isEmpty) {
            company = data['company'] as String?;
          }
          if (company == null || company.isEmpty) {
            company = settings?['companyName'] as String?;
          }
          if (company == null || company.isEmpty) {
            // Try to get from billing or business info
            company = data['businessName'] as String?;
          }

          // Get profile photo URL with comprehensive fallback logic
          String? profilePhotoUrl = data['profileImageUrl'] as String?;

          // Check settings for profile image URL as backup
          if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
            profilePhotoUrl = settings?['profileImageUrl'] as String?;
          }

          // Check alternative field names
          if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
            profilePhotoUrl = data['photoURL'] as String?;
          }
          if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
            profilePhotoUrl = data['profileImageURL'] as String?;
          }

          debugPrint(
              '🔍 UserProfile Loading - Company: $company, PhotoURL: $profilePhotoUrl');

          final String? phone = data['phone'] as String?;
          final String? position = data['position'] as String?;
          final String? department = data['department'] as String?;

          final now = DateTime.now();
          final user = UserProfile(
            id: uid,
            name: name.isEmpty ? 'Kullanıcı' : name,
            surname: surname,
            email: email,
            company: company,
            phone: phone,
            position: position,
            department: department,
            profilePhotoUrl: profilePhotoUrl,
            role: (data['role'] as String?) ?? 'Kullanıcı',
            isActive: (data['isActive'] as bool?) ?? true,
            createdAt: (data['createdAt'] != null)
                ? (data['createdAt'] as Timestamp).toDate()
                : now,
            updatedAt: (data['updatedAt'] != null)
                ? (data['updatedAt'] as Timestamp).toDate()
                : now,
          );
          state = AsyncValue.data(user);
          return;
        }
      }

      // 2) Firebase yoksa yerel repository'den default al
      final profile = await _repository.getUserProfile(uid ?? _defaultUserId);
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
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
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
