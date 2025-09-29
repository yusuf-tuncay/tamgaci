import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_product_repository.dart';
import '../../data/repositories/firebase_price_list_repository.dart';
import '../../data/repositories/firebase_tax_rule_repository.dart';
import '../../data/repositories/firebase_product_attribute_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/price_list_repository.dart';
import '../../domain/repositories/tax_rule_repository.dart';
import '../../domain/repositories/product_attribute_repository.dart';
import '../../domain/entities/price_list.dart';
import '../../domain/entities/tax_rule.dart';
import '../../domain/entities/product_attribute.dart';

/// Ürün repository provider'ı - Firebase only
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirebaseProductRepository();
});

/// Fiyat listesi repository provider'ı
final priceListRepositoryProvider = Provider<PriceListRepository>((ref) {
  return FirebasePriceListRepository();
});

/// Vergi kuralı repository provider'ı
final taxRuleRepositoryProvider = Provider<TaxRuleRepository>((ref) {
  return FirebaseTaxRuleRepository();
});

/// Ürün özelliği repository provider'ı
final productAttributeRepositoryProvider =
    Provider<ProductAttributeRepository>((ref) {
  return FirebaseProductAttributeRepository();
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
final productDetailProvider =
    FutureProvider.family<Product?, String>((ref, id) {
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

  /// Hızlı/minimal ürün oluştur (sadece isim)
  Future<Product?> createMinimalProduct(String name) async {
    try {
      final product = Product(
        id: '',
        tenantId: '', // Repository'de set edilecek
        name: name,
        productCode: null,
        sku: null,
        barcode: null,
        gs1Barcode: null,
        description: null,
        category: null,
        purchasePrice: 0,
        salesPrice: 0,
        purchaseCurrency: 'TRY',
        salesCurrency: 'TRY',
        salesTaxRate: 0,
        // criticalStockQuantity is optional; variants control stock
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
      );
      await _repository.createProduct(product);
      // repo.createProduct void dönüyor; yeni ID'yi almak için arama yapalım
      final latest = await _repository.getActiveProducts().first;
      return latest.firstWhere((p) => p.name == name, orElse: () => product);
    } catch (_) {
      return null;
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
  Future<void> deleteProduct(String id) async {
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
  Future<void> updateStockQuantity(String id, int quantity) async {
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

// ========== PRICE LIST PROVIDERS ==========

/// Tüm fiyat listeleri stream provider'ı
final priceListsStreamProvider = StreamProvider<List<PriceList>>((ref) {
  final repository = ref.watch(priceListRepositoryProvider);
  return repository.getActivePriceLists();
});

/// Geçerli fiyat listeleri stream provider'ı
final validPriceListsStreamProvider = StreamProvider<List<PriceList>>((ref) {
  final repository = ref.watch(priceListRepositoryProvider);
  return repository.getValidPriceLists();
});

/// Müşteri fiyat listeleri stream provider'ı
final customerPriceListsStreamProvider =
    StreamProvider.family<List<PriceList>, String>((ref, customerId) {
  final repository = ref.watch(priceListRepositoryProvider);
  return repository.getCustomerPriceLists(customerId);
});

/// Fiyat listesi detay provider'ı
final priceListDetailProvider =
    FutureProvider.family<PriceList?, String>((ref, id) {
  final repository = ref.watch(priceListRepositoryProvider);
  return repository.getPriceListById(id);
});

// ========== TAX RULE PROVIDERS ==========

/// Tüm vergi kuralları stream provider'ı
final taxRulesStreamProvider = StreamProvider<List<TaxRule>>((ref) {
  final repository = ref.watch(taxRuleRepositoryProvider);
  return repository.getActiveTaxRules();
});

/// Geçerli vergi kuralları stream provider'ı
final validTaxRulesStreamProvider = StreamProvider<List<TaxRule>>((ref) {
  final repository = ref.watch(taxRuleRepositoryProvider);
  return repository.getValidTaxRules();
});

/// Ürün vergi kuralları stream provider'ı
final productTaxRulesStreamProvider =
    StreamProvider.family<List<TaxRule>, Map<String, String?>>((ref, params) {
  final repository = ref.watch(taxRuleRepositoryProvider);
  return repository.getValidTaxRulesForProduct(
      params['productId']!, params['categoryId']);
});

/// Müşteri vergi kuralları stream provider'ı
final customerTaxRulesStreamProvider =
    StreamProvider.family<List<TaxRule>, String?>((ref, customerId) {
  final repository = ref.watch(taxRuleRepositoryProvider);
  return repository.getValidTaxRulesForCustomer(customerId);
});

/// Vergi kuralı detay provider'ı
final taxRuleDetailProvider =
    FutureProvider.family<TaxRule?, String>((ref, id) {
  final repository = ref.watch(taxRuleRepositoryProvider);
  return repository.getTaxRuleById(id);
});

// ========== PRODUCT ATTRIBUTE PROVIDERS ==========

/// Tüm ürün özellikleri stream provider'ı
final productAttributesStreamProvider =
    StreamProvider<List<ProductAttribute>>((ref) {
  final repository = ref.watch(productAttributeRepositoryProvider);
  return repository.getActiveProductAttributes();
});

/// Arama yapılabilir özellikler stream provider'ı
final searchableAttributesStreamProvider =
    StreamProvider<List<ProductAttribute>>((ref) {
  final repository = ref.watch(productAttributeRepositoryProvider);
  return repository.getSearchableAttributes();
});

/// Filtrelenebilir özellikler stream provider'ı
final filterableAttributesStreamProvider =
    StreamProvider<List<ProductAttribute>>((ref) {
  final repository = ref.watch(productAttributeRepositoryProvider);
  return repository.getFilterableAttributes();
});

/// Görünür özellikler stream provider'ı
final visibleAttributesStreamProvider =
    StreamProvider<List<ProductAttribute>>((ref) {
  final repository = ref.watch(productAttributeRepositoryProvider);
  return repository.getVisibleAttributes();
});

/// Zorunlu özellikler stream provider'ı
final requiredAttributesStreamProvider =
    StreamProvider<List<ProductAttribute>>((ref) {
  final repository = ref.watch(productAttributeRepositoryProvider);
  return repository.getRequiredAttributes();
});

/// Özellik türüne göre özellikler stream provider'ı
final attributesByTypeStreamProvider =
    StreamProvider.family<List<ProductAttribute>, AttributeType>((ref, type) {
  final repository = ref.watch(productAttributeRepositoryProvider);
  return repository.getProductAttributesByType(type);
});

/// Ürün özelliği detay provider'ı
final productAttributeDetailProvider =
    FutureProvider.family<ProductAttribute?, String>((ref, id) {
  final repository = ref.watch(productAttributeRepositoryProvider);
  return repository.getProductAttributeById(id);
});
