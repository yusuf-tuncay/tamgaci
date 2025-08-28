import '../entities/stock_movement.dart';

abstract class StockMovementRepository {
  /// Tüm stok hareketlerini getir
  Future<List<StockMovement>> getAllStockMovements();

  /// Ürüne göre stok hareketlerini getir
  Future<List<StockMovement>> getStockMovementsByProduct(int productId);

  /// Depoya göre stok hareketlerini getir
  Future<List<StockMovement>> getStockMovementsByWarehouse(int warehouseId);

  /// Tarih aralığına göre stok hareketlerini getir
  Future<List<StockMovement>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate);

  /// Hareket türüne göre stok hareketlerini getir
  Future<List<StockMovement>> getStockMovementsByType(StockMovementType movementType);

  /// Referans numarasına göre stok hareketlerini getir
  Future<List<StockMovement>> getStockMovementsByReference(String referenceNumber);

  /// Son N stok hareketini getir
  Future<List<StockMovement>> getRecentStockMovements(int limit);

  /// Stok hareketi oluştur
  Future<StockMovement> createStockMovement(StockMovement stockMovement);

  /// Stok hareketi güncelle
  Future<StockMovement> updateStockMovement(StockMovement stockMovement);

  /// Stok hareketi sil
  Future<void> deleteStockMovement(int id);

  /// ID'ye göre stok hareketi getir
  Future<StockMovement?> getStockMovementById(int id);

  /// Ürün ve depo bazında toplam giriş miktarı
  Future<int> getTotalInQuantity(int productId, int warehouseId);

  /// Ürün ve depo bazında toplam çıkış miktarı
  Future<int> getTotalOutQuantity(int productId, int warehouseId);

  /// Ürün ve depo bazında toplam düzeltme miktarı
  Future<int> getTotalAdjustmentQuantity(int productId, int warehouseId);
}
