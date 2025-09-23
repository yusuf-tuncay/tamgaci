// ========== STOCK COUNT ENTITY ==========
// lib/features/inventory/domain/entities/stock_count.dart

/// Stok sayım durumu
enum StockCountStatus {
  draft('Taslak'),
  inProgress('Devam Ediyor'),
  completed('Tamamlandı'),
  approved('Onaylandı'),
  cancelled('İptal');

  const StockCountStatus(this.displayName);
  final String displayName;
}

/// Stok sayım türü
enum StockCountType {
  full('Tam Sayım'),
  partial('Kısmi Sayım'),
  cycle('Döngüsel Sayım'),
  spot('Anlık Sayım');

  const StockCountType(this.displayName);
  final String displayName;
}

/// Stok sayım entity'si
class StockCount {
  final String id;
  final String countNumber;
  final String name;
  final String? description;
  final StockCountType type;
  final StockCountStatus status;
  final String warehouseId;
  final String? warehouseName;
  final DateTime countDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<StockCountItem> items;
  final String? notes;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockCount({
    required this.id,
    required this.countNumber,
    required this.name,
    this.description,
    required this.type,
    required this.status,
    required this.warehouseId,
    this.warehouseName,
    required this.countDate,
    this.startDate,
    this.endDate,
    this.items = const [],
    this.notes,
    this.approvedBy,
    this.approvedAt,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  StockCount copyWith({
    String? id,
    String? countNumber,
    String? name,
    String? description,
    StockCountType? type,
    StockCountStatus? status,
    String? warehouseId,
    String? warehouseName,
    DateTime? countDate,
    DateTime? startDate,
    DateTime? endDate,
    List<StockCountItem>? items,
    String? notes,
    String? approvedBy,
    DateTime? approvedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockCount(
      id: id ?? this.id,
      countNumber: countNumber ?? this.countNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      countDate: countDate ?? this.countDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan StockCount oluştur
  factory StockCount.fromJson(Map<String, dynamic> json) {
    return StockCount(
      id: json['id'] as String,
      countNumber: json['countNumber'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: StockCountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StockCountType.full,
      ),
      status: StockCountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockCountStatus.draft,
      ),
      warehouseId: json['warehouseId'] as String,
      warehouseName: json['warehouseName'] as String?,
      countDate: DateTime.parse(json['countDate'] as String),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => StockCountItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// StockCount'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countNumber': countNumber,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'countDate': countDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'notes': notes,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Toplam ürün sayısı
  int get totalItems => items.length;

  /// Sayılan ürün sayısı
  int get countedItems =>
      items.where((item) => item.countedQuantity != null).length;

  /// Sayım ilerlemesi (yüzde)
  double get progressPercentage {
    if (totalItems == 0) return 0;
    return (countedItems / totalItems) * 100;
  }

  /// Sayım tamamlandı mı?
  bool get isCompleted => status == StockCountStatus.completed;

  /// Sayım onaylandı mı?
  bool get isApproved => status == StockCountStatus.approved;

  @override
  String toString() {
    return 'StockCount(id: $id, countNumber: $countNumber, name: $name, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockCount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Stok sayım kalemi
class StockCountItem {
  final String id;
  final String productId;
  final String? productName;
  final String? productSku;
  final String? productBarcode;
  final double expectedQuantity;
  final double? countedQuantity;
  final String unit;
  final double unitCost;
  final String? location;
  final String? notes;
  final DateTime? countedAt;
  final String? countedBy;
  final bool isVariance; // Fark var mı?
  final double? varianceQuantity; // Fark miktarı
  final double? varianceValue; // Fark değeri

  const StockCountItem({
    required this.id,
    required this.productId,
    this.productName,
    this.productSku,
    this.productBarcode,
    required this.expectedQuantity,
    this.countedQuantity,
    required this.unit,
    required this.unitCost,
    this.location,
    this.notes,
    this.countedAt,
    this.countedBy,
    this.isVariance = false,
    this.varianceQuantity,
    this.varianceValue,
  });

  /// CopyWith metodu
  StockCountItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productSku,
    String? productBarcode,
    double? expectedQuantity,
    double? countedQuantity,
    String? unit,
    double? unitCost,
    String? location,
    String? notes,
    DateTime? countedAt,
    String? countedBy,
    bool? isVariance,
    double? varianceQuantity,
    double? varianceValue,
  }) {
    return StockCountItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productBarcode: productBarcode ?? this.productBarcode,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      countedAt: countedAt ?? this.countedAt,
      countedBy: countedBy ?? this.countedBy,
      isVariance: isVariance ?? this.isVariance,
      varianceQuantity: varianceQuantity ?? this.varianceQuantity,
      varianceValue: varianceValue ?? this.varianceValue,
    );
  }

  /// JSON'dan StockCountItem oluştur
  factory StockCountItem.fromJson(Map<String, dynamic> json) {
    return StockCountItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productSku: json['productSku'] as String?,
      productBarcode: json['productBarcode'] as String?,
      expectedQuantity: (json['expectedQuantity'] as num).toDouble(),
      countedQuantity: (json['countedQuantity'] as num?)?.toDouble(),
      unit: json['unit'] as String,
      unitCost: (json['unitCost'] as num).toDouble(),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      countedAt: json['countedAt'] != null
          ? DateTime.parse(json['countedAt'] as String)
          : null,
      countedBy: json['countedBy'] as String?,
      isVariance: json['isVariance'] ?? false,
      varianceQuantity: (json['varianceQuantity'] as num?)?.toDouble(),
      varianceValue: (json['varianceValue'] as num?)?.toDouble(),
    );
  }

  /// StockCountItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'productBarcode': productBarcode,
      'expectedQuantity': expectedQuantity,
      'countedQuantity': countedQuantity,
      'unit': unit,
      'unitCost': unitCost,
      'location': location,
      'notes': notes,
      'countedAt': countedAt?.toIso8601String(),
      'countedBy': countedBy,
      'isVariance': isVariance,
      'varianceQuantity': varianceQuantity,
      'varianceValue': varianceValue,
    };
  }

  /// Sayım yapıldı mı?
  bool get isCounted => countedQuantity != null;

  /// Fark hesapla
  double get calculatedVariance {
    if (countedQuantity == null) return 0;
    return countedQuantity! - expectedQuantity;
  }

  /// Fark yüzdesi
  double get variancePercentage {
    if (expectedQuantity == 0) return 0;
    return (calculatedVariance / expectedQuantity) * 100;
  }

  @override
  String toString() {
    return 'StockCountItem(id: $id, productId: $productId, expectedQuantity: $expectedQuantity, countedQuantity: $countedQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockCountItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
