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
    super.phoneE164,
    super.phoneCountry,
    super.phoneDialCode,
    super.profileImageUrl,
    super.profileImagePath,
    super.profileImageMetadata,
    required super.role,
    required super.status,
    super.tenantId,
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
    super.taxId,
    super.taxOffice,
    super.billingAddress,
    super.subscriptionStatus = SubscriptionStatus.none,
    super.subscriptionPlan = SubscriptionPlan.none,
    super.trialStartAt,
    super.trialEndAt,
    super.subscriptionStartAt,
    super.subscriptionEndAt,
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
      phoneE164: data['phoneE164'],
      phoneCountry: data['phoneCountry'],
      phoneDialCode: data['phoneDialCode'],
      // Best practice: Profile image with path + metadata
      profileImageUrl: data['profileImageUrl'], // Cache for performance
      profileImagePath: data['profileImagePath'], // Path for reliability
      profileImageMetadata: data['profileImageMetadata'] != null
          ? Map<String, dynamic>.from(data['profileImageMetadata'])
          : null,
      role: UserRole.fromString(data['role'] ?? 'user'),
      status: UserStatus.fromString(data['status'] ?? 'active'),
      tenantId: data['tenantId'],
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
      taxId: data['taxId'],
      taxOffice: data['taxOffice'],
      billingAddress: data['billingAddress'],
      subscriptionStatus:
          SubscriptionStatus.fromString(data['subscriptionStatus'] ?? 'none'),
      subscriptionPlan:
          SubscriptionPlan.fromString(data['subscriptionPlan'] ?? 'none'),
      trialStartAt: (data['trialStartAt'] as Timestamp?)?.toDate(),
      trialEndAt: (data['trialEndAt'] as Timestamp?)?.toDate(),
      subscriptionStartAt:
          (data['subscriptionStartAt'] as Timestamp?)?.toDate(),
      subscriptionEndAt: (data['subscriptionEndAt'] as Timestamp?)?.toDate(),
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
      'phoneE164': phoneE164,
      'phoneCountry': phoneCountry,
      'phoneDialCode': phoneDialCode,
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
      'taxId': taxId,
      'taxOffice': taxOffice,
      'billingAddress': billingAddress,
      'subscriptionStatus': subscriptionStatus.value,
      'subscriptionPlan': subscriptionPlan.value,
      'trialStartAt':
          trialStartAt != null ? Timestamp.fromDate(trialStartAt!) : null,
      'trialEndAt': trialEndAt != null ? Timestamp.fromDate(trialEndAt!) : null,
      'subscriptionStartAt': subscriptionStartAt != null
          ? Timestamp.fromDate(subscriptionStartAt!)
          : null,
      'subscriptionEndAt': subscriptionEndAt != null
          ? Timestamp.fromDate(subscriptionEndAt!)
          : null,
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
      phoneE164: phoneE164,
      phoneCountry: phoneCountry,
      phoneDialCode: phoneDialCode,
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
      taxId: taxId,
      taxOffice: taxOffice,
      billingAddress: billingAddress,
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
      phoneE164: user.phoneE164,
      phoneCountry: user.phoneCountry,
      phoneDialCode: user.phoneDialCode,
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
      taxId: user.taxId,
      taxOffice: user.taxOffice,
      billingAddress: user.billingAddress,
      subscriptionStatus: user.subscriptionStatus,
      subscriptionPlan: user.subscriptionPlan,
      trialStartAt: user.trialStartAt,
      trialEndAt: user.trialEndAt,
      subscriptionStartAt: user.subscriptionStartAt,
      subscriptionEndAt: user.subscriptionEndAt,
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
    String? phoneE164,
    String? phoneCountry,
    String? phoneDialCode,
    String? profileImageUrl,
    String? profileImagePath,
    Map<String, dynamic>? profileImageMetadata,
    UserRole? role,
    UserStatus? status,
    String? tenantId,
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
    String? taxId,
    String? taxOffice,
    String? billingAddress,
    SubscriptionStatus? subscriptionStatus,
    SubscriptionPlan? subscriptionPlan,
    DateTime? trialStartAt,
    DateTime? trialEndAt,
    DateTime? subscriptionStartAt,
    DateTime? subscriptionEndAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      phoneE164: phoneE164 ?? this.phoneE164,
      phoneCountry: phoneCountry ?? this.phoneCountry,
      phoneDialCode: phoneDialCode ?? this.phoneDialCode,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      profileImageMetadata: profileImageMetadata ?? this.profileImageMetadata,
      role: role ?? this.role,
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
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
      taxId: taxId ?? this.taxId,
      taxOffice: taxOffice ?? this.taxOffice,
      billingAddress: billingAddress ?? this.billingAddress,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      trialStartAt: trialStartAt ?? this.trialStartAt,
      trialEndAt: trialEndAt ?? this.trialEndAt,
      subscriptionStartAt: subscriptionStartAt ?? this.subscriptionStartAt,
      subscriptionEndAt: subscriptionEndAt ?? this.subscriptionEndAt,
    );
  }
}
