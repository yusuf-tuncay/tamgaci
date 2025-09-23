// ========== STOCK MOVEMENT ==========
// lib/features/inventory/domain/entities/stock_movement.dart

/// Stok hareket tipi enum'u
enum StockMovementType {
  stockIn('Giriş'),
  stockOut('Çıkış'),
  transfer('Transfer'),
  adjustment('Düzeltme'),
  return_('İade');

  const StockMovementType(this.displayName);
  final String displayName;
}

/// Stok hareket entity'si
class StockMovement {
  final String id;
  final String productId;
  final String warehouseId;
  final StockMovementType type;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime movementDate;
  final String? reference;
  final String? notes;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.movementDate,
    this.reference,
    this.notes,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  StockMovement copyWith({
    String? id,
    String? productId,
    String? warehouseId,
    StockMovementType? type,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? movementDate,
    String? reference,
    String? notes,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      movementDate: movementDate ?? this.movementDate,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan StockMovement oluştur
  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      productId: json['productId'] as String,
      warehouseId: json['warehouseId'] as String,
      type: StockMovementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StockMovementType.stockIn,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      movementDate: DateTime.parse(json['movementDate'] as String),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// StockMovement'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'type': type.name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'movementDate': movementDate.toIso8601String(),
      'reference': reference,
      'notes': notes,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  String toString() {
    return 'StockMovement(id: $id, productId: $productId, type: $type, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockMovement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
