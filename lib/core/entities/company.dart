// ========== COMPANY ENTITY ==========
// lib/core/entities/company.dart

class Company {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? settings;
  final String? logoUrl;
  final String? website;
  final String? phone;
  final String? email;
  final String? address;

  Company({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.settings,
    this.logoUrl,
    this.website,
    this.phone,
    this.email,
    this.address,
  });

  Company copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? settings,
    String? logoUrl,
    String? website,
    String? phone,
    String? email,
    String? address,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'settings': settings,
      'logoUrl': logoUrl,
      'website': website,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      settings: json['settings'] as Map<String, dynamic>?,
      logoUrl: json['logoUrl'] as String?,
      website: json['website'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
    );
  }

  @override
  String toString() {
    return 'Company(id: $id, name: $name, ownerId: $ownerId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Company && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
