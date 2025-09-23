// ========== EXCHANGE RATE DIFFERENCE ENTITY ==========
// lib/features/regulatory/domain/entities/exchange_rate_difference.dart

/// Kur farkı türü
enum ExchangeRateDifferenceType {
  sales('Satış Kur Farkı'),
  purchase('Alış Kur Farkı'),
  payment('Ödeme Kur Farkı'),
  receipt('Tahsilat Kur Farkı'),
  adjustment('Düzeltme Kur Farkı');

  const ExchangeRateDifferenceType(this.displayName);
  final String displayName;
}

/// Kur farkı durumu
enum ExchangeRateDifferenceStatus {
  draft('Taslak'),
  calculated('Hesaplandı'),
  applied('Uygulandı'),
  reported('Beyan Edildi'),
  cancelled('İptal Edildi');

  const ExchangeRateDifferenceStatus(this.displayName);
  final String displayName;
}

/// Kur farkı entity'si
class ExchangeRateDifference {
  final String id;
  final String documentNumber;
  final ExchangeRateDifferenceType type;
  final ExchangeRateDifferenceStatus status;
  final String? customerId;
  final String? customerName;
  final String? customerTaxNumber;
  final String? supplierId;
  final String? supplierName;
  final String? supplierTaxNumber;
  final String fromCurrency;
  final String toCurrency;
  final double originalAmount;
  final double originalExchangeRate;
  final double currentExchangeRate;
  final double exchangeRateDifference;
  final double differenceAmount;
  final String currency;
  final DateTime documentDate;
  final DateTime? calculatedDate;
  final DateTime? appliedDate;
  final DateTime? reportedDate;
  final String? description;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const ExchangeRateDifference({
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
    required this.fromCurrency,
    required this.toCurrency,
    required this.originalAmount,
    required this.originalExchangeRate,
    required this.currentExchangeRate,
    required this.exchangeRateDifference,
    required this.differenceAmount,
    required this.currency,
    required this.documentDate,
    this.calculatedDate,
    this.appliedDate,
    this.reportedDate,
    this.description,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  ExchangeRateDifference copyWith({
    String? id,
    String? documentNumber,
    ExchangeRateDifferenceType? type,
    ExchangeRateDifferenceStatus? status,
    String? customerId,
    String? customerName,
    String? customerTaxNumber,
    String? supplierId,
    String? supplierName,
    String? supplierTaxNumber,
    String? fromCurrency,
    String? toCurrency,
    double? originalAmount,
    double? originalExchangeRate,
    double? currentExchangeRate,
    double? exchangeRateDifference,
    double? differenceAmount,
    String? currency,
    DateTime? documentDate,
    DateTime? calculatedDate,
    DateTime? appliedDate,
    DateTime? reportedDate,
    String? description,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ExchangeRateDifference(
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
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      originalAmount: originalAmount ?? this.originalAmount,
      originalExchangeRate: originalExchangeRate ?? this.originalExchangeRate,
      currentExchangeRate: currentExchangeRate ?? this.currentExchangeRate,
      exchangeRateDifference:
          exchangeRateDifference ?? this.exchangeRateDifference,
      differenceAmount: differenceAmount ?? this.differenceAmount,
      currency: currency ?? this.currency,
      documentDate: documentDate ?? this.documentDate,
      calculatedDate: calculatedDate ?? this.calculatedDate,
      appliedDate: appliedDate ?? this.appliedDate,
      reportedDate: reportedDate ?? this.reportedDate,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan ExchangeRateDifference oluştur
  factory ExchangeRateDifference.fromJson(Map<String, dynamic> json) {
    return ExchangeRateDifference(
      id: json['id'] as String,
      documentNumber: json['documentNumber'] as String,
      type: ExchangeRateDifferenceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExchangeRateDifferenceType.sales,
      ),
      status: ExchangeRateDifferenceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExchangeRateDifferenceStatus.draft,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerTaxNumber: json['customerTaxNumber'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierTaxNumber: json['supplierTaxNumber'] as String?,
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      originalExchangeRate: (json['originalExchangeRate'] as num).toDouble(),
      currentExchangeRate: (json['currentExchangeRate'] as num).toDouble(),
      exchangeRateDifference:
          (json['exchangeRateDifference'] as num).toDouble(),
      differenceAmount: (json['differenceAmount'] as num).toDouble(),
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
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// ExchangeRateDifference'ı JSON'a çevir
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
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'originalAmount': originalAmount,
      'originalExchangeRate': originalExchangeRate,
      'currentExchangeRate': currentExchangeRate,
      'exchangeRateDifference': exchangeRateDifference,
      'differenceAmount': differenceAmount,
      'currency': currency,
      'documentDate': documentDate.toIso8601String(),
      'calculatedDate': calculatedDate?.toIso8601String(),
      'appliedDate': appliedDate?.toIso8601String(),
      'reportedDate': reportedDate?.toIso8601String(),
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
  bool get isDraft => status == ExchangeRateDifferenceStatus.draft;

  /// Hesaplandı mı?
  bool get isCalculated => status == ExchangeRateDifferenceStatus.calculated;

  /// Uygulandı mı?
  bool get isApplied => status == ExchangeRateDifferenceStatus.applied;

  /// Beyan edildi mi?
  bool get isReported => status == ExchangeRateDifferenceStatus.reported;

  /// İptal edildi mi?
  bool get isCancelled => status == ExchangeRateDifferenceStatus.cancelled;

  /// Satış kur farkı mı?
  bool get isSalesExchangeRateDifference =>
      type == ExchangeRateDifferenceType.sales;

  /// Alış kur farkı mı?
  bool get isPurchaseExchangeRateDifference =>
      type == ExchangeRateDifferenceType.purchase;

  /// Ödeme kur farkı mı?
  bool get isPaymentExchangeRateDifference =>
      type == ExchangeRateDifferenceType.payment;

  /// Tahsilat kur farkı mı?
  bool get isReceiptExchangeRateDifference =>
      type == ExchangeRateDifferenceType.receipt;

  /// Düzeltme kur farkı mı?
  bool get isAdjustmentExchangeRateDifference =>
      type == ExchangeRateDifferenceType.adjustment;

  /// Müşteri kur farkı mı?
  bool get isCustomerExchangeRateDifference => customerId != null;

  /// Tedarikçi kur farkı mı?
  bool get isSupplierExchangeRateDifference => supplierId != null;

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
    return status == ExchangeRateDifferenceStatus.draft &&
        originalAmount > 0 &&
        originalExchangeRate > 0 &&
        currentExchangeRate > 0;
  }

  /// Uygulanabilir mi?
  bool get canBeApplied {
    return status == ExchangeRateDifferenceStatus.calculated;
  }

  /// Beyan edilebilir mi?
  bool get canBeReported {
    return status == ExchangeRateDifferenceStatus.applied;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status != ExchangeRateDifferenceStatus.reported &&
        status != ExchangeRateDifferenceStatus.cancelled;
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

  /// Kur farkı yüzdesi
  double get exchangeRateDifferencePercentage {
    if (originalExchangeRate == 0) return 0;
    return (exchangeRateDifference / originalExchangeRate) * 100;
  }

  /// Kur farkı yüzdesi etiketi
  String get exchangeRateDifferencePercentageLabel =>
      '${exchangeRateDifferencePercentage.toStringAsFixed(2)}%';

  /// Pozitif kur farkı mı?
  bool get isPositiveExchangeRateDifference => exchangeRateDifference > 0;

  /// Negatif kur farkı mı?
  bool get isNegativeExchangeRateDifference => exchangeRateDifference < 0;

  /// Sıfır kur farkı mı?
  bool get isZeroExchangeRateDifference => exchangeRateDifference == 0;

  /// Pozitif fark tutarı mı?
  bool get isPositiveDifferenceAmount => differenceAmount > 0;

  /// Negatif fark tutarı mı?
  bool get isNegativeDifferenceAmount => differenceAmount < 0;

  /// Sıfır fark tutarı mı?
  bool get isZeroDifferenceAmount => differenceAmount == 0;

  /// Yüksek kur farkı mı? (%10'dan fazla)
  bool get isHighExchangeRateDifference =>
      exchangeRateDifferencePercentage.abs() > 10;

  /// Düşük kur farkı mı? (%1'den az)
  bool get isLowExchangeRateDifference =>
      exchangeRateDifferencePercentage.abs() < 1;

  /// Orta kur farkı mı? (%1-10 arası)
  bool get isMediumExchangeRateDifference =>
      exchangeRateDifferencePercentage.abs() >= 1 &&
      exchangeRateDifferencePercentage.abs() <= 10;

  /// Kur farkı kategorisi
  String get exchangeRateDifferenceCategory {
    if (isHighExchangeRateDifference) return 'Yüksek';
    if (isLowExchangeRateDifference) return 'Düşük';
    return 'Orta';
  }

  /// Pozitif orijinal tutar mı?
  bool get isPositiveOriginalAmount => originalAmount > 0;

  /// Pozitif orijinal kur mı?
  bool get isPositiveOriginalExchangeRate => originalExchangeRate > 0;

  /// Pozitif güncel kur mı?
  bool get isPositiveCurrentExchangeRate => currentExchangeRate > 0;

  /// Yüksek orijinal tutar mı? (100,000'den fazla)
  bool get isHighOriginalAmount => originalAmount > 100000;

  /// Düşük orijinal tutar mı? (1,000'den az)
  bool get isLowOriginalAmount => originalAmount < 1000;

  /// Orta orijinal tutar mı? (1,000-100,000 arası)
  bool get isMediumOriginalAmount =>
      originalAmount >= 1000 && originalAmount <= 100000;

  /// Orijinal tutar kategorisi
  String get originalAmountCategory {
    if (isHighOriginalAmount) return 'Yüksek';
    if (isLowOriginalAmount) return 'Düşük';
    return 'Orta';
  }

  /// Kur farkı durumu
  String get exchangeRateDifferenceStatus {
    if (isPositiveExchangeRateDifference) return 'Pozitif';
    if (isNegativeExchangeRateDifference) return 'Negatif';
    return 'Sıfır';
  }

  /// Fark tutarı durumu
  String get differenceAmountStatus {
    if (isPositiveDifferenceAmount) return 'Pozitif';
    if (isNegativeDifferenceAmount) return 'Negatif';
    return 'Sıfır';
  }

  @override
  String toString() {
    return 'ExchangeRateDifference(id: $id, documentNumber: $documentNumber, type: $type, differenceAmount: $differenceAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExchangeRateDifference && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
