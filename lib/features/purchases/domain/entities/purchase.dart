// ========== PURCHASES DOMAIN ENTITY ==========
// lib/features/purchases/domain/entities/purchase.dart

/// Satın alma türü enum'u
enum PurchaseType {
  purchase('Normal Alış'),
  returnPurchase('Satıştan İade Alışı'),
  invoice('Fatura'),
  proforma('Proforma'),
  waybill('İrsaliye'),
  receipt('Fiş'),
  estimate('Teklif');

  const PurchaseType(this.displayName);
  final String displayName;
}

/// Satın alma durumu enum'u
enum PurchaseStatus {
  draft('Taslak'),
  pending('Beklemede'),
  confirmed('Onaylandı'),
  received('Teslim Alındı'),
  paid('Ödendi'),
  cancelled('İptal Edildi'),
  returned('İade Edildi');

  const PurchaseStatus(this.displayName);
  final String displayName;
}

/// Ödeme durumu enum'u
enum PurchasePaymentStatus {
  pending('Ödeme Bekliyor'),
  partial('Kısmi Ödeme'),
  paid('Ödendi'),
  overdue('Vadesi Geçmiş'),
  refunded('İade Edildi');

  const PurchasePaymentStatus(this.displayName);
  final String displayName;
}

/// Satın alma domain entity'si
class Purchase {
  final String id;
  final String tenantId; // Multi-tenant güvenlik için zorunlu
  final String purchaseNumber; // Satın alma numarası
  final PurchaseType type;
  final PurchaseStatus status;
  final PurchasePaymentStatus paymentStatus;
  final String supplierId;
  final String? supplierName; // Tedarikçi adı (lazy loading için)
  final DateTime purchaseDate;
  final DateTime? dueDate; // Vade tarihi
  final DateTime? receivedDate; // Teslim alma tarihi
  final double subtotal; // Alt toplam (KDV hariç)
  final double taxRate; // KDV oranı
  final double taxAmount; // KDV tutarı
  final double discountAmount; // İndirim tutarı
  final double totalAmount; // Toplam tutar
  final String currency;
  final String? notes; // Notlar
  final String? description; // Açıklama
  final String? shippingAddress; // Teslimat adresi
  final String? billingAddress; // Fatura adresi
  final double? shippingCost; // Kargo ücreti
  final String? paymentMethod; // Ödeme yöntemi
  final String? paymentTerms; // Ödeme koşulları
  final List<PurchaseItem> items; // Satın alma kalemleri
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy; // Oluşturan kullanıcı
  final String? updatedBy; // Güncelleyen kullanıcı

  const Purchase({
    required this.id,
    required this.tenantId,
    required this.purchaseNumber,
    required this.type,
    required this.status,
    required this.paymentStatus,
    required this.supplierId,
    this.supplierName,
    required this.purchaseDate,
    this.dueDate,
    this.receivedDate,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    this.notes,
    this.description,
    this.shippingAddress,
    this.billingAddress,
    this.shippingCost,
    this.paymentMethod,
    this.paymentTerms,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) &&
        paymentStatus != PurchasePaymentStatus.paid;
  }

  /// Ödeme bekliyor mu?
  bool get isPaymentPending {
    return paymentStatus == PurchasePaymentStatus.pending ||
        paymentStatus == PurchasePaymentStatus.overdue;
  }

  /// Kopyalama metodu
  Purchase copyWith({
    String? id,
    String? purchaseNumber,
    PurchaseType? type,
    PurchaseStatus? status,
    PurchasePaymentStatus? paymentStatus,
    String? supplierId,
    String? supplierName,
    DateTime? purchaseDate,
    DateTime? dueDate,
    DateTime? receivedDate,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    String? notes,
    String? description,
    String? shippingAddress,
    String? billingAddress,
    double? shippingCost,
    String? paymentMethod,
    String? paymentTerms,
    List<PurchaseItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Purchase(
      id: id ?? this.id,
      tenantId: tenantId,
      purchaseNumber: purchaseNumber ?? this.purchaseNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      dueDate: dueDate ?? this.dueDate,
      receivedDate: receivedDate ?? this.receivedDate,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingCost: shippingCost ?? this.shippingCost,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan oluşturma
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      purchaseNumber: json['purchaseNumber'] as String,
      type: PurchaseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PurchaseType.purchase,
      ),
      status: PurchaseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PurchaseStatus.draft,
      ),
      paymentStatus: PurchasePaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PurchasePaymentStatus.pending,
      ),
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
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
      notes: json['notes'] as String?,
      description: json['description'] as String?,
      shippingAddress: json['shippingAddress'] as String?,
      billingAddress: json['billingAddress'] as String?,
      shippingCost: json['shippingCost']?.toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (item) => PurchaseItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseNumber': purchaseNumber,
      'type': type.name,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'purchaseDate': purchaseDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'receivedDate': receivedDate?.toIso8601String(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'notes': notes,
      'description': description,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'shippingCost': shippingCost,
      'paymentMethod': paymentMethod,
      'paymentTerms': paymentTerms,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Purchase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Purchase(id: $id, purchaseNumber: $purchaseNumber, type: $type, status: $status)';
  }
}

/// Satın alma kalemi entity'si
class PurchaseItem {
  final String id;
  final String purchaseId;
  final String productId;
  final String? productName; // Ürün adı (lazy loading için)
  final String? productDescription; // Ürün açıklaması
  final String? productSku; // Ürün SKU
  final double quantity;
  final double unitPrice;
  final double discountRate; // İndirim oranı (%)
  final double discountAmount; // İndirim tutarı
  final double taxRate; // KDV oranı (%)
  final double taxAmount; // KDV tutarı
  final double totalAmount; // Toplam tutar
  final String? currency; // Para birimi
  final String? description; // Açıklama
  final String? notes; // Notlar

  const PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productId,
    this.productName,
    this.productDescription,
    this.productSku,
    required this.quantity,
    required this.unitPrice,
    this.discountRate = 0.0,
    this.discountAmount = 0.0,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    this.currency,
    this.description,
    this.notes,
  });

  /// Net tutar (indirim sonrası)
  double get netAmount => (unitPrice * quantity) - discountAmount;

  /// KDV dahil tutar
  double get amountWithTax => netAmount + taxAmount;

  /// Kopyalama metodu
  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    String? productName,
    String? productDescription,
    String? productSku,
    double? quantity,
    double? unitPrice,
    double? discountRate,
    double? discountAmount,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    String? currency,
    String? description,
    String? notes,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productSku: productSku ?? this.productSku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountRate: discountRate ?? this.discountRate,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan oluşturma
  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] as String,
      purchaseId: json['purchaseId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productDescription: json['productDescription'] as String?,
      productSku: json['productSku'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discountRate: (json['discountRate'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseId': purchaseId,
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productSku': productSku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'description': description,
      'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PurchaseItem(id: $id, productId: $productId, quantity: $quantity, unitPrice: $unitPrice)';
  }
}
