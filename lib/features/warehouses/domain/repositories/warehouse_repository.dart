import '../entities/warehouse.dart';

/// Warehouse Repository Interface
abstract class WarehouseRepository {
  /// Tüm depoları getir
  Future<List<Warehouse>> getWarehouses();

  /// Aktif depoları getir
  Future<List<Warehouse>> getActiveWarehouses();

  /// Depo ID'sine göre depo getir
  Future<Warehouse?> getWarehouseById(String id);

  /// Depo türüne göre depoları getir
  Future<List<Warehouse>> getWarehousesByType(WarehouseType type);

  /// Depo durumuna göre depoları getir
  Future<List<Warehouse>> getWarehousesByStatus(WarehouseStatus status);

  /// Şehre göre depoları getir
  Future<List<Warehouse>> getWarehousesByCity(String city);

  /// Depo ara
  Future<List<Warehouse>> searchWarehouses(String query);

  /// Yeni depo oluştur
  Future<String> createWarehouse(Warehouse warehouse);

  /// Depo güncelle
  Future<void> updateWarehouse(Warehouse warehouse);

  /// Depo sil
  Future<void> deleteWarehouse(String id);

  /// Depo istatistikleri getir
  Future<Map<String, dynamic>> getWarehouseStatistics();
}
