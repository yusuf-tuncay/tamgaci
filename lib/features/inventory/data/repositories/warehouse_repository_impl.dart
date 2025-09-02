import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/entities/warehouse.dart';
import '../datasources/warehouse_dao.dart';
import '../models/warehouse_entity.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final WarehouseDao _warehouseDao;

  WarehouseRepositoryImpl(this._warehouseDao);

  @override
  Future<List<Warehouse>> getAllWarehouses() async {
    try {
      final entities = await _warehouseDao.getAllWarehouses();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Depolar getirilemedi: $e');
    }
  }

  @override
  Future<List<Warehouse>> getActiveWarehouses() async {
    try {
      final entities = await _warehouseDao.getActiveWarehouses();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Aktif depolar getirilemedi: $e');
    }
  }

  @override
  Future<Warehouse?> getDefaultWarehouse() async {
    try {
      final entity = await _warehouseDao.getDefaultWarehouse();
      return entity != null ? _mapEntityToDomain(entity) : null;
    } catch (e) {
      throw Exception('Varsayılan depo getirilemedi: $e');
    }
  }

  @override
  Future<Warehouse?> getWarehouseById(int id) async {
    try {
      final entity = await _warehouseDao.getWarehouseById(id);
      return entity != null ? _mapEntityToDomain(entity) : null;
    } catch (e) {
      throw Exception('Depo getirilemedi: $e');
    }
  }

  @override
  Future<Warehouse?> getWarehouseByCode(String code) async {
    try {
      final entity = await _warehouseDao.getWarehouseByCode(code);
      return entity != null ? _mapEntityToDomain(entity) : null;
    } catch (e) {
      throw Exception('Depo kodu ile getirilemedi: $e');
    }
  }

  @override
  Future<Warehouse> createWarehouse(Warehouse warehouse) async {
    try {
      final entity = _mapDomainToEntity(warehouse);
      final id = await _warehouseDao.insertWarehouse(entity);
      return warehouse.copyWith(id: id);
    } catch (e) {
      throw Exception('Depo oluşturulamadı: $e');
    }
  }

  @override
  Future<Warehouse> updateWarehouse(Warehouse warehouse) async {
    try {
      final entity = _mapDomainToEntity(warehouse);
      await _warehouseDao.updateWarehouse(entity);
      return warehouse;
    } catch (e) {
      throw Exception('Depo güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteWarehouse(int id) async {
    try {
      final entity = await _warehouseDao.getWarehouseById(id);
      if (entity != null) {
        await _warehouseDao.deleteWarehouse(entity);
      }
    } catch (e) {
      throw Exception('Depo silinemedi: $e');
    }
  }

  @override
  Future<int> getWarehouseCount() async {
    try {
      final count = await _warehouseDao.getWarehouseCount();
      return count ?? 0;
    } catch (e) {
      throw Exception('Depo sayısı getirilemedi: $e');
    }
  }

  @override
  Future<int> getActiveWarehouseCount() async {
    try {
      final count = await _warehouseDao.getActiveWarehouseCount();
      return count ?? 0;
    } catch (e) {
      throw Exception('Aktif depo sayısı getirilemedi: $e');
    }
  }

  /// Entity'den domain modeline dönüştürme
  Warehouse _mapEntityToDomain(WarehouseEntity entity) {
    return Warehouse(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      description: entity.description,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      manager: entity.manager,
      capacity: entity.capacity,
      capacityUnit: entity.capacityUnit,
      currency: entity.currency,
      isActive: entity.isActive,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Domain modelinden entity'ye dönüştürme
  WarehouseEntity _mapDomainToEntity(Warehouse warehouse) {
    return WarehouseEntity(
      id: warehouse.id,
      name: warehouse.name,
      code: warehouse.code,
      description: warehouse.description,
      address: warehouse.address,
      phone: warehouse.phone,
      email: warehouse.email,
      manager: warehouse.manager,
      capacity: warehouse.capacity,
      capacityUnit: warehouse.capacityUnit,
      currency: warehouse.currency,
      isActive: warehouse.isActive,
      isDefault: warehouse.isDefault,
      createdAt: warehouse.createdAt,
      updatedAt: warehouse.updatedAt,
    );
  }
}
