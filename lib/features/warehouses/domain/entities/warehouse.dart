import 'package:equatable/equatable.dart';

/// Depo Türü Enum
enum WarehouseType {
  main, // Ana depo
  branch, // Şube deposu
  retail, // Perakende deposu
  wholesale, // Toptan satış deposu
  cold, // Soğuk hava deposu
  bonded, // Gümrük deposu
  virtual, // Sanal depo
  other, // Diğer
}

/// Depo Durumu Enum
enum WarehouseStatus {
  active, // Aktif
  inactive, // Pasif
  maintenance, // Bakımda
  closed, // Kapalı
  suspended, // Askıya alınmış
}

/// Depo Entity sınıfı
class Warehouse extends Equatable {
  final String id;
  final String name;
  final String? description;
  final WarehouseType type;
  final WarehouseStatus status;
  final String address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? phone;
  final String? email;
  final String? managerName;
  final String? managerPhone;
  final String? managerEmail;
  final double? latitude;
  final double? longitude;
  final int? capacity; // Kapasite (m² veya adet)
  final String? capacityUnit; // Kapasite birimi
  final bool isActive;
  final bool isDefault; // Varsayılan depo kontrolü için
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final String tenantId; // Multi-tenant ID

  const Warehouse({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.status,
    required this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.phone,
    this.email,
    this.managerName,
    this.managerPhone,
    this.managerEmail,
    this.latitude,
    this.longitude,
    this.capacity,
    this.capacityUnit,
    this.isActive = true,
    this.isDefault = false,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.tenantId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        status,
        address,
        city,
        state,
        country,
        postalCode,
        phone,
        email,
        managerName,
        managerPhone,
        managerEmail,
        latitude,
        longitude,
        capacity,
        capacityUnit,
        isActive,
        isDefault,
        notes,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt,
        tenantId,
      ];

  /// JSON'dan Warehouse oluşturur
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as String,
      name: json['name'] as String,
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
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      managerName: json['managerName'] as String?,
      managerPhone: json['managerPhone'] as String?,
      managerEmail: json['managerEmail'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      capacity: json['capacity'] as int?,
      capacityUnit: json['capacityUnit'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedBy: json['updatedBy'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tenantId: json['tenantId'] as String,
    );
  }

  /// Warehouse'ı JSON'a dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'phone': phone,
      'email': email,
      'managerName': managerName,
      'managerPhone': managerPhone,
      'managerEmail': managerEmail,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'capacityUnit': capacityUnit,
      'isActive': isActive,
      'isDefault': isDefault,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt.toIso8601String(),
      'tenantId': tenantId,
    };
  }

  /// Warehouse'ı kopyalar ve belirtilen alanları günceller
  Warehouse copyWith({
    String? id,
    String? name,
    String? description,
    WarehouseType? type,
    WarehouseStatus? status,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? phone,
    String? email,
    String? managerName,
    String? managerPhone,
    String? managerEmail,
    double? latitude,
    double? longitude,
    int? capacity,
    String? capacityUnit,
    bool? isActive,
    bool? isDefault,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    String? tenantId,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      managerName: managerName ?? this.managerName,
      managerPhone: managerPhone ?? this.managerPhone,
      managerEmail: managerEmail ?? this.managerEmail,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      tenantId: tenantId ?? this.tenantId,
    );
  }
}

/// Warehouse Type için icon extension
extension WarehouseTypeExtension on WarehouseType {
  String get icon {
    switch (this) {
      case WarehouseType.main:
        return '🏢';
      case WarehouseType.branch:
        return '🏪';
      case WarehouseType.retail:
        return '🛍️';
      case WarehouseType.wholesale:
        return '📦';
      case WarehouseType.cold:
        return '❄️';
      case WarehouseType.bonded:
        return '🏛️';
      case WarehouseType.virtual:
        return '💻';
      case WarehouseType.other:
        return '📋';
    }
  }

  String get displayName {
    switch (this) {
      case WarehouseType.main:
        return 'Ana Depo';
      case WarehouseType.branch:
        return 'Şube Deposu';
      case WarehouseType.retail:
        return 'Perakende Deposu';
      case WarehouseType.wholesale:
        return 'Toptan Satış Deposu';
      case WarehouseType.cold:
        return 'Soğuk Hava Deposu';
      case WarehouseType.bonded:
        return 'Gümrük Deposu';
      case WarehouseType.virtual:
        return 'Sanal Depo';
      case WarehouseType.other:
        return 'Diğer';
    }
  }
}

/// Warehouse Status için renk extension
extension WarehouseStatusExtension on WarehouseStatus {
  String get displayName {
    switch (this) {
      case WarehouseStatus.active:
        return 'Aktif';
      case WarehouseStatus.inactive:
        return 'Pasif';
      case WarehouseStatus.maintenance:
        return 'Bakımda';
      case WarehouseStatus.closed:
        return 'Kapalı';
      case WarehouseStatus.suspended:
        return 'Askıya Alınmış';
    }
  }
}
