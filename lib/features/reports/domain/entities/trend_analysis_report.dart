// ========== TREND ANALYSIS REPORT ENTITY ==========
// lib/features/reports/domain/entities/trend_analysis_report.dart

/// Trend analizi raporu türü
enum TrendAnalysisReportType {
  sales('Satış Trendi'),
  profit('Kar Trendi'),
  inventory('Stok Trendi'),
  cashFlow('Nakit Akış Trendi'),
  combined('Kombine Trend');

  const TrendAnalysisReportType(this.displayName);
  final String displayName;
}

/// Trend analizi raporu entity'si
class TrendAnalysisReport {
  final String id;
  final String reportNumber;
  final TrendAnalysisReportType type;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final List<TrendAnalysisItem> items;
  final TrendAnalysisSummary summary;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const TrendAnalysisReport({
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
  TrendAnalysisReport copyWith({
    String? id,
    String? reportNumber,
    TrendAnalysisReportType? type,
    DateTime? reportDate,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? currency,
    List<TrendAnalysisItem>? items,
    TrendAnalysisSummary? summary,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return TrendAnalysisReport(
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

  /// JSON'dan TrendAnalysisReport oluştur
  factory TrendAnalysisReport.fromJson(Map<String, dynamic> json) {
    return TrendAnalysisReport(
      id: json['id'] as String,
      reportNumber: json['reportNumber'] as String,
      type: TrendAnalysisReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TrendAnalysisReportType.sales,
      ),
      reportDate: DateTime.parse(json['reportDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      currency: json['currency'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => TrendAnalysisItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: TrendAnalysisSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// TrendAnalysisReport'ı JSON'a çevir
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

  /// Satış trendi mi?
  bool get isSalesTrend => type == TrendAnalysisReportType.sales;

  /// Kar trendi mi?
  bool get isProfitTrend => type == TrendAnalysisReportType.profit;

  /// Stok trendi mi?
  bool get isInventoryTrend => type == TrendAnalysisReportType.inventory;

  /// Nakit akış trendi mi?
  bool get isCashFlowTrend => type == TrendAnalysisReportType.cashFlow;

  /// Kombine trend mi?
  bool get isCombinedTrend => type == TrendAnalysisReportType.combined;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Dönem süresi (gün)
  int get periodDays => periodEnd.difference(periodStart).inDays + 1;

  /// Trend yönü
  String get trendDirection => summary.trendDirection;

  /// Trend gücü
  String get trendStrength => summary.trendStrength;

  /// Trend değişim yüzdesi
  double get trendChangePercentage => summary.trendChangePercentage;

  @override
  String toString() {
    return 'TrendAnalysisReport(id: $id, reportNumber: $reportNumber, type: $type, trendDirection: $trendDirection)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendAnalysisReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Trend analizi kalemi
class TrendAnalysisItem {
  final String id;
  final DateTime periodDate;
  final double value;
  final String currency;
  final String? notes;

  const TrendAnalysisItem({
    required this.id,
    required this.periodDate,
    required this.value,
    required this.currency,
    this.notes,
  });

  /// CopyWith metodu
  TrendAnalysisItem copyWith({
    String? id,
    DateTime? periodDate,
    double? value,
    String? currency,
    String? notes,
  }) {
    return TrendAnalysisItem(
      id: id ?? this.id,
      periodDate: periodDate ?? this.periodDate,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan TrendAnalysisItem oluştur
  factory TrendAnalysisItem.fromJson(Map<String, dynamic> json) {
    return TrendAnalysisItem(
      id: json['id'] as String,
      periodDate: DateTime.parse(json['periodDate'] as String),
      value: (json['value'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
    );
  }

  /// TrendAnalysisItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodDate': periodDate.toIso8601String(),
      'value': value,
      'currency': currency,
      'notes': notes,
    };
  }

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Pozitif değer mi?
  bool get isPositiveValue => value > 0;

  /// Negatif değer mi?
  bool get isNegativeValue => value < 0;

  /// Sıfır değer mi?
  bool get isZeroValue => value == 0;

  /// Yüksek değer mi? (100,000'den fazla)
  bool get isHighValue => value.abs() > 100000;

  /// Düşük değer mi? (1,000'den az)
  bool get isLowValue => value.abs() < 1000;

  /// Orta değer mi? (1,000-100,000 arası)
  bool get isMediumValue => value.abs() >= 1000 && value.abs() <= 100000;

  /// Değer kategorisi
  String get valueCategory {
    if (isHighValue) return 'Yüksek';
    if (isLowValue) return 'Düşük';
    return 'Orta';
  }

  /// Değer durumu
  String get valueStatus {
    if (isPositiveValue) return 'Pozitif';
    if (isNegativeValue) return 'Negatif';
    return 'Sıfır';
  }

  @override
  String toString() {
    return 'TrendAnalysisItem(id: $id, periodDate: $periodDate, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendAnalysisItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Trend analizi özeti
class TrendAnalysisSummary {
  final double startValue;
  final double endValue;
  final double highestValue;
  final double lowestValue;
  final double averageValue;
  final double trendChangePercentage;
  final String trendDirection;
  final String trendStrength;
  final int totalItemsCount;
  final String currency;

  const TrendAnalysisSummary({
    required this.startValue,
    required this.endValue,
    required this.highestValue,
    required this.lowestValue,
    required this.averageValue,
    required this.trendChangePercentage,
    required this.trendDirection,
    required this.trendStrength,
    required this.totalItemsCount,
    required this.currency,
  });

  /// CopyWith metodu
  TrendAnalysisSummary copyWith({
    double? startValue,
    double? endValue,
    double? highestValue,
    double? lowestValue,
    double? averageValue,
    double? trendChangePercentage,
    String? trendDirection,
    String? trendStrength,
    int? totalItemsCount,
    String? currency,
  }) {
    return TrendAnalysisSummary(
      startValue: startValue ?? this.startValue,
      endValue: endValue ?? this.endValue,
      highestValue: highestValue ?? this.highestValue,
      lowestValue: lowestValue ?? this.lowestValue,
      averageValue: averageValue ?? this.averageValue,
      trendChangePercentage:
          trendChangePercentage ?? this.trendChangePercentage,
      trendDirection: trendDirection ?? this.trendDirection,
      trendStrength: trendStrength ?? this.trendStrength,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      currency: currency ?? this.currency,
    );
  }

  /// JSON'dan TrendAnalysisSummary oluştur
  factory TrendAnalysisSummary.fromJson(Map<String, dynamic> json) {
    return TrendAnalysisSummary(
      startValue: (json['startValue'] as num).toDouble(),
      endValue: (json['endValue'] as num).toDouble(),
      highestValue: (json['highestValue'] as num).toDouble(),
      lowestValue: (json['lowestValue'] as num).toDouble(),
      averageValue: (json['averageValue'] as num).toDouble(),
      trendChangePercentage: (json['trendChangePercentage'] as num).toDouble(),
      trendDirection: json['trendDirection'] as String,
      trendStrength: json['trendStrength'] as String,
      totalItemsCount: json['totalItemsCount'] as int,
      currency: json['currency'] as String,
    );
  }

  /// TrendAnalysisSummary'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'startValue': startValue,
      'endValue': endValue,
      'highestValue': highestValue,
      'lowestValue': lowestValue,
      'averageValue': averageValue,
      'trendChangePercentage': trendChangePercentage,
      'trendDirection': trendDirection,
      'trendStrength': trendStrength,
      'totalItemsCount': totalItemsCount,
      'currency': currency,
    };
  }

  /// Yükseliş trendi mi?
  bool get isUpwardTrend => trendDirection == 'Yükseliş';

  /// Düşüş trendi mi?
  bool get isDownwardTrend => trendDirection == 'Düşüş';

  /// Yatay trend mi?
  bool get isHorizontalTrend => trendDirection == 'Yatay';

  /// Güçlü trend mi?
  bool get isStrongTrend => trendStrength == 'Güçlü';

  /// Orta trend mi?
  bool get isMediumTrend => trendStrength == 'Orta';

  /// Zayıf trend mi?
  bool get isWeakTrend => trendStrength == 'Zayıf';

  /// Başlangıç değeri sıfır mı?
  bool get isZeroStartValue => startValue == 0;

  /// Bitiş değeri sıfır mı?
  bool get isZeroEndValue => endValue == 0;

  /// Ortalama değer sıfır mı?
  bool get isZeroAverageValue => averageValue == 0;

  /// En yüksek değer sıfır mı?
  bool get isZeroHighestValue => highestValue == 0;

  /// En düşük değer sıfır mı?
  bool get isZeroLowestValue => lowestValue == 0;

  /// Değer aralığı
  double get valueRange => highestValue - lowestValue;

  /// Değer aralığı yüzdesi
  double get valueRangePercentage {
    if (averageValue == 0) return 0;
    return (valueRange / averageValue) * 100;
  }

  /// Trend değişim tutarı
  double get trendChangeAmount => endValue - startValue;

  /// Pozitif trend değişimi mi?
  bool get isPositiveTrendChange => trendChangePercentage > 0;

  /// Negatif trend değişimi mi?
  bool get isNegativeTrendChange => trendChangePercentage < 0;

  /// Sıfır trend değişimi mi?
  bool get isZeroTrendChange => trendChangePercentage == 0;

  /// Yüksek trend değişimi mi? (%20'den fazla)
  bool get isHighTrendChange => trendChangePercentage.abs() > 20;

  /// Düşük trend değişimi mi? (%5'ten az)
  bool get isLowTrendChange => trendChangePercentage.abs() < 5;

  /// Orta trend değişimi mi? (%5-20 arası)
  bool get isMediumTrendChange =>
      trendChangePercentage.abs() >= 5 && trendChangePercentage.abs() <= 20;

  /// Sağlıklı trend mi? (Yükseliş ve güçlü)
  bool get isHealthyTrend => isUpwardTrend && isStrongTrend;

  /// Riskli trend mi? (Düşüş ve güçlü)
  bool get isRiskyTrend => isDownwardTrend && isStrongTrend;

  /// Kararsız trend mi? (Yatay veya zayıf)
  bool get isUnstableTrend => isHorizontalTrend || isWeakTrend;

  @override
  String toString() {
    return 'TrendAnalysisSummary(startValue: $startValue, endValue: $endValue, trendDirection: $trendDirection, trendChangePercentage: $trendChangePercentage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendAnalysisSummary &&
        other.startValue == startValue &&
        other.endValue == endValue;
  }

  @override
  int get hashCode => startValue.hashCode ^ endValue.hashCode;
}

