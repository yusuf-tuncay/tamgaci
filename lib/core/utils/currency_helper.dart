// ========== CURRENCY HELPER ==========
// lib/core/utils/currency_helper.dart

import 'package:intl/intl.dart';

/// Para birimi yardımcı sınıfı
class CurrencyHelper {
  /// Para birimini formatla
  static String formatCurrency(double amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: getCurrencySymbol(currencyCode),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Para birimi sembolünü al
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'TRY':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'CHF':
        return 'CHF';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'DKK':
        return 'kr';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'SAR':
        return '﷼';
      case 'KWD':
        return 'KD';
      case 'BGN':
        return 'лв';
      case 'RON':
        return 'lei';
      case 'RUB':
        return '₽';
      case 'IRR':
        return '﷼';
      case 'CNY':
        return '¥';
      case 'PKR':
        return '₨';
      case 'QAR':
        return '﷼';
      case 'XDR':
        return 'XDR';
      case 'XAU':
        return 'Au';
      case 'AED':
        return 'د.إ';
      default:
        return currencyCode;
    }
  }

  /// Para birimini kuruştan liraya çevir
  static double kurusToLira(int kurus) {
    return kurus / 100.0;
  }

  /// Para birimini liradan kuruşa çevir
  static int liraToKurus(double lira) {
    return (lira * 100).round();
  }

  /// Para birimini formatla (kuruş cinsinden)
  static String formatCurrencyFromKurus(int kurus, String currencyCode) {
    final lira = kurusToLira(kurus);
    return formatCurrency(lira, currencyCode);
  }

  /// Para birimini formatla (amount parametresi ile)
  static String formatAmount(double amount, String currencyCode) {
    return formatCurrency(amount, currencyCode);
  }

  /// Para birimini formatla (lira cinsinden)
  static String formatCurrencyFromLira(double lira, String currencyCode) {
    return formatCurrency(lira, currencyCode);
  }

  /// Para birimi seçeneklerini al
  static List<String> getCurrencyOptions() {
    return [
      'TRY',
      'USD',
      'EUR',
      'GBP',
      'CHF',
      'JPY',
      'CAD',
      'AUD',
      'DKK',
      'SEK',
      'NOK',
      'SAR',
      'KWD',
      'BGN',
      'RON',
      'RUB',
      'IRR',
      'CNY',
      'PKR',
      'QAR',
      'XDR',
      'XAU',
      'AED'
    ];
  }

  /// Para birimi dönüştür (basit implementasyon)
  static double convertCurrency(
      double amount, String fromCurrency, String toCurrency) {
    // Basit dönüştürme - gerçek uygulamada API kullanılmalı
    if (fromCurrency == toCurrency) return amount;

    // Örnek dönüştürme oranları
    final rates = {
      'TRY': 1.0,
      'USD': 0.03,
      'EUR': 0.028,
      'GBP': 0.024,
    };

    final fromRate = rates[fromCurrency] ?? 1.0;
    final toRate = rates[toCurrency] ?? 1.0;

    return amount * (toRate / fromRate);
  }

  /// Para birimini parse et
  static double parseCurrency(String currencyString) {
    // Türkçe format: 1.234,56 ₺
    final cleanString = currencyString
        .replaceAll(
            RegExp(r'[^\d,.-]'), '') // Sadece rakam, virgül, nokta, tire
        .replaceAll('.', '') // Binlik ayırıcıları kaldır
        .replaceAll(',', '.'); // Virgülü nokta yap

    return double.tryParse(cleanString) ?? 0.0;
  }

  /// Para birimini kısa formatla (örn: 1.2K, 1.5M)
  static String formatCurrencyShort(double amount, String currencyCode) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ${getCurrencySymbol(currencyCode)}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ${getCurrencySymbol(currencyCode)}';
    } else {
      return formatCurrency(amount, currencyCode);
    }
  }

  /// Para birimini yüzde formatla
  static String formatPercentage(double percentage) {
    final formatter = NumberFormat.percentPattern('tr_TR');
    return formatter.format(percentage / 100);
  }

  /// Para birimini sayı formatla
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return formatter.format(number);
  }

  /// Para birimini sayı formatla (ondalık olmadan)
  static String formatNumberWithoutDecimals(double number) {
    final formatter = NumberFormat('#,##0', 'tr_TR');
    return formatter.format(number);
  }
}
