// ========== USER PROFILE ENTITY ==========
// lib/features/user_profile/domain/entities/user_profile.dart

/// Kullanıcı profil entity'si
class UserProfile {
  /// Kullanıcı ID'si
  final String id;

  /// Kullanıcının adı
  final String name;

  /// Kullanıcının soyadı
  final String surname;

  /// Kullanıcının e-posta adresi
  final String email;

  /// Kullanıcının telefon numarası
  final String? phone;

  /// Kullanıcının pozisyonu
  final String? position;

  /// Kullanıcının departmanı
  final String? department;

  /// Kullanıcının şirketi
  final String? company;

  /// Kullanıcının profil fotoğrafı URL'si
  final String? profilePhotoUrl;

  /// Kullanıcının rolü
  final String role;

  /// Kullanıcının aktif olup olmadığı
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    this.phone,
    this.position,
    this.department,
    this.company,
    this.profilePhotoUrl,
    this.role = 'Kullanıcı',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tam ad getter'ı
  String get fullName => '$name $surname'.trim();

  /// Baş harfler getter'ı (profil fotoğrafı için)
  String get initials {
    final nameInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final surnameInitial = surname.isNotEmpty ? surname[0].toUpperCase() : '';
    return '$nameInitial$surnameInitial';
  }

  /// Kopyalama metodu
  UserProfile copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? phone,
    String? position,
    String? department,
    String? company,
    String? profilePhotoUrl,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      department: department ?? this.department,
      company: company ?? this.company,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.surname == surname &&
        other.email == email &&
        other.phone == phone &&
        other.position == position &&
        other.department == department &&
        other.company == company &&
        other.profilePhotoUrl == profilePhotoUrl &&
        other.role == role &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      surname,
      email,
      phone,
      position,
      department,
      company,
      profilePhotoUrl,
      role,
      isActive,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, surname: $surname, email: $email, fullName: $fullName)';
  }
}
