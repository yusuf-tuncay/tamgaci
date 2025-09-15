// ========== BASE PROVIDER ==========
// lib/core/providers/base_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Base state class for all providers
abstract class BaseState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const BaseState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  BaseState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  });
}

/// Base notifier class for all providers
abstract class BaseNotifier<T extends BaseState> extends StateNotifier<T> {
  BaseNotifier(super.initialState);

  /// Set loading state
  void setLoading(bool loading) {
    state = _updateState(
        isLoading: loading, errorMessage: null, successMessage: null);
  }

  /// Set error state
  void setError(String error) {
    state = _updateState(
        isLoading: false, errorMessage: error, successMessage: null);
    ErrorLogger.logError(
      'Provider error: $error',
      context: runtimeType.toString(),
    );
  }

  /// Set success state
  void setSuccess(String message) {
    state = _updateState(
        isLoading: false, errorMessage: null, successMessage: message);
    ErrorLogger.logInfo(
      'Provider success: $message',
      context: runtimeType.toString(),
    );
  }

  /// Clear messages
  void clearMessages() {
    state = _updateState(errorMessage: null, successMessage: null);
  }

  /// Update state helper method
  T _updateState({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return state.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    ) as T;
  }

  /// Handle async operation with error handling
  Future<void> handleAsyncOperation(
    Future<void> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      setLoading(true);
      await operation();
      if (successMessage != null) {
        setSuccess(successMessage);
      } else {
        setLoading(false);
      }
    } catch (e) {
      final error = errorMessage ?? 'Bir hata oluştu: $e';
      setError(error);
      ErrorLogger.logError(
        'Async operation failed',
        error: e,
        context: runtimeType.toString(),
      );
    }
  }
}

/// Base list state class
abstract class BaseListState<T> extends BaseState {
  final List<T> items;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;

  const BaseListState({
    super.isLoading,
    super.errorMessage,
    super.successMessage,
    this.items = const [],
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery,
  });

  @override
  BaseListState<T> copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<T>? items,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
  });
}

/// Base list notifier class
abstract class BaseListNotifier<T, S extends BaseListState<T>>
    extends BaseNotifier<S> {
  BaseListNotifier(super.initialState);

  /// Load items
  Future<void> loadItems({bool refresh = false}) async {
    await handleAsyncOperation(
      () async {
        if (refresh) {
          state = _updateListState(
            items: [],
            currentPage: 1,
            hasMore: true,
            searchQuery: null,
          );
        }

        final newItems = await fetchItems(
          page: state.currentPage,
          searchQuery: state.searchQuery,
        );

        state = _updateListState(
          items: refresh ? newItems : [...state.items, ...newItems],
          hasMore: newItems.length >= 20, // Assuming 20 items per page
          currentPage: state.currentPage + 1,
        );
      },
      loadingMessage: 'Veriler yükleniyor...',
    );
  }

  /// Load more items
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadItems();
  }

  /// Refresh items
  Future<void> refresh() async {
    await loadItems(refresh: true);
  }

  /// Search items
  Future<void> search(String query) async {
    await handleAsyncOperation(
      () async {
        state = _updateListState(
          items: [],
          currentPage: 1,
          hasMore: true,
          searchQuery: query,
        );

        final newItems = await fetchItems(
          page: 1,
          searchQuery: query,
        );

        state = _updateListState(
          items: newItems,
          hasMore: newItems.length >= 20,
          currentPage: 2,
        );
      },
      loadingMessage: 'Aranıyor...',
    );
  }

  /// Clear search
  Future<void> clearSearch() async {
    await search('');
  }

  /// Add item
  Future<void> addItem(T item) async {
    await handleAsyncOperation(
      () async {
        await createItem(item);
        state = _updateListState(
          items: [item, ...state.items],
        );
      },
      successMessage: 'Öğe başarıyla eklendi',
    );
  }

  /// Update item
  Future<void> updateItem(T item) async {
    await handleAsyncOperation(
      () async {
        await updateItemInRepository(item);
        final updatedItems =
            state.items.map((i) => isSameItem(i, item) ? item : i).toList();
        state = _updateListState(items: updatedItems);
      },
      successMessage: 'Öğe başarıyla güncellendi',
    );
  }

  /// Delete item
  Future<void> deleteItem(T item) async {
    await handleAsyncOperation(
      () async {
        await deleteItemFromRepository(item);
        state = _updateListState(
          items: state.items.where((i) => !isSameItem(i, item)).toList(),
        );
      },
      successMessage: 'Öğe başarıyla silindi',
    );
  }

  /// Update list state helper method
  S _updateListState({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<T>? items,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
  }) {
    return state.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      items: items,
      hasMore: hasMore,
      currentPage: currentPage,
      searchQuery: searchQuery,
    ) as S;
  }

  /// Fetch items from repository (to be implemented by concrete classes)
  Future<List<T>> fetchItems({
    int page = 1,
    String? searchQuery,
  });

  /// Create item in repository (to be implemented by concrete classes)
  Future<void> createItem(T item);

  /// Update item in repository (to be implemented by concrete classes)
  Future<void> updateItemInRepository(T item);

  /// Delete item from repository (to be implemented by concrete classes)
  Future<void> deleteItemFromRepository(T item);

  /// Check if two items are the same (to be implemented by concrete classes)
  bool isSameItem(T item1, T item2);
}

