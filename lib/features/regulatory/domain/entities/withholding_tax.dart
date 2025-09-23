// ========== WITHHOLDING TAX ENTITY ==========
// lib/features/regulatory/domain/entities/withholding_tax.dart

/// Tevkifat türü
enum WithholdingTaxType {
  income('Gelir Vergisi'),
  corporate('Kurumlar Vergisi'),
  stamp('Damga Vergisi'),
  vat('KDV Tevkifatı'),
  other('Diğer');

  const WithholdingTaxType(this.displayName);
  final String displayName;
}

/// Tevkifat durumu
enum WithholdingTaxStatus {
  draft('Taslak'),
  calculated('Hesaplandı'),
  applied('Uygulandı'),
  reported('Beyan Edildi'),
  paid('Ödendi'),
  cancelled('İptal Edildi');

  const WithholdingTaxStatus(this.displayName);
  final String displayName;
}

/// Tevkifat entity'si
class WithholdingTax {
  final String id;
  final String documentNumber;
  final WithholdingTaxType type;
  final WithholdingTaxStatus status;
  final String? customerId;
  final String? customerName;
  final String? customerTaxNumber;
  final String? supplierId;
  final String? supplierName;
  final String? supplierTaxNumber;
  final double grossAmount;
  final double withholdingRate;
  final double withholdingAmount;
  final double netAmount;
  final String currency;
  final DateTime documentDate;
  final DateTime? calculatedDate;
  final DateTime? appliedDate;
  final DateTime? reportedDate;
  final DateTime? paidDate;
  final String? description;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const WithholdingTax({
    required this.id,
    required this.documentNumber,
    required this.type,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerTaxNumber,
    this.supplierId,
    this.supplierName,
    this.supplierTaxNumber,
    required this.grossAmount,
    required this.withholdingRate,
    required this.withholdingAmount,
    required this.netAmount,
    required this.currency,
    required this.documentDate,
    this.calculatedDate,
    this.appliedDate,
    this.reportedDate,
    this.paidDate,
    this.description,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  WithholdingTax copyWith({
    String? id,
    String? documentNumber,
    WithholdingTaxType? type,
    WithholdingTaxStatus? status,
    String? customerId,
    String? customerName,
    String? customerTaxNumber,
    String? supplierId,
    String? supplierName,
    String? supplierTaxNumber,
    double? grossAmount,
    double? withholdingRate,
    double? withholdingAmount,
    double? netAmount,
    String? currency,
    DateTime? documentDate,
    DateTime? calculatedDate,
    DateTime? appliedDate,
    DateTime? reportedDate,
    DateTime? paidDate,
    String? description,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return WithholdingTax(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerTaxNumber: customerTaxNumber ?? this.customerTaxNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierTaxNumber: supplierTaxNumber ?? this.supplierTaxNumber,
      grossAmount: grossAmount ?? this.grossAmount,
      withholdingRate: withholdingRate ?? this.withholdingRate,
      withholdingAmount: withholdingAmount ?? this.withholdingAmount,
      netAmount: netAmount ?? this.netAmount,
      currency: currency ?? this.currency,
      documentDate: documentDate ?? this.documentDate,
      calculatedDate: calculatedDate ?? this.calculatedDate,
      appliedDate: appliedDate ?? this.appliedDate,
      reportedDate: reportedDate ?? this.reportedDate,
      paidDate: paidDate ?? this.paidDate,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan WithholdingTax oluştur
  factory WithholdingTax.fromJson(Map<String, dynamic> json) {
    return WithholdingTax(
      id: json['id'] as String,
      documentNumber: json['documentNumber'] as String,
      type: WithholdingTaxType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WithholdingTaxType.income,
      ),
      status: WithholdingTaxStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WithholdingTaxStatus.draft,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerTaxNumber: json['customerTaxNumber'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierTaxNumber: json['supplierTaxNumber'] as String?,
      grossAmount: (json['grossAmount'] as num).toDouble(),
      withholdingRate: (json['withholdingRate'] as num).toDouble(),
      withholdingAmount: (json['withholdingAmount'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      documentDate: DateTime.parse(json['documentDate'] as String),
      calculatedDate: json['calculatedDate'] != null
          ? DateTime.parse(json['calculatedDate'] as String)
          : null,
      appliedDate: json['appliedDate'] != null
          ? DateTime.parse(json['appliedDate'] as String)
          : null,
      reportedDate: json['reportedDate'] != null
          ? DateTime.parse(json['reportedDate'] as String)
          : null,
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// WithholdingTax'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentNumber': documentNumber,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'customerTaxNumber': customerTaxNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierTaxNumber': supplierTaxNumber,
      'grossAmount': grossAmount,
      'withholdingRate': withholdingRate,
      'withholdingAmount': withholdingAmount,
      'netAmount': netAmount,
      'currency': currency,
      'documentDate': documentDate.toIso8601String(),
      'calculatedDate': calculatedDate?.toIso8601String(),
      'appliedDate': appliedDate?.toIso8601String(),
      'reportedDate': reportedDate?.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'description': description,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Taslak mı?
  bool get isDraft => status == WithholdingTaxStatus.draft;

  /// Hesaplandı mı?
  bool get isCalculated => status == WithholdingTaxStatus.calculated;

  /// Uygulandı mı?
  bool get isApplied => status == WithholdingTaxStatus.applied;

  /// Beyan edildi mi?
  bool get isReported => status == WithholdingTaxStatus.reported;

  /// Ödendi mi?
  bool get isPaid => status == WithholdingTaxStatus.paid;

  /// İptal edildi mi?
  bool get isCancelled => status == WithholdingTaxStatus.cancelled;

  /// Gelir vergisi mi?
  bool get isIncomeTax => type == WithholdingTaxType.income;

  /// Kurumlar vergisi mi?
  bool get isCorporateTax => type == WithholdingTaxType.corporate;

  /// Damga vergisi mi?
  bool get isStampTax => type == WithholdingTaxType.stamp;

  /// KDV tevkifatı mı?
  bool get isVatWithholding => type == WithholdingTaxType.vat;

  /// Diğer tevkifat mı?
  bool get isOtherWithholding => type == WithholdingTaxType.other;

  /// Müşteri tevkifatı mı?
  bool get isCustomerWithholding => customerId != null;

  /// Tedarikçi tevkifatı mı?
  bool get isSupplierWithholding => supplierId != null;

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

  /// Hesaplanabilir mi?
  bool get canBeCalculated {
    return status == WithholdingTaxStatus.draft &&
        grossAmount > 0 &&
        withholdingRate > 0;
  }

  /// Uygulanabilir mi?
  bool get canBeApplied {
    return status == WithholdingTaxStatus.calculated;
  }

  /// Beyan edilebilir mi?
  bool get canBeReported {
    return status == WithholdingTaxStatus.applied;
  }

  /// Ödenebilir mi?
  bool get canBePaid {
    return status == WithholdingTaxStatus.reported;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status != WithholdingTaxStatus.paid &&
        status != WithholdingTaxStatus.cancelled;
  }

  /// Hesaplama süresi (gün)
  int? get calculationTimeInDays {
    if (calculatedDate == null) return null;
    return calculatedDate!.difference(documentDate).inDays;
  }

  /// Uygulama süresi (gün)
  int? get applicationTimeInDays {
    if (appliedDate == null || calculatedDate == null) return null;
    return appliedDate!.difference(calculatedDate!).inDays;
  }

  /// Beyan süresi (gün)
  int? get reportingTimeInDays {
    if (reportedDate == null || appliedDate == null) return null;
    return reportedDate!.difference(appliedDate!).inDays;
  }

  /// Ödeme süresi (gün)
  int? get paymentTimeInDays {
    if (paidDate == null || reportedDate == null) return null;
    return paidDate!.difference(reportedDate!).inDays;
  }

  /// Tevkifat oranı yüzdesi
  double get withholdingRatePercentage => withholdingRate * 100;

  /// Tevkifat oranı etiketi
  String get withholdingRateLabel =>
      '${withholdingRatePercentage.toStringAsFixed(2)}%';

  /// Yüksek tevkifat oranı mı? (%20'den fazla)
  bool get isHighWithholdingRate => withholdingRate > 0.20;

  /// Düşük tevkifat oranı mı? (%5'ten az)
  bool get isLowWithholdingRate => withholdingRate < 0.05;

  /// Orta tevkifat oranı mı? (%5-20 arası)
  bool get isMediumWithholdingRate =>
      withholdingRate >= 0.05 && withholdingRate <= 0.20;

  /// Tevkifat oranı kategorisi
  String get withholdingRateCategory {
    if (isHighWithholdingRate) return 'Yüksek';
    if (isLowWithholdingRate) return 'Düşük';
    return 'Orta';
  }

  /// Pozitif brüt tutar mı?
  bool get isPositiveGrossAmount => grossAmount > 0;

  /// Pozitif tevkifat tutarı mı?
  bool get isPositiveWithholdingAmount => withholdingAmount > 0;

  /// Pozitif net tutar mı?
  bool get isPositiveNetAmount => netAmount > 0;

  /// Sıfır tevkifat tutarı mı?
  bool get isZeroWithholdingAmount => withholdingAmount == 0;

  /// Yüksek brüt tutar mı? (100,000'den fazla)
  bool get isHighGrossAmount => grossAmount > 100000;

  /// Düşük brüt tutar mı? (1,000'den az)
  bool get isLowGrossAmount => grossAmount < 1000;

  /// Orta brüt tutar mı? (1,000-100,000 arası)
  bool get isMediumGrossAmount => grossAmount >= 1000 && grossAmount <= 100000;

  /// Brüt tutar kategorisi
  String get grossAmountCategory {
    if (isHighGrossAmount) return 'Yüksek';
    if (isLowGrossAmount) return 'Düşük';
    return 'Orta';
  }

  @override
  String toString() {
    return 'WithholdingTax(id: $id, documentNumber: $documentNumber, type: $type, withholdingAmount: $withholdingAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WithholdingTax && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
