// ========== GOODS RECEIPT ENTITY ==========
// lib/features/purchases/domain/entities/goods_receipt.dart

/// Mal kabul durumu
enum GoodsReceiptStatus {
  draft('Taslak'),
  pending('Beklemede'),
  partial('Kısmi'),
  completed('Tamamlandı'),
  rejected('Reddedildi'),
  cancelled('İptal Edildi');

  const GoodsReceiptStatus(this.displayName);
  final String displayName;
}

/// Mal kabul türü
enum GoodsReceiptType {
  purchase('Satınalma'),
  returnGoods('İade'),
  transfer('Transfer'),
  adjustment('Düzeltme'),
  production('Üretim');

  const GoodsReceiptType(this.displayName);
  final String displayName;
}

/// Mal kabul entity'si
class GoodsReceipt {
  final String id;
  final String receiptNumber;
  final GoodsReceiptType type;
  final GoodsReceiptStatus status;
  final String? purchaseOrderId; // Satınalma siparişi ID'si
  final String? purchaseOrderNumber; // Satınalma siparişi numarası
  final String supplierId;
  final String? supplierName;
  final String warehouseId; // Depo ID'si
  final String? warehouseName; // Depo adı
  final DateTime receiptDate;
  final DateTime? expectedDate; // Beklenen teslimat tarihi
  final String? receivedBy; // Teslim alan kişi
  final String? notes;
  final String? description;
  final List<GoodsReceiptItem> items;
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const GoodsReceipt({
    required this.id,
    required this.receiptNumber,
    required this.type,
    required this.status,
    this.purchaseOrderId,
    this.purchaseOrderNumber,
    required this.supplierId,
    this.supplierName,
    required this.warehouseId,
    this.warehouseName,
    required this.receiptDate,
    this.expectedDate,
    this.receivedBy,
    this.notes,
    this.description,
    this.items = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  GoodsReceipt copyWith({
    String? id,
    String? receiptNumber,
    GoodsReceiptType? type,
    GoodsReceiptStatus? status,
    String? purchaseOrderId,
    String? purchaseOrderNumber,
    String? supplierId,
    String? supplierName,
    String? warehouseId,
    String? warehouseName,
    DateTime? receiptDate,
    DateTime? expectedDate,
    String? receivedBy,
    String? notes,
    String? description,
    List<GoodsReceiptItem>? items,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return GoodsReceipt(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      purchaseOrderNumber: purchaseOrderNumber ?? this.purchaseOrderNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      receiptDate: receiptDate ?? this.receiptDate,
      expectedDate: expectedDate ?? this.expectedDate,
      receivedBy: receivedBy ?? this.receivedBy,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan GoodsReceipt oluştur
  factory GoodsReceipt.fromJson(Map<String, dynamic> json) {
    return GoodsReceipt(
      id: json['id'] as String,
      receiptNumber: json['receiptNumber'] as String,
      type: GoodsReceiptType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoodsReceiptType.purchase,
      ),
      status: GoodsReceiptStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoodsReceiptStatus.draft,
      ),
      purchaseOrderId: json['purchaseOrderId'] as String?,
      purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      warehouseId: json['warehouseId'] as String,
      warehouseName: json['warehouseName'] as String?,
      receiptDate: DateTime.parse(json['receiptDate'] as String),
      expectedDate: json['expectedDate'] != null
          ? DateTime.parse(json['expectedDate'] as String)
          : null,
      receivedBy: json['receivedBy'] as String?,
      notes: json['notes'] as String?,
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => GoodsReceiptItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// GoodsReceipt'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptNumber': receiptNumber,
      'type': type.name,
      'status': status.name,
      'purchaseOrderId': purchaseOrderId,
      'purchaseOrderNumber': purchaseOrderNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'receiptDate': receiptDate.toIso8601String(),
      'expectedDate': expectedDate?.toIso8601String(),
      'receivedBy': receivedBy,
      'notes': notes,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Toplam kalem sayısı
  int get totalItems => items.length;

  /// Toplam miktar
  double get totalQuantity {
    return items.fold(0.0, (sum, item) => sum + item.receivedQuantity);
  }

  /// Beklenen toplam miktar
  double get expectedTotalQuantity {
    return items.fold(0.0, (sum, item) => sum + item.expectedQuantity);
  }

  /// Tamamlanma yüzdesi
  double get completionPercentage {
    if (expectedTotalQuantity == 0) return 0;
    return (totalQuantity / expectedTotalQuantity) * 100;
  }

  /// Tamamlandı mı?
  bool get isCompleted => status == GoodsReceiptStatus.completed;

  /// Kısmi mi?
  bool get isPartial => status == GoodsReceiptStatus.partial;

  /// Gecikmiş mi?
  bool get isOverdue {
    if (expectedDate == null) return false;
    return DateTime.now().isAfter(expectedDate!) && !isCompleted;
  }

  /// Onaylanabilir mi?
  bool get canBeApproved {
    return status == GoodsReceiptStatus.draft ||
        status == GoodsReceiptStatus.pending;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status != GoodsReceiptStatus.cancelled &&
        status != GoodsReceiptStatus.completed;
  }

  @override
  String toString() {
    return 'GoodsReceipt(id: $id, receiptNumber: $receiptNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoodsReceipt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Mal kabul kalemi
class GoodsReceiptItem {
  final String id;
  final String receiptId;
  final String? purchaseOrderItemId; // Satınalma siparişi kalemi ID'si
  final String productId;
  final String? productName;
  final String? productDescription;
  final String? productSku;
  final String? productBarcode;
  final double expectedQuantity; // Beklenen miktar
  final double receivedQuantity; // Teslim alınan miktar
  final double unitCost; // Birim maliyet
  final String unitCostCurrency; // Birim maliyet para birimi
  final double? unitCostExchangeRate; // Birim maliyet kuru
  final String? batchNumber; // Parti numarası
  final DateTime? expiryDate; // Son kullanma tarihi
  final String? serialNumber; // Seri numarası
  final String? location; // Depo konumu
  final String? condition; // Ürün durumu
  final String? notes;
  final Map<String, dynamic> metadata; // Ek bilgiler

  const GoodsReceiptItem({
    required this.id,
    required this.receiptId,
    this.purchaseOrderItemId,
    required this.productId,
    this.productName,
    this.productDescription,
    this.productSku,
    this.productBarcode,
    required this.expectedQuantity,
    required this.receivedQuantity,
    required this.unitCost,
    this.unitCostCurrency = 'TRY',
    this.unitCostExchangeRate,
    this.batchNumber,
    this.expiryDate,
    this.serialNumber,
    this.location,
    this.condition,
    this.notes,
    this.metadata = const {},
  });

  /// CopyWith metodu
  GoodsReceiptItem copyWith({
    String? id,
    String? receiptId,
    String? purchaseOrderItemId,
    String? productId,
    String? productName,
    String? productDescription,
    String? productSku,
    String? productBarcode,
    double? expectedQuantity,
    double? receivedQuantity,
    double? unitCost,
    String? unitCostCurrency,
    double? unitCostExchangeRate,
    String? batchNumber,
    DateTime? expiryDate,
    String? serialNumber,
    String? location,
    String? condition,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return GoodsReceiptItem(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      purchaseOrderItemId: purchaseOrderItemId ?? this.purchaseOrderItemId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productSku: productSku ?? this.productSku,
      productBarcode: productBarcode ?? this.productBarcode,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      unitCost: unitCost ?? this.unitCost,
      unitCostCurrency: unitCostCurrency ?? this.unitCostCurrency,
      unitCostExchangeRate: unitCostExchangeRate ?? this.unitCostExchangeRate,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON'dan GoodsReceiptItem oluştur
  factory GoodsReceiptItem.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptItem(
      id: json['id'] as String,
      receiptId: json['receiptId'] as String,
      purchaseOrderItemId: json['purchaseOrderItemId'] as String?,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productDescription: json['productDescription'] as String?,
      productSku: json['productSku'] as String?,
      productBarcode: json['productBarcode'] as String?,
      expectedQuantity: (json['expectedQuantity'] as num).toDouble(),
      receivedQuantity: (json['receivedQuantity'] as num).toDouble(),
      unitCost: (json['unitCost'] as num).toDouble(),
      unitCostCurrency: json['unitCostCurrency'] as String? ?? 'TRY',
      unitCostExchangeRate: (json['unitCostExchangeRate'] as num?)?.toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      serialNumber: json['serialNumber'] as String?,
      location: json['location'] as String?,
      condition: json['condition'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// GoodsReceiptItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptId': receiptId,
      'purchaseOrderItemId': purchaseOrderItemId,
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productSku': productSku,
      'productBarcode': productBarcode,
      'expectedQuantity': expectedQuantity,
      'receivedQuantity': receivedQuantity,
      'unitCost': unitCost,
      'unitCostCurrency': unitCostCurrency,
      'unitCostExchangeRate': unitCostExchangeRate,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'serialNumber': serialNumber,
      'location': location,
      'condition': condition,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Toplam maliyet
  double get totalCost => receivedQuantity * unitCost;

  /// Eksik miktar
  double get shortfallQuantity => expectedQuantity - receivedQuantity;

  /// Fazla miktar
  double get excessQuantity => receivedQuantity - expectedQuantity;

  /// Tam teslim alındı mı?
  bool get isFullyReceived => receivedQuantity >= expectedQuantity;

  /// Kısmi teslim alındı mı?
  bool get isPartiallyReceived =>
      receivedQuantity > 0 && receivedQuantity < expectedQuantity;

  /// Hiç teslim alınmadı mı?
  bool get isNotReceived => receivedQuantity == 0;

  /// Eksik var mı?
  bool get hasShortfall => shortfallQuantity > 0;

  /// Fazla var mı?
  bool get hasExcess => excessQuantity > 0;

  /// Son kullanma tarihi geçmiş mi?
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Son kullanma tarihi yaklaşıyor mu? (30 gün)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  /// Birim maliyet kur kilitleme yapılmış mı?
  bool get isUnitCostExchangeRateLocked => unitCostExchangeRate != null;

  @override
  String toString() {
    return 'GoodsReceiptItem(id: $id, productId: $productId, expectedQuantity: $expectedQuantity, receivedQuantity: $receivedQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoodsReceiptItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
