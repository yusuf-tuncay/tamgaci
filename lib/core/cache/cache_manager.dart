import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Central cache manager for the application
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  static const String _cachePrefix = 'tamgaci_cache_';
  static const String _cacheTimestampPrefix = 'tamgaci_timestamp_';
  static const String _cacheSizePrefix = 'tamgaci_size_';

  // Default cache settings
  static const Duration _defaultExpiry = Duration(hours: 1);
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheItems = 1000;

  /// Cache configuration
  CacheConfig _config = const CacheConfig(
    maxSize: _maxCacheSize,
    maxItems: _maxCacheItems,
    defaultExpiry: _defaultExpiry,
    enableMemoryCache: true,
    enableDiskCache: true,
  );

  /// Memory cache
  final Map<String, CacheItem> _memoryCache = {};

  /// Cache statistics
  final CacheStats _stats = CacheStats();

  /// Get cache configuration
  CacheConfig get config => _config;

  /// Get cache statistics
  CacheStats get stats => _stats;

  /// Set cache configuration
  void configure(CacheConfig config) {
    _config = config;
    ErrorLogger.logInfo(
      'Cache configuration updated',
      context: 'CacheManager',
      additionalData: {
        'maxSize': config.maxSize,
        'maxItems': config.maxItems,
        'defaultExpiry': config.defaultExpiry.inMinutes,
        'enableMemoryCache': config.enableMemoryCache,
        'enableDiskCache': config.enableDiskCache,
      },
    );
  }

  /// Get cached data
  Future<T?> get<T>(String key,
      {T Function(Map<String, dynamic>)? fromJson}) async {
    try {
      _stats.hitAttempts++;

      // Check memory cache first
      if (_config.enableMemoryCache && _memoryCache.containsKey(key)) {
        final item = _memoryCache[key]!;
        if (!item.isExpired) {
          _stats.memoryHits++;
          ErrorLogger.logDebug(
            'Cache hit (memory): $key',
            context: 'CacheManager',
          );
          return _deserializeData<T>(item.data, fromJson);
        } else {
          _memoryCache.remove(key);
        }
      }

      // Check disk cache
      if (_config.enableDiskCache) {
        final item = await _getFromDisk(key);
        if (item != null && !item.isExpired) {
          _stats.diskHits++;

          // Add to memory cache
          if (_config.enableMemoryCache) {
            _memoryCache[key] = item;
          }

          ErrorLogger.logDebug(
            'Cache hit (disk): $key',
            context: 'CacheManager',
          );
          return _deserializeData<T>(item.data, fromJson);
        }
      }

      _stats.misses++;
      ErrorLogger.logDebug(
        'Cache miss: $key',
        context: 'CacheManager',
      );
      return null;
    } catch (e) {
      _stats.errors++;
      ErrorLogger.logError(
        'Error getting cache: $key',
        error: e,
        context: 'CacheManager',
      );
      return null;
    }
  }

  /// Set cached data
  Future<void> set<T>(
    String key,
    T data, {
    Duration? expiry,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    try {
      final serializedData = _serializeData(data, toJson);
      final cacheItem = CacheItem(
        key: key,
        data: serializedData,
        expiry: expiry ?? _config.defaultExpiry,
        createdAt: DateTime.now(),
        size: serializedData.length,
      );

      // Add to memory cache
      if (_config.enableMemoryCache) {
        _memoryCache[key] = cacheItem;
        _cleanupMemoryCache();
      }

      // Add to disk cache
      if (_config.enableDiskCache) {
        await _saveToDisk(cacheItem);
        _cleanupDiskCache();
      }

      _stats.sets++;
      ErrorLogger.logDebug(
        'Cache set: $key',
        context: 'CacheManager',
        additionalData: {
          'size': cacheItem.size,
          'expiry': cacheItem.expiry.inMinutes,
        },
      );
    } catch (e) {
      _stats.errors++;
      ErrorLogger.logError(
        'Error setting cache: $key',
        error: e,
        context: 'CacheManager',
      );
    }
  }

  /// Remove cached data
  Future<void> remove(String key) async {
    try {
      // Remove from memory cache
      if (_config.enableMemoryCache) {
        _memoryCache.remove(key);
      }

      // Remove from disk cache
      if (_config.enableDiskCache) {
        await _removeFromDisk(key);
      }

      _stats.removes++;
      ErrorLogger.logDebug(
        'Cache removed: $key',
        context: 'CacheManager',
      );
    } catch (e) {
      _stats.errors++;
      ErrorLogger.logError(
        'Error removing cache: $key',
        error: e,
        context: 'CacheManager',
      );
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    try {
      // Clear memory cache
      if (_config.enableMemoryCache) {
        _memoryCache.clear();
      }

      // Clear disk cache
      if (_config.enableDiskCache) {
        await _clearDiskCache();
      }

      _stats.clears++;
      ErrorLogger.logInfo(
        'All cache cleared',
        context: 'CacheManager',
      );
    } catch (e) {
      _stats.errors++;
      ErrorLogger.logError(
        'Error clearing cache',
        error: e,
        context: 'CacheManager',
      );
    }
  }

  /// Check if key exists in cache
  Future<bool> exists(String key) async {
    try {
      // Check memory cache
      if (_config.enableMemoryCache && _memoryCache.containsKey(key)) {
        final item = _memoryCache[key]!;
        if (!item.isExpired) {
          return true;
        } else {
          _memoryCache.remove(key);
        }
      }

      // Check disk cache
      if (_config.enableDiskCache) {
        final item = await _getFromDisk(key);
        if (item != null && !item.isExpired) {
          return true;
        }
      }

      return false;
    } catch (e) {
      ErrorLogger.logError(
        'Error checking cache existence: $key',
        error: e,
        context: 'CacheManager',
      );
      return false;
    }
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;

      // Memory cache size
      if (_config.enableMemoryCache) {
        totalSize +=
            _memoryCache.values.fold(0, (sum, item) => sum + item.size);
      }

      // Disk cache size
      if (_config.enableDiskCache) {
        totalSize += await _getDiskCacheSize();
      }

      return totalSize;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cache size',
        error: e,
        context: 'CacheManager',
      );
      return 0;
    }
  }

  /// Get cache info
  Future<CacheInfo> getCacheInfo() async {
    try {
      final size = await getCacheSize();
      final memoryItems = _config.enableMemoryCache ? _memoryCache.length : 0;
      final diskItems =
          _config.enableDiskCache ? await _getDiskCacheItemCount() : 0;

      return CacheInfo(
        totalSize: size,
        memoryItems: memoryItems,
        diskItems: diskItems,
        totalItems: memoryItems + diskItems,
        hitRate: _stats.hitRate,
        memoryHitRate: _stats.memoryHitRate,
        diskHitRate: _stats.diskHitRate,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cache info',
        error: e,
        context: 'CacheManager',
      );
      return CacheInfo.empty();
    }
  }

  /// Cleanup expired items
  Future<void> cleanup() async {
    try {
      // Cleanup memory cache
      if (_config.enableMemoryCache) {
        _memoryCache.removeWhere((key, item) => item.isExpired);
      }

      // Cleanup disk cache
      if (_config.enableDiskCache) {
        await _cleanupExpiredDiskCache();
      }

      ErrorLogger.logInfo(
        'Cache cleanup completed',
        context: 'CacheManager',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error during cache cleanup',
        error: e,
        context: 'CacheManager',
      );
    }
  }

  /// Serialize data
  Map<String, dynamic> _serializeData<T>(
      T data, Map<String, dynamic> Function(T)? toJson) {
    if (toJson != null) {
      return toJson(data);
    } else if (data is Map<String, dynamic>) {
      return data;
    } else if (data is String) {
      return {'value': data};
    } else if (data is num || data is bool) {
      return {'value': data};
    } else {
      return {'value': data.toString()};
    }
  }

  /// Deserialize data
  T? _deserializeData<T>(
      Map<String, dynamic> data, T Function(Map<String, dynamic>)? fromJson) {
    if (fromJson != null) {
      return fromJson(data);
    } else if (T == String) {
      return data['value'] as T?;
    } else if (T == int) {
      return (data['value'] as num?)?.toInt() as T?;
    } else if (T == double) {
      return (data['value'] as num?)?.toDouble() as T?;
    } else if (T == bool) {
      return data['value'] as T?;
    } else {
      return data as T?;
    }
  }

  /// Get from disk cache
  Future<CacheItem?> _getFromDisk(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('$_cachePrefix$key');
      final timestampString = prefs.getString('$_cacheTimestampPrefix$key');
      final sizeString = prefs.getString('$_cacheSizePrefix$key');

      if (dataString == null || timestampString == null || sizeString == null) {
        return null;
      }

      final data = jsonDecode(dataString) as Map<String, dynamic>;
      final timestamp = DateTime.parse(timestampString);
      final size = int.parse(sizeString);

      return CacheItem(
        key: key,
        data: data,
        expiry: _config.defaultExpiry,
        createdAt: timestamp,
        size: size,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error getting from disk cache: $key',
        error: e,
        context: 'CacheManager',
      );
      return null;
    }
  }

  /// Save to disk cache
  Future<void> _saveToDisk(CacheItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix${item.key}', jsonEncode(item.data));
      await prefs.setString('$_cacheTimestampPrefix${item.key}',
          item.createdAt.toIso8601String());
      await prefs.setString(
          '$_cacheSizePrefix${item.key}', item.size.toString());
    } catch (e) {
      ErrorLogger.logError(
        'Error saving to disk cache: ${item.key}',
        error: e,
        context: 'CacheManager',
      );
    }
  }

  /// Remove from disk cache
  Future<void> _removeFromDisk(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_cacheTimestampPrefix$key');
      await prefs.remove('$_cacheSizePrefix$key');
    } catch (e) {
      ErrorLogger.logError(
        'Error removing from disk cache: $key',
        error: e,
        context: 'CacheManager',
      );
    }
  }

  /// Clear disk cache
  Future<void> _clearDiskCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix) ||
            key.startsWith(_cacheTimestampPrefix) ||
            key.startsWith(_cacheSizePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      ErrorLogger.logError(
        'Error clearing disk cache',
        error: e,
        context: 'CacheManager',
      );
    }
  }

  /// Get disk cache size
  Future<int> _getDiskCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalSize = 0;

      for (final key in keys) {
        if (key.startsWith(_cacheSizePrefix)) {
          final sizeString = prefs.getString(key);
          if (sizeString != null) {
            totalSize += int.parse(sizeString);
          }
        }
      }

      return totalSize;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting disk cache size',
        error: e,
        context: 'CacheManager',
      );
      return 0;
    }
  }

  /// Get disk cache item count
  Future<int> _getDiskCacheItemCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      return keys.where((key) => key.startsWith(_cachePrefix)).length;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting disk cache item count',
        error: e,
        context: 'CacheManager',
      );
      return 0;
    }
  }

  /// Cleanup memory cache
  void _cleanupMemoryCache() {
    if (_memoryCache.length <= _config.maxItems) return;

    // Remove oldest items
    final sortedItems = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

    final itemsToRemove =
        sortedItems.take(_memoryCache.length - _config.maxItems);
    for (final entry in itemsToRemove) {
      _memoryCache.remove(entry.key);
    }
  }

  /// Cleanup disk cache
  Future<void> _cleanupDiskCache() async {
    final currentSize = await _getDiskCacheSize();
    if (currentSize <= _config.maxSize) return;

    // This would require more complex logic to remove oldest items
    // For now, we'll just log a warning
    ErrorLogger.logWarning(
      'Disk cache size exceeded limit',
      context: 'CacheManager',
      additionalData: {
        'currentSize': currentSize,
        'maxSize': _config.maxSize,
      },
    );
  }

  /// Cleanup expired disk cache
  Future<void> _cleanupExpiredDiskCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now();

      for (final key in keys) {
        if (key.startsWith(_cacheTimestampPrefix)) {
          final timestampString = prefs.getString(key);
          if (timestampString != null) {
            final timestamp = DateTime.parse(timestampString);
            if (now.difference(timestamp) > _config.defaultExpiry) {
              final cacheKey = key.replaceFirst(_cacheTimestampPrefix, '');
              await _removeFromDisk(cacheKey);
            }
          }
        }
      }
    } catch (e) {
      ErrorLogger.logError(
        'Error cleaning up expired disk cache',
        error: e,
        context: 'CacheManager',
      );
    }
  }
}

