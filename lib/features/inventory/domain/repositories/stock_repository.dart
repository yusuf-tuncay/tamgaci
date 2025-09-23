// ========== STOCK REPOSITORY INTERFACE ==========
// lib/features/inventory/domain/repositories/stock_repository.dart

import '../entities/stock.dart';

abstract class StockRepository {
  /// Tüm stokları getir
  Future<List<Stock>> getAllStocks();

  /// Aktif stokları getir
  Future<List<Stock>> getActiveStocks();

  /// ID'ye göre stok getir
  Future<Stock?> getStockById(String id);

  /// Ürün ID'sine göre stokları getir
  Future<List<Stock>> getStocksByProductId(String productId);

  /// Depo ID'sine göre stokları getir
  Future<List<Stock>> getStocksByWarehouseId(String warehouseId);

  /// Ürün ve depo ID'sine göre stok getir
  Future<Stock?> getStockByProductAndWarehouse(
      String productId, String warehouseId);

  /// Düşük stokları getir
  Future<List<Stock>> getLowStocks();

  /// Yüksek stokları getir
  Future<List<Stock>> getOverstockedItems();

  /// Stok oluştur
  Future<Stock> createStock(Stock stock);

  /// Stok güncelle
  Future<Stock> updateStock(Stock stock);

  /// Stok sil
  Future<void> deleteStock(String id);

  /// Stok miktarını güncelle
  Future<void> updateStockQuantity(String id, double quantity);

  /// Stok fiyatını güncelle
  Future<void> updateStockPrice(String id, double unitPrice);

  /// Stok sayısını getir
  Future<int> getStockCount();

  /// Aktif stok sayısını getir
  Future<int> getActiveStockCount();

  /// Düşük stok sayısını getir
  Future<int> getLowStockCount();

  /// Toplam stok değerini getir
  Future<double> getTotalStockValue();
}
