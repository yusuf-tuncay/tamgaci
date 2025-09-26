// ========== RATE LIMITER SERVICE ==========
// lib/features/products/domain/services/rate_limiter.dart

import 'dart:async';

/// Rate limiting servisi - API güvenliği için
class RateLimiter {
  static final Map<String, List<DateTime>> _requestHistory = {};
  static final Map<String, Timer> _cleanupTimers = {};

  // Rate limit ayarları
  static const int _maxRequestsPerMinute = 60;
  static const int _maxRequestsPerHour = 1000;
  static const int _maxRequestsPerDay = 10000;
  static const Duration _cleanupInterval = Duration(minutes: 5);

  /// Rate limit kontrolü
  static bool checkRateLimit(String userId, String action) {
    final now = DateTime.now();
    final key = '${userId}_$action';

    // Mevcut istekleri al
    final requests = _requestHistory[key] ?? [];

    // Eski istekleri temizle
    requests.removeWhere((time) => now.difference(time) > const Duration(days: 1));

    // Rate limit kontrolü
    if (_isRateLimited(requests, now)) {
      return false;
    }

    // Yeni isteği kaydet
    requests.add(now);
    _requestHistory[key] = requests;

    // Cleanup timer'ı başlat
    _startCleanupTimer(key);

    return true;
  }

  /// Rate limit kontrolü
  static bool _isRateLimited(List<DateTime> requests, DateTime now) {
    // Dakika bazında kontrol
    final lastMinute = requests
        .where((time) => now.difference(time) < const Duration(minutes: 1))
        .length;
    if (lastMinute >= _maxRequestsPerMinute) {
      return true;
    }

    // Saat bazında kontrol
    final lastHour = requests
        .where((time) => now.difference(time) < const Duration(hours: 1))
        .length;
    if (lastHour >= _maxRequestsPerHour) {
      return true;
    }

    // Gün bazında kontrol
    final lastDay = requests
        .where((time) => now.difference(time) < const Duration(days: 1))
        .length;
    if (lastDay >= _maxRequestsPerDay) {
      return true;
    }

    return false;
  }

  /// Cleanup timer başlat
  static void _startCleanupTimer(String key) {
    if (_cleanupTimers.containsKey(key)) {
      _cleanupTimers[key]?.cancel();
    }

    _cleanupTimers[key] = Timer(_cleanupInterval, () {
      _cleanupOldRequests(key);
    });
  }

  /// Eski istekleri temizle
  static void _cleanupOldRequests(String key) {
    final requests = _requestHistory[key];
    if (requests != null) {
      final now = DateTime.now();
      requests.removeWhere((time) => now.difference(time) > const Duration(days: 1));

      if (requests.isEmpty) {
        _requestHistory.remove(key);
      }
    }

    _cleanupTimers.remove(key);
  }

  /// Kullanıcı için rate limit bilgisi
  static Map<String, dynamic> getRateLimitInfo(String userId, String action) {
    final key = '${userId}_$action';
    final requests = _requestHistory[key] ?? [];
    final now = DateTime.now();

    final lastMinute = requests
        .where((time) => now.difference(time) < const Duration(minutes: 1))
        .length;
    final lastHour = requests
        .where((time) => now.difference(time) < const Duration(hours: 1))
        .length;
    final lastDay = requests
        .where((time) => now.difference(time) < const Duration(days: 1))
        .length;

    return {
      'userId': userId,
      'action': action,
      'requestsLastMinute': lastMinute,
      'requestsLastHour': lastHour,
      'requestsLastDay': lastDay,
      'maxPerMinute': _maxRequestsPerMinute,
      'maxPerHour': _maxRequestsPerHour,
      'maxPerDay': _maxRequestsPerDay,
      'isLimited': _isRateLimited(requests, now),
    };
  }

  /// Tüm rate limit verilerini temizle
  static void clearAllRateLimits() {
    _requestHistory.clear();
    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();
  }

  /// Belirli kullanıcının rate limit'ini temizle
  static void clearUserRateLimits(String userId) {
    final keysToRemove = _requestHistory.keys
        .where((key) => key.startsWith('${userId}_'))
        .toList();

    for (final key in keysToRemove) {
      _requestHistory.remove(key);
      _cleanupTimers[key]?.cancel();
      _cleanupTimers.remove(key);
    }
  }
}
