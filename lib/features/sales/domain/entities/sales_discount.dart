// ========== SALES DISCOUNT ENTITY ==========
// lib/features/sales/domain/entities/sales_discount.dart

/// İndirim türü
enum DiscountType {
  percentage('Yüzde'),
  fixed('Sabit Tutar'),
  quantity('Miktar Bazlı'),
  customer('Müşteri Bazlı'),
  product('Ürün Bazlı'),
  category('Kategori Bazlı'),
  seasonal('Sezonluk'),
  promotional('Promosyon'),
  loyalty('Sadakat'),
  volume('Hacim Bazlı');

  const DiscountType(this.displayName);
  final String displayName;
}

/// İndirim uygulama yeri
enum DiscountApplication {
  line('Satır Bazlı'),
  document('Belge Bazlı'),
  total('Toplam Bazlı'),
  shipping('Kargo Bazlı'),
  tax('Vergi Bazlı');

  const DiscountApplication(this.displayName);
  final String displayName;
}

/// İndirim durumu
enum DiscountStatus {
  active('Aktif'),
  inactive('Pasif'),
  expired('Süresi Dolmuş'),
  used('Kullanılmış'),
  cancelled('İptal Edilmiş');

  const DiscountStatus(this.displayName);
  final String displayName;
}

/// Satış indirimi entity'si
class SalesDiscount {
  final String id;
  final String name;
  final String? description;
  final DiscountType type;
  final DiscountApplication application;
  final DiscountStatus status;
  final double value; // İndirim değeri (yüzde veya tutar)
  final String currency;
  final double? minimumAmount; // Minimum tutar
  final double? maximumAmount; // Maksimum tutar
  final int? minimumQuantity; // Minimum miktar
  final int? maximumQuantity; // Maksimum miktar
  final DateTime? validFrom; // Geçerlilik başlangıç tarihi
  final DateTime? validTo; // Geçerlilik bitiş tarihi
  final List<String> applicableProducts; // Uygulanabilir ürünler
  final List<String> applicableCategories; // Uygulanabilir kategoriler
  final List<String> applicableCustomers; // Uygulanabilir müşteriler
  final int? usageLimit; // Kullanım limiti
  final int currentUsage; // Mevcut kullanım
  final String? couponCode; // Kupon kodu
  final bool isStackable; // Diğer indirimlerle birleştirilebilir mi?
  final Map<String, dynamic> conditions; // Koşullar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const SalesDiscount({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.application,
    required this.status,
    required this.value,
    this.currency = 'TRY',
    this.minimumAmount,
    this.maximumAmount,
    this.minimumQuantity,
    this.maximumQuantity,
    this.validFrom,
    this.validTo,
    this.applicableProducts = const [],
    this.applicableCategories = const [],
    this.applicableCustomers = const [],
    this.usageLimit,
    this.currentUsage = 0,
    this.couponCode,
    this.isStackable = false,
    this.conditions = const {},
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  SalesDiscount copyWith({
    String? id,
    String? name,
    String? description,
    DiscountType? type,
    DiscountApplication? application,
    DiscountStatus? status,
    double? value,
    String? currency,
    double? minimumAmount,
    double? maximumAmount,
    int? minimumQuantity,
    int? maximumQuantity,
    DateTime? validFrom,
    DateTime? validTo,
    List<String>? applicableProducts,
    List<String>? applicableCategories,
    List<String>? applicableCustomers,
    int? usageLimit,
    int? currentUsage,
    String? couponCode,
    bool? isStackable,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return SalesDiscount(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      application: application ?? this.application,
      status: status ?? this.status,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      minimumAmount: minimumAmount ?? this.minimumAmount,
      maximumAmount: maximumAmount ?? this.maximumAmount,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      maximumQuantity: maximumQuantity ?? this.maximumQuantity,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      applicableCustomers: applicableCustomers ?? this.applicableCustomers,
      usageLimit: usageLimit ?? this.usageLimit,
      currentUsage: currentUsage ?? this.currentUsage,
      couponCode: couponCode ?? this.couponCode,
      isStackable: isStackable ?? this.isStackable,
      conditions: conditions ?? this.conditions,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan SalesDiscount oluştur
  factory SalesDiscount.fromJson(Map<String, dynamic> json) {
    return SalesDiscount(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: DiscountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DiscountType.percentage,
      ),
      application: DiscountApplication.values.firstWhere(
        (e) => e.name == json['application'],
        orElse: () => DiscountApplication.line,
      ),
      status: DiscountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DiscountStatus.active,
      ),
      value: (json['value'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      minimumAmount: (json['minimumAmount'] as num?)?.toDouble(),
      maximumAmount: (json['maximumAmount'] as num?)?.toDouble(),
      minimumQuantity: json['minimumQuantity'] as int?,
      maximumQuantity: json['maximumQuantity'] as int?,
      validFrom: json['validFrom'] != null
          ? DateTime.parse(json['validFrom'] as String)
          : null,
      validTo: json['validTo'] != null
          ? DateTime.parse(json['validTo'] as String)
          : null,
      applicableProducts: List<String>.from(json['applicableProducts'] ?? []),
      applicableCategories:
          List<String>.from(json['applicableCategories'] ?? []),
      applicableCustomers: List<String>.from(json['applicableCustomers'] ?? []),
      usageLimit: json['usageLimit'] as int?,
      currentUsage: json['currentUsage'] ?? 0,
      couponCode: json['couponCode'] as String?,
      isStackable: json['isStackable'] ?? false,
      conditions: Map<String, dynamic>.from(json['conditions'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// SalesDiscount'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'application': application.name,
      'status': status.name,
      'value': value,
      'currency': currency,
      'minimumAmount': minimumAmount,
      'maximumAmount': maximumAmount,
      'minimumQuantity': minimumQuantity,
      'maximumQuantity': maximumQuantity,
      'validFrom': validFrom?.toIso8601String(),
      'validTo': validTo?.toIso8601String(),
      'applicableProducts': applicableProducts,
      'applicableCategories': applicableCategories,
      'applicableCustomers': applicableCustomers,
      'usageLimit': usageLimit,
      'currentUsage': currentUsage,
      'couponCode': couponCode,
      'isStackable': isStackable,
      'conditions': conditions,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// İndirim geçerli mi?
  bool get isValid {
    final now = DateTime.now();
    if (status != DiscountStatus.active) return false;
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    if (usageLimit != null && currentUsage >= usageLimit!) return false;
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

  /// Belirli bir müşteri için uygulanabilir mı?
  bool isApplicableToCustomer(String? customerId) {
    if (!isValid) return false;

    // Müşteri özel kuralı var mı?
    if (customerId != null && applicableCustomers.contains(customerId)) {
      return true;
    }

    // Genel kural mı?
    return applicableCustomers.isEmpty;
  }

  /// Belirli bir tutar için uygulanabilir mi?
  bool isApplicableToAmount(double amount) {
    if (!isValid) return false;
    if (minimumAmount != null && amount < minimumAmount!) return false;
    if (maximumAmount != null && amount > maximumAmount!) return false;
    return true;
  }

  /// Belirli bir miktar için uygulanabilir mi?
  bool isApplicableToQuantity(int quantity) {
    if (!isValid) return false;
    if (minimumQuantity != null && quantity < minimumQuantity!) return false;
    if (maximumQuantity != null && quantity > maximumQuantity!) return false;
    return true;
  }

  /// İndirim tutarını hesapla
  double calculateDiscount(double baseAmount, {int quantity = 1}) {
    if (!isValid) return 0;
    if (!isApplicableToAmount(baseAmount)) return 0;
    if (!isApplicableToQuantity(quantity)) return 0;

    double discountAmount = 0;

    switch (type) {
      case DiscountType.percentage:
        discountAmount = baseAmount * (value / 100);
        break;
      case DiscountType.fixed:
        discountAmount = value;
        break;
      case DiscountType.quantity:
        // Miktar bazlı indirim (koşullardan alınabilir)
        final quantityThreshold = conditions['quantityThreshold'] as int? ?? 1;
        final quantityDiscount = conditions['quantityDiscount'] as double? ?? 0;
        if (quantity >= quantityThreshold) {
          discountAmount = baseAmount * (quantityDiscount / 100);
        }
        break;
      case DiscountType.volume:
        // Hacim bazlı indirim
        final volumeThreshold = conditions['volumeThreshold'] as double? ?? 0;
        final volumeDiscount = conditions['volumeDiscount'] as double? ?? 0;
        if (baseAmount >= volumeThreshold) {
          discountAmount = baseAmount * (volumeDiscount / 100);
        }
        break;
      default:
        discountAmount = 0;
    }

    // Maksimum indirim kontrolü
    if (maximumAmount != null && discountAmount > maximumAmount!) {
      discountAmount = maximumAmount!;
    }

    return discountAmount;
  }

  /// Kupon kodu var mı?
  bool get hasCouponCode => couponCode != null && couponCode!.isNotEmpty;

  /// Kullanım limiti var mı?
  bool get hasUsageLimit => usageLimit != null;

  /// Kullanım limiti dolmuş mu?
  bool get isUsageLimitReached {
    if (usageLimit == null) return false;
    return currentUsage >= usageLimit!;
  }

  @override
  String toString() {
    return 'SalesDiscount(id: $id, name: $name, type: $type, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesDiscount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
