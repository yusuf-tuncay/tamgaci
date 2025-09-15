import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_item_repository.dart';

/// Envanter öğelerini getirme use case'i
class GetInventoryItemsUseCase {
  final InventoryItemRepository _repository;

  GetInventoryItemsUseCase(this._repository);

  /// Tüm envanter öğelerini getirir
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> call({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getAllInventoryItems(
      limit: limit,
      offset: offset,
    );
  }

  /// Türüne göre envanter öğelerini getirir
  /// [type]: Envanter öğesi türü
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getByType(
    InventoryItemType type, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryItemsByType(
      type,
      limit: limit,
      offset: offset,
    );
  }

  /// Duruma göre envanter öğelerini getirir
  /// [status]: Envanter öğesi durumu
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getByStatus(
    InventoryItemStatus status, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryItemsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
  }

  /// Kategoriye göre envanter öğelerini getirir
  /// [category]: Kategori
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getByCategory(
    String category, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryItemsByCategory(
      category,
      limit: limit,
      offset: offset,
    );
  }

  /// Tedarikçiye göre envanter öğelerini getirir
  /// [supplierId]: Tedarikçi ID'si
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryItemsBySupplier(
      supplierId,
      limit: limit,
      offset: offset,
    );
  }

  /// Stok seviyesine göre envanter öğelerini getirir
  /// [stockLevel]: Stok seviyesi (low, normal, high)
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getByStockLevel(
    String stockLevel, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryItemsByStockLevel(
      stockLevel,
      limit: limit,
      offset: offset,
    );
  }

  /// Yeniden sipariş noktasına ulaşan öğeleri getirir
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getAtReorderPoint({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryItemsAtReorderPoint(
      limit: limit,
      offset: offset,
    );
  }

  /// Stokta olmayan öğeleri getirir
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getOutOfStock({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getOutOfStockItems(
      limit: limit,
      offset: offset,
    );
  }

  /// Son kullanma tarihi yaklaşan öğeleri getirir
  /// [days]: Kaç gün içinde
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getExpiring(
    int days, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getExpiringItems(
      days,
      limit: limit,
      offset: offset,
    );
  }

  /// Envanter öğesi arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.searchInventoryItems(
      query,
      limit: limit,
      offset: offset,
    );
  }
}
