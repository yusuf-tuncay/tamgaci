import 'package:floor/floor.dart';

/// Ürün entity modeli
@Entity(tableName: 'products')
class ProductEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Ürün adı
  @ColumnInfo(name: 'name')
  final String name;

  /// Ürün açıklaması
  @ColumnInfo(name: 'description')
  final String? description;

  /// Ürün kodu/SKU
  @ColumnInfo(name: 'sku')
  final String? sku;

  /// Barkod
  @ColumnInfo(name: 'barcode')
  final String? barcode;

  /// Kategori
  @ColumnInfo(name: 'category')
  final String? category;

  /// Birim fiyat
  @ColumnInfo(name: 'unit_price')
  final double unitPrice;

  /// Stok miktarı
  @ColumnInfo(name: 'stock_quantity')
  final int stockQuantity;

  /// Minimum stok seviyesi
  @ColumnInfo(name: 'min_stock_level')
  final int minStockLevel;

  /// Birim (adet, kg, lt, vb.)
  @ColumnInfo(name: 'unit')
  final String unit;

  /// Vergi oranı (%)
  @ColumnInfo(name: 'tax_rate')
  final double taxRate;

  /// Aktif/Pasif durumu
  @ColumnInfo(name: 'is_active')
  final bool isActive;

  /// Resim URL'si
  @ColumnInfo(name: 'image_url')
  final String? imageUrl;

  /// Oluşturulma tarihi
  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  ProductEntity({
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

  /// Entity'den domain modeline dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'unitPrice': unitPrice,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'unit': unit,
      'taxRate': taxRate,
      'isActive': isActive ? 1 : 0,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Map'ten entity oluşturma
  factory ProductEntity.fromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      category: map['category'] as String?,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      stockQuantity: map['stockQuantity'] as int,
      minStockLevel: map['minStockLevel'] as int,
      unit: map['unit'] as String,
      taxRate: (map['taxRate'] as num).toDouble(),
      isActive: (map['isActive'] as int) == 1,
      imageUrl: map['imageUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  /// Kopyalama metodu
  ProductEntity copyWith({
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
    return ProductEntity(
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
