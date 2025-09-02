// ========== STOCK DAO ==========
// lib/features/inventory/data/datasources/stock_dao.dart

import 'package:floor/floor.dart';
import '../models/stock_entity.dart';

@dao
abstract class StockDao {
  /// Tüm stokları getir
  @Query('SELECT * FROM stocks ORDER BY updatedAt DESC')
  Future<List<StockEntity>> getAllStocks();

  /// Aktif stokları getir
  @Query('SELECT * FROM stocks WHERE isActive = 1 ORDER BY updatedAt DESC')
  Future<List<StockEntity>> getActiveStocks();

  /// ID'ye göre stok getir
  @Query('SELECT * FROM stocks WHERE id = :id')
  Future<StockEntity?> getStockById(int id);

  /// Ürün ID'sine göre stokları getir
  @Query('SELECT * FROM stocks WHERE productId = :productId AND isActive = 1')
  Future<List<StockEntity>> getStocksByProductId(int productId);

  /// Depo ID'sine göre stokları getir
  @Query('SELECT * FROM stocks WHERE warehouseId = :warehouseId AND isActive = 1')
  Future<List<StockEntity>> getStocksByWarehouseId(int warehouseId);

  /// Ürün ve depo ID'sine göre stok getir
  @Query('SELECT * FROM stocks WHERE productId = :productId AND warehouseId = :warehouseId')
  Future<StockEntity?> getStockByProductAndWarehouse(int productId, int warehouseId);

  /// Düşük stokları getir
  @Query('SELECT * FROM stocks WHERE quantity <= minimumQuantity AND isActive = 1')
  Future<List<StockEntity>> getLowStocks();

  /// Yüksek stokları getir
  @Query('SELECT * FROM stocks WHERE quantity >= maximumQuantity AND isActive = 1')
  Future<List<StockEntity>> getOverstockedItems();

  /// Stok sayısını getir
  @Query('SELECT COUNT(*) FROM stocks')
  Future<int?> getStockCount();

  /// Aktif stok sayısını getir
  @Query('SELECT COUNT(*) FROM stocks WHERE isActive = 1')
  Future<int?> getActiveStockCount();

  /// Düşük stok sayısını getir
  @Query('SELECT COUNT(*) FROM stocks WHERE quantity <= minimumQuantity AND isActive = 1')
  Future<int?> getLowStockCount();

  /// Toplam stok değerini getir
  @Query('SELECT SUM(quantity * unitPrice) FROM stocks WHERE isActive = 1')
  Future<double?> getTotalStockValue();

  /// Stok ekle
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertStock(StockEntity stock);

  /// Stok güncelle
  @Update()
  Future<void> updateStock(StockEntity stock);

  /// Stok sil
  @delete
  Future<void> deleteStock(StockEntity stock);

  /// ID'ye göre stok sil
  @Query('DELETE FROM stocks WHERE id = :id')
  Future<void> deleteStockById(int id);

  /// Ürün ID'sine göre stokları sil
  @Query('DELETE FROM stocks WHERE productId = :productId')
  Future<void> deleteStocksByProductId(int productId);

  /// Depo ID'sine göre stokları sil
  @Query('DELETE FROM stocks WHERE warehouseId = :warehouseId')
  Future<void> deleteStocksByWarehouseId(int warehouseId);

  /// Stok miktarını güncelle
  @Query('UPDATE stocks SET quantity = :quantity, updatedAt = :updatedAt WHERE id = :id')
  Future<void> updateStockQuantity(int id, double quantity, DateTime updatedAt);

  /// Stok fiyatını güncelle
  @Query('UPDATE stocks SET unitPrice = :unitPrice, updatedAt = :updatedAt WHERE id = :id')
  Future<void> updateStockPrice(int id, double unitPrice, DateTime updatedAt);
}
