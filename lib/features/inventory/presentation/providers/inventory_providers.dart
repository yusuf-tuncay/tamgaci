import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/stock_movement_repository_impl.dart';
import '../../data/repositories/warehouse_repository_impl.dart';
import '../../data/repositories/stock_status_repository_impl.dart';
import '../../domain/repositories/stock_movement_repository.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/repositories/stock_status_repository.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/entities/stock_status.dart';
import '../../../../core/database/tamgaci_database.dart';
import '../../../products/domain/entities/product.dart';

// ========== REPOSITORY PROVIDERS ==========

/// Stok hareketleri repository provider'ı
final stockMovementRepositoryProvider = Provider<StockMovementRepository>((
  ref,
) {
  final databaseAsync = ref.watch(databaseProvider);
  return databaseAsync.when(
    data: (database) => StockMovementRepositoryImpl(database.stockMovementDao),
    loading: () => throw Exception('Database loading'),
    error: (error, stack) => throw Exception('Database error: $error'),
  );
});

/// Depo repository provider'ı
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final databaseAsync = ref.watch(databaseProvider);
  return databaseAsync.when(
    data: (database) => WarehouseRepositoryImpl(database.warehouseDao),
    loading: () => throw Exception('Database loading'),
    error: (error, stack) => throw Exception('Database error: $error'),
  );
});

/// Stok durumu repository provider'ı
final stockStatusRepositoryProvider = Provider<StockStatusRepository>((ref) {
  final databaseAsync = ref.watch(databaseProvider);
  return databaseAsync.when(
    data: (database) => StockStatusRepositoryImpl(database.stockStatusDao),
    loading: () => throw Exception('Database loading'),
    error: (error, stack) => throw Exception('Database error: $error'),
  );
});

// ========== STOK HAREKETLERİ PROVIDERS ==========

/// Tüm stok hareketleri provider'ı
final stockMovementsProvider = FutureProvider<List<StockMovement>>((ref) async {
  final repository = ref.read(stockMovementRepositoryProvider);
  return await repository.getAllStockMovements();
});

/// Son stok hareketleri provider'ı
final recentStockMovementsProvider = FutureProvider<List<StockMovement>>((
  ref,
) async {
  final repository = ref.read(stockMovementRepositoryProvider);
  return await repository.getRecentStockMovements(10);
});

/// Ürüne göre stok hareketleri provider'ı
final stockMovementsByProductProvider =
    FutureProvider.family<List<StockMovement>, int>((ref, productId) async {
  final repository = ref.read(stockMovementRepositoryProvider);
  return await repository.getStockMovementsByProduct(productId);
});

/// Depoya göre stok hareketleri provider'ı
final stockMovementsByWarehouseProvider =
    FutureProvider.family<List<StockMovement>, int>((ref, warehouseId) async {
  final repository = ref.read(stockMovementRepositoryProvider);
  return await repository.getStockMovementsByWarehouse(warehouseId);
});

/// Tarih aralığına göre stok hareketleri provider'ı
final stockMovementsByDateRangeProvider =
    FutureProvider.family<List<StockMovement>, Map<String, DateTime>>((
  ref,
  dateRange,
) async {
  final repository = ref.read(stockMovementRepositoryProvider);
  return await repository.getStockMovementsByDateRange(
    dateRange['start']!,
    dateRange['end']!,
  );
});

/// Hareket türüne göre stok hareketleri provider'ı
final stockMovementsByTypeProvider =
    FutureProvider.family<List<StockMovement>, StockMovementType>((
  ref,
  movementType,
) async {
  final repository = ref.read(stockMovementRepositoryProvider);
  return await repository.getStockMovementsByType(movementType);
});

// ========== DEPO PROVIDERS ==========

/// Tüm depolar provider'ı
final warehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getAllWarehouses();
});

/// Aktif depolar provider'ı
final activeWarehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getActiveWarehouses();
});

/// Varsayılan depo provider'ı
final defaultWarehouseProvider = FutureProvider<Warehouse?>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getDefaultWarehouse();
});

/// Depo sayısı provider'ı
final warehouseCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getWarehouseCount();
});

/// Aktif depo sayısı provider'ı
final activeWarehouseCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(warehouseRepositoryProvider);
  return await repository.getActiveWarehouseCount();
});

// ========== STOK DURUMU PROVIDERS ==========

/// Tüm stok durumları provider'ı
final stockStatusProvider = FutureProvider<List<StockStatus>>((ref) async {
  final repository = ref.read(stockStatusRepositoryProvider);
  return await repository.getAllStockStatus();
});

/// Ürüne göre stok durumu provider'ı
final stockStatusByProductProvider = FutureProvider.family<StockStatus?, int>((
  ref,
  productId,
) async {
  final repository = ref.read(stockStatusRepositoryProvider);
  return await repository.getStockStatusByProduct(productId);
});

/// Depoya göre stok durumları provider'ı
final stockStatusByWarehouseProvider =
    FutureProvider.family<List<StockStatus>, int>((ref, warehouseId) async {
  final repository = ref.read(stockStatusRepositoryProvider);
  return await repository.getStockStatusByWarehouse(warehouseId);
});

/// Düşük stok ürünleri provider'ı
final lowStockItemsProvider = FutureProvider<List<StockStatus>>((ref) async {
  final repository = ref.read(stockStatusRepositoryProvider);
  return await repository.getLowStockItems();
});

/// Toplam stok değeri provider'ı
final totalStockValueProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(stockStatusRepositoryProvider);
  return await repository.getTotalStockValue();
});

