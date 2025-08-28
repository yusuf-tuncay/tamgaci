import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_dao.dart';
import '../models/product_entity.dart';

/// Ürün repository implementasyonu
class ProductRepositoryImpl implements ProductRepository {
  final ProductDao _productDao;

  ProductRepositoryImpl(this._productDao);

  @override
  Stream<List<Product>> getAllProducts() {
    return _productDao.getAllProducts().map(
          (entities) =>
              entities.map((entity) => _mapEntityToProduct(entity)).toList(),
        );
  }

  @override
  Stream<List<Product>> getActiveProducts() {
    return _productDao.getActiveProducts().map(
          (entities) =>
              entities.map((entity) => _mapEntityToProduct(entity)).toList(),
        );
  }

  @override
  Future<Product?> getProductById(int id) async {
    final entity = await _productDao.getProductById(id);
    return entity != null ? _mapEntityToProduct(entity) : null;
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    final entity = await _productDao.getProductBySku(sku);
    return entity != null ? _mapEntityToProduct(entity) : null;
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final entity = await _productDao.getProductByBarcode(barcode);
    return entity != null ? _mapEntityToProduct(entity) : null;
  }

  @override
  Stream<List<Product>> getProductsByCategory(String category) {
    return _productDao.getProductsByCategory(category).map(
          (entities) =>
              entities.map((entity) => _mapEntityToProduct(entity)).toList(),
        );
  }

  @override
  Stream<List<Product>> getLowStockProducts() {
    return _productDao.getLowStockProducts().map(
          (entities) =>
              entities.map((entity) => _mapEntityToProduct(entity)).toList(),
        );
  }

  @override
  Stream<List<Product>> getOutOfStockProducts() {
    return _productDao.getOutOfStockProducts().map(
          (entities) =>
              entities.map((entity) => _mapEntityToProduct(entity)).toList(),
        );
  }

  @override
  Stream<List<Product>> searchProducts(String query) {
    return _productDao.searchProducts(query).map(
          (entities) =>
              entities.map((entity) => _mapEntityToProduct(entity)).toList(),
        );
  }

  @override
  Future<void> createProduct(Product product) async {
    final entity = _mapProductToEntity(product);
    await _productDao.insertProduct(entity);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final entity = _mapProductToEntity(product);
    await _productDao.updateProduct(entity);
  }

  @override
  Future<void> deleteProduct(int id) async {
    final product = await _productDao.getProductById(id);
    if (product != null) {
      await _productDao.deleteProduct(product);
    }
  }

  @override
  Future<void> updateStockQuantity(int id, int quantity) async {
    final now = DateTime.now();
    await _productDao.updateStockQuantity(
      id,
      quantity,
      now.millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> updateProductStatus(int id, bool isActive) async {
    final now = DateTime.now();
    await _productDao.updateProductStatus(
      id,
      isActive ? 1 : 0,
      now.millisecondsSinceEpoch,
    );
  }

  @override
  Future<int> getActiveProductCount() async {
    final count = await _productDao.getActiveProductCount();
    return count ?? 0;
  }

  @override
  Future<double> getTotalStockValue() async {
    final value = await _productDao.getTotalStockValue();
    return value ?? 0.0;
  }

  @override
  Stream<List<String>> getCategories() {
    return _productDao.getCategories();
  }

  /// Entity'den Product'a dönüştürme
  Product _mapEntityToProduct(ProductEntity entity) {
    return Product(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      sku: entity.sku,
      barcode: entity.barcode,
      category: entity.category,
      unitPrice: entity.unitPrice,
      stockQuantity: entity.stockQuantity,
      minStockLevel: entity.minStockLevel,
      unit: entity.unit,
      taxRate: entity.taxRate,
      isActive: entity.isActive,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Product'tan Entity'ye dönüştürme
  ProductEntity _mapProductToEntity(Product product) {
    return ProductEntity(
      id: product.id,
      name: product.name,
      description: product.description,
      sku: product.sku,
      barcode: product.barcode,
      category: product.category,
      unitPrice: product.unitPrice,
      stockQuantity: product.stockQuantity,
      minStockLevel: product.minStockLevel,
      unit: product.unit,
      taxRate: product.taxRate,
      isActive: product.isActive,
      imageUrl: product.imageUrl,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
