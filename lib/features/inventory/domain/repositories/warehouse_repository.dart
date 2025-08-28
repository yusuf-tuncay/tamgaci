import '../entities/warehouse.dart';

abstract class WarehouseRepository {
  /// Tüm depoları getir
  Future<List<Warehouse>> getAllWarehouses();

  /// Aktif depoları getir
  Future<List<Warehouse>> getActiveWarehouses();

  /// Varsayılan depoyu getir
  Future<Warehouse?> getDefaultWarehouse();

  /// ID'ye göre depo getir
  Future<Warehouse?> getWarehouseById(int id);

  /// Koda göre depo getir
  Future<Warehouse?> getWarehouseByCode(String code);

  /// Depo oluştur
  Future<Warehouse> createWarehouse(Warehouse warehouse);

  /// Depo güncelle
  Future<Warehouse> updateWarehouse(Warehouse warehouse);

  /// Depo sil
  Future<void> deleteWarehouse(int id);

  /// Depo sayısını getir
  Future<int> getWarehouseCount();

  /// Aktif depo sayısını getir
  Future<int> getActiveWarehouseCount();
}
