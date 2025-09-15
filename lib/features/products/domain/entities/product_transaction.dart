// ========== PRODUCT TRANSACTION DOMAIN ENTITY ==========
// lib/features/products/domain/entities/product_transaction.dart

import '../../../customers/domain/entities/customer.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import 'product.dart';

/// Ürün işlem geçmişi entity'si
class ProductTransaction {
  final int id;
  final int productId;
  final ProductTransactionType type;
  final String documentNumber; // Fatura, irsaliye, proforma numarası
  final double quantity;
  final double unitPrice;
  final double totalAmount;
  final String currency;
  final DateTime transactionDate;
  final String? description;
  final DateTime createdAt;
  final String? createdBy;

  // İlişkili müşteri veya tedarikçi
  final int? customerId;
  final int? supplierId;

  // Navigation properties (optional, for UI purposes)
  final Product? product;
  final Customer? customer;
  final Supplier? supplier;

  const ProductTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.documentNumber,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.currency,
    required this.transactionDate,
    this.description,
    required this.createdAt,
    this.createdBy,
    this.customerId,
    this.supplierId,
    this.product,
    this.customer,
    this.supplier,
  });

  /// Kar marjını hesaplar (sadece satış işlemleri için)
  double? get profitMargin {
    if (type != ProductTransactionType.sale) return null;
    // Burada maliyet fiyatı ile satış fiyatı arasındaki fark hesaplanabilir
    // Şimdilik null döndürüyoruz, daha sonra maliyet takibi eklendiğinde hesaplanacak
    return null;
  }

  /// Copy with method
  ProductTransaction copyWith({
    int? id,
    int? productId,
    ProductTransactionType? type,
    String? documentNumber,
    double? quantity,
    double? unitPrice,
    double? totalAmount,
    String? currency,
    DateTime? transactionDate,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    int? customerId,
    int? supplierId,
    Product? product,
    Customer? customer,
    Supplier? supplier,
  }) {
    return ProductTransaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      documentNumber: documentNumber ?? this.documentNumber,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      product: product ?? this.product,
      customer: customer ?? this.customer,
      supplier: supplier ?? this.supplier,
    );
  }

  /// Map'ten ProductTransaction oluşturur
  factory ProductTransaction.fromMap(Map<String, dynamic> map) {
    return ProductTransaction(
      id: map['id']?.toInt() ?? 0,
      productId: map['productId']?.toInt() ?? 0,
      type: ProductTransactionType.values[map['type'] ?? 0],
      documentNumber: map['documentNumber'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unitPrice: map['unitPrice']?.toDouble() ?? 0.0,
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'TRY',
      transactionDate: DateTime.parse(map['transactionDate']),
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
      customerId: map['customerId']?.toInt(),
      supplierId: map['supplierId']?.toInt(),
    );
  }

  /// ProductTransaction'u Map'e çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'type': type.index,
      'documentNumber': documentNumber,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'currency': currency,
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'customerId': customerId,
      'supplierId': supplierId,
    };
  }

  @override
  String toString() {
    return 'ProductTransaction(id: $id, productId: $productId, type: $type, documentNumber: $documentNumber, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Ürün işlem türü enum'u
enum ProductTransactionType {
  purchase, // Satın alma
  sale, // Satış
  return_, // İade
  adjustment, // Düzeltme
  transfer, // Transfer
  loss, // Fire/zayi
}

/// Ürün işlem türü için extension
extension ProductTransactionTypeExtension on ProductTransactionType {
  String get displayName {
    switch (this) {
      case ProductTransactionType.purchase:
        return 'Satın Alma';
      case ProductTransactionType.sale:
        return 'Satış';
      case ProductTransactionType.return_:
        return 'İade';
      case ProductTransactionType.adjustment:
        return 'Düzeltme';
      case ProductTransactionType.transfer:
        return 'Transfer';
      case ProductTransactionType.loss:
        return 'Fire/Zayi';
    }
  }

  String get shortName {
    switch (this) {
      case ProductTransactionType.purchase:
        return 'SATIN';
      case ProductTransactionType.sale:
        return 'SATIŞ';
      case ProductTransactionType.return_:
        return 'İADE';
      case ProductTransactionType.adjustment:
        return 'DÜZELT';
      case ProductTransactionType.transfer:
        return 'TRANSFER';
      case ProductTransactionType.loss:
        return 'FIRE';
    }
  }

  String get icon {
    switch (this) {
      case ProductTransactionType.purchase:
        return '📥';
      case ProductTransactionType.sale:
        return '📤';
      case ProductTransactionType.return_:
        return '↩️';
      case ProductTransactionType.adjustment:
        return '⚖️';
      case ProductTransactionType.transfer:
        return '🔄';
      case ProductTransactionType.loss:
        return '❌';
    }
  }

  /// İşlem türü satış mı?
  bool get isSale => this == ProductTransactionType.sale;

  /// İşlem türü satın alma mı?
  bool get isPurchase => this == ProductTransactionType.purchase;
}
