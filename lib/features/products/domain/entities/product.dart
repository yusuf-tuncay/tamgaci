import 'product_variant.dart';

/// Ürün türü enum'u
enum ProductType {
  stocked('Stoklu'),
  nonStocked('Stoksuz');

  const ProductType(this.displayName);
  final String displayName;
}

/// Stok takibi türü enum'u
enum StockTrackingType {
  normal('Normal'),
  serialNumber('Seri Numarası');

  const StockTrackingType(this.displayName);
  final String displayName;
}

/// KDV dahil seçeneği enum'u
enum TaxInclusiveOption {
  exclusive('KDV Hariç'),
  inclusive('KDV Dahil');

  const TaxInclusiveOption(this.displayName);
  final String displayName;
}

/// Ürün domain entity'si
class Product {
  final String id;
  final String name;
  final String? description;
  final String? productCode; // Otomatik + manuel ürün kodu
  final String? sku;
  final String? barcode; // Manuel barkod
  final String? gs1Barcode; // Otomatik GS1 barkod
  final String? category;
  final String? brand;
  final ProductType type; // Stoklu/Stoksuz
  final double salesPrice; // Satış fiyatı
  final double? purchasePrice; // Alış fiyatı
  final String salesCurrency; // Satış para birimi
  final String? purchaseCurrency; // Alış para birimi
  final double taxRate; // KDV oranı
  final TaxInclusiveOption taxInclusive; // KDV dahil/hariç
  final double? purchaseDiscount; // Alış iskontosu
  final double? sct; // ÖTV (Özel Tüketim Vergisi)
  final String? shelfLocation; // Raf yeri (depo modülüyle takip)
  final StockTrackingType stockTracking; // Stok takibi türü
  final int? criticalStockQuantity; // Kritik stok miktarı
  final String? gtipCode; // GTIP kodu
  final String? countryCode; // Ülke kodu
  final List<String> tags; // Etiketler
  final List<String> images; // Resimler
  final List<ProductVariant>? variants; // Varyantlar
  final List<String>?
      linkedProducts; // Bağlı ürünler (satıldığında stoktan düşsün)
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.productCode,
    this.sku,
    this.barcode,
    this.gs1Barcode,
    this.category,
    this.brand,
    this.type = ProductType.stocked,
    required this.salesPrice,
    this.purchasePrice,
    this.salesCurrency = 'TRY',
    this.purchaseCurrency,
    required this.taxRate,
    this.taxInclusive = TaxInclusiveOption.exclusive,
    this.purchaseDiscount,
    this.sct,
    this.shelfLocation,
    this.stockTracking = StockTrackingType.normal,
    this.criticalStockQuantity,
    this.gtipCode,
    this.countryCode,
    this.tags = const [],
    this.images = const [],
    this.variants,
    this.linkedProducts,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// Vergi dahil satış fiyatı
  double get salesPriceWithTax {
    if (taxInclusive == TaxInclusiveOption.inclusive) {
      return salesPrice;
    }
    return salesPrice * (1 + taxRate / 100);
  }

  /// Vergi dahil alış fiyatı
  double? get purchasePriceWithTax {
    if (purchasePrice == null) return null;
    if (taxInclusive == TaxInclusiveOption.inclusive) {
      return purchasePrice;
    }
    return purchasePrice! * (1 + taxRate / 100);
  }

  /// Toplam stok miktarı (varyantlar dahil)
  int get totalStockQuantity {
    if (variants == null || variants!.isEmpty) {
      return 0; // Ana ürün stok miktarı yok, sadece varyantlar var
    }
    return variants!
        .fold<int>(0, (sum, variant) => sum + variant.stockQuantity);
  }

  /// Kritik stok durumu
  bool get isLowStock {
    if (criticalStockQuantity == null) return false;
    return totalStockQuantity <= criticalStockQuantity!;
  }

  /// Stok durumu
  String get stockStatus {
    if (totalStockQuantity <= 0) return 'Stokta Yok';
    if (isLowStock) return 'Kritik Stok';
    return 'Stokta Var';
  }

