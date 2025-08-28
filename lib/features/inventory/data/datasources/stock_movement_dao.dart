import 'package:floor/floor.dart';
import '../models/stock_movement_entity.dart';

@dao
abstract class StockMovementDao {
  /// Tüm stok hareketlerini getir
  @Query('SELECT * FROM stock_movements ORDER BY movement_date DESC')
  Future<List<StockMovementEntity>> getAllStockMovements();

  /// Ürüne göre stok hareketlerini getir
  @Query('SELECT * FROM stock_movements WHERE product_id = :productId ORDER BY movement_date DESC')
  Future<List<StockMovementEntity>> getStockMovementsByProduct(int productId);

  /// Depoya göre stok hareketlerini getir
  @Query('SELECT * FROM stock_movements WHERE warehouse_id = :warehouseId ORDER BY movement_date DESC')
  Future<List<StockMovementEntity>> getStockMovementsByWarehouse(int warehouseId);

  /// Tarih aralığına göre stok hareketlerini getir
  @Query('SELECT * FROM stock_movements WHERE movement_date BETWEEN :startDate AND :endDate ORDER BY movement_date DESC')
  Future<List<StockMovementEntity>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate);

  /// Hareket türüne göre stok hareketlerini getir
  @Query('SELECT * FROM stock_movements WHERE movement_type = :movementType ORDER BY movement_date DESC')
  Future<List<StockMovementEntity>> getStockMovementsByType(String movementType);

  /// Referans numarasına göre stok hareketlerini getir
  @Query('SELECT * FROM stock_movements WHERE reference_number = :referenceNumber ORDER BY movement_date DESC')
  Future<List<StockMovementEntity>> getStockMovementsByReference(String referenceNumber);

  /// Son N stok hareketini getir
  @Query('SELECT * FROM stock_movements ORDER BY movement_date DESC LIMIT :limit')
  Future<List<StockMovementEntity>> getRecentStockMovements(int limit);

  /// Stok hareketi ekle
  @insert
  Future<int> insertStockMovement(StockMovementEntity stockMovement);

  /// Stok hareketi güncelle
  @update
  Future<int> updateStockMovement(StockMovementEntity stockMovement);

  /// Stok hareketi sil
  @delete
  Future<int> deleteStockMovement(StockMovementEntity stockMovement);

  /// ID'ye göre stok hareketi getir
  @Query('SELECT * FROM stock_movements WHERE id = :id')
  Future<StockMovementEntity?> getStockMovementById(int id);

  /// Ürün ve depo bazında toplam giriş miktarı
  @Query('''
    SELECT SUM(quantity) as total_in 
    FROM stock_movements 
    WHERE product_id = :productId 
    AND warehouse_id = :warehouseId 
    AND movement_type = 'in_'
  ''')
  Future<int?> getTotalInQuantity(int productId, int warehouseId);

  /// Ürün ve depo bazında toplam çıkış miktarı
  @Query('''
    SELECT SUM(quantity) as total_out 
    FROM stock_movements 
    WHERE product_id = :productId 
    AND warehouse_id = :warehouseId 
    AND movement_type = 'out'
  ''')
  Future<int?> getTotalOutQuantity(int productId, int warehouseId);

  /// Ürün ve depo bazında toplam düzeltme miktarı
  @Query('''
    SELECT SUM(quantity) as total_adjustment 
    FROM stock_movements 
    WHERE product_id = :productId 
    AND warehouse_id = :warehouseId 
    AND movement_type = 'adjustment'
  ''')
  Future<int?> getTotalAdjustmentQuantity(int productId, int warehouseId);
}
