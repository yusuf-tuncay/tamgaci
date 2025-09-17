// ========== FIREBASE PRODUCT ENTITY ==========
// lib/features/products/data/models/firebase_product_entity.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/products/domain/entities/product.dart';

class ProductEntity {
  final String id;
  final String name;
  final String? description;
  final String? barcode;
  final String? sku;
  final double price;
  final String currency;
  final double? costPrice;
  final String category;
  final String? brand;
  final String? model;
  final String? color;
  final String? size;
  final double? weight;
  final String? weightUnit;
  final String? imageUrl;
  final int stockQuantity;
  final int? minStockLevel;
  final int? maxStockLevel;
  final String? unit;
  final String? location;
  final bool isActive;
  final bool isDigital;
  final String? tags;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductEntity({
    required this.id,
    required this.name,
    this.description,
    this.barcode,
    this.sku,
    required this.price,
    required this.currency,
    this.costPrice,
    required this.category,
    this.brand,
    this.model,
    this.color,
    this.size,
    this.weight,
    this.weightUnit,
    this.imageUrl,
    required this.stockQuantity,
    this.minStockLevel,
    this.maxStockLevel,
    this.unit,
    this.location,
    required this.isActive,
    required this.isDigital,
    this.tags,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductEntity(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      barcode: data['barcode'],
      sku: data['sku'],
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      costPrice: data['costPrice']?.toDouble(),
      category: data['category'] ?? '',
      brand: data['brand'],
      model: data['model'],
      color: data['color'],
      size: data['size'],
      weight: data['weight']?.toDouble(),
      weightUnit: data['weightUnit'],
      imageUrl: data['imageUrl'],
      stockQuantity: data['stockQuantity'] ?? 0,
      minStockLevel: data['minStockLevel'] ?? 0,
      maxStockLevel: data['maxStockLevel'] ?? 0,
      unit: data['unit'],
      location: data['location'],
      isActive: data['isActive'] ?? true,
      isDigital: data['isDigital'] ?? false,
      tags: data['tags'],
      notes: data['notes'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory ProductEntity.fromDomain(Product product) {
    return ProductEntity(
      id: product.id,
      name: product.name,
      description: product.description,
      barcode: product.barcode,
      sku: product.sku,
      price: product.salesPrice,
      currency: product.salesCurrency,
      costPrice: product.purchasePrice,
      category: product.category ?? '',
      brand: product.brand,
      model: null, // Removed from new Product entity
      color: null, // Removed from new Product entity
      size: null, // Removed from new Product entity
      weight: null, // Removed from new Product entity
      weightUnit: null, // Removed from new Product entity
      imageUrl: product.images.isNotEmpty ? product.images.first : null,
      stockQuantity: product.totalStockQuantity,
      minStockLevel: product.criticalStockQuantity,
      maxStockLevel: null, // Removed from new Product entity
      unit: null, // Removed from new Product entity
      location: product.shelfLocation,
      isActive: product.isActive,
      isDigital: false, // Removed from new Product entity
      tags: product.tags.join(','),
      notes: product.notes,
      createdBy: product.createdBy,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'barcode': barcode,
      'sku': sku,
      'price': price,
      'currency': currency,
      'costPrice': costPrice,
      'category': category,
      'brand': brand,
      'model': model,
      'color': color,
      'size': size,
      'weight': weight,
      'weightUnit': weightUnit,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'maxStockLevel': maxStockLevel,
      'unit': unit,
      'location': location,
      'isActive': isActive,
      'isDigital': isDigital,
      'tags': tags,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      description: description,
      barcode: barcode,
      sku: sku,
      salesPrice: price,
      salesCurrency: currency,
      purchasePrice: costPrice,
      category: category.isEmpty ? null : category,
      brand: brand,
      taxRate: 20.0, // Default tax rate
      shelfLocation: location,
      criticalStockQuantity: minStockLevel,
      tags: tags?.split(',') ?? [],
      images: imageUrl != null ? [imageUrl!] : [],
      isActive: isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// ProductEntity'yi kopyala ve güncelle
  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    String? sku,
    double? price,
    String? currency,
    double? costPrice,
    String? category,
    String? brand,
    String? model,
    String? color,
    String? size,
    double? weight,
    String? weightUnit,
    String? imageUrl,
    int? stockQuantity,
    int? minStockLevel,
    int? maxStockLevel,
    String? unit,
    String? location,
    bool? isActive,
    bool? isDigital,
    String? tags,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      costPrice: costPrice ?? this.costPrice,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      isDigital: isDigital ?? this.isDigital,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
