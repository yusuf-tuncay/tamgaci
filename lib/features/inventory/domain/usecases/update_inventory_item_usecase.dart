import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_item_repository.dart';

/// Envanter öğesi güncelleme use case'i
class UpdateInventoryItemUseCase {
  final InventoryItemRepository _repository;

  UpdateInventoryItemUseCase(this._repository);

  /// Envanter öğesi günceller
  /// [inventoryItem]: Güncellenecek envanter öğesi
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> call(InventoryItem inventoryItem) async {
    final updatedInventoryItem = inventoryItem.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateInventoryItem(updatedInventoryItem);
  }

  /// Envanter öğesi durumunu günceller
  /// [id]: Envanter öğesi ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> updateStatus(
      String id, InventoryItemStatus status) async {
    return await _repository.updateInventoryItemStatus(id, status);
  }

  /// Stok miktarını günceller
  /// [id]: Envanter öğesi ID'si
  /// [quantity]: Yeni stok miktarı
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> updateStockQuantity(String id, double quantity) async {
    return await _repository.updateStockQuantity(id, quantity);
  }

  /// Envanter öğesi arşivler
  /// [id]: Envanter öğesi ID'si
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> archive(String id) async {
    return await _repository.archiveInventoryItem(id);
  }

  /// Envanter öğesi aktifleştirir
  /// [id]: Envanter öğesi ID'si
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> activate(String id) async {
    return await _repository.activateInventoryItem(id);
  }
}
