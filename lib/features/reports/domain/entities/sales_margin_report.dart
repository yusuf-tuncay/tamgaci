// ========== SALES MARGIN REPORT ENTITY ==========
// lib/features/reports/domain/entities/sales_margin_report.dart

/// Satış marjı raporu türü
enum SalesMarginReportType {
  product('Ürün Bazlı'),
  customer('Müşteri Bazlı'),
  category('Kategori Bazlı'),
  period('Dönem Bazlı'),
  combined('Kombine');

  const SalesMarginReportType(this.displayName);
  final String displayName;
}

/// Satış marjı raporu entity'si
class SalesMarginReport {
  final String id;
  final String reportNumber;
  final SalesMarginReportType type;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final List<SalesMarginItem> items;
  final SalesMarginSummary summary;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const SalesMarginReport({
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
  SalesMarginReport copyWith({
    String? id,
    String? reportNumber,
    SalesMarginReportType? type,
    DateTime? reportDate,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? currency,
    List<SalesMarginItem>? items,
    SalesMarginSummary? summary,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return SalesMarginReport(
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

  /// JSON'dan SalesMarginReport oluştur
  factory SalesMarginReport.fromJson(Map<String, dynamic> json) {
    return SalesMarginReport(
      id: json['id'] as String,
      reportNumber: json['reportNumber'] as String,
      type: SalesMarginReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SalesMarginReportType.product,
      ),
      reportDate: DateTime.parse(json['reportDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      currency: json['currency'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SalesMarginItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary:
          SalesMarginSummary.fromJson(json['summary'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// SalesMarginReport'ı JSON'a çevir
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

  /// Ürün bazlı rapor mu?
  bool get isProductReport => type == SalesMarginReportType.product;

  /// Müşteri bazlı rapor mu?
  bool get isCustomerReport => type == SalesMarginReportType.customer;

  /// Kategori bazlı rapor mu?
  bool get isCategoryReport => type == SalesMarginReportType.category;

  /// Dönem bazlı rapor mu?
  bool get isPeriodReport => type == SalesMarginReportType.period;

  /// Kombine rapor mu?
  bool get isCombinedReport => type == SalesMarginReportType.combined;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Dönem süresi (gün)
  int get periodDays => periodEnd.difference(periodStart).inDays + 1;

  /// Toplam satış tutarı
  double get totalSalesAmount => summary.totalSalesAmount;

  /// Toplam maliyet
  double get totalCost => summary.totalCost;

  /// Toplam marj
  double get totalMargin => summary.totalMargin;

  /// Ortalama marj yüzdesi
  double get averageMarginPercentage => summary.averageMarginPercentage;

  /// En yüksek marj yüzdesi
  double get highestMarginPercentage => summary.highestMarginPercentage;

  /// En düşük marj yüzdesi
  double get lowestMarginPercentage => summary.lowestMarginPercentage;

  /// Sağlıklı marj mı? (%20'den fazla)
  bool get isHealthyMargin => averageMarginPercentage > 20;

  /// Düşük marj mı? (%10'dan az)
  bool get isLowMargin => averageMarginPercentage < 10;

  /// Orta marj mı? (%10-20 arası)
  bool get isMediumMargin =>
      averageMarginPercentage >= 10 && averageMarginPercentage <= 20;

  @override
  String toString() {
    return 'SalesMarginReport(id: $id, reportNumber: $reportNumber, type: $type, totalMargin: $totalMargin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesMarginReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Satış marjı kalemi
class SalesMarginItem {
  final String id;
  final String? productId;
  final String? productName;
  final String? productCode;
  final String? categoryId;
  final String? categoryName;
  final String? customerId;
  final String? customerName;
  final String? customerCode;
  final double quantity;
  final double unitPrice;
  final double totalSalesAmount;
  final double unitCost;
  final double totalCost;
  final double margin;
  final double marginPercentage;
  final String currency;
  final DateTime saleDate;
  final String? saleNumber;
  final String? notes;

  const SalesMarginItem({
    required this.id,
    this.productId,
    this.productName,
    this.productCode,
    this.categoryId,
    this.categoryName,
    this.customerId,
    this.customerName,
    this.customerCode,
    required this.quantity,
    required this.unitPrice,
    required this.totalSalesAmount,
    required this.unitCost,
    required this.totalCost,
    required this.margin,
    required this.marginPercentage,
    required this.currency,
    required this.saleDate,
    this.saleNumber,
    this.notes,
  });

  /// CopyWith metodu
  SalesMarginItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productCode,
    String? categoryId,
    String? categoryName,
    String? customerId,
    String? customerName,
    String? customerCode,
    double? quantity,
    double? unitPrice,
    double? totalSalesAmount,
    double? unitCost,
    double? totalCost,
    double? margin,
    double? marginPercentage,
    String? currency,
    DateTime? saleDate,
    String? saleNumber,
    String? notes,
  }) {
    return SalesMarginItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerCode: customerCode ?? this.customerCode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalSalesAmount: totalSalesAmount ?? this.totalSalesAmount,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      margin: margin ?? this.margin,
      marginPercentage: marginPercentage ?? this.marginPercentage,
      currency: currency ?? this.currency,
      saleDate: saleDate ?? this.saleDate,
      saleNumber: saleNumber ?? this.saleNumber,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan SalesMarginItem oluştur
  factory SalesMarginItem.fromJson(Map<String, dynamic> json) {
    return SalesMarginItem(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      productCode: json['productCode'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerCode: json['customerCode'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalSalesAmount: (json['totalSalesAmount'] as num).toDouble(),
      unitCost: (json['unitCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      margin: (json['margin'] as num).toDouble(),
      marginPercentage: (json['marginPercentage'] as num).toDouble(),
      currency: json['currency'] as String,
      saleDate: DateTime.parse(json['saleDate'] as String),
      saleNumber: json['saleNumber'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// SalesMarginItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'customerId': customerId,
      'customerName': customerName,
      'customerCode': customerCode,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalSalesAmount': totalSalesAmount,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'margin': margin,
      'marginPercentage': marginPercentage,
      'currency': currency,
      'saleDate': saleDate.toIso8601String(),
      'saleNumber': saleNumber,
      'notes': notes,
    };
  }

  /// Ürün bilgisi var mı?
  bool get hasProductInfo => productId != null && productName != null;

  /// Kategori bilgisi var mı?
  bool get hasCategoryInfo => categoryId != null && categoryName != null;

  /// Müşteri bilgisi var mı?
  bool get hasCustomerInfo => customerId != null && customerName != null;

  /// Ürün kodu var mı?
  bool get hasProductCode => productCode != null && productCode!.isNotEmpty;

  /// Müşteri kodu var mı?
  bool get hasCustomerCode => customerCode != null && customerCode!.isNotEmpty;

  /// Satış numarası var mı?
  bool get hasSaleNumber => saleNumber != null && saleNumber!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Pozitif marj mı?
  bool get isPositiveMargin => margin > 0;

  /// Negatif marj mı?
  bool get isNegativeMargin => margin < 0;

  /// Sıfır marj mı?
  bool get isZeroMargin => margin == 0;

  /// Yüksek marj mı? (%30'dan fazla)
  bool get isHighMargin => marginPercentage > 30;

  /// Düşük marj mı? (%10'dan az)
  bool get isLowMargin => marginPercentage < 10;

  /// Orta marj mı? (%10-30 arası)
  bool get isMediumMargin => marginPercentage >= 10 && marginPercentage <= 30;

  /// Sağlıklı marj mı? (%20'den fazla)
  bool get isHealthyMargin => marginPercentage > 20;

  /// Birim marj
  double get unitMargin => unitPrice - unitCost;

  /// Birim marj yüzdesi
  double get unitMarginPercentage {
    if (unitPrice == 0) return 0;
    return (unitMargin / unitPrice) * 100;
  }

  @override
  String toString() {
    return 'SalesMarginItem(id: $id, productName: $productName, margin: $margin, marginPercentage: $marginPercentage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesMarginItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Satış marjı özeti
class SalesMarginSummary {
  final double totalSalesAmount;
  final double totalCost;
  final double totalMargin;
  final double averageMarginPercentage;
  final double highestMarginPercentage;
  final double lowestMarginPercentage;
  final int totalItemsCount;
  final int positiveMarginItemsCount;
  final int negativeMarginItemsCount;
  final int zeroMarginItemsCount;
  final String currency;

  const SalesMarginSummary({
    required this.totalSalesAmount,
    required this.totalCost,
    required this.totalMargin,
    required this.averageMarginPercentage,
    required this.highestMarginPercentage,
    required this.lowestMarginPercentage,
    required this.totalItemsCount,
    required this.positiveMarginItemsCount,
    required this.negativeMarginItemsCount,
    required this.zeroMarginItemsCount,
    required this.currency,
  });

  /// CopyWith metodu
  SalesMarginSummary copyWith({
    double? totalSalesAmount,
    double? totalCost,
    double? totalMargin,
    double? averageMarginPercentage,
    double? highestMarginPercentage,
    double? lowestMarginPercentage,
    int? totalItemsCount,
    int? positiveMarginItemsCount,
    int? negativeMarginItemsCount,
    int? zeroMarginItemsCount,
    String? currency,
  }) {
    return SalesMarginSummary(
      totalSalesAmount: totalSalesAmount ?? this.totalSalesAmount,
      totalCost: totalCost ?? this.totalCost,
      totalMargin: totalMargin ?? this.totalMargin,
      averageMarginPercentage:
          averageMarginPercentage ?? this.averageMarginPercentage,
      highestMarginPercentage:
          highestMarginPercentage ?? this.highestMarginPercentage,
      lowestMarginPercentage:
          lowestMarginPercentage ?? this.lowestMarginPercentage,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      positiveMarginItemsCount:
          positiveMarginItemsCount ?? this.positiveMarginItemsCount,
      negativeMarginItemsCount:
          negativeMarginItemsCount ?? this.negativeMarginItemsCount,
      zeroMarginItemsCount: zeroMarginItemsCount ?? this.zeroMarginItemsCount,
      currency: currency ?? this.currency,
    );
  }

  /// JSON'dan SalesMarginSummary oluştur
  factory SalesMarginSummary.fromJson(Map<String, dynamic> json) {
    return SalesMarginSummary(
      totalSalesAmount: (json['totalSalesAmount'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      totalMargin: (json['totalMargin'] as num).toDouble(),
      averageMarginPercentage:
          (json['averageMarginPercentage'] as num).toDouble(),
      highestMarginPercentage:
          (json['highestMarginPercentage'] as num).toDouble(),
      lowestMarginPercentage:
          (json['lowestMarginPercentage'] as num).toDouble(),
      totalItemsCount: json['totalItemsCount'] as int,
      positiveMarginItemsCount: json['positiveMarginItemsCount'] as int,
      negativeMarginItemsCount: json['negativeMarginItemsCount'] as int,
      zeroMarginItemsCount: json['zeroMarginItemsCount'] as int,
      currency: json['currency'] as String,
    );
  }

  /// SalesMarginSummary'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'totalSalesAmount': totalSalesAmount,
      'totalCost': totalCost,
      'totalMargin': totalMargin,
      'averageMarginPercentage': averageMarginPercentage,
      'highestMarginPercentage': highestMarginPercentage,
      'lowestMarginPercentage': lowestMarginPercentage,
      'totalItemsCount': totalItemsCount,
      'positiveMarginItemsCount': positiveMarginItemsCount,
      'negativeMarginItemsCount': negativeMarginItemsCount,
      'zeroMarginItemsCount': zeroMarginItemsCount,
      'currency': currency,
    };
  }

  /// Pozitif marj yüzdesi
  double get positiveMarginPercentage {
    if (totalItemsCount == 0) return 0;
    return (positiveMarginItemsCount / totalItemsCount) * 100;
  }

  /// Negatif marj yüzdesi
  double get negativeMarginPercentage {
    if (totalItemsCount == 0) return 0;
    return (negativeMarginItemsCount / totalItemsCount) * 100;
  }

  /// Sıfır marj yüzdesi
  double get zeroMarginPercentage {
    if (totalItemsCount == 0) return 0;
    return (zeroMarginItemsCount / totalItemsCount) * 100;
  }

  /// Sağlıklı marj mı? (%20'den fazla)
  bool get isHealthyMargin => averageMarginPercentage > 20;

  /// Düşük marj mı? (%10'dan az)
  bool get isLowMargin => averageMarginPercentage < 10;

  /// Orta marj mı? (%10-20 arası)
  bool get isMediumMargin =>
      averageMarginPercentage >= 10 && averageMarginPercentage <= 20;

  /// Pozitif marj var mı?
  bool get hasPositiveMargin => totalMargin > 0;

  /// Negatif marj var mı?
  bool get hasNegativeMargin => totalMargin < 0;

  /// Sıfır marj mı?
  bool get isZeroMargin => totalMargin == 0;

  /// Marj dağılımı sağlıklı mı? (Pozitif marj %80'den fazla)
  bool get isHealthyMarginDistribution => positiveMarginPercentage > 80;

  /// Marj dağılımı riskli mi? (Negatif marj %20'den fazla)
  bool get isRiskyMarginDistribution => negativeMarginPercentage > 20;

  @override
  String toString() {
    return 'SalesMarginSummary(totalSalesAmount: $totalSalesAmount, totalMargin: $totalMargin, averageMarginPercentage: $averageMarginPercentage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesMarginSummary &&
        other.totalSalesAmount == totalSalesAmount &&
        other.totalMargin == totalMargin;
  }

  @override
  int get hashCode => totalSalesAmount.hashCode ^ totalMargin.hashCode;
}

