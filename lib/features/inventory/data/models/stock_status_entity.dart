import 'package:floor/floor.dart';

/// Stok durumu entity modeli
@Entity(tableName: 'stock_status')
class StockStatusEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Ürün ID'si
  @ColumnInfo(name: 'product_id')
  final int productId;

  /// Ürün adı
  @ColumnInfo(name: 'product_name')
  final String productName;

  /// Ürün kodu
  @ColumnInfo(name: 'product_code')
  final String productCode;

  /// Depo ID'si
  @ColumnInfo(name: 'warehouse_id')
  final int warehouseId;

  /// Depo adı
  @ColumnInfo(name: 'warehouse_name')
  final String warehouseName;

  /// Mevcut stok miktarı
  @ColumnInfo(name: 'current_stock')
  final int currentStock;

  /// Minimum stok seviyesi
  @ColumnInfo(name: 'min_stock')
  final int minStock;

  /// Maksimum stok seviyesi
  @ColumnInfo(name: 'max_stock')
  final int maxStock;

  /// Birim fiyat
  @ColumnInfo(name: 'unit_price')
  final double unitPrice;

  /// Toplam değer
  @ColumnInfo(name: 'total_value')
  final double totalValue;

  /// Son güncelleme tarihi
  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  StockStatusEntity({
    this.id,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.warehouseId,
    required this.warehouseName,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.unitPrice,
    required this.totalValue,
    required this.updatedAt,
  });

  /// Entity'den domain modeline dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'currentStock': currentStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'unitPrice': unitPrice,
      'totalValue': totalValue,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Map'ten entity oluşturma
  factory StockStatusEntity.fromMap(Map<String, dynamic> map) {
    return StockStatusEntity(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      productName: map['productName'] as String,
      productCode: map['productCode'] as String,
      warehouseId: map['warehouseId'] as int,
      warehouseName: map['warehouseName'] as String,
      currentStock: map['currentStock'] as int,
      minStock: map['minStock'] as int,
      maxStock: map['maxStock'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      totalValue: (map['totalValue'] as num).toDouble(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  /// Kopyalama metodu
  StockStatusEntity copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productCode,
    int? warehouseId,
    String? warehouseName,
    int? currentStock,
    int? minStock,
    int? maxStock,
    double? unitPrice,
    double? totalValue,
    DateTime? updatedAt,
  }) {
    return StockStatusEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      unitPrice: unitPrice ?? this.unitPrice,
      totalValue: totalValue ?? this.totalValue,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
