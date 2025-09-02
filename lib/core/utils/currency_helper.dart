// ========== CURRENCY HELPER ==========
// lib/core/utils/currency_helper.dart

import '../domain/entities/currency.dart';

/// Para birimi yardımcı sınıfı
class CurrencyHelper {
  /// Para birimi sembolünü döndürür
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
      case 'RUB':
        return '₽';
      case 'CNY':
        return '¥';
      case 'AED':
        return 'د.إ';
      case 'BGN':
        return 'лв';
      case 'CHF':
        return 'CHF';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'JPY':
        return '¥';
      case 'XAU':
        return 'Au';
      default:
        return currencyCode;
    }
  }

  /// Para birimi adını döndürür
  static String getCurrencyName(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'TRY':
        return 'Türk Lirası';
      case 'USD':
        return 'Amerikan Doları';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'İngiliz Sterlini';
      case 'RUB':
        return 'Rus Rublesi';
      case 'CNY':
        return 'Çin Yuanı';
      case 'AED':
        return 'Birleşik Arap Emirlikleri Dirhemi';
      case 'BGN':
        return 'Bulgar Levası';
      case 'CHF':
        return 'İsviçre Frangı';
      case 'CAD':
        return 'Kanada Doları';
      case 'AUD':
        return 'Avustralya Doları';
      case 'JPY':
        return 'Japon Yeni';
      case 'XAU':
        return 'Altın (Gram)';
      default:
        return currencyCode;
    }
  }

  /// Tutarı formatlar
  static String formatAmount(double amount, String currencyCode, {int decimalPlaces = 2}) {
    final symbol = getCurrencySymbol(currencyCode);
    final formattedAmount = amount.toStringAsFixed(decimalPlaces);
    
    switch (currencyCode.toUpperCase()) {
      case 'TRY':
        return '₺$formattedAmount';
      case 'USD':
        return '\$$formattedAmount';
      case 'EUR':
        return '€$formattedAmount';
      case 'GBP':
        return '£$formattedAmount';
      case 'RUB':
        return '₽$formattedAmount';
      case 'CNY':
        return '¥$formattedAmount';
      case 'AED':
        return 'د.إ$formattedAmount';
      case 'BGN':
        return 'лв$formattedAmount';
      case 'XAU':
        return 'Au $formattedAmount g';
      default:
        return '$symbol$formattedAmount';
    }
  }

  /// Kur bilgisini formatlar (1 USD = 40.98 TRY)
  static String formatExchangeRate(String fromCurrency, String toCurrency, double rate, {int decimalPlaces = 2}) {
    final fromSymbol = getCurrencySymbol(fromCurrency);
    final toSymbol = getCurrencySymbol(toCurrency);
    final formattedRate = rate.toStringAsFixed(decimalPlaces);
    
    return '1 $fromSymbol = $formattedRate $toSymbol';
  }

  /// Para birimi dönüştürme (seçili para birimine göre)
  static double convertCurrency({
    required double amount,
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required List<Currency> exchangeRates,
  }) {
    if (fromCurrencyCode == toCurrencyCode) {
      return amount;
    }

    // TRY'yi bul (base currency) - şu anda kullanılmıyor ama gelecekte gerekebilir
    // final tryCurrency = exchangeRates.firstWhere(
    //   (currency) => currency.code == 'TRY',
    //   orElse: () => Currency(
    //     code: 'TRY',
    //     name: 'Türk Lirası',
    //     symbol: '₺',
    //     country: 'Türkiye',
    //     isDefault: true,
    //     lastUpdated: DateTime.now(),
    //     exchangeRate: 1.0,
    //     changeRate: 0.0,
    //     isIncreasing: true,
    //   ),
    // );

    // Kaynak para birimini bul
    final fromCurrency = exchangeRates.firstWhere(
      (currency) => currency.code == fromCurrencyCode,
      orElse: () => Currency(
        code: fromCurrencyCode,
        name: getCurrencyName(fromCurrencyCode),
        symbol: getCurrencySymbol(fromCurrencyCode),
        country: '',
        lastUpdated: DateTime.now(),
        exchangeRate: 1.0,
        changeRate: 0.0,
        isIncreasing: true,
      ),
    );

    // Hedef para birimini bul
    final toCurrency = exchangeRates.firstWhere(
      (currency) => currency.code == toCurrencyCode,
      orElse: () => Currency(
        code: toCurrencyCode,
        name: getCurrencyName(toCurrencyCode),
        symbol: getCurrencySymbol(toCurrencyCode),
        country: '',
        lastUpdated: DateTime.now(),
        exchangeRate: 1.0,
        changeRate: 0.0,
        isIncreasing: true,
      ),
    );

    // TRY'ye çevir
    final amountInTRY = amount * fromCurrency.exchangeRate;

    // Hedef para birimine çevir
    return amountInTRY / toCurrency.exchangeRate;
  }

  /// Seçili para birimine göre tutar gösterimi
  static String formatAmountWithDefaultCurrency({
    required double amount,
    required String currencyCode,
    required String defaultCurrencyCode,
    required List<Currency> exchangeRates,
    int decimalPlaces = 2,
  }) {
    if (currencyCode == defaultCurrencyCode) {
      return formatAmount(amount, currencyCode, decimalPlaces: decimalPlaces);
    }

    // Varsayılan para birimine çevir
    final convertedAmount = convertCurrency(
      amount: amount,
      fromCurrencyCode: currencyCode,
      toCurrencyCode: defaultCurrencyCode,
      exchangeRates: exchangeRates,
    );

    final originalFormatted = formatAmount(amount, currencyCode, decimalPlaces: decimalPlaces);
    final convertedFormatted = formatAmount(convertedAmount, defaultCurrencyCode, decimalPlaces: decimalPlaces);

    return '$originalFormatted ($convertedFormatted)';
  }

  /// Para birimi seçeneklerini döndürür
  static List<Map<String, String>> getCurrencyOptions() {
    return [
      {'code': 'TRY', 'name': 'Türk Lirası (₺)'},
      {'code': 'USD', 'name': 'Amerikan Doları (\$)'},
      {'code': 'EUR', 'name': 'Euro (€)'},
      {'code': 'GBP', 'name': 'İngiliz Sterlini (£)'},
      {'code': 'RUB', 'name': 'Rus Rublesi (₽)'},
      {'code': 'CNY', 'name': 'Çin Yuanı (¥)'},
      {'code': 'AED', 'name': 'Birleşik Arap Emirlikleri Dirhemi (د.إ)'},
      {'code': 'BGN', 'name': 'Bulgar Levası (лв)'},
      {'code': 'CHF', 'name': 'İsviçre Frangı (CHF)'},
      {'code': 'CAD', 'name': 'Kanada Doları (C\$)'},
      {'code': 'AUD', 'name': 'Avustralya Doları (A\$)'},
      {'code': 'JPY', 'name': 'Japon Yeni (¥)'},
    ];
  }

  /// Para birimi geçerli mi kontrol eder
  static bool isValidCurrencyCode(String currencyCode) {
    final validCodes = ['TRY', 'USD', 'EUR', 'GBP', 'RUB', 'CNY', 'AED', 'BGN', 'CHF', 'CAD', 'AUD', 'JPY'];
    return validCodes.contains(currencyCode.toUpperCase());
  }
}
