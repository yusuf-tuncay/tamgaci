import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';

/// Purchase model for Firebase integration
class PurchaseModel extends Purchase {
  const PurchaseModel({
    required super.id,
    required super.purchaseNumber,
    required super.type,
    required super.status,
    required super.paymentStatus,
    required super.supplierId,
    super.supplierName,
    required super.purchaseDate,
    super.dueDate,
    super.receivedDate,
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

  /// Firestore DocumentSnapshot'tan PurchaseModel oluşturur
  factory PurchaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PurchaseModel(
      id: doc.id,
      purchaseNumber: data['purchaseNumber'] as String,
      type: PurchaseType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PurchaseType.purchase,
      ),
      status: PurchaseStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PurchaseStatus.draft,
      ),
      paymentStatus: PurchasePaymentStatus.values.firstWhere(
        (e) => e.name == data['paymentStatus'],
        orElse: () => PurchasePaymentStatus.pending,
      ),
      supplierId: data['supplierId'] as String,
      supplierName: data['supplierName'] as String?,
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      receivedDate: (data['receivedDate'] as Timestamp?)?.toDate(),
      subtotal: (data['subtotal'] as num).toDouble(),
      taxRate: (data['taxRate'] as num).toDouble(),
      taxAmount: (data['taxAmount'] as num).toDouble(),
      discountAmount: (data['discountAmount'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      currency: data['currency'] as String,
      notes: data['notes'] as String?,
      description: data['description'] as String?,
      shippingAddress: data['shippingAddress'] as String?,
      billingAddress: data['billingAddress'] as String?,
      shippingCost: (data['shippingCost'] as num?)?.toDouble(),
      paymentMethod: data['paymentMethod'] as String?,
      paymentTerms: data['paymentTerms'] as String?,
      items: (data['items'] as List<dynamic>?)
              ?.map((item) =>
                  PurchaseItemModel.fromFirestore(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  PurchaseModel copyWith({
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
    return PurchaseModel(
      id: id ?? this.id,
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

  /// PurchaseModel'i Firestore'a uygun Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
      'purchaseNumber': purchaseNumber,
      'type': type.name,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'receivedDate':
          receivedDate != null ? Timestamp.fromDate(receivedDate!) : null,
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
      'items': items
          .map((item) => (item as PurchaseItemModel).toFirestore())
          .toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// PurchaseModel'i Purchase entity'sine dönüştürür
  Purchase toEntity() {
    return Purchase(
      id: id,
      purchaseNumber: purchaseNumber,
      type: type,
      status: status,
      paymentStatus: paymentStatus,
      supplierId: supplierId,
      supplierName: supplierName,
      purchaseDate: purchaseDate,
      dueDate: dueDate,
      receivedDate: receivedDate,
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

  /// Purchase entity'sinden PurchaseModel oluşturur
  factory PurchaseModel.fromEntity(Purchase purchase) {
    return PurchaseModel(
      id: purchase.id,
      purchaseNumber: purchase.purchaseNumber,
      type: purchase.type,
      status: purchase.status,
      paymentStatus: purchase.paymentStatus,
      supplierId: purchase.supplierId,
      supplierName: purchase.supplierName,
      purchaseDate: purchase.purchaseDate,
      dueDate: purchase.dueDate,
      receivedDate: purchase.receivedDate,
      subtotal: purchase.subtotal,
      taxRate: purchase.taxRate,
      taxAmount: purchase.taxAmount,
      discountAmount: purchase.discountAmount,
      totalAmount: purchase.totalAmount,
      currency: purchase.currency,
      notes: purchase.notes,
      description: purchase.description,
      shippingAddress: purchase.shippingAddress,
      billingAddress: purchase.billingAddress,
      shippingCost: purchase.shippingCost,
      paymentMethod: purchase.paymentMethod,
      paymentTerms: purchase.paymentTerms,
      items: purchase.items
          .map((item) => PurchaseItemModel.fromEntity(item))
          .toList(),
      createdAt: purchase.createdAt,
      updatedAt: purchase.updatedAt,
      createdBy: purchase.createdBy,
      updatedBy: purchase.updatedBy,
    );
  }
}

/// PurchaseItem model for Firebase integration
class PurchaseItemModel extends PurchaseItem {
  const PurchaseItemModel({
    required super.id,
    required super.purchaseId,
    required super.productId,
    super.productName,
    super.productDescription,
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
  });

  /// Firestore Map'ten PurchaseItemModel oluşturur
  factory PurchaseItemModel.fromFirestore(Map<String, dynamic> data) {
    return PurchaseItemModel(
      id: data['id'] as String,
      purchaseId: data['purchaseId'] as String,
      productId: data['productId'] as String,
      productName: data['productName'] as String?,
      productDescription: data['productDescription'] as String?,
      productSku: data['productSku'] as String?,
      quantity: (data['quantity'] as num).toDouble(),
      unitPrice: (data['unitPrice'] as num).toDouble(),
      discountRate: (data['discountRate'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (data['taxRate'] as num).toDouble(),
      taxAmount: (data['taxAmount'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      description: data['description'] as String?,
      notes: data['notes'] as String?,
    );
  }

  /// PurchaseItemModel'i Firestore'a uygun Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
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

  /// PurchaseItemModel'i PurchaseItem entity'sine dönüştürür
  PurchaseItem toEntity() {
    return PurchaseItem(
      id: id,
      purchaseId: purchaseId,
      productId: productId,
      productName: productName,
      productDescription: productDescription,
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
    );
  }

  /// PurchaseItem entity'sinden PurchaseItemModel oluşturur
  factory PurchaseItemModel.fromEntity(PurchaseItem item) {
    return PurchaseItemModel(
      id: item.id,
      purchaseId: item.purchaseId,
      productId: item.productId,
      productName: item.productName,
      productDescription: item.productDescription,
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
    );
  }
}
