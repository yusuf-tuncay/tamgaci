// ========== VAT SUMMARY REPORT ENTITY ==========
// lib/features/reports/domain/entities/vat_summary_report.dart

/// KDV özet raporu türü
enum VatSummaryReportType {
  monthly('Aylık'),
  quarterly('Üç Aylık'),
  yearly('Yıllık'),
  custom('Özel Dönem');

  const VatSummaryReportType(this.displayName);
  final String displayName;
}

/// KDV özet raporu entity'si
class VatSummaryReport {
  final String id;
  final String reportNumber;
  final VatSummaryReportType type;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final List<VatSummaryItem> items;
  final VatSummarySummary summary;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const VatSummaryReport({
    required this.id,
    required this.reportNumber,
    required this.type,
    required this.reportDate,
    required this.periodStart,
    required this.periodEnd,
    required this.currency,
    this.items = const [],
    required this.summary,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  VatSummaryReport copyWith({
    String? id,
    String? reportNumber,
    VatSummaryReportType? type,
    DateTime? reportDate,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? currency,
    List<VatSummaryItem>? items,
    VatSummarySummary? summary,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return VatSummaryReport(
      id: id ?? this.id,
      reportNumber: reportNumber ?? this.reportNumber,
      type: type ?? this.type,
      reportDate: reportDate ?? this.reportDate,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      currency: currency ?? this.currency,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan VatSummaryReport oluştur
  factory VatSummaryReport.fromJson(Map<String, dynamic> json) {
    return VatSummaryReport(
      id: json['id'] as String,
      reportNumber: json['reportNumber'] as String,
      type: VatSummaryReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VatSummaryReportType.monthly,
      ),
      reportDate: DateTime.parse(json['reportDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      currency: json['currency'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => VatSummaryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary:
          VatSummarySummary.fromJson(json['summary'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// VatSummaryReport'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportNumber': reportNumber,
      'type': type.name,
      'reportDate': reportDate.toIso8601String(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'currency': currency,
      'items': items.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Aylık rapor mu?
  bool get isMonthlyReport => type == VatSummaryReportType.monthly;

  /// Üç aylık rapor mu?
  bool get isQuarterlyReport => type == VatSummaryReportType.quarterly;

  /// Yıllık rapor mu?
  bool get isYearlyReport => type == VatSummaryReportType.yearly;

  /// Özel dönem raporu mu?
  bool get isCustomReport => type == VatSummaryReportType.custom;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Dönem süresi (gün)
  int get periodDays => periodEnd.difference(periodStart).inDays + 1;

  /// Toplam KDV alacağı
  double get totalVatReceivable => summary.totalVatReceivable;

  /// Toplam KDV borcu
  double get totalVatPayable => summary.totalVatPayable;

  /// Net KDV durumu
  double get netVatPosition => summary.netVatPosition;

  /// KDV alacağı mı?
  bool get isVatReceivable => netVatPosition > 0;

  /// KDV borcu mu?
  bool get isVatPayable => netVatPosition < 0;

  /// KDV sıfır mı?
  bool get isVatZero => netVatPosition == 0;

  @override
  String toString() {
    return 'VatSummaryReport(id: $id, reportNumber: $reportNumber, type: $type, netVatPosition: $netVatPosition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VatSummaryReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// KDV özet kalemi
class VatSummaryItem {
  final String id;
  final double vatRate; // KDV oranı
  final double taxableAmount; // Matrah
  final double vatAmount; // KDV tutarı
  final String currency;
  final String? notes;

  const VatSummaryItem({
    required this.id,
    required this.vatRate,
    required this.taxableAmount,
    required this.vatAmount,
    required this.currency,
    this.notes,
  });

  /// CopyWith metodu
  VatSummaryItem copyWith({
    String? id,
    double? vatRate,
    double? taxableAmount,
    double? vatAmount,
    String? currency,
    String? notes,
  }) {
    return VatSummaryItem(
      id: id ?? this.id,
      vatRate: vatRate ?? this.vatRate,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan VatSummaryItem oluştur
  factory VatSummaryItem.fromJson(Map<String, dynamic> json) {
    return VatSummaryItem(
      id: json['id'] as String,
      vatRate: (json['vatRate'] as num).toDouble(),
      taxableAmount: (json['taxableAmount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
    );
  }

  /// VatSummaryItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vatRate': vatRate,
      'taxableAmount': taxableAmount,
      'vatAmount': vatAmount,
      'currency': currency,
      'notes': notes,
    };
  }

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// KDV oranı yüzdesi
  double get vatRatePercentage => vatRate * 100;

  /// KDV oranı etiketi
  String get vatRateLabel => '${vatRatePercentage.toStringAsFixed(0)}%';

  /// Matrah sıfır mı?
  bool get isZeroTaxableAmount => taxableAmount == 0;

  /// KDV tutarı sıfır mı?
  bool get isZeroVatAmount => vatAmount == 0;

  /// Yüksek KDV oranı mı? (%20'den fazla)
  bool get isHighVatRate => vatRate > 0.20;

  /// Düşük KDV oranı mı? (%10'dan az)
  bool get isLowVatRate => vatRate < 0.10;

  /// Orta KDV oranı mı? (%10-20 arası)
  bool get isMediumVatRate => vatRate >= 0.10 && vatRate <= 0.20;

  /// KDV oranı kategorisi
  String get vatRateCategory {
    if (isHighVatRate) return 'Yüksek';
    if (isLowVatRate) return 'Düşük';
    return 'Orta';
  }

  @override
  String toString() {
    return 'VatSummaryItem(id: $id, vatRate: $vatRate, taxableAmount: $taxableAmount, vatAmount: $vatAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VatSummaryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// KDV özet özeti
class VatSummarySummary {
  final double totalVatReceivable;
  final double totalVatPayable;
  final double netVatPosition;
  final int totalItemsCount;
  final String currency;

  const VatSummarySummary({
    required this.totalVatReceivable,
    required this.totalVatPayable,
    required this.netVatPosition,
    required this.totalItemsCount,
    required this.currency,
  });

  /// CopyWith metodu
  VatSummarySummary copyWith({
    double? totalVatReceivable,
    double? totalVatPayable,
    double? netVatPosition,
    int? totalItemsCount,
    String? currency,
  }) {
    return VatSummarySummary(
      totalVatReceivable: totalVatReceivable ?? this.totalVatReceivable,
      totalVatPayable: totalVatPayable ?? this.totalVatPayable,
      netVatPosition: netVatPosition ?? this.netVatPosition,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      currency: currency ?? this.currency,
    );
  }

  /// JSON'dan VatSummarySummary oluştur
  factory VatSummarySummary.fromJson(Map<String, dynamic> json) {
    return VatSummarySummary(
      totalVatReceivable: (json['totalVatReceivable'] as num).toDouble(),
      totalVatPayable: (json['totalVatPayable'] as num).toDouble(),
      netVatPosition: (json['netVatPosition'] as num).toDouble(),
      totalItemsCount: json['totalItemsCount'] as int,
      currency: json['currency'] as String,
    );
  }

  /// VatSummarySummary'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'totalVatReceivable': totalVatReceivable,
      'totalVatPayable': totalVatPayable,
      'netVatPosition': netVatPosition,
      'totalItemsCount': totalItemsCount,
      'currency': currency,
    };
  }

  /// KDV alacağı mı?
  bool get isVatReceivable => netVatPosition > 0;

  /// KDV borcu mu?
  bool get isVatPayable => netVatPosition < 0;

  /// KDV sıfır mı?
  bool get isVatZero => netVatPosition == 0;

  /// KDV alacağı sıfır mı?
  bool get isZeroVatReceivable => totalVatReceivable == 0;

  /// KDV borcu sıfır mı?
  bool get isZeroVatPayable => totalVatPayable == 0;

  /// Toplam KDV tutarı
  double get totalVatAmount => totalVatReceivable + totalVatPayable;

  /// KDV alacağı yüzdesi
  double get vatReceivablePercentage {
    if (totalVatAmount == 0) return 0;
    return (totalVatReceivable / totalVatAmount) * 100;
  }

  /// KDV borcu yüzdesi
  double get vatPayablePercentage {
    if (totalVatAmount == 0) return 0;
    return (totalVatPayable / totalVatAmount) * 100;
  }

  /// Net KDV durumu etiketi
  String get netVatPositionLabel {
    if (isVatReceivable) return 'KDV Alacağı';
    if (isVatPayable) return 'KDV Borcu';
    return 'KDV Sıfır';
  }

  @override
  String toString() {
    return 'VatSummarySummary(totalVatReceivable: $totalVatReceivable, totalVatPayable: $totalVatPayable, netVatPosition: $netVatPosition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VatSummarySummary &&
        other.totalVatReceivable == totalVatReceivable &&
        other.totalVatPayable == totalVatPayable;
  }

  @override
  int get hashCode => totalVatReceivable.hashCode ^ totalVatPayable.hashCode;
}

