import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';

/// Sales model sınıfı
/// Firebase Firestore ile uyumlu sales veri modeli
class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    required super.tenantId,
    required super.saleNumber,
    required super.type,
    required super.status,
    required super.paymentStatus,
    required super.customerId,
    super.customerName,
    required super.saleDate,
    super.dueDate,
    super.deliveryDate,
    required super.subtotal,
    required super.taxRate,
    required super.taxAmount,
    required super.discountAmount,
    required super.totalAmount,
    required super.currency,
    super.notes,
    super.description,
    super.shippingAddress,
    super.billingAddress,
    super.shippingCost,
    super.paymentMethod,
    super.paymentTerms,
    required super.items,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  /// Firebase Firestore'dan SaleModel oluşturur
  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      id: doc.id,
      tenantId: data['tenantId'] ?? '',
      saleNumber: data['saleNumber'] ?? '',
      type: SaleType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => SaleType.invoice,
      ),
      status: SaleStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SaleStatus.draft,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == data['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'],
      saleDate: (data['saleDate'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      deliveryDate: data['deliveryDate'] != null
          ? (data['deliveryDate'] as Timestamp).toDate()
          : null,
      subtotal: (data['subtotal'] as num).toDouble(),
      taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (data['taxAmount'] as num).toDouble(),
      discountAmount: (data['discountAmount'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      currency: data['currency'] ?? 'TRY',
      notes: data['notes'],
      description: data['description'],
      shippingAddress: data['shippingAddress'],
      billingAddress: data['billingAddress'],
      shippingCost: data['shippingCost']?.toDouble(),
      paymentMethod: data['paymentMethod'],
      paymentTerms: data['paymentTerms'],
      items: (data['items'] as List<dynamic>?)
              ?.map(
                  (item) => SaleItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
    );
  }

  /// SaleModel'ı Firebase Firestore'a dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
      'saleNumber': saleNumber,
      'type': type.name,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'customerId': customerId,
      'customerName': customerName,
      'saleDate': Timestamp.fromDate(saleDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'deliveryDate':
          deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
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
      'items':
          items.map((item) => SaleItemModel.fromEntity(item).toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// SaleModel'ı Sale entity'ye dönüştürür
  Sale toEntity() {
    return Sale(
      id: id,
      tenantId: tenantId,
      saleNumber: saleNumber,
      type: type,
      status: status,
      paymentStatus: paymentStatus,
      customerId: customerId,
      customerName: customerName,
      saleDate: saleDate,
      dueDate: dueDate,
      deliveryDate: deliveryDate,
      subtotal: subtotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      currency: currency,
      notes: notes,
      description: description,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      shippingCost: shippingCost,
      paymentMethod: paymentMethod,
      paymentTerms: paymentTerms,
      items: items,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Sale entity'den SaleModel oluşturur
  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      tenantId: sale.tenantId,
      saleNumber: sale.saleNumber,
      type: sale.type,
      status: sale.status,
      paymentStatus: sale.paymentStatus,
      customerId: sale.customerId,
      customerName: sale.customerName,
      saleDate: sale.saleDate,
      dueDate: sale.dueDate,
      deliveryDate: sale.deliveryDate,
      subtotal: sale.subtotal,
      taxRate: sale.taxRate,
      taxAmount: sale.taxAmount,
      discountAmount: sale.discountAmount,
      totalAmount: sale.totalAmount,
      currency: sale.currency,
      notes: sale.notes,
      description: sale.description,
      shippingAddress: sale.shippingAddress,
      billingAddress: sale.billingAddress,
      shippingCost: sale.shippingCost,
      paymentMethod: sale.paymentMethod,
      paymentTerms: sale.paymentTerms,
      items: sale.items,
      createdAt: sale.createdAt,
      updatedAt: sale.updatedAt,
      createdBy: sale.createdBy,
      updatedBy: sale.updatedBy,
    );
  }

  /// SaleModel'ı kopyalar ve belirtilen alanları günceller
  @override
  SaleModel copyWith({
    String? id,
    String? saleNumber,
    SaleType? type,
    SaleStatus? status,
    PaymentStatus? paymentStatus,
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
    return SaleModel(
      id: id ?? this.id,
      tenantId: tenantId,
      saleNumber: saleNumber ?? this.saleNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
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
}

/// SaleItem model sınıfı
class SaleItemModel extends SaleItem {
  const SaleItemModel({
    required super.id,
    required super.saleId,
    required super.productId,
    super.productName,
    super.productSku,
    required super.quantity,
    required super.unitPrice,
    super.discountRate,
    super.discountAmount,
    required super.taxRate,
    required super.taxAmount,
    required super.totalAmount,
    super.description,
    super.notes,
    required super.currency,
  });

  /// Map'ten SaleItemModel oluşturur
  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'] ?? '',
      saleId: map['saleId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'],
      productSku: map['productSku'],
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      discountRate: (map['discountRate'] as num).toDouble(),
      discountAmount: (map['discountAmount'] as num).toDouble(),
      taxRate: (map['taxRate'] as num).toDouble(),
      taxAmount: (map['taxAmount'] as num).toDouble(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      description: map['description'],
      notes: map['notes'],
      currency: map['currency'] ?? 'TRY',
    );
  }

  /// SaleItemModel'ı Map'e dönüştürür
  Map<String, dynamic> toMap() {
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
    };
  }

  /// SaleItemModel'ı SaleItem entity'ye dönüştürür
  SaleItem toEntity() {
    return SaleItem(
      id: id,
      saleId: saleId,
      productId: productId,
      productName: productName,
      productSku: productSku,
      quantity: quantity,
      unitPrice: unitPrice,
      discountRate: discountRate,
      discountAmount: discountAmount,
      taxRate: taxRate,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      description: description,
      notes: notes,
      currency: currency,
    );
  }

  /// SaleItem entity'den SaleItemModel oluşturur
  factory SaleItemModel.fromEntity(SaleItem item) {
    return SaleItemModel(
      id: item.id,
      saleId: item.saleId,
      productId: item.productId,
      productName: item.productName,
      productSku: item.productSku,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      discountRate: item.discountRate,
      discountAmount: item.discountAmount,
      taxRate: item.taxRate,
      taxAmount: item.taxAmount,
      totalAmount: item.totalAmount,
      description: item.description,
      notes: item.notes,
      currency: item.currency,
    );
  }
}
