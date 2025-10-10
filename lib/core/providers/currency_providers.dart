// ========== CURRENCY PROVIDERS ==========
// lib/core/providers/currency_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/currency.dart';
import '../services/utils/exchange_rate_service.dart';

/// Para birimi koduna göre ülke adını döndürür
String _getCountryByCode(String code) {
  const countryMap = {
    'TRY': 'Türkiye',
    'USD': 'Amerika',
    'EUR': 'Avrupa',
    'GBP': 'İngiltere',
    'RUB': 'Rusya',
    'CNY': 'Çin',
    'AED': 'Dubai',
    'BGN': 'Bulgaristan',
    'XAU': 'Altın',
    'JPY': 'Japonya',
    'CHF': 'İsviçre',
    'CAD': 'Kanada',
    'AUD': 'Avustralya',
    'NZD': 'Yeni Zelanda',
    'SEK': 'İsveç',
    'NOK': 'Norveç',
    'DKK': 'Danimarka',
    'PLN': 'Polonya',
    'CZK': 'Çekya',
    'HUF': 'Macaristan',
    'RON': 'Romanya',
    'HRK': 'Hırvatistan',
    'RSD': 'Sırbistan',
    'MKD': 'Makedonya',
    'ALL': 'Arnavutluk',
    'BAM': 'Bosna',
    'UAH': 'Ukrayna',
    'BYN': 'Belarus',
    'MDL': 'Moldova',
    'GEL': 'Gürcistan',
    'AMD': 'Ermenistan',
    'AZN': 'Azerbaycan',
    'KZT': 'Kazakistan',
    'UZS': 'Özbekistan',
    'KGS': 'Kırgızistan',
    'TJS': 'Tacikistan',
    'TMT': 'Türkmenistan',
    'AFN': 'Afganistan',
    'PKR': 'Pakistan',
    'INR': 'Hindistan',
    'BDT': 'Bangladeş',
    'LKR': 'Sri Lanka',
    'NPR': 'Nepal',
    'BTN': 'Bhutan',
    'MVR': 'Maldivler',
    'IDR': 'Endonezya',
    'MYR': 'Malezya',
    'SGD': 'Singapur',
    'THB': 'Tayland',
    'VND': 'Vietnam',
    'PHP': 'Filipinler',
    'KRW': 'Güney Kore',
    'MNT': 'Moğolistan',
    'KHR': 'Kamboçya',
    'LAK': 'Laos',
    'MMK': 'Myanmar',
    'BND': 'Brunei',
    'HKD': 'Hong Kong',
    'TWD': 'Tayvan',
    'MOP': 'Makao',
    'BRL': 'Brezilya',
    'ARS': 'Arjantin',
    'CLP': 'Şili',
    'COP': 'Kolombiya',
    'PEN': 'Peru',
    'UYU': 'Uruguay',
    'VES': 'Venezuela',
    'BOB': 'Bolivya',
    'PYG': 'Paraguay',
    'GYD': 'Guyana',
    'SRD': 'Surinam',
    'TTD': 'Trinidad',
    'JMD': 'Jamaika',
    'BBD': 'Barbados',
    'BZD': 'Belize',
    'GTQ': 'Guatemala',
    'HNL': 'Honduras',
    'NIO': 'Nikaragua',
    'CRC': 'Kosta Rika',
    'PAB': 'Panama',
    'DOP': 'Dominik',
    'HTG': 'Haiti',
    'CUP': 'Küba',
    'MXN': 'Meksika',
    'ZAR': 'Güney Afrika',
    'EGP': 'Mısır',
    'MAD': 'Fas',
    'TND': 'Tunus',
    'DZD': 'Cezayir',
    'LYD': 'Libya',
    'SDG': 'Sudan',
    'ETB': 'Etiyopya',
    'KES': 'Kenya',
    'TZS': 'Tanzanya',
    'UGX': 'Uganda',
    'RWF': 'Ruanda',
    'BIF': 'Burundi',
    'DJF': 'Cibuti',
    'SOS': 'Somali',
    'ERN': 'Eritre',
    'SLL': 'Sierra Leone',
    'GMD': 'Gambiya',
    'GNF': 'Gine',
    'LRD': 'Liberya',
    'CDF': 'Kongo',
    'AOA': 'Angola',
    'ZMW': 'Zambiya',
    'BWP': 'Botsvana',
    'SZL': 'Eswatini',
    'LSL': 'Lesotho',
    'NAD': 'Namibya',
    'MZN': 'Mozambik',
    'MWK': 'Malavi',
    'ZWL': 'Zimbabve',
  };
  return countryMap[code] ?? code; // Unknown yerine para birimi kodunu döndür
}

