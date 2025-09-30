// ========== PRODUCT MOVEMENT PROVIDERS ==========
// lib/features/products/presentation/providers/product_movement_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_movement.dart';
import '../../data/repositories/firebase_product_movement_repository.dart';

/// Ürün hareketleri repository provider'ı
final productMovementRepositoryProvider = Provider<FirebaseProductMovementRepository>((ref) {
  return FirebaseProductMovementRepository();
});

/// Belirli bir ürünün hareketleri provider'ı
final productMovementsProvider = StreamProvider.family<List<ProductMovement>, String>((ref, productId) {
  final repository = ref.watch(productMovementRepositoryProvider);
  return repository.getProductMovements(productId);
});

/// Ürün hareketleri istatistikleri provider'ı
final productMovementStatsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, productId) {
  final repository = ref.watch(productMovementRepositoryProvider);
  return repository.getProductMovementStats(productId);
});

/// Tüm ürün hareketleri provider'ı (admin için)
final allProductMovementsProvider = StreamProvider<List<ProductMovement>>((ref) {
  final repository = ref.watch(productMovementRepositoryProvider);
  return repository.getAllProductMovements();
});

/// Ürün hareketi oluşturma provider'ı
final createProductMovementProvider = Provider<CreateProductMovementNotifier>((ref) {
  return CreateProductMovementNotifier(ref.read(productMovementRepositoryProvider));
});

/// Ürün hareketi oluşturma StateNotifier'ı
class CreateProductMovementNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseProductMovementRepository _repository;

  CreateProductMovementNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createMovement(ProductMovement movement) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createMovement(movement);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
