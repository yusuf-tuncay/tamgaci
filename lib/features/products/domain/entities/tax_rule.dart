// ========== TAX RULE ENTITY ==========
// lib/features/products/domain/entities/tax_rule.dart

/// Vergi türü
enum TaxType {
  vat('KDV'),
  excise('ÖTV'),
  special('Özel Tüketim'),
  stamp('Damga'),
  withholding('Stopaj'),
  municipality('Belediye'),
  other('Diğer');

  const TaxType(this.displayName);
  final String displayName;
}

/// Vergi hesaplama yöntemi
enum TaxCalculationMethod {
  percentage('Yüzde'),
  fixed('Sabit Tutar'),
  tiered('Kademeli');

  const TaxCalculationMethod(this.displayName);
  final String displayName;
}

/// Vergi kuralı entity'si
class TaxRule {
  final String id;
  final String name;
  final String? description;
  final TaxType type;
  final double rate; // Yüzde oranı veya sabit tutar
  final TaxCalculationMethod calculationMethod;
  final String currency;
  final bool isInclusive; // Vergi dahil mi?
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validTo;
  final List<String> applicableCategories; // Uygulanabilir kategoriler
  final List<String> applicableProducts; // Uygulanabilir ürünler
  final List<String> applicableCustomers; // Uygulanabilir müşteriler
  final Map<String, dynamic> additionalSettings; // Ek ayarlar
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const TaxRule({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.rate,
    required this.calculationMethod,
    required this.currency,
    this.isInclusive = false,
    this.isActive = true,
    this.validFrom,
    this.validTo,
    this.applicableCategories = const [],
    this.applicableProducts = const [],
    this.applicableCustomers = const [],
    this.additionalSettings = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  TaxRule copyWith({
    String? id,
    String? name,
    String? description,
    TaxType? type,
    double? rate,
    TaxCalculationMethod? calculationMethod,
    String? currency,
    bool? isInclusive,
    bool? isActive,
    DateTime? validFrom,
    DateTime? validTo,
    List<String>? applicableCategories,
    List<String>? applicableProducts,
    List<String>? applicableCustomers,
    Map<String, dynamic>? additionalSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return TaxRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      rate: rate ?? this.rate,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      currency: currency ?? this.currency,
      isInclusive: isInclusive ?? this.isInclusive,
      isActive: isActive ?? this.isActive,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      applicableCustomers: applicableCustomers ?? this.applicableCustomers,
      additionalSettings: additionalSettings ?? this.additionalSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan TaxRule oluştur
  factory TaxRule.fromJson(Map<String, dynamic> json) {
    return TaxRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: TaxType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaxType.vat,
      ),
      rate: (json['rate'] as num).toDouble(),
      calculationMethod: TaxCalculationMethod.values.firstWhere(
        (e) => e.name == json['calculationMethod'],
        orElse: () => TaxCalculationMethod.percentage,
      ),
      currency: json['currency'] as String,
      isInclusive: json['isInclusive'] ?? false,
      isActive: json['isActive'] ?? true,
      validFrom: json['validFrom'] != null
          ? DateTime.parse(json['validFrom'] as String)
          : null,
      validTo: json['validTo'] != null
          ? DateTime.parse(json['validTo'] as String)
          : null,
      applicableCategories:
          List<String>.from(json['applicableCategories'] ?? []),
      applicableProducts: List<String>.from(json['applicableProducts'] ?? []),
      applicableCustomers: List<String>.from(json['applicableCustomers'] ?? []),
      additionalSettings:
          Map<String, dynamic>.from(json['additionalSettings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// TaxRule'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'rate': rate,
      'calculationMethod': calculationMethod.name,
      'currency': currency,
      'isInclusive': isInclusive,
      'isActive': isActive,
      'validFrom': validFrom?.toIso8601String(),
      'validTo': validTo?.toIso8601String(),
      'applicableCategories': applicableCategories,
      'applicableProducts': applicableProducts,
      'applicableCustomers': applicableCustomers,
      'additionalSettings': additionalSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Vergi kuralı geçerli mi?
  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return true;
  }

  /// Belirli bir ürün için uygulanabilir mi?
  bool isApplicableToProduct(String productId, String? categoryId) {
    if (!isValid) return false;

    // Ürün özel kuralı var mı?
    if (applicableProducts.contains(productId)) return true;

    // Kategori kuralı var mı?
    if (categoryId != null && applicableCategories.contains(categoryId)) {
      return true;
    }

    // Genel kural mı?
    return applicableProducts.isEmpty && applicableCategories.isEmpty;
  }

  /// Belirli bir müşteri için uygulanabilir mi?
  bool isApplicableToCustomer(String? customerId) {
    if (!isValid) return false;

    // Müşteri özel kuralı var mı?
    if (customerId != null && applicableCustomers.contains(customerId)) {
      return true;
    }

    // Genel kural mı?
    return applicableCustomers.isEmpty;
  }

  /// Vergi tutarını hesapla
  double calculateTax(double baseAmount) {
    switch (calculationMethod) {
      case TaxCalculationMethod.percentage:
        return baseAmount * (rate / 100);
      case TaxCalculationMethod.fixed:
        return rate;
      case TaxCalculationMethod.tiered:
        // Kademeli vergi hesaplama (ek ayarlardan alınabilir)
        return _calculateTieredTax(baseAmount);
    }
  }

  /// Kademeli vergi hesaplama
  double _calculateTieredTax(double baseAmount) {
    // Basit kademeli hesaplama - gerçek uygulamada daha karmaşık olabilir
    final tiers =
        additionalSettings['tiers'] as List<Map<String, dynamic>>? ?? [];

    double totalTax = 0;
    double remainingAmount = baseAmount;

    for (final tier in tiers) {
      final tierMin = (tier['min'] as num).toDouble();
      final tierMax = (tier['max'] as num?)?.toDouble() ?? double.infinity;
      final tierRate = (tier['rate'] as num).toDouble();

      if (remainingAmount <= 0) break;

      final tierAmount = remainingAmount.clamp(0, tierMax - tierMin);
      totalTax += tierAmount * (tierRate / 100);
      remainingAmount -= tierAmount;
    }

    return totalTax;
  }

  @override
  String toString() {
    return 'TaxRule(id: $id, name: $name, type: $type, rate: $rate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxRule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
