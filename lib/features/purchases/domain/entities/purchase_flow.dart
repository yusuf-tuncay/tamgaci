// ========== PURCHASE FLOW ENTITY ==========
// lib/features/purchases/domain/entities/purchase_flow.dart

/// Satınalma belgesi türü
enum PurchaseDocumentType {
  request('Satınalma Talebi'),
  quote('Teklif'),
  order('Satınalma Siparişi'),
  waybill('İrsaliye'),
  invoice('Alış Faturası'),
  creditNote('İade Faturası'),
  debitNote('Alacak Dekontu');

  const PurchaseDocumentType(this.displayName);
  final String displayName;
}

/// Satınalma belgesi durumu
enum PurchaseDocumentStatus {
  draft('Taslak'),
  pending('Beklemede'),
  approved('Onaylandı'),
  sent('Gönderildi'),
  confirmed('Onaylandı'),
  received('Teslim Alındı'),
  invoiced('Faturalandı'),
  paid('Ödendi'),
  cancelled('İptal Edildi'),
  returned('İade Edildi');

  const PurchaseDocumentStatus(this.displayName);
  final String displayName;
}

/// Satınalma belgesi entity'si
class PurchaseDocument {
  final String id;
  final String documentNumber;
  final PurchaseDocumentType type;
  final PurchaseDocumentStatus status;
  final String?
      parentDocumentId; // Üst belge ID'si (talep->sipariş->irsaliye->fatura)
  final String? parentDocumentNumber; // Üst belge numarası
  final String supplierId;
  final String? supplierName;
  final DateTime documentDate;
  final DateTime? validUntil; // Geçerlilik tarihi (teklif için)
  final DateTime? dueDate; // Vade tarihi
  final DateTime? receivedDate; // Teslim alma tarihi
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final double? exchangeRate; // Döviz kuru (kilitleme için)
  final String? exchangeRateSource; // Kur kaynağı
  final DateTime? exchangeRateDate; // Kur tarihi
  final String? notes;
  final String? description;
  final String? shippingAddress;
  final String? billingAddress;
  final double? shippingCost;
  final String? paymentMethod;
  final String? paymentTerms;
  final List<PurchaseDocumentItem> items;
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const PurchaseDocument({
    required this.id,
    required this.documentNumber,
    required this.type,
    required this.status,
    this.parentDocumentId,
    this.parentDocumentNumber,
    required this.supplierId,
    this.supplierName,
    required this.documentDate,
    this.validUntil,
    this.dueDate,
    this.receivedDate,
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
    this.description,
    this.shippingAddress,
    this.billingAddress,
    this.shippingCost,
    this.paymentMethod,
    this.paymentTerms,
    this.items = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  PurchaseDocument copyWith({
    String? id,
    String? documentNumber,
    PurchaseDocumentType? type,
    PurchaseDocumentStatus? status,
    String? parentDocumentId,
    String? parentDocumentNumber,
    String? supplierId,
    String? supplierName,
    DateTime? documentDate,
    DateTime? validUntil,
    DateTime? dueDate,
    DateTime? receivedDate,
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
    String? description,
    String? shippingAddress,
    String? billingAddress,
    double? shippingCost,
    String? paymentMethod,
    String? paymentTerms,
    List<PurchaseDocumentItem>? items,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PurchaseDocument(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      parentDocumentId: parentDocumentId ?? this.parentDocumentId,
      parentDocumentNumber: parentDocumentNumber ?? this.parentDocumentNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      documentDate: documentDate ?? this.documentDate,
      validUntil: validUntil ?? this.validUntil,
      dueDate: dueDate ?? this.dueDate,
      receivedDate: receivedDate ?? this.receivedDate,
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
      description: description ?? this.description,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingCost: shippingCost ?? this.shippingCost,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan PurchaseDocument oluştur
  factory PurchaseDocument.fromJson(Map<String, dynamic> json) {
    return PurchaseDocument(
      id: json['id'] as String,
      documentNumber: json['documentNumber'] as String,
      type: PurchaseDocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PurchaseDocumentType.request,
      ),
      status: PurchaseDocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PurchaseDocumentStatus.draft,
      ),
      parentDocumentId: json['parentDocumentId'] as String?,
      parentDocumentNumber: json['parentDocumentNumber'] as String?,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      documentDate: DateTime.parse(json['documentDate'] as String),
      validUntil: json['validUntil'] != null
          ? DateTime.parse(json['validUntil'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      receivedDate: json['receivedDate'] != null
          ? DateTime.parse(json['receivedDate'] as String)
          : null,
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
      description: json['description'] as String?,
      shippingAddress: json['shippingAddress'] as String?,
      billingAddress: json['billingAddress'] as String?,
      shippingCost: (json['shippingCost'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  PurchaseDocumentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// PurchaseDocument'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentNumber': documentNumber,
      'type': type.name,
      'status': status.name,
      'parentDocumentId': parentDocumentId,
      'parentDocumentNumber': parentDocumentNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'documentDate': documentDate.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'receivedDate': receivedDate?.toIso8601String(),
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
      'description': description,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'shippingCost': shippingCost,
      'paymentMethod': paymentMethod,
      'paymentTerms': paymentTerms,
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

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Geçerliliği dolmuş mu? (teklif için)
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Onaylanabilir mi?
  bool get canBeApproved {
    return status == PurchaseDocumentStatus.draft ||
        status == PurchaseDocumentStatus.pending;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status != PurchaseDocumentStatus.cancelled &&
        status != PurchaseDocumentStatus.returned;
  }

  @override
  String toString() {
    return 'PurchaseDocument(id: $id, documentNumber: $documentNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Satınalma belgesi kalemi
class PurchaseDocumentItem {
  final String id;
  final String documentId;
  final String productId;
  final String? productName;
  final String? productDescription;
  final String? productSku;
  final String? productBarcode;
  final double quantity;
  final double unitPrice;
  final String unitPriceCurrency; // Birim fiyat para birimi
  final double? unitPriceExchangeRate; // Birim fiyat kuru
  final double discountRate;
  final double discountAmount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String? description;
  final String? notes;
  final Map<String, dynamic> metadata; // Ek bilgiler

  const PurchaseDocumentItem({
    required this.id,
    required this.documentId,
    required this.productId,
    this.productName,
    this.productDescription,
    this.productSku,
    this.productBarcode,
    required this.quantity,
    required this.unitPrice,
    this.unitPriceCurrency = 'TRY',
    this.unitPriceExchangeRate,
    this.discountRate = 0.0,
    this.discountAmount = 0.0,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    this.description,
    this.notes,
    this.metadata = const {},
  });

  /// CopyWith metodu
  PurchaseDocumentItem copyWith({
    String? id,
    String? documentId,
    String? productId,
    String? productName,
    String? productDescription,
    String? productSku,
    String? productBarcode,
    double? quantity,
    double? unitPrice,
    String? unitPriceCurrency,
    double? unitPriceExchangeRate,
    double? discountRate,
    double? discountAmount,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    String? description,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return PurchaseDocumentItem(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productSku: productSku ?? this.productSku,
      productBarcode: productBarcode ?? this.productBarcode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unitPriceCurrency: unitPriceCurrency ?? this.unitPriceCurrency,
      unitPriceExchangeRate:
          unitPriceExchangeRate ?? this.unitPriceExchangeRate,
      discountRate: discountRate ?? this.discountRate,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON'dan PurchaseDocumentItem oluştur
  factory PurchaseDocumentItem.fromJson(Map<String, dynamic> json) {
    return PurchaseDocumentItem(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productDescription: json['productDescription'] as String?,
      productSku: json['productSku'] as String?,
      productBarcode: json['productBarcode'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      unitPriceCurrency: json['unitPriceCurrency'] as String? ?? 'TRY',
      unitPriceExchangeRate:
          (json['unitPriceExchangeRate'] as num?)?.toDouble(),
      discountRate: (json['discountRate'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// PurchaseDocumentItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productSku': productSku,
      'productBarcode': productBarcode,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'unitPriceCurrency': unitPriceCurrency,
      'unitPriceExchangeRate': unitPriceExchangeRate,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'description': description,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Net tutar (indirim sonrası)
  double get netAmount => (unitPrice * quantity) - discountAmount;

  /// KDV dahil tutar
  double get amountWithTax => netAmount + taxAmount;

  /// Birim fiyat kur kilitleme yapılmış mı?
  bool get isUnitPriceExchangeRateLocked => unitPriceExchangeRate != null;

  @override
  String toString() {
    return 'PurchaseDocumentItem(id: $id, productId: $productId, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseDocumentItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
