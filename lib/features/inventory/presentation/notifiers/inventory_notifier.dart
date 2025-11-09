import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';
import 'package:tamgaci/features/inventory/domain/usecases/create_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_items_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/update_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/delete_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_items_statistics_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/duplicate_inventory_item_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/create_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_movements_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/update_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/delete_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/get_inventory_movements_statistics_usecase.dart';
import 'package:tamgaci/features/inventory/domain/usecases/duplicate_inventory_movement_usecase.dart';
import 'package:tamgaci/features/inventory/presentation/states/inventory_state.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Inventory state notifier
class InventoryNotifier extends StateNotifier<InventoryState> {
  // Inventory Item Use Cases
  final CreateInventoryItemUseCase _createInventoryItemUseCase;
  final GetInventoryItemsUseCase _getInventoryItemsUseCase;
  final GetInventoryItemUseCase _getInventoryItemUseCase;
  final UpdateInventoryItemUseCase _updateInventoryItemUseCase;
  final DeleteInventoryItemUseCase _deleteInventoryItemUseCase;
  final GetInventoryItemsStatisticsUseCase _getInventoryItemsStatisticsUseCase;
  final DuplicateInventoryItemUseCase _duplicateInventoryItemUseCase;

  // Inventory Movement Use Cases
  final CreateInventoryMovementUseCase _createInventoryMovementUseCase;
  final GetInventoryMovementsUseCase _getInventoryMovementsUseCase;
  final GetInventoryMovementUseCase _getInventoryMovementUseCase;
  final UpdateInventoryMovementUseCase _updateInventoryMovementUseCase;
  final DeleteInventoryMovementUseCase _deleteInventoryMovementUseCase;
  final GetInventoryMovementsStatisticsUseCase
      _getInventoryMovementsStatisticsUseCase;
  final DuplicateInventoryMovementUseCase _duplicateInventoryMovementUseCase;

  InventoryNotifier({
    required CreateInventoryItemUseCase createInventoryItemUseCase,
    required GetInventoryItemsUseCase getInventoryItemsUseCase,
    required GetInventoryItemUseCase getInventoryItemUseCase,
    required UpdateInventoryItemUseCase updateInventoryItemUseCase,
    required DeleteInventoryItemUseCase deleteInventoryItemUseCase,
    required GetInventoryItemsStatisticsUseCase
        getInventoryItemsStatisticsUseCase,
    required DuplicateInventoryItemUseCase duplicateInventoryItemUseCase,
    required CreateInventoryMovementUseCase createInventoryMovementUseCase,
    required GetInventoryMovementsUseCase getInventoryMovementsUseCase,
    required GetInventoryMovementUseCase getInventoryMovementUseCase,
    required UpdateInventoryMovementUseCase updateInventoryMovementUseCase,
    required DeleteInventoryMovementUseCase deleteInventoryMovementUseCase,
    required GetInventoryMovementsStatisticsUseCase
        getInventoryMovementsStatisticsUseCase,
    required DuplicateInventoryMovementUseCase
        duplicateInventoryMovementUseCase,
  })  : _createInventoryItemUseCase = createInventoryItemUseCase,
        _getInventoryItemsUseCase = getInventoryItemsUseCase,
        _getInventoryItemUseCase = getInventoryItemUseCase,
        _updateInventoryItemUseCase = updateInventoryItemUseCase,
        _deleteInventoryItemUseCase = deleteInventoryItemUseCase,
        _getInventoryItemsStatisticsUseCase =
            getInventoryItemsStatisticsUseCase,
        _duplicateInventoryItemUseCase = duplicateInventoryItemUseCase,
        _createInventoryMovementUseCase = createInventoryMovementUseCase,
        _getInventoryMovementsUseCase = getInventoryMovementsUseCase,
        _getInventoryMovementUseCase = getInventoryMovementUseCase,
        _updateInventoryMovementUseCase = updateInventoryMovementUseCase,
        _deleteInventoryMovementUseCase = deleteInventoryMovementUseCase,
        _getInventoryMovementsStatisticsUseCase =
            getInventoryMovementsStatisticsUseCase,
        _duplicateInventoryMovementUseCase = duplicateInventoryMovementUseCase,
        super(const InventoryState());

  // Inventory Item Methods

