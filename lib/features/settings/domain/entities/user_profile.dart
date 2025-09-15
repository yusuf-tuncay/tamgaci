import 'package:equatable/equatable.dart';

/// Kullanıcı rolü
enum UserRole {
  admin('Yönetici'),
  manager('Müdür'),
  employee('Çalışan'),
  accountant('Muhasebeci'),
  viewer('Görüntüleyici');

  const UserRole(this.displayName);
  final String displayName;
}

/// Kullanıcı durumu
enum UserStatus {
  active('Aktif'),
  inactive('Pasif'),
  suspended('Askıya Alındı'),
  pending('Beklemede');

  const UserStatus(this.displayName);
  final String displayName;
}

/// Kullanıcı profili entity'si
class UserProfile extends Equatable {
  final String id;
  final String uid; // Firebase Auth UID
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? photoUrl;
  final UserRole role;
  final UserStatus status;
  final String? companyName;
  final String? department;
  final String? position;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? website;
  final String? bio;
  final DateTime? dateOfBirth;
  final List<String> permissions;
  final Map<String, dynamic> preferences;
  final DateTime? lastLoginAt;
  final String? lastLoginIp;
  final bool emailVerified;
  final bool phoneVerified;
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const UserProfile({
    required this.id,
    required this.uid,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.photoUrl,
    this.role = UserRole.employee,
    this.status = UserStatus.active,
    this.companyName,
    this.department,
    this.position,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.website,
    this.bio,
    this.dateOfBirth,
    this.permissions = const [],
    this.preferences = const {},
    this.lastLoginAt,
    this.lastLoginIp,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.twoFactorEnabled = false,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  UserProfile copyWith({
    String? id,
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    UserRole? role,
    UserStatus? status,
    String? companyName,
    String? department,
    String? position,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? website,
    String? bio,
    DateTime? dateOfBirth,
    List<String>? permissions,
    Map<String, dynamic>? preferences,
    DateTime? lastLoginAt,
    String? lastLoginIp,
    bool? emailVerified,
    bool? phoneVerified,
    bool? twoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return UserProfile(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      companyName: companyName ?? this.companyName,
      department: department ?? this.department,
      position: position ?? this.position,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      website: website ?? this.website,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      permissions: permissions ?? this.permissions,
      preferences: preferences ?? this.preferences,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastLoginIp: lastLoginIp ?? this.lastLoginIp,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (displayName != null) {
      return displayName!;
    } else {
      return email;
    }
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        return displayName![0].toUpperCase();
      }
    } else {
      return email[0].toUpperCase();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role.name,
      'status': status.name,
      'companyName': companyName,
      'department': department,
      'position': position,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'website': website,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'permissions': permissions,
      'preferences': preferences,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'lastLoginIp': lastLoginIp,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'twoFactorEnabled': twoFactorEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.employee,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      companyName: json['companyName'] as String?,
      department: json['department'] as String?,
      position: json['position'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      website: json['website'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      permissions: List<String>.from(json['permissions'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      lastLoginIp: json['lastLoginIp'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        email,
        displayName,
        firstName,
        lastName,
        phoneNumber,
        photoUrl,
        role,
        status,
        companyName,
        department,
        position,
        address,
        city,
        country,
        postalCode,
        website,
        bio,
        dateOfBirth,
        permissions,
        preferences,
        lastLoginAt,
        lastLoginIp,
        emailVerified,
        phoneVerified,
        twoFactorEnabled,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
