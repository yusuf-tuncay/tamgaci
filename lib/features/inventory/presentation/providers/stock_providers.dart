// ========== STOCK PROVIDERS ==========
// lib/features/inventory/presentation/providers/stock_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stock.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../data/datasources/stock_dao.dart';

// Mock stock data
class MockStockRepository implements StockRepositoryImpl {
  static final List<Stock> _mockStocks = [
    Stock(
      id: 1,
      productId: 1,
      warehouseId: 1,
      quantity: 150.0,
      minimumQuantity: 50.0,
      maximumQuantity: 500.0,
      unit: 'adet',
      currency: 'TRY',
      unitPrice: 25.0,
      location: 'A-1-1',
      notes: 'Ana depo raf A1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Stock(
      id: 2,
      productId: 2,
      warehouseId: 1,
      quantity: 25.0,
      minimumQuantity: 30.0,
      maximumQuantity: 200.0,
      unit: 'kg',
      currency: 'USD',
      unitPrice: 15.0,
      location: 'B-2-1',
      notes: 'Ana depo raf B2',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    Stock(
      id: 3,
      productId: 3,
      warehouseId: 2,
      quantity: 75.0,
      minimumQuantity: 20.0,
      maximumQuantity: 100.0,
      unit: 'litre',
      currency: 'EUR',
      unitPrice: 8.5,
      location: 'C-1-1',
      notes: 'Şube depo raf C1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    Stock(
      id: 4,
      productId: 1,
      warehouseId: 2,
      quantity: 80.0,
      minimumQuantity: 50.0,
      maximumQuantity: 300.0,
      unit: 'adet',
      currency: 'TRY',
      unitPrice: 25.0,
      location: 'A-1-2',
      notes: 'Şube depo raf A1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    Stock(
      id: 5,
      productId: 4,
      warehouseId: 3,
      quantity: 200.0,
      minimumQuantity: 50.0,
      maximumQuantity: 150.0,
      unit: 'adet',
      currency: 'TRY',
      unitPrice: 12.0,
      location: 'D-1-1',
      notes: 'Soğuk hava deposu raf D1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Stock>> getAllStocks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockStocks;
  }

  @override
  Future<List<Stock>> getActiveStocks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockStocks.where((s) => s.isActive).toList();
  }

  @override
  Future<Stock?> getStockById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockStocks.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Stock>> getStocksByProductId(int productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockStocks.where((s) => s.productId == productId && s.isActive).toList();
  }

  @override
  Future<List<Stock>> getStocksByWarehouseId(int warehouseId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockStocks.where((s) => s.warehouseId == warehouseId && s.isActive).toList();
  }

  @override
  Future<Stock?> getStockByProductAndWarehouse(int productId, int warehouseId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockStocks.firstWhere((s) => s.productId == productId && s.warehouseId == warehouseId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Stock>> getLowStocks() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockStocks.where((s) => s.isCritical && s.isActive).toList();
  }

  @override
  Future<List<Stock>> getOverstockedItems() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockStocks.where((s) => s.isOverstocked && s.isActive).toList();
  }

  @override
  Future<Stock> createStock(Stock stock) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newStock = stock.copyWith(
      id: _mockStocks.length + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockStocks.add(newStock);
    return newStock;
  }

  @override
  Future<Stock> updateStock(Stock stock) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockStocks.indexWhere((s) => s.id == stock.id);
    if (index != -1) {
      final updatedStock = stock.copyWith(updatedAt: DateTime.now());
      _mockStocks[index] = updatedStock;
      return updatedStock;
    }
    throw Exception('Stok bulunamadı');
  }

  @override
  Future<void> deleteStock(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockStocks.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> updateStockQuantity(int id, double quantity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockStocks.indexWhere((s) => s.id == id);
    if (index != -1) {
      _mockStocks[index] = _mockStocks[index].copyWith(
        quantity: quantity,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateStockPrice(int id, double unitPrice) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockStocks.indexWhere((s) => s.id == id);
    if (index != -1) {
      _mockStocks[index] = _mockStocks[index].copyWith(
        unitPrice: unitPrice,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<int> getStockCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockStocks.length;
  }

  @override
  Future<int> getActiveStockCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockStocks.where((s) => s.isActive).length;
  }

  @override
  Future<int> getLowStockCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockStocks.where((s) => s.isCritical && s.isActive).length;
  }

  @override
  Future<double> getTotalStockValue() async {
    await Future.delayed(const Duration(milliseconds: 100));
    double total = 0.0;
    for (final stock in _mockStocks.where((s) => s.isActive)) {
      total += stock.totalValue;
    }
    return total;
  }

  // Mock DAO methods (not used in mock implementation)
  @override
  StockDao get _stockDao => throw UnimplementedError();
}

// Providers
final stockRepositoryProvider = Provider<MockStockRepository>((ref) {
  return MockStockRepository();
});

final stocksProvider = FutureProvider<List<Stock>>((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getAllStocks();
});

final activeStocksProvider = FutureProvider<List<Stock>>((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getActiveStocks();
});

final lowStocksProvider = FutureProvider<List<Stock>>((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getLowStocks();
});

final overstockedItemsProvider = FutureProvider<List<Stock>>((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getOverstockedItems();
});

final stockCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getStockCount();
});

final activeStockCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getActiveStockCount();
});

final lowStockCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getLowStockCount();
});

final totalStockValueProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getTotalStockValue();
});

// Stock by ID provider
final stockByIdProvider = FutureProvider.family<Stock?, int>((ref, id) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getStockById(id);
});

// Stocks by product ID provider
final stocksByProductIdProvider = FutureProvider.family<List<Stock>, int>((ref, productId) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getStocksByProductId(productId);
});

// Stocks by warehouse ID provider
final stocksByWarehouseIdProvider = FutureProvider.family<List<Stock>, int>((ref, warehouseId) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getStocksByWarehouseId(warehouseId);
});
