import 'package:floor/floor.dart';
import '../models/warehouse_entity.dart';

@dao
abstract class WarehouseDao {
  /// Tüm depoları getir
  @Query('SELECT * FROM warehouses ORDER BY name ASC')
  Future<List<WarehouseEntity>> getAllWarehouses();

  /// Aktif depoları getir
  @Query('SELECT * FROM warehouses WHERE is_active = 1 ORDER BY name ASC')
  Future<List<WarehouseEntity>> getActiveWarehouses();

  /// Varsayılan depoyu getir
  @Query('SELECT * FROM warehouses WHERE is_default = 1 LIMIT 1')
  Future<WarehouseEntity?> getDefaultWarehouse();

  /// ID'ye göre depo getir
  @Query('SELECT * FROM warehouses WHERE id = :id')
  Future<WarehouseEntity?> getWarehouseById(int id);

  /// Koda göre depo getir
  @Query('SELECT * FROM warehouses WHERE code = :code')
  Future<WarehouseEntity?> getWarehouseByCode(String code);

  /// Depo ekle
  @insert
  Future<int> insertWarehouse(WarehouseEntity warehouse);

  /// Depo güncelle
  @update
  Future<int> updateWarehouse(WarehouseEntity warehouse);

  /// Depo sil
  @delete
  Future<int> deleteWarehouse(WarehouseEntity warehouse);

  /// Depo sayısını getir
  @Query('SELECT COUNT(*) FROM warehouses')
  Future<int?> getWarehouseCount();

  /// Aktif depo sayısını getir
  @Query('SELECT COUNT(*) FROM warehouses WHERE is_active = 1')
  Future<int?> getActiveWarehouseCount();
}
