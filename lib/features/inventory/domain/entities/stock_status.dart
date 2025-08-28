/// Stok durumu domain entity'si
class StockStatus {
  final int? id;
  final int productId;
  final String productName;
  final String productCode;
  final int warehouseId;
  final String warehouseName;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final double unitPrice;
  final double totalValue;
  final DateTime updatedAt;

  StockStatus({
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

  /// Kopyalama metodu
  StockStatus copyWith({
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
    return StockStatus(
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

  /// Stok seviyesi durumu
  StockLevel get stockLevel {
    if (currentStock <= 0) return StockLevel.outOfStock;
    if (currentStock <= minStock) return StockLevel.low;
    if (currentStock >= maxStock) return StockLevel.high;
    return StockLevel.normal;
  }

  /// Stok seviyesi rengi
  String get stockLevelColor {
    switch (stockLevel) {
      case StockLevel.outOfStock:
        return '#FF0000'; // Kırmızı
      case StockLevel.low:
        return '#FFA500'; // Turuncu
      case StockLevel.normal:
        return '#00FF00'; // Yeşil
      case StockLevel.high:
        return '#0000FF'; // Mavi
    }
  }

  /// Stok seviyesi metni
  String get stockLevelText {
    switch (stockLevel) {
      case StockLevel.outOfStock:
        return 'Stokta Yok';
      case StockLevel.low:
        return 'Düşük Stok';
      case StockLevel.normal:
        return 'Normal';
      case StockLevel.high:
        return 'Yüksek Stok';
    }
  }
}

/// Stok seviyesi enum'u
enum StockLevel { outOfStock, low, normal, high }
