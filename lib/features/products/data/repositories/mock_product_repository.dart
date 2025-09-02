import 'dart:async';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

/// Web platformu için mock ürün repository'si
class MockProductRepository implements ProductRepository {
  final List<Product> _mockProducts = [
    Product(
      id: 1,
      name: 'iPhone 15 Pro',
      description: 'Apple iPhone 15 Pro 128GB Titanium',
      sku: 'IPH15PRO-128',
      barcode: '1234567890123',
      category: 'Elektronik',
      unitPrice: 89999.99,
      stockQuantity: 15,
      minStockLevel: 5,
      unit: 'Adet',
      taxRate: 20.0,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 2,
      name: 'Samsung Galaxy S24',
      description: 'Samsung Galaxy S24 256GB Phantom Black',
      sku: 'SAMS24-256',
      barcode: '1234567890124',
      category: 'Elektronik',
      unitPrice: 79999.99,
      stockQuantity: 8,
      minStockLevel: 10,
      unit: 'Adet',
      taxRate: 20.0,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 3,
      name: 'MacBook Air M3',
      description: 'Apple MacBook Air M3 13.6" 256GB',
      sku: 'MBA-M3-256',
      barcode: '1234567890125',
      category: 'Bilgisayar',
      unitPrice: 129999.99,
      stockQuantity: 3,
      minStockLevel: 5,
      unit: 'Adet',
      taxRate: 20.0,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 4,
      name: 'Dell XPS 13',
      description: 'Dell XPS 13 13.4" Intel i7 512GB',
      sku: 'DELL-XPS13-512',
      barcode: '1234567890126',
      category: 'Bilgisayar',
      unitPrice: 89999.99,
      stockQuantity: 0,
      minStockLevel: 3,
      unit: 'Adet',
      taxRate: 20.0,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 5,
      name: 'AirPods Pro',
      description: 'Apple AirPods Pro 2. Nesil',
      sku: 'AIRPODS-PRO2',
      barcode: '1234567890127',
      category: 'Aksesuar',
      unitPrice: 8999.99,
      stockQuantity: 25,
      minStockLevel: 10,
      unit: 'Adet',
      taxRate: 20.0,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 6,
      name: 'Samsung Galaxy Watch 6',
      description: 'Samsung Galaxy Watch 6 44mm',
      sku: 'SAMS-WATCH6-44',
      barcode: '1234567890128',
      category: 'Aksesuar',
      unitPrice: 5999.99,
      stockQuantity: 12,
      minStockLevel: 8,
      unit: 'Adet',
      taxRate: 20.0,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Stream<List<Product>> getActiveProducts() {
    return Stream.value(_mockProducts.where((p) => p.isActive).toList());
  }

  @override
  Stream<List<Product>> getLowStockProducts() {
    return Stream.value(_mockProducts.where((p) => p.isLowStock).toList());
  }

  @override
  Stream<List<Product>> getOutOfStockProducts() {
    return Stream.value(
        _mockProducts.where((p) => p.stockQuantity <= 0).toList());
  }

  @override
  Stream<List<String>> getCategories() {
    final categories = _mockProducts
        .map((p) => p.category)
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList();
    return Stream.value(categories);
  }

  @override
  Stream<List<Product>> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    final results = _mockProducts.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          (product.description?.toLowerCase().contains(lowercaseQuery) ==
              true) ||
          (product.sku?.toLowerCase().contains(lowercaseQuery) == true) ||
          (product.barcode?.contains(query) == true);
    }).toList();
    return Stream.value(results);
  }

  @override
  Stream<List<Product>> getProductsByCategory(String category) {
    final results =
        _mockProducts.where((product) => product.category == category).toList();
    return Stream.value(results);
  }

  @override
  Future<Product?> getProductById(int id) async {
    try {
      return _mockProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getActiveProductCount() async {
    return _mockProducts.where((p) => p.isActive).length;
  }

  @override
  Future<double> getTotalStockValue() async {
    double total = 0.0;
    for (final product in _mockProducts.where((p) => p.isActive)) {
      total += product.unitPrice * product.stockQuantity;
    }
    return total;
  }

  @override
  Stream<List<Product>> getAllProducts() {
    return Stream.value(_mockProducts);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      return _mockProducts.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    try {
      return _mockProducts.firstWhere((product) => product.sku == sku);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProductStatus(int id, bool isActive) async {
    final index = _mockProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final product = _mockProducts[index];
      final updatedProduct = product.copyWith(
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
      _mockProducts[index] = updatedProduct;
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    // Mock implementation - add to list
    final newProduct = product.copyWith(
      id: _mockProducts.length + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockProducts.add(newProduct);
  }

  @override
  Future<void> updateProduct(Product product) async {
    // Mock implementation - update in list
    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      _mockProducts[index] = updatedProduct;
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    // Mock implementation - remove from list
    _mockProducts.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> updateStockQuantity(int id, int quantity) async {
    // Mock implementation - update stock
    final index = _mockProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final product = _mockProducts[index];
      final updatedProduct = product.copyWith(
        stockQuantity: quantity,
        updatedAt: DateTime.now(),
      );
      _mockProducts[index] = updatedProduct;
    }
  }
}
