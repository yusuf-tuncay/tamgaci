import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_movement_repository.dart';

/// Envanter hareket oluşturma use case'i
class CreateInventoryMovementUseCase {
  final InventoryMovementRepository _repository;

  CreateInventoryMovementUseCase(this._repository);

  /// Yeni envanter hareket oluşturur
  /// [inventoryMovement]: Oluşturulacak envanter hareket
  /// Returns: Oluşturulan envanter hareket
  Future<InventoryMovement> call(InventoryMovement inventoryMovement) async {
    // Envanter hareket numarası otomatik oluşturulacak
    final movementNumber = await _repository
        .generateInventoryMovementNumber(inventoryMovement.type);

    final newInventoryMovement = inventoryMovement.copyWith(
      movementNumber: movementNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createInventoryMovement(newInventoryMovement);
  }
}