/// Cache configuration
class CacheConfig {
  final int maxSize;
  final int maxItems;
  final Duration defaultExpiry;
  final bool enableMemoryCache;
  final bool enableDiskCache;

  const CacheConfig({
    required this.maxSize,
    required this.maxItems,
    required this.defaultExpiry,
    required this.enableMemoryCache,
    required this.enableDiskCache,
  });
}

/// Cache item
class CacheItem {
  final String key;
  final Map<String, dynamic> data;
  final Duration expiry;
  final DateTime createdAt;
  final int size;

  const CacheItem({
    required this.key,
    required this.data,
    required this.expiry,
    required this.createdAt,
    required this.size,
  });

  bool get isExpired => DateTime.now().difference(createdAt) > expiry;
}

/// Cache statistics
class CacheStats {
  int hitAttempts = 0;
  int memoryHits = 0;
  int diskHits = 0;
  int misses = 0;
  int sets = 0;
  int removes = 0;
  int clears = 0;
  int errors = 0;

  double get hitRate =>
      hitAttempts > 0 ? (memoryHits + diskHits) / hitAttempts : 0.0;
  double get memoryHitRate => hitAttempts > 0 ? memoryHits / hitAttempts : 0.0;
  double get diskHitRate => hitAttempts > 0 ? diskHits / hitAttempts : 0.0;
}

/// Cache info
class CacheInfo {
  final int totalSize;
  final int memoryItems;
  final int diskItems;
  final int totalItems;
  final double hitRate;
  final double memoryHitRate;
  final double diskHitRate;

  const CacheInfo({
    required this.totalSize,
    required this.memoryItems,
    required this.diskItems,
    required this.totalItems,
    required this.hitRate,
    required this.memoryHitRate,
    required this.diskHitRate,
  });

  factory CacheInfo.empty() => const CacheInfo(
        totalSize: 0,
        memoryItems: 0,
        diskItems: 0,
        totalItems: 0,
        hitRate: 0.0,
        memoryHitRate: 0.0,
        diskHitRate: 0.0,
      );

  @override
  String toString() {
    return 'CacheInfo(totalSize: $totalSize, totalItems: $totalItems, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}
