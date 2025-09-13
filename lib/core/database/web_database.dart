// ========== WEB DATABASE IMPLEMENTATION ==========
// lib/core/database/web_database.dart

import 'dart:async';
import 'dart:convert';
import 'package:web/web.dart' as web;
import '../../features/products/data/models/product_entity.dart';
import '../../features/products/data/datasources/product_dao.dart';

/// Web platformu için localStorage tabanlı veritabanı implementasyonu
class WebDatabase {
  static const String _productsKey = 'tamgaci_products';
  // ignore: unused_field
  static const String _customersKey = 'tamgaci_customers';
  // ignore: unused_field
  static const String _invoicesKey = 'tamgaci_invoices';
  // ignore: unused_field
  static const String _expensesKey = 'tamgaci_expenses';
  // ignore: unused_field
  static const String _incomeKey = 'tamgaci_income';

  /// Products'ı localStorage'dan alır
  static List<Map<String, dynamic>> _getProductsData() {
    final data = web.window.localStorage.getItem(_productsKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Products'ı localStorage'a kaydeder
  static void _saveProductsData(List<Map<String, dynamic>> data) {
    web.window.localStorage.setItem(_productsKey, jsonEncode(data));
  }

  /// Veritabanını sıfırlar
  static Future<void> resetDatabase() async {
    web.window.localStorage.clear();
  }
}

/// Web platformu için Product DAO implementasyonu
class WebProductDao implements ProductDao {
  @override
  Stream<List<ProductEntity>> getAllProducts() async* {
    final data = WebDatabase._getProductsData();
    final products = data.map((item) => ProductEntity.fromMap(item)).toList();
    yield products;
  }

  @override
  Stream<List<ProductEntity>> getActiveProducts() async* {
    final data = WebDatabase._getProductsData();
    final products = data
        .map((item) => ProductEntity.fromMap(item))
        .where((product) => product.isActive)
        .toList();
    yield products;
  }

  @override
  Stream<List<ProductEntity>> getLowStockProducts() async* {
    final products = await getActiveProducts().first;
    final lowStockProducts = products
        .where((product) => product.stockQuantity <= product.minStockLevel)
        .toList();
    yield lowStockProducts;
  }

  @override
  Stream<List<ProductEntity>> getOutOfStockProducts() async* {
    final products = await getActiveProducts().first;
    final outOfStockProducts =
        products.where((product) => product.stockQuantity <= 0).toList();
    yield outOfStockProducts;
  }

  @override
  Stream<List<String>> getCategories() async* {
    final products = await getActiveProducts().first;
    final categories = products
        .map((p) => p.category)
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList();
    yield categories;
  }

  @override
  Stream<List<ProductEntity>> searchProducts(String query) async* {
    final products = await getActiveProducts().first;
    final lowercaseQuery = query.toLowerCase();

    final results = products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          (product.description?.toLowerCase().contains(lowercaseQuery) ==
              true) ||
          (product.sku?.toLowerCase().contains(lowercaseQuery) == true) ||
          (product.barcode?.contains(query) == true);
    }).toList();

    yield results;
  }

  @override
  Stream<List<ProductEntity>> getProductsByCategory(String category) async* {
    final products = await getActiveProducts().first;
    final results =
        products.where((product) => product.category == category).toList();
    yield results;
  }

  @override
  Future<ProductEntity?> getProductById(int id) async {
    final data = WebDatabase._getProductsData();
    final productData = data.where((item) => item['id'] == id).firstOrNull;
    return productData != null ? ProductEntity.fromMap(productData) : null;
  }

  @override
  Future<int> getActiveProductCount() async {
    final products = await getActiveProducts().first;
    return products.length;
  }

  @override
  Future<double?> getTotalStockValue() async {
    final products = await getActiveProducts().first;
    double total = 0.0;
    for (final product in products) {
      total += product.unitPrice * product.stockQuantity;
    }
    return total;
  }

  @override
  Future<ProductEntity?> getProductBySku(String sku) async {
    final data = WebDatabase._getProductsData();
    final productData = data.where((item) => item['sku'] == sku).firstOrNull;
    return productData != null ? ProductEntity.fromMap(productData) : null;
  }

  @override
  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    final data = WebDatabase._getProductsData();
    final productData =
        data.where((item) => item['barcode'] == barcode).firstOrNull;
    return productData != null ? ProductEntity.fromMap(productData) : null;
  }

  @override
  Future<int> insertProduct(ProductEntity product) async {
    final data = WebDatabase._getProductsData();

    // Yeni ID oluştur
    final newId = data.isEmpty
        ? 1
        : data
                .map((item) => item['id'] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final newProduct = product.copyWith(id: newId);
    data.add(newProduct.toMap());

    WebDatabase._saveProductsData(data);
    return newId;
  }

  @override
  Future<int> updateProduct(ProductEntity product) async {
    final data = WebDatabase._getProductsData();
    final index = data.indexWhere((item) => item['id'] == product.id);

    if (index != -1) {
      data[index] = product.toMap();
      WebDatabase._saveProductsData(data);
    }
    return 1; // Başarılı güncelleme sayısı
  }

  @override
  Future<int> deleteProduct(ProductEntity product) async {
    final data = WebDatabase._getProductsData();
    final initialLength = data.length;
    data.removeWhere((item) => item['id'] == product.id);
    WebDatabase._saveProductsData(data);
    return initialLength > data.length ? 1 : 0; // Silinen kayıt sayısı
  }

  @override
  Future<void> updateStockQuantity(int id, int quantity, int updatedAt) async {
    final product = await getProductById(id);
    if (product != null) {
      final updatedProduct = product.copyWith(
        stockQuantity: quantity,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      );
      await updateProduct(updatedProduct);
    }
  }

  @override
  Future<void> updateProductStatus(int id, int isActive, int updatedAt) async {
    final product = await getProductById(id);
    if (product != null) {
      final updatedProduct = product.copyWith(
        isActive: isActive == 1,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      );
      await updateProduct(updatedProduct);
    }
  }
}

/// Web platformu için mock veri ekleme
class WebDatabaseInitializer {
  static Future<void> initializeWithMockData() async {
    final productDao = WebProductDao();

    // Eğer hiç ürün yoksa mock veri ekle
    final products = await productDao.getAllProducts().first;
    if (products.isEmpty) {
      await _addMockProducts(productDao);
    }
  }

  static Future<void> _addMockProducts(WebProductDao productDao) async {
    final mockProducts = [
      ProductEntity(
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
      ProductEntity(
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
      ProductEntity(
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
      ProductEntity(
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
      ProductEntity(
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
      ProductEntity(
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

    for (final product in mockProducts) {
      await productDao.insertProduct(product);
    }
  }
}
