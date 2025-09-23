// ========== STOCK TURNOVER REPORT ENTITY ==========
// lib/features/reports/domain/entities/stock_turnover_report.dart

/// Stok devir raporu türü
enum StockTurnoverReportType {
  product('Ürün Bazlı'),
  category('Kategori Bazlı'),
  warehouse('Depo Bazlı'),
  combined('Kombine');

  const StockTurnoverReportType(this.displayName);
  final String displayName;
}

/// Stok devir raporu entity'si
class StockTurnoverReport {
  final String id;
  final String reportNumber;
  final StockTurnoverReportType type;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final List<StockTurnoverItem> items;
  final StockTurnoverSummary summary;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const StockTurnoverReport({
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
  StockTurnoverReport copyWith({
    String? id,
    String? reportNumber,
    StockTurnoverReportType? type,
    DateTime? reportDate,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? currency,
    List<StockTurnoverItem>? items,
    StockTurnoverSummary? summary,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return StockTurnoverReport(
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

  /// JSON'dan StockTurnoverReport oluştur
  factory StockTurnoverReport.fromJson(Map<String, dynamic> json) {
    return StockTurnoverReport(
      id: json['id'] as String,
      reportNumber: json['reportNumber'] as String,
      type: StockTurnoverReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StockTurnoverReportType.product,
      ),
      reportDate: DateTime.parse(json['reportDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      currency: json['currency'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => StockTurnoverItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: StockTurnoverSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// StockTurnoverReport'ı JSON'a çevir
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
  bool get isProductReport => type == StockTurnoverReportType.product;

  /// Kategori bazlı rapor mu?
  bool get isCategoryReport => type == StockTurnoverReportType.category;

  /// Depo bazlı rapor mu?
  bool get isWarehouseReport => type == StockTurnoverReportType.warehouse;

  /// Kombine rapor mu?
  bool get isCombinedReport => type == StockTurnoverReportType.combined;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Dönem süresi (gün)
  int get periodDays => periodEnd.difference(periodStart).inDays + 1;

  /// Ortalama stok devir hızı
  double get averageTurnoverRate => summary.averageTurnoverRate;

  /// En yüksek stok devir hızı
  double get highestTurnoverRate => summary.highestTurnoverRate;

  /// En düşük stok devir hızı
  double get lowestTurnoverRate => summary.lowestTurnoverRate;

  /// Toplam stok değeri
  double get totalStockValue => summary.totalStockValue;

  /// Toplam satış değeri
  double get totalSalesValue => summary.totalSalesValue;

  /// Sağlıklı devir hızı mı? (4'ten fazla)
  bool get isHealthyTurnover => averageTurnoverRate > 4;

  /// Düşük devir hızı mı? (2'den az)
  bool get isLowTurnover => averageTurnoverRate < 2;

  /// Orta devir hızı mı? (2-4 arası)
  bool get isMediumTurnover =>
      averageTurnoverRate >= 2 && averageTurnoverRate <= 4;

  @override
  String toString() {
    return 'StockTurnoverReport(id: $id, reportNumber: $reportNumber, type: $type, averageTurnoverRate: $averageTurnoverRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockTurnoverReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Stok devir kalemi
class StockTurnoverItem {
  final String id;
  final String? productId;
  final String? productName;
  final String? productCode;
  final String? categoryId;
  final String? categoryName;
  final String? warehouseId;
  final String? warehouseName;
  final double beginningStock;
  final double endingStock;
  final double averageStock;
  final double costOfGoodsSold;
  final double turnoverRate;
  final int daysInInventory;
  final String currency;
  final String? notes;

  const StockTurnoverItem({
    required this.id,
    this.productId,
    this.productName,
    this.productCode,
    this.categoryId,
    this.categoryName,
    this.warehouseId,
    this.warehouseName,
    required this.beginningStock,
    required this.endingStock,
    required this.averageStock,
    required this.costOfGoodsSold,
    required this.turnoverRate,
    required this.daysInInventory,
    required this.currency,
    this.notes,
  });

  /// CopyWith metodu
  StockTurnoverItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productCode,
    String? categoryId,
    String? categoryName,
    String? warehouseId,
    String? warehouseName,
    double? beginningStock,
    double? endingStock,
    double? averageStock,
    double? costOfGoodsSold,
    double? turnoverRate,
    int? daysInInventory,
    String? currency,
    String? notes,
  }) {
    return StockTurnoverItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      beginningStock: beginningStock ?? this.beginningStock,
      endingStock: endingStock ?? this.endingStock,
      averageStock: averageStock ?? this.averageStock,
      costOfGoodsSold: costOfGoodsSold ?? this.costOfGoodsSold,
      turnoverRate: turnoverRate ?? this.turnoverRate,
      daysInInventory: daysInInventory ?? this.daysInInventory,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan StockTurnoverItem oluştur
  factory StockTurnoverItem.fromJson(Map<String, dynamic> json) {
    return StockTurnoverItem(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      productCode: json['productCode'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      warehouseId: json['warehouseId'] as String?,
      warehouseName: json['warehouseName'] as String?,
      beginningStock: (json['beginningStock'] as num).toDouble(),
      endingStock: (json['endingStock'] as num).toDouble(),
      averageStock: (json['averageStock'] as num).toDouble(),
      costOfGoodsSold: (json['costOfGoodsSold'] as num).toDouble(),
      turnoverRate: (json['turnoverRate'] as num).toDouble(),
      daysInInventory: json['daysInInventory'] as int,
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
    );
  }

  /// StockTurnoverItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'beginningStock': beginningStock,
      'endingStock': endingStock,
      'averageStock': averageStock,
      'costOfGoodsSold': costOfGoodsSold,
      'turnoverRate': turnoverRate,
      'daysInInventory': daysInInventory,
      'currency': currency,
      'notes': notes,
    };
  }

  /// Ürün bilgisi var mı?
  bool get hasProductInfo => productId != null && productName != null;

  /// Kategori bilgisi var mı?
  bool get hasCategoryInfo => categoryId != null && categoryName != null;

  /// Depo bilgisi var mı?
  bool get hasWarehouseInfo => warehouseId != null && warehouseName != null;

  /// Ürün kodu var mı?
  bool get hasProductCode => productCode != null && productCode!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Yüksek devir hızı mı? (6'dan fazla)
  bool get isHighTurnover => turnoverRate > 6;

  /// Düşük devir hızı mı? (2'den az)
  bool get isLowTurnover => turnoverRate < 2;

  /// Orta devir hızı mı? (2-6 arası)
  bool get isMediumTurnover => turnoverRate >= 2 && turnoverRate <= 6;

  /// Sağlıklı devir hızı mı? (4'ten fazla)
  bool get isHealthyTurnover => turnoverRate > 4;

  /// Stok artışı mı?
  bool get isStockIncrease => endingStock > beginningStock;

  /// Stok azalışı mı?
  bool get isStockDecrease => endingStock < beginningStock;

  /// Stok değişmedi mi?
  bool get isStockUnchanged => endingStock == beginningStock;

  /// Stok değişim miktarı
  double get stockChangeAmount => endingStock - beginningStock;

  /// Stok değişim yüzdesi
  double get stockChangePercentage {
    if (beginningStock == 0) return 0;
    return (stockChangeAmount / beginningStock) * 100;
  }

  /// Stok devir hızı kategorisi
  String get turnoverCategory {
    if (isHighTurnover) return 'Yüksek';
    if (isLowTurnover) return 'Düşük';
    return 'Orta';
  }

  /// Stok durumu
  String get stockStatus {
    if (isStockIncrease) return 'Artış';
    if (isStockDecrease) return 'Azalış';
    return 'Sabit';
  }

  @override
  String toString() {
    return 'StockTurnoverItem(id: $id, productName: $productName, turnoverRate: $turnoverRate, daysInInventory: $daysInInventory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockTurnoverItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Stok devir özeti
class StockTurnoverSummary {
  final double totalStockValue;
  final double totalSalesValue;
  final double averageTurnoverRate;
  final double highestTurnoverRate;
  final double lowestTurnoverRate;
  final int totalItemsCount;
  final int highTurnoverItemsCount;
  final int mediumTurnoverItemsCount;
  final int lowTurnoverItemsCount;
  final String currency;

  const StockTurnoverSummary({
    required this.totalStockValue,
    required this.totalSalesValue,
    required this.averageTurnoverRate,
    required this.highestTurnoverRate,
    required this.lowestTurnoverRate,
    required this.totalItemsCount,
    required this.highTurnoverItemsCount,
    required this.mediumTurnoverItemsCount,
    required this.lowTurnoverItemsCount,
    required this.currency,
  });

  /// CopyWith metodu
  StockTurnoverSummary copyWith({
    double? totalStockValue,
    double? totalSalesValue,
    double? averageTurnoverRate,
    double? highestTurnoverRate,
    double? lowestTurnoverRate,
    int? totalItemsCount,
    int? highTurnoverItemsCount,
    int? mediumTurnoverItemsCount,
    int? lowTurnoverItemsCount,
    String? currency,
  }) {
    return StockTurnoverSummary(
      totalStockValue: totalStockValue ?? this.totalStockValue,
      totalSalesValue: totalSalesValue ?? this.totalSalesValue,
      averageTurnoverRate: averageTurnoverRate ?? this.averageTurnoverRate,
      highestTurnoverRate: highestTurnoverRate ?? this.highestTurnoverRate,
      lowestTurnoverRate: lowestTurnoverRate ?? this.lowestTurnoverRate,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      highTurnoverItemsCount:
          highTurnoverItemsCount ?? this.highTurnoverItemsCount,
      mediumTurnoverItemsCount:
          mediumTurnoverItemsCount ?? this.mediumTurnoverItemsCount,
      lowTurnoverItemsCount:
          lowTurnoverItemsCount ?? this.lowTurnoverItemsCount,
      currency: currency ?? this.currency,
    );
  }

  /// JSON'dan StockTurnoverSummary oluştur
  factory StockTurnoverSummary.fromJson(Map<String, dynamic> json) {
    return StockTurnoverSummary(
      totalStockValue: (json['totalStockValue'] as num).toDouble(),
      totalSalesValue: (json['totalSalesValue'] as num).toDouble(),
      averageTurnoverRate: (json['averageTurnoverRate'] as num).toDouble(),
      highestTurnoverRate: (json['highestTurnoverRate'] as num).toDouble(),
      lowestTurnoverRate: (json['lowestTurnoverRate'] as num).toDouble(),
      totalItemsCount: json['totalItemsCount'] as int,
      highTurnoverItemsCount: json['highTurnoverItemsCount'] as int,
      mediumTurnoverItemsCount: json['mediumTurnoverItemsCount'] as int,
      lowTurnoverItemsCount: json['lowTurnoverItemsCount'] as int,
      currency: json['currency'] as String,
    );
  }

  /// StockTurnoverSummary'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'totalStockValue': totalStockValue,
      'totalSalesValue': totalSalesValue,
      'averageTurnoverRate': averageTurnoverRate,
      'highestTurnoverRate': highestTurnoverRate,
      'lowestTurnoverRate': lowestTurnoverRate,
      'totalItemsCount': totalItemsCount,
      'highTurnoverItemsCount': highTurnoverItemsCount,
      'mediumTurnoverItemsCount': mediumTurnoverItemsCount,
      'lowTurnoverItemsCount': lowTurnoverItemsCount,
      'currency': currency,
    };
  }

  /// Yüksek devir hızı yüzdesi
  double get highTurnoverPercentage {
    if (totalItemsCount == 0) return 0;
    return (highTurnoverItemsCount / totalItemsCount) * 100;
  }

  /// Orta devir hızı yüzdesi
  double get mediumTurnoverPercentage {
    if (totalItemsCount == 0) return 0;
    return (mediumTurnoverItemsCount / totalItemsCount) * 100;
  }

  /// Düşük devir hızı yüzdesi
  double get lowTurnoverPercentage {
    if (totalItemsCount == 0) return 0;
    return (lowTurnoverItemsCount / totalItemsCount) * 100;
  }

  /// Sağlıklı devir hızı mı? (4'ten fazla)
  bool get isHealthyTurnover => averageTurnoverRate > 4;

  /// Düşük devir hızı mı? (2'den az)
  bool get isLowTurnover => averageTurnoverRate < 2;

  /// Orta devir hızı mı? (2-4 arası)
  bool get isMediumTurnover =>
      averageTurnoverRate >= 2 && averageTurnoverRate <= 4;

  /// Devir hızı dağılımı sağlıklı mı? (Yüksek devir %60'dan fazla)
  bool get isHealthyTurnoverDistribution => highTurnoverPercentage > 60;

  /// Devir hızı dağılımı riskli mi? (Düşük devir %30'dan fazla)
  bool get isRiskyTurnoverDistribution => lowTurnoverPercentage > 30;

  /// Stok değeri sıfır mı?
  bool get isZeroStockValue => totalStockValue == 0;

  /// Satış değeri sıfır mı?
  bool get isZeroSalesValue => totalSalesValue == 0;

  @override
  String toString() {
    return 'StockTurnoverSummary(totalStockValue: $totalStockValue, totalSalesValue: $totalSalesValue, averageTurnoverRate: $averageTurnoverRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockTurnoverSummary &&
        other.totalStockValue == totalStockValue &&
        other.averageTurnoverRate == averageTurnoverRate;
  }

  @override
  int get hashCode => totalStockValue.hashCode ^ averageTurnoverRate.hashCode;
}