/// Kur yenileme notifier'ı
class CurrencyRefreshNotifier
    extends StateNotifier<AsyncValue<List<Currency>>> {
  CurrencyRefreshNotifier() : super(const AsyncValue.loading()) {
    _loadRates();
  }

  /// Kurları yükle
  Future<void> _loadRates() async {
    state = const AsyncValue.loading();
    try {
      final exchangeRates = await ExchangeRateService().getExchangeRates();
      final currencies = exchangeRates
          .map((rate) => Currency(
                code: rate.code,
                name: rate.name,
                symbol: rate.symbol,
                country: _getCountryByCode(rate.code),
                exchangeRate: rate.rate,
                lastUpdated: rate.lastUpdated,
                changeRate: _calculateChangeRate(rate),
                isIncreasing: _isRateIncreasing(rate),
              ))
          .toList();
      state = AsyncValue.data(currencies);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Kur değişim oranını hesapla (mock veri - gerçek uygulamada geçmiş verilerle karşılaştırılmalı)
  double _calculateChangeRate(ExchangeRate rate) {
    // Mock değişim oranları - gerçek uygulamada geçmiş verilerle karşılaştırılmalı
    final mockChanges = {
      'USD': 0.5, // %0.5 artış
      'EUR': -0.3, // %0.3 azalış
      'GBP': 1.2, // %1.2 artış
      'CHF': -0.8, // %0.8 azalış
      'JPY': 0.1, // %0.1 artış
      'CAD': 0.7, // %0.7 artış
      'AUD': -0.4, // %0.4 azalış
      'DKK': 0.2, // %0.2 artış
      'SEK': -0.6, // %0.6 azalış
      'NOK': 0.9, // %0.9 artış
      'SAR': 0.3, // %0.3 artış
      'KWD': -0.1, // %0.1 azalış
      'BGN': 0.4, // %0.4 artış
      'RON': -0.2, // %0.2 azalış
      'RUB': 2.1, // %2.1 artış
      'IRR': 0.8, // %0.8 artış
      'CNY': -0.5, // %0.5 azalış
      'PKR': 1.5, // %1.5 artış
      'QAR': 0.6, // %0.6 artış
      'XAU': -1.2, // %1.2 azalış
    };

    return mockChanges[rate.code] ?? 0.0;
  }

  /// Kur artış/azalış durumunu belirle
  bool _isRateIncreasing(ExchangeRate rate) {
    return _calculateChangeRate(rate) >= 0;
  }

  /// Kurları yenile
  Future<void> refresh() async {
    await _loadRates();
  }
}

final currencyRefreshNotifierProvider =
    StateNotifierProvider<CurrencyRefreshNotifier, AsyncValue<List<Currency>>>(
        (ref) {
  return CurrencyRefreshNotifier();
});

/// Güncel kurlar provider'ı
final exchangeRatesProvider = FutureProvider<List<Currency>>((ref) async {
  final exchangeRates = await ExchangeRateService().getExchangeRates();
  return exchangeRates
      .map((rate) => Currency(
            code: rate.code,
            name: rate.name,
            symbol: rate.symbol,
            country: _getCountryByCode(rate.code),
            exchangeRate: rate.rate,
            lastUpdated: rate.lastUpdated,
            changeRate: _calculateChangeRateStatic(rate),
            isIncreasing: _isRateIncreasingStatic(rate),
          ))
      .toList();
});

/// Kur değişim oranını hesapla (static versiyon)
double _calculateChangeRateStatic(ExchangeRate rate) {
  // Mock değişim oranları - gerçek uygulamada geçmiş verilerle karşılaştırılmalı
  final mockChanges = {
    'USD': 0.5, // %0.5 artış
    'EUR': -0.3, // %0.3 azalış
    'GBP': 1.2, // %1.2 artış
    'CHF': -0.8, // %0.8 azalış
    'JPY': 0.1, // %0.1 artış
    'CAD': 0.7, // %0.7 artış
    'AUD': -0.4, // %0.4 azalış
    'DKK': 0.2, // %0.2 artış
    'SEK': -0.6, // %0.6 azalış
    'NOK': 0.9, // %0.9 artış
    'SAR': 0.3, // %0.3 artış
    'KWD': -0.1, // %0.1 azalış
    'BGN': 0.4, // %0.4 artış
    'RON': -0.2, // %0.2 azalış
    'RUB': 2.1, // %2.1 artış
    'IRR': 0.8, // %0.8 artış
    'CNY': -0.5, // %0.5 azalış
    'PKR': 1.5, // %1.5 artış
    'QAR': 0.6, // %0.6 artış
    'XAU': -1.2, // %1.2 azalış
  };

  return mockChanges[rate.code] ?? 0.0;
}

/// Kur artış/azalış durumunu belirle (static versiyon)
bool _isRateIncreasingStatic(ExchangeRate rate) {
  return _calculateChangeRateStatic(rate) >= 0;
}

/// Varsayılan para birimi provider'ı
final defaultCurrencyProvider = Provider<Currency>((ref) {
  return SupportedCurrencies.defaultCurrency;
});

/// Aktif para birimleri provider'ı
final activeCurrenciesProvider = Provider<List<Currency>>((ref) {
  return SupportedCurrencies.activeCurrencies;
});

/// Seçili para birimi provider'ı (ayarlardan alınacak)
final selectedCurrencyProvider =
    StateNotifierProvider<SelectedCurrencyNotifier, Currency>((ref) {
  return SelectedCurrencyNotifier();
});

/// Para birimi dönüştürme provider'ı
final currencyConverterProvider = Provider<CurrencyConverter>((ref) {
  final rates = ref.watch(exchangeRatesProvider);
  return CurrencyConverter(rates: rates);
});

/// Kur değişim geçmişi provider'ı
final exchangeRateHistoryProvider =
    FutureProvider<Map<String, List<double>>>((ref) async {
  // Son 30 günlük kur geçmişi (mock veri)
  return {
    'USD': List.generate(30, (index) => 0.031 + (index * 0.0001)),
    'EUR': List.generate(30, (index) => 0.029 - (index * 0.00005)),
    'RUB': List.generate(30, (index) => 2.85 + (index * 0.01)),
    'CNY': List.generate(30, (index) => 0.22 + (index * 0.001)),
    'AED': List.generate(30, (index) => 0.114 - (index * 0.0002)),
    'XAU': List.generate(30, (index) => 0.0000012 + (index * 0.00000001)),
  };
});

/// Seçili para birimi notifier'ı
class SelectedCurrencyNotifier extends StateNotifier<Currency> {
  SelectedCurrencyNotifier() : super(SupportedCurrencies.defaultCurrency) {
    _loadSelectedCurrency();
  }

  /// Seçili para birimini yükle
  Future<void> _loadSelectedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyCode = prefs.getString('selected_currency_code') ?? 'TRY';
      final currency = SupportedCurrencies.findByCode(currencyCode);
      if (currency != null) {
        state = currency;
      }
    } catch (e) {
      // Hata durumunda varsayılan para birimini kullan
      state = SupportedCurrencies.defaultCurrency;
    }
  }

  /// Para birimi seç
  Future<void> selectCurrency(Currency currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency_code', currency.code);
      state = currency;
    } catch (e) {
      // Hata durumunda state'i güncelleme
    }
  }

  /// Para birimi koduna göre seç
  Future<void> selectCurrencyByCode(String currencyCode) async {
    final currency = SupportedCurrencies.findByCode(currencyCode);
    if (currency != null) {
      await selectCurrency(currency);
    }
  }
}

