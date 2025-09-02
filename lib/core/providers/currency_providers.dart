// ========== CURRENCY PROVIDERS ==========
// lib/core/providers/currency_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/currency.dart';
import '../services/exchange_rate_service.dart';

/// Güncel kurlar provider'ı
final exchangeRatesProvider = FutureProvider<List<Currency>>((ref) async {
  return await ExchangeRateService.getExchangeRates();
});

/// Varsayılan para birimi provider'ı
final defaultCurrencyProvider = Provider<Currency>((ref) {
  return SupportedCurrencies.defaultCurrency;
});

/// Aktif para birimleri provider'ı
final activeCurrenciesProvider = Provider<List<Currency>>((ref) {
  return SupportedCurrencies.activeCurrencies;
});

/// Seçili para birimi provider'ı (ayarlardan alınacak)
final selectedCurrencyProvider = StateNotifierProvider<SelectedCurrencyNotifier, Currency>((ref) {
  return SelectedCurrencyNotifier();
});

/// Para birimi dönüştürme provider'ı
final currencyConverterProvider = Provider<CurrencyConverter>((ref) {
  final rates = ref.watch(exchangeRatesProvider);
  return CurrencyConverter(rates: rates);
});

/// Kur değişim geçmişi provider'ı
final exchangeRateHistoryProvider = FutureProvider<Map<String, List<double>>>((ref) async {
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

    return ExchangeRateService.convertCurrency(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
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
      amount: amount,
      currency: currency,
      decimalPlaces: decimalPlaces,
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
final currencyRefreshProvider = FutureProvider.autoDispose.family<List<Currency>, void>((ref, _) async {
  // Kur servisini yenile
  return await ExchangeRateService.getExchangeRates();
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
