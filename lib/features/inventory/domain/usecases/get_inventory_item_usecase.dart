import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_item_repository.dart';

/// Tek envanter öğesi getirme use case'i
class GetInventoryItemUseCase {
  final InventoryItemRepository _repository;

  GetInventoryItemUseCase(this._repository);

  /// ID'ye göre envanter öğesi getirir
  /// [id]: Envanter öğesi ID'si
  /// Returns: Envanter öğesi veya null
  Future<InventoryItem?> call(String id) async {
    return await _repository.getInventoryItemById(id);
  }

  /// SKU'ya göre envanter öğesi getirir
  /// [sku]: SKU kodu
  /// Returns: Envanter öğesi veya null
  Future<InventoryItem?> getBySku(String sku) async {
    return await _repository.getInventoryItemBySku(sku);
  }

  /// Barkod'a göre envanter öğesi getirir
  /// [barcode]: Barkod
  /// Returns: Envanter öğesi veya null
  Future<InventoryItem?> getByBarcode(String barcode) async {
    return await _repository.getInventoryItemByBarcode(barcode);
  }
}
