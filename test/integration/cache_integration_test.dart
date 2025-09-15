import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamgaci/core/cache/cache_manager.dart';
import 'package:tamgaci/core/cache/image_cache.dart';
import 'package:tamgaci/core/cache/data_cache.dart';
import '../utils/test_helpers.dart';

void main() {
  group('Cache Integration Tests', () {
    late CacheManager cacheManager;
    late ImageCache imageCache;
    late DataCache dataCache;

    setUp(() {
      // Initialize test environment
      SharedPreferences.setMockInitialValues({});
      cacheManager = CacheManager();
      imageCache = ImageCache();
      dataCache = DataCache();

      // Setup test environment
      TestHelpers.setupTestEnvironment();
    });

    tearDown(() {
      // Cleanup test environment
      TestHelpers.cleanupTestEnvironment();
    });

    group('Cache Manager Integration', () {
      test('should handle complex data types', () async {
        // Arrange
        const key = 'complex_data';
        final complexData = {
          'string': 'Hello World',
          'number': 42,
          'boolean': true,
          'list': [1, 2, 3, 4, 5],
          'nested': {
            'inner': 'value',
            'array': ['a', 'b', 'c'],
          },
          'nullValue': null,
        };

        // Act
        await cacheManager.set(key, complexData);
        final retrievedData = await cacheManager.get<Map<String, dynamic>>(
          key,
          fromJson: (data) => data,
        );

        // Assert
        expect(retrievedData, isNotNull);
        expect(retrievedData!['string'], equals('Hello World'));
        expect(retrievedData['number'], equals(42));
        expect(retrievedData['boolean'], equals(true));
        expect(retrievedData['list'], equals([1, 2, 3, 4, 5]));
        expect(retrievedData['nested']['inner'], equals('value'));
        expect(retrievedData['nested']['array'], equals(['a', 'b', 'c']));
        expect(retrievedData['nullValue'], isNull);
      });

      test('should handle large datasets', () async {
        // Arrange
        const key = 'large_dataset';
        final largeData = List.generate(
            1000,
            (index) => {
                  'id': index,
                  'name': 'Item $index',
                  'value': index * 10,
                });

        // Act
        await cacheManager.set(key, largeData);
        final retrievedData =
            await cacheManager.get<List<Map<String, dynamic>>>(
          key,
          fromJson: (data) =>
              (data['value'] as List).cast<Map<String, dynamic>>(),
        );

        // Assert
        expect(retrievedData, isNotNull);
        expect(retrievedData!.length, equals(1000));
        expect(retrievedData.first['id'], equals(0));
        expect(retrievedData.last['id'], equals(999));
      });

      test('should handle concurrent operations', () async {
        // Arrange
        const keys = ['key1', 'key2', 'key3', 'key4', 'key5'];
        final values =
            keys.map((key) => {'key': key, 'value': key.hashCode}).toList();

        // Act
        final futures = keys.asMap().entries.map((entry) {
          final index = entry.key;
          final key = entry.value;
          return cacheManager.set(key, values[index]);
        });

        await Future.wait(futures);

        // Assert
        for (int i = 0; i < keys.length; i++) {
          final retrievedData = await cacheManager.get<Map<String, dynamic>>(
            keys[i],
            fromJson: (data) => data,
          );
          expect(retrievedData, isNotNull);
          expect(retrievedData!['key'], equals(keys[i]));
          expect(retrievedData['value'], equals(values[i]['value']));
        }
      });

      test('should handle cache expiry correctly', () async {
        // Arrange
        const key = 'expiry_test';
        const testData = {'message': 'This will expire'};
        const shortExpiry = Duration(milliseconds: 100);

        // Act
        await cacheManager.set(key, testData, expiry: shortExpiry);

        // Verify data exists immediately
        final immediateData = await cacheManager.get<Map<String, dynamic>>(
          key,
          fromJson: (data) => data,
        );
        expect(immediateData, isNotNull);

        // Wait for expiry
        await Future.delayed(const Duration(milliseconds: 150));

        // Verify data is expired
        final expiredData = await cacheManager.get<Map<String, dynamic>>(
          key,
          fromJson: (data) => data,
        );
        expect(expiredData, isNull);
      });
    });

    group('Image Cache Integration', () {
      test('should handle image caching workflow', () async {
        // Arrange
        const imageUrl = 'https://example.com/test-image.jpg';
        final imageData =
            Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

        // Act
        await imageCache.cacheImage(imageUrl, imageData);
        final cachedImage = await imageCache.getCachedImage(imageUrl);
        final isCached = await imageCache.isImageCached(imageUrl);
        final cacheInfo = await imageCache.getImageCacheInfo(imageUrl);

        // Assert
        expect(cachedImage, isNotNull);
        expect(cachedImage, equals(imageData));
        expect(isCached, isTrue);
        expect(cacheInfo, isNotNull);
        expect(cacheInfo!.url, equals(imageUrl));
        expect(cacheInfo.size, equals(imageData.length));
      });

      test('should handle image cache cleanup', () async {
        // Arrange
        const imageUrl = 'https://example.com/test-image.jpg';
        final imageData = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

        // Act
        await imageCache.cacheImage(imageUrl, imageData);
        await imageCache.removeCachedImage(imageUrl);
        final cachedImage = await imageCache.getCachedImage(imageUrl);
        final isCached = await imageCache.isImageCached(imageUrl);

        // Assert
        expect(cachedImage, isNull);
        expect(isCached, isFalse);
      });

      test('should handle batch image operations', () async {
        // Arrange
        final imageUrls = [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
          'https://example.com/image3.jpg',
        ];
        final imageDataList = imageUrls
            .map((url) => Uint8List.fromList(
                [0xFF, 0xD8, 0xFF, 0xE0, url.hashCode & 0xFF]))
            .toList();

        // Act
        for (int i = 0; i < imageUrls.length; i++) {
          await imageCache.cacheImage(imageUrls[i], imageDataList[i]);
        }

        await imageCache.clearAllImages();

        // Assert
        for (final url in imageUrls) {
          final cachedImage = await imageCache.getCachedImage(url);
          expect(cachedImage, isNull);
        }
      });
    });

    group('Data Cache Integration', () {
      test('should handle customer data caching workflow', () async {
        // Arrange
        final customers = TestHelpers.createMockCustomers(count: 10);

        // Act
        await dataCache.cacheCustomers(customers);
        final cachedCustomers = await dataCache.getCachedCustomers();

        // Assert
        expect(cachedCustomers, isNotNull);
        expect(cachedCustomers!.length, equals(10));
        expect(cachedCustomers.first['name'], equals('Test Customer 1'));
        expect(cachedCustomers.last['name'], equals('Test Customer 10'));
      });

      test('should handle product data caching workflow', () async {
        // Arrange
        final products = TestHelpers.createMockProducts(count: 5);

        // Act
        await dataCache.cacheProducts(products);
        final cachedProducts = await dataCache.getCachedProducts();

        // Assert
        expect(cachedProducts, isNotNull);
        expect(cachedProducts!.length, equals(5));
        expect(cachedProducts.first['name'], equals('Test Product 1'));
        expect(cachedProducts.last['name'], equals('Test Product 5'));
      });

      test('should handle dashboard data caching workflow', () async {
        // Arrange
        final dashboardData = {
          'totalSales': 10000.0,
          'totalPurchases': 8000.0,
          'totalCustomers': 50,
          'totalProducts': 100,
          'lowStockProducts': 5,
          'pendingInvoices': 10,
        };

        // Act
        await dataCache.cacheDashboardData(dashboardData);
        final cachedDashboardData = await dataCache.getCachedDashboardData();

        // Assert
        expect(cachedDashboardData, isNotNull);
        expect(cachedDashboardData!['totalSales'], equals(10000.0));
        expect(cachedDashboardData['totalCustomers'], equals(50));
        expect(cachedDashboardData['lowStockProducts'], equals(5));
      });

      test('should handle search results caching workflow', () async {
        // Arrange
        const query = 'test query';
        final searchResults = TestHelpers.createMockCustomers(count: 3);

        // Act
        await dataCache.cacheSearchResults(query, searchResults);
        final cachedResults = await dataCache.getCachedSearchResults(query);

        // Assert
        expect(cachedResults, isNotNull);
        expect(cachedResults!.length, equals(3));
        expect(cachedResults.first['name'], equals('Test Customer 1'));
      });

      test('should handle user preferences caching workflow', () async {
        // Arrange
        final preferences = {
          'theme': 'dark',
          'language': 'tr',
          'notifications': true,
          'autoSave': false,
        };

        // Act
        await dataCache.cacheUserPreferences(preferences);
        final cachedPreferences = await dataCache.getCachedUserPreferences();

        // Assert
        expect(cachedPreferences, isNotNull);
        expect(cachedPreferences!['theme'], equals('dark'));
        expect(cachedPreferences['language'], equals('tr'));
        expect(cachedPreferences['notifications'], equals(true));
        expect(cachedPreferences['autoSave'], equals(false));
      });

      test('should handle cache statistics', () async {
        // Arrange
        final customers = TestHelpers.createMockCustomers(count: 5);
        final products = TestHelpers.createMockProducts(count: 3);

        // Act
        await dataCache.cacheCustomers(customers);
        await dataCache.cacheProducts(products);
        final stats = await dataCache.getCacheStatistics();

        // Assert
        expect(stats, isNotNull);
        expect(stats.totalSize, greaterThan(0));
        expect(stats.totalItems, greaterThan(0));
        expect(stats.hitRate, greaterThanOrEqualTo(0.0));
        expect(stats.hitRate, lessThanOrEqualTo(1.0));
      });
    });

    group('Cross-Cache Integration', () {
      test('should handle data flow between different cache types', () async {
        // Arrange
        final customers = TestHelpers.createMockCustomers(count: 5);
        const imageUrl = 'https://example.com/customer-avatar.jpg';
        final imageData = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

        // Act
        await dataCache.cacheCustomers(customers);
        await imageCache.cacheImage(imageUrl, imageData);
        await cacheManager.set('user_session', {
          'userId': 'test_user',
          'loginTime': DateTime.now().toIso8601String()
        });

        // Assert
        final cachedCustomers = await dataCache.getCachedCustomers();
        final cachedImage = await imageCache.getCachedImage(imageUrl);
        final sessionData = await cacheManager.get<Map<String, dynamic>>(
          'user_session',
          fromJson: (data) => data,
        );

        expect(cachedCustomers, isNotNull);
        expect(cachedCustomers!.length, equals(5));
        expect(cachedImage, isNotNull);
        expect(sessionData, isNotNull);
        expect(sessionData!['userId'], equals('test_user'));
      });

      test('should handle cache cleanup across all cache types', () async {
        // Arrange
        final customers = TestHelpers.createMockCustomers(count: 3);
        const imageUrl = 'https://example.com/test.jpg';
        final imageData = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

        await dataCache.cacheCustomers(customers);
        await imageCache.cacheImage(imageUrl, imageData);
        await cacheManager.set('test_key', {'value': 'test'});

        // Act
        await dataCache.clearAllDataCache();
        await imageCache.clearAllImages();
        await cacheManager.clear();

        // Assert
        final cachedCustomers = await dataCache.getCachedCustomers();
        final cachedImage = await imageCache.getCachedImage(imageUrl);
        final cachedData = await cacheManager.get<Map<String, dynamic>>(
          'test_key',
          fromJson: (data) => data,
        );

        expect(cachedCustomers, isNull);
        expect(cachedImage, isNull);
        expect(cachedData, isNull);
      });

      test('should handle cache performance under load', () async {
        // Arrange
        final operations = <Future<void>>[];

        // Act
        // Simulate high load with multiple concurrent operations
        for (int i = 0; i < 100; i++) {
          operations.add(cacheManager.set('key_$i', {'value': i}));
          operations.add(dataCache.cacheCustomer(
              'customer_$i', TestHelpers.createMockCustomer()));
          operations.add(imageCache.cacheImage(
              'image_$i', Uint8List.fromList([i & 0xFF])));
        }

        await Future.wait(operations);

        // Assert
        final cacheInfo = await cacheManager.getCacheInfo();
        final dataStats = await dataCache.getCacheStatistics();
        final imageCacheSize = await imageCache.getCacheSize();

        expect(cacheInfo.totalItems, greaterThan(0));
        expect(dataStats.totalItems, greaterThan(0));
        expect(imageCacheSize, greaterThan(0));
      });
    });
  });
}
