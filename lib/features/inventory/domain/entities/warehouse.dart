// ========== WAREHOUSE ENTITY ==========
// lib/features/inventory/domain/entities/warehouse.dart

/// Depo domain entity'si
class Warehouse {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? manager;
  final double? capacity;
  final String? capacityUnit;
  final String currency; // Para birimi desteği
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Warehouse({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.manager,
    this.capacity,
    this.capacityUnit,
    this.currency = 'TRY', // Varsayılan para birimi
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Kopyalama metodu
  Warehouse copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? manager,
    double? capacity,
    String? capacityUnit,
    String? currency,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      manager: manager ?? this.manager,
      capacity: capacity ?? this.capacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Map'ten Warehouse oluşturur
  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      id: map['id'] as String,
      name: map['name'] ?? '',
      code: map['code'],
      description: map['description'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      manager: map['manager'],
      capacity: map['capacity']?.toDouble(),
      capacityUnit: map['capacityUnit'],
      currency: map['currency'] ?? 'TRY',
      isActive: map['isActive'] ?? true,
      isDefault: map['isDefault'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Warehouse'u Map'e çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'manager': manager,
      'capacity': capacity,
      'capacityUnit': capacityUnit,
      'currency': currency,
      'isActive': isActive,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, code: $code, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Warehouse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
