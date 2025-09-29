import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_warehouse_repository.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';

/// Warehouse Repository Provider
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return FirebaseWarehouseRepository();
});

/// Warehouses List Provider
final warehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getWarehouses();
});

/// Active Warehouses Provider
final activeWarehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getActiveWarehouses();
});

/// Warehouse by ID Provider
final warehouseByIdProvider =
    FutureProvider.family<Warehouse?, String>((ref, id) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getWarehouseById(id);
});

/// Warehouses by Type Provider
final warehousesByTypeProvider =
    FutureProvider.family<List<Warehouse>, WarehouseType>((ref, type) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getWarehousesByType(type);
});

/// Warehouses by Status Provider
final warehousesByStatusProvider =
    FutureProvider.family<List<Warehouse>, WarehouseStatus>((ref, status) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getWarehousesByStatus(status);
});

/// Warehouses by City Provider
final warehousesByCityProvider =
    FutureProvider.family<List<Warehouse>, String>((ref, city) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getWarehousesByCity(city);
});

/// Search Warehouses Provider
final searchWarehousesProvider =
    FutureProvider.family<List<Warehouse>, String>((ref, query) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.searchWarehouses(query);
});

/// Warehouse Statistics Provider
final warehouseStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getWarehouseStatistics();
});

/// Warehouse Notifier (for CRUD operations)
class WarehouseNotifier extends StateNotifier<AsyncValue<List<Warehouse>>> {
  final WarehouseRepository _repository;

  WarehouseNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    try {
      state = const AsyncValue.loading();
      final warehouses = await _repository.getWarehouses();
      state = AsyncValue.data(warehouses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadWarehouses();
  }

  Future<void> createWarehouse(Warehouse warehouse) async {
    try {
      state = const AsyncValue.loading();
      await _repository.createWarehouse(warehouse);
      await _loadWarehouses(); // Refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateWarehouse(Warehouse warehouse) async {
    try {
      state = const AsyncValue.loading();
      await _repository.updateWarehouse(warehouse);
      await _loadWarehouses(); // Refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteWarehouse(String id) async {
    try {
      state = const AsyncValue.loading();
      await _repository.deleteWarehouse(id);
      await _loadWarehouses(); // Refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final warehouseNotifierProvider =
    StateNotifierProvider<WarehouseNotifier, AsyncValue<List<Warehouse>>>((ref) {
  return WarehouseNotifier(ref.watch(warehouseRepositoryProvider));
});
