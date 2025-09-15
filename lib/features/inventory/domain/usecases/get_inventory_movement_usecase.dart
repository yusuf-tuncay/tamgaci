import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_movement_repository.dart';

/// Tek envanter hareket getirme use case'i
class GetInventoryMovementUseCase {
  final InventoryMovementRepository _repository;

  GetInventoryMovementUseCase(this._repository);

  /// ID'ye göre envanter hareket getirir
  /// [id]: Envanter hareket ID'si
  /// Returns: Envanter hareket veya null
  Future<InventoryMovement?> call(String id) async {
    return await _repository.getInventoryMovementById(id);
  }

  /// Hareket numarasına göre envanter hareket getirir
  /// [movementNumber]: Hareket numarası
  /// Returns: Envanter hareket veya null
  Future<InventoryMovement?> getByNumber(String movementNumber) async {
    return await _repository.getInventoryMovementByNumber(movementNumber);
  }
}
