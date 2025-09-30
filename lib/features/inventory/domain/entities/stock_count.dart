import 'package:equatable/equatable.dart';

/// Stok Sayımı Durumu
enum StockCountStatus {
  draft('Taslak'),
  inProgress('Devam Ediyor'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi');

  const StockCountStatus(this.displayName);
  final String displayName;
}

/// Stok Sayımı Tipi
enum StockCountType {
  full('Tam Sayım'),
  partial('Kısmi Sayım'),
  cycle('Döngüsel Sayım');

  const StockCountType(this.displayName);
  final String displayName;
}

/// Stok Sayımı Entity
class StockCount extends Equatable {
  final String id;
  final String tenantId;
  final String warehouseId;
  final String warehouseName;
  final String countNumber; // Sayım numarası (otomatik)
  final StockCountType type;
  final StockCountStatus status;
  final DateTime countDate;
  final String? description;
  final String? notes;
  final List<StockCountItem> items;
  final int totalItemsCount; // Toplam ürün sayısı
  final int countedItemsCount; // Sayılan ürün sayısı
  final double? totalVariance; // Toplam fark tutarı
  final String createdBy;
  final String? completedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const StockCount({
    required this.id,
    required this.tenantId,
    required this.warehouseId,
    required this.warehouseName,
    required this.countNumber,
    required this.type,
    required this.status,
    required this.countDate,
    this.description,
    this.notes,
    required this.items,
    required this.totalItemsCount,
    required this.countedItemsCount,
    this.totalVariance,
    required this.createdBy,
    this.completedBy,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        warehouseId,
        warehouseName,
        countNumber,
        type,
        status,
        countDate,
        description,
        notes,
        items,
        totalItemsCount,
        countedItemsCount,
        totalVariance,
        createdBy,
        completedBy,
        createdAt,
        updatedAt,
        completedAt,
      ];

  StockCount copyWith({
    String? id,
    String? tenantId,
    String? warehouseId,
    String? warehouseName,
    String? countNumber,
    StockCountType? type,
    StockCountStatus? status,
    DateTime? countDate,
    String? description,
    String? notes,
    List<StockCountItem>? items,
    int? totalItemsCount,
    int? countedItemsCount,
    double? totalVariance,
    String? createdBy,
    String? completedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return StockCount(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      countNumber: countNumber ?? this.countNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      countDate: countDate ?? this.countDate,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      countedItemsCount: countedItemsCount ?? this.countedItemsCount,
      totalVariance: totalVariance ?? this.totalVariance,
      createdBy: createdBy ?? this.createdBy,
      completedBy: completedBy ?? this.completedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'countNumber': countNumber,
      'type': type.name,
      'status': status.name,
      'countDate': countDate.toIso8601String(),
      'description': description,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'totalItemsCount': totalItemsCount,
      'countedItemsCount': countedItemsCount,
      'totalVariance': totalVariance,
      'createdBy': createdBy,
      'completedBy': completedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory StockCount.fromJson(Map<String, dynamic> json) {
    return StockCount(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      warehouseId: json['warehouseId'] as String,
      warehouseName: json['warehouseName'] as String,
      countNumber: json['countNumber'] as String,
      type: StockCountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StockCountType.full,
      ),
      status: StockCountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockCountStatus.draft,
      ),
      countDate: DateTime.parse(json['countDate'] as String),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => StockCountItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          <StockCountItem>[],
      totalItemsCount: json['totalItemsCount'] as int,
      countedItemsCount: json['countedItemsCount'] as int,
      totalVariance: json['totalVariance'] as double?,
      createdBy: json['createdBy'] as String,
      completedBy: json['completedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// Stok Sayım Kalemi
class StockCountItem extends Equatable {
  final String productId;
  final String productName;
  final String? productCode;
  final String? barcode;
  final String? variantId;
  final String? variantName;
  final int systemQuantity; // Sistemdeki miktar
  final int? countedQuantity; // Sayılan miktar
  final int? variance; // Fark
  final double? varianceValue; // Fark tutarı
  final String? shelfLocation;
  final String? notes;
  final bool isCounted; // Sayıldı mı?
  final DateTime? countedAt;
  final String? countedBy;

  const StockCountItem({
    required this.productId,
    required this.productName,
    this.productCode,
    this.barcode,
    this.variantId,
    this.variantName,
    required this.systemQuantity,
    this.countedQuantity,
    this.variance,
    this.varianceValue,
    this.shelfLocation,
    this.notes,
    this.isCounted = false,
    this.countedAt,
    this.countedBy,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        productCode,
        barcode,
        variantId,
        variantName,
        systemQuantity,
        countedQuantity,
        variance,
        varianceValue,
        shelfLocation,
        notes,
        isCounted,
        countedAt,
        countedBy,
      ];

  StockCountItem copyWith({
    String? productId,
    String? productName,
    String? productCode,
    String? barcode,
    String? variantId,
    String? variantName,
    int? systemQuantity,
    int? countedQuantity,
    int? variance,
    double? varianceValue,
    String? shelfLocation,
    String? notes,
    bool? isCounted,
    DateTime? countedAt,
    String? countedBy,
  }) {
    return StockCountItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      barcode: barcode ?? this.barcode,
      variantId: variantId ?? this.variantId,
      variantName: variantName ?? this.variantName,
      systemQuantity: systemQuantity ?? this.systemQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
      variance: variance ?? this.variance,
      varianceValue: varianceValue ?? this.varianceValue,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      notes: notes ?? this.notes,
      isCounted: isCounted ?? this.isCounted,
      countedAt: countedAt ?? this.countedAt,
      countedBy: countedBy ?? this.countedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'barcode': barcode,
      'variantId': variantId,
      'variantName': variantName,
      'systemQuantity': systemQuantity,
      'countedQuantity': countedQuantity,
      'variance': variance,
      'varianceValue': varianceValue,
      'shelfLocation': shelfLocation,
      'notes': notes,
      'isCounted': isCounted,
      'countedAt': countedAt?.toIso8601String(),
      'countedBy': countedBy,
    };
  }

  factory StockCountItem.fromJson(Map<String, dynamic> json) {
    return StockCountItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productCode: json['productCode'] as String?,
      barcode: json['barcode'] as String?,
      variantId: json['variantId'] as String?,
      variantName: json['variantName'] as String?,
      systemQuantity: json['systemQuantity'] as int,
      countedQuantity: json['countedQuantity'] as int?,
      variance: json['variance'] as int?,
      varianceValue: json['varianceValue'] as double?,
      shelfLocation: json['shelfLocation'] as String?,
      notes: json['notes'] as String?,
      isCounted: json['isCounted'] as bool? ?? false,
      countedAt: json['countedAt'] != null
          ? DateTime.parse(json['countedAt'] as String)
          : null,
      countedBy: json['countedBy'] as String?,
    );
  }
}