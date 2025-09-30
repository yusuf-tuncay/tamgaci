// ========== PRODUCT MOVEMENT ENTITY ==========
// lib/features/products/domain/entities/product_movement.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Ürün hareket türü
enum ProductMovementType {
  stockIn,        // Stok girişi
  stockOut,       // Stok çıkışı
  transfer,       // Transfer
  adjustment,     // Düzeltme
  sale,           // Satış
  purchase,       // Alış
  returnIn,       // İade girişi
  returnOut,      // İade çıkışı
  production,     // Üretim
  consumption,    // Tüketim
  waste,          // Fire
  other,          // Diğer
}

/// Ürün hareketi entity'si
class ProductMovement {
  final String id;
  final String productId;
  final String productName;
  final ProductMovementType type;
  final int quantity;
  final String? fromWarehouseId;
  final String? fromWarehouseName;
  final String? toWarehouseId;
  final String? toWarehouseName;
  final String? referenceId; // Satış, alış, transfer ID'si
  final String? referenceType; // 'sale', 'purchase', 'transfer', etc.
  final String? notes;
  final String? userId;
  final String? userName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    this.fromWarehouseId,
    this.fromWarehouseName,
    this.toWarehouseId,
    this.toWarehouseName,
    this.referenceId,
    this.referenceType,
    this.notes,
    this.userId,
    this.userName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ProductMovement kopyalama metodu
  ProductMovement copyWith({
    String? id,
    String? productId,
    String? productName,
    ProductMovementType? type,
    int? quantity,
    String? fromWarehouseId,
    String? fromWarehouseName,
    String? toWarehouseId,
    String? toWarehouseName,
    String? referenceId,
    String? referenceType,
    String? notes,
    String? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      fromWarehouseName: fromWarehouseName ?? this.fromWarehouseName,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      toWarehouseName: toWarehouseName ?? this.toWarehouseName,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan ProductMovement oluşturma
  factory ProductMovement.fromJson(Map<String, dynamic> json) {
    return ProductMovement(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: ProductMovementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProductMovementType.other,
      ),
      quantity: json['quantity'] as int,
      fromWarehouseId: json['fromWarehouseId'] as String?,
      fromWarehouseName: json['fromWarehouseName'] as String?,
      toWarehouseId: json['toWarehouseId'] as String?,
      toWarehouseName: json['toWarehouseName'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      notes: json['notes'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// ProductMovement'ı JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type.name,
      'quantity': quantity,
      'fromWarehouseId': fromWarehouseId,
      'fromWarehouseName': fromWarehouseName,
      'toWarehouseId': toWarehouseId,
      'toWarehouseName': toWarehouseName,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'notes': notes,
      'userId': userId,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Hareket türü display name
  String get typeDisplayName {
    switch (type) {
      case ProductMovementType.stockIn:
        return 'Stok Girişi';
      case ProductMovementType.stockOut:
        return 'Stok Çıkışı';
      case ProductMovementType.transfer:
        return 'Transfer';
      case ProductMovementType.adjustment:
        return 'Düzeltme';
      case ProductMovementType.sale:
        return 'Satış';
      case ProductMovementType.purchase:
        return 'Alış';
      case ProductMovementType.returnIn:
        return 'İade Girişi';
      case ProductMovementType.returnOut:
        return 'İade Çıkışı';
      case ProductMovementType.production:
        return 'Üretim';
      case ProductMovementType.consumption:
        return 'Tüketim';
      case ProductMovementType.waste:
        return 'Fire';
      case ProductMovementType.other:
        return 'Diğer';
    }
  }

  /// Hareket türü ikonu
  String get typeIcon {
    switch (type) {
      case ProductMovementType.stockIn:
        return '📥';
      case ProductMovementType.stockOut:
        return '📤';
      case ProductMovementType.transfer:
        return '🔄';
      case ProductMovementType.adjustment:
        return '⚖️';
      case ProductMovementType.sale:
        return '💰';
      case ProductMovementType.purchase:
        return '🛒';
      case ProductMovementType.returnIn:
        return '↩️';
      case ProductMovementType.returnOut:
        return '↪️';
      case ProductMovementType.production:
        return '🏭';
      case ProductMovementType.consumption:
        return '⚡';
      case ProductMovementType.waste:
        return '🗑️';
      case ProductMovementType.other:
        return '📋';
    }
  }

  /// Hareket türü rengi
  String get typeColor {
    switch (type) {
      case ProductMovementType.stockIn:
      case ProductMovementType.purchase:
      case ProductMovementType.returnIn:
      case ProductMovementType.production:
        return 'green';
      case ProductMovementType.stockOut:
      case ProductMovementType.sale:
      case ProductMovementType.returnOut:
      case ProductMovementType.consumption:
      case ProductMovementType.waste:
        return 'red';
      case ProductMovementType.transfer:
        return 'blue';
      case ProductMovementType.adjustment:
        return 'orange';
      case ProductMovementType.other:
        return 'grey';
    }
  }

  /// Hareket açıklaması
  String get description {
    switch (type) {
      case ProductMovementType.stockIn:
        return 'Stok girişi yapıldı';
      case ProductMovementType.stockOut:
        return 'Stok çıkışı yapıldı';
      case ProductMovementType.transfer:
        return '${fromWarehouseName ?? "Bilinmeyen"} → ${toWarehouseName ?? "Bilinmeyen"}';
      case ProductMovementType.adjustment:
        return 'Stok düzeltmesi yapıldı';
      case ProductMovementType.sale:
        return 'Satış işlemi';
      case ProductMovementType.purchase:
        return 'Alış işlemi';
      case ProductMovementType.returnIn:
        return 'İade girişi yapıldı';
      case ProductMovementType.returnOut:
        return 'İade çıkışı yapıldı';
      case ProductMovementType.production:
        return 'Üretim işlemi';
      case ProductMovementType.consumption:
        return 'Tüketim işlemi';
      case ProductMovementType.waste:
        return 'Fire işlemi';
      case ProductMovementType.other:
        return 'Diğer işlem';
    }
  }
}
