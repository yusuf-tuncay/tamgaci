// ========== PRICE LIST ENTITY ==========
// lib/features/products/domain/entities/price_list.dart

/// Fiyat listesi türü
enum PriceListType {
  standard('Standart'),
  wholesale('Toptan'),
  retail('Perakende'),
  promotional('Promosyon'),
  seasonal('Sezonluk'),
  customer('Müşteri Özel');

  const PriceListType(this.displayName);
  final String displayName;
}

/// Fiyat listesi entity'si
class PriceList {
  final String id;
  final String name;
  final String? description;
  final PriceListType type;
  final String currency;
  final DateTime validFrom;
  final DateTime? validTo;
  final bool isActive;
  final Map<String, double> productPrices; // productId -> price
  final Map<String, double>
      productDiscounts; // productId -> discount percentage
  final String? customerId; // Müşteri özel fiyat listesi için
  final String? categoryId; // Kategori özel fiyat listesi için
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const PriceList({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.currency,
    required this.validFrom,
    this.validTo,
    this.isActive = true,
    this.productPrices = const {},
    this.productDiscounts = const {},
    this.customerId,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  PriceList copyWith({
    String? id,
    String? name,
    String? description,
    PriceListType? type,
    String? currency,
    DateTime? validFrom,
    DateTime? validTo,
    bool? isActive,
    Map<String, double>? productPrices,
    Map<String, double>? productDiscounts,
    String? customerId,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PriceList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      isActive: isActive ?? this.isActive,
      productPrices: productPrices ?? this.productPrices,
      productDiscounts: productDiscounts ?? this.productDiscounts,
      customerId: customerId ?? this.customerId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan PriceList oluştur
  factory PriceList.fromJson(Map<String, dynamic> json) {
    return PriceList(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: PriceListType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PriceListType.standard,
      ),
      currency: json['currency'] as String,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: json['validTo'] != null
          ? DateTime.parse(json['validTo'] as String)
          : null,
      isActive: json['isActive'] ?? true,
      productPrices: Map<String, double>.from(json['productPrices'] ?? {}),
      productDiscounts:
          Map<String, double>.from(json['productDiscounts'] ?? {}),
      customerId: json['customerId'] as String?,
      categoryId: json['categoryId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// PriceList'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'currency': currency,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo?.toIso8601String(),
      'isActive': isActive,
      'productPrices': productPrices,
      'productDiscounts': productDiscounts,
      'customerId': customerId,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Belirli bir ürün için fiyat getir
  double? getProductPrice(String productId) {
    return productPrices[productId];
  }

  /// Belirli bir ürün için iskonto getir
  double? getProductDiscount(String productId) {
    return productDiscounts[productId];
  }

  /// Fiyat listesi geçerli mi?
  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (now.isBefore(validFrom)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return true;
  }

  /// Müşteri özel fiyat listesi mi?
  bool get isCustomerSpecific => customerId != null;

  /// Kategori özel fiyat listesi mi?
  bool get isCategorySpecific => categoryId != null;

  @override
  String toString() {
    return 'PriceList(id: $id, name: $name, type: $type, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PriceList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
