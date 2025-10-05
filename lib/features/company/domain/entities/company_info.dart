/// Firma bilgileri entity
class CompanyInfo {
  final String id;
  final String? tenantId;
  final String? createdBy;
  final String name;
  final String? taxNumber;
  final String? taxOffice;
  final String? address;
  final String? city;
  final String? district;
  final String? postalCode;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CompanyInfo({
    required this.id,
    this.tenantId,
    this.createdBy,
    required this.name,
    this.taxNumber,
    this.taxOffice,
    this.address,
    this.city,
    this.district,
    this.postalCode,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String?,
      createdBy: json['createdBy'] as String?,
      name: json['name'] as String,
      taxNumber: json['taxNumber'] as String?,
      taxOffice: json['taxOffice'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      postalCode: json['postalCode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'createdBy': createdBy,
      'name': name,
      'taxNumber': taxNumber,
      'taxOffice': taxOffice,
      'address': address,
      'city': city,
      'district': district,
      'postalCode': postalCode,
      'phone': phone,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CompanyInfo copyWith({
    String? id,
    String? tenantId,
    String? createdBy,
    String? name,
    String? taxNumber,
    String? taxOffice,
    String? address,
    String? city,
    String? district,
    String? postalCode,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyInfo(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      taxNumber: taxNumber ?? this.taxNumber,
      taxOffice: taxOffice ?? this.taxOffice,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Tam adres bilgisini döndür
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }

  /// İletişim bilgilerini döndür
  String get contactInfo {
    final parts = <String>[];
    if (phone != null && phone!.isNotEmpty) parts.add('Tel: $phone');
    if (email != null && email!.isNotEmpty) parts.add('E-posta: $email');
    if (website != null && website!.isNotEmpty) parts.add('Web: $website');
    return parts.join('\n');
  }
}
