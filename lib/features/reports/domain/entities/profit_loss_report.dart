// ========== PROFIT LOSS REPORT ENTITY ==========
// lib/features/reports/domain/entities/profit_loss_report.dart

/// Kar/zarar raporu türü
enum ProfitLossReportType {
  monthly('Aylık'),
  quarterly('Üç Aylık'),
  yearly('Yıllık'),
  custom('Özel Dönem');

  const ProfitLossReportType(this.displayName);
  final String displayName;
}

/// Kar/zarar raporu entity'si
class ProfitLossReport {
  final String id;
  final String reportNumber;
  final ProfitLossReportType type;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final List<ProfitLossItem> items;
  final ProfitLossSummary summary;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const ProfitLossReport({
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
  ProfitLossReport copyWith({
    String? id,
    String? reportNumber,
    ProfitLossReportType? type,
    DateTime? reportDate,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? currency,
    List<ProfitLossItem>? items,
    ProfitLossSummary? summary,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ProfitLossReport(
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

  /// JSON'dan ProfitLossReport oluştur
  factory ProfitLossReport.fromJson(Map<String, dynamic> json) {
    return ProfitLossReport(
      id: json['id'] as String,
      reportNumber: json['reportNumber'] as String,
      type: ProfitLossReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProfitLossReportType.monthly,
      ),
      reportDate: DateTime.parse(json['reportDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      currency: json['currency'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ProfitLossItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary:
          ProfitLossSummary.fromJson(json['summary'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// ProfitLossReport'ı JSON'a çevir
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
  bool get isMonthlyReport => type == ProfitLossReportType.monthly;

  /// Üç aylık rapor mu?
  bool get isQuarterlyReport => type == ProfitLossReportType.quarterly;

  /// Yıllık rapor mu?
  bool get isYearlyReport => type == ProfitLossReportType.yearly;

  /// Özel dönem raporu mu?
  bool get isCustomReport => type == ProfitLossReportType.custom;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Dönem süresi (gün)
  int get periodDays => periodEnd.difference(periodStart).inDays + 1;

  /// Net kar/zarar
  double get netProfitLoss => summary.netProfitLoss;

  /// Kar mı?
  bool get isProfit => netProfitLoss > 0;

  /// Zarar mı?
  bool get isLoss => netProfitLoss < 0;

  /// Sıfır mı?
  bool get isBreakEven => netProfitLoss == 0;

  @override
  String toString() {
    return 'ProfitLossReport(id: $id, reportNumber: $reportNumber, type: $type, netProfitLoss: $netProfitLoss)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfitLossReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Kar/zarar kalemi
class ProfitLossItem {
  final String id;
  final String accountCode; // Hesap kodu
  final String accountName; // Hesap adı
  final String accountType; // Hesap türü (Gelir, Gider, Varlık, Yükümlülük)
  final double amount;
  final String currency;
  final String? notes;

  const ProfitLossItem({
    required this.id,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.amount,
    required this.currency,
    this.notes,
  });

  /// CopyWith metodu
  ProfitLossItem copyWith({
    String? id,
    String? accountCode,
    String? accountName,
    String? accountType,
    double? amount,
    String? currency,
    String? notes,
  }) {
    return ProfitLossItem(
      id: id ?? this.id,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan ProfitLossItem oluştur
  factory ProfitLossItem.fromJson(Map<String, dynamic> json) {
    return ProfitLossItem(
      id: json['id'] as String,
      accountCode: json['accountCode'] as String,
      accountName: json['accountName'] as String,
      accountType: json['accountType'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
    );
  }

  /// ProfitLossItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountCode': accountCode,
      'accountName': accountName,
      'accountType': accountType,
      'amount': amount,
      'currency': currency,
      'notes': notes,
    };
  }

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Gelir hesabı mı?
  bool get isRevenueAccount => accountType == 'Gelir';

  /// Gider hesabı mı?
  bool get isExpenseAccount => accountType == 'Gider';

  /// Varlık hesabı mı?
  bool get isAssetAccount => accountType == 'Varlık';

  /// Yükümlülük hesabı mı?
  bool get isLiabilityAccount => accountType == 'Yükümlülük';

  /// Pozitif tutar mı?
  bool get isPositiveAmount => amount > 0;

  /// Negatif tutar mı?
  bool get isNegativeAmount => amount < 0;

  /// Sıfır tutar mı?
  bool get isZeroAmount => amount == 0;

  /// Yüksek tutar mı? (100,000'den fazla)
  bool get isHighAmount => amount.abs() > 100000;

  /// Düşük tutar mı? (1,000'den az)
  bool get isLowAmount => amount.abs() < 1000;

  /// Orta tutar mı? (1,000-100,000 arası)
  bool get isMediumAmount => amount.abs() >= 1000 && amount.abs() <= 100000;

  /// Tutar kategorisi
  String get amountCategory {
    if (isHighAmount) return 'Yüksek';
    if (isLowAmount) return 'Düşük';
    return 'Orta';
  }

  /// Tutar durumu
  String get amountStatus {
    if (isPositiveAmount) return 'Pozitif';
    if (isNegativeAmount) return 'Negatif';
    return 'Sıfır';
  }

  @override
  String toString() {
    return 'ProfitLossItem(id: $id, accountCode: $accountCode, accountName: $accountName, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfitLossItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Kar/zarar özeti
class ProfitLossSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double grossProfit;
  final double operatingProfit;
  final double netProfitLoss;
  final double totalAssets;
  final double totalLiabilities;
  final double equity;
  final int totalItemsCount;
  final String currency;

  const ProfitLossSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.grossProfit,
    required this.operatingProfit,
    required this.netProfitLoss,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.equity,
    required this.totalItemsCount,
    required this.currency,
  });

  /// CopyWith metodu
  ProfitLossSummary copyWith({
    double? totalRevenue,
    double? totalExpenses,
    double? grossProfit,
    double? operatingProfit,
    double? netProfitLoss,
    double? totalAssets,
    double? totalLiabilities,
    double? equity,
    int? totalItemsCount,
    String? currency,
  }) {
    return ProfitLossSummary(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      grossProfit: grossProfit ?? this.grossProfit,
      operatingProfit: operatingProfit ?? this.operatingProfit,
      netProfitLoss: netProfitLoss ?? this.netProfitLoss,
      totalAssets: totalAssets ?? this.totalAssets,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      equity: equity ?? this.equity,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      currency: currency ?? this.currency,
    );
  }

  /// JSON'dan ProfitLossSummary oluştur
  factory ProfitLossSummary.fromJson(Map<String, dynamic> json) {
    return ProfitLossSummary(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      grossProfit: (json['grossProfit'] as num).toDouble(),
      operatingProfit: (json['operatingProfit'] as num).toDouble(),
      netProfitLoss: (json['netProfitLoss'] as num).toDouble(),
      totalAssets: (json['totalAssets'] as num).toDouble(),
      totalLiabilities: (json['totalLiabilities'] as num).toDouble(),
      equity: (json['equity'] as num).toDouble(),
      totalItemsCount: json['totalItemsCount'] as int,
      currency: json['currency'] as String,
    );
  }

  /// ProfitLossSummary'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'grossProfit': grossProfit,
      'operatingProfit': operatingProfit,
      'netProfitLoss': netProfitLoss,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'equity': equity,
      'totalItemsCount': totalItemsCount,
      'currency': currency,
    };
  }

  /// Kar mı?
  bool get isProfit => netProfitLoss > 0;

  /// Zarar mı?
  bool get isLoss => netProfitLoss < 0;

  /// Sıfır mı?
  bool get isBreakEven => netProfitLoss == 0;

  /// Brüt kar mı?
  bool get isGrossProfit => grossProfit > 0;

  /// İşletme karı mı?
  bool get isOperatingProfit => operatingProfit > 0;

  /// Toplam gelir sıfır mı?
  bool get isZeroRevenue => totalRevenue == 0;

  /// Toplam gider sıfır mı?
  bool get isZeroExpenses => totalExpenses == 0;

  /// Toplam varlık sıfır mı?
  bool get isZeroAssets => totalAssets == 0;

  /// Toplam yükümlülük sıfır mı?
  bool get isZeroLiabilities => totalLiabilities == 0;

  /// Özkaynak sıfır mı?
  bool get isZeroEquity => equity == 0;

  /// Brüt kar marjı
  double get grossProfitMargin {
    if (totalRevenue == 0) return 0;
    return (grossProfit / totalRevenue) * 100;
  }

  /// İşletme kar marjı
  double get operatingProfitMargin {
    if (totalRevenue == 0) return 0;
    return (operatingProfit / totalRevenue) * 100;
  }

  /// Net kar marjı
  double get netProfitMargin {
    if (totalRevenue == 0) return 0;
    return (netProfitLoss / totalRevenue) * 100;
  }

  /// Gider oranı
  double get expenseRatio {
    if (totalRevenue == 0) return 0;
    return (totalExpenses / totalRevenue) * 100;
  }

  /// Varlık getirisi
  double get returnOnAssets {
    if (totalAssets == 0) return 0;
    return (netProfitLoss / totalAssets) * 100;
  }

  /// Özkaynak getirisi
  double get returnOnEquity {
    if (equity == 0) return 0;
    return (netProfitLoss / equity) * 100;
  }

  /// Borç/özkaynak oranı
  double get debtToEquityRatio {
    if (equity == 0) return 0;
    return totalLiabilities / equity;
  }

  /// Sağlıklı kar marjı mı? (%10'dan fazla)
  bool get isHealthyProfitMargin => netProfitMargin > 10;

  /// Düşük kar marjı mı? (%5'ten az)
  bool get isLowProfitMargin => netProfitMargin < 5;

  /// Orta kar marjı mı? (%5-10 arası)
  bool get isMediumProfitMargin =>
      netProfitMargin >= 5 && netProfitMargin <= 10;

  /// Sağlıklı gider oranı mı? (%80'den az)
  bool get isHealthyExpenseRatio => expenseRatio < 80;

  /// Yüksek gider oranı mı? (%90'dan fazla)
  bool get isHighExpenseRatio => expenseRatio > 90;

  /// Sağlıklı borç/özkaynak oranı mı? (2'den az)
  bool get isHealthyDebtToEquityRatio => debtToEquityRatio < 2;

  /// Yüksek borç/özkaynak oranı mı? (3'ten fazla)
  bool get isHighDebtToEquityRatio => debtToEquityRatio > 3;

  @override
  String toString() {
    return 'ProfitLossSummary(totalRevenue: $totalRevenue, totalExpenses: $totalExpenses, netProfitLoss: $netProfitLoss)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfitLossSummary &&
        other.totalRevenue == totalRevenue &&
        other.netProfitLoss == netProfitLoss;
  }

  @override
  int get hashCode => totalRevenue.hashCode ^ netProfitLoss.hashCode;
}

