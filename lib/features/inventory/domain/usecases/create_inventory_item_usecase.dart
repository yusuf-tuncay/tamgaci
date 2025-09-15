import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_item_repository.dart';

/// Envanter öğesi oluşturma use case'i
class CreateInventoryItemUseCase {
  final InventoryItemRepository _repository;

  CreateInventoryItemUseCase(this._repository);

  /// Yeni envanter öğesi oluşturur
  /// [inventoryItem]: Oluşturulacak envanter öğesi
  /// Returns: Oluşturulan envanter öğesi
  Future<InventoryItem> call(InventoryItem inventoryItem) async {
    // Envanter öğesi numarası otomatik oluşturulacak
    final itemNumber =
        await _repository.generateInventoryItemNumber(inventoryItem.type);

    final newInventoryItem = inventoryItem.copyWith(
      sku: inventoryItem.sku ?? itemNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createInventoryItem(newInventoryItem);
  }
}
