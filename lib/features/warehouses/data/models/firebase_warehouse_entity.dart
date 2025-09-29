import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/warehouse.dart';

/// Firebase Warehouse Entity
class FirebaseWarehouseEntity {
  final String id;
  final String name;
  final String? description;
  final String type; // String representation of WarehouseType
  final String status; // String representation of WarehouseStatus
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
  final int? capacity;
  final String? capacityUnit;
  final bool isActive;
  final bool isDefault;
  final String? notes;
  final String createdBy;
  final Timestamp createdAt;
  final String updatedBy;
  final Timestamp updatedAt;
  final String tenantId;

  FirebaseWarehouseEntity({
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

  /// Firestore'dan FirebaseWarehouseEntity oluşturur
  factory FirebaseWarehouseEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseWarehouseEntity(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      type: data['type'] as String,
      status: data['status'] as String,
      address: data['address'] as String,
      city: data['city'] as String?,
      state: data['state'] as String?,
      country: data['country'] as String?,
      postalCode: data['postalCode'] as String?,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      managerName: data['managerName'] as String?,
      managerPhone: data['managerPhone'] as String?,
      managerEmail: data['managerEmail'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      capacity: data['capacity'] as int?,
      capacityUnit: data['capacityUnit'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      isDefault: data['isDefault'] as bool? ?? false,
      notes: data['notes'] as String?,
      createdBy: data['createdBy'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedBy: data['updatedBy'] as String,
      updatedAt: data['updatedAt'] as Timestamp,
      tenantId: data['tenantId'] as String,
    );
  }

  /// Domain entity'den FirebaseWarehouseEntity oluşturur
  factory FirebaseWarehouseEntity.fromDomain(Warehouse warehouse) {
    return FirebaseWarehouseEntity(
      id: warehouse.id,
      name: warehouse.name,
      description: warehouse.description,
      type: warehouse.type.name,
      status: warehouse.status.name,
      address: warehouse.address,
      city: warehouse.city,
      state: warehouse.state,
      country: warehouse.country,
      postalCode: warehouse.postalCode,
      phone: warehouse.phone,
      email: warehouse.email,
      managerName: warehouse.managerName,
      managerPhone: warehouse.managerPhone,
      managerEmail: warehouse.managerEmail,
      latitude: warehouse.latitude,
      longitude: warehouse.longitude,
      capacity: warehouse.capacity,
      capacityUnit: warehouse.capacityUnit,
      isActive: warehouse.isActive,
      isDefault: warehouse.isDefault,
      notes: warehouse.notes,
      createdBy: warehouse.createdBy,
      createdAt: Timestamp.fromDate(warehouse.createdAt),
      updatedBy: warehouse.updatedBy,
      updatedAt: Timestamp.fromDate(warehouse.updatedAt),
      tenantId: warehouse.tenantId,
    );
  }

  /// FirebaseWarehouseEntity'yi domain entity'ye dönüştürür
  Warehouse toDomain() {
    return Warehouse(
      id: id,
      name: name,
      description: description,
      type: WarehouseType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => WarehouseType.main,
      ),
      status: WarehouseStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => WarehouseStatus.active,
      ),
      address: address,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      phone: phone,
      email: email,
      managerName: managerName,
      managerPhone: managerPhone,
      managerEmail: managerEmail,
      latitude: latitude,
      longitude: longitude,
      capacity: capacity,
      capacityUnit: capacityUnit,
      isActive: isActive,
      isDefault: isDefault,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt.toDate(),
      updatedBy: updatedBy,
      updatedAt: updatedAt.toDate(),
      tenantId: tenantId,
    );
  }

  /// Firebase'e yazılacak Map formatına dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'status': status,
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
      'createdAt': createdAt,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
      'tenantId': tenantId,
    };
  }

  /// FirebaseWarehouseEntity'yi kopyalar ve belirtilen alanları günceller
  FirebaseWarehouseEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? status,
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
    Timestamp? createdAt,
    String? updatedBy,
    Timestamp? updatedAt,
    String? tenantId,
  }) {
    return FirebaseWarehouseEntity(
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
