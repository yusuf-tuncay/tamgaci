// ========== lib/features/invoices/domain/entities/invoice_item.dart ==========

import '../../data/models/invoice_item_entity.dart';

/// Fatura kalemi domain entity'si
class InvoiceItem {
  /// Fatura kalemi benzersiz ID'si
  final String id;

  /// Fatura ID'si
  final String invoiceId;

  /// Kalem sıra numarası
  final int itemOrder;

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

  /// KDV oranı (örn: 18.0 = %18)
  final double taxRate;

  /// KDV tutarı
  final double taxAmount;

  /// Toplam tutar (KDV hariç)
  final double lineTotal;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.itemOrder,
    required this.productName,
    this.description,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    required this.taxRate,
    required this.taxAmount,
    required this.lineTotal,
    required this.createdAt,
  });

  /// InvoiceItemEntity'den InvoiceItem'a dönüştürme
  factory InvoiceItem.fromEntity(InvoiceItemEntity entity) {
    return InvoiceItem(
      id: entity.id,
      invoiceId: entity.invoiceId,
      itemOrder: entity.itemOrder,
      productName: entity.productName,
      description: entity.description,
      quantity: entity.quantity,
      unit: entity.unit,
      unitPrice: entity.unitPrice / 100.0, // Kuruştan liraya
      taxRate: entity.taxRate,
      taxAmount: entity.taxAmount / 100.0,
      lineTotal: entity.lineTotal / 100.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
    );
  }

  /// InvoiceItem'dan InvoiceItemEntity'ye dönüştürme
  InvoiceItemEntity toEntity() {
    return InvoiceItemEntity(
      id: id,
      invoiceId: invoiceId,
      itemOrder: itemOrder,
      productName: productName,
      description: description,
      quantity: quantity,
      unit: unit,
      unitPrice: (unitPrice * 100).round(), // Liradan kuruşa
      taxRate: taxRate,
      taxAmount: (taxAmount * 100).round(),
      lineTotal: (lineTotal * 100).round(),
      createdAt: createdAt.millisecondsSinceEpoch,
    );
  }

  /// CopyWith metodu
  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    int? itemOrder,
    String? productName,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? taxRate,
    double? taxAmount,
    double? lineTotal,
    DateTime? createdAt,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      itemOrder: itemOrder ?? this.itemOrder,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      lineTotal: lineTotal ?? this.lineTotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ========== BUSINESS LOGIC METODLARI ==========

  /// Formatlanmış birim fiyat
  String get formattedUnitPrice {
    return '${unitPrice.toStringAsFixed(2)} ₺';
  }

  /// Formatlanmış satır toplamı
  String get formattedLineTotal {
    return '${lineTotal.toStringAsFixed(2)} ₺';
  }

  /// Formatlanmış KDV tutarı
  String get formattedTaxAmount {
    return '${taxAmount.toStringAsFixed(2)} ₺';
  }

  /// Formatlanmış miktar ve birim
  String get formattedQuantity {
    if (unit != null && unit!.isNotEmpty) {
      return '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)} $unit';
    }
    return quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1);
  }

  /// KDV dahil toplam tutar
  double get totalWithTax {
    return lineTotal + taxAmount;
  }

  /// Formatlanmış KDV dahil toplam
  String get formattedTotalWithTax {
    return '${totalWithTax.toStringAsFixed(2)} ₺';
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
    required String productName,
    String? description,
    required double quantity,
    String? unit,
    required double unitPrice,
    required double taxRate,
  }) {
    final lineTotal = quantity * unitPrice;
    final taxAmount = lineTotal * (taxRate / 100.0);
    
    return InvoiceItem(
      id: id,
      invoiceId: invoiceId,
      itemOrder: itemOrder,
      productName: productName,
      description: description,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      taxRate: taxRate,
      taxAmount: taxAmount,
      lineTotal: lineTotal,
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
