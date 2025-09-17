// ========== PRODUCT VARIANT ENTITY ==========
// lib/features/products/domain/entities/product_variant.dart

/// Ürün varyantı entity'si
class ProductVariant {
  /// Varyant benzersiz ID'si
  final String id;

  /// Varyant adı (örn: "Kırmızı - M", "Büyük Boy")
  final String name;

  /// Varyant kodu
  final String? variantCode;

  /// Varyant barkodu
  final String? barcode;

  /// Varyant fiyatı (ana ürün fiyatından farklıysa)
  final double? price;

  /// Varyant maliyet fiyatı
  final double? costPrice;

  /// Stok miktarı
  final int stockQuantity;

  /// Kritik stok miktarı
  final int? criticalStockQuantity;

  /// Varyant özellikleri (renk, boyut, model vb.)
  final Map<String, String> attributes;

  /// Varyant resimleri
  final List<String> images;

  /// Aktif/Pasif durumu
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const ProductVariant({
    required this.id,
    required this.name,
    this.variantCode,
    this.barcode,
    this.price,
    this.costPrice,
    required this.stockQuantity,
    this.criticalStockQuantity,
    this.attributes = const {},
    this.images = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  ProductVariant copyWith({
    String? id,
    String? name,
    String? variantCode,
    String? barcode,
    double? price,
    double? costPrice,
    int? stockQuantity,
    int? criticalStockQuantity,
    Map<String, String>? attributes,
    List<String>? images,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      variantCode: variantCode ?? this.variantCode,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      criticalStockQuantity:
          criticalStockQuantity ?? this.criticalStockQuantity,
      attributes: attributes ?? this.attributes,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan ProductVariant oluştur
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      name: json['name'] as String,
      variantCode: json['variantCode'] as String?,
      barcode: json['barcode'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      criticalStockQuantity: json['criticalStockQuantity'] as int?,
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// ProductVariant'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'variantCode': variantCode,
      'barcode': barcode,
      'price': price,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'criticalStockQuantity': criticalStockQuantity,
      'attributes': attributes,
      'images': images,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Varyant özelliklerini string olarak döndür
  String get attributesString {
    if (attributes.isEmpty) return '';
    return attributes.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  /// Stok durumu
  String get stockStatus {
    if (stockQuantity <= 0) return 'Stokta Yok';
    if (criticalStockQuantity != null &&
        stockQuantity <= criticalStockQuantity!) {
      return 'Kritik Stok';
    }
    return 'Stokta Var';
  }

  /// Kritik stok mu?
  bool get isLowStock {
    if (criticalStockQuantity == null) return false;
    return stockQuantity <= criticalStockQuantity!;
  }

  @override
  String toString() {
    return 'ProductVariant(id: $id, name: $name, stockQuantity: $stockQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductVariant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
