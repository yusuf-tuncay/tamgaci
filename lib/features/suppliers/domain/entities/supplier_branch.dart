// ========== SUPPLIER BRANCH ENTITY ==========
// lib/features/suppliers/domain/entities/supplier_branch.dart

/// Tedarikçi şube bilgisi entity'si
class SupplierBranch {
  /// Şube benzersiz ID'si
  final String id;

  /// Şube adı
  final String name;

  /// Şube adresi
  final String address;

  /// Şube kodu
  final String? branchCode;

  /// Şube telefonu
  final String? phone;

  /// Şube e-postası
  final String? email;

  /// Şube sorumlusu
  final String? manager;

  /// Şube şehri
  final String? city;

  /// Şube ülkesi
  final String? country;

  /// Posta kodu
  final String? postalCode;

  /// Aktif/Pasif durumu
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  /// Oluşturan kullanıcı
  final String createdBy;

  /// Güncelleyen kullanıcı
  final String? updatedBy;

  const SupplierBranch({
    required this.id,
    required this.name,
    required this.address,
    this.branchCode,
    this.phone,
    this.email,
    this.manager,
    this.city,
    this.country,
    this.postalCode,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  SupplierBranch copyWith({
    String? id,
    String? name,
    String? address,
    String? branchCode,
    String? phone,
    String? email,
    String? manager,
    String? city,
    String? country,
    String? postalCode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return SupplierBranch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      branchCode: branchCode ?? this.branchCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      manager: manager ?? this.manager,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan SupplierBranch oluştur
  factory SupplierBranch.fromJson(Map<String, dynamic> json) {
    return SupplierBranch(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      branchCode: json['branchCode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      manager: json['manager'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// SupplierBranch'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'branchCode': branchCode,
      'phone': phone,
      'email': email,
      'manager': manager,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Tam adres
  String get fullAddress {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Görünen ad
  String get displayName {
    if (branchCode != null && branchCode!.isNotEmpty) {
      return '$name ($branchCode)';
    }
    return name;
  }

  @override
  String toString() {
    return 'SupplierBranch(id: $id, name: $name, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierBranch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
