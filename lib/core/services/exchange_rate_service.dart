// ========== EXCHANGE RATE SERVICE ==========
// lib/core/services/exchange_rate_service.dart

import 'package:tamgaci/core/utils/logger.dart';

/// Döviz kuru servisi
class ExchangeRateService {
  /// Döviz kurlarını al
  static Future<Map<String, double>> getExchangeRates() async {
    try {
      // Gerçek uygulamada API'den alınacak
      // Şimdilik sabit değerler
      final rates = {
        'USD': 30.50,
        'EUR': 33.20,
        'GBP': 38.80,
        'TRY': 1.0,
      };

      AppLogger.info('Exchange rates fetched successfully');
      return rates;
    } catch (e) {
      AppLogger.error('Failed to fetch exchange rates', e);
      return {
        'USD': 30.50,
        'EUR': 33.20,
        'GBP': 38.80,
        'TRY': 1.0,
      };
    }
  }

  /// Para birimi dönüştür
  static double convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    if (fromCurrency == toCurrency) return amount;

    // Basit dönüştürme oranları
    final rates = {
      'TRY': 1.0,
      'USD': 0.033,
      'EUR': 0.030,
      'GBP': 0.026,
    };

    final fromRate = rates[fromCurrency] ?? 1.0;
    final toRate = rates[toCurrency] ?? 1.0;

    return amount * (toRate / fromRate);
  }

  /// Para birimi formatla
  static String formatCurrencyRate(double rate, String currency) {
    return '${rate.toStringAsFixed(2)} $currency';
  }
}
