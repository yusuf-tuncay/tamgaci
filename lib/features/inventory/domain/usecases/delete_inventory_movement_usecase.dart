import 'package:tamgaci/features/inventory/domain/repositories/inventory_movement_repository.dart';

/// Envanter hareket silme use case'i
class DeleteInventoryMovementUseCase {
  final InventoryMovementRepository _repository;

  DeleteInventoryMovementUseCase(this._repository);

  /// Envanter hareket siler
  /// [id]: Silinecek envanter hareket ID'si
  Future<void> call(String id) async {
    await _repository.deleteInventoryMovement(id);
  }
}
