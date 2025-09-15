import 'package:flutter/material.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Pagination controller for managing pagination state and operations
class PaginationController<T> extends ChangeNotifier {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;
  int _totalItems = 0;
  int _pageSize = 20;
  String? _searchQuery;

  /// Get current items
  List<T> get items => List.unmodifiable(_items);

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get loading more state
  bool get isLoadingMore => _isLoadingMore;

  /// Get error state
  bool get hasError => _hasError;

  /// Get has more data state
  bool get hasMore => _hasMore;

  /// Get current page
  int get currentPage => _currentPage;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get total items count
  int get totalItems => _totalItems;

  /// Get page size
  int get pageSize => _pageSize;

  /// Get search query
  String? get searchQuery => _searchQuery;

  /// Get total pages
  int get totalPages => (_totalItems / _pageSize).ceil();

  /// Get has previous page
  bool get hasPreviousPage => _currentPage > 1;

  /// Get has next page
  bool get hasNextPage => _currentPage < totalPages;

  /// Set page size
  void setPageSize(int size) {
    if (size != _pageSize) {
      _pageSize = size;
      // _reloadData(); // Method not implemented yet
    }
  }

  /// Set search query
  void setSearchQuery(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      // _reloadData(); // Method not implemented yet
    }
  }

  /// Load initial data
  Future<void> loadInitialData(
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await fetchData(1, _pageSize, _searchQuery);

      _items.clear();
      _items.addAll(result.items);
      _currentPage = 1;
      _totalItems = result.totalItems;
      _hasMore = result.hasMore;
      _isLoading = false;
      notifyListeners();

      ErrorLogger.logInfo(
        'Loaded initial data: ${result.items.length} items (total: ${result.totalItems})',
        context: 'PaginationController',
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      ErrorLogger.logError(
        'Error loading initial data',
        error: e,
        context: 'PaginationController',
      );
    }
  }

  /// Load more data
  Future<void> loadMoreData(
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await fetchData(nextPage, _pageSize, _searchQuery);

      _items.addAll(result.items);
      _currentPage = nextPage;
      _totalItems = result.totalItems;
      _hasMore = result.hasMore;
      _isLoadingMore = false;
      notifyListeners();

      ErrorLogger.logInfo(
        'Loaded more data: ${result.items.length} items (page $nextPage)',
        context: 'PaginationController',
      );
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();

      ErrorLogger.logError(
        'Error loading more data',
        error: e,
        context: 'PaginationController',
      );
    }
  }

  /// Go to specific page
  Future<void> goToPage(
    int page,
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    if (page < 1 || page > totalPages || page == _currentPage) return;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await fetchData(page, _pageSize, _searchQuery);

      _items.clear();
      _items.addAll(result.items);
      _currentPage = page;
      _totalItems = result.totalItems;
      _hasMore = result.hasMore;
      _isLoading = false;
      notifyListeners();

      ErrorLogger.logInfo(
        'Navigated to page $page: ${result.items.length} items',
        context: 'PaginationController',
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      ErrorLogger.logError(
        'Error navigating to page $page',
        error: e,
        context: 'PaginationController',
      );
    }
  }

  /// Go to next page
  Future<void> nextPage(
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    if (hasNextPage) {
      await goToPage(_currentPage + 1, fetchData);
    }
  }

  /// Go to previous page
  Future<void> previousPage(
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    if (hasPreviousPage) {
      await goToPage(_currentPage - 1, fetchData);
    }
  }

  /// Go to first page
  Future<void> firstPage(
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    await goToPage(1, fetchData);
  }

  /// Go to last page
  Future<void> lastPage(
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    await goToPage(totalPages, fetchData);
  }

  /// Reload current data
  Future<void> reloadData(
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    await loadInitialData(fetchData);
  }

  /// Refresh data (pull to refresh)
  Future<void> refreshData(
    Future<PaginationResult<T>> Function(
            int page, int limit, String? searchQuery)
        fetchData,
  ) async {
    await reloadData(fetchData);
  }

  /// Add item to the beginning of the list
  void addItem(T item) {
    _items.insert(0, item);
    _totalItems++;
    notifyListeners();
  }

  /// Add item at specific index
  void addItemAt(T item, int index) {
    if (index >= 0 && index <= _items.length) {
      _items.insert(index, item);
      _totalItems++;
      notifyListeners();
    }
  }

  /// Update item
  void updateItem(T item, bool Function(T) predicate) {
    final index = _items.indexWhere(predicate);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  /// Remove item
  void removeItem(bool Function(T) predicate) {
    final removedCount = _items.where(predicate).length;
    _items.removeWhere(predicate);
    _totalItems -= removedCount;
    notifyListeners();
  }

  /// Remove item at specific index
  void removeItemAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _totalItems--;
      notifyListeners();
    }
  }

  /// Clear all items
  void clearItems() {
    _items.clear();
    _currentPage = 1;
    _totalItems = 0;
    _hasMore = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset pagination state
  void reset() {
    clearItems();
    _isLoading = false;
    _isLoadingMore = false;
    _searchQuery = null;
    notifyListeners();
  }

  /// Get items for current page
  List<T> getCurrentPageItems() {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    return _items.sublist(
      startIndex,
      endIndex > _items.length ? _items.length : endIndex,
    );
  }

  /// Get page info
  PageInfo getPageInfo() {
    return PageInfo(
      currentPage: _currentPage,
      totalPages: totalPages,
      pageSize: _pageSize,
      totalItems: _totalItems,
      hasPreviousPage: hasPreviousPage,
      hasNextPage: hasNextPage,
      hasMore: _hasMore,
    );
  }

  /// Get pagination statistics
  PaginationStats getStats() {
    return PaginationStats(
      totalItems: _totalItems,
      loadedItems: _items.length,
      currentPage: _currentPage,
      totalPages: totalPages,
      pageSize: _pageSize,
      hasMore: _hasMore,
      isLoading: _isLoading,
      isLoadingMore: _isLoadingMore,
      hasError: _hasError,
    );
  }
}

/// Pagination result
class PaginationResult<T> {
  final List<T> items;
  final int totalItems;
  final bool hasMore;
  final int currentPage;
  final int totalPages;

  const PaginationResult({
    required this.items,
    required this.totalItems,
    required this.hasMore,
    required this.currentPage,
    required this.totalPages,
  });
}

/// Page info
class PageInfo {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalItems;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final bool hasMore;

  const PageInfo({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalItems,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.hasMore,
  });

  @override
  String toString() {
    return 'PageInfo(page: $currentPage/$totalPages, items: $totalItems, hasMore: $hasMore)';
  }
}

/// Pagination statistics
class PaginationStats {
  final int totalItems;
  final int loadedItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;

  const PaginationStats({
    required this.totalItems,
    required this.loadedItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasError,
  });

  @override
  String toString() {
    return 'PaginationStats(loaded: $loadedItems/$totalItems, page: $currentPage/$totalPages)';
  }
}