  /// Kopyalama metodu
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? productCode,
    String? sku,
    String? barcode,
    String? gs1Barcode,
    String? category,
    String? brand,
    ProductType? type,
    double? salesPrice,
    double? purchasePrice,
    String? salesCurrency,
    String? purchaseCurrency,
    double? taxRate,
    TaxInclusiveOption? taxInclusive,
    double? purchaseDiscount,
    double? sct,
    String? shelfLocation,
    StockTrackingType? stockTracking,
    int? criticalStockQuantity,
    String? gtipCode,
    String? countryCode,
    List<String>? tags,
    List<String>? images,
    List<ProductVariant>? variants,
    List<String>? linkedProducts,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productCode: productCode ?? this.productCode,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      gs1Barcode: gs1Barcode ?? this.gs1Barcode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      salesPrice: salesPrice ?? this.salesPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salesCurrency: salesCurrency ?? this.salesCurrency,
      purchaseCurrency: purchaseCurrency ?? this.purchaseCurrency,
      taxRate: taxRate ?? this.taxRate,
      taxInclusive: taxInclusive ?? this.taxInclusive,
      purchaseDiscount: purchaseDiscount ?? this.purchaseDiscount,
      sct: sct ?? this.sct,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      stockTracking: stockTracking ?? this.stockTracking,
      criticalStockQuantity:
          criticalStockQuantity ?? this.criticalStockQuantity,
      gtipCode: gtipCode ?? this.gtipCode,
      countryCode: countryCode ?? this.countryCode,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      variants: variants ?? this.variants,
      linkedProducts: linkedProducts ?? this.linkedProducts,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
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
      productCode: json['productCode'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      gs1Barcode: json['gs1Barcode'] as String?,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      type: ProductType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProductType.stocked,
      ),
      salesPrice: (json['salesPrice'] as num).toDouble(),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      salesCurrency: json['salesCurrency'] as String? ?? 'TRY',
      purchaseCurrency: json['purchaseCurrency'] as String?,
      taxRate: (json['taxRate'] as num).toDouble(),
      taxInclusive: TaxInclusiveOption.values.firstWhere(
        (e) => e.name == json['taxInclusive'],
        orElse: () => TaxInclusiveOption.exclusive,
      ),
      purchaseDiscount: (json['purchaseDiscount'] as num?)?.toDouble(),
      sct: (json['sct'] as num?)?.toDouble(),
      shelfLocation: json['shelfLocation'] as String?,
      stockTracking: StockTrackingType.values.firstWhere(
        (e) => e.name == json['stockTracking'],
        orElse: () => StockTrackingType.normal,
      ),
      criticalStockQuantity: json['criticalStockQuantity'] as int?,
      gtipCode: json['gtipCode'] as String?,
      countryCode: json['countryCode'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      linkedProducts: json['linkedProducts'] != null
          ? List<String>.from(json['linkedProducts'])
          : null,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
      'productCode': productCode,
      'sku': sku,
      'barcode': barcode,
      'gs1Barcode': gs1Barcode,
      'category': category,
      'brand': brand,
      'type': type.name,
      'salesPrice': salesPrice,
      'purchasePrice': purchasePrice,
      'salesCurrency': salesCurrency,
      'purchaseCurrency': purchaseCurrency,
      'taxRate': taxRate,
      'taxInclusive': taxInclusive.name,
      'purchaseDiscount': purchaseDiscount,
      'sct': sct,
      'shelfLocation': shelfLocation,
      'stockTracking': stockTracking.name,
      'criticalStockQuantity': criticalStockQuantity,
      'gtipCode': gtipCode,
      'countryCode': countryCode,
      'tags': tags,
      'images': images,
      'variants': variants?.map((e) => e.toJson()).toList(),
      'linkedProducts': linkedProducts,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, type: $type, salesPrice: $salesPrice, totalStock: $totalStockQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
