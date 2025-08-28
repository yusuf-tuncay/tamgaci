/// Ürün domain entity'si
class Product {
  final int? id;
  final String name;
  final String? description;
  final String? sku;
  final String? barcode;
  final String? category;
  final double unitPrice;
  final int stockQuantity;
  final int minStockLevel;
  final String unit;
  final double taxRate;
  final bool isActive;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    this.description,
    this.sku,
    this.barcode,
    this.category,
    required this.unitPrice,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.unit,
    required this.taxRate,
    this.isActive = true,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
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
    int? id,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    String? category,
    double? unitPrice,
    int? stockQuantity,
    int? minStockLevel,
    String? unit,
    double? taxRate,
    bool? isActive,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unit: unit ?? this.unit,
      taxRate: taxRate ?? this.taxRate,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
