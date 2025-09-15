import 'package:tamgaci/features/auth/domain/entities/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// User model sınıfı
/// Firebase Firestore ile uyumlu user veri modeli
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.surname,
    super.phone,
    super.profileImageUrl,
    required super.role,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.lastLoginAt,
    required super.isEmailVerified,
    required super.isTwoFactorEnabled,
    super.companyId,
    super.department,
    super.position,
    super.preferences,
    super.settings,
  });

  /// Firebase Firestore'dan UserModel oluşturur
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      phone: data['phone'],
      profileImageUrl: data['profileImageUrl'],
      role: UserRole.fromString(data['role'] ?? 'user'),
      status: UserStatus.fromString(data['status'] ?? 'active'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isEmailVerified: data['isEmailVerified'] ?? false,
      isTwoFactorEnabled: data['isTwoFactorEnabled'] ?? false,
      companyId: data['companyId'],
      department: data['department'],
      position: data['position'],
      preferences: data['preferences'] != null
          ? Map<String, dynamic>.from(data['preferences'])
          : null,
      settings: data['settings'] != null
          ? Map<String, dynamic>.from(data['settings'])
          : null,
    );
  }

  /// UserModel'ı Firebase Firestore'a dönüştürür
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'role': role.value,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isEmailVerified': isEmailVerified,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'companyId': companyId,
      'department': department,
      'position': position,
      'preferences': preferences,
      'settings': settings,
    };
  }

  /// UserModel'ı User entity'ye dönüştürür
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      surname: surname,
      phone: phone,
      profileImageUrl: profileImageUrl,
      role: role,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
      isEmailVerified: isEmailVerified,
      isTwoFactorEnabled: isTwoFactorEnabled,
      companyId: companyId,
      department: department,
      position: position,
      preferences: preferences,
      settings: settings,
    );
  }

  /// User entity'den UserModel oluşturur
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      surname: user.surname,
      phone: user.phone,
      profileImageUrl: user.profileImageUrl,
      role: user.role,
      status: user.status,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLoginAt: user.lastLoginAt,
      isEmailVerified: user.isEmailVerified,
      isTwoFactorEnabled: user.isTwoFactorEnabled,
      companyId: user.companyId,
      department: user.department,
      position: user.position,
      preferences: user.preferences,
      settings: user.settings,
    );
  }

  /// UserModel'ı kopyalar ve belirtilen alanları günceller
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? surname,
    String? phone,
    String? profileImageUrl,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isTwoFactorEnabled,
    String? companyId,
    String? department,
    String? position,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      companyId: companyId ?? this.companyId,
      department: department ?? this.department,
      position: position ?? this.position,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
    );
  }
}
