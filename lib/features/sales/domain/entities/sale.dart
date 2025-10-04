// ========== SALES DOMAIN ENTITY ==========
// lib/features/sales/domain/entities/sale.dart

/// Satış türü enum'u
enum SaleType {
  sale('Satış'),
  invoice('Fatura'),
  proforma('Proforma'),
  waybill('İrsaliye'),
  receipt('Fiş'),
  estimate('Teklif');

  const SaleType(this.displayName);
  final String displayName;
}

/// Satış durumu enum'u
enum SaleStatus {
  draft('Taslak'),
  pending('Beklemede'),
  confirmed('Onaylandı'),
  shipped('Kargoya Verildi'),
  delivered('Teslim Edildi'),
  paid('Ödendi'),
  cancelled('İptal Edildi'),
  returned('İade Edildi');

  const SaleStatus(this.displayName);
  final String displayName;
}

/// Ödeme durumu enum'u
enum PaymentStatus {
  pending('Ödeme Bekliyor'),
  partial('Kısmi Ödeme'),
  paid('Ödendi'),
  overdue('Vadesi Geçmiş'),
  refunded('İade Edildi');

  const PaymentStatus(this.displayName);
  final String displayName;
}

/// Satış domain entity'si
class Sale {
  final String id;
  final String tenantId; // Multi-tenant güvenlik için zorunlu
  final String saleNumber; // Satış numarası
  final SaleType type;
  final SaleStatus status;
  final PaymentStatus paymentStatus;
  final bool isPaid; // Ödeme yapıldı mı?
  final String customerId;
  final String? customerName; // Müşteri adı (lazy loading için)
  final DateTime saleDate;
  final DateTime? dueDate; // Vade tarihi
  final DateTime? deliveryDate; // Teslimat tarihi
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
  final List<SaleItem> items; // Satış kalemleri
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy; // Oluşturan kullanıcı
  final String? updatedBy; // Güncelleyen kullanıcı

  const Sale({
    required this.id,
    required this.tenantId,
    required this.saleNumber,
    required this.type,
    required this.status,
    required this.paymentStatus,
    required this.isPaid,
    required this.customerId,
    this.customerName,
    required this.saleDate,
    this.dueDate,
    this.deliveryDate,
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

  /// KDV dahil toplam
  double get totalWithTax => subtotal + taxAmount;

  /// Net tutar (indirim sonrası)
  double get netAmount => subtotal - discountAmount;

  /// Final tutar (KDV + indirim sonrası)
  double get finalAmount => netAmount + taxAmount;

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    if (dueDate == null || paymentStatus == PaymentStatus.paid) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Ödeme bekliyor mu?
  bool get isPaymentPending {
    return paymentStatus == PaymentStatus.pending ||
        paymentStatus == PaymentStatus.overdue;
  }

  /// Kopyalama metodu
  Sale copyWith({
    String? id,
    String? saleNumber,
    SaleType? type,
    SaleStatus? status,
    PaymentStatus? paymentStatus,
    bool? isPaid,
    String? customerId,
    String? customerName,
    DateTime? saleDate,
    DateTime? dueDate,
    DateTime? deliveryDate,
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
    List<SaleItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Sale(
      id: id ?? this.id,
      tenantId: tenantId,
      saleNumber: saleNumber ?? this.saleNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      isPaid: isPaid ?? this.isPaid,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      saleDate: saleDate ?? this.saleDate,
      dueDate: dueDate ?? this.dueDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
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

  /// JSON'dan Sale oluşturma
  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      saleNumber: json['saleNumber'] as String,
      type: SaleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SaleType.invoice,
      ),
      status: SaleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SaleStatus.draft,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      isPaid: json['isPaid'] as bool? ?? false,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      saleDate: DateTime.parse(json['saleDate'] as String),
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
      notes: json['notes'] as String?,
      description: json['description'] as String?,
      shippingAddress: json['shippingAddress'] as String?,
      billingAddress: json['billingAddress'] as String?,
      shippingCost: json['shippingCost']?.toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
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
      'saleNumber': saleNumber,
      'type': type.name,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'isPaid': isPaid,
      'customerId': customerId,
      'customerName': customerName,
      'saleDate': saleDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
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
    return other is Sale && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Sale(id: $id, saleNumber: $saleNumber, type: $type, status: $status)';
  }
}

/// Satış kalemi entity'si
class SaleItem {
  final String id;
  final String saleId;
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
  final String? description; // Açıklama
  final String? notes; // Notlar
  final String currency; // Para birimi
  final double? fxRateToBase; // Kur bilgisi (base currency'ye dönüşüm oranı)

  const SaleItem({
    required this.id,
    required this.saleId,
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
    this.description,
    this.notes,
    required this.currency,
    this.fxRateToBase,
  });

  /// Net tutar (indirim sonrası)
  double get netAmount => (unitPrice * quantity) - discountAmount;

  /// KDV dahil tutar
  double get amountWithTax => netAmount + taxAmount;

  /// Kopyalama metodu
  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    String? productSku,
    double? quantity,
    double? unitPrice,
    double? discountRate,
    double? discountAmount,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    String? description,
    String? notes,
    String? currency,
    double? fxRateToBase,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountRate: discountRate ?? this.discountRate,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      currency: currency ?? this.currency,
      fxRateToBase: fxRateToBase ?? this.fxRateToBase,
    );
  }

  /// JSON'dan SaleItem oluşturma
  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] as String,
      saleId: json['saleId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productSku: json['productSku'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discountRate: (json['discountRate'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      currency: json['currency'] as String? ?? 'TRY',
      fxRateToBase: json['fxRateToBase'] != null
          ? (json['fxRateToBase'] as num).toDouble()
          : null,
    );
  }

  /// JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'productName': productName,
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
      'currency': currency,
      'fxRateToBase': fxRateToBase,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SaleItem(id: $id, productId: $productId, quantity: $quantity, unitPrice: $unitPrice)';
  }
}
