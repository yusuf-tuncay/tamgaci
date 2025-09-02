// ========== STOCK REPOSITORY INTERFACE ==========
// lib/features/inventory/domain/repositories/stock_repository.dart

import '../entities/stock.dart';

abstract class StockRepository {
  /// Tüm stokları getir
  Future<List<Stock>> getAllStocks();

  /// Aktif stokları getir
  Future<List<Stock>> getActiveStocks();

  /// ID'ye göre stok getir
  Future<Stock?> getStockById(int id);

  /// Ürün ID'sine göre stokları getir
  Future<List<Stock>> getStocksByProductId(int productId);

  /// Depo ID'sine göre stokları getir
  Future<List<Stock>> getStocksByWarehouseId(int warehouseId);

  /// Ürün ve depo ID'sine göre stok getir
  Future<Stock?> getStockByProductAndWarehouse(int productId, int warehouseId);

  /// Düşük stokları getir
  Future<List<Stock>> getLowStocks();

  /// Yüksek stokları getir
  Future<List<Stock>> getOverstockedItems();

  /// Stok oluştur
  Future<Stock> createStock(Stock stock);

  /// Stok güncelle
  Future<Stock> updateStock(Stock stock);

  /// Stok sil
  Future<void> deleteStock(int id);

  /// Stok miktarını güncelle
  Future<void> updateStockQuantity(int id, double quantity);

  /// Stok fiyatını güncelle
  Future<void> updateStockPrice(int id, double unitPrice);

  /// Stok sayısını getir
  Future<int> getStockCount();

  /// Aktif stok sayısını getir
  Future<int> getActiveStockCount();

  /// Düşük stok sayısını getir
  Future<int> getLowStockCount();

  /// Toplam stok değerini getir
  Future<double> getTotalStockValue();
}
