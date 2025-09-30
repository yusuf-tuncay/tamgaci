// ========== FIREBASE PRODUCT ENTITY ==========
// lib/features/products/data/models/firebase_product_entity.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/products/domain/entities/product.dart';
import 'package:tamgaci/features/products/domain/entities/product_variant.dart';
import 'package:tamgaci/features/products/domain/entities/product_attribute.dart';

class ProductEntity {
  final String id;
  final String tenantId; // Multi-tenant güvenlik için zorunlu
  final String name;
  final String? description;
  final String? productCode;
  final String? sku;
  final String? barcode;
  final String? gs1Barcode;
  final String? category;
  final String? brand;
  final ProductType type;
  final double salesPrice;
  final double? purchasePrice;
  final String salesCurrency;
  final String? purchaseCurrency;
  final double salesTaxRate;
  final double? purchaseTaxRate;
  final TaxInclusiveOption salesTaxInclusive;
  final TaxInclusiveOption? purchaseTaxInclusive;
  final double? purchaseDiscount;
  final double? sct;
  final String? shelfLocation;
  final StockTrackingType stockTracking;
  final String? warehouseId;
  final String? warehouseName;
  final int stockQuantity;
  final int? criticalStockQuantity;
  final String? gtipCode;
  final String? countryCode;
  final List<String> tags;
  final List<String> images;
  final List<ProductVariant>? variants;
  final List<ProductAttribute>? attributes;
  final Map<String, dynamic>? attributeValues;
  final List<String>? linkedProducts;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  ProductEntity({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.productCode,
    this.sku,
    this.barcode,
    this.gs1Barcode,
    this.category,
    this.brand,
    required this.type,
    required this.salesPrice,
    this.purchasePrice,
    this.salesCurrency = 'TRY',
    this.purchaseCurrency,
    required this.salesTaxRate,
    this.purchaseTaxRate,
    this.salesTaxInclusive = TaxInclusiveOption.exclusive,
    this.purchaseTaxInclusive,
    this.purchaseDiscount,
    this.sct,
    this.shelfLocation,
    this.stockTracking = StockTrackingType.normal,
    this.warehouseId,
    this.warehouseName,
    this.stockQuantity = 0,
    this.criticalStockQuantity,
    this.gtipCode,
    this.countryCode,
    this.tags = const [],
    this.images = const [],
    this.variants,
    this.attributes,
    this.attributeValues,
    this.linkedProducts,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  factory ProductEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductEntity(
      id: doc.id,
      tenantId: data['tenantId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      productCode: data['productCode'],
      sku: data['sku'],
      barcode: data['barcode'],
      gs1Barcode: data['gs1Barcode'],
      category: data['category'],
      brand: data['brand'],
      type: ProductType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ProductType.stocked,
      ),
      salesPrice: (data['salesPrice'] ?? 0).toDouble(),
      purchasePrice: data['purchasePrice']?.toDouble(),
      salesCurrency: data['salesCurrency'] ?? 'TRY',
      purchaseCurrency: data['purchaseCurrency'],
      salesTaxRate: (data['salesTaxRate'] ?? 0).toDouble(),
      purchaseTaxRate: data['purchaseTaxRate']?.toDouble(),
      salesTaxInclusive: TaxInclusiveOption.values.firstWhere(
        (e) => e.name == data['salesTaxInclusive'],
        orElse: () => TaxInclusiveOption.exclusive,
      ),
      purchaseTaxInclusive: data['purchaseTaxInclusive'] != null
          ? TaxInclusiveOption.values.firstWhere(
              (e) => e.name == data['purchaseTaxInclusive'],
              orElse: () => TaxInclusiveOption.exclusive,
            )
          : null,
      purchaseDiscount: data['purchaseDiscount']?.toDouble(),
      sct: data['sct']?.toDouble(),
      shelfLocation: data['shelfLocation'],
      stockTracking: StockTrackingType.values.firstWhere(
        (e) => e.name == data['stockTracking'],
        orElse: () => StockTrackingType.normal,
      ),
      warehouseId: data['warehouseId'],
      warehouseName: data['warehouseName'],
      stockQuantity: data['stockQuantity'] ?? 0,
      criticalStockQuantity: data['criticalStockQuantity'],
      gtipCode: data['gtipCode'],
      countryCode: data['countryCode'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      variants: (data['variants'] as List<dynamic>?)
          ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: (data['attributes'] as List<dynamic>?)
          ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributeValues: data['attributeValues'] != null
          ? Map<String, dynamic>.from(data['attributeValues'])
          : null,
      linkedProducts: data['linkedProducts'] != null
          ? List<String>.from(data['linkedProducts'])
          : null,
      notes: data['notes'],
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory ProductEntity.fromDomain(Product product) {
    return ProductEntity(
      id: product.id,
      tenantId: product.tenantId,
      name: product.name,
      description: product.description,
      productCode: product.productCode,
      sku: product.sku,
      barcode: product.barcode,
      gs1Barcode: product.gs1Barcode,
      category: product.category,
      brand: product.brand,
      type: product.type,
      salesPrice: product.salesPrice,
      purchasePrice: product.purchasePrice,
      salesCurrency: product.salesCurrency,
      purchaseCurrency: product.purchaseCurrency,
      salesTaxRate: product.salesTaxRate,
      purchaseTaxRate: product.purchaseTaxRate,
      salesTaxInclusive: product.salesTaxInclusive,
      purchaseTaxInclusive: product.purchaseTaxInclusive,
      purchaseDiscount: product.purchaseDiscount,
      sct: product.sct,
      shelfLocation: product.shelfLocation,
      stockTracking: product.stockTracking,
      warehouseId: product.warehouseId,
      warehouseName: product.warehouseName,
      stockQuantity: product.stockQuantity,
      criticalStockQuantity: product.criticalStockQuantity,
      gtipCode: product.gtipCode,
      countryCode: product.countryCode,
      tags: product.tags,
      images: product.images,
      variants: product.variants,
      attributes: product.attributes,
      attributeValues: product.attributeValues,
      linkedProducts: product.linkedProducts,
      notes: product.notes,
      isActive: product.isActive,
      createdBy: product.createdBy,
      updatedBy: product.updatedBy,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
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
      'salesTaxRate': salesTaxRate,
      'purchaseTaxRate': purchaseTaxRate,
      'salesTaxInclusive': salesTaxInclusive.name,
      'purchaseTaxInclusive': purchaseTaxInclusive?.name,
      'purchaseDiscount': purchaseDiscount,
      'sct': sct,
      'shelfLocation': shelfLocation,
      'stockTracking': stockTracking.name,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'stockQuantity': stockQuantity,
      'criticalStockQuantity': criticalStockQuantity,
      'gtipCode': gtipCode,
      'countryCode': countryCode,
      'tags': tags,
      'images': images,
      'variants': variants?.map((e) => e.toJson()).toList(),
      'attributes': attributes?.map((e) => e.toJson()).toList(),
      'attributeValues': attributeValues,
      'linkedProducts': linkedProducts,
      'notes': notes,
      'isActive': isActive,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product toDomain() {
    return Product(
      id: id,
      tenantId: tenantId,
      name: name,
      description: description,
      productCode: productCode,
      sku: sku,
      barcode: barcode,
      gs1Barcode: gs1Barcode,
      category: category,
      brand: brand,
      type: type,
      salesPrice: salesPrice,
      purchasePrice: purchasePrice,
      salesCurrency: salesCurrency,
      purchaseCurrency: purchaseCurrency,
      salesTaxRate: salesTaxRate,
      purchaseTaxRate: purchaseTaxRate,
      salesTaxInclusive: salesTaxInclusive,
      purchaseTaxInclusive: purchaseTaxInclusive,
      purchaseDiscount: purchaseDiscount,
      sct: sct,
      shelfLocation: shelfLocation,
      stockTracking: stockTracking,
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      stockQuantity: stockQuantity,
      criticalStockQuantity: criticalStockQuantity,
      gtipCode: gtipCode,
      countryCode: countryCode,
      tags: tags,
      images: images,
      variants: variants,
      attributes: attributes,
      attributeValues: attributeValues,
      linkedProducts: linkedProducts,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// ProductEntity'yi kopyala ve güncelle
  ProductEntity copyWith({
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
    double? salesTaxRate,
    double? purchaseTaxRate,
    TaxInclusiveOption? salesTaxInclusive,
    TaxInclusiveOption? purchaseTaxInclusive,
    double? purchaseDiscount,
    double? sct,
    String? shelfLocation,
    StockTrackingType? stockTracking,
    String? warehouseId,
    String? warehouseName,
    int? stockQuantity,
    int? criticalStockQuantity,
    String? gtipCode,
    String? countryCode,
    List<String>? tags,
    List<String>? images,
    List<ProductVariant>? variants,
    List<ProductAttribute>? attributes,
    Map<String, dynamic>? attributeValues,
    List<String>? linkedProducts,
    String? notes,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      tenantId: tenantId,
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
      salesTaxRate: salesTaxRate ?? this.salesTaxRate,
      purchaseTaxRate: purchaseTaxRate ?? this.purchaseTaxRate,
      salesTaxInclusive: salesTaxInclusive ?? this.salesTaxInclusive,
      purchaseTaxInclusive: purchaseTaxInclusive ?? this.purchaseTaxInclusive,
      purchaseDiscount: purchaseDiscount ?? this.purchaseDiscount,
      sct: sct ?? this.sct,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      stockTracking: stockTracking ?? this.stockTracking,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      criticalStockQuantity:
          criticalStockQuantity ?? this.criticalStockQuantity,
      gtipCode: gtipCode ?? this.gtipCode,
      countryCode: countryCode ?? this.countryCode,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      variants: variants ?? this.variants,
      attributes: attributes ?? this.attributes,
      attributeValues: attributeValues ?? this.attributeValues,
      linkedProducts: linkedProducts ?? this.linkedProducts,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
