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

  /// Kullanıcı profil fotoğrafı URL'si
  final String? profileImageUrl;

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

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    this.phone,
    this.profileImageUrl,
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

  /// User'ı Firebase Firestore'a dönüştürür
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

  /// User'ı kopyalar ve belirtilen alanları günceller
  User copyWith({
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
    return User(
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
