// ========== WAREHOUSE DOMAIN ENTITY ==========
// lib/features/products/domain/entities/warehouse.dart

/// Depo türü enum'u
enum WarehouseType {
  main('Ana Depo'),
  branch('Şube Deposu'),
  temporary('Geçici Depo'),
  cold('Soğuk Depo'),
  hazardous('Tehlikeli Madde Deposu'),
  warehouse('Depo');

  const WarehouseType(this.displayName);
  final String displayName;
}

/// Depo durumu enum'u
enum WarehouseStatus {
  active('Aktif'),
  inactive('Pasif'),
  maintenance('Bakımda'),
  full('Dolu');

  const WarehouseStatus(this.displayName);
  final String displayName;
}

/// Depo domain entity'si
class Warehouse {
  final String id;
  final String name;
  final String? code; // Depo kodu
  final String? description;
  final WarehouseType type;
  final WarehouseStatus status;
  final String address;
  final String? city;
  final String? district;
  final String? postalCode;
  final String? phone;
  final String? email;
  final String? managerName; // Depo sorumlusu
  final String? manager; // Depo sorumlusu (alternatif)
  final String? companyId; // Şirket ID'si
  final double? capacity; // Kapasite (m² veya m³)
  final double? usedCapacity; // Kullanılan kapasite
  final bool hasClimateControl; // İklim kontrolü var mı
  final bool hasSecurity; // Güvenlik var mı
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const Warehouse({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.type = WarehouseType.main,
    this.status = WarehouseStatus.active,
    required this.address,
    this.city,
    this.district,
    this.postalCode,
    this.phone,
    this.email,
    this.managerName,
    this.manager,
    this.companyId,
    this.capacity,
    this.usedCapacity,
    this.hasClimateControl = false,
    this.hasSecurity = false,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// Kapasite kullanım oranı
  double get capacityUsageRate {
    if (capacity == null || capacity == 0) return 0.0;
    return (usedCapacity ?? 0) / capacity!;
  }

  /// Kapasite durumu
  String get capacityStatus {
    final rate = capacityUsageRate;
    if (rate >= 0.9) return 'Dolu';
    if (rate >= 0.7) return 'Yüksek';
    if (rate >= 0.5) return 'Orta';
    return 'Boş';
  }

  /// Kopyalama metodu
  Warehouse copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    WarehouseType? type,
    WarehouseStatus? status,
    String? address,
    String? city,
    String? district,
    String? postalCode,
    String? phone,
    String? email,
    String? managerName,
    double? capacity,
    double? usedCapacity,
    bool? hasClimateControl,
    bool? hasSecurity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      managerName: managerName ?? this.managerName,
      capacity: capacity ?? this.capacity,
      usedCapacity: usedCapacity ?? this.usedCapacity,
      hasClimateControl: hasClimateControl ?? this.hasClimateControl,
      hasSecurity: hasSecurity ?? this.hasSecurity,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Warehouse oluşturma
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      description: json['description'] as String?,
      type: WarehouseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WarehouseType.main,
      ),
      status: WarehouseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WarehouseStatus.active,
      ),
      address: json['address'] as String,
      city: json['city'] as String?,
      district: json['district'] as String?,
      postalCode: json['postalCode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      managerName: json['managerName'] as String?,
      capacity: json['capacity']?.toDouble(),
      usedCapacity: json['usedCapacity']?.toDouble(),
      hasClimateControl: json['hasClimateControl'] as bool? ?? false,
      hasSecurity: json['hasSecurity'] as bool? ?? false,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'type': type.name,
      'status': status.name,
      'address': address,
      'city': city,
      'district': district,
      'postalCode': postalCode,
      'phone': phone,
      'email': email,
      'managerName': managerName,
      'capacity': capacity,
      'usedCapacity': usedCapacity,
      'hasClimateControl': hasClimateControl,
      'hasSecurity': hasSecurity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Warehouse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, type: $type)';
  }
}
