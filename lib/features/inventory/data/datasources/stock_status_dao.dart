import 'package:floor/floor.dart';
import '../models/stock_status_entity.dart';

@dao
abstract class StockStatusDao {
  /// Tüm stok durumlarını getir
  @Query('SELECT * FROM stock_status ORDER BY product_name ASC')
  Future<List<StockStatusEntity>> getAllStockStatus();

  /// Ürüne göre stok durumu getir
  @Query('SELECT * FROM stock_status WHERE product_id = :productId')
  Future<StockStatusEntity?> getStockStatusByProduct(int productId);

  /// Depoya göre stok durumları getir
  @Query(
    'SELECT * FROM stock_status WHERE warehouse_id = :warehouseId ORDER BY product_name ASC',
  )
  Future<List<StockStatusEntity>> getStockStatusByWarehouse(int warehouseId);

  /// Kritik stok seviyesindeki ürünleri getir
  @Query(
    'SELECT * FROM stock_status WHERE current_stock <= min_stock ORDER BY current_stock ASC',
  )
  Future<List<StockStatusEntity>> getLowStockItems();

  /// Stok durumu ekle
  @insert
  Future<int> insertStockStatus(StockStatusEntity stockStatus);

  /// Stok durumu güncelle
  @update
  Future<int> updateStockStatus(StockStatusEntity stockStatus);

  /// Stok durumu sil
  @delete
  Future<int> deleteStockStatus(StockStatusEntity stockStatus);

  /// Ürün stok miktarını güncelle
  @Query(
    'UPDATE stock_status SET current_stock = :newStock, updated_at = :updatedAt WHERE product_id = :productId AND warehouse_id = :warehouseId',
  )
  Future<int?> updateStockQuantity(
    int productId,
    int warehouseId,
    int newStock,
    int updatedAt,
  );

  /// Stok durumu sayısını getir
  @Query('SELECT COUNT(*) FROM stock_status')
  Future<int?> getStockStatusCount();

  /// Toplam stok değerini getir
  @Query('SELECT SUM(current_stock * unit_price) FROM stock_status')
  Future<double?> getTotalStockValue();
}
