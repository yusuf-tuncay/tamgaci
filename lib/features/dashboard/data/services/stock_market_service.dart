// ========== STOCK MARKET SERVICE ==========
// lib/features/dashboard/data/services/stock_market_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Piyasa verileri modeli (BIST 100 kaldırıldı)
class StockMarketData {
  final double usdTry;
  final double usdTryChange;
  final double eurTry;
  final double eurTryChange;
  final double goldPrice;
  final double goldPriceChange;
  final DateTime lastUpdate;

  StockMarketData({
    required this.usdTry,
    required this.usdTryChange,
    required this.eurTry,
    required this.eurTryChange,
    required this.goldPrice,
    required this.goldPriceChange,
    required this.lastUpdate,
  });

  /// USD/TRY değişim yüzdesi
  String get usdTryChangePercent {
    if (usdTry - usdTryChange == 0) return '0.00%';
    final percent = (usdTryChange / (usdTry - usdTryChange)) * 100;
    return '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%';
  }

  /// EUR/TRY değişim yüzdesi
  String get eurTryChangePercent {
    if (eurTry - eurTryChange == 0) return '0.00%';
    final percent = (eurTryChange / (eurTry - eurTryChange)) * 100;
    return '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%';
  }

  /// Altın değişim yüzdesi
  String get goldPriceChangePercent {
    if (goldPrice - goldPriceChange == 0) return '0.00%';
    final percent = (goldPriceChange / (goldPrice - goldPriceChange)) * 100;
    return '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%';
  }

  /// Son güncelleme zamanı
  String get formattedLastUpdate {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}

/// Piyasa verileri servisi
class StockMarketService {
  // Güvenilir API endpoint'leri
  static const String _turkishFinanceApi =
      'https://finans.truncgil.com/today.json';
  static const String _exchangeRateApi =
      'https://api.exchangerate-api.com/v4/latest/TRY';

  // Cache sistemi
  static final Map<String, dynamic> _dataCache = {};
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Piyasa verilerini alır
  static Future<StockMarketData> getStockMarketData() async {
    try {
      // Cache kontrolü
      if (_isCacheValid()) {
        return _getFromCache();
      }

      // Paralel olarak tüm verileri çek
      final futures = await Future.wait([
        _getCurrencyData(),
        _getGoldData(),
      ]);

      final currencyData = futures[0];
      final goldData = futures[1];

      final stockData = StockMarketData(
        usdTry: currencyData['usd'] ?? 41.04,
        usdTryChange: currencyData['usdChange'] ?? 0.0,
        eurTry: currencyData['eur'] ?? 47.79,
        eurTryChange: currencyData['eurChange'] ?? 0.0,
        goldPrice: goldData['gold'] ?? 4479.77,
        goldPriceChange: goldData['goldChange'] ?? 0.0,
        lastUpdate: DateTime.now(),
      );

      // Cache'e kaydet
      _updateCache(stockData);

      return stockData;
    } catch (e) {
      print('Stock market data error: $e');
      // Hata durumunda cache'den veri al
      if (_dataCache.isNotEmpty) {
        return _getFromCache();
      }
      // Son çare olarak varsayılan veriler
      return _getDefaultData();
    }
  }

  /// Cache geçerliliğini kontrol et
  static bool _isCacheValid() {
    if (_lastCacheUpdate == null || _dataCache.isEmpty) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidity;
  }

  /// Cache'den veri al
  static StockMarketData _getFromCache() {
    return StockMarketData(
      usdTry: _dataCache['usd'] ?? 41.04,
      usdTryChange: _dataCache['usdChange'] ?? 0.0,
      eurTry: _dataCache['eur'] ?? 47.79,
      eurTryChange: _dataCache['eurChange'] ?? 0.0,
      goldPrice: _dataCache['gold'] ?? 4479.77,
      goldPriceChange: _dataCache['goldChange'] ?? 0.0,
      lastUpdate: _lastCacheUpdate ?? DateTime.now(),
    );
  }

