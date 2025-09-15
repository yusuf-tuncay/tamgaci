import 'package:tamgaci/features/inventory/domain/repositories/inventory_item_repository.dart';

/// Envanter öğesi silme use case'i
class DeleteInventoryItemUseCase {
  final InventoryItemRepository _repository;

  DeleteInventoryItemUseCase(this._repository);

  /// Envanter öğesi siler
  /// [id]: Silinecek envanter öğesi ID'si
  Future<void> call(String id) async {
    await _repository.deleteInventoryItem(id);
  }
}
