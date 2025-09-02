import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/warehouse.dart';
import '../../data/repositories/warehouse_repository_impl.dart';
import '../../data/datasources/warehouse_dao.dart';

// Mock warehouse data
class MockWarehouseRepository implements WarehouseRepositoryImpl {
  static final List<Warehouse> _mockWarehouses = [
    Warehouse(
      id: 1,
      name: 'Ana Depo',
      code: 'DEPO001',
      description: 'Ana şirket deposu',
      address: 'Organize Sanayi Bölgesi No:123',
      phone: '+90 555 123 45 67',
      email: 'depo@tamgaci.com',
      manager: 'Ahmet Yılmaz',
      capacity: 1000.0,
      capacityUnit: 'm²',
      currency: 'TRY',
      isActive: true,
      isDefault: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Warehouse(
      id: 2,
      name: 'Şube Depo',
      code: 'DEPO002',
      description: 'Şube deposu',
      address: 'Merkez Mahallesi No:456',
      phone: '+90 555 987 65 43',
      email: 'sube@tamgaci.com',
      manager: 'Fatma Demir',
      capacity: 500.0,
      capacityUnit: 'm²',
      currency: 'USD',
      isActive: true,
      isDefault: false,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    Warehouse(
      id: 3,
      name: 'Soğuk Hava Deposu',
      code: 'DEPO003',
      description: 'Soğuk hava deposu',
      address: 'Sanayi Caddesi No:789',
      phone: '+90 555 456 78 90',
      email: 'soguk@tamgaci.com',
      manager: 'Mehmet Kaya',
      capacity: 200.0,
      capacityUnit: 'm³',
      currency: 'EUR',
      isActive: true,
      isDefault: false,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Warehouse>> getAllWarehouses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockWarehouses;
  }

  @override
  Future<List<Warehouse>> getActiveWarehouses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockWarehouses.where((w) => w.isActive).toList();
  }

  @override
  Future<Warehouse?> getDefaultWarehouse() async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockWarehouses.firstWhere((w) => w.isDefault);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Warehouse?> getWarehouseById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockWarehouses.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Warehouse?> getWarehouseByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockWarehouses.firstWhere((w) => w.code == code);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Warehouse> createWarehouse(Warehouse warehouse) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newWarehouse = warehouse.copyWith(
      id: _mockWarehouses.length + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockWarehouses.add(newWarehouse);
    return newWarehouse;
  }

  @override
  Future<Warehouse> updateWarehouse(Warehouse warehouse) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockWarehouses.indexWhere((w) => w.id == warehouse.id);
    if (index != -1) {
      final updatedWarehouse = warehouse.copyWith(updatedAt: DateTime.now());
      _mockWarehouses[index] = updatedWarehouse;
      return updatedWarehouse;
    }
    throw Exception('Depo bulunamadı');
  }

  @override
  Future<void> deleteWarehouse(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockWarehouses.removeWhere((w) => w.id == id);
  }

  @override
  Future<int> getWarehouseCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockWarehouses.length;
  }

  @override
  Future<int> getActiveWarehouseCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockWarehouses.where((w) => w.isActive).length;
  }

  // Mock DAO methods (not used in mock implementation)
  @override
  WarehouseDao get _warehouseDao => throw UnimplementedError();
}

// Providers
final warehouseRepositoryProvider = Provider<MockWarehouseRepository>((ref) {
  return MockWarehouseRepository();
});

final warehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getAllWarehouses();
});

final activeWarehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getActiveWarehouses();
});

final defaultWarehouseProvider = FutureProvider<Warehouse?>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getDefaultWarehouse();
});

final warehouseCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getWarehouseCount();
});

final activeWarehouseCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getActiveWarehouseCount();
});
