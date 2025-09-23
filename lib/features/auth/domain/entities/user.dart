import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı entity sınıfı
/// Firebase Firestore ile uyumlu kullanıcı veri modeli
class User extends Equatable {
  /// Kullanıcı ID'si (Firebase UID)
  final String id;

  /// Kullanıcı email adresi
  final String email;

  /// Kullanıcı adı
  final String name;

  /// Kullanıcı soyadı
  final String surname;

  /// Kullanıcı telefon numarası
  final String? phone;

  /// E164 formatında tam telefon numarası (+905551234567)
  final String? phoneE164;

  /// Ülke ISO kodu (TR, US ...)
  final String? phoneCountry;

  /// Ülke alan kodu (+90, +1 ...)
  final String? phoneDialCode;

  /// Kullanıcı profil fotoğrafı URL'si (cache for performance)
  final String? profileImageUrl;

  /// Kullanıcı profil fotoğrafı path'i (reliable storage path)
  final String? profileImagePath;

  /// Kullanıcı profil fotoğrafı metadata'sı (upload info, file size, etc.)
  final Map<String, dynamic>? profileImageMetadata;

  /// Kullanıcı rolü (admin, user, manager)
  final UserRole role;

  /// Kullanıcı durumu (active, inactive, suspended)
  final UserStatus status;

  /// Kullanıcı oluşturulma tarihi
  final DateTime createdAt;

  /// Kullanıcı güncellenme tarihi
  final DateTime updatedAt;

  /// Son giriş tarihi
  final DateTime? lastLoginAt;

  /// Email doğrulama durumu
  final bool isEmailVerified;

  /// İki faktörlü kimlik doğrulama durumu
  final bool isTwoFactorEnabled;

  /// Kullanıcı şirket ID'si
  final String? companyId;

  /// Kullanıcı departmanı
  final String? department;

  /// Kullanıcı pozisyonu
  final String? position;

  /// Kullanıcı tercihleri
  final Map<String, dynamic>? preferences;

  /// Kullanıcı ayarları
  final Map<String, dynamic>? settings;

  /// Vergi Kimlik Numarası (TCKN/VKN)
  final String? taxId;

  /// Vergi Dairesi
  final String? taxOffice;

  /// Fatura/İş Adresi
  final String? billingAddress;

  /// Abonelik durumu
  final SubscriptionStatus subscriptionStatus;

  /// Abonelik planı
  final SubscriptionPlan subscriptionPlan;

  /// Deneme başlangıç tarihi
  final DateTime? trialStartAt;

  /// Deneme bitiş tarihi
  final DateTime? trialEndAt;

  /// Abonelik başlangıç tarihi
  final DateTime? subscriptionStartAt;

  /// Abonelik bitiş tarihi
  final DateTime? subscriptionEndAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    this.phone,
    this.phoneE164,
    this.phoneCountry,
    this.phoneDialCode,
    this.profileImageUrl,
    this.profileImagePath,
    this.profileImageMetadata,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    required this.isEmailVerified,
    required this.isTwoFactorEnabled,
    this.companyId,
    this.department,
    this.position,
    this.preferences,
    this.settings,
    this.taxId,
    this.taxOffice,
    this.billingAddress,
    this.subscriptionStatus = SubscriptionStatus.none,
    this.subscriptionPlan = SubscriptionPlan.none,
    this.trialStartAt,
    this.trialEndAt,
    this.subscriptionStartAt,
    this.subscriptionEndAt,
  });

  /// Firebase Firestore'dan User oluşturur
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      phone: data['phone'],
      phoneE164: data['phoneE164'],
      phoneCountry: data['phoneCountry'],
      phoneDialCode: data['phoneDialCode'],
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

  /// User'ı Firebase Firestore'a dönüştürür
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

  /// User'ı kopyalar ve belirtilen alanları günceller
  User copyWith({
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
    return User(
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

  /// Kullanıcının tam adını döndürür
  String get fullName => '$name $surname';

  /// Kullanıcının admin olup olmadığını kontrol eder
  bool get isAdmin => role == UserRole.admin;

  /// Kullanıcının aktif olup olmadığını kontrol eder
  bool get isActive => status == UserStatus.active;

  /// Kullanıcının giriş yapıp yapmadığını kontrol eder
  bool get isLoggedIn => lastLoginAt != null;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        surname,
        phone,
        profileImageUrl,
        profileImagePath,
        profileImageMetadata,
        role,
        status,
        createdAt,
        updatedAt,
        lastLoginAt,
        isEmailVerified,
        isTwoFactorEnabled,
        companyId,
        department,
        position,
        preferences,
        settings,
        taxId,
        taxOffice,
        billingAddress,
        subscriptionStatus,
        subscriptionPlan,
        trialStartAt,
        trialEndAt,
        subscriptionStartAt,
        subscriptionEndAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, surname: $surname, role: $role, status: $status)';
  }
}

/// Kullanıcı rolleri enum'u
enum UserRole {
  admin('admin'),
  manager('manager'),
  user('user');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.user;
    }
  }
}

/// Kullanıcı durumları enum'u
enum UserStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended');

  const UserStatus(this.value);
  final String value;

  static UserStatus fromString(String value) {
    switch (value) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      default:
        return UserStatus.active;
    }
  }
}

/// Abonelik durumu enum'u
enum SubscriptionStatus {
  none('none'),
  trial('trial'),
  active('active'),
  expired('expired');

  const SubscriptionStatus(this.value);
  final String value;

  static SubscriptionStatus fromString(String value) {
    switch (value) {
      case 'trial':
        return SubscriptionStatus.trial;
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'none':
      default:
        return SubscriptionStatus.none;
    }
  }
}

/// Abonelik planı enum'u
enum SubscriptionPlan {
  none('none'),
  monthly('monthly'),
  semiAnnual('semi_annual'),
  annual('annual');

  const SubscriptionPlan(this.value);
  final String value;

  static SubscriptionPlan fromString(String value) {
    switch (value) {
      case 'monthly':
        return SubscriptionPlan.monthly;
      case 'semi_annual':
        return SubscriptionPlan.semiAnnual;
      case 'annual':
        return SubscriptionPlan.annual;
      case 'none':
      default:
        return SubscriptionPlan.none;
    }
  }
}
