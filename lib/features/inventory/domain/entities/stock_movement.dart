
/// Stok hareket türü enum'u
enum StockMovementType {
  in_('Giriş'),
  out('Çıkış'),
  adjustment('Düzeltme'),
  transfer('Transfer');

  const StockMovementType(this.displayName);
  final String displayName;
}

/// Stok hareket domain entity'si
class StockMovement {
  final int? id;
  final int productId;
  final StockMovementType movementType;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String? description;
  final String? referenceNumber;
  final String? referenceType;
  final int? warehouseId;
  final int? sourceWarehouseId;
  final int? destinationWarehouseId;
  final DateTime movementDate;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockMovement({
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

  /// Kopyalama metodu
  StockMovement copyWith({
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
    return StockMovement(
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
      destinationWarehouseId: destinationWarehouseId ?? this.destinationWarehouseId,
      movementDate: movementDate ?? this.movementDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