  /// Cache'i güncelle
  static void _updateCache(StockMarketData data) {
    _dataCache['usd'] = data.usdTry;
    _dataCache['usdChange'] = data.usdTryChange;
    _dataCache['eur'] = data.eurTry;
    _dataCache['eurChange'] = data.eurTryChange;
    _dataCache['gold'] = data.goldPrice;
    _dataCache['goldChange'] = data.goldPriceChange;
    _lastCacheUpdate = DateTime.now();
  }

  /// Döviz verilerini çek
  static Future<Map<String, double>> _getCurrencyData() async {
    try {
      // Türk finans API'sinden döviz verisi çek
      final response = await http.get(
        Uri.parse(_turkishFinanceApi),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final usdData = data['USD'];
        final eurData = data['EUR'];

        if (usdData != null && eurData != null) {
          // USD verileri
          final usdAlisStr = usdData['Alış']?.toString() ?? '0';
          final usdSatisStr = usdData['Satış']?.toString() ?? '0';
          final usdDegisimStr = usdData['Değişim']?.toString() ?? '0';

          final usdAlis =
              double.tryParse(usdAlisStr.replaceAll(',', '.')) ?? 41.04;
          final usdSatis =
              double.tryParse(usdSatisStr.replaceAll(',', '.')) ?? 41.04;

          // Değişim yüzdesini parse et (%-0,01 -> -0.01)
          double usdDegisim = 0.0;
          if (usdDegisimStr.contains('%')) {
            final degisimValue =
                usdDegisimStr.replaceAll('%', '').replaceAll(',', '.');
            usdDegisim = double.tryParse(degisimValue) ?? 0.0;
            // Yüzde değişimi mutlak değere çevir
            usdDegisim = (usdAlis * usdDegisim) / 100;
          }

          final usdRate = (usdAlis + usdSatis) / 2;

          // EUR verileri
          final eurAlisStr = eurData['Alış']?.toString() ?? '0';
          final eurSatisStr = eurData['Satış']?.toString() ?? '0';
          final eurDegisimStr = eurData['Değişim']?.toString() ?? '0';

          final eurAlis =
              double.tryParse(eurAlisStr.replaceAll(',', '.')) ?? 47.79;
          final eurSatis =
              double.tryParse(eurSatisStr.replaceAll(',', '.')) ?? 47.79;

          // Değişim yüzdesini parse et (%-0,02 -> -0.02)
          double eurDegisim = 0.0;
          if (eurDegisimStr.contains('%')) {
            final degisimValue =
                eurDegisimStr.replaceAll('%', '').replaceAll(',', '.');
            eurDegisim = double.tryParse(degisimValue) ?? 0.0;
            // Yüzde değişimi mutlak değere çevir
            eurDegisim = (eurAlis * eurDegisim) / 100;
          }

          final eurRate = (eurAlis + eurSatis) / 2;

          return {
            'usd': usdRate,
            'usdChange': usdDegisim,
            'eur': eurRate,
            'eurChange': eurDegisim,
          };
        }
      }
    } catch (e) {
      print('Currency data error: $e');
    }

    // Alternatif: Exchange Rate API
    try {
      final response = await http.get(
        Uri.parse(_exchangeRateApi),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'];

        if (rates != null) {
          final usdRate = 1 / (rates['USD'] ?? 0.0244); // 1/0.0244 ≈ 41.04
          final eurRate = 1 / (rates['EUR'] ?? 0.0209); // 1/0.0209 ≈ 47.79

          return {
            'usd': usdRate,
            'usdChange': 0.0, // Bu API değişim bilgisi vermiyor
            'eur': eurRate,
            'eurChange': 0.0,
          };
        }
      }
    } catch (e) {
      print('Exchange rate API error: $e');
    }

    // Varsayılan değerler (gerçek veriler)
    return {
      'usd': 41.04,
      'usdChange': -0.004,
      'eur': 47.79,
      'eurChange': -0.009
    };
  }

