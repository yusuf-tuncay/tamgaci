// ========== SALES FLOW ENTITY ==========
// lib/features/sales/domain/entities/sales_flow.dart

/// Satış belgesi türü
enum SalesDocumentType {
  quote('Teklif'),
  order('Sipariş'),
  waybill('İrsaliye'),
  invoice('Fatura'),
  creditNote('İade Faturası'),
  debitNote('Borç Dekontu');

  const SalesDocumentType(this.displayName);
  final String displayName;
}

/// Satış belgesi durumu
enum SalesDocumentStatus {
  draft('Taslak'),
  pending('Beklemede'),
  approved('Onaylandı'),
  sent('Gönderildi'),
  confirmed('Onaylandı'),
  shipped('Kargoya Verildi'),
  delivered('Teslim Edildi'),
  invoiced('Faturalandı'),
  paid('Ödendi'),
  cancelled('İptal Edildi'),
  returned('İade Edildi');

  const SalesDocumentStatus(this.displayName);
  final String displayName;
}

/// Satış belgesi entity'si
class SalesDocument {
  final String id;
  final String documentNumber;
  final SalesDocumentType type;
  final SalesDocumentStatus status;
  final String?
      parentDocumentId; // Üst belge ID'si (teklif->sipariş->irsaliye->fatura)
  final String? parentDocumentNumber; // Üst belge numarası
  final String customerId;
  final String? customerName;
  final DateTime documentDate;
  final DateTime? validUntil; // Geçerlilik tarihi (teklif için)
  final DateTime? dueDate; // Vade tarihi
  final DateTime? deliveryDate; // Teslimat tarihi
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
  final List<SalesDocumentItem> items;
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const SalesDocument({
    required this.id,
    required this.documentNumber,
    required this.type,
    required this.status,
    this.parentDocumentId,
    this.parentDocumentNumber,
    required this.customerId,
    this.customerName,
    required this.documentDate,
    this.validUntil,
    this.dueDate,
    this.deliveryDate,
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
  SalesDocument copyWith({
    String? id,
    String? documentNumber,
    SalesDocumentType? type,
    SalesDocumentStatus? status,
    String? parentDocumentId,
    String? parentDocumentNumber,
    String? customerId,
    String? customerName,
    DateTime? documentDate,
    DateTime? validUntil,
    DateTime? dueDate,
    DateTime? deliveryDate,
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
    List<SalesDocumentItem>? items,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return SalesDocument(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      parentDocumentId: parentDocumentId ?? this.parentDocumentId,
      parentDocumentNumber: parentDocumentNumber ?? this.parentDocumentNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      documentDate: documentDate ?? this.documentDate,
      validUntil: validUntil ?? this.validUntil,
      dueDate: dueDate ?? this.dueDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
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

  /// JSON'dan SalesDocument oluştur
  factory SalesDocument.fromJson(Map<String, dynamic> json) {
    return SalesDocument(
      id: json['id'] as String,
      documentNumber: json['documentNumber'] as String,
      type: SalesDocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SalesDocumentType.quote,
      ),
      status: SalesDocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SalesDocumentStatus.draft,
      ),
      parentDocumentId: json['parentDocumentId'] as String?,
      parentDocumentNumber: json['parentDocumentNumber'] as String?,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      documentDate: DateTime.parse(json['documentDate'] as String),
      validUntil: json['validUntil'] != null
          ? DateTime.parse(json['validUntil'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'] as String)
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
              ?.map(
                  (e) => SalesDocumentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// SalesDocument'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentNumber': documentNumber,
      'type': type.name,
      'status': status.name,
      'parentDocumentId': parentDocumentId,
      'parentDocumentNumber': parentDocumentNumber,
      'customerId': customerId,
      'customerName': customerName,
      'documentDate': documentDate.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
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
    return status == SalesDocumentStatus.draft ||
        status == SalesDocumentStatus.pending;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status != SalesDocumentStatus.cancelled &&
        status != SalesDocumentStatus.returned;
  }

  @override
  String toString() {
    return 'SalesDocument(id: $id, documentNumber: $documentNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Satış belgesi kalemi
class SalesDocumentItem {
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

  const SalesDocumentItem({
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
  SalesDocumentItem copyWith({
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
    return SalesDocumentItem(
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

  /// JSON'dan SalesDocumentItem oluştur
  factory SalesDocumentItem.fromJson(Map<String, dynamic> json) {
    return SalesDocumentItem(
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

  /// SalesDocumentItem'ı JSON'a çevir
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
    return 'SalesDocumentItem(id: $id, productId: $productId, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesDocumentItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
