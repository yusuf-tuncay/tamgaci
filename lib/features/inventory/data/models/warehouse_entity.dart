import 'package:floor/floor.dart';

/// Depo entity modeli
@Entity(tableName: 'warehouses')
class WarehouseEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Depo adı
  @ColumnInfo(name: 'name')
  final String name;

  /// Depo kodu
  @ColumnInfo(name: 'code')
  final String? code;

  /// Depo açıklaması
  @ColumnInfo(name: 'description')
  final String? description;

  /// Adres
  @ColumnInfo(name: 'address')
  final String? address;

  /// Telefon
  @ColumnInfo(name: 'phone')
  final String? phone;

  /// E-posta
  @ColumnInfo(name: 'email')
  final String? email;

  /// Depo sorumlusu
  @ColumnInfo(name: 'manager')
  final String? manager;

  /// Kapasite
  @ColumnInfo(name: 'capacity')
  final double? capacity;

  /// Kapasite birimi
  @ColumnInfo(name: 'capacity_unit')
  final String? capacityUnit;

  /// Para birimi
  @ColumnInfo(name: 'currency')
  final String currency;

  /// Aktif/Pasif durumu
  @ColumnInfo(name: 'is_active')
  final bool isActive;

  /// Varsayılan depo mu?
  @ColumnInfo(name: 'is_default')
  final bool isDefault;

  /// Oluşturulma tarihi
  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  WarehouseEntity({
    this.id,
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

  /// Entity'den domain modeline dönüştürme
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
      'isActive': isActive ? 1 : 0,
      'isDefault': isDefault ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Map'ten entity oluşturma
  factory WarehouseEntity.fromMap(Map<String, dynamic> map) {
    return WarehouseEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String?,
      description: map['description'] as String?,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      manager: map['manager'] as String?,
      capacity: map['capacity'] as double?,
      capacityUnit: map['capacityUnit'] as String?,
      currency: map['currency'] as String? ?? 'TRY',
      isActive: (map['isActive'] as int) == 1,
      isDefault: (map['isDefault'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  /// Kopyalama metodu
  WarehouseEntity copyWith({
    int? id,
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
    return WarehouseEntity(
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
}
