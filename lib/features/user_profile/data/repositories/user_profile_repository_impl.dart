// ========== USER PROFILE REPOSITORY IMPLEMENTATION ==========
// lib/features/user_profile/data/repositories/user_profile_repository_impl.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile.dart';

/// Kullanıcı profil repository implementation
class UserProfileRepositoryImpl implements UserProfileRepository {
  static const String _profilesKey = 'user_profiles';
  static const String _photoDirectory = 'profile_photos';

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString(_profilesKey);

    if (profilesJson != null) {
      final Map<String, dynamic> profilesMap = json.decode(profilesJson);
      if (profilesMap.containsKey(userId)) {
        return _fromJson(profilesMap[userId]);
      }
    }

    // Profil bulunamadıysa varsayılan profil oluştur
    return createDefaultProfile(userId);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString(_profilesKey);
    Map<String, dynamic> profilesMap = {};

    if (profilesJson != null) {
      profilesMap = json.decode(profilesJson);
    }

    profilesMap[profile.id] = _toJson(profile);
    await prefs.setString(_profilesKey, json.encode(profilesMap));
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await saveUserProfile(profile);
  }

  @override
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    try {
      if (kIsWeb) {
        // Web platformu için base64 formatında saklama
        final prefs = await SharedPreferences.getInstance();
        final photoKey = 'profile_photo_$userId';

        // Web için dosya yolu yerine base64 string kullan
        // Bu durumda filePath aslında base64 string olacak
        await prefs.setString(photoKey, filePath);

        return 'web_photo_$userId';
      } else {
        // Mobil platform için dosya sistemi kullan
        final appDir = await getApplicationDocumentsDirectory();
        final photoDir = Directory('${appDir.path}/$_photoDirectory');

        // Fotoğraf dizini yoksa oluştur
        if (!await photoDir.exists()) {
          await photoDir.create(recursive: true);
        }

        // Dosya adını oluştur
        final fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final targetPath = '${photoDir.path}/$fileName';

        // Dosyayı kopyala
        final sourceFile = File(filePath);
        final targetFile = await sourceFile.copy(targetPath);

        return targetFile.path;
      }
    } catch (e) {
      throw Exception('Profil fotoğrafı yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      if (profile.profilePhotoUrl != null) {
        if (kIsWeb) {
          // Web platformu için SharedPreferences'dan sil
          final prefs = await SharedPreferences.getInstance();
          final photoKey = 'profile_photo_$userId';
          await prefs.remove(photoKey);
        } else {
          // Mobil platform için dosyayı sil
          final file = File(profile.profilePhotoUrl!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Profilden fotoğraf URL'sini kaldır
        final updatedProfile = profile.copyWith(
          profilePhotoUrl: null,
          updatedAt: DateTime.now(),
        );
        await updateUserProfile(updatedProfile);
      }
    } catch (e) {
      throw Exception('Profil fotoğrafı silinirken hata oluştu: $e');
    }
  }

  @override
  Future<bool> isEmailUnique(String email, {String? excludeUserId}) async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString(_profilesKey);

    if (profilesJson != null) {
      final Map<String, dynamic> profilesMap = json.decode(profilesJson);

      for (final entry in profilesMap.entries) {
        final profileId = entry.key;
        final profileData = entry.value as Map<String, dynamic>;

        // Kendisi hariç aynı e-posta varsa false döndür
        if (profileId != excludeUserId && profileData['email'] == email) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  Future<bool> isPhoneUnique(String phone, {String? excludeUserId}) async {
    if (phone.isEmpty) {
      return true; // Boş telefon numarası benzersiz kabul edilir
    }

    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString(_profilesKey);

    if (profilesJson != null) {
      final Map<String, dynamic> profilesMap = json.decode(profilesJson);

      for (final entry in profilesMap.entries) {
        final profileId = entry.key;
        final profileData = entry.value as Map<String, dynamic>;

        // Kendisi hariç aynı telefon numarası varsa false döndür
        if (profileId != excludeUserId && profileData['phone'] == phone) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  Future<UserProfile> createDefaultProfile(String userId) async {
    final defaultProfile = UserProfile(
      id: userId,
      name: 'Kullanıcı',
      surname: '',
      email: 'kullanici@tamgaci.com',
      phone: null,
      position: null,
      department: null,
      company: null,
      profilePhotoUrl: null,
      role: 'Kullanıcı',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveUserProfile(defaultProfile);
    return defaultProfile;
  }

  // JSON dönüşüm metodları
  Map<String, dynamic> _toJson(UserProfile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'surname': profile.surname,
      'email': profile.email,
      'phone': profile.phone,
      'position': profile.position,
      'department': profile.department,
      'company': profile.company,
      'profilePhotoUrl': profile.profilePhotoUrl,
      'role': profile.role,
      'isActive': profile.isActive,
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
    };
  }

  UserProfile _fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      position: json['position'] as String?,
      department: json['department'] as String?,
      company: json['company'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      role: json['role'] as String? ?? 'Kullanıcı',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
