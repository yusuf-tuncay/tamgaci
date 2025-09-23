// ========== EXCHANGE RATE SERVICE ==========
// lib/core/services/utils/exchange_rate_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
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
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 12),
    // EVDS sometimes blocks CORS directly; we proxy via a simple passthrough if provided
  ));

  // TCMB EVDS configuration
  static const String _series =
      'TP.DK.USD.A.YTL-TP.DK.USD.S.YTL-TP.DK.EUR.A.YTL-TP.DK.EUR.S.YTL-TP.DK.GBP.A.YTL-TP.DK.GBP.S.YTL-TP.DK.CHF.A.YTL-TP.DK.CHF.S.YTL-TP.DK.JPY.A.YTL-TP.DK.JPY.S.YTL-TP.DK.CAD.A.YTL-TP.DK.CAD.S.YTL-TP.DK.AUD.A.YTL-TP.DK.AUD.S.YTL-TP.DK.DKK.A.YTL-TP.DK.DKK.S.YTL-TP.DK.SEK.A.YTL-TP.DK.SEK.S.YTL-TP.DK.NOK.A.YTL-TP.DK.NOK.S.YTL-TP.DK.SAR.A.YTL-TP.DK.SAR.S.YTL-TP.DK.KWD.A.YTL-TP.DK.KWD.S.YTL-TP.DK.BGN.A.YTL-TP.DK.BGN.S.YTL-TP.DK.RON.A.YTL-TP.DK.RON.S.YTL-TP.DK.RUB.A.YTL-TP.DK.RUB.S.YTL-TP.DK.IRR.A.YTL-TP.DK.IRR.S.YTL-TP.DK.CNY.A.YTL-TP.DK.CNY.S.YTL-TP.DK.PKR.A.YTL-TP.DK.PKR.S.YTL-TP.DK.QAR.A.YTL-TP.DK.QAR.S.YTL-TP.DK.XDR.A.YTL-TP.DK.XDR.S.YTL-TP.DK.XAU.A.YTL-TP.DK.XAU.S.YTL';
  static const String _apiKey =
      String.fromEnvironment('EVDS_API_KEY', defaultValue: '');
  static const String _evdsBase = 'https://evds2.tcmb.gov.tr/service/evds/';
  // Temporary fallback API (Hasan Adıgüzel FX) — public free endpoint
  // Docs: https://hasanadiguzel.com.tr/api/
  static const String _hasanFxUrl = 'https://hasanadiguzel.com.tr/api/kurgetir';

  // Optional environment proxies to bypass CORS on web builds
  // Usage: flutter run -d chrome --dart-define=EVDS_PROXY_URL=https://your-proxy.example.com/?url={url}
  static const String _evdsProxyTemplate =
      String.fromEnvironment('EVDS_PROXY_URL');
  // Alternative: Firebase Functions HTTPS proxy
  // Usage: flutter run -d chrome --dart-define=FIREBASE_FX_PROXY_URL=https://<region>-<project>.cloudfunctions.net/evdsProxy?url={url}
  static const String _firebaseFxProxyTemplate =
      String.fromEnvironment('FIREBASE_FX_PROXY_URL');

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

    // 2) Fetch from API (EVDS primary)
    try {
      AppLogger.info('Fetching FX rates from TCMB EVDS API');

      // Build base parameters (without key for security; proxy will inject)
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 7));
      final fmt = DateFormat('dd-MM-yyyy');
      final startDate = fmt.format(start);
      final endDate = fmt.format(now);
      final baseParams = {
        'series': _series,
        'startDate': startDate,
        'endDate': endDate,
        'type': 'json',
        'frequency': '1',
        'formulas': '0',
        'aggregationTypes': 'last',
        'decimalSeperator': '.',
      };

      // Decide call path: proxy secure, proxy passthrough, or direct
      String template = _evdsProxyTemplate.isNotEmpty
          ? _evdsProxyTemplate
          : (_firebaseFxProxyTemplate.isNotEmpty
              ? _firebaseFxProxyTemplate
              : '');

      String endpointToCall;
      Map<String, dynamic>? queryParams;
      if (template.isNotEmpty) {
        final hasPlaceholder = template.contains('{url}') ||
            template.contains('%s') ||
            template.endsWith('/');
        if (hasPlaceholder) {
          // Passthrough mode: build EVDS URL without key and encode into template
          final qs =
              'series=${baseParams['series']}&startDate=$startDate&endDate=$endDate&type=json&frequency=1&formulas=0&aggregationTypes=last&decimalSeperator=.';
          final evdsUrlNoKey = '$_evdsBase$qs';
          endpointToCall = _computeEndpointForWeb(evdsUrlNoKey);
          queryParams = null;
        } else {
          // Secure mode: call proxy base with query parameters (no key on client)
          endpointToCall = template;
          queryParams = baseParams;
        }
      } else {
        // Direct EVDS (mobile/desktop). Key must be provided via dart-define; otherwise EVDS may reject.
        final qs =
            'series=${baseParams['series']}&startDate=$startDate&endDate=$endDate&type=json&frequency=1&formulas=0&aggregationTypes=last&decimalSeperator=.';
        final evdsUrl =
            _apiKey.isNotEmpty ? '$_evdsBase$qs&key=$_apiKey' : '$_evdsBase$qs';
        endpointToCall = evdsUrl;
        queryParams = null;
      }

      final response = await _dio.get(
        endpointToCall,
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.json),
      );
      final data = response.data;

      final List<dynamic> rows = _extractEvdsRows(data);
      final now2 = DateTime.now();

      final List<ExchangeRate> parsed = [];

      // Always include TRY baseline
      parsed.add(ExchangeRate(
        code: 'TRY',
        name: 'Türk Lirası',
        symbol: '₺',
        rate: 1.0,
        lastUpdated: now2,
      ));

      if (rows.isNotEmpty) {
        // Latest row is last
        final latest = Map<String, dynamic>.from(rows.last as Map);
        final mapping = <String, String?>{
          'USD': latest['TP_DK_USD_S_YTL']?.toString() ??
              latest['TP_DK_USD_A_YTL']?.toString(),
          'EUR': latest['TP_DK_EUR_S_YTL']?.toString() ??
              latest['TP_DK_EUR_A_YTL']?.toString(),
          'GBP': latest['TP_DK_GBP_S_YTL']?.toString() ??
              latest['TP_DK_GBP_A_YTL']?.toString(),
          'CHF': latest['TP_DK_CHF_S_YTL']?.toString() ??
              latest['TP_DK_CHF_A_YTL']?.toString(),
          'JPY': latest['TP_DK_JPY_S_YTL']?.toString() ??
              latest['TP_DK_JPY_A_YTL']?.toString(),
          'CAD': latest['TP_DK_CAD_S_YTL']?.toString() ??
              latest['TP_DK_CAD_A_YTL']?.toString(),
          'AUD': latest['TP_DK_AUD_S_YTL']?.toString() ??
              latest['TP_DK_AUD_A_YTL']?.toString(),
          'DKK': latest['TP_DK_DKK_S_YTL']?.toString() ??
              latest['TP_DK_DKK_A_YTL']?.toString(),
          'SEK': latest['TP_DK_SEK_S_YTL']?.toString() ??
              latest['TP_DK_SEK_A_YTL']?.toString(),
          'NOK': latest['TP_DK_NOK_S_YTL']?.toString() ??
              latest['TP_DK_NOK_A_YTL']?.toString(),
          'SAR': latest['TP_DK_SAR_S_YTL']?.toString() ??
              latest['TP_DK_SAR_A_YTL']?.toString(),
          'KWD': latest['TP_DK_KWD_S_YTL']?.toString() ??
              latest['TP_DK_KWD_A_YTL']?.toString(),
          'BGN': latest['TP_DK_BGN_S_YTL']?.toString() ??
              latest['TP_DK_BGN_A_YTL']?.toString(),
          'RON': latest['TP_DK_RON_S_YTL']?.toString() ??
              latest['TP_DK_RON_A_YTL']?.toString(),
          'RUB': latest['TP_DK_RUB_S_YTL']?.toString() ??
              latest['TP_DK_RUB_A_YTL']?.toString(),
          'IRR': latest['TP_DK_IRR_S_YTL']?.toString() ??
              latest['TP_DK_IRR_A_YTL']?.toString(),
          'CNY': latest['TP_DK_CNY_S_YTL']?.toString() ??
              latest['TP_DK_CNY_A_YTL']?.toString(),
          'PKR': latest['TP_DK_PKR_S_YTL']?.toString() ??
              latest['TP_DK_PKR_A_YTL']?.toString(),
          'QAR': latest['TP_DK_QAR_S_YTL']?.toString() ??
              latest['TP_DK_QAR_A_YTL']?.toString(),
          'XAU': latest['TP_DK_XAU_S_YTL']?.toString() ??
              latest['TP_DK_XAU_A_YTL']?.toString(),
        };

        mapping.forEach((code, str) {
          final rate = double.tryParse((str ?? '').replaceAll(',', '.'));
          if (rate == null || rate <= 0) return;
          parsed.add(ExchangeRate(
            code: code,
            name: code,
            symbol: _symbolFor(code),
            rate: rate,
            lastUpdated: now2,
          ));
        });
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
      // Network/XHR errors on web are expected; fallback will be tried next
      AppLogger.warning('EVDS fetch failed, trying Hasan API fallback', e);
      // 2b) Try Hasan Adıgüzel API as temporary fallback
      try {
        AppLogger.info('Trying Hasan Adıgüzel FX API fallback');
        final resp = await _dio.get(_hasanFxUrl,
            options: Options(responseType: ResponseType.json));
        final body = resp.data;
        final now2 = DateTime.now();
        final List<ExchangeRate> parsed = [
          ExchangeRate(
            code: 'TRY',
            name: 'Türk Lirası',
            symbol: '₺',
            rate: 1.0,
            lastUpdated: now2,
          )
        ];
        try {
          final List items = (body['TCMB_AnlikKurBilgileri'] ?? []) as List;
          for (final it in items) {
            final m = it as Map<String, dynamic>;
            final code = (m['Isim'] as String? ?? '').toUpperCase();
            final forexSelling = double.tryParse((m['ForexSelling'] ?? '')
                    .toString()
                    .replaceAll(',', '.')) ??
                0.0;
            final unit = double.tryParse(
                    (m['Unit'] ?? '1').toString().replaceAll(',', '.')) ??
                1.0;
            if (forexSelling > 0 && unit > 0) {
              final normalized = forexSelling / unit; // 1 birim fiyat
              final cc = _mapHasanSymbolToIso(code);
              if (cc != null && cc != 'TRY') {
                parsed.add(ExchangeRate(
                  code: cc,
                  name: cc,
                  symbol: _symbolFor(cc),
                  rate: normalized,
                  lastUpdated: now2,
                ));
              }
            }
          }
        } catch (_) {}

        if (parsed.length > 1) {
          await _cache.set<List<ExchangeRate>>(
            _cacheKeyLatest,
            parsed,
            expiry: _cacheTtl,
            toJson: (list) => {
              'rates': list.map((e) => e.toJson()).toList(),
            },
          );
          _lastRates = parsed;
          AppLogger.info('FX rates fetched from Hasan API (${parsed.length})');
          return parsed;
        }
      } catch (e2) {
        AppLogger.warning('Hasan FX API fallback failed', e2);
      }
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
      // If network layer failed (e.g., CORS/XHR), return TRY-only baseline to avoid full crash
      return _lastRates ??
          [
            ExchangeRate(
              code: 'TRY',
              name: 'Türk Lirası',
              symbol: '₺',
              rate: 1.0,
              lastUpdated: DateTime.now(),
            ),
          ];
    }
  }

  // If running on web and a proxy template is provided, transform the EVDS URL
  String _computeEndpointForWeb(String original) {
    if (!kIsWeb) return original;
    String template = _evdsProxyTemplate;
    if (template.isEmpty) {
      template = _firebaseFxProxyTemplate;
      if (template.isEmpty) return original;
    }
    final encoded = Uri.encodeComponent(original);
    if (template.contains('{url}')) {
      return template.replaceAll('{url}', encoded);
    }
    if (template.contains('%s')) return template.replaceAll('%s', encoded);
    if (template.endsWith('/')) return '$template$encoded';
    if (template.contains('?')) return '$template&url=$encoded';
    return '$template?url=$encoded';
  }

  String buildEvdsUrl() {
    // Use last 7 days window to ensure at least one row is present
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    final fmt = DateFormat('dd-MM-yyyy');
    final startDate = fmt.format(start);
    final endDate = fmt.format(now);
    final qs =
        'series=$_series&startDate=$startDate&endDate=$endDate&type=json&key=$_apiKey';
    return 'https://evds2.tcmb.gov.tr/service/evds/$qs';
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

  /// Map Hasan API currency name to ISO code
  String? _mapHasanSymbolToIso(String name) {
    switch (name) {
      case 'ABD DOLARI':
      case 'USD':
        return 'USD';
      case 'EURO':
      case 'EUR':
        return 'EUR';
      case 'İNGİLİZ STERLİNİ':
      case 'GBP':
        return 'GBP';
      case 'İSVİÇRE FRANGI':
      case 'CHF':
        return 'CHF';
      case 'JAPON YENİ':
      case 'JPY':
        return 'JPY';
      case 'KANADA DOLARI':
      case 'CAD':
        return 'CAD';
      case 'AVUSTRALYA DOLARI':
      case 'AUD':
        return 'AUD';
      case 'DANİMARKA KRONU':
      case 'DKK':
        return 'DKK';
      case 'İSVEÇ KRONU':
      case 'SEK':
        return 'SEK';
      case 'NORVEÇ KRONU':
      case 'NOK':
        return 'NOK';
      case 'SUUDİ ARABİSTAN RİYALİ':
      case 'SAR':
        return 'SAR';
      default:
        return null;
    }
  }

  // Extract rows from EVDS JSON response
  List<dynamic> _extractEvdsRows(dynamic data) {
    try {
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        if (data['items'] is List) {
          return data['items'] as List; // some EVDS variants
        }
        if (data['data'] is List) return data['data'] as List; // standard EVDS
      }
    } catch (_) {}
    return const [];
  }
}
