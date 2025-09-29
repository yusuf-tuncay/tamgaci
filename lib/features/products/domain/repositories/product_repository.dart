import '../entities/product.dart';

/// Ürün repository interface'i
abstract class ProductRepository {
  /// Tüm ürünleri getir
  Stream<List<Product>> getAllProducts();

  /// Aktif ürünleri getir
  Stream<List<Product>> getActiveProducts();

  /// ID'ye göre ürün getir
  Future<Product?> getProductById(String id);

  /// SKU'ya göre ürün getir
  Future<Product?> getProductBySku(String sku);

  /// Barkoda göre ürün getir
  Future<Product?> getProductByBarcode(String barcode);

  /// Kategoriye göre ürünleri getir
  Stream<List<Product>> getProductsByCategory(String category);

  /// Depoya göre ürünleri getir
  Stream<List<Product>> getProductsByWarehouse(String warehouseId);

  /// Düşük stoklu ürünleri getir
  Stream<List<Product>> getLowStockProducts();

  /// Stokta olmayan ürünleri getir
  Stream<List<Product>> getOutOfStockProducts();

  /// Depo bazında düşük stoklu ürünleri getir
  Stream<List<Product>> getLowStockProductsByWarehouse(String warehouseId);

  /// Depo bazında stokta olmayan ürünleri getir
  Stream<List<Product>> getOutOfStockProductsByWarehouse(String warehouseId);

  /// Arama yap
  Stream<List<Product>> searchProducts(String query);

  /// Ürün oluştur
  Future<void> createProduct(Product product);

  /// Ürün güncelle
  Future<void> updateProduct(Product product);

  /// Ürün sil
  Future<void> deleteProduct(String id);

  /// Stok miktarını güncelle
  Future<void> updateStockQuantity(String id, int quantity);

  /// Ürün durumunu değiştir
  Future<void> updateProductStatus(String id, bool isActive);

  /// Toplam ürün sayısı
  Future<int> getActiveProductCount();

  /// Toplam stok değeri
  Future<double> getTotalStockValue();

  /// Kategorileri getir
  Stream<List<String>> getCategories();
}