  /// Tüm envanter öğelerini getirir
  Future<void> getInventoryItems({
    int? limit,
    int? offset,
  }) async {
    AppLogger.info(
        'getInventoryItems başlatıldı - limit: $limit, offset: $offset');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.call(
        limit: limit,
        offset: offset,
      );

      AppLogger.info(
          'getInventoryItems başarılı - ${inventoryItems.length} öğe getirildi');
      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('getInventoryItems hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Türüne göre envanter öğelerini getirir
  Future<void> getInventoryItemsByType(
    InventoryItemType type, {
    int? limit,
    int? offset,
  }) async {
    AppLogger.info(
        'getInventoryItemsByType başlatıldı - type: $type, limit: $limit, offset: $offset');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.getByType(
        type,
        limit: limit,
        offset: offset,
      );

      AppLogger.info(
          'getInventoryItemsByType başarılı - ${inventoryItems.length} öğe getirildi');
      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('getInventoryItemsByType hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Duruma göre envanter öğelerini getirir
  Future<void> getInventoryItemsByStatus(
    InventoryItemStatus status, {
    int? limit,
    int? offset,
  }) async {
    AppLogger.info(
        'getInventoryItemsByStatus başlatıldı - status: $status, limit: $limit, offset: $offset');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.getByStatus(
        status,
        limit: limit,
        offset: offset,
      );

      AppLogger.info(
          'getInventoryItemsByStatus başarılı - ${inventoryItems.length} öğe getirildi');
      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('getInventoryItemsByStatus hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Kategoriye göre envanter öğelerini getirir
  Future<void> getInventoryItemsByCategory(
    String category, {
    int? limit,
    int? offset,
  }) async {
    AppLogger.info(
        'getInventoryItemsByCategory başlatıldı - category: $category, limit: $limit, offset: $offset');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.getByCategory(
        category,
        limit: limit,
        offset: offset,
      );

      AppLogger.info(
          'getInventoryItemsByCategory başarılı - ${inventoryItems.length} öğe getirildi');
      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('getInventoryItemsByCategory hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tedarikçiye göre envanter öğelerini getirir
  Future<void> getInventoryItemsBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.getBySupplier(
        supplierId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Stok seviyesine göre envanter öğelerini getirir
  Future<void> getInventoryItemsByStockLevel(
    String stockLevel, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.getByStockLevel(
        stockLevel,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeniden sipariş noktasına ulaşan öğeleri getirir
  Future<void> getInventoryItemsAtReorderPoint({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.getAtReorderPoint(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Stokta olmayan öğeleri getirir
  Future<void> getOutOfStockItems({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.getOutOfStock(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Son kullanma tarihi yaklaşan öğeleri getirir
  Future<void> getExpiringItems(
    int days, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.getExpiring(
        days,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğesi arama
  Future<void> searchInventoryItems(
    String query, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItems = await _getInventoryItemsUseCase.search(
        query,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryItems: inventoryItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tek envanter öğesi getirir
  Future<void> getInventoryItem(String id) async {
    AppLogger.info('getInventoryItem başlatıldı - id: $id');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItem = await _getInventoryItemUseCase.call(id);

      AppLogger.info('getInventoryItem başarılı - id: $id');
      state = state.copyWith(
        isLoading: false,
        selectedInventoryItem: inventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error('getInventoryItem hatası - id: $id', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// SKU'ya göre envanter öğesi getirir
  Future<void> getInventoryItemBySku(String sku) async {
    AppLogger.info('getInventoryItemBySku başlatıldı - sku: $sku');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItem = await _getInventoryItemUseCase.getBySku(sku);

      AppLogger.info('getInventoryItemBySku başarılı - sku: $sku');
      state = state.copyWith(
        isLoading: false,
        selectedInventoryItem: inventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
          'getInventoryItemBySku hatası - sku: $sku', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Barkod'a göre envanter öğesi getirir
  Future<void> getInventoryItemByBarcode(String barcode) async {
    AppLogger.info('getInventoryItemByBarcode başlatıldı - barcode: $barcode');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryItem =
          await _getInventoryItemUseCase.getByBarcode(barcode);

      AppLogger.info('getInventoryItemByBarcode başarılı - barcode: $barcode');
      state = state.copyWith(
        isLoading: false,
        selectedInventoryItem: inventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error('getInventoryItemByBarcode hatası - barcode: $barcode', e,
          stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeni envanter öğesi oluşturur
  Future<void> createInventoryItem(InventoryItem inventoryItem) async {
    AppLogger.info(
        'createInventoryItem başlatıldı - id: ${inventoryItem.id}, name: ${inventoryItem.name}');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdInventoryItem =
          await _createInventoryItemUseCase.call(inventoryItem);

      AppLogger.info(
          'createInventoryItem başarılı - id: ${createdInventoryItem.id}');
      state = state.copyWith(
        isLoading: false,
        inventoryItems: [...state.inventoryItems, createdInventoryItem],
      );
    } catch (e, stackTrace) {
      AppLogger.error('createInventoryItem hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğesi günceller
  Future<void> updateInventoryItem(InventoryItem inventoryItem) async {
    AppLogger.info('updateInventoryItem başlatıldı - id: ${inventoryItem.id}');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryItem =
          await _updateInventoryItemUseCase.call(inventoryItem);

      AppLogger.info(
          'updateInventoryItem başarılı - id: ${updatedInventoryItem.id}');
      final updatedInventoryItems = state.inventoryItems.map((item) {
        return item.id == updatedInventoryItem.id ? updatedInventoryItem : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryItems: updatedInventoryItems,
        selectedInventoryItem:
            state.selectedInventoryItem?.id == updatedInventoryItem.id
                ? updatedInventoryItem
                : state.selectedInventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error('updateInventoryItem hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğesi durumunu günceller
  Future<void> updateInventoryItemStatus(
      String id, InventoryItemStatus status) async {
    AppLogger.info(
        'updateInventoryItemStatus başlatıldı - id: $id, status: $status');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryItem =
          await _updateInventoryItemUseCase.updateStatus(id, status);

      AppLogger.info('updateInventoryItemStatus başarılı - id: $id');
      final updatedInventoryItems = state.inventoryItems.map((item) {
        return item.id == updatedInventoryItem.id ? updatedInventoryItem : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryItems: updatedInventoryItems,
        selectedInventoryItem:
            state.selectedInventoryItem?.id == updatedInventoryItem.id
                ? updatedInventoryItem
                : state.selectedInventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
          'updateInventoryItemStatus hatası - id: $id', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Stok miktarını günceller
  Future<void> updateStockQuantity(String id, double quantity) async {
    AppLogger.info(
        'updateStockQuantity başlatıldı - id: $id, quantity: $quantity');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryItem =
          await _updateInventoryItemUseCase.updateStockQuantity(id, quantity);

      AppLogger.info(
          'updateStockQuantity başarılı - id: $id, yeni miktar: ${updatedInventoryItem.currentStock}');
      final updatedInventoryItems = state.inventoryItems.map((item) {
        return item.id == updatedInventoryItem.id ? updatedInventoryItem : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryItems: updatedInventoryItems,
        selectedInventoryItem:
            state.selectedInventoryItem?.id == updatedInventoryItem.id
                ? updatedInventoryItem
                : state.selectedInventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error('updateStockQuantity hatası - id: $id', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğesi siler
  Future<void> deleteInventoryItem(String id) async {
    AppLogger.info('deleteInventoryItem başlatıldı - id: $id');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteInventoryItemUseCase.call(id);

      AppLogger.info('deleteInventoryItem başarılı - id: $id');
      final updatedInventoryItems =
          state.inventoryItems.where((item) => item.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryItems: updatedInventoryItems,
        selectedInventoryItem: state.selectedInventoryItem?.id == id
            ? null
            : state.selectedInventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error('deleteInventoryItem hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğesi kopyalar
  Future<void> duplicateInventoryItem(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final duplicatedInventoryItem =
          await _duplicateInventoryItemUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        inventoryItems: [...state.inventoryItems, duplicatedInventoryItem],
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğesi arşivler
  Future<void> archiveInventoryItem(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryItem =
          await _updateInventoryItemUseCase.archive(id);

      final updatedInventoryItems = state.inventoryItems.map((item) {
        return item.id == updatedInventoryItem.id ? updatedInventoryItem : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryItems: updatedInventoryItems,
        selectedInventoryItem:
            state.selectedInventoryItem?.id == updatedInventoryItem.id
                ? updatedInventoryItem
                : state.selectedInventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğesi aktifleştirir
  Future<void> activateInventoryItem(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryItem =
          await _updateInventoryItemUseCase.activate(id);

      final updatedInventoryItems = state.inventoryItems.map((item) {
        return item.id == updatedInventoryItem.id ? updatedInventoryItem : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryItems: updatedInventoryItems,
        selectedInventoryItem:
            state.selectedInventoryItem?.id == updatedInventoryItem.id
                ? updatedInventoryItem
                : state.selectedInventoryItem,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğeleri istatistiklerini getirir
  Future<void> getInventoryItemsStatistics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _getInventoryItemsStatisticsUseCase.call();

      state = state.copyWith(
        isLoading: false,
        inventoryItemsStatistics: statistics,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter öğeleri raporu oluşturur
  Future<void> getInventoryItemsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _getInventoryItemsStatisticsUseCase.getReport(
        startDate,
        endDate,
        groupBy: groupBy,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryItemsReport: report,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Inventory Movement Methods

  /// Tüm envanter hareketlerini getirir
  Future<void> getInventoryMovements({
    int? limit,
    int? offset,
  }) async {
    AppLogger.info(
        'getInventoryMovements başlatıldı - limit: $limit, offset: $offset');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovements = await _getInventoryMovementsUseCase.call(
        limit: limit,
        offset: offset,
      );

      AppLogger.info(
          'getInventoryMovements başarılı - ${inventoryMovements.length} hareket getirildi');
      state = state.copyWith(
        isLoading: false,
        inventoryMovements: inventoryMovements,
      );
    } catch (e, stackTrace) {
      AppLogger.error('getInventoryMovements hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Öğeye göre envanter hareketleri getirir
  Future<void> getInventoryMovementsByItem(
    String itemId, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovements = await _getInventoryMovementsUseCase.getByItem(
        itemId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: inventoryMovements,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tarih aralığına göre envanter hareketleri getirir
  Future<void> getInventoryMovementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovements =
          await _getInventoryMovementsUseCase.getByDateRange(
        startDate,
        endDate,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: inventoryMovements,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Türüne göre envanter hareketleri getirir
  Future<void> getInventoryMovementsByType(
    InventoryMovementType type, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovements = await _getInventoryMovementsUseCase.getByType(
        type,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: inventoryMovements,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Duruma göre envanter hareketleri getirir
  Future<void> getInventoryMovementsByStatus(
    InventoryMovementStatus status, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovements =
          await _getInventoryMovementsUseCase.getByStatus(
        status,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: inventoryMovements,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Lokasyona göre envanter hareketleri getirir
  Future<void> getInventoryMovementsByLocation(
    String location, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovements =
          await _getInventoryMovementsUseCase.getByLocation(
        location,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: inventoryMovements,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Referansa göre envanter hareketleri getirir
  Future<void> getInventoryMovementsByReference(
    String referenceType,
    String referenceId, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovements =
          await _getInventoryMovementsUseCase.getByReference(
        referenceType,
        referenceId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: inventoryMovements,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareket arama
  Future<void> searchInventoryMovements(
    String query, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovements = await _getInventoryMovementsUseCase.search(
        query,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: inventoryMovements,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tek envanter hareket getirir
  Future<void> getInventoryMovement(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovement = await _getInventoryMovementUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        selectedInventoryMovement: inventoryMovement,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Hareket numarasına göre envanter hareket getirir
  Future<void> getInventoryMovementByNumber(String movementNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final inventoryMovement =
          await _getInventoryMovementUseCase.getByNumber(movementNumber);

      state = state.copyWith(
        isLoading: false,
        selectedInventoryMovement: inventoryMovement,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeni envanter hareket oluşturur
  Future<void> createInventoryMovement(
      InventoryMovement inventoryMovement) async {
    AppLogger.info(
        'createInventoryMovement başlatıldı - id: ${inventoryMovement.id}, type: ${inventoryMovement.type}');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdInventoryMovement =
          await _createInventoryMovementUseCase.call(inventoryMovement);

      AppLogger.info(
          'createInventoryMovement başarılı - id: ${createdInventoryMovement.id}');
      state = state.copyWith(
        isLoading: false,
        inventoryMovements: [
          ...state.inventoryMovements,
          createdInventoryMovement
        ],
      );
    } catch (e, stackTrace) {
      AppLogger.error('createInventoryMovement hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareket günceller
  Future<void> updateInventoryMovement(
      InventoryMovement inventoryMovement) async {
    AppLogger.info(
        'updateInventoryMovement başlatıldı - id: ${inventoryMovement.id}');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryMovement =
          await _updateInventoryMovementUseCase.call(inventoryMovement);

      AppLogger.info(
          'updateInventoryMovement başarılı - id: ${updatedInventoryMovement.id}');
      final updatedInventoryMovements =
          state.inventoryMovements.map((movement) {
        return movement.id == updatedInventoryMovement.id
            ? updatedInventoryMovement
            : movement;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: updatedInventoryMovements,
        selectedInventoryMovement:
            state.selectedInventoryMovement?.id == updatedInventoryMovement.id
                ? updatedInventoryMovement
                : state.selectedInventoryMovement,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
          'updateInventoryMovement hatası - id: ${inventoryMovement.id}',
          e,
          stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareket durumunu günceller
  Future<void> updateInventoryMovementStatus(
      String id, InventoryMovementStatus status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryMovement =
          await _updateInventoryMovementUseCase.updateStatus(id, status);

      final updatedInventoryMovements =
          state.inventoryMovements.map((movement) {
        return movement.id == updatedInventoryMovement.id
            ? updatedInventoryMovement
            : movement;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: updatedInventoryMovements,
        selectedInventoryMovement:
            state.selectedInventoryMovement?.id == updatedInventoryMovement.id
                ? updatedInventoryMovement
                : state.selectedInventoryMovement,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareket onaylar
  Future<void> approveInventoryMovement(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryMovement =
          await _updateInventoryMovementUseCase.approve(id);

      final updatedInventoryMovements =
          state.inventoryMovements.map((movement) {
        return movement.id == updatedInventoryMovement.id
            ? updatedInventoryMovement
            : movement;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: updatedInventoryMovements,
        selectedInventoryMovement:
            state.selectedInventoryMovement?.id == updatedInventoryMovement.id
                ? updatedInventoryMovement
                : state.selectedInventoryMovement,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareket tamamlar
  Future<void> completeInventoryMovement(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryMovement =
          await _updateInventoryMovementUseCase.complete(id);

      final updatedInventoryMovements =
          state.inventoryMovements.map((movement) {
        return movement.id == updatedInventoryMovement.id
            ? updatedInventoryMovement
            : movement;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: updatedInventoryMovements,
        selectedInventoryMovement:
            state.selectedInventoryMovement?.id == updatedInventoryMovement.id
                ? updatedInventoryMovement
                : state.selectedInventoryMovement,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareket iptal eder
  Future<void> cancelInventoryMovement(String id, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedInventoryMovement =
          await _updateInventoryMovementUseCase.cancel(id, reason);

      final updatedInventoryMovements =
          state.inventoryMovements.map((movement) {
        return movement.id == updatedInventoryMovement.id
            ? updatedInventoryMovement
            : movement;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: updatedInventoryMovements,
        selectedInventoryMovement:
            state.selectedInventoryMovement?.id == updatedInventoryMovement.id
                ? updatedInventoryMovement
                : state.selectedInventoryMovement,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareket siler
  Future<void> deleteInventoryMovement(String id) async {
    AppLogger.info('deleteInventoryMovement başlatıldı - id: $id');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteInventoryMovementUseCase.call(id);

      AppLogger.info('deleteInventoryMovement başarılı - id: $id');
      final updatedInventoryMovements = state.inventoryMovements
          .where((movement) => movement.id != id)
          .toList();

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: updatedInventoryMovements,
        selectedInventoryMovement: state.selectedInventoryMovement?.id == id
            ? null
            : state.selectedInventoryMovement,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
          'deleteInventoryMovement hatası - id: $id', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareket kopyalar
  Future<void> duplicateInventoryMovement(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final duplicatedInventoryMovement =
          await _duplicateInventoryMovementUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        inventoryMovements: [
          ...state.inventoryMovements,
          duplicatedInventoryMovement
        ],
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareketleri istatistiklerini getirir
  Future<void> getInventoryMovementsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _getInventoryMovementsStatisticsUseCase.call(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovementsStatistics: statistics,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Envanter hareketleri raporu oluşturur
  Future<void> getInventoryMovementsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _getInventoryMovementsStatisticsUseCase.getReport(
        startDate,
        endDate,
        groupBy: groupBy,
      );

      state = state.copyWith(
        isLoading: false,
        inventoryMovementsReport: report,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// En çok hareket edilen öğeleri getirir
  Future<void> getTopMovedItems({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topMovedItems =
          await _getInventoryMovementsStatisticsUseCase.getTopMovedItems(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        topMovedItems: topMovedItems,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// En çok hareket edilen lokasyonları getirir
  Future<void> getTopLocations({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topLocations =
          await _getInventoryMovementsStatisticsUseCase.getTopLocations(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        topLocations: topLocations,
      );
    } catch (e, stackTrace) {
      AppLogger.error('InventoryNotifier metod hatası', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Seçili envanter öğesi temizler
  void clearSelectedInventoryItem() {
    state = state.copyWith(selectedInventoryItem: null);
  }

  /// Seçili envanter hareket temizler
  void clearSelectedInventoryMovement() {
    state = state.copyWith(selectedInventoryMovement: null);
  }

  /// Hata mesajını temizler
  void clearError() {
    state = state.copyWith(error: null);
  }
}
