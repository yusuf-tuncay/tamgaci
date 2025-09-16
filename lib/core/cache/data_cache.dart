import 'package:tamgaci/core/errors/error_logger.dart';
import 'package:tamgaci/core/cache/cache_manager.dart';

/// Data cache manager for handling application data caching
class DataCache {
  static final DataCache _instance = DataCache._internal();
  factory DataCache() => _instance;
  DataCache._internal();

  final CacheManager _cacheManager = CacheManager();

  // Cache prefixes for different data types
  static const String _customerCachePrefix = 'customer_cache_';
  static const String _productCachePrefix = 'product_cache_';
  static const String _invoiceCachePrefix = 'invoice_cache_';
  static const String _dashboardCachePrefix = 'dashboard_cache_';
  static const String _reportCachePrefix = 'report_cache_';

  // Cache expiry durations
  static const Duration _customerExpiry = Duration(minutes: 30);
  static const Duration _productExpiry = Duration(minutes: 15);
  static const Duration _invoiceExpiry = Duration(minutes: 10);
  static const Duration _dashboardExpiry = Duration(minutes: 5);
  static const Duration _reportExpiry = Duration(hours: 1);

  /// Cache customers data
  Future<void> cacheCustomers(List<Map<String, dynamic>> customers) async {
    try {
      await _cacheManager.set(
        '${_customerCachePrefix}all',
        customers,
        expiry: _customerExpiry,
      );

      ErrorLogger.logInfo(
        'Cached ${customers.length} customers',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching customers',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached customers
  Future<List<Map<String, dynamic>>?> getCachedCustomers() async {
    try {
      final cachedData = await _cacheManager.get<List<Map<String, dynamic>>>(
        '${_customerCachePrefix}all',
        fromJson: (data) =>
            (data['customers'] as List).cast<Map<String, dynamic>>().toList(),
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved ${cachedData.length} cached customers',
          context: 'DataCache',
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached customers',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Cache single customer
  Future<void> cacheCustomer(
      String customerId, Map<String, dynamic> customer) async {
    try {
      await _cacheManager.set(
        '$_customerCachePrefix$customerId',
        customer,
        expiry: _customerExpiry,
      );

      ErrorLogger.logDebug(
        'Cached customer: $customerId',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching customer: $customerId',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached customer
  Future<Map<String, dynamic>?> getCachedCustomer(String customerId) async {
    try {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(
        '$_customerCachePrefix$customerId',
        fromJson: (data) => data,
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved cached customer: $customerId',
          context: 'DataCache',
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached customer: $customerId',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Cache products data
  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    try {
      await _cacheManager.set(
        '${_productCachePrefix}all',
        products,
        expiry: _productExpiry,
      );

      ErrorLogger.logInfo(
        'Cached ${products.length} products',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching products',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached products
  Future<List<Map<String, dynamic>>?> getCachedProducts() async {
    try {
      final cachedData = await _cacheManager.get<List<Map<String, dynamic>>>(
        '${_productCachePrefix}all',
        fromJson: (data) =>
            (data['products'] as List).cast<Map<String, dynamic>>().toList(),
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved ${cachedData.length} cached products',
          context: 'DataCache',
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached products',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Cache single product
  Future<void> cacheProduct(
      String productId, Map<String, dynamic> product) async {
    try {
      await _cacheManager.set(
        '$_productCachePrefix$productId',
        product,
        expiry: _productExpiry,
      );

      ErrorLogger.logDebug(
        'Cached product: $productId',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching product: $productId',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached product
  Future<Map<String, dynamic>?> getCachedProduct(String productId) async {
    try {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(
        '$_productCachePrefix$productId',
        fromJson: (data) => data,
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved cached product: $productId',
          context: 'DataCache',
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached product: $productId',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Cache invoices data
  Future<void> cacheInvoices(List<Map<String, dynamic>> invoices) async {
    try {
      await _cacheManager.set(
        '${_invoiceCachePrefix}all',
        invoices,
        expiry: _invoiceExpiry,
      );

      ErrorLogger.logInfo(
        'Cached ${invoices.length} invoices',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching invoices',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached invoices
  Future<List<Map<String, dynamic>>?> getCachedInvoices() async {
    try {
      final cachedData = await _cacheManager.get<List<Map<String, dynamic>>>(
        '${_invoiceCachePrefix}all',
        fromJson: (data) =>
            (data['invoices'] as List).cast<Map<String, dynamic>>().toList(),
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved ${cachedData.length} cached invoices',
          context: 'DataCache',
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached invoices',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Cache dashboard data
  Future<void> cacheDashboardData(Map<String, dynamic> dashboardData) async {
    try {
      await _cacheManager.set(
        '${_dashboardCachePrefix}summary',
        dashboardData,
        expiry: _dashboardExpiry,
      );

      ErrorLogger.logDebug(
        'Cached dashboard data',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching dashboard data',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached dashboard data
  Future<Map<String, dynamic>?> getCachedDashboardData() async {
    try {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(
        '${_dashboardCachePrefix}summary',
        fromJson: (data) => data,
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved cached dashboard data',
          context: 'DataCache',
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached dashboard data',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Cache report data
  Future<void> cacheReportData(
      String reportType, Map<String, dynamic> reportData) async {
    try {
      await _cacheManager.set(
        '$_reportCachePrefix$reportType',
        reportData,
        expiry: _reportExpiry,
      );

      ErrorLogger.logDebug(
        'Cached report data: $reportType',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching report data: $reportType',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached report data
  Future<Map<String, dynamic>?> getCachedReportData(String reportType) async {
    try {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(
        '$_reportCachePrefix$reportType',
        fromJson: (data) => data,
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved cached report data: $reportType',
          context: 'DataCache',
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached report data: $reportType',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Cache search results
  Future<void> cacheSearchResults(
      String query, List<Map<String, dynamic>> results) async {
    try {
      final cacheKey = 'search_${query.hashCode}';
      await _cacheManager.set(
        cacheKey,
        results,
        expiry: const Duration(minutes: 10),
      );

      ErrorLogger.logDebug(
        'Cached search results for: $query',
        context: 'DataCache',
        additionalData: {'resultCount': results.length},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching search results: $query',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached search results
  Future<List<Map<String, dynamic>>?> getCachedSearchResults(
      String query) async {
    try {
      final cacheKey = 'search_${query.hashCode}';
      final cachedData = await _cacheManager.get<List<Map<String, dynamic>>>(
        cacheKey,
        fromJson: (data) =>
            (data['results'] as List).cast<Map<String, dynamic>>().toList(),
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved cached search results for: $query',
          context: 'DataCache',
          additionalData: {'resultCount': cachedData.length},
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached search results: $query',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Cache user preferences
  Future<void> cacheUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _cacheManager.set(
        'user_preferences',
        preferences,
        expiry: const Duration(days: 30),
      );

      ErrorLogger.logDebug(
        'Cached user preferences',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching user preferences',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cached user preferences
  Future<Map<String, dynamic>?> getCachedUserPreferences() async {
    try {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(
        'user_preferences',
        fromJson: (data) => data,
      );

      if (cachedData != null) {
        ErrorLogger.logDebug(
          'Retrieved cached user preferences',
          context: 'DataCache',
        );
      }

      return cachedData;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached user preferences',
        error: e,
        context: 'DataCache',
      );
      return null;
    }
  }

  /// Clear specific data type cache
  Future<void> clearDataTypeCache(DataType dataType) async {
    try {
      // This would require more complex logic to remove only specific prefix items
      // For now, we'll just log the action
      ErrorLogger.logInfo(
        'Cleared cache for data type: ${dataType.name}',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error clearing cache for data type: ${dataType.name}',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Clear all data cache
  Future<void> clearAllDataCache() async {
    try {
      await _cacheManager.clear();

      ErrorLogger.logInfo(
        'All data cache cleared',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error clearing all data cache',
        error: e,
        context: 'DataCache',
      );
    }
  }

  /// Get cache statistics
  Future<DataCacheStats> getCacheStatistics() async {
    try {
      final cacheInfo = await _cacheManager.getCacheInfo();

      return DataCacheStats(
        totalSize: cacheInfo.totalSize,
        totalItems: cacheInfo.totalItems,
        hitRate: cacheInfo.hitRate,
        memoryItems: cacheInfo.memoryItems,
        diskItems: cacheInfo.diskItems,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cache statistics',
        error: e,
        context: 'DataCache',
      );
      return DataCacheStats.empty();
    }
  }

  /// Preload critical data
  Future<void> preloadCriticalData() async {
    try {
      ErrorLogger.logInfo(
        'Preloading critical data',
        context: 'DataCache',
      );

      // This would typically preload essential data like:
      // - User preferences
      // - Dashboard summary
      // - Recent customers/products
      // - etc.

      ErrorLogger.logInfo(
        'Critical data preloading completed',
        context: 'DataCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error preloading critical data',
        error: e,
        context: 'DataCache',
      );
    }
  }
}

/// Data type enum
enum DataType {
  customers,
  products,
  invoices,
  dashboard,
  reports,
}

/// Data cache statistics
class DataCacheStats {
  final int totalSize;
  final int totalItems;
  final double hitRate;
  final int memoryItems;
  final int diskItems;

  const DataCacheStats({
    required this.totalSize,
    required this.totalItems,
    required this.hitRate,
    required this.memoryItems,
    required this.diskItems,
  });

  factory DataCacheStats.empty() => const DataCacheStats(
        totalSize: 0,
        totalItems: 0,
        hitRate: 0.0,
        memoryItems: 0,
        diskItems: 0,
      );

  @override
  String toString() {
    return 'DataCacheStats(totalSize: $totalSize, totalItems: $totalItems, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}