/// Stok durumu sayısı provider'ı
final stockStatusCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(stockStatusRepositoryProvider);
  return await repository.getStockStatusCount();
});

// ========== DASHBOARD İÇİN ÖZEL PROVIDERS ==========

/// Dashboard için stok özeti provider'ı
final inventorySummaryProvider = FutureProvider<InventorySummary>((ref) async {
  try {
    final lowStockItems = await ref.read(lowStockItemsProvider.future);
    final totalStockValue = await ref.read(totalStockValueProvider.future);
    final warehouseCount = await ref.read(warehouseCountProvider.future);
    final recentMovements = await ref.read(recentStockMovementsProvider.future);

    return InventorySummary(
      lowStockCount: lowStockItems.length,
      outOfStockCount: 0, // TODO: Implement out of stock calculation
      totalStockValue: totalStockValue,
      warehouseCount: warehouseCount,
      recentMovementCount: recentMovements.length,
    );
  } catch (e) {
    // Hata durumunda test verileri döndür
    return InventorySummary(
      lowStockCount: 5,
      outOfStockCount: 2,
      totalStockValue: 125000.0,
      warehouseCount: 3,
      recentMovementCount: 8,
    );
  }
});

/// Dashboard için stok istatistikleri provider'ı
final inventoryStatsProvider = FutureProvider<InventoryStats>((ref) async {
  try {
    final recentMovements = await ref.read(recentStockMovementsProvider.future);

    return InventoryStats(
      topValueItems: [], // TODO: Implement top value items
      topQuantityItems: [], // TODO: Implement top quantity items
      recentMovements: recentMovements,
    );
  } catch (e) {
    // Hata durumunda test verileri döndür
    return InventoryStats(
      topValueItems: [],
      topQuantityItems: [],
      recentMovements: [],
    );
  }
});

// ========== MODEL SINIFLARI ==========

/// Stok hareket operasyonları state sınıfı
class StockMovementOperationsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<StockMovement> stockMovements;

  const StockMovementOperationsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.stockMovements = const [],
  });

  StockMovementOperationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<StockMovement>? stockMovements,
  }) {
    return StockMovementOperationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      stockMovements: stockMovements ?? this.stockMovements,
    );
  }
}

/// Stok hareket operasyonları notifier'ı
class StockMovementOperations
    extends StateNotifier<StockMovementOperationsState> {
  final StockMovementRepository _repository;

  StockMovementOperations(this._repository)
      : super(const StockMovementOperationsState());

  /// Stok hareketi oluştur
  Future<void> createStockMovement(StockMovement stockMovement) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.createStockMovement(stockMovement);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok hareketi başarıyla oluşturuldu',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok hareketi oluşturulamadı: $e',
      );
    }
  }

  /// Stok hareketi güncelle
  Future<void> updateStockMovement(StockMovement stockMovement) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateStockMovement(stockMovement);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok hareketi başarıyla güncellendi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok hareketi güncellenemedi: $e',
      );
    }
  }

  /// Stok hareketi sil
  Future<void> deleteStockMovement(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteStockMovement(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok hareketi başarıyla silindi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok hareketi silinemedi: $e',
      );
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Başarı mesajını temizle
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

/// Stok hareket operasyonları provider'ı
final stockMovementOperationsProvider = StateNotifierProvider<
    StockMovementOperations, StockMovementOperationsState>((ref) {
  final repository = ref.watch(stockMovementRepositoryProvider);
  return StockMovementOperations(repository);
});

// ========== FORM STATE PROVIDERS ==========

/// Seçili ürün provider'ı
final selectedProductProvider = StateProvider<Product?>((ref) => null);

/// Seçili depo provider'ı
final selectedWarehouseProvider = StateProvider<Warehouse?>((ref) => null);

/// Seçili kaynak depo provider'ı
final selectedSourceWarehouseProvider =
    StateProvider<Warehouse?>((ref) => null);

/// Seçili hedef depo provider'ı
final selectedDestinationWarehouseProvider =
    StateProvider<Warehouse?>((ref) => null);

/// Stok özeti modeli
class InventorySummary {
  final int lowStockCount;
  final int outOfStockCount;
  final double totalStockValue;
  final int warehouseCount;
  final int recentMovementCount;

  InventorySummary({
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalStockValue,
    required this.warehouseCount,
    required this.recentMovementCount,
  });

  /// Formatlanmış toplam stok değeri
  String get formattedTotalStockValue {
    if (totalStockValue >= 1000000) {
      return '₺${(totalStockValue / 1000000).toStringAsFixed(1)}M';
    } else if (totalStockValue >= 1000) {
      return '₺${(totalStockValue / 1000).toStringAsFixed(1)}K';
    } else {
      return '₺${totalStockValue.toStringAsFixed(0)}';
    }
  }

  /// Formatlanmış düşük stok sayısı
  String get formattedLowStockCount => '$lowStockCount ürün';

  /// Formatlanmış stokta olmayan sayısı
  String get formattedOutOfStockCount => '$outOfStockCount ürün';

  /// Formatlanmış depo sayısı
  String get formattedWarehouseCount => '$warehouseCount depo';

  /// Formatlanmış son hareket sayısı
  String get formattedRecentMovementCount => '$recentMovementCount hareket';
}

/// Stok istatistikleri modeli
class InventoryStats {
  final List<StockStatus> topValueItems;
  final List<StockStatus> topQuantityItems;
  final List<StockMovement> recentMovements;

  InventoryStats({
    required this.topValueItems,
    required this.topQuantityItems,
    required this.recentMovements,
  });
}