/// Para birimi dönüştürücü sınıfı
class CurrencyConverter {
  final AsyncValue<List<Currency>> rates;

  CurrencyConverter({required this.rates});

  /// Para birimi dönüştürme
  double convert({
    required double amount,
    required String fromCurrencyCode,
    required String toCurrencyCode,
  }) {
    final ratesData = rates.value;
    if (ratesData == null) return amount;

    final fromCurrency = ratesData.firstWhere(
      (c) => c.code == fromCurrencyCode,
      orElse: () => SupportedCurrencies.defaultCurrency,
    );

    final toCurrency = ratesData.firstWhere(
      (c) => c.code == toCurrencyCode,
      orElse: () => SupportedCurrencies.defaultCurrency,
    );

    return ExchangeRateService().convertCurrency(
      amount,
      fromCurrency.code,
      toCurrency.code,
    );
  }

  /// Para birimi formatla
  String format({
    required double amount,
    required String currencyCode,
    int decimalPlaces = 2,
  }) {
    final ratesData = rates.value;
    if (ratesData == null) return amount.toStringAsFixed(decimalPlaces);

    final currency = ratesData.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => SupportedCurrencies.defaultCurrency,
    );

    return ExchangeRateService.formatCurrency(
      amount,
      currency.code,
      decimalPlaces,
    );
  }

  /// Kur bilgisini al
  Currency? getCurrency(String code) {
    final ratesData = rates.value;
    if (ratesData == null) return null;

    try {
      return ratesData.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Tüm kurları al
  List<Currency> getAllCurrencies() {
    return rates.value ?? SupportedCurrencies.currencies;
  }
}

/// Kur güncelleme provider'ı
final currencyRefreshProvider =
    FutureProvider.autoDispose.family<List<Currency>, void>((ref, _) async {
  // Kur servisini yenile
  final exchangeRates = await ExchangeRateService().getExchangeRates();
  return exchangeRates
      .map((rate) => Currency(
            code: rate.code,
            name: rate.name,
            symbol: rate.symbol,
            country: _getCountryByCode(rate.code),
            exchangeRate: rate.rate,
            lastUpdated: rate.lastUpdated,
            changeRate: _calculateChangeRateStatic(rate),
            isIncreasing: _isRateIncreasingStatic(rate),
          ))
      .toList();
});

/// Kur değişim oranları provider'ı
final currencyChangeRatesProvider = Provider<Map<String, double>>((ref) {
  final rates = ref.watch(exchangeRatesProvider);

  if (rates.value == null) return {};

  final changeRates = <String, double>{};

  for (final currency in rates.value!) {
    changeRates[currency.code] = currency.changeRate;
  }

  return changeRates;
});

/// En çok değişen kurlar provider'ı
final topChangingCurrenciesProvider = Provider<List<Currency>>((ref) {
  final rates = ref.watch(exchangeRatesProvider);

  if (rates.value == null) return [];

  final currencies = List<Currency>.from(rates.value!);

  // Mutlak değişim oranına göre sırala
  currencies.sort((a, b) => b.changeRate.abs().compareTo(a.changeRate.abs()));

  // İlk 5'i döndür
  return currencies.take(5).toList();
});

/// USD ve EUR kurları provider'ı (drawer için)
final usdEurRatesProvider = Provider<Map<String, Currency>>((ref) {
  final rates = ref.watch(exchangeRatesProvider);

  if (rates.value == null) {
    return {
      'USD': SupportedCurrencies.findByCode('USD')!,
      'EUR': SupportedCurrencies.findByCode('EUR')!,
    };
  }

  final usdCurrency = rates.value!.firstWhere(
    (c) => c.code == 'USD',
    orElse: () => SupportedCurrencies.findByCode('USD')!,
  );

  final eurCurrency = rates.value!.firstWhere(
    (c) => c.code == 'EUR',
    orElse: () => SupportedCurrencies.findByCode('EUR')!,
  );

  return {
    'USD': usdCurrency,
    'EUR': eurCurrency,
  };
});
