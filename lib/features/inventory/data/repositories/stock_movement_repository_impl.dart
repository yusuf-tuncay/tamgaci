import '../../domain/repositories/stock_movement_repository.dart';
import '../../domain/entities/stock_movement.dart';
import '../datasources/stock_movement_dao.dart';
import '../models/stock_movement_entity.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  final StockMovementDao _stockMovementDao;

  StockMovementRepositoryImpl(this._stockMovementDao);

  @override
  Future<List<StockMovement>> getAllStockMovements() async {
    try {
      final entities = await _stockMovementDao.getAllStockMovements();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Stok hareketleri getirilemedi: $e');
    }
  }

  @override
  Future<List<StockMovement>> getStockMovementsByProduct(int productId) async {
    try {
      final entities = await _stockMovementDao.getStockMovementsByProduct(productId);
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Ürün stok hareketleri getirilemedi: $e');
    }
  }

  @override
  Future<List<StockMovement>> getStockMovementsByWarehouse(int warehouseId) async {
    try {
      final entities = await _stockMovementDao.getStockMovementsByWarehouse(warehouseId);
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Depo stok hareketleri getirilemedi: $e');
    }
  }

  @override
  Future<List<StockMovement>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final entities = await _stockMovementDao.getStockMovementsByDateRange(startDate, endDate);
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Tarih aralığı stok hareketleri getirilemedi: $e');
    }
  }

  @override
  Future<List<StockMovement>> getStockMovementsByType(StockMovementType movementType) async {
    try {
      final entities = await _stockMovementDao.getStockMovementsByType(movementType.name);
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Hareket türü stok hareketleri getirilemedi: $e');
    }
  }

  @override
  Future<List<StockMovement>> getStockMovementsByReference(String referenceNumber) async {
    try {
      final entities = await _stockMovementDao.getStockMovementsByReference(referenceNumber);
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Referans stok hareketleri getirilemedi: $e');
    }
  }

  @override
  Future<List<StockMovement>> getRecentStockMovements(int limit) async {
    try {
      final entities = await _stockMovementDao.getRecentStockMovements(limit);
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Son stok hareketleri getirilemedi: $e');
    }
  }

  @override
  Future<StockMovement> createStockMovement(StockMovement stockMovement) async {
    try {
      final entity = _mapDomainToEntity(stockMovement);
      final id = await _stockMovementDao.insertStockMovement(entity);
      return stockMovement.copyWith(id: id);
    } catch (e) {
      throw Exception('Stok hareketi oluşturulamadı: $e');
    }
  }

  @override
  Future<StockMovement> updateStockMovement(StockMovement stockMovement) async {
    try {
      final entity = _mapDomainToEntity(stockMovement);
      await _stockMovementDao.updateStockMovement(entity);
      return stockMovement;
    } catch (e) {
      throw Exception('Stok hareketi güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteStockMovement(int id) async {
    try {
      final entity = await _stockMovementDao.getStockMovementById(id);
      if (entity != null) {
        await _stockMovementDao.deleteStockMovement(entity);
      }
    } catch (e) {
      throw Exception('Stok hareketi silinemedi: $e');
    }
  }

  @override
  Future<StockMovement?> getStockMovementById(int id) async {
    try {
      final entity = await _stockMovementDao.getStockMovementById(id);
      return entity != null ? _mapEntityToDomain(entity) : null;
    } catch (e) {
      throw Exception('Stok hareketi getirilemedi: $e');
    }
  }

  @override
  Future<int> getTotalInQuantity(int productId, int warehouseId) async {
    try {
      final quantity = await _stockMovementDao.getTotalInQuantity(productId, warehouseId);
      return quantity ?? 0;
    } catch (e) {
      throw Exception('Toplam giriş miktarı getirilemedi: $e');
    }
  }

  @override
  Future<int> getTotalOutQuantity(int productId, int warehouseId) async {
    try {
      final quantity = await _stockMovementDao.getTotalOutQuantity(productId, warehouseId);
      return quantity ?? 0;
    } catch (e) {
      throw Exception('Toplam çıkış miktarı getirilemedi: $e');
    }
  }

  @override
  Future<int> getTotalAdjustmentQuantity(int productId, int warehouseId) async {
    try {
      final quantity = await _stockMovementDao.getTotalAdjustmentQuantity(productId, warehouseId);
      return quantity ?? 0;
    } catch (e) {
      throw Exception('Toplam düzeltme miktarı getirilemedi: $e');
    }
  }

  /// Entity'den domain modeline dönüştürme
  StockMovement _mapEntityToDomain(StockMovementEntity entity) {
    return StockMovement(
      id: entity.id,
      productId: entity.productId,
      movementType: entity.movementType,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      totalAmount: entity.totalAmount,
      description: entity.description,
      referenceNumber: entity.referenceNumber,
      referenceType: entity.referenceType,
      warehouseId: entity.warehouseId,
      sourceWarehouseId: entity.sourceWarehouseId,
      destinationWarehouseId: entity.destinationWarehouseId,
      movementDate: entity.movementDate,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Domain modelinden entity'ye dönüştürme
  StockMovementEntity _mapDomainToEntity(StockMovement stockMovement) {
    return StockMovementEntity(
      id: stockMovement.id,
      productId: stockMovement.productId,
      movementType: stockMovement.movementType,
      quantity: stockMovement.quantity,
      unitPrice: stockMovement.unitPrice,
      totalAmount: stockMovement.totalAmount,
      description: stockMovement.description,
      referenceNumber: stockMovement.referenceNumber,
      referenceType: stockMovement.referenceType,
      warehouseId: stockMovement.warehouseId,
      sourceWarehouseId: stockMovement.sourceWarehouseId,
      destinationWarehouseId: stockMovement.destinationWarehouseId,
      movementDate: stockMovement.movementDate,
      createdBy: stockMovement.createdBy,
      createdAt: stockMovement.createdAt,
      updatedAt: stockMovement.updatedAt,
    );
  }
}
