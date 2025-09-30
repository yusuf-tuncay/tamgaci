import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_stock_count_repository.dart';
import '../../domain/entities/stock_count.dart';

/// Stock Count Repository Provider
final stockCountRepositoryProvider = Provider<FirebaseStockCountRepository>((ref) {
  return FirebaseStockCountRepository();
});

/// Depoya göre stok sayımları stream provider
final stockCountsByWarehouseStreamProvider =
    StreamProvider.family<List<StockCount>, String>((ref, warehouseId) {
  final repository = ref.watch(stockCountRepositoryProvider);
  return repository.getStockCountsByWarehouse(warehouseId);
});

/// Tüm stok sayımları stream provider
final allStockCountsStreamProvider = StreamProvider<List<StockCount>>((ref) {
  final repository = ref.watch(stockCountRepositoryProvider);
  return repository.getAllStockCounts();
});

/// Stock Count Detail Provider
final stockCountDetailProvider =
    FutureProvider.family<StockCount?, String>((ref, id) async {
  final repository = ref.watch(stockCountRepositoryProvider);
  return repository.getStockCount(id);
});

/// Stock Count Operations State
class StockCountOperationsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const StockCountOperationsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  StockCountOperationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return StockCountOperationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Stock Count Operations Notifier
class StockCountOperationsNotifier
    extends StateNotifier<StockCountOperationsState> {
  final FirebaseStockCountRepository _repository;

  StockCountOperationsNotifier(this._repository)
      : super(const StockCountOperationsState());

  /// Stok sayımı oluştur
  Future<String?> createStockCount(StockCount stockCount) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final id = await _repository.createStockCount(stockCount);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok sayımı başarıyla oluşturuldu',
      );
      return id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok sayımı oluşturulamadı: $e',
      );
      return null;
    }
  }

  /// Stok sayımını güncelle
  Future<bool> updateStockCount(StockCount stockCount) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateStockCount(stockCount);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok sayımı başarıyla güncellendi',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok sayımı güncellenemedi: $e',
      );
      return false;
    }
  }

  /// Stok sayımını tamamla
  Future<bool> completeStockCount(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.completeStockCount(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok sayımı tamamlandı ve ürün stokları güncellendi',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok sayımı tamamlanamadı: $e',
      );
      return false;
    }
  }

  /// Stok sayımını iptal et
  Future<bool> cancelStockCount(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.cancelStockCount(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok sayımı iptal edildi',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok sayımı iptal edilemedi: $e',
      );
      return false;
    }
  }

  /// Stok sayımını sil
  Future<bool> deleteStockCount(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteStockCount(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok sayımı silindi',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stok sayımı silinemedi: $e',
      );
      return false;
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

/// Stock Count Operations Provider
final stockCountOperationsProvider =
    StateNotifierProvider<StockCountOperationsNotifier,
        StockCountOperationsState>((ref) {
  final repository = ref.watch(stockCountRepositoryProvider);
  return StockCountOperationsNotifier(repository);
});
