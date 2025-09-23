// ========== STOCK TRANSFER ENTITY ==========
// lib/features/inventory/domain/entities/stock_transfer.dart

/// Stok transfer durumu
enum StockTransferStatus {
  draft('Taslak'),
  pending('Beklemede'),
  inTransit('Yolda'),
  completed('Tamamlandı'),
  cancelled('İptal'),
  rejected('Reddedildi');

  const StockTransferStatus(this.displayName);
  final String displayName;
}

/// Stok transfer türü
enum StockTransferType {
  internal('İç Transfer'),
  external('Dış Transfer'),
  return_('İade Transfer'),
  adjustment('Düzeltme Transfer');

  const StockTransferType(this.displayName);
  final String displayName;
}

/// Stok transfer entity'si
class StockTransfer {
  final String id;
  final String transferNumber;
  final String? reference;
  final StockTransferType type;
  final StockTransferStatus status;
  final String fromWarehouseId;
  final String? fromWarehouseName;
  final String toWarehouseId;
  final String? toWarehouseName;
  final DateTime transferDate;
  final DateTime? expectedDate;
  final DateTime? completedDate;
  final List<StockTransferItem> items;
  final String? notes;
  final String? reason;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? receivedBy;
  final DateTime? receivedAt;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockTransfer({
    required this.id,
    required this.transferNumber,
    this.reference,
    required this.type,
    required this.status,
    required this.fromWarehouseId,
    this.fromWarehouseName,
    required this.toWarehouseId,
    this.toWarehouseName,
    required this.transferDate,
    this.expectedDate,
    this.completedDate,
    this.items = const [],
    this.notes,
    this.reason,
    this.approvedBy,
    this.approvedAt,
    this.receivedBy,
    this.receivedAt,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  StockTransfer copyWith({
    String? id,
    String? transferNumber,
    String? reference,
    StockTransferType? type,
    StockTransferStatus? status,
    String? fromWarehouseId,
    String? fromWarehouseName,
    String? toWarehouseId,
    String? toWarehouseName,
    DateTime? transferDate,
    DateTime? expectedDate,
    DateTime? completedDate,
    List<StockTransferItem>? items,
    String? notes,
    String? reason,
    String? approvedBy,
    DateTime? approvedAt,
    String? receivedBy,
    DateTime? receivedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockTransfer(
      id: id ?? this.id,
      transferNumber: transferNumber ?? this.transferNumber,
      reference: reference ?? this.reference,
      type: type ?? this.type,
      status: status ?? this.status,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      fromWarehouseName: fromWarehouseName ?? this.fromWarehouseName,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      toWarehouseName: toWarehouseName ?? this.toWarehouseName,
      transferDate: transferDate ?? this.transferDate,
      expectedDate: expectedDate ?? this.expectedDate,
      completedDate: completedDate ?? this.completedDate,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      reason: reason ?? this.reason,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      receivedBy: receivedBy ?? this.receivedBy,
      receivedAt: receivedAt ?? this.receivedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan StockTransfer oluştur
  factory StockTransfer.fromJson(Map<String, dynamic> json) {
    return StockTransfer(
      id: json['id'] as String,
      transferNumber: json['transferNumber'] as String,
      reference: json['reference'] as String?,
      type: StockTransferType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StockTransferType.internal,
      ),
      status: StockTransferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockTransferStatus.draft,
      ),
      fromWarehouseId: json['fromWarehouseId'] as String,
      fromWarehouseName: json['fromWarehouseName'] as String?,
      toWarehouseId: json['toWarehouseId'] as String,
      toWarehouseName: json['toWarehouseName'] as String?,
      transferDate: DateTime.parse(json['transferDate'] as String),
      expectedDate: json['expectedDate'] != null
          ? DateTime.parse(json['expectedDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => StockTransferItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      reason: json['reason'] as String?,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      receivedBy: json['receivedBy'] as String?,
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// StockTransfer'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transferNumber': transferNumber,
      'reference': reference,
      'type': type.name,
      'status': status.name,
      'fromWarehouseId': fromWarehouseId,
      'fromWarehouseName': fromWarehouseName,
      'toWarehouseId': toWarehouseId,
      'toWarehouseName': toWarehouseName,
      'transferDate': transferDate.toIso8601String(),
      'expectedDate': expectedDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'notes': notes,
      'reason': reason,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'receivedBy': receivedBy,
      'receivedAt': receivedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Toplam ürün sayısı
  int get totalItems => items.length;

  /// Toplam miktar
  double get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  /// Toplam değer
  double get totalValue => items.fold(0, (sum, item) => sum + item.totalValue);

  /// Transfer tamamlandı mı?
  bool get isCompleted => status == StockTransferStatus.completed;

  /// Transfer onaylandı mı?
  bool get isApproved => approvedBy != null && approvedAt != null;

  /// Transfer alındı mı?
  bool get isReceived => receivedBy != null && receivedAt != null;

  @override
  String toString() {
    return 'StockTransfer(id: $id, transferNumber: $transferNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockTransfer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Stok transfer kalemi
class StockTransferItem {
  final String id;
  final String productId;
  final String? productName;
  final String? productSku;
  final String? productBarcode;
  final double quantity;
  final String unit;
  final double unitCost;
  final double totalValue;
  final String? fromLocation;
  final String? toLocation;
  final String? notes;
  final double? receivedQuantity;
  final DateTime? receivedAt;
  final String? receivedBy;

  const StockTransferItem({
    required this.id,
    required this.productId,
    this.productName,
    this.productSku,
    this.productBarcode,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.totalValue,
    this.fromLocation,
    this.toLocation,
    this.notes,
    this.receivedQuantity,
    this.receivedAt,
    this.receivedBy,
  });

  /// CopyWith metodu
  StockTransferItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productSku,
    String? productBarcode,
    double? quantity,
    String? unit,
    double? unitCost,
    double? totalValue,
    String? fromLocation,
    String? toLocation,
    String? notes,
    double? receivedQuantity,
    DateTime? receivedAt,
    String? receivedBy,
  }) {
    return StockTransferItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productBarcode: productBarcode ?? this.productBarcode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
      totalValue: totalValue ?? this.totalValue,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      notes: notes ?? this.notes,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      receivedAt: receivedAt ?? this.receivedAt,
      receivedBy: receivedBy ?? this.receivedBy,
    );
  }

  /// JSON'dan StockTransferItem oluştur
  factory StockTransferItem.fromJson(Map<String, dynamic> json) {
    return StockTransferItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productSku: json['productSku'] as String?,
      productBarcode: json['productBarcode'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitCost: (json['unitCost'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      fromLocation: json['fromLocation'] as String?,
      toLocation: json['toLocation'] as String?,
      notes: json['notes'] as String?,
      receivedQuantity: (json['receivedQuantity'] as num?)?.toDouble(),
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'] as String)
          : null,
      receivedBy: json['receivedBy'] as String?,
    );
  }

  /// StockTransferItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'productBarcode': productBarcode,
      'quantity': quantity,
      'unit': unit,
      'unitCost': unitCost,
      'totalValue': totalValue,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'notes': notes,
      'receivedQuantity': receivedQuantity,
      'receivedAt': receivedAt?.toIso8601String(),
      'receivedBy': receivedBy,
    };
  }

  /// Alım tamamlandı mı?
  bool get isReceived => receivedQuantity != null && receivedAt != null;

  /// Alım miktarı
  double get receivedAmount => receivedQuantity ?? 0;

  /// Bekleyen miktar
  double get pendingQuantity => quantity - receivedAmount;

  /// Alım yüzdesi
  double get receivedPercentage {
    if (quantity == 0) return 0;
    return (receivedAmount / quantity) * 100;
  }

  @override
  String toString() {
    return 'StockTransferItem(id: $id, productId: $productId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockTransferItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
