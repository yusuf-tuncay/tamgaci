// ========== CUSTOMER BRANCH ENTITY ==========
// lib/features/customers/domain/entities/customer_branch.dart

/// Müşteri şube bilgisi entity'si
class CustomerBranch {
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

  /// Aktif/Pasif durumu
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const CustomerBranch({
    required this.id,
    required this.name,
    required this.address,
    this.branchCode,
    this.phone,
    this.email,
    this.manager,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  CustomerBranch copyWith({
    String? id,
    String? name,
    String? address,
    String? branchCode,
    String? phone,
    String? email,
    String? manager,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerBranch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      branchCode: branchCode ?? this.branchCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      manager: manager ?? this.manager,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan CustomerBranch oluştur
  factory CustomerBranch.fromJson(Map<String, dynamic> json) {
    return CustomerBranch(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      branchCode: json['branchCode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      manager: json['manager'] as String?,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// CustomerBranch'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'branchCode': branchCode,
      'phone': phone,
      'email': email,
      'manager': manager,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CustomerBranch(id: $id, name: $name, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerBranch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
