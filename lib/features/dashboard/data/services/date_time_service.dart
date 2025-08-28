// ========== DATE TIME SERVICE ==========
// lib/features/dashboard/data/services/date_time_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// İnternetten güncel tarih ve saat bilgisini alan servis
class DateTimeService {
  // Birden fazla API endpoint'i
  static const String _worldTimeApiUrl =
      'http://worldtimeapi.org/api/timezone/Europe/Istanbul';
  static const String _timeApiUrl = 'http://worldtimeapi.org/api/ip';
  static const String _httpBinUrl = 'https://httpbin.org/delay/0';
  static const String _timeServerUrl =
      'https://worldtimeapi.org/api/timezone/Europe/Istanbul';

  // Cache için
  static DateTime? _lastFetchedTime;
  static DateTime? _lastLocalTime;
  static const Duration _cacheDuration = Duration(seconds: 10);
  static bool _isOnline = true;

  /// İnternetten güncel tarih ve saati alır (birden fazla API ile yedekleme)
  static Future<DateTime> getCurrentDateTime() async {
    try {
      // Cache kontrolü
      final now = DateTime.now();
      if (_lastFetchedTime != null &&
          now.difference(_lastLocalTime!) < _cacheDuration) {
        // Cache'den döndür - yerel saat farkını ekle
        final timeDiff = now.difference(_lastLocalTime!);
        return _lastFetchedTime!.add(timeDiff);
      }

      // İnternet bağlantısını kontrol et
      _isOnline = await _checkInternetConnection();

      if (_isOnline) {
        // İlk API'yi dene
        DateTime? result = await _tryWorldTimeApi();
        if (result != null) {
          _updateCache(result, now);
          return result;
        }

        // İkinci API'yi dene
        result = await _tryTimeApi();
        if (result != null) {
          _updateCache(result, now);
          return result;
        }

        // Üçüncü API'yi dene
        result = await _tryTimeServerApi();
        if (result != null) {
          _updateCache(result, now);
          return result;
        }
      }

      // Tüm API'ler başarısız olursa yerel saati kullan
      _updateCache(now, now);
      return now;
    } catch (e) {
      // Hata durumunda yerel saati kullan
      final now = DateTime.now();
      _updateCache(now, now);
      return now;
    }
  }

  /// İnternet bağlantısını kontrol eder
  static Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(
        Uri.parse(_httpBinUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// World Time API'den tarih ve saat almayı dener
  static Future<DateTime?> _tryWorldTimeApi() async {
    try {
      final response = await http.get(
        Uri.parse(_worldTimeApiUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dateTimeString = data['datetime'] as String;
        final utcOffset = data['utc_offset'] as String;

        // UTC offset'i parse et
        final offset = _parseUtcOffset(utcOffset);
        final utcTime = DateTime.parse(dateTimeString);

        // Türkiye saatine çevir (UTC+3)
        return utcTime.add(const Duration(hours: 3));
      }
    } catch (e) {
      // Hata durumunda null döndür
    }
    return null;
  }

  /// Time API'den tarih ve saat almayı dener
  static Future<DateTime?> _tryTimeApi() async {
    try {
      final response = await http.get(
        Uri.parse(_timeApiUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dateTimeString = data['datetime'] as String;
        final utcOffset = data['utc_offset'] as String;

        // UTC offset'i parse et
        final offset = _parseUtcOffset(utcOffset);
        final utcTime = DateTime.parse(dateTimeString);

        // Türkiye saatine çevir (UTC+3)
        return utcTime.add(const Duration(hours: 3));
      }
    } catch (e) {
      // Hata durumunda null döndür
    }
    return null;
  }

  /// Time Server API'den tarih ve saat almayı dener
  static Future<DateTime?> _tryTimeServerApi() async {
    try {
      final response = await http.get(
        Uri.parse(_timeServerUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dateTimeString = data['datetime'] as String;
        final utcOffset = data['utc_offset'] as String;

        // UTC offset'i parse et
        final offset = _parseUtcOffset(utcOffset);
        final utcTime = DateTime.parse(dateTimeString);

        // Türkiye saatine çevir (UTC+3)
        return utcTime.add(const Duration(hours: 3));
      }
    } catch (e) {
      // Hata durumunda null döndür
    }
    return null;
  }

  /// UTC offset string'ini parse eder
  static int _parseUtcOffset(String utcOffset) {
    try {
      // "+03:00" formatından saat kısmını al
      final offset = utcOffset.replaceAll(':', '');
      final sign = offset[0];
      final hours = int.parse(offset.substring(1, 3));
      return sign == '+' ? hours : -hours;
    } catch (e) {
      return 3; // Varsayılan olarak Türkiye saati (UTC+3)
    }
  }

  /// Cache'i günceller
  static void _updateCache(DateTime fetchedTime, DateTime localTime) {
    _lastFetchedTime = fetchedTime;
    _lastLocalTime = localTime;
  }

  /// Tarih formatını Türkçe olarak döndürür
  static String formatDate(DateTime dateTime) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    final days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    final dayName = days[dateTime.weekday - 1];
    final monthName = months[dateTime.month - 1];

    return '$dayName, ${dateTime.day} $monthName ${dateTime.year}';
  }

  /// Saat formatını döndürür
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }

  /// Tarih ve saati birlikte formatlar
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Kısa tarih formatı (gün/ay/yıl)
  static String formatShortDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    return '$day/$month/$year';
  }

  /// Kısa saat formatı (saat:dakika)
  static String formatShortTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  /// Gün adını döndürür
  static String getDayName(DateTime dateTime) {
    final days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[dateTime.weekday - 1];
  }

  /// Ay adını döndürür
  static String getMonthName(DateTime dateTime) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[dateTime.month - 1];
  }

  /// İnternet bağlantısı durumunu döndürür
  static bool get isOnline => _isOnline;

  /// Cache'i temizler
  static void clearCache() {
    _lastFetchedTime = null;
    _lastLocalTime = null;
  }
}
