import 'package:flutter/material.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Infinite scroll widget for handling continuous data loading
class InfiniteScroll<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) fetchData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? loadMoreWidget;
  final int pageSize;
  final bool enablePullToRefresh;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final double loadMoreThreshold;
  final String? searchQuery;
  final Future<List<T>> Function(String query, int page, int limit)?
      searchFunction;

  const InfiniteScroll({
    super.key,
    required this.fetchData,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.loadMoreWidget,
    this.pageSize = 20,
    this.enablePullToRefresh = true,
    this.scrollController,
    this.padding,
    this.loadMoreThreshold = 0.8,
    this.searchQuery,
    this.searchFunction,
  });

  @override
  State<InfiniteScroll<T>> createState() => _InfiniteScrollState<T>();
}

class _InfiniteScrollState<T> extends State<InfiniteScroll<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InfiniteScroll<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload if search query changed
    if (oldWidget.searchQuery != widget.searchQuery) {
      _reloadData();
    }
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = maxScroll * widget.loadMoreThreshold;

    if (currentScroll >= maxScroll - delta) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final items = await _fetchData(1);

      setState(() {
        _items.clear();
        _items.addAll(items);
        _currentPage = 1;
        _hasMore = items.length >= widget.pageSize;
        _isLoading = false;
      });

      ErrorLogger.logInfo(
        'Loaded initial data: ${items.length} items',
        context: 'InfiniteScroll',
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ErrorLogger.logError(
        'Error loading initial data',
        error: e,
        context: 'InfiniteScroll',
      );
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final items = await _fetchData(nextPage);

      setState(() {
        _items.addAll(items);
        _currentPage = nextPage;
        _hasMore = items.length >= widget.pageSize;
        _isLoadingMore = false;
      });

      ErrorLogger.logInfo(
        'Loaded more data: ${items.length} items (page $nextPage)',
        context: 'InfiniteScroll',
      );
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });

      ErrorLogger.logError(
        'Error loading more data',
        error: e,
        context: 'InfiniteScroll',
      );
    }
  }

  Future<void> _reloadData() async {
    await _loadInitialData();
  }

  Future<List<T>> _fetchData(int page) async {
    if (widget.searchQuery != null && widget.searchFunction != null) {
      return await widget.searchFunction!(
          widget.searchQuery!, page, widget.pageSize);
    } else {
      return await widget.fetchData(page, widget.pageSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return widget.errorWidget ?? _buildErrorWidget();
    }

    if (_items.isEmpty) {
      return widget.emptyWidget ?? _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: widget.enablePullToRefresh ? _reloadData : () async {},
      child: ListView.separated(
        controller: widget.scrollController ?? _scrollController,
        padding: widget.padding,
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: widget.separatorBuilder ??
            (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return widget.loadMoreWidget ?? _buildLoadMoreWidget();
          }

          return widget.itemBuilder(context, _items[index], index);
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Veriler yüklenirken bir hata oluştu',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _reloadData,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Veri bulunamadı',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Henüz hiç veri eklenmemiş',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: _hasMore
          ? const CircularProgressIndicator()
          : Text(
              'Tüm veriler yüklendi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
    );
  }
}

/// Infinite scroll controller for managing infinite scroll state
class InfiniteScrollController<T> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  List<T> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  String? get errorMessage => _errorMessage;

  /// Load initial data
  Future<void> loadInitialData(
    Future<List<T>> Function(int page, int limit) fetchData, {
    int pageSize = 20,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;

    try {
      final items = await fetchData(1, pageSize);

      _items.clear();
      _items.addAll(items);
      _currentPage = 1;
      _hasMore = items.length >= pageSize;
      _isLoading = false;

      ErrorLogger.logInfo(
        'Loaded initial data: ${items.length} items',
        context: 'InfiniteScrollController',
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;

      ErrorLogger.logError(
        'Error loading initial data',
        error: e,
        context: 'InfiniteScrollController',
      );
    }
  }

  /// Load more data
  Future<void> loadMoreData(
    Future<List<T>> Function(int page, int limit) fetchData, {
    int pageSize = 20,
  }) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;

    try {
      final nextPage = _currentPage + 1;
      final items = await fetchData(nextPage, pageSize);

      _items.addAll(items);
      _currentPage = nextPage;
      _hasMore = items.length >= pageSize;
      _isLoadingMore = false;

      ErrorLogger.logInfo(
        'Loaded more data: ${items.length} items (page $nextPage)',
        context: 'InfiniteScrollController',
      );
    } catch (e) {
      _isLoadingMore = false;

      ErrorLogger.logError(
        'Error loading more data',
        error: e,
        context: 'InfiniteScrollController',
      );
    }
  }

  /// Reload data
  Future<void> reloadData(
    Future<List<T>> Function(int page, int limit) fetchData, {
    int pageSize = 20,
  }) async {
    await loadInitialData(fetchData, pageSize: pageSize);
  }

  /// Add item
  void addItem(T item) {
    _items.insert(0, item);
  }

  /// Update item
  void updateItem(T item, bool Function(T) predicate) {
    final index = _items.indexWhere(predicate);
    if (index != -1) {
      _items[index] = item;
    }
  }

  /// Remove item
  void removeItem(bool Function(T) predicate) {
    _items.removeWhere(predicate);
  }

  /// Clear all items
  void clearItems() {
    _items.clear();
    _currentPage = 1;
    _hasMore = true;
    _hasError = false;
    _errorMessage = null;
  }

  /// Reset infinite scroll state
  void reset() {
    clearItems();
    _isLoading = false;
    _isLoadingMore = false;
  }
}
