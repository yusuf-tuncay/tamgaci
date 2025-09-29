// ========== STOCK DOMAIN ENTITY ==========
// lib/features/inventory/domain/entities/stock.dart

import '../../../products/domain/entities/product.dart';
import 'warehouse.dart';

/// Stok entity'si - Warehouse'larda bulunan ürünlerin stok bilgilerini tutar
class Stock {
  final String id;
  final String tenantId; // Multi-tenant güvenlik için zorunlu
  final String productId;
  final String warehouseId;
  final double quantity;
  final double minimumQuantity;
  final double maximumQuantity;
  final String unit;
  final String currency;
  final double unitPrice;
  final String? location;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Navigation properties (optional, for UI purposes)
  final Product? product;
  final Warehouse? warehouse;

  const Stock({
    required this.id,
    required this.tenantId,
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
    this.product,
    this.warehouse,
  });

  /// Stok durumunu hesaplar
  StockStatus get status {
    if (quantity <= minimumQuantity) {
      return StockStatus.low;
    } else if (quantity >= maximumQuantity) {
      return StockStatus.high;
    } else {
      return StockStatus.normal;
    }
  }

  /// Toplam değeri hesaplar
  double get totalValue => quantity * unitPrice;

  /// Stok yüzdesini hesaplar
  double get stockPercentage {
    if (maximumQuantity <= 0) return 0;
    return (quantity / maximumQuantity) * 100;
  }

  /// Stok kritik seviyede mi?
  bool get isCritical => quantity <= minimumQuantity;

  /// Stok fazla mı?
  bool get isOverstocked => quantity >= maximumQuantity;

  /// Stok normal seviyede mi?
  bool get isNormal => !isCritical && !isOverstocked;

  /// Copy with method
  Stock copyWith({
    String? id,
    String? productId,
    String? warehouseId,
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
    Product? product,
    Warehouse? warehouse,
  }) {
    return Stock(
      id: id ?? this.id,
      tenantId: tenantId,
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
      product: product ?? this.product,
      warehouse: warehouse ?? this.warehouse,
    );
  }

  /// Map'ten Stock oluşturur
  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id']?.toString() ?? '',
      tenantId: map['tenantId']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      warehouseId: map['warehouseId']?.toString() ?? '',
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

  /// Stock'u Map'e çevirir
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

  @override
  String toString() {
    return 'Stock(id: $id, productId: $productId, warehouseId: $warehouseId, quantity: $quantity, unit: $unit, currency: $currency, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stock &&
        other.id == id &&
        other.productId == productId &&
        other.warehouseId == warehouseId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ productId.hashCode ^ warehouseId.hashCode;
  }
}

/// Stok durumu enum'u
enum StockStatus {
  low, // Düşük stok
  normal, // Normal stok
  high, // Yüksek stok
}

/// Stok durumu için extension
extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.low:
        return 'Düşük Stok';
      case StockStatus.normal:
        return 'Normal Stok';
      case StockStatus.high:
        return 'Yüksek Stok';
    }
  }

  String get shortName {
    switch (this) {
      case StockStatus.low:
        return 'Düşük';
      case StockStatus.normal:
        return 'Normal';
      case StockStatus.high:
        return 'Yüksek';
    }
  }
}
