import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/settings/domain/entities/user_profile.dart';

/// UserProfile model for Firebase integration
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.uid,
    required super.email,
    super.displayName,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.photoUrl,
    super.role,
    super.status,
    super.companyName,
    super.department,
    super.position,
    super.address,
    super.city,
    super.country,
    super.postalCode,
    super.website,
    super.bio,
    super.dateOfBirth,
    super.permissions,
    super.preferences,
    super.lastLoginAt,
    super.lastLoginIp,
    super.emailVerified,
    super.phoneVerified,
    super.twoFactorEnabled,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  /// Firestore DocumentSnapshot'tan UserProfileModel oluşturur
  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfileModel(
      id: doc.id,
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.employee,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => UserStatus.active,
      ),
      companyName: data['companyName'] as String?,
      department: data['department'] as String?,
      position: data['position'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      country: data['country'] as String?,
      postalCode: data['postalCode'] as String?,
      website: data['website'] as String?,
      bio: data['bio'] as String?,
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      permissions: List<String>.from(data['permissions'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      lastLoginIp: data['lastLoginIp'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      twoFactorEnabled: data['twoFactorEnabled'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  /// UserProfileModel'i Firestore'a uygun Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
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
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'permissions': permissions,
      'preferences': preferences,
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'lastLoginIp': lastLoginIp,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'twoFactorEnabled': twoFactorEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// UserProfileModel'i UserProfile entity'sine dönüştürür
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      uid: uid,
      email: email,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      role: role,
      status: status,
      companyName: companyName,
      department: department,
      position: position,
      address: address,
      city: city,
      country: country,
      postalCode: postalCode,
      website: website,
      bio: bio,
      dateOfBirth: dateOfBirth,
      permissions: permissions,
      preferences: preferences,
      lastLoginAt: lastLoginAt,
      lastLoginIp: lastLoginIp,
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
      twoFactorEnabled: twoFactorEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// UserProfile entity'sinden UserProfileModel oluşturur
  factory UserProfileModel.fromEntity(UserProfile userProfile) {
    return UserProfileModel(
      id: userProfile.id,
      uid: userProfile.uid,
      email: userProfile.email,
      displayName: userProfile.displayName,
      firstName: userProfile.firstName,
      lastName: userProfile.lastName,
      phoneNumber: userProfile.phoneNumber,
      photoUrl: userProfile.photoUrl,
      role: userProfile.role,
      status: userProfile.status,
      companyName: userProfile.companyName,
      department: userProfile.department,
      position: userProfile.position,
      address: userProfile.address,
      city: userProfile.city,
      country: userProfile.country,
      postalCode: userProfile.postalCode,
      website: userProfile.website,
      bio: userProfile.bio,
      dateOfBirth: userProfile.dateOfBirth,
      permissions: userProfile.permissions,
      preferences: userProfile.preferences,
      lastLoginAt: userProfile.lastLoginAt,
      lastLoginIp: userProfile.lastLoginIp,
      emailVerified: userProfile.emailVerified,
      phoneVerified: userProfile.phoneVerified,
      twoFactorEnabled: userProfile.twoFactorEnabled,
      createdAt: userProfile.createdAt,
      updatedAt: userProfile.updatedAt,
      createdBy: userProfile.createdBy,
      updatedBy: userProfile.updatedBy,
    );
  }
}
