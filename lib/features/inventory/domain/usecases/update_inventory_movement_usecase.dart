import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_movement_repository.dart';

/// Envanter hareket güncelleme use case'i
class UpdateInventoryMovementUseCase {
  final InventoryMovementRepository _repository;

  UpdateInventoryMovementUseCase(this._repository);

  /// Envanter hareket günceller
  /// [inventoryMovement]: Güncellenecek envanter hareket
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> call(InventoryMovement inventoryMovement) async {
    final updatedInventoryMovement = inventoryMovement.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateInventoryMovement(updatedInventoryMovement);
  }

  /// Envanter hareket durumunu günceller
  /// [id]: Envanter hareket ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> updateStatus(
      String id, InventoryMovementStatus status) async {
    return await _repository.updateInventoryMovementStatus(id, status);
  }

  /// Envanter hareket onaylar
  /// [id]: Envanter hareket ID'si
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> approve(String id) async {
    return await _repository.approveInventoryMovement(id);
  }

  /// Envanter hareket tamamlar
  /// [id]: Envanter hareket ID'si
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> complete(String id) async {
    return await _repository.completeInventoryMovement(id);
  }

  /// Envanter hareket iptal eder
  /// [id]: Envanter hareket ID'si
  /// [reason]: İptal nedeni
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> cancel(String id, String reason) async {
    return await _repository.cancelInventoryMovement(id, reason);
  }
}
