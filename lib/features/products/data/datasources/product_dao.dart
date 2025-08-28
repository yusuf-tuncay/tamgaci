import 'package:floor/floor.dart';
import '../models/product_entity.dart';

/// Ürün veri erişim nesnesi
@dao
abstract class ProductDao {
  /// Tüm ürünleri getir
  @Query('SELECT * FROM products ORDER BY name ASC')
  Stream<List<ProductEntity>> getAllProducts();

  /// Aktif ürünleri getir
  @Query('SELECT * FROM products WHERE is_active = 1 ORDER BY name ASC')
  Stream<List<ProductEntity>> getActiveProducts();

  /// ID'ye göre ürün getir
  @Query('SELECT * FROM products WHERE id = :id')
  Future<ProductEntity?> getProductById(int id);

  /// SKU'ya göre ürün getir
  @Query('SELECT * FROM products WHERE sku = :sku')
  Future<ProductEntity?> getProductBySku(String sku);

  /// Barkoda göre ürün getir
  @Query('SELECT * FROM products WHERE barcode = :barcode')
  Future<ProductEntity?> getProductByBarcode(String barcode);

  /// Kategoriye göre ürünleri getir
  @Query(
    'SELECT * FROM products WHERE category = :category AND is_active = 1 ORDER BY name ASC',
  )
  Stream<List<ProductEntity>> getProductsByCategory(String category);

  /// Düşük stoklu ürünleri getir
  @Query(
    'SELECT * FROM products WHERE stock_quantity <= min_stock_level AND is_active = 1 ORDER BY stock_quantity ASC',
  )
  Stream<List<ProductEntity>> getLowStockProducts();

  /// Stokta olmayan ürünleri getir
  @Query(
    'SELECT * FROM products WHERE stock_quantity = 0 AND is_active = 1 ORDER BY name ASC',
  )
  Stream<List<ProductEntity>> getOutOfStockProducts();

  /// Arama yap
  @Query('''
    SELECT * FROM products 
    WHERE (name LIKE '%' || :query || '%' OR 
           description LIKE '%' || :query || '%' OR 
           sku LIKE '%' || :query || '%' OR 
           barcode LIKE '%' || :query || '%')
    AND is_active = 1
    ORDER BY name ASC
  ''')
  Stream<List<ProductEntity>> searchProducts(String query);

  /// Ürün ekle
  @Insert()
  Future<int> insertProduct(ProductEntity product);

  /// Ürün güncelle
  @Update()
  Future<int> updateProduct(ProductEntity product);

  /// Ürün sil
  @delete
  Future<int> deleteProduct(ProductEntity product);

  /// Stok miktarını güncelle
  @Query(
    'UPDATE products SET stock_quantity = :quantity, updated_at = :updatedAt WHERE id = :id',
  )
  Future<void> updateStockQuantity(int id, int quantity, int updatedAt);

  /// Ürün durumunu değiştir
  @Query(
    'UPDATE products SET is_active = :isActive, updated_at = :updatedAt WHERE id = :id',
  )
  Future<void> updateProductStatus(int id, int isActive, int updatedAt);

  /// Toplam ürün sayısı
  @Query('SELECT COUNT(*) FROM products WHERE is_active = 1')
  Future<int?> getActiveProductCount();

  /// Toplam stok değeri
  @Query(
    'SELECT SUM(stock_quantity * unit_price) FROM products WHERE is_active = 1',
  )
  Future<double?> getTotalStockValue();

  /// Kategorileri getir
  @Query(
    'SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != "" AND is_active = 1 ORDER BY category ASC',
  )
  Stream<List<String>> getCategories();
}
