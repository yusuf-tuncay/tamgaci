// ========== EXCHANGE RATE SERVICE ==========
// lib/core/services/utils/exchange_rate_service.dart

import 'package:dio/dio.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/core/cache/cache_manager.dart';

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

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  // Hasan Adıgüzel TCMB realtime FX API
  // Docs commonly reference `https://hasanadiguzel.com.tr/api/kurgetir`
  // The response contains a list under keys like `TCMB_AnlikKurBilgileri`.
  static const String _fxEndpoint = 'https://hasanadiguzel.com.tr/api/kurgetir';

  // Simple cache via shared CacheManager
  final CacheManager _cache = CacheManager();
  static const String _cacheKeyLatest = 'fx_rates_latest';
  static const Duration _cacheTtl = Duration(minutes: 30);

  // Keep last fetched in memory for fast convert operations
  List<ExchangeRate>? _lastRates;

  /// Döviz kurlarını getir (TRY bazında 1 birim döviz = X TRY)
  Future<List<ExchangeRate>> getExchangeRates() async {
    // 1) Try cache first
    try {
      final cached = await _cache.get<List<ExchangeRate>>(
        _cacheKeyLatest,
        fromJson: (data) {
          final list =
              (data['rates'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          return list.map(ExchangeRate.fromJson).toList();
        },
      );
      if (cached != null && cached.isNotEmpty) {
        _lastRates = cached;
        AppLogger.debug('FX rates served from cache (${cached.length})');
        return cached;
      }
    } catch (e) {
      AppLogger.warning('FX cache read failed', e);
    }

    // 2) Fetch from API
    try {
      AppLogger.info('Fetching FX rates from Hasan Adıgüzel API');
      final response = await _dio.get(_fxEndpoint);
      final data = response.data;

      final List<dynamic> rows = _extractRows(data);
      final now = DateTime.now();

      final List<ExchangeRate> parsed = [];

      // Always include TRY baseline
      parsed.add(ExchangeRate(
        code: 'TRY',
        name: 'Türk Lirası',
        symbol: '₺',
        rate: 1.0,
        lastUpdated: now,
      ));

      for (final item in rows) {
        final map = Map<String, dynamic>.from(item as Map);
        final code = (map['CurrencyCode'] ?? map['Kod'] ?? '').toString();
        if (code.isEmpty || code == 'XDR') continue; // skip invalid/SDR

        // Prefer ForexSelling / BanknoteSelling; fallback to ForexBuying / BanknoteBuying
        final sellingStr = (map['ForexSelling'] ??
                map['BanknoteSelling'] ??
                map['Satis'] ??
                map['Selling'] ??
                '')
            .toString();
        final buyingStr = (map['ForexBuying'] ??
                map['BanknoteBuying'] ??
                map['Alis'] ??
                map['Buying'] ??
                '')
            .toString();
        double? rate;
        rate = double.tryParse(sellingStr.replaceAll(',', '.')) ??
            double.tryParse(buyingStr.replaceAll(',', '.'));
        if (rate == null || rate <= 0) continue;

        parsed.add(ExchangeRate(
          code: code,
          name: (map['Isim'] ?? map['Unit'] ?? code).toString(),
          symbol: _symbolFor(code),
          rate: rate,
          lastUpdated: now,
        ));
      }

      // Cache & return
      await _cache.set<List<ExchangeRate>>(
        _cacheKeyLatest,
        parsed,
        expiry: _cacheTtl,
        toJson: (list) => {
          'rates': list.map((e) => e.toJson()).toList(),
        },
      );

      _lastRates = parsed;
      AppLogger.info('FX rates fetched (${parsed.length})');
      return parsed;
    } catch (e) {
      AppLogger.error('Error fetching exchange rates from API', e);
      // 3) Fallback to stale cache if available
      try {
        final cached = await _cache.get<List<ExchangeRate>>(
          _cacheKeyLatest,
          fromJson: (data) {
            final list =
                (data['rates'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            return list.map(ExchangeRate.fromJson).toList();
          },
        );
        if (cached != null && cached.isNotEmpty) {
          _lastRates = cached;
          AppLogger.warning('Using stale FX cache due to error');
          return cached;
        }
      } catch (_) {}
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

    final rates = _lastRates;
    if (rates == null || rates.isEmpty) {
      // Without rates, return amount unchanged to avoid wrong numbers
      return amount;
    }

    double rateOf(String code) {
      if (code == 'TRY') return 1.0;
      final r = rates.cast<ExchangeRate?>().firstWhere(
            (e) => e?.code == code,
            orElse: () => null,
          );
      return r?.rate ?? 1.0;
    }

    final fromRateTry = rateOf(fromCurrency);
    final toRateTry = rateOf(toCurrency);
    return (amount * fromRateTry) / toRateTry;
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

  // Map currency code to common symbol
  String _symbolFor(String code) {
    switch (code) {
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
      case 'XAU':
        return 'Au';
      default:
        return code;
    }
  }

  // Extract rows from Hasan Adıgüzel/TCMB response
  List<dynamic> _extractRows(dynamic data) {
    try {
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        if (data['TCMB_AnlikKurBilgileri'] is List) {
          return data['TCMB_AnlikKurBilgileri'] as List;
        }
        if (data['data'] is List) {
          return data['data'] as List;
        }
        if (data['result'] is List) {
          return data['result'] as List;
        }
      }
    } catch (_) {}
    return const [];
  }
}