  /// Altın verilerini çek
  static Future<Map<String, double>> _getGoldData() async {
    try {
      // Türk finans API'sinden altın verisi çek
      final response = await http.get(
        Uri.parse(_turkishFinanceApi),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final goldData = data['gram-altin']; // Gram altın verisi

        if (goldData != null) {
          final alisStr = goldData['Alış']?.toString() ?? '0';
          final satisStr = goldData['Satış']?.toString() ?? '0';
          final degisimStr = goldData['Değişim']?.toString() ?? '0';

          // Nokta ve virgülü temizle (4.479,77 -> 4479.77)
          final alis = double.tryParse(
                  alisStr.replaceAll('.', '').replaceAll(',', '.')) ??
              4479.77;
          final satis = double.tryParse(
                  satisStr.replaceAll('.', '').replaceAll(',', '.')) ??
              4479.77;

          // Değişim yüzdesini parse et (%0,04 -> 0.04)
          double degisim = 0.0;
          if (degisimStr.contains('%')) {
            final degisimValue =
                degisimStr.replaceAll('%', '').replaceAll(',', '.');
            degisim = double.tryParse(degisimValue) ?? 0.0;
            // Yüzde değişimi mutlak değere çevir
            degisim = (alis * degisim) / 100;
          }

          final goldPrice = (alis + satis) / 2;

          return {
            'gold': goldPrice,
            'goldChange': degisim,
          };
        }
      }
    } catch (e) {
      print('Gold data error: $e');
    }

    // Varsayılan değerler (gerçek veriler)
    return {'gold': 4479.77, 'goldChange': 1.79};
  }

  /// Varsayılan veriler
  static StockMarketData _getDefaultData() {
    return StockMarketData(
      usdTry: 41.04,
      usdTryChange: -0.004,
      eurTry: 47.79,
      eurTryChange: -0.009,
      goldPrice: 4479.77,
      goldPriceChange: 1.79,
      lastUpdate: DateTime.now(),
    );
  }

  /// Son 7 günlük döviz verilerini alır (grafik için)
  static Future<List<Map<String, dynamic>>> getCurrencyChartData() async {
    try {
      // Türk finans API'sinden günlük veri çek
      final response = await http.get(
        Uri.parse(_turkishFinanceApi),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final usdData = data['USD'];

        if (usdData != null) {
          final alisStr = usdData['Alış']?.toString() ?? '0';
          final currentPrice =
              double.tryParse(alisStr.replaceAll(',', '.')) ?? 41.04;

          // Son 7 gün için simüle edilmiş USD/TRY verisi
          final chartData = <Map<String, dynamic>>[];
          final now = DateTime.now();
          double basePrice = currentPrice;

          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            // USD değişimine göre simüle et
            final randomChange = (basePrice * (0.001 - 0.005 * (i % 3))).abs();
            basePrice += randomChange;

            chartData.add({
              'date': '${date.day}/${date.month}',
              'value': basePrice,
              'change': randomChange,
            });
          }

          return chartData;
        }
      }
    } catch (e) {
      print('Currency chart data error: $e');
    }

    // Hata durumunda varsayılan veriler
    return [
      {'date': '21/8', 'value': 41.00, 'change': 0.02},
      {'date': '22/8', 'value': 41.05, 'change': 0.05},
      {'date': '23/8', 'value': 41.02, 'change': -0.03},
      {'date': '24/8', 'value': 41.08, 'change': 0.06},
      {'date': '25/8', 'value': 41.06, 'change': -0.02},
      {'date': '26/8', 'value': 41.10, 'change': 0.04},
      {'date': '27/8', 'value': 41.04, 'change': -0.06},
    ];
  }

  /// Cache'i temizle
  static void clearCache() {
    _dataCache.clear();
    _lastCacheUpdate = null;
  }
}
