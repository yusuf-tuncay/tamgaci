// ========== CURRENCY ENTITY ==========
// lib/core/domain/entities/currency.dart

/// Para birimi entity'si
class Currency {
  /// Para birimi kodu (TRY, USD, EUR, vb.)
  final String code;

  /// Para birimi adı (Türk Lirası, Amerikan Doları, vb.)
  final String name;

  /// Para birimi sembolü (₺, $, €, vb.)
  final String symbol;

  /// Ülke/bölge adı
  final String country;

  /// Varsayılan para birimi mi?
  final bool isDefault;

  /// Aktif mi?
  final bool isActive;

  /// Son güncelleme tarihi
  final DateTime? lastUpdated;

  /// TRY'ye göre kur (1 TRY = ?)
  final double exchangeRate;

  /// Kur değişim oranı (%)
  final double changeRate;

  /// Kur değişim yönü (true: artış, false: azalış)
  final bool isIncreasing;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.country,
    this.isDefault = false,
    this.isActive = true,
    required this.lastUpdated,
    required this.exchangeRate,
    this.changeRate = 0.0,
    this.isIncreasing = true,
  });

  /// Currency kopyalama metodu
  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    String? country,
    bool? isDefault,
    bool? isActive,
    DateTime? lastUpdated,
    double? exchangeRate,
    double? changeRate,
    bool? isIncreasing,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      changeRate: changeRate ?? this.changeRate,
      isIncreasing: isIncreasing ?? this.isIncreasing,
    );
  }

  /// JSON'dan Currency oluşturur
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      country: json['country'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      changeRate: (json['changeRate'] as num?)?.toDouble() ?? 0.0,
      isIncreasing: json['isIncreasing'] as bool? ?? true,
    );
  }

  /// Currency'yi JSON'a dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'country': country,
      'isDefault': isDefault,
      'isActive': isActive,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'exchangeRate': exchangeRate,
      'changeRate': changeRate,
      'isIncreasing': isIncreasing,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() {
    return 'Currency(code: $code, name: $name, symbol: $symbol)';
  }
}

/// Desteklenen para birimleri
class SupportedCurrencies {
  static const List<Currency> currencies = [
    Currency(
      code: 'TRY',
      name: 'Türk Lirası',
      symbol: '₺',
      country: 'Türkiye',
      isDefault: true,
      lastUpdated: null,
      exchangeRate: 1.0,
    ),
    Currency(
      code: 'USD',
      name: 'Amerikan Doları',
      symbol: '\$',
      country: 'Amerika',
      lastUpdated: null,
      exchangeRate: 0.0,
    ),
    Currency(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      country: 'Avrupa',
      lastUpdated: null,
      exchangeRate: 0.0,
    ),
    Currency(
      code: 'RUB',
      name: 'Rus Rublesi',
      symbol: '₽',
      country: 'Rusya',
      lastUpdated: null,
      exchangeRate: 0.0,
    ),
    Currency(
      code: 'CNY',
      name: 'Çin Yuanı',
      symbol: '¥',
      country: 'Çin',
      lastUpdated: null,
      exchangeRate: 0.0,
    ),
    Currency(
      code: 'AED',
      name: 'Birleşik Arap Emirlikleri Dirhemi',
      symbol: 'د.إ',
      country: 'Dubai',
      lastUpdated: null,
      exchangeRate: 0.0,
    ),
    Currency(
      code: 'BGN',
      name: 'Bulgar Levası',
      symbol: 'лв',
      country: 'Bulgaristan',
      lastUpdated: null,
      exchangeRate: 0.0,
    ),
    Currency(
      code: 'XAU',
      name: 'Altın (Gram)',
      symbol: 'Au',
      country: 'Altın',
      lastUpdated: null,
      exchangeRate: 0.0,
    ),
  ];

  /// Varsayılan para birimini döndürür
  static Currency get defaultCurrency =>
      currencies.firstWhere((c) => c.isDefault);

  /// Aktif para birimlerini döndürür
  static List<Currency> get activeCurrencies =>
      currencies.where((c) => c.isActive).toList();

  /// Para birimi koduna göre bulur
  static Currency? findByCode(String code) {
    try {
      return currencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }
}
