// ========== EXCHANGE RATE SERVICE ==========
// lib/core/services/exchange_rate_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../domain/entities/currency.dart';

/// Kur servisi
class ExchangeRateService {
  // TCMB Resmi API - Hasan Adıgüzel
  static const String _tcmbApiUrl = 'https://hasanadiguzel.com.tr/api/kurgetir';

  /// Güncel kurları getirir
  static Future<List<Currency>> getExchangeRates() async {
    try {
      // TCMB API'den kurları al (en güvenilir - resmi kaynak)
      final response = await http.get(Uri.parse(_tcmbApiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('TCMB API başarılı - Resmi kurlar alındı');
        return _parseTCMBRates(data);
      } else {
        debugPrint('TCMB API başarısız: ${response.statusCode}');
        throw Exception("TCMB API'den veri alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('TCMB API hatası: $e');
      throw Exception('Kur verileri alınamadı: $e');
    }
  }

  /// TCMB API verilerini parse eder
  static List<Currency> _parseTCMBRates(Map<String, dynamic> data) {
    final now = DateTime.now();
    final currencies = <Currency>[];

    // TRY her zaman 1.0
    currencies.add(Currency(
      code: 'TRY',
      name: 'Türk Lirası',
      symbol: '₺',
      country: 'Türkiye',
      isDefault: true,
      lastUpdated: now,
      exchangeRate: 1.0,
      changeRate: 0.0,
      isIncreasing: true,
    ));

    final tcmbData = data['TCMB_AnlikKurBilgileri'] as List<dynamic>? ?? [];

    for (final currencyData in tcmbData) {
      try {
        final currencyMap = currencyData as Map<String, dynamic>;
        final currencyName = currencyMap['Isim'] as String? ?? '';

        // Güvenli sayı dönüşümü
        final forexBuyingStr = currencyMap['ForexBuying']?.toString() ?? '';
        final forexSellingStr = currencyMap['ForexSelling']?.toString() ?? '';

        final forexBuying = double.tryParse(forexBuyingStr) ?? 0.0;
        final forexSelling = double.tryParse(forexSellingStr) ?? 0.0;

        // Ortalama kur (alış + satış) / 2
        final averageRate = forexBuying > 0 && forexSelling > 0
            ? (forexBuying + forexSelling) / 2
            : (forexBuying > 0 ? forexBuying : forexSelling);

        if (averageRate > 0) {
          final currency = _mapTCMBCurrency(currencyName, averageRate, now);
          if (currency != null) {
            currencies.add(currency);
            debugPrint('TCMB Kur eklendi: $currencyName = $averageRate TRY');
          }
        }
      } catch (e) {
        debugPrint('TCMB parse hatası ($currencyData): $e');
        continue;
      }
    }

    debugPrint("TCMB'den ${currencies.length} kur eklendi");

    // Debug: Kurları yazdır
    for (final currency in currencies) {
      debugPrint('${currency.code}: ${currency.exchangeRate} TRY');
    }

    return currencies;
  }

  /// TCMB para birimi adını uygulama formatına çevirir
  static Currency? _mapTCMBCurrency(
      String tcmbName, double rate, DateTime timestamp) {
    switch (tcmbName.toUpperCase()) {
      case 'ABD DOLARI':
        return Currency(
          code: 'USD',
          name: 'Amerikan Doları',
          symbol: '\$',
          country: 'Amerika',
          lastUpdated: timestamp,
          exchangeRate:
              rate, // 1 USD = X TRY (TCMB'den gelen değer doğrudan kullanılır)
          changeRate: 0.8,
          isIncreasing: true,
        );
      case 'EURO':
        return Currency(
          code: 'EUR',
          name: 'Euro',
          symbol: '€',
          country: 'Avrupa',
          lastUpdated: timestamp,
          exchangeRate:
              rate, // 1 EUR = X TRY (TCMB'den gelen değer doğrudan kullanılır)
          changeRate: -0.2,
          isIncreasing: false,
        );
      case 'İNGİLİZ STERLİNİ':
        return Currency(
          code: 'GBP',
          name: 'İngiliz Sterlini',
          symbol: '£',
          country: 'İngiltere',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 GBP = X TRY (doğrudan kullan)
          changeRate: 0.5,
          isIncreasing: true,
        );
      case 'RUS RUBLESİ':
        return Currency(
          code: 'RUB',
          name: 'Rus Rublesi',
          symbol: '₽',
          country: 'Rusya',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 RUB = X TRY (doğrudan kullan)
          changeRate: 1.5,
          isIncreasing: true,
        );
      case 'ÇİN YUANI':
        return Currency(
          code: 'CNY',
          name: 'Çin Yuanı',
          symbol: '¥',
          country: 'Çin',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 CNY = X TRY (doğrudan kullan)
          changeRate: 0.6,
          isIncreasing: true,
        );
      case 'BİRLEŞİK ARAP EMİRLİKLERİ DİRHEMİ':
        return Currency(
          code: 'AED',
          name: 'Birleşik Arap Emirlikleri Dirhemi',
          symbol: 'د.إ',
          country: 'Dubai',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 AED = X TRY (doğrudan kullan)
          changeRate: -0.1,
          isIncreasing: false,
        );
      case 'BULGAR LEVASI':
        return Currency(
          code: 'BGN',
          name: 'Bulgar Levası',
          symbol: 'лв',
          country: 'Bulgaristan',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 BGN = X TRY (doğrudan kullan)
          changeRate: 0.4,
          isIncreasing: true,
        );
      case 'İSVİÇRE FRANGI':
        return Currency(
          code: 'CHF',
          name: 'İsviçre Frangı',
          symbol: 'CHF',
          country: 'İsviçre',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 CHF = X TRY (doğrudan kullan)
          changeRate: 0.3,
          isIncreasing: true,
        );
      case 'KANADA DOLARI':
        return Currency(
          code: 'CAD',
          name: 'Kanada Doları',
          symbol: 'C\$',
          country: 'Kanada',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 CAD = X TRY (doğrudan kullan)
          changeRate: 0.7,
          isIncreasing: true,
        );
      case 'AVUSTRALYA DOLARI':
        return Currency(
          code: 'AUD',
          name: 'Avustralya Doları',
          symbol: 'A\$',
          country: 'Avustralya',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 AUD = X TRY (doğrudan kullan)
          changeRate: 0.9,
          isIncreasing: true,
        );
      case 'JAPON YENİ':
        return Currency(
          code: 'JPY',
          name: 'Japon Yeni',
          symbol: '¥',
          country: 'Japonya',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 JPY = X TRY
          changeRate: 0.2,
          isIncreasing: true,
        );
      case 'NORVEÇ KRONU':
        return Currency(
          code: 'NOK',
          name: 'Norveç Kronu',
          symbol: 'kr',
          country: 'Norveç',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 NOK = X TRY
          changeRate: 0.1,
          isIncreasing: true,
        );
      case 'İSVEÇ KRONU':
        return Currency(
          code: 'SEK',
          name: 'İsveç Kronu',
          symbol: 'kr',
          country: 'İsveç',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 SEK = X TRY
          changeRate: 0.2,
          isIncreasing: true,
        );
      case 'DANİMARKA KRONU':
        return Currency(
          code: 'DKK',
          name: 'Danimarka Kronu',
          symbol: 'kr',
          country: 'Danimarka',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 DKK = X TRY
          changeRate: 0.1,
          isIncreasing: true,
        );
      case 'POLONYA ZLOTİSİ':
        return Currency(
          code: 'PLN',
          name: 'Polonya Zlotisi',
          symbol: 'zł',
          country: 'Polonya',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 PLN = X TRY
          changeRate: 0.3,
          isIncreasing: true,
        );
      case 'MACAR FORİNTİ':
        return Currency(
          code: 'HUF',
          name: 'Macar Forinti',
          symbol: 'Ft',
          country: 'Macaristan',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 HUF = X TRY
          changeRate: 0.4,
          isIncreasing: true,
        );
      case 'ÇEK KORUNASI':
        return Currency(
          code: 'CZK',
          name: 'Çek Korunası',
          symbol: 'Kč',
          country: 'Çekya',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 CZK = X TRY
          changeRate: 0.2,
          isIncreasing: true,
        );
      case 'GÜNEY KORE WONU':
        return Currency(
          code: 'KRW',
          name: 'Güney Kore Wonu',
          symbol: '₩',
          country: 'Güney Kore',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 KRW = X TRY
          changeRate: 0.1,
          isIncreasing: true,
        );
      case 'HİNDİSTAN RUPİSİ':
        return Currency(
          code: 'INR',
          name: 'Hindistan Rupisi',
          symbol: '₹',
          country: 'Hindistan',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 INR = X TRY
          changeRate: 0.3,
          isIncreasing: true,
        );
      case 'BREZİLYA REALİ':
        return Currency(
          code: 'BRL',
          name: 'Brezilya Realı',
          symbol: 'R\$',
          country: 'Brezilya',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 BRL = X TRY
          changeRate: 0.5,
          isIncreasing: true,
        );
      case 'MEKSİKA PESOSU':
        return Currency(
          code: 'MXN',
          name: 'Meksika Pesosu',
          symbol: '\$',
          country: 'Meksika',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 MXN = X TRY
          changeRate: 0.2,
          isIncreasing: true,
        );
      case 'GÜNEY AFRİKA RANDI':
        return Currency(
          code: 'ZAR',
          name: 'Güney Afrika Randı',
          symbol: 'R',
          country: 'Güney Afrika',
          lastUpdated: timestamp,
          exchangeRate: rate, // 1 ZAR = X TRY
          changeRate: 0.4,
          isIncreasing: true,
        );
      default:
        debugPrint("TCMB'de bulunmayan para birimi: $tcmbName");
        return null;
    }
  }

  /// Para birimi dönüştürme (seçili para birimine göre)
  static double convertCurrency({
    required double amount,
    required Currency fromCurrency,
    required Currency toCurrency,
  }) {
    if (fromCurrency.code == toCurrency.code) {
      return amount;
    }

    // TRY'ye çevir (base currency)
    final amountInTRY = amount * fromCurrency.exchangeRate;

    // Hedef para birimine çevir
    return amountInTRY / toCurrency.exchangeRate;
  }

  /// Seçili para birimine göre kur gösterimi
  static String formatCurrencyRate({
    required Currency currency,
    required Currency selectedCurrency,
    int decimalPlaces = 2,
  }) {
    if (currency.code == selectedCurrency.code) {
      return '1 ${currency.code}';
    }

    // Seçili para birimine göre kur hesapla
    final rate = currency.exchangeRate / selectedCurrency.exchangeRate;
    final formattedRate = rate.toStringAsFixed(decimalPlaces);

    return '1 ${currency.code} = $formattedRate ${selectedCurrency.code}';
  }

  /// Para birimi formatla
  static String formatCurrency({
    required double amount,
    required Currency currency,
    int decimalPlaces = 2,
  }) {
    final symbol = currency.symbol;
    final formattedAmount = amount.toStringAsFixed(decimalPlaces);

    // Para birimi sembolüne göre formatla
    switch (currency.code) {
      case 'TRY':
        return '₺$formattedAmount';
      case 'USD':
        return '\$$formattedAmount';
      case 'EUR':
        return '€$formattedAmount';
      case 'RUB':
        return '₽$formattedAmount';
      case 'CNY':
        return '¥$formattedAmount';
      case 'AED':
        return 'د.إ$formattedAmount';
      case 'BGN':
        return 'лв$formattedAmount';
      default:
        return '$symbol$formattedAmount';
    }
  }

  /// Kur değişim yüzdesini hesapla
  static double calculateChangeRate({
    required double currentRate,
    required double previousRate,
  }) {
    if (previousRate == 0) return 0.0;
    return ((currentRate - previousRate) / previousRate) * 100;
  }
}
