import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/database/tamgaci_database.dart';

/// Ürün repository provider'ı
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  try {
    final databaseAsync = ref.watch(databaseProvider);
    return databaseAsync.when(
      data: (database) => ProductRepositoryImpl(database.productDao),
      loading: () => throw Exception('Database loading'),
      error: (error, stack) => throw Exception('Database error: $error'),
    );
  } catch (e) {
    throw Exception('Product repository initialization failed: $e');
  }
});

/// Tüm ürünler stream provider'ı
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getActiveProducts();
});

/// Düşük stoklu ürünler stream provider'ı
final lowStockProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getLowStockProducts();
});

/// Stokta olmayan ürünler stream provider'ı
final outOfStockProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getOutOfStockProducts();
});

/// Kategoriler stream provider'ı
final productCategoriesStreamProvider = StreamProvider<List<String>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getCategories();
});

/// Ürün arama provider'ı
final productSearchProvider =
    StreamProvider.family<List<Product>, String>((ref, query) {
  final repository = ref.watch(productRepositoryProvider);
  if (query.isEmpty) {
    return repository.getActiveProducts();
  }
  return repository.searchProducts(query);
});

/// Kategoriye göre ürünler provider'ı
final productsByCategoryProvider =
    StreamProvider.family<List<Product>, String>((ref, category) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsByCategory(category);
});

/// Ürün detay provider'ı
final productDetailProvider = FutureProvider.family<Product?, int>((ref, id) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});

/// Aktif ürün sayısı provider'ı
final activeProductCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getActiveProductCount();
});

/// Toplam stok değeri provider'ı
final totalStockValueProvider = FutureProvider<double>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getTotalStockValue();
});

/// Ürün işlemleri provider'ı
final productOperationsProvider =
    StateNotifierProvider<ProductOperations, ProductOperationsState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductOperations(repository);
});

/// Ürün operasyonları state sınıfı
class ProductOperationsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<Product> products;

  const ProductOperationsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.products = const [],
  });

  ProductOperationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<Product>? products,
  }) {
    return ProductOperationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      products: products ?? this.products,
    );
  }
}

/// Ürün operasyonları notifier'ı
class ProductOperations extends StateNotifier<ProductOperationsState> {
  final ProductRepository _repository;

  ProductOperations(this._repository) : super(const ProductOperationsState());

  /// Ürünleri yükle
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final products = await _repository.getActiveProducts().first;
      state = state.copyWith(
        isLoading: false,
        products: products,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ürünler yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Ürün oluştur
  Future<void> createProduct(Product product) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.createProduct(product);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Ürün başarıyla oluşturuldu',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ürün oluşturulamadı: $e',
      );
    }
  }

  /// Ürün güncelle
  Future<void> updateProduct(Product product) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateProduct(product);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Ürün başarıyla güncellendi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ürün güncellenemedi: $e',
      );
    }
  }

  /// Ürün sil
  Future<void> deleteProduct(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteProduct(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Ürün başarıyla silindi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ürün silinemedi: $e',
      );
    }
  }

  /// Stok miktarını güncelle
  Future<void> updateStockQuantity(int id, int quantity) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateStockQuantity(id, quantity);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok miktarı başarıyla güncellendi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok miktarı güncellenemedi: $e',
      );
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Başarı mesajını temizle
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}
