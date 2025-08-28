import '../entities/stock_status.dart';

/// Stok durumu repository interface
abstract class StockStatusRepository {
  /// Tüm stok durumlarını getir
  Future<List<StockStatus>> getAllStockStatus();

  /// Ürüne göre stok durumu getir
  Future<StockStatus?> getStockStatusByProduct(int productId);

  /// Depoya göre stok durumları getir
  Future<List<StockStatus>> getStockStatusByWarehouse(int warehouseId);

  /// Kritik stok seviyesindeki ürünleri getir
  Future<List<StockStatus>> getLowStockItems();

  /// Stok durumu oluştur
  Future<StockStatus> createStockStatus(StockStatus stockStatus);

  /// Stok durumu güncelle
  Future<StockStatus> updateStockStatus(StockStatus stockStatus);

  /// Stok durumu sil
  Future<void> deleteStockStatus(int id);

  /// Ürün stok miktarını güncelle
  Future<void> updateStockQuantity(
    int productId,
    int warehouseId,
    int newStock,
  );

  /// Stok durumu sayısını getir
  Future<int> getStockStatusCount();

  /// Toplam stok değerini getir
  Future<double> getTotalStockValue();

  /// Stok durumlarını yenile (stok hareketlerinden hesapla)
  Future<void> refreshStockStatus();
}