/// Base form state class
abstract class BaseFormState extends BaseState {
  final bool isEditing;
  final bool isValid;

  const BaseFormState({
    super.isLoading,
    super.errorMessage,
    super.successMessage,
    this.isEditing = false,
    this.isValid = false,
  });

  @override
  BaseFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isEditing,
    bool? isValid,
  });
}

/// Base form notifier class
abstract class BaseFormNotifier<T, S extends BaseFormState>
    extends BaseNotifier<S> {
  BaseFormNotifier(super.initialState);

  /// Initialize form for editing
  Future<void> initializeForEdit(T item) async {
    await handleAsyncOperation(
      () async {
        await loadItemForEdit(item);
        state = _updateFormState(isEditing: true, isValid: true);
      },
      loadingMessage: 'Form yükleniyor...',
    );
  }

  /// Initialize form for creating
  void initializeForCreate() {
    state = _updateFormState(isEditing: false, isValid: false);
  }

  /// Save form
  Future<void> saveForm(T item) async {
    await handleAsyncOperation(
      () async {
        if (state.isEditing) {
          await updateItem(item);
        } else {
          await createItem(item);
        }
      },
      successMessage:
          state.isEditing ? 'Başarıyla güncellendi' : 'Başarıyla oluşturuldu',
    );
  }

  /// Validate form
  void validateForm(T item) {
    final isValid = validateItem(item);
    state = _updateFormState(isValid: isValid);
  }

  /// Reset form
  void resetForm() {
    state = _updateFormState(
      isLoading: false,
      errorMessage: null,
      successMessage: null,
      isEditing: false,
      isValid: false,
    );
  }

  /// Update form state helper method
  S _updateFormState({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isEditing,
    bool? isValid,
  }) {
    return state.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isEditing: isEditing,
      isValid: isValid,
    ) as S;
  }

  /// Load item for editing (to be implemented by concrete classes)
  Future<void> loadItemForEdit(T item);

  /// Create item (to be implemented by concrete classes)
  Future<void> createItem(T item);

  /// Update item (to be implemented by concrete classes)
  Future<void> updateItem(T item);

  /// Validate item (to be implemented by concrete classes)
  bool validateItem(T item);
}

/// Base detail state class
abstract class BaseDetailState<T> extends BaseState {
  final T? item;
  final bool isLoaded;

