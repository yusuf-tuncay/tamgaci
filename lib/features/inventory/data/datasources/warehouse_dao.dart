import 'package:floor/floor.dart';
import '../models/warehouse_entity.dart';

@dao
abstract class WarehouseDao {
  @Query('SELECT * FROM warehouses ORDER BY name ASC')
  Future<List<WarehouseEntity>> getAllWarehouses();

  @Query('SELECT * FROM warehouses WHERE is_active = 1 ORDER BY name ASC')
  Future<List<WarehouseEntity>> getActiveWarehouses();

  @Query('SELECT * FROM warehouses WHERE is_default = 1 LIMIT 1')
  Future<WarehouseEntity?> getDefaultWarehouse();

  @Query('SELECT * FROM warehouses WHERE id = :id')
  Future<WarehouseEntity?> getWarehouseById(int id);

  @Query('SELECT * FROM warehouses WHERE code = :code')
  Future<WarehouseEntity?> getWarehouseByCode(String code);

  @Query('SELECT COUNT(*) FROM warehouses')
  Future<int?> getWarehouseCount();

  @Query('SELECT COUNT(*) FROM warehouses WHERE is_active = 1')
  Future<int?> getActiveWarehouseCount();

  @insert
  Future<int> insertWarehouse(WarehouseEntity warehouse);

  @update
  Future<void> updateWarehouse(WarehouseEntity warehouse);

  @delete
  Future<void> deleteWarehouse(WarehouseEntity warehouse);
}
