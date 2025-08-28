import '../../domain/repositories/stock_status_repository.dart';
import '../../domain/entities/stock_status.dart';
import '../datasources/stock_status_dao.dart';
import '../models/stock_status_entity.dart';

class StockStatusRepositoryImpl implements StockStatusRepository {
  final StockStatusDao _stockStatusDao;

  StockStatusRepositoryImpl(this._stockStatusDao);

  @override
  Future<List<StockStatus>> getAllStockStatus() async {
    try {
      final entities = await _stockStatusDao.getAllStockStatus();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Stok durumları getirilemedi: $e');
    }
  }

  @override
  Future<StockStatus?> getStockStatusByProduct(int productId) async {
    try {
      final entity = await _stockStatusDao.getStockStatusByProduct(productId);
      return entity != null ? _mapEntityToDomain(entity) : null;
    } catch (e) {
      throw Exception('Ürün stok durumu getirilemedi: $e');
    }
  }

  @override
  Future<List<StockStatus>> getStockStatusByWarehouse(int warehouseId) async {
    try {
      final entities = await _stockStatusDao.getStockStatusByWarehouse(
        warehouseId,
      );
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Depo stok durumları getirilemedi: $e');
    }
  }

  @override
  Future<List<StockStatus>> getLowStockItems() async {
    try {
      final entities = await _stockStatusDao.getLowStockItems();
      return entities.map((entity) => _mapEntityToDomain(entity)).toList();
    } catch (e) {
      throw Exception('Düşük stok ürünleri getirilemedi: $e');
    }
  }

  @override
  Future<StockStatus> createStockStatus(StockStatus stockStatus) async {
    try {
      final entity = _mapDomainToEntity(stockStatus);
      final id = await _stockStatusDao.insertStockStatus(entity);
      return stockStatus.copyWith(id: id);
    } catch (e) {
      throw Exception('Stok durumu oluşturulamadı: $e');
    }
  }

  @override
  Future<StockStatus> updateStockStatus(StockStatus stockStatus) async {
    try {
      final entity = _mapDomainToEntity(stockStatus);
      await _stockStatusDao.updateStockStatus(entity);
      return stockStatus;
    } catch (e) {
      throw Exception('Stok durumu güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteStockStatus(int id) async {
    try {
      // TODO: Implement delete by ID
      throw UnimplementedError('Delete by ID not implemented yet');
    } catch (e) {
      throw Exception('Stok durumu silinemedi: $e');
    }
  }

  @override
  Future<void> updateStockQuantity(
    int productId,
    int warehouseId,
    int newStock,
  ) async {
    try {
      final now = DateTime.now();
      final result = await _stockStatusDao.updateStockQuantity(
        productId,
        warehouseId,
        newStock,
        now.millisecondsSinceEpoch,
      );
      if (result == null || result == 0) {
        throw Exception('Stok miktarı güncellenemedi: Kayıt bulunamadı');
      }
    } catch (e) {
      throw Exception('Stok miktarı güncellenemedi: $e');
    }
  }

  @override
  Future<int> getStockStatusCount() async {
    try {
      final count = await _stockStatusDao.getStockStatusCount();
      return count ?? 0;
    } catch (e) {
      throw Exception('Stok durumu sayısı getirilemedi: $e');
    }
  }

  @override
  Future<double> getTotalStockValue() async {
    try {
      final value = await _stockStatusDao.getTotalStockValue();
      return value ?? 0.0;
    } catch (e) {
      throw Exception('Toplam stok değeri getirilemedi: $e');
    }
  }

  @override
  Future<void> refreshStockStatus() async {
    try {
      // TODO: Implement stock status refresh from stock movements
      // This should recalculate all stock quantities based on stock movements
      throw UnimplementedError('Stock status refresh not implemented yet');
    } catch (e) {
      throw Exception('Stok durumları yenilenemedi: $e');
    }
  }

  /// Entity'den domain modeline dönüştürme
  StockStatus _mapEntityToDomain(StockStatusEntity entity) {
    return StockStatus(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      productCode: entity.productCode,
      warehouseId: entity.warehouseId,
      warehouseName: entity.warehouseName,
      currentStock: entity.currentStock,
      minStock: entity.minStock,
      maxStock: entity.maxStock,
      unitPrice: entity.unitPrice,
      totalValue: entity.totalValue,
      updatedAt: entity.updatedAt,
    );
  }

  /// Domain modelinden entity'ye dönüştürme
  StockStatusEntity _mapDomainToEntity(StockStatus stockStatus) {
    return StockStatusEntity(
      id: stockStatus.id,
      productId: stockStatus.productId,
      productName: stockStatus.productName,
      productCode: stockStatus.productCode,
      warehouseId: stockStatus.warehouseId,
      warehouseName: stockStatus.warehouseName,
      currentStock: stockStatus.currentStock,
      minStock: stockStatus.minStock,
      maxStock: stockStatus.maxStock,
      unitPrice: stockStatus.unitPrice,
      totalValue: stockStatus.totalValue,
      updatedAt: stockStatus.updatedAt,
    );
  }
}
