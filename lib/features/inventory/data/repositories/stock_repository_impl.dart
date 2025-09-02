// ========== STOCK REPOSITORY IMPLEMENTATION ==========
// lib/features/inventory/data/repositories/stock_repository_impl.dart

import '../../domain/repositories/stock_repository.dart';
import '../../domain/entities/stock.dart';
import '../datasources/stock_dao.dart';
import '../models/stock_entity.dart';

class StockRepositoryImpl implements StockRepository {
  final StockDao _stockDao;

  StockRepositoryImpl(this._stockDao);

  @override
  Future<List<Stock>> getAllStocks() async {
    try {
      final entities = await _stockDao.getAllStocks();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Stoklar getirilemedi: $e');
    }
  }

  @override
  Future<List<Stock>> getActiveStocks() async {
    try {
      final entities = await _stockDao.getActiveStocks();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Aktif stoklar getirilemedi: $e');
    }
  }

  @override
  Future<Stock?> getStockById(int id) async {
    try {
      final entity = await _stockDao.getStockById(id);
      return entity != null ? _mapEntityToDomain(entity) : null;
    } catch (e) {
      throw Exception('Stok getirilemedi: $e');
    }
  }

  @override
  Future<List<Stock>> getStocksByProductId(int productId) async {
    try {
      final entities = await _stockDao.getStocksByProductId(productId);
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Ürün stokları getirilemedi: $e');
    }
  }

  @override
  Future<List<Stock>> getStocksByWarehouseId(int warehouseId) async {
    try {
      final entities = await _stockDao.getStocksByWarehouseId(warehouseId);
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Depo stokları getirilemedi: $e');
    }
  }

  @override
  Future<Stock?> getStockByProductAndWarehouse(int productId, int warehouseId) async {
    try {
      final entity = await _stockDao.getStockByProductAndWarehouse(productId, warehouseId);
      return entity != null ? _mapEntityToDomain(entity) : null;
    } catch (e) {
      throw Exception('Stok getirilemedi: $e');
    }
  }

  @override
  Future<List<Stock>> getLowStocks() async {
    try {
      final entities = await _stockDao.getLowStocks();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Düşük stoklar getirilemedi: $e');
    }
  }

  @override
  Future<List<Stock>> getOverstockedItems() async {
    try {
      final entities = await _stockDao.getOverstockedItems();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Fazla stoklar getirilemedi: $e');
    }
  }

  @override
  Future<Stock> createStock(Stock stock) async {
    try {
      final entity = _mapDomainToEntity(stock);
      final id = await _stockDao.insertStock(entity);
      return stock.copyWith(id: id);
    } catch (e) {
      throw Exception('Stok oluşturulamadı: $e');
    }
  }

  @override
  Future<Stock> updateStock(Stock stock) async {
    try {
      final entity = _mapDomainToEntity(stock);
      await _stockDao.updateStock(entity);
      return stock;
    } catch (e) {
      throw Exception('Stok güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteStock(int id) async {
    try {
      await _stockDao.deleteStockById(id);
    } catch (e) {
      throw Exception('Stok silinemedi: $e');
    }
  }

  @override
  Future<void> updateStockQuantity(int id, double quantity) async {
    try {
      await _stockDao.updateStockQuantity(id, quantity, DateTime.now());
    } catch (e) {
      throw Exception('Stok miktarı güncellenemedi: $e');
    }
  }

  @override
  Future<void> updateStockPrice(int id, double unitPrice) async {
    try {
      await _stockDao.updateStockPrice(id, unitPrice, DateTime.now());
    } catch (e) {
      throw Exception('Stok fiyatı güncellenemedi: $e');
    }
  }

  @override
  Future<int> getStockCount() async {
    try {
      final count = await _stockDao.getStockCount();
      return count ?? 0;
    } catch (e) {
      throw Exception('Stok sayısı getirilemedi: $e');
    }
  }

  @override
  Future<int> getActiveStockCount() async {
    try {
      final count = await _stockDao.getActiveStockCount();
      return count ?? 0;
    } catch (e) {
      throw Exception('Aktif stok sayısı getirilemedi: $e');
    }
  }

  @override
  Future<int> getLowStockCount() async {
    try {
      final count = await _stockDao.getLowStockCount();
      return count ?? 0;
    } catch (e) {
      throw Exception('Düşük stok sayısı getirilemedi: $e');
    }
  }

  @override
  Future<double> getTotalStockValue() async {
    try {
      final value = await _stockDao.getTotalStockValue();
      return value ?? 0.0;
    } catch (e) {
      throw Exception('Toplam stok değeri getirilemedi: $e');
    }
  }

  /// Entity'yi Domain'e çevirir
  Stock _mapEntityToDomain(StockEntity entity) {
    return Stock(
      id: entity.id,
      productId: entity.productId,
      warehouseId: entity.warehouseId,
      quantity: entity.quantity,
      minimumQuantity: entity.minimumQuantity,
      maximumQuantity: entity.maximumQuantity,
      unit: entity.unit,
      currency: entity.currency,
      unitPrice: entity.unitPrice,
      location: entity.location,
      notes: entity.notes,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Domain'i Entity'ye çevirir
  StockEntity _mapDomainToEntity(Stock stock) {
    return StockEntity(
      id: stock.id,
      productId: stock.productId,
      warehouseId: stock.warehouseId,
      quantity: stock.quantity,
      minimumQuantity: stock.minimumQuantity,
      maximumQuantity: stock.maximumQuantity,
      unit: stock.unit,
      currency: stock.currency,
      unitPrice: stock.unitPrice,
      location: stock.location,
      notes: stock.notes,
      isActive: stock.isActive,
      createdAt: stock.createdAt,
      updatedAt: stock.updatedAt,
    );
  }
}
