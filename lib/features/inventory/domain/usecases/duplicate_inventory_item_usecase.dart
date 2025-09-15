import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_item_repository.dart';

/// Envanter öğesi kopyalama use case'i
class DuplicateInventoryItemUseCase {
  final InventoryItemRepository _repository;

  DuplicateInventoryItemUseCase(this._repository);

  /// Envanter öğesi kopyalar
  /// [id]: Kopyalanacak envanter öğesi ID'si
  /// Returns: Kopyalanan envanter öğesi
  Future<InventoryItem> call(String id) async {
    return await _repository.duplicateInventoryItem(id);
  }
}
