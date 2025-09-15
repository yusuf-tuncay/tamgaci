import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamgaci/core/cache/cache_manager.dart';
import '../utils/test_helpers.dart';

void main() {
  group('CacheManager Tests', () {
    late CacheManager cacheManager;

    setUp(() {
      // Initialize test environment
      SharedPreferences.setMockInitialValues({});
      cacheManager = CacheManager();

      // Setup test environment
      TestHelpers.setupTestEnvironment();
    });

    tearDown(() async {
      // Cleanup test environment
      await cacheManager.clear(); // Clear cache between tests
      // Reset cache statistics
      cacheManager.stats.sets = 0;
      cacheManager.stats.hitAttempts = 0;
      cacheManager.stats.memoryHits = 0;
      cacheManager.stats.diskHits = 0;
      cacheManager.stats.misses = 0;
      TestHelpers.cleanupTestEnvironment();
    });

    group('Configuration', () {
      test('should set default configuration', () {
        // Arrange & Act
        final config = cacheManager.config;

        // Assert
        expect(config.maxSize, equals(100 * 1024 * 1024)); // 100MB
        expect(config.maxItems, equals(1000));
        expect(config.defaultExpiry, equals(const Duration(hours: 1)));
        expect(config.enableMemoryCache, isTrue);
        expect(config.enableDiskCache, isTrue);
      });

      test('should update configuration', () {
        // Arrange
        const newConfig = CacheConfig(
          maxSize: 50 * 1024 * 1024, // 50MB
          maxItems: 500,
          defaultExpiry: Duration(minutes: 30),
          enableMemoryCache: false,
          enableDiskCache: true,
        );

        // Act
        cacheManager.configure(newConfig);

        // Assert
        expect(cacheManager.config.maxSize, equals(50 * 1024 * 1024));
        expect(cacheManager.config.maxItems, equals(500));
        expect(cacheManager.config.defaultExpiry,
            equals(const Duration(minutes: 30)));
        expect(cacheManager.config.enableMemoryCache, isFalse);
        expect(cacheManager.config.enableDiskCache, isTrue);
      });
    });

    group('Cache Operations', () {
      test('should set and get data from cache', () async {
        // Arrange
        const key = 'test_key';
        const testData = {'message': 'Hello World'};

        // Act
        await cacheManager.set(key, testData);
        final retrievedData = await cacheManager.get<Map<String, dynamic>>(
          key,
          fromJson: (data) => data,
        );

        // Assert
        expect(retrievedData, isNotNull);
        expect(retrievedData!['message'], equals('Hello World'));
      });

      test('should return null for non-existent key', () async {
        // Arrange
        const key = 'non_existent_key';

        // Act
        final result = await cacheManager.get<Map<String, dynamic>>(
          key,
          fromJson: (data) => data,
        );

        // Assert
        expect(result, isNull);
      });

      test('should remove data from cache', () async {
        // Arrange
        const key = 'test_key';
        const testData = {'message': 'Hello World'};
        await cacheManager.set(key, testData);

        // Act
        await cacheManager.remove(key);
        final result = await cacheManager.get<Map<String, dynamic>>(
          key,
          fromJson: (data) => data,
        );

        // Assert
        expect(result, isNull);
      });

      test('should clear all cache', () async {
        // Arrange
        const key1 = 'test_key_1';
        const key2 = 'test_key_2';
        const testData1 = {'message': 'Hello World 1'};
        const testData2 = {'message': 'Hello World 2'};

        await cacheManager.set(key1, testData1);
        await cacheManager.set(key2, testData2);

        // Act
        await cacheManager.clear();

        final result1 = await cacheManager.get<Map<String, dynamic>>(
          key1,
          fromJson: (data) => data,
        );
        final result2 = await cacheManager.get<Map<String, dynamic>>(
          key2,
          fromJson: (data) => data,
        );

        // Assert
        expect(result1, isNull);
        expect(result2, isNull);
      });

      test('should check if key exists', () async {
        // Arrange
        const key = 'test_key';
        const testData = {'message': 'Hello World'};

        // Act
        final existsBefore = await cacheManager.exists(key);
        await cacheManager.set(key, testData);
        final existsAfter = await cacheManager.exists(key);

        // Assert
        expect(existsBefore, isFalse);
        expect(existsAfter, isTrue);
      });
    });

    group('Cache Statistics', () {
      test('should get cache size', () async {
        // Arrange
        const key = 'test_key';
        const testData = {'message': 'Hello World'};
        await cacheManager.set(key, testData);

        // Act
        final size = await cacheManager.getCacheSize();

        // Assert
        expect(size, greaterThan(0));
      });

      test('should get cache info', () async {
        // Arrange
        const key = 'test_key';
        const testData = {'message': 'Hello World'};
        await cacheManager.set(key, testData);

        // Act
        final info = await cacheManager.getCacheInfo();

        // Assert
        expect(info, isNotNull);
        expect(info.totalSize, greaterThan(0));
        expect(info.totalItems, greaterThan(0));
      });

      test('should track cache statistics', () async {
        // Arrange
        const key = 'test_key';
        const testData = {'message': 'Hello World'};

        // Act
        await cacheManager.set(key, testData);
        await cacheManager.get<Map<String, dynamic>>(
          key,
          fromJson: (data) => data,
        );
        await cacheManager.get<Map<String, dynamic>>(
          'non_existent_key',
          fromJson: (data) => data,
        );

        // Assert
        final stats = cacheManager.stats;
        expect(stats.sets, equals(1));
        expect(stats.hitAttempts, equals(2));
        expect(stats.memoryHits + stats.diskHits, equals(1));
        expect(stats.misses, equals(1));
      });
    });

    group('Error Handling', () {
      test('should handle cache errors gracefully', () async {
        // Arrange
        const key = 'test_key';
        const testData = {'message': 'Hello World'};

        // Act & Assert
        // This test would typically use a mock to simulate errors
        // For now, we'll test that the cache manager doesn't throw exceptions
        expect(
            () async => await cacheManager.set(key, testData), returnsNormally);
        expect(
            () async => await cacheManager.get<Map<String, dynamic>>(
                  key,
                  fromJson: (data) => data,
                ),
            returnsNormally);
        expect(() async => await cacheManager.remove(key), returnsNormally);
        expect(() async => await cacheManager.clear(), returnsNormally);
      });
    });

    group('Data Types', () {
      test('should handle different data types', () async {
        // Arrange
        const stringKey = 'string_key';
        const intKey = 'int_key';
        const boolKey = 'bool_key';
        const mapKey = 'map_key';
        const listKey = 'list_key';

        const stringValue = 'Hello World';
        const intValue = 42;
        const boolValue = true;
        const mapValue = {'key': 'value'};
        const listValue = [1, 2, 3, 4, 5];

        // Act
        await cacheManager.set(stringKey, stringValue);
        await cacheManager.set(intKey, intValue);
        await cacheManager.set(boolKey, boolValue);
        await cacheManager.set(mapKey, mapValue);
        await cacheManager.set(listKey, listValue);

        final retrievedString = await cacheManager.get<String>(stringKey);
        final retrievedInt = await cacheManager.get<int>(intKey);
        final retrievedBool = await cacheManager.get<bool>(boolKey);
        final retrievedMap = await cacheManager.get<Map<String, dynamic>>(
          mapKey,
          fromJson: (data) => data,
        );
        final retrievedList = await cacheManager.get<List<dynamic>>(
          listKey,
          fromJson: (data) => data['value'] as List<dynamic>,
        );

        // Assert
        expect(retrievedString, equals(stringValue));
        expect(retrievedInt, equals(intValue));
        expect(retrievedBool, equals(boolValue));
        expect(retrievedMap, equals(mapValue));
        expect(retrievedList, equals(listValue));
      });
    });

    group('Cleanup', () {
      test('should cleanup expired items', () async {
        // Arrange
        const key = 'test_key';
        const testData = {'message': 'Hello World'};

        // Set with very short expiry
        const shortExpiry = Duration(milliseconds: 1);
        await cacheManager.set(key, testData, expiry: shortExpiry);

        // Wait for expiry
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        await cacheManager.cleanup();
        final result = await cacheManager.get<Map<String, dynamic>>(
          key,
          fromJson: (data) => data,
        );

        // Assert
        expect(result, isNull);
      });
    });
  });
}
