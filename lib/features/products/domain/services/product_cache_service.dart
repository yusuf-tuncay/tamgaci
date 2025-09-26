// ========== PRODUCT CACHE SERVICE ==========
// lib/features/products/domain/services/product_cache_service.dart

import '../entities/product.dart';

/// Ürün cache servisi - Performans optimizasyonu için
class ProductCacheService {
  static final Map<String, Product> _productCache = {};
  static final Map<String, List<Product>> _listCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _maxCacheSize = 1000;

  /// Ürün cache'den al
  static Product? getProduct(String id) {
    final cacheKey = 'product_$id';
    if (_isCacheValid(cacheKey)) {
      return _productCache[id];
    }
    _removeFromCache(cacheKey);
    return null;
  }

  /// Ürün cache'e kaydet
  static void setProduct(Product product) {
    _cleanupCache();
    _productCache[product.id] = product;
    _cacheTimestamps['product_${product.id}'] = DateTime.now();
  }

  /// Ürün listesi cache'den al
  static List<Product>? getProductList(String cacheKey) {
    if (_isCacheValid(cacheKey)) {
      return _listCache[cacheKey];
    }
    _removeFromCache(cacheKey);
    return null;
  }

  /// Ürün listesi cache'e kaydet
  static void setProductList(String cacheKey, List<Product> products) {
    _cleanupCache();
    _listCache[cacheKey] = products;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  /// Cache geçerliliğini kontrol et
  static bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Cache'den kaldır
  static void _removeFromCache(String cacheKey) {
    _cacheTimestamps.remove(cacheKey);
    if (cacheKey.startsWith('product_')) {
      final productId = cacheKey.substring(7);
      _productCache.remove(productId);
    } else {
      _listCache.remove(cacheKey);
    }
  }

  /// Cache temizleme
  static void _cleanupCache() {
    if (_productCache.length + _listCache.length > _maxCacheSize) {
      // En eski cache'leri kaldır
      final sortedTimestamps = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final toRemove = sortedTimestamps.take(_maxCacheSize ~/ 2);
      for (final entry in toRemove) {
        _removeFromCache(entry.key);
      }
    }
  }

  /// Tüm cache'i temizle
  static void clearAllCache() {
    _productCache.clear();
    _listCache.clear();
    _cacheTimestamps.clear();
  }

  /// Belirli ürün cache'ini temizle
  static void clearProductCache(String productId) {
    _removeFromCache('product_$productId');
  }

  /// Cache istatistikleri
  static Map<String, dynamic> getCacheStats() {
    return {
      'productCount': _productCache.length,
      'listCount': _listCache.length,
      'totalCacheSize': _productCache.length + _listCache.length,
      'maxCacheSize': _maxCacheSize,
      'cacheExpiryMinutes': _cacheExpiry.inMinutes,
    };
  }
}
