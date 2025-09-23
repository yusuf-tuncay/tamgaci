// ========== E-INVOICE ENTITY ==========
// lib/features/regulatory/domain/entities/e_invoice.dart

/// e-Fatura türü
enum EInvoiceType {
  sales('Satış Faturası'),
  purchase('Alış Faturası'),
  service('Hizmet Faturası'),
  export('İhracat Faturası'),
  import('İthalat Faturası');

  const EInvoiceType(this.displayName);
  final String displayName;
}

/// e-Fatura durumu
enum EInvoiceStatus {
  draft('Taslak'),
  sent('Gönderildi'),
  accepted('Kabul Edildi'),
  rejected('Reddedildi'),
  cancelled('İptal Edildi'),
  archived('Arşivlendi');

  const EInvoiceStatus(this.displayName);
  final String displayName;
}

/// e-Fatura entity'si
class EInvoice {
  final String id;
  final String invoiceNumber;
  final String? eInvoiceNumber; // e-Fatura numarası
  final EInvoiceType type;
  final EInvoiceStatus status;
  final String? customerId;
  final String? customerName;
  final String? customerTaxNumber;
  final String? supplierId;
  final String? supplierName;
  final String? supplierTaxNumber;
  final double totalAmount;
  final double taxAmount;
  final double netAmount;
  final String currency;
  final DateTime invoiceDate;
  final DateTime? eInvoiceDate; // e-Fatura tarihi
  final DateTime? sentDate; // Gönderim tarihi
  final DateTime? acceptedDate; // Kabul tarihi
  final DateTime? rejectedDate; // Red tarihi
  final String? rejectionReason; // Red nedeni
  final String? gibInvoiceId; // GİB fatura ID'si
  final String? gibInvoiceUuid; // GİB fatura UUID
  final String? envelopeId; // Zarf ID'si
  final String? envelopeUuid; // Zarf UUID
  final String? description;
  final String? notes;
  final List<EInvoiceItem> items;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const EInvoice({
    required this.id,
    required this.invoiceNumber,
    this.eInvoiceNumber,
    required this.type,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerTaxNumber,
    this.supplierId,
    this.supplierName,
    this.supplierTaxNumber,
    required this.totalAmount,
    required this.taxAmount,
    required this.netAmount,
    required this.currency,
    required this.invoiceDate,
    this.eInvoiceDate,
    this.sentDate,
    this.acceptedDate,
    this.rejectedDate,
    this.rejectionReason,
    this.gibInvoiceId,
    this.gibInvoiceUuid,
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
  EInvoice copyWith({
    String? id,
    String? invoiceNumber,
    String? eInvoiceNumber,
    EInvoiceType? type,
    EInvoiceStatus? status,
    String? customerId,
    String? customerName,
    String? customerTaxNumber,
    String? supplierId,
    String? supplierName,
    String? supplierTaxNumber,
    double? totalAmount,
    double? taxAmount,
    double? netAmount,
    String? currency,
    DateTime? invoiceDate,
    DateTime? eInvoiceDate,
    DateTime? sentDate,
    DateTime? acceptedDate,
    DateTime? rejectedDate,
    String? rejectionReason,
    String? gibInvoiceId,
    String? gibInvoiceUuid,
    String? envelopeId,
    String? envelopeUuid,
    String? description,
    String? notes,
    List<EInvoiceItem>? items,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return EInvoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      eInvoiceNumber: eInvoiceNumber ?? this.eInvoiceNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerTaxNumber: customerTaxNumber ?? this.customerTaxNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierTaxNumber: supplierTaxNumber ?? this.supplierTaxNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      netAmount: netAmount ?? this.netAmount,
      currency: currency ?? this.currency,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      eInvoiceDate: eInvoiceDate ?? this.eInvoiceDate,
      sentDate: sentDate ?? this.sentDate,
      acceptedDate: acceptedDate ?? this.acceptedDate,
      rejectedDate: rejectedDate ?? this.rejectedDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      gibInvoiceId: gibInvoiceId ?? this.gibInvoiceId,
      gibInvoiceUuid: gibInvoiceUuid ?? this.gibInvoiceUuid,
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

  /// JSON'dan EInvoice oluştur
  factory EInvoice.fromJson(Map<String, dynamic> json) {
    return EInvoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      eInvoiceNumber: json['eInvoiceNumber'] as String?,
      type: EInvoiceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EInvoiceType.sales,
      ),
      status: EInvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EInvoiceStatus.draft,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerTaxNumber: json['customerTaxNumber'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierTaxNumber: json['supplierTaxNumber'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      eInvoiceDate: json['eInvoiceDate'] != null
          ? DateTime.parse(json['eInvoiceDate'] as String)
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
      gibInvoiceId: json['gibInvoiceId'] as String?,
      gibInvoiceUuid: json['gibInvoiceUuid'] as String?,
      envelopeId: json['envelopeId'] as String?,
      envelopeUuid: json['envelopeUuid'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => EInvoiceItem.fromJson(e as Map<String, dynamic>))
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

  /// EInvoice'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'eInvoiceNumber': eInvoiceNumber,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'customerTaxNumber': customerTaxNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierTaxNumber': supplierTaxNumber,
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'netAmount': netAmount,
      'currency': currency,
      'invoiceDate': invoiceDate.toIso8601String(),
      'eInvoiceDate': eInvoiceDate?.toIso8601String(),
      'sentDate': sentDate?.toIso8601String(),
      'acceptedDate': acceptedDate?.toIso8601String(),
      'rejectedDate': rejectedDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'gibInvoiceId': gibInvoiceId,
      'gibInvoiceUuid': gibInvoiceUuid,
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
  bool get isDraft => status == EInvoiceStatus.draft;

  /// Gönderildi mi?
  bool get isSent => status == EInvoiceStatus.sent;

  /// Kabul edildi mi?
  bool get isAccepted => status == EInvoiceStatus.accepted;

  /// Reddedildi mi?
  bool get isRejected => status == EInvoiceStatus.rejected;

  /// İptal edildi mi?
  bool get isCancelled => status == EInvoiceStatus.cancelled;

  /// Arşivlendi mi?
  bool get isArchived => status == EInvoiceStatus.archived;

  /// Satış faturası mı?
  bool get isSalesInvoice => type == EInvoiceType.sales;

  /// Alış faturası mı?
  bool get isPurchaseInvoice => type == EInvoiceType.purchase;

  /// Hizmet faturası mı?
  bool get isServiceInvoice => type == EInvoiceType.service;

  /// İhracat faturası mı?
  bool get isExportInvoice => type == EInvoiceType.export;

  /// İthalat faturası mı?
  bool get isImportInvoice => type == EInvoiceType.import;

  /// Müşteri faturası mı?
  bool get isCustomerInvoice => customerId != null;

  /// Tedarikçi faturası mı?
  bool get isSupplierInvoice => supplierId != null;

  /// e-Fatura numarası var mı?
  bool get hasEInvoiceNumber =>
      eInvoiceNumber != null && eInvoiceNumber!.isNotEmpty;

  /// GİB fatura ID'si var mı?
  bool get hasGibInvoiceId => gibInvoiceId != null && gibInvoiceId!.isNotEmpty;

  /// GİB fatura UUID var mı?
  bool get hasGibInvoiceUuid =>
      gibInvoiceUuid != null && gibInvoiceUuid!.isNotEmpty;

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
    return status == EInvoiceStatus.draft &&
        hasCustomerTaxNumber &&
        items.isNotEmpty;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status == EInvoiceStatus.draft || status == EInvoiceStatus.sent;
  }

  /// Arşivlenebilir mi?
  bool get canBeArchived {
    return status == EInvoiceStatus.accepted ||
        status == EInvoiceStatus.rejected;
  }

  /// Gönderim süresi (gün)
  int? get sendingTimeInDays {
    if (sentDate == null) return null;
    return sentDate!.difference(invoiceDate).inDays;
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
    return 'EInvoice(id: $id, invoiceNumber: $invoiceNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EInvoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// e-Fatura kalemi
class EInvoiceItem {
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

  const EInvoiceItem({
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
  EInvoiceItem copyWith({
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
    return EInvoiceItem(
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

  /// JSON'dan EInvoiceItem oluştur
  factory EInvoiceItem.fromJson(Map<String, dynamic> json) {
    return EInvoiceItem(
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

  /// EInvoiceItem'ı JSON'a çevir
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
    return 'EInvoiceItem(id: $id, productName: $productName, quantity: $quantity, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EInvoiceItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
