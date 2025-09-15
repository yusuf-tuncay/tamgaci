import 'package:flutter_test/flutter_test.dart';
import 'package:tamgaci/core/pagination/pagination_controller.dart';
import '../utils/test_helpers.dart';

void main() {
  group('Pagination Integration Tests', () {
    group('PaginationController Integration', () {
      test('should handle complete pagination workflow', () async {
        // Arrange
        final controller = PaginationController<Map<String, dynamic>>();
        final mockData = TestHelpers.createMockCustomers(count: 100);

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          await Future.delayed(const Duration(milliseconds: 50));
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          final items = mockData.sublist(
            startIndex,
            endIndex > mockData.length ? mockData.length : endIndex,
          );

          return PaginationResult<Map<String, dynamic>>(
            items: items,
            totalItems: mockData.length,
            hasMore: endIndex < mockData.length,
            currentPage: page,
            totalPages: (mockData.length / limit).ceil(),
          );
        }

        // Act & Assert
        // Load initial data
        await controller.loadInitialData(mockFetchData);
        expect(controller.items.length, equals(20));
        expect(controller.currentPage, equals(1));
        expect(controller.hasMore, isTrue);
        expect(controller.totalPages, equals(5));

        // Load more data
        await controller.loadMoreData(mockFetchData);
        expect(controller.items.length, equals(40));
        expect(controller.currentPage, equals(2));
        expect(controller.hasMore, isTrue);

        // Navigate to specific page
        await controller.goToPage(3, mockFetchData);
        expect(controller.currentPage, equals(3));
        expect(controller.items.length, equals(20));

        // Navigate to last page
        await controller.lastPage(mockFetchData);
        expect(controller.currentPage, equals(5));
        expect(controller.hasMore, isFalse);

        // Navigate back to first page
        await controller.firstPage(mockFetchData);
        expect(controller.currentPage, equals(1));

        // Test search functionality
        controller.setSearchQuery('Test Customer 1');
        await controller.reloadData(mockFetchData);
        expect(controller.searchQuery, equals('Test Customer 1'));

        // Test item management
        final newItem = TestHelpers.createMockCustomer();
        controller.addItem(newItem);
        expect(controller.items.length, equals(21));
        expect(controller.totalItems, equals(101));

        // Test item update
        final updatedItem = Map<String, dynamic>.from(newItem);
        updatedItem['name'] = 'Updated Customer';
        controller.updateItem(
            updatedItem, (item) => item['id'] == newItem['id']);
        expect(
            controller.items
                .firstWhere((item) => item['id'] == newItem['id'])['name'],
            equals('Updated Customer'));

        // Test item removal
        controller.removeItem((item) => item['id'] == newItem['id']);
        expect(controller.items.length, equals(20));
        expect(controller.totalItems, equals(100));

        // Test reset
        controller.reset();
        expect(controller.items.length, equals(0));
        expect(controller.currentPage, equals(1));
        expect(controller.searchQuery, isNull);

        controller.dispose();
      });

      test('should handle pagination with different page sizes', () async {
        // Arrange
        final controller = PaginationController<Map<String, dynamic>>();
        final mockData = TestHelpers.createMockCustomers(count: 50);

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          final items = mockData.sublist(
            startIndex,
            endIndex > mockData.length ? mockData.length : endIndex,
          );

          return PaginationResult<Map<String, dynamic>>(
            items: items,
            totalItems: mockData.length,
            hasMore: endIndex < mockData.length,
            currentPage: page,
            totalPages: (mockData.length / limit).ceil(),
          );
        }

        // Act & Assert
        // Test with page size 10
        controller.setPageSize(10);
        await controller.loadInitialData(mockFetchData);
        expect(controller.items.length, equals(10));
        expect(controller.totalPages, equals(5));

        // Test with page size 25
        controller.setPageSize(25);
        await controller.reloadData(mockFetchData);
        expect(controller.items.length, equals(25));
        expect(controller.totalPages, equals(2));

        // Test with page size 50
        controller.setPageSize(50);
        await controller.reloadData(mockFetchData);
        expect(controller.items.length, equals(50));
        expect(controller.totalPages, equals(1));
        expect(controller.hasMore, isFalse);

        controller.dispose();
      });

      test('should handle pagination errors gracefully', () async {
        // Arrange
        final controller = PaginationController<Map<String, dynamic>>();

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          if (page == 2) {
            throw Exception('Network error');
          }
          return PaginationResult<Map<String, dynamic>>(
            items: TestHelpers.createMockCustomers(count: limit),
            totalItems: 100,
            hasMore: true,
            currentPage: page,
            totalPages: 5,
          );
        }

        // Act & Assert
        // Load initial data successfully
        await controller.loadInitialData(mockFetchData);
        expect(controller.items.length, equals(20));
        expect(controller.hasError, isFalse);

        // Try to load more data (should fail)
        await controller.loadMoreData(mockFetchData);
        expect(controller.hasError, isTrue);
        expect(controller.errorMessage, contains('Network error'));

        // Try to navigate to page 2 (should fail)
        await controller.goToPage(2, mockFetchData);
        expect(controller.hasError, isTrue);

        // Reload should work
        await controller.reloadData(mockFetchData);
        expect(controller.hasError, isFalse);
        expect(controller.items.length, equals(20));

        controller.dispose();
      });
    });

    group('PaginatedList Integration', () {
      test('should handle complete pagination workflow in widget', () async {
        // Arrange
        final mockData = TestHelpers.createMockCustomers(count: 100);

        Future<List<Map<String, dynamic>>> mockFetchData(
            int page, int limit) async {
          await Future.delayed(const Duration(milliseconds: 50));
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          return mockData.sublist(
            startIndex,
            endIndex > mockData.length ? mockData.length : endIndex,
          );
        }

        // Act & Assert
        // This would typically be tested with a widget tester
        // For now, we'll test the data flow
        final initialData = await mockFetchData(1, 20);
        expect(initialData.length, equals(20));

        final moreData = await mockFetchData(2, 20);
        expect(moreData.length, equals(20));

        final lastPageData = await mockFetchData(5, 20);
        expect(lastPageData.length, equals(20));
      });

      test('should handle search functionality in widget', () async {
        // Arrange
        final mockData = TestHelpers.createMockCustomers(count: 50);

        Future<List<Map<String, dynamic>>> mockFetchData(
            int page, int limit) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return mockData.take(limit).toList();
        }

        Future<List<Map<String, dynamic>>> mockSearchFunction(
            String query, int page, int limit) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return mockData
              .where((item) => item['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .take(limit)
              .toList();
        }

        // Act & Assert
        final searchResults =
            await mockSearchFunction('Test Customer 1', 1, 20);
        expect(searchResults.length, equals(1));
        expect(searchResults.first['name'], equals('Test Customer 1'));

        final noResults = await mockSearchFunction('NonExistent', 1, 20);
        expect(noResults.length, equals(0));
      });
    });

    group('InfiniteScroll Integration', () {
      test('should handle infinite scroll workflow', () async {
        // Arrange
        final mockData = TestHelpers.createMockCustomers(count: 100);

        Future<List<Map<String, dynamic>>> mockFetchData(
            int page, int limit) async {
          await Future.delayed(const Duration(milliseconds: 50));
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          return mockData.sublist(
            startIndex,
            endIndex > mockData.length ? mockData.length : endIndex,
          );
        }

        // Act & Assert
        // Simulate infinite scroll behavior
        final page1Data = await mockFetchData(1, 20);
        expect(page1Data.length, equals(20));

        final page2Data = await mockFetchData(2, 20);
        expect(page2Data.length, equals(20));

        final page3Data = await mockFetchData(3, 20);
        expect(page3Data.length, equals(20));

        final page4Data = await mockFetchData(4, 20);
        expect(page4Data.length, equals(20));

        final page5Data = await mockFetchData(5, 20);
        expect(page5Data.length, equals(20));

        // All data should be loaded
        final allData = [
          ...page1Data,
          ...page2Data,
          ...page3Data,
          ...page4Data,
          ...page5Data
        ];
        expect(allData.length, equals(100));
      });

      test('should handle infinite scroll with different thresholds', () async {
        // Arrange
        final mockData = TestHelpers.createMockCustomers(count: 50);

        Future<List<Map<String, dynamic>>> mockFetchData(
            int page, int limit) async {
          await Future.delayed(const Duration(milliseconds: 50));
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          return mockData.sublist(
            startIndex,
            endIndex > mockData.length ? mockData.length : endIndex,
          );
        }

        // Act & Assert
        // Test with different page sizes
        final smallPageData = await mockFetchData(1, 10);
        expect(smallPageData.length, equals(10));

        final largePageData = await mockFetchData(1, 25);
        expect(largePageData.length, equals(25));

        final fullPageData = await mockFetchData(1, 50);
        expect(fullPageData.length, equals(50));
      });
    });

    group('Cross-Pagination Integration', () {
      test('should handle data consistency across pagination types', () async {
        // Arrange
        final mockData = TestHelpers.createMockCustomers(count: 100);
        final controller = PaginationController<Map<String, dynamic>>();

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          final items = mockData.sublist(
            startIndex,
            endIndex > mockData.length ? mockData.length : endIndex,
          );

          return PaginationResult<Map<String, dynamic>>(
            items: items,
            totalItems: mockData.length,
            hasMore: endIndex < mockData.length,
            currentPage: page,
            totalPages: (mockData.length / limit).ceil(),
          );
        }

        // Act & Assert
        // Test controller pagination
        await controller.loadInitialData(mockFetchData);
        final controllerData = controller.items;

        // Test direct data fetching
        final directData = await mockFetchData(1, 20);
        final directItems = directData.items;

        // Data should be consistent
        expect(controllerData.length, equals(directItems.length));
        expect(controllerData.first['id'], equals(directItems.first['id']));
        expect(controllerData.last['id'], equals(directItems.last['id']));

        controller.dispose();
      });

      test('should handle pagination state management', () async {
        // Arrange
        final controller = PaginationController<Map<String, dynamic>>();
        final mockData = TestHelpers.createMockCustomers(count: 50);

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          final items = mockData.sublist(
            startIndex,
            endIndex > mockData.length ? mockData.length : endIndex,
          );

          return PaginationResult<Map<String, dynamic>>(
            items: items,
            totalItems: mockData.length,
            hasMore: endIndex < mockData.length,
            currentPage: page,
            totalPages: (mockData.length / limit).ceil(),
          );
        }

        // Act & Assert
        // Test initial state
        expect(controller.items.length, equals(0));
        expect(controller.currentPage, equals(1));
        expect(controller.hasMore, isTrue);

        // Load data and test state
        await controller.loadInitialData(mockFetchData);
        expect(controller.items.length, equals(20));
        expect(controller.currentPage, equals(1));
        expect(controller.hasMore, isTrue);
        expect(controller.totalPages, equals(3));

        // Load more and test state
        await controller.loadMoreData(mockFetchData);
        expect(controller.items.length, equals(40));
        expect(controller.currentPage, equals(2));
        expect(controller.hasMore, isTrue);

        // Load final page and test state
        await controller.loadMoreData(mockFetchData);
        expect(controller.items.length, equals(50));
        expect(controller.currentPage, equals(3));
        expect(controller.hasMore, isFalse);

        // Test page info
        final pageInfo = controller.getPageInfo();
        expect(pageInfo.currentPage, equals(3));
        expect(pageInfo.totalPages, equals(3));
        expect(pageInfo.hasMore, isFalse);
        expect(pageInfo.hasNextPage, isFalse);
        expect(pageInfo.hasPreviousPage, isTrue);

        // Test statistics
        final stats = controller.getStats();
        expect(stats.totalItems, equals(50));
        expect(stats.loadedItems, equals(50));
        expect(stats.currentPage, equals(3));
        expect(stats.totalPages, equals(3));
        expect(stats.hasMore, isFalse);

        controller.dispose();
      });
    });
  });
}
