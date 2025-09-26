// ========== TENANT ENTITY ==========
// lib/core/entities/tenant.dart

class Tenant {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final List<String> memberIds;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? logoUrl;
  final String? website;
  final String? phone;
  final String? email;
  final String? address;
  final String? country;
  final String? timezone;
  final String? currency;
  final String? language;

  Tenant({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.memberIds = const [],
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.logoUrl,
    this.website,
    this.phone,
    this.email,
    this.address,
    this.country,
    this.timezone,
    this.currency = 'TRY',
    this.language = 'tr',
  });

  Tenant copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? memberIds,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? logoUrl,
    String? website,
    String? phone,
    String? email,
    String? address,
    String? country,
    String? timezone,
    String? currency,
    String? language,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'logoUrl': logoUrl,
      'website': website,
      'phone': phone,
      'email': email,
      'address': address,
      'country': country,
      'timezone': timezone,
      'currency': currency,
      'language': language,
    };
  }

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String,
      memberIds:
          json['memberIds'] != null ? List<String>.from(json['memberIds']) : [],
      settings: json['settings'] != null
          ? Map<String, dynamic>.from(json['settings'])
          : {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      logoUrl: json['logoUrl'] as String?,
      website: json['website'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String? ?? 'TRY',
      language: json['language'] as String? ?? 'tr',
    );
  }

  @override
  String toString() {
    return 'Tenant(id: $id, name: $name, ownerId: $ownerId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tenant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
