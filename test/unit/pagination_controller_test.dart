import 'package:flutter_test/flutter_test.dart';
import 'package:tamgaci/core/pagination/pagination_controller.dart';
import '../utils/test_helpers.dart';

void main() {
  group('PaginationController Tests', () {
    late PaginationController<Map<String, dynamic>> controller;

    setUp(() {
      controller = PaginationController<Map<String, dynamic>>();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        // Assert
        expect(controller.items, isEmpty);
        expect(controller.isLoading, isFalse);
        expect(controller.isLoadingMore, isFalse);
        expect(controller.hasError, isFalse);
        expect(controller.hasMore, isTrue);
        expect(controller.currentPage, equals(1));
        expect(controller.errorMessage, isNull);
        expect(controller.totalItems, equals(0));
        expect(controller.pageSize, equals(20));
        expect(controller.searchQuery, isNull);
        expect(controller.totalPages, equals(0));
        expect(controller.hasPreviousPage, isFalse);
        expect(controller.hasNextPage, isFalse);
      });
    });

    group('Configuration', () {
      test('should update page size', () {
        // Act
        controller.setPageSize(50);

        // Assert
        expect(controller.pageSize, equals(50));
      });

      test('should update search query', () {
        // Act
        controller.setSearchQuery('test query');

        // Assert
        expect(controller.searchQuery, equals('test query'));
      });
    });

    group('Data Loading', () {
      test('should load initial data successfully', () async {
        // Arrange
        final mockData = TestHelpers.createMockCustomers(count: 10);
        final mockResult = PaginationResult<Map<String, dynamic>>(
          items: mockData,
          totalItems: 50,
          hasMore: true,
          currentPage: 1,
          totalPages: 3,
        );

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          return mockResult;
        }

        // Act
        await controller.loadInitialData(mockFetchData);

        // Assert
        expect(controller.items, hasLength(10));
        expect(controller.totalItems, equals(50));
        expect(controller.currentPage, equals(1));
        expect(controller.hasMore, isTrue);
        expect(controller.totalPages, equals(3));
        expect(controller.isLoading, isFalse);
        expect(controller.hasError, isFalse);
      });

      test('should load more data successfully', () async {
        // Arrange
        final initialData = TestHelpers.createMockCustomers(count: 10);
        final moreData = TestHelpers.createMockCustomers(count: 10);

        final initialResult = PaginationResult<Map<String, dynamic>>(
          items: initialData,
          totalItems: 50,
          hasMore: true,
          currentPage: 1,
          totalPages: 3,
        );

        final moreResult = PaginationResult<Map<String, dynamic>>(
          items: moreData,
          totalItems: 50,
          hasMore: true,
          currentPage: 2,
          totalPages: 3,
        );

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          if (page == 1) return initialResult;
          if (page == 2) return moreResult;
          return PaginationResult<Map<String, dynamic>>(
            items: [],
            totalItems: 50,
            hasMore: false,
            currentPage: page,
            totalPages: 3,
          );
        }

        // Act
        await controller.loadInitialData(mockFetchData);
        await controller.loadMoreData(mockFetchData);

        // Assert
        expect(controller.items, hasLength(20));
        expect(controller.currentPage, equals(2));
        expect(controller.hasMore, isTrue);
        expect(controller.isLoadingMore, isFalse);
      });

      test('should handle loading errors', () async {
        // Arrange
        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          throw Exception('Network error');
        }

        // Act
        await controller.loadInitialData(mockFetchData);

        // Assert
        expect(controller.hasError, isTrue);
        expect(controller.errorMessage, equals('Exception: Network error'));
        expect(controller.isLoading, isFalse);
        expect(controller.items, isEmpty);
      });
    });

    group('Navigation', () {
      test('should navigate to specific page', () async {
        // Arrange
        final mockData = TestHelpers.createMockCustomers(count: 10);

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          // Return different data for different pages
          final pageData = TestHelpers.createMockCustomers(count: 10);
          for (int i = 0; i < pageData.length; i++) {
            pageData[i]['id'] = 'page_${page}_customer_${i + 1}';
            pageData[i]['name'] = 'Page $page Customer ${i + 1}';
          }

          return PaginationResult<Map<String, dynamic>>(
            items: pageData,
            totalItems: 50,
            hasMore: page < 3,
            currentPage: page,
            totalPages: 3,
          );
        }

        // Load initial data first
        await controller.loadInitialData(mockFetchData);

        // Act
        await controller.goToPage(2, mockFetchData);

        // Assert
        expect(controller.currentPage, equals(2));
        expect(controller.items, hasLength(10));
        expect(controller.isLoading, isFalse);
      });

      test('should navigate to next page', () async {
        // Arrange
        final initialData = TestHelpers.createMockCustomers(count: 10);
        final nextData = TestHelpers.createMockCustomers(count: 10);

        final initialResult = PaginationResult<Map<String, dynamic>>(
          items: initialData,
          totalItems: 50,
          hasMore: true,
          currentPage: 1,
          totalPages: 3,
        );

        final nextResult = PaginationResult<Map<String, dynamic>>(
          items: nextData,
          totalItems: 50,
          hasMore: true,
          currentPage: 2,
          totalPages: 3,
        );

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          if (page == 1) return initialResult;
          if (page == 2) return nextResult;
          return PaginationResult<Map<String, dynamic>>(
            items: [],
            totalItems: 50,
            hasMore: false,
            currentPage: page,
            totalPages: 3,
          );
        }

        // Act
        await controller.loadInitialData(mockFetchData);
        await controller.nextPage(mockFetchData);

        // Assert
        expect(controller.currentPage, equals(2));
        expect(controller.items, hasLength(10));
      });

      test('should navigate to previous page', () async {
        // Arrange
        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          // Return different data for different pages
          final pageData = TestHelpers.createMockCustomers(count: 10);
          for (int i = 0; i < pageData.length; i++) {
            pageData[i]['id'] = 'page_${page}_customer_${i + 1}';
            pageData[i]['name'] = 'Page $page Customer ${i + 1}';
          }

          return PaginationResult<Map<String, dynamic>>(
            items: pageData,
            totalItems: 50,
            hasMore: page < 3,
            currentPage: page,
            totalPages: 3,
          );
        }

        // Load initial data first
        await controller.loadInitialData(mockFetchData);

        // Act
        await controller.goToPage(2, mockFetchData);
        await controller.previousPage(mockFetchData);

        // Assert
        expect(controller.currentPage, equals(1));
        expect(controller.items, hasLength(10));
      });

      test('should navigate to first page', () async {
        // Arrange
        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          // Return different data for different pages
          final pageData = TestHelpers.createMockCustomers(count: 10);
          for (int i = 0; i < pageData.length; i++) {
            pageData[i]['id'] = 'page_${page}_customer_${i + 1}';
            pageData[i]['name'] = 'Page $page Customer ${i + 1}';
          }

          return PaginationResult<Map<String, dynamic>>(
            items: pageData,
            totalItems: 50,
            hasMore: page < 3,
            currentPage: page,
            totalPages: 3,
          );
        }

        // Load initial data first
        await controller.loadInitialData(mockFetchData);

        // Act
        await controller.goToPage(3, mockFetchData);
        await controller.firstPage(mockFetchData);

        // Assert
        expect(controller.currentPage, equals(1));
        expect(controller.items, hasLength(10));
      });

      test('should navigate to last page', () async {
        // Arrange
        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          // Return different data for different pages
          final pageData = TestHelpers.createMockCustomers(count: 10);
          for (int i = 0; i < pageData.length; i++) {
            pageData[i]['id'] = 'page_${page}_customer_${i + 1}';
            pageData[i]['name'] = 'Page $page Customer ${i + 1}';
          }

          return PaginationResult<Map<String, dynamic>>(
            items: pageData,
            totalItems: 50,
            hasMore: page < 3,
            currentPage: page,
            totalPages: 3,
          );
        }

        // Load initial data first
        await controller.loadInitialData(mockFetchData);

        // Act
        await controller.lastPage(mockFetchData);

        // Assert
        expect(controller.currentPage, equals(3));
        expect(controller.items, hasLength(10));
        expect(controller.hasMore, isFalse);
      });
    });

    group('Item Management', () {
      test('should add item', () {
        // Arrange
        final item = TestHelpers.createMockCustomer();

        // Act
        controller.addItem(item);

        // Assert
        expect(controller.items, hasLength(1));
        expect(controller.items.first, equals(item));
        expect(controller.totalItems, equals(1));
      });

      test('should update item', () {
        // Arrange
        final item = TestHelpers.createMockCustomer();
        final updatedItem = TestHelpers.createMockCustomer();
        updatedItem['name'] = 'Updated Customer';

        controller.addItem(item);

        // Act
        controller.updateItem(updatedItem, (i) => i['id'] == item['id']);

        // Assert
        expect(controller.items, hasLength(1));
        expect(controller.items.first['name'], equals('Updated Customer'));
      });

      test('should remove item', () {
        // Arrange
        final item = TestHelpers.createMockCustomer();
        controller.addItem(item);

        // Act
        controller.removeItem((i) => i['id'] == item['id']);

        // Assert
        expect(controller.items, isEmpty);
        expect(controller.totalItems, equals(0));
      });

      test('should clear all items', () {
        // Arrange
        final items = TestHelpers.createMockCustomers(count: 5);
        for (final item in items) {
          controller.addItem(item);
        }

        // Act
        controller.clearItems();

        // Assert
        expect(controller.items, isEmpty);
        expect(controller.totalItems, equals(0));
        expect(controller.currentPage, equals(1));
        expect(controller.hasMore, isTrue);
        expect(controller.hasError, isFalse);
        expect(controller.errorMessage, isNull);
      });
    });

    group('Page Info', () {
      test('should get page info', () async {
        // Arrange
        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          // Return different data for different pages
          final pageData = TestHelpers.createMockCustomers(count: 10);
          for (int i = 0; i < pageData.length; i++) {
            pageData[i]['id'] = 'page_${page}_customer_${i + 1}';
            pageData[i]['name'] = 'Page $page Customer ${i + 1}';
          }

          return PaginationResult<Map<String, dynamic>>(
            items: pageData,
            totalItems: 50,
            hasMore: page < 3,
            currentPage: page,
            totalPages: 3,
          );
        }

        // Act
        await controller.goToPage(2, mockFetchData);
        final pageInfo = controller.getPageInfo();

        // Assert
        expect(pageInfo.currentPage, equals(2));
        expect(pageInfo.totalPages, equals(3));
        expect(pageInfo.pageSize, equals(20));
        expect(pageInfo.totalItems, equals(50));
        expect(pageInfo.hasPreviousPage, isTrue);
        expect(pageInfo.hasNextPage, isTrue);
        expect(pageInfo.hasMore, isTrue);
      });
    });

    group('Statistics', () {
      test('should get pagination statistics', () async {
        // Arrange
        final mockData = TestHelpers.createMockCustomers(count: 10);
        final mockResult = PaginationResult<Map<String, dynamic>>(
          items: mockData,
          totalItems: 50,
          hasMore: true,
          currentPage: 1,
          totalPages: 3,
        );

        Future<PaginationResult<Map<String, dynamic>>> mockFetchData(
            int page, int limit, String? searchQuery) async {
          return mockResult;
        }

        // Act
        await controller.loadInitialData(mockFetchData);
        final stats = controller.getStats();

        // Assert
        expect(stats.totalItems, equals(50));
        expect(stats.loadedItems, equals(10));
        expect(stats.currentPage, equals(1));
        expect(stats.totalPages, equals(3));
        expect(stats.pageSize, equals(20));
        expect(stats.hasMore, isTrue);
        expect(stats.isLoading, isFalse);
        expect(stats.isLoadingMore, isFalse);
        expect(stats.hasError, isFalse);
      });
    });

    group('Reset', () {
      test('should reset pagination state', () {
        // Arrange
        final item = TestHelpers.createMockCustomer();
        controller.addItem(item);
        controller.setSearchQuery('test query');

        // Act
        controller.reset();

        // Assert
        expect(controller.items, isEmpty);
        expect(controller.isLoading, isFalse);
        expect(controller.isLoadingMore, isFalse);
        expect(controller.searchQuery, isNull);
        expect(controller.currentPage, equals(1));
        expect(controller.totalItems, equals(0));
        expect(controller.hasMore, isTrue);
        expect(controller.hasError, isFalse);
        expect(controller.errorMessage, isNull);
      });
    });
  });
}