  const BaseDetailState({
    super.isLoading,
    super.errorMessage,
    super.successMessage,
    this.item,
    this.isLoaded = false,
  });

  @override
  BaseDetailState<T> copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    T? item,
    bool? isLoaded,
  });
}

/// Base detail notifier class
abstract class BaseDetailNotifier<T, S extends BaseDetailState<T>>
    extends BaseNotifier<S> {
  BaseDetailNotifier(super.initialState);

  /// Load item by ID
  Future<void> loadItem(String id) async {
    await handleAsyncOperation(
      () async {
        final item = await fetchItemById(id);
        state = _updateDetailState(item: item, isLoaded: true);
      },
      loadingMessage: 'Veriler yükleniyor...',
    );
  }

  /// Refresh item
  Future<void> refreshItem() async {
    if (state.item != null) {
      final itemId = getItemId(state.item as T);
      await loadItem(itemId);
    }
  }

  /// Update item
  Future<void> updateItem(T item) async {
    await handleAsyncOperation(
      () async {
        await updateItemInRepository(item);
        state = _updateDetailState(item: item);
      },
      successMessage: 'Başarıyla güncellendi',
    );
  }

  /// Delete item
  Future<void> deleteItem() async {
    if (state.item == null) return;

    await handleAsyncOperation(
      () async {
        await deleteItemFromRepository(state.item as T);
        state = _updateDetailState(item: null, isLoaded: false);
      },
      successMessage: 'Başarıyla silindi',
    );
  }

  /// Update detail state helper method
  S _updateDetailState({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    T? item,
    bool? isLoaded,
  }) {
    return state.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      item: item,
      isLoaded: isLoaded,
    ) as S;
  }

  /// Fetch item by ID (to be implemented by concrete classes)
  Future<T> fetchItemById(String id);

  /// Update item in repository (to be implemented by concrete classes)
  Future<void> updateItemInRepository(T item);

  /// Delete item from repository (to be implemented by concrete classes)
  Future<void> deleteItemFromRepository(T item);

  /// Get item ID (to be implemented by concrete classes)
  String getItemId(T item);
}

/// Provider utilities
class ProviderUtils {
  /// Create a provider with error handling
  static Provider<T> createProvider<T>(
    T Function() create, {
    String? name,
  }) {
    return Provider<T>((ref) {
      try {
        return create();
      } catch (e) {
        ErrorLogger.logError(
          'Error creating provider: ${name ?? T.toString()}',
          error: e,
          context: 'ProviderUtils',
        );
        rethrow;
      }
    });
  }

  /// Create a state notifier provider with error handling
  static StateNotifierProvider<T, S>
      createStateNotifierProvider<T extends StateNotifier<S>, S>(
    T Function() create, {
    String? name,
  }) {
    return StateNotifierProvider<T, S>((ref) {
      try {
        return create();
      } catch (e) {
        ErrorLogger.logError(
          'Error creating state notifier provider: ${name ?? T.toString()}',
          error: e,
          context: 'ProviderUtils',
        );
        rethrow;
      }
    });
  }

  /// Create a future provider with error handling
  static FutureProvider<T> createFutureProvider<T>(
    Future<T> Function() create, {
    String? name,
  }) {
    return FutureProvider<T>((ref) async {
      try {
        return await create();
      } catch (e) {
        ErrorLogger.logError(
          'Error creating future provider: ${name ?? T.toString()}',
          error: e,
          context: 'ProviderUtils',
        );
        rethrow;
      }
    });
  }

  /// Create a stream provider with error handling
  static StreamProvider<T> createStreamProvider<T>(
    Stream<T> Function() create, {
    String? name,
  }) {
    return StreamProvider<T>((ref) {
      try {
        return create();
      } catch (e) {
        ErrorLogger.logError(
          'Error creating stream provider: ${name ?? T.toString()}',
          error: e,
          context: 'ProviderUtils',
        );
        rethrow;
      }
    });
  }
}
