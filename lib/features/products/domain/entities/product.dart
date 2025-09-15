/// Ürün türü enum'u
enum ProductType {
  product('Ürün'),
  service('Hizmet'),
  rawMaterial('Hammadde'),
  finishedGood('Mamul');

  const ProductType(this.displayName);
  final String displayName;
}

/// Ürün domain entity'si
class Product {
  final String id;
  final String name;
  final String? description;
  final String? sku;
  final String? barcode;
  final String? category;
  final ProductType type;
  final double unitPrice;
  final double? costPrice; // Maliyet fiyatı
  final int stockQuantity;
  final int minStockLevel;
  final int maxStockLevel; // Maksimum stok seviyesi
  final String unit;
  final double taxRate;
  final String currency;
  final bool isActive;
  final String? imageUrl;
  final String? supplierId; // Ana tedarikçi ID'si
  final String? warehouseId; // Ana depo ID'si
  final String? shelfLocation; // Raf konumu
  final String? brand; // Marka
  final String? model; // Model
  final String? color; // Renk
  final String? size; // Boyut
  final double? weight; // Ağırlık
  final String? weightUnit; // Ağırlık birimi
  final bool isDigital; // Dijital ürün mü
  final List<String> tags; // Etiketler
  final String? notes; // Notlar
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    this.barcode,
    this.category,
    this.type = ProductType.product,
    required this.unitPrice,
    this.costPrice,
    required this.stockQuantity,
    required this.minStockLevel,
    this.maxStockLevel = 1000,
    required this.unit,
    required this.taxRate,
    this.currency = 'TRY',
    this.isActive = true,
    this.imageUrl,
    this.supplierId,
    this.warehouseId,
    this.shelfLocation,
    this.brand,
    this.model,
    this.color,
    this.size,
    this.weight,
    this.weightUnit,
    this.isDigital = false,
    this.tags = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// Vergi dahil fiyat
  double get priceWithTax => unitPrice * (1 + taxRate / 100);

  /// Stok durumu
  String get stockStatus {
    if (stockQuantity <= 0) return 'Stokta Yok';
    if (stockQuantity <= minStockLevel) return 'Kritik Stok';
    return 'Stokta Var';
  }

  /// Stok durumu rengi
  bool get isLowStock => stockQuantity <= minStockLevel;

  /// Kopyalama metodu
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    String? category,
    ProductType? type,
    double? unitPrice,
    double? costPrice,
    int? stockQuantity,
    int? minStockLevel,
    int? maxStockLevel,
    String? unit,
    double? taxRate,
    String? currency,
    bool? isActive,
    String? imageUrl,
    String? supplierId,
    String? warehouseId,
    String? shelfLocation,
    String? brand,
    String? model,
    String? color,
    String? size,
    double? weight,
    String? weightUnit,
    bool? isDigital,
    List<String>? tags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      type: type ?? this.type,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      unit: unit ?? this.unit,
      taxRate: taxRate ?? this.taxRate,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      supplierId: supplierId ?? this.supplierId,
      warehouseId: warehouseId ?? this.warehouseId,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      isDigital: isDigital ?? this.isDigital,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan Product oluştur
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      category: json['category'] as String?,
      type: ProductType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProductType.product,
      ),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      costPrice: json['costPrice'] != null ? (json['costPrice'] as num).toDouble() : null,
      stockQuantity: json['stockQuantity'] as int,
      minStockLevel: json['minStockLevel'] as int,
      maxStockLevel: json['maxStockLevel'] as int,
      unit: json['unit'] as String,
      taxRate: (json['taxRate'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      supplierId: json['supplierId'] as String?,
      warehouseId: json['warehouseId'] as String?,
      shelfLocation: json['shelfLocation'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      weightUnit: json['weightUnit'] as String?,
      isDigital: json['isDigital'] as bool? ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// Product'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'type': type.name,
      'unitPrice': unitPrice,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'maxStockLevel': maxStockLevel,
      'unit': unit,
      'taxRate': taxRate,
      'currency': currency,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'supplierId': supplierId,
      'warehouseId': warehouseId,
      'shelfLocation': shelfLocation,
      'brand': brand,
      'model': model,
      'color': color,
      'size': size,
      'weight': weight,
      'weightUnit': weightUnit,
      'isDigital': isDigital,
      'tags': tags,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, type: $type, unitPrice: $unitPrice, stockQuantity: $stockQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}