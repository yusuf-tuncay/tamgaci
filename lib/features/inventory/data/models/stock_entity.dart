// ========== STOCK DATA MODEL ==========
// lib/features/inventory/data/models/stock_entity.dart

import 'package:floor/floor.dart';
import '../../../products/data/models/product_entity.dart';
import 'warehouse_entity.dart';

/// Stock entity for database operations
@Entity(
  tableName: 'stocks',
  foreignKeys: [
    ForeignKey(
      childColumns: ['productId'],
      parentColumns: ['id'],
      entity: ProductEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['warehouseId'],
      parentColumns: ['id'],
      entity: WarehouseEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class StockEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;

  @ColumnInfo(name: 'productId')
  final int productId;

  @ColumnInfo(name: 'warehouseId')
  final int warehouseId;

  @ColumnInfo(name: 'quantity')
  final double quantity;

  @ColumnInfo(name: 'minimumQuantity')
  final double minimumQuantity;

  @ColumnInfo(name: 'maximumQuantity')
  final double maximumQuantity;

  @ColumnInfo(name: 'unit')
  final String unit;

  @ColumnInfo(name: 'currency')
  final String currency;

  @ColumnInfo(name: 'unitPrice')
  final double unitPrice;

  @ColumnInfo(name: 'location')
  final String? location;

  @ColumnInfo(name: 'notes')
  final String? notes;

  @ColumnInfo(name: 'isActive')
  final bool isActive;

  @ColumnInfo(name: 'createdAt')
  final DateTime createdAt;

  @ColumnInfo(name: 'updatedAt')
  final DateTime updatedAt;

  const StockEntity({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.quantity,
    required this.minimumQuantity,
    required this.maximumQuantity,
    required this.unit,
    required this.currency,
    required this.unitPrice,
    this.location,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Map'ten StockEntity oluşturur
  factory StockEntity.fromMap(Map<String, dynamic> map) {
    return StockEntity(
      id: map['id']?.toInt() ?? 0,
      productId: map['productId']?.toInt() ?? 0,
      warehouseId: map['warehouseId']?.toInt() ?? 0,
      quantity: map['quantity']?.toDouble() ?? 0.0,
      minimumQuantity: map['minimumQuantity']?.toDouble() ?? 0.0,
      maximumQuantity: map['maximumQuantity']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      currency: map['currency'] ?? 'TRY',
      unitPrice: map['unitPrice']?.toDouble() ?? 0.0,
      location: map['location'],
      notes: map['notes'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// StockEntity'yi Map'e çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'maximumQuantity': maximumQuantity,
      'unit': unit,
      'currency': currency,
      'unitPrice': unitPrice,
      'location': location,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method
  StockEntity copyWith({
    int? id,
    int? productId,
    int? warehouseId,
    double? quantity,
    double? minimumQuantity,
    double? maximumQuantity,
    String? unit,
    String? currency,
    double? unitPrice,
    String? location,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      quantity: quantity ?? this.quantity,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      maximumQuantity: maximumQuantity ?? this.maximumQuantity,
      unit: unit ?? this.unit,
      currency: currency ?? this.currency,
      unitPrice: unitPrice ?? this.unitPrice,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StockEntity(id: $id, productId: $productId, warehouseId: $warehouseId, quantity: $quantity, unit: $unit, currency: $currency, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockEntity &&
        other.id == id &&
        other.productId == productId &&
        other.warehouseId == warehouseId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ productId.hashCode ^ warehouseId.hashCode;
  }
}
