// ========== lib/features/invoices/domain/entities/invoice_item.dart ==========

// import '../../data/models/invoice_item_entity.dart'; // Removed - using Firebase only

/// Fatura kalemi domain entity'si
class InvoiceItem {
  /// Fatura kalemi benzersiz ID'si
  final String id;

  /// Fatura ID'si
  final String invoiceId;

  /// Kalem sıra numarası
  final int itemOrder;

  /// Ürün ID'si (kayıtlı ürünlerden seçim için)
  final String? productId;

  /// Ürün/Hizmet adı
  final String productName;

  /// Açıklama
  final String? description;

  /// Miktar
  final double quantity;

  /// Birim
  final String? unit;

  /// Birim fiyat
  final double unitPrice;

  /// İndirim oranı (örn: 10.0 = %10)
  final double discountRate;

  /// İndirim tutarı
  final double discountAmount;

  /// KDV oranı (örn: 18.0 = %18)
  final double taxRate;

  /// KDV tutarı
  final double taxAmount;

  /// Toplam tutar (KDV hariç)
  final double lineTotal;

  /// Para birimi kodu
  final String currencyCode;

  /// Döviz kuru (farklı para birimi kullanılıyorsa)
  final double? exchangeRate;

  /// Döviz kuru tarihi
  final DateTime? exchangeRateDate;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.itemOrder,
    this.productId,
    required this.productName,
    this.description,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    this.discountRate = 0.0,
    this.discountAmount = 0.0,
    required this.taxRate,
    required this.taxAmount,
    required this.lineTotal,
    this.currencyCode = 'TRY',
    this.exchangeRate,
    this.exchangeRateDate,
    required this.createdAt,
  });

  /// JSON'dan InvoiceItem oluştur
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      itemOrder: json['itemOrder'] as int,
      productId: json['productId'] as String?,
      productName: json['productName'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discountRate: (json['discountRate'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'TRY',
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      exchangeRateDate: json['exchangeRateDate'] != null
          ? DateTime.parse(json['exchangeRateDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// InvoiceItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'itemOrder': itemOrder,
      'productId': productId,
      'productName': productName,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'lineTotal': lineTotal,
      'currencyCode': currencyCode,
      'exchangeRate': exchangeRate,
      'exchangeRateDate': exchangeRateDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// CopyWith metodu
  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    int? itemOrder,
    String? productId,
    String? productName,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? discountRate,
    double? discountAmount,
    double? taxRate,
    double? taxAmount,
    double? lineTotal,
    String? currencyCode,
    double? exchangeRate,
    DateTime? exchangeRateDate,
    DateTime? createdAt,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      itemOrder: itemOrder ?? this.itemOrder,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      discountRate: discountRate ?? this.discountRate,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      lineTotal: lineTotal ?? this.lineTotal,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      exchangeRateDate: exchangeRateDate ?? this.exchangeRateDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ========== BUSINESS LOGIC METODLARI ==========

  /// Para birimi sembolü
  String get currencySymbol {
    switch (currencyCode) {
      case 'TRY':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currencyCode;
    }
  }

  /// Formatlanmış birim fiyat
  String get formattedUnitPrice {
    return '${unitPrice.toStringAsFixed(2)} $currencySymbol';
  }

  /// Formatlanmış satır toplamı
  String get formattedLineTotal {
    return '${lineTotal.toStringAsFixed(2)} $currencySymbol';
  }

  /// Formatlanmış KDV tutarı
  String get formattedTaxAmount {
    return '${taxAmount.toStringAsFixed(2)} $currencySymbol';
  }

  /// Formatlanmış miktar ve birim
  String get formattedQuantity {
    if (unit != null && unit!.isNotEmpty) {
      return '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)} $unit';
    }
    return quantity
        .toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1);
  }

  /// KDV dahil toplam tutar
  double get totalWithTax {
    return lineTotal + taxAmount;
  }

  /// Formatlanmış KDV dahil toplam
  String get formattedTotalWithTax {
    return '${totalWithTax.toStringAsFixed(2)} $currencySymbol';
  }

  /// Ürün açıklaması (boşsa ürün adı)
  String get displayDescription {
    return description?.isNotEmpty == true ? description! : productName;
  }

  /// Tutarları yeniden hesapla
  InvoiceItem recalculate() {
    final newLineTotal = quantity * unitPrice;
    final newTaxAmount = newLineTotal * (taxRate / 100.0);

    return copyWith(
      lineTotal: newLineTotal,
      taxAmount: newTaxAmount,
    );
  }

  /// Factory constructor - Hesaplamalı oluşturma
  factory InvoiceItem.create({
    required String id,
    required String invoiceId,
    required int itemOrder,
    String? productId,
    required String productName,
    String? description,
    required double quantity,
    String? unit,
    required double unitPrice,
    required double taxRate,
    String currencyCode = 'TRY',
    double? exchangeRate,
    DateTime? exchangeRateDate,
  }) {
    final lineTotal = quantity * unitPrice;
    final taxAmount = lineTotal * (taxRate / 100.0);

    return InvoiceItem(
      id: id,
      invoiceId: invoiceId,
      itemOrder: itemOrder,
      productId: productId,
      productName: productName,
      description: description,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      taxRate: taxRate,
      taxAmount: taxAmount,
      lineTotal: lineTotal,
      currencyCode: currencyCode,
      exchangeRate: exchangeRate,
      exchangeRateDate: exchangeRateDate,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'InvoiceItem(id: $id, product: $productName, quantity: $quantity, total: $formattedLineTotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
