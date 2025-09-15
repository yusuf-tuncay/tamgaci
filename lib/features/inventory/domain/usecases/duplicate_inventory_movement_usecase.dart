import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_movement_repository.dart';

/// Envanter hareket kopyalama use case'i
class DuplicateInventoryMovementUseCase {
  final InventoryMovementRepository _repository;

  DuplicateInventoryMovementUseCase(this._repository);

  /// Envanter hareket kopyalar
  /// [id]: Kopyalanacak envanter hareket ID'si
  /// Returns: Kopyalanan envanter hareket
  Future<InventoryMovement> call(String id) async {
    return await _repository.duplicateInventoryMovement(id);
  }
}
