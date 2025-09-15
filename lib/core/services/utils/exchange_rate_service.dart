// ========== EXCHANGE RATE SERVICE ==========
// lib/core/services/utils/exchange_rate_service.dart

import 'package:dio/dio.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Döviz kuru modeli
class ExchangeRate {
  final String code;
  final String name;
  final String symbol;
  final double rate;
  final DateTime lastUpdated;

  const ExchangeRate({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rate,
    required this.lastUpdated,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      rate: (json['rate'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(
          json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'rate': rate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// Döviz kuru servisi
class ExchangeRateService {
  static final ExchangeRateService _instance = ExchangeRateService._internal();
  factory ExchangeRateService() => _instance;
  ExchangeRateService._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  /// Döviz kurlarını getir
  Future<List<ExchangeRate>> getExchangeRates() async {
    try {
      AppLogger.info('Fetching exchange rates');

      // Mock data - gerçek API entegrasyonu için
      final mockRates = [
        ExchangeRate(
          code: 'TRY',
          name: 'Türk Lirası',
          symbol: '₺',
          rate: 1.0,
          lastUpdated: DateTime.now(),
        ),
        ExchangeRate(
          code: 'USD',
          name: 'Amerikan Doları',
          symbol: '\$',
          rate: 34.50,
          lastUpdated: DateTime.now(),
        ),
        ExchangeRate(
          code: 'EUR',
          name: 'Euro',
          symbol: '€',
          rate: 37.20,
          lastUpdated: DateTime.now(),
        ),
        ExchangeRate(
          code: 'GBP',
          name: 'İngiliz Sterlini',
          symbol: '£',
          rate: 43.80,
          lastUpdated: DateTime.now(),
        ),
      ];

      AppLogger.info('Exchange rates fetched successfully');
      return mockRates;
    } catch (e) {
      AppLogger.error('Error fetching exchange rates', e);
      rethrow;
    }
  }

  /// Belirli bir para biriminin kurunu getir
  Future<ExchangeRate?> getExchangeRate(String currencyCode) async {
    try {
      final rates = await getExchangeRates();
      return rates.firstWhere(
        (rate) => rate.code == currencyCode,
        orElse: () => rates.first, // TRY as default
      );
    } catch (e) {
      AppLogger.error('Error fetching exchange rate for $currencyCode', e);
      return null;
    }
  }

  /// Para birimi dönüşümü
  double convertCurrency(
      double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    // Mock conversion - gerçek API entegrasyonu için
    final conversionRates = {
      'TRY': 1.0,
      'USD': 34.50,
      'EUR': 37.20,
      'GBP': 43.80,
    };

    final fromRate = conversionRates[fromCurrency] ?? 1.0;
    final toRate = conversionRates[toCurrency] ?? 1.0;

    return (amount * fromRate) / toRate;
  }

  /// Para birimi formatla
  static String formatCurrency(
      double amount, String currency, int decimalPlaces) {
    final symbols = {
      'TRY': '₺',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
    };

    final symbol = symbols[currency] ?? currency;
    final formattedAmount = amount.toStringAsFixed(decimalPlaces);

    return '$symbol$formattedAmount';
  }

  /// Kur formatla
  static String formatCurrencyRate(double rate, String currency) {
    return '1 $currency = ${rate.toStringAsFixed(4)} TRY';
  }
}
