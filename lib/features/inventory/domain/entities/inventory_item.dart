import 'package:equatable/equatable.dart';

/// Envanter öğesi türü
enum InventoryItemType {
  product('Ürün'),
  material('Malzeme'),
  equipment('Ekipman'),
  consumable('Sarf Malzeme'),
  other('Diğer');

  const InventoryItemType(this.displayName);
  final String displayName;
}

/// Envanter öğesi durumu
enum InventoryItemStatus {
  active('Aktif'),
  inactive('Pasif'),
  discontinued('Üretimden Kaldırıldı'),
  outOfStock('Stokta Yok');

  const InventoryItemStatus(this.displayName);
  final String displayName;
}

/// Envanter öğesi entity'si
class InventoryItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? sku;
  final String? barcode;
  final InventoryItemType type;
  final InventoryItemStatus status;
  final String? category;
  final String? brand;
  final String? model;
  final String? unit;
  final double currentStock;
  final double minimumStock;
  final double maximumStock;
  final double reorderPoint;
  final double reorderQuantity;
  final double unitCost;
  final double unitPrice;
  final String currency;
  final String? location;
  final String? supplierId;
  final String? supplierName;
  final DateTime? lastRestocked;
  final DateTime? lastSold;
  final DateTime? expiryDate;
  final Map<String, dynamic> attributes;
  final List<String> tags;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const InventoryItem({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    this.barcode,
    required this.type,
    required this.status,
    this.category,
    this.brand,
    this.model,
    required this.unit,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.unitCost,
    required this.unitPrice,
    required this.currency,
    this.location,
    this.supplierId,
    this.supplierName,
    this.lastRestocked,
    this.lastSold,
    this.expiryDate,
    this.attributes = const {},
    this.tags = const [],
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    InventoryItemType? type,
    InventoryItemStatus? status,
    String? category,
    String? brand,
    String? model,
    String? unit,
    double? currentStock,
    double? minimumStock,
    double? maximumStock,
    double? reorderPoint,
    double? reorderQuantity,
    double? unitCost,
    double? unitPrice,
    String? currency,
    String? location,
    String? supplierId,
    String? supplierName,
    DateTime? lastRestocked,
    DateTime? lastSold,
    DateTime? expiryDate,
    Map<String, dynamic>? attributes,
    List<String>? tags,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      unitCost: unitCost ?? this.unitCost,
      unitPrice: unitPrice ?? this.unitPrice,
      currency: currency ?? this.currency,
      location: location ?? this.location,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      lastRestocked: lastRestocked ?? this.lastRestocked,
      lastSold: lastSold ?? this.lastSold,
      expiryDate: expiryDate ?? this.expiryDate,
      attributes: attributes ?? this.attributes,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'type': type.name,
      'status': status.name,
      'category': category,
      'brand': brand,
      'model': model,
      'unit': unit,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'reorderPoint': reorderPoint,
      'reorderQuantity': reorderQuantity,
      'unitCost': unitCost,
      'unitPrice': unitPrice,
      'currency': currency,
      'location': location,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'lastRestocked': lastRestocked?.toIso8601String(),
      'lastSold': lastSold?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'attributes': attributes,
      'tags': tags,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      type: InventoryItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InventoryItemType.product,
      ),
      status: InventoryItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InventoryItemStatus.active,
      ),
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      unit: json['unit'] as String,
      currentStock: (json['currentStock'] as num).toDouble(),
      minimumStock: (json['minimumStock'] as num).toDouble(),
      maximumStock: (json['maximumStock'] as num).toDouble(),
      reorderPoint: (json['reorderPoint'] as num).toDouble(),
      reorderQuantity: (json['reorderQuantity'] as num).toDouble(),
      unitCost: (json['unitCost'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      location: json['location'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      lastRestocked: json['lastRestocked'] != null
          ? DateTime.parse(json['lastRestocked'] as String)
          : null,
      lastSold: json['lastSold'] != null
          ? DateTime.parse(json['lastSold'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sku,
        barcode,
        type,
        status,
        category,
        brand,
        model,
        unit,
        currentStock,
        minimumStock,
        maximumStock,
        reorderPoint,
        reorderQuantity,
        unitCost,
        unitPrice,
        currency,
        location,
        supplierId,
        supplierName,
        lastRestocked,
        lastSold,
        expiryDate,
        attributes,
        tags,
        images,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
