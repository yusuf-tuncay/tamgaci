// ========== SALES RETURN ENTITY ==========
// lib/features/sales/domain/entities/sales_return.dart

/// İade türü
enum ReturnType {
  full('Tam İade'),
  partial('Kısmi İade'),
  exchange('Değişim'),
  warranty('Garanti'),
  defect('Defolu Ürün'),
  customerRequest('Müşteri Talebi');

  const ReturnType(this.displayName);
  final String displayName;
}

/// İade durumu
enum ReturnStatus {
  draft('Taslak'),
  pending('Beklemede'),
  approved('Onaylandı'),
  rejected('Reddedildi'),
  processed('İşlendi'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi');

  const ReturnStatus(this.displayName);
  final String displayName;
}

/// Satış iadesi entity'si
class SalesReturn {
  final String id;
  final String returnNumber;
  final String originalSaleId; // Orijinal satış ID'si
  final String? originalSaleNumber; // Orijinal satış numarası
  final ReturnType type;
  final ReturnStatus status;
  final String customerId;
  final String? customerName;
  final DateTime returnDate;
  final DateTime? approvedDate;
  final DateTime? processedDate;
  final String? reason; // İade nedeni
  final String? description; // Açıklama
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final double? exchangeRate; // Döviz kuru
  final String? exchangeRateSource; // Kur kaynağı
  final DateTime? exchangeRateDate; // Kur tarihi
  final String? notes;
  final String? approvedBy;
  final String? processedBy;
  final List<SalesReturnItem> items;
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const SalesReturn({
    required this.id,
    required this.returnNumber,
    required this.originalSaleId,
    this.originalSaleNumber,
    required this.type,
    required this.status,
    required this.customerId,
    this.customerName,
    required this.returnDate,
    this.approvedDate,
    this.processedDate,
    this.reason,
    this.description,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    this.exchangeRate,
    this.exchangeRateSource,
    this.exchangeRateDate,
    this.notes,
    this.approvedBy,
    this.processedBy,
    this.items = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  SalesReturn copyWith({
    String? id,
    String? returnNumber,
    String? originalSaleId,
    String? originalSaleNumber,
    ReturnType? type,
    ReturnStatus? status,
    String? customerId,
    String? customerName,
    DateTime? returnDate,
    DateTime? approvedDate,
    DateTime? processedDate,
    String? reason,
    String? description,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    double? exchangeRate,
    String? exchangeRateSource,
    DateTime? exchangeRateDate,
    String? notes,
    String? approvedBy,
    String? processedBy,
    List<SalesReturnItem>? items,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return SalesReturn(
      id: id ?? this.id,
      returnNumber: returnNumber ?? this.returnNumber,
      originalSaleId: originalSaleId ?? this.originalSaleId,
      originalSaleNumber: originalSaleNumber ?? this.originalSaleNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      returnDate: returnDate ?? this.returnDate,
      approvedDate: approvedDate ?? this.approvedDate,
      processedDate: processedDate ?? this.processedDate,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      exchangeRateSource: exchangeRateSource ?? this.exchangeRateSource,
      exchangeRateDate: exchangeRateDate ?? this.exchangeRateDate,
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      processedBy: processedBy ?? this.processedBy,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan SalesReturn oluştur
  factory SalesReturn.fromJson(Map<String, dynamic> json) {
    return SalesReturn(
      id: json['id'] as String,
      returnNumber: json['returnNumber'] as String,
      originalSaleId: json['originalSaleId'] as String,
      originalSaleNumber: json['originalSaleNumber'] as String?,
      type: ReturnType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReturnType.customerRequest,
      ),
      status: ReturnStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReturnStatus.draft,
      ),
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      returnDate: DateTime.parse(json['returnDate'] as String),
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'] as String)
          : null,
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'] as String)
          : null,
      reason: json['reason'] as String?,
      description: json['description'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      exchangeRateSource: json['exchangeRateSource'] as String?,
      exchangeRateDate: json['exchangeRateDate'] != null
          ? DateTime.parse(json['exchangeRateDate'] as String)
          : null,
      notes: json['notes'] as String?,
      approvedBy: json['approvedBy'] as String?,
      processedBy: json['processedBy'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SalesReturnItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// SalesReturn'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'returnNumber': returnNumber,
      'originalSaleId': originalSaleId,
      'originalSaleNumber': originalSaleNumber,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'returnDate': returnDate.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'reason': reason,
      'description': description,
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'exchangeRateSource': exchangeRateSource,
      'exchangeRateDate': exchangeRateDate?.toIso8601String(),
      'notes': notes,
      'approvedBy': approvedBy,
      'processedBy': processedBy,
      'items': items.map((e) => e.toJson()).toList(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// KDV dahil toplam
  double get totalWithTax => subtotal + taxAmount;

  /// Net tutar (indirim sonrası)
  double get netAmount => subtotal - discountAmount;

  /// Final tutar (KDV + indirim sonrası)
  double get finalAmount => netAmount + taxAmount;

  /// Kur kilitleme yapılmış mı?
  bool get isExchangeRateLocked => exchangeRate != null;

  /// Onaylanabilir mi?
  bool get canBeApproved {
    return status == ReturnStatus.draft || status == ReturnStatus.pending;
  }

  /// İşlenebilir mi?
  bool get canBeProcessed {
    return status == ReturnStatus.approved;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status != ReturnStatus.cancelled && status != ReturnStatus.completed;
  }

  @override
  String toString() {
    return 'SalesReturn(id: $id, returnNumber: $returnNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesReturn && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Satış iadesi kalemi
class SalesReturnItem {
  final String id;
  final String returnId;
  final String originalSaleItemId; // Orijinal satış kalemi ID'si
  final String productId;
  final String? productName;
  final String? productDescription;
  final String? productSku;
  final String? productBarcode;
  final double originalQuantity; // Orijinal miktar
  final double returnedQuantity; // İade edilen miktar
  final double unitPrice;
  final String unitPriceCurrency; // Birim fiyat para birimi
  final double? unitPriceExchangeRate; // Birim fiyat kuru
  final double discountRate;
  final double discountAmount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String? reason; // İade nedeni
  final String? description;
  final String? notes;
  final Map<String, dynamic> metadata; // Ek bilgiler

  const SalesReturnItem({
    required this.id,
    required this.returnId,
    required this.originalSaleItemId,
    required this.productId,
    this.productName,
    this.productDescription,
    this.productSku,
    this.productBarcode,
    required this.originalQuantity,
    required this.returnedQuantity,
    required this.unitPrice,
    this.unitPriceCurrency = 'TRY',
    this.unitPriceExchangeRate,
    this.discountRate = 0.0,
    this.discountAmount = 0.0,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    this.reason,
    this.description,
    this.notes,
    this.metadata = const {},
  });

  /// CopyWith metodu
  SalesReturnItem copyWith({
    String? id,
    String? returnId,
    String? originalSaleItemId,
    String? productId,
    String? productName,
    String? productDescription,
    String? productSku,
    String? productBarcode,
    double? originalQuantity,
    double? returnedQuantity,
    double? unitPrice,
    String? unitPriceCurrency,
    double? unitPriceExchangeRate,
    double? discountRate,
    double? discountAmount,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    String? reason,
    String? description,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return SalesReturnItem(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      originalSaleItemId: originalSaleItemId ?? this.originalSaleItemId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productSku: productSku ?? this.productSku,
      productBarcode: productBarcode ?? this.productBarcode,
      originalQuantity: originalQuantity ?? this.originalQuantity,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unitPriceCurrency: unitPriceCurrency ?? this.unitPriceCurrency,
      unitPriceExchangeRate:
          unitPriceExchangeRate ?? this.unitPriceExchangeRate,
      discountRate: discountRate ?? this.discountRate,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON'dan SalesReturnItem oluştur
  factory SalesReturnItem.fromJson(Map<String, dynamic> json) {
    return SalesReturnItem(
      id: json['id'] as String,
      returnId: json['returnId'] as String,
      originalSaleItemId: json['originalSaleItemId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productDescription: json['productDescription'] as String?,
      productSku: json['productSku'] as String?,
      productBarcode: json['productBarcode'] as String?,
      originalQuantity: (json['originalQuantity'] as num).toDouble(),
      returnedQuantity: (json['returnedQuantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      unitPriceCurrency: json['unitPriceCurrency'] as String? ?? 'TRY',
      unitPriceExchangeRate:
          (json['unitPriceExchangeRate'] as num?)?.toDouble(),
      discountRate: (json['discountRate'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      reason: json['reason'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// SalesReturnItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'returnId': returnId,
      'originalSaleItemId': originalSaleItemId,
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productSku': productSku,
      'productBarcode': productBarcode,
      'originalQuantity': originalQuantity,
      'returnedQuantity': returnedQuantity,
      'unitPrice': unitPrice,
      'unitPriceCurrency': unitPriceCurrency,
      'unitPriceExchangeRate': unitPriceExchangeRate,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'reason': reason,
      'description': description,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Net tutar (indirim sonrası)
  double get netAmount => (unitPrice * returnedQuantity) - discountAmount;

  /// KDV dahil tutar
  double get amountWithTax => netAmount + taxAmount;

  /// İade yüzdesi
  double get returnPercentage {
    if (originalQuantity == 0) return 0;
    return (returnedQuantity / originalQuantity) * 100;
  }

  /// Tam iade mi?
  bool get isFullReturn => returnedQuantity >= originalQuantity;

  /// Kısmi iade mi?
  bool get isPartialReturn =>
      returnedQuantity > 0 && returnedQuantity < originalQuantity;

  /// Birim fiyat kur kilitleme yapılmış mı?
  bool get isUnitPriceExchangeRateLocked => unitPriceExchangeRate != null;

  @override
  String toString() {
    return 'SalesReturnItem(id: $id, productId: $productId, returnedQuantity: $returnedQuantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesReturnItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
