import 'package:floor/floor.dart';
import '../../domain/entities/stock_movement.dart';

/// Stok hareket entity modeli
@Entity(tableName: 'stock_movements')
class StockMovementEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Ürün ID'si
  @ColumnInfo(name: 'product_id')
  final int productId;

  /// Hareket türü
  @ColumnInfo(name: 'movement_type')
  final StockMovementType movementType;

  /// Miktar
  @ColumnInfo(name: 'quantity')
  final int quantity;

  /// Birim fiyat
  @ColumnInfo(name: 'unit_price')
  final double unitPrice;

  /// Toplam tutar
  @ColumnInfo(name: 'total_amount')
  final double totalAmount;

  /// Açıklama
  @ColumnInfo(name: 'description')
  final String? description;

  /// Referans numarası (fatura, sipariş vb.)
  @ColumnInfo(name: 'reference_number')
  final String? referenceNumber;

  /// Referans türü
  @ColumnInfo(name: 'reference_type')
  final String? referenceType;

  /// Depo ID'si (giriş/çıkış için)
  @ColumnInfo(name: 'warehouse_id')
  final int? warehouseId;

  /// Kaynak depo ID'si (transfer için)
  @ColumnInfo(name: 'source_warehouse_id')
  final int? sourceWarehouseId;

  /// Hedef depo ID'si (transfer için)
  @ColumnInfo(name: 'destination_warehouse_id')
  final int? destinationWarehouseId;

  /// Hareket tarihi
  @ColumnInfo(name: 'movement_date')
  final DateTime movementDate;

  /// Oluşturan kullanıcı ID'si
  @ColumnInfo(name: 'created_by')
  final int? createdBy;

  /// Oluşturulma tarihi
  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  StockMovementEntity({
    this.id,
    required this.productId,
    required this.movementType,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.description,
    this.referenceNumber,
    this.referenceType,
    this.warehouseId,
    this.sourceWarehouseId,
    this.destinationWarehouseId,
    required this.movementDate,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Entity'den domain modeline dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'movementType': movementType.name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'description': description,
      'referenceNumber': referenceNumber,
      'referenceType': referenceType,
      'warehouseId': warehouseId,
      'sourceWarehouseId': sourceWarehouseId,
      'destinationWarehouseId': destinationWarehouseId,
      'movementDate': movementDate.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Map'ten entity oluşturma
  factory StockMovementEntity.fromMap(Map<String, dynamic> map) {
    return StockMovementEntity(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      movementType: StockMovementType.values.firstWhere(
        (e) => e.name == map['movementType'],
      ),
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      description: map['description'] as String?,
      referenceNumber: map['referenceNumber'] as String?,
      referenceType: map['referenceType'] as String?,
      warehouseId: map['warehouseId'] as int?,
      sourceWarehouseId: map['sourceWarehouseId'] as int?,
      destinationWarehouseId: map['destinationWarehouseId'] as int?,
      movementDate: DateTime.fromMillisecondsSinceEpoch(
        map['movementDate'] as int,
      ),
      createdBy: map['createdBy'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  /// Kopyalama metodu
  StockMovementEntity copyWith({
    int? id,
    int? productId,
    StockMovementType? movementType,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    String? description,
    String? referenceNumber,
    String? referenceType,
    int? warehouseId,
    int? sourceWarehouseId,
    int? destinationWarehouseId,
    DateTime? movementDate,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockMovementEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      referenceType: referenceType ?? this.referenceType,
      warehouseId: warehouseId ?? this.warehouseId,
      sourceWarehouseId: sourceWarehouseId ?? this.sourceWarehouseId,
      destinationWarehouseId:
          destinationWarehouseId ?? this.destinationWarehouseId,
      movementDate: movementDate ?? this.movementDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
