// ========== E-DESPATCH ENTITY ==========
// lib/features/regulatory/domain/entities/e_despatch.dart

/// e-İrsaliye türü
enum EDespatchType {
  sales('Satış İrsaliyesi'),
  purchase('Alış İrsaliyesi'),
  transfer('Transfer İrsaliyesi'),
  returnGoods('İade İrsaliyesi'),
  adjustment('Düzeltme İrsaliyesi');

  const EDespatchType(this.displayName);
  final String displayName;
}

/// e-İrsaliye durumu
enum EDespatchStatus {
  draft('Taslak'),
  sent('Gönderildi'),
  accepted('Kabul Edildi'),
  rejected('Reddedildi'),
  cancelled('İptal Edildi'),
  archived('Arşivlendi');

  const EDespatchStatus(this.displayName);
  final String displayName;
}

/// e-İrsaliye entity'si
class EDespatch {
  final String id;
  final String despatchNumber;
  final String? eDespatchNumber; // e-İrsaliye numarası
  final EDespatchType type;
  final EDespatchStatus status;
  final String? customerId;
  final String? customerName;
  final String? customerTaxNumber;
  final String? supplierId;
  final String? supplierName;
  final String? supplierTaxNumber;
  final String? fromWarehouseId;
  final String? fromWarehouseName;
  final String? toWarehouseId;
  final String? toWarehouseName;
  final double totalAmount;
  final double taxAmount;
  final double netAmount;
  final String currency;
  final DateTime despatchDate;
  final DateTime? eDespatchDate; // e-İrsaliye tarihi
  final DateTime? sentDate; // Gönderim tarihi
  final DateTime? acceptedDate; // Kabul tarihi
  final DateTime? rejectedDate; // Red tarihi
  final String? rejectionReason; // Red nedeni
  final String? gibDespatchId; // GİB irsaliye ID'si
  final String? gibDespatchUuid; // GİB irsaliye UUID
  final String? envelopeId; // Zarf ID'si
  final String? envelopeUuid; // Zarf UUID
  final String? description;
  final String? notes;
  final List<EDespatchItem> items;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const EDespatch({
    required this.id,
    required this.despatchNumber,
    this.eDespatchNumber,
    required this.type,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerTaxNumber,
    this.supplierId,
    this.supplierName,
    this.supplierTaxNumber,
    this.fromWarehouseId,
    this.fromWarehouseName,
    this.toWarehouseId,
    this.toWarehouseName,
    required this.totalAmount,
    required this.taxAmount,
    required this.netAmount,
    required this.currency,
    required this.despatchDate,
    this.eDespatchDate,
    this.sentDate,
    this.acceptedDate,
    this.rejectedDate,
    this.rejectionReason,
    this.gibDespatchId,
    this.gibDespatchUuid,
    this.envelopeId,
    this.envelopeUuid,
    this.description,
    this.notes,
    this.items = const [],
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  EDespatch copyWith({
    String? id,
    String? despatchNumber,
    String? eDespatchNumber,
    EDespatchType? type,
    EDespatchStatus? status,
    String? customerId,
    String? customerName,
    String? customerTaxNumber,
    String? supplierId,
    String? supplierName,
    String? supplierTaxNumber,
    String? fromWarehouseId,
    String? fromWarehouseName,
    String? toWarehouseId,
    String? toWarehouseName,
    double? totalAmount,
    double? taxAmount,
    double? netAmount,
    String? currency,
    DateTime? despatchDate,
    DateTime? eDespatchDate,
    DateTime? sentDate,
    DateTime? acceptedDate,
    DateTime? rejectedDate,
    String? rejectionReason,
    String? gibDespatchId,
    String? gibDespatchUuid,
    String? envelopeId,
    String? envelopeUuid,
    String? description,
    String? notes,
    List<EDespatchItem>? items,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return EDespatch(
      id: id ?? this.id,
      despatchNumber: despatchNumber ?? this.despatchNumber,
      eDespatchNumber: eDespatchNumber ?? this.eDespatchNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerTaxNumber: customerTaxNumber ?? this.customerTaxNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierTaxNumber: supplierTaxNumber ?? this.supplierTaxNumber,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      fromWarehouseName: fromWarehouseName ?? this.fromWarehouseName,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      toWarehouseName: toWarehouseName ?? this.toWarehouseName,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      netAmount: netAmount ?? this.netAmount,
      currency: currency ?? this.currency,
      despatchDate: despatchDate ?? this.despatchDate,
      eDespatchDate: eDespatchDate ?? this.eDespatchDate,
      sentDate: sentDate ?? this.sentDate,
      acceptedDate: acceptedDate ?? this.acceptedDate,
      rejectedDate: rejectedDate ?? this.rejectedDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      gibDespatchId: gibDespatchId ?? this.gibDespatchId,
      gibDespatchUuid: gibDespatchUuid ?? this.gibDespatchUuid,
      envelopeId: envelopeId ?? this.envelopeId,
      envelopeUuid: envelopeUuid ?? this.envelopeUuid,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan EDespatch oluştur
  factory EDespatch.fromJson(Map<String, dynamic> json) {
    return EDespatch(
      id: json['id'] as String,
      despatchNumber: json['despatchNumber'] as String,
      eDespatchNumber: json['eDespatchNumber'] as String?,
      type: EDespatchType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EDespatchType.sales,
      ),
      status: EDespatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EDespatchStatus.draft,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerTaxNumber: json['customerTaxNumber'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierTaxNumber: json['supplierTaxNumber'] as String?,
      fromWarehouseId: json['fromWarehouseId'] as String?,
      fromWarehouseName: json['fromWarehouseName'] as String?,
      toWarehouseId: json['toWarehouseId'] as String?,
      toWarehouseName: json['toWarehouseName'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      despatchDate: DateTime.parse(json['despatchDate'] as String),
      eDespatchDate: json['eDespatchDate'] != null
          ? DateTime.parse(json['eDespatchDate'] as String)
          : null,
      sentDate: json['sentDate'] != null
          ? DateTime.parse(json['sentDate'] as String)
          : null,
      acceptedDate: json['acceptedDate'] != null
          ? DateTime.parse(json['acceptedDate'] as String)
          : null,
      rejectedDate: json['rejectedDate'] != null
          ? DateTime.parse(json['rejectedDate'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      gibDespatchId: json['gibDespatchId'] as String?,
      gibDespatchUuid: json['gibDespatchUuid'] as String?,
      envelopeId: json['envelopeId'] as String?,
      envelopeUuid: json['envelopeUuid'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => EDespatchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// EDespatch'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'despatchNumber': despatchNumber,
      'eDespatchNumber': eDespatchNumber,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'customerTaxNumber': customerTaxNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierTaxNumber': supplierTaxNumber,
      'fromWarehouseId': fromWarehouseId,
      'fromWarehouseName': fromWarehouseName,
      'toWarehouseId': toWarehouseId,
      'toWarehouseName': toWarehouseName,
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'netAmount': netAmount,
      'currency': currency,
      'despatchDate': despatchDate.toIso8601String(),
      'eDespatchDate': eDespatchDate?.toIso8601String(),
      'sentDate': sentDate?.toIso8601String(),
      'acceptedDate': acceptedDate?.toIso8601String(),
      'rejectedDate': rejectedDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'gibDespatchId': gibDespatchId,
      'gibDespatchUuid': gibDespatchUuid,
      'envelopeId': envelopeId,
      'envelopeUuid': envelopeUuid,
      'description': description,
      'notes': notes,
      'items': items.map((e) => e.toJson()).toList(),
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Taslak mı?
  bool get isDraft => status == EDespatchStatus.draft;

  /// Gönderildi mi?
  bool get isSent => status == EDespatchStatus.sent;

  /// Kabul edildi mi?
  bool get isAccepted => status == EDespatchStatus.accepted;

  /// Reddedildi mi?
  bool get isRejected => status == EDespatchStatus.rejected;

  /// İptal edildi mi?
  bool get isCancelled => status == EDespatchStatus.cancelled;

  /// Arşivlendi mi?
  bool get isArchived => status == EDespatchStatus.archived;

  /// Satış irsaliyesi mi?
  bool get isSalesDespatch => type == EDespatchType.sales;

  /// Alış irsaliyesi mi?
  bool get isPurchaseDespatch => type == EDespatchType.purchase;

  /// Transfer irsaliyesi mi?
  bool get isTransferDespatch => type == EDespatchType.transfer;

  /// İade irsaliyesi mi?
  bool get isReturnDespatch => type == EDespatchType.returnGoods;

  /// Düzeltme irsaliyesi mi?
  bool get isAdjustmentDespatch => type == EDespatchType.adjustment;

  /// Müşteri irsaliyesi mi?
  bool get isCustomerDespatch => customerId != null;

  /// Tedarikçi irsaliyesi mi?
  bool get isSupplierDespatch => supplierId != null;

  /// e-İrsaliye numarası var mı?
  bool get hasEDespatchNumber =>
      eDespatchNumber != null && eDespatchNumber!.isNotEmpty;

  /// GİB irsaliye ID'si var mı?
  bool get hasGibDespatchId =>
      gibDespatchId != null && gibDespatchId!.isNotEmpty;

  /// GİB irsaliye UUID var mı?
  bool get hasGibDespatchUuid =>
      gibDespatchUuid != null && gibDespatchUuid!.isNotEmpty;

  /// Zarf ID'si var mı?
  bool get hasEnvelopeId => envelopeId != null && envelopeId!.isNotEmpty;

  /// Zarf UUID var mı?
  bool get hasEnvelopeUuid => envelopeUuid != null && envelopeUuid!.isNotEmpty;

  /// Müşteri vergi numarası var mı?
  bool get hasCustomerTaxNumber =>
      customerTaxNumber != null && customerTaxNumber!.isNotEmpty;

  /// Tedarikçi vergi numarası var mı?
  bool get hasSupplierTaxNumber =>
      supplierTaxNumber != null && supplierTaxNumber!.isNotEmpty;

  /// Gönderen depo bilgisi var mı?
  bool get hasFromWarehouse =>
      fromWarehouseId != null && fromWarehouseName != null;

  /// Alıcı depo bilgisi var mı?
  bool get hasToWarehouse => toWarehouseId != null && toWarehouseName != null;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// Red nedeni var mı?
  bool get hasRejectionReason =>
      rejectionReason != null && rejectionReason!.isNotEmpty;

  /// Gönderilebilir mi?
  bool get canBeSent {
    return status == EDespatchStatus.draft &&
        hasCustomerTaxNumber &&
        items.isNotEmpty;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status == EDespatchStatus.draft || status == EDespatchStatus.sent;
  }

  /// Arşivlenebilir mi?
  bool get canBeArchived {
    return status == EDespatchStatus.accepted ||
        status == EDespatchStatus.rejected;
  }

  /// Gönderim süresi (gün)
  int? get sendingTimeInDays {
    if (sentDate == null) return null;
    return sentDate!.difference(despatchDate).inDays;
  }

  /// Kabul süresi (gün)
  int? get acceptanceTimeInDays {
    if (acceptedDate == null || sentDate == null) return null;
    return acceptedDate!.difference(sentDate!).inDays;
  }

  /// Red süresi (gün)
  int? get rejectionTimeInDays {
    if (rejectedDate == null || sentDate == null) return null;
    return rejectedDate!.difference(sentDate!).inDays;
  }

  /// KDV oranı
  double get taxRate {
    if (netAmount == 0) return 0;
    return (taxAmount / netAmount) * 100;
  }

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Toplam kalem tutarı
  double get totalItemsAmount =>
      items.fold(0.0, (sum, item) => sum + item.totalAmount);

  /// Toplam kalem KDV tutarı
  double get totalItemsTaxAmount =>
      items.fold(0.0, (sum, item) => sum + item.taxAmount);

  @override
  String toString() {
    return 'EDespatch(id: $id, despatchNumber: $despatchNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EDespatch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// e-İrsaliye kalemi
class EDespatchItem {
  final String id;
  final String? productId;
  final String? productName;
  final String? productCode;
  final String? description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalAmount;
  final double taxRate;
  final double taxAmount;
  final double netAmount;
  final String currency;
  final String? notes;

  const EDespatchItem({
    required this.id,
    this.productId,
    this.productName,
    this.productCode,
    this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.netAmount,
    required this.currency,
    this.notes,
  });

  /// CopyWith metodu
  EDespatchItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productCode,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalAmount,
    double? taxRate,
    double? taxAmount,
    double? netAmount,
    String? currency,
    String? notes,
  }) {
    return EDespatchItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      netAmount: netAmount ?? this.netAmount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan EDespatchItem oluştur
  factory EDespatchItem.fromJson(Map<String, dynamic> json) {
    return EDespatchItem(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      productCode: json['productCode'] as String?,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
    );
  }

  /// EDespatchItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'netAmount': netAmount,
      'currency': currency,
      'notes': notes,
    };
  }

  /// Ürün bilgisi var mı?
  bool get hasProductInfo => productId != null && productName != null;

  /// Ürün kodu var mı?
  bool get hasProductCode => productCode != null && productCode!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Pozitif miktar mı?
  bool get isPositiveQuantity => quantity > 0;

  /// Pozitif birim fiyat mı?
  bool get isPositiveUnitPrice => unitPrice > 0;

  /// Pozitif toplam tutar mı?
  bool get isPositiveTotalAmount => totalAmount > 0;

  /// Pozitif KDV tutarı mı?
  bool get isPositiveTaxAmount => taxAmount > 0;

  /// Pozitif net tutar mı?
  bool get isPositiveNetAmount => netAmount > 0;

  /// KDV oranı yüzdesi
  double get taxRatePercentage => taxRate * 100;

  /// KDV oranı etiketi
  String get taxRateLabel => '${taxRatePercentage.toStringAsFixed(0)}%';

  /// Yüksek KDV oranı mı? (%20'den fazla)
  bool get isHighTaxRate => taxRate > 0.20;

  /// Düşük KDV oranı mı? (%10'dan az)
  bool get isLowTaxRate => taxRate < 0.10;

  /// Orta KDV oranı mı? (%10-20 arası)
  bool get isMediumTaxRate => taxRate >= 0.10 && taxRate <= 0.20;

  /// KDV oranı kategorisi
  String get taxRateCategory {
    if (isHighTaxRate) return 'Yüksek';
    if (isLowTaxRate) return 'Düşük';
    return 'Orta';
  }

  @override
  String toString() {
    return 'EDespatchItem(id: $id, productName: $productName, quantity: $quantity, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EDespatchItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
