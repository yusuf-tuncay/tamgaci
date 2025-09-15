import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_item_repository.dart';
import 'package:tamgaci/features/inventory/data/datasources/inventory_item_firebase_datasource.dart';
import 'package:tamgaci/features/inventory/data/models/inventory_item_model.dart';

/// Inventory Item repository implementasyonu
/// Firebase Firestore işlemleri için repository
class InventoryItemRepositoryImpl implements InventoryItemRepository {
  final InventoryItemFirebaseDataSource _dataSource;

  InventoryItemRepositoryImpl({
    required InventoryItemFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<InventoryItem>> getAllInventoryItems({
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.getAllInventoryItems(
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<InventoryItem?> getInventoryItemById(String id) async {
    final inventoryItemModel = await _dataSource.getInventoryItemById(id);
    return inventoryItemModel?.toEntity();
  }

  @override
  Future<InventoryItem?> getInventoryItemBySku(String sku) async {
    final inventoryItemModel = await _dataSource.getInventoryItemBySku(sku);
    return inventoryItemModel?.toEntity();
  }

  @override
  Future<InventoryItem?> getInventoryItemByBarcode(String barcode) async {
    final inventoryItemModel =
        await _dataSource.getInventoryItemByBarcode(barcode);
    return inventoryItemModel?.toEntity();
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsByType(
    InventoryItemType type, {
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.getInventoryItemsByType(
      type,
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsByStatus(
    InventoryItemStatus status, {
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.getInventoryItemsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsByCategory(
    String category, {
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.getInventoryItemsByCategory(
      category,
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.getInventoryItemsBySupplier(
      supplierId,
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsByStockLevel(
    String stockLevel, {
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.getInventoryItemsByStockLevel(
      stockLevel,
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsAtReorderPoint({
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels =
        await _dataSource.getInventoryItemsAtReorderPoint(
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryItem>> getOutOfStockItems({
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.getOutOfStockItems(
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryItem>> getExpiringItems(
    int days, {
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.getExpiringItems(
      days,
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<InventoryItem> createInventoryItem(InventoryItem inventoryItem) async {
    final inventoryItemModel = InventoryItemModel.fromEntity(inventoryItem);
    final createdInventoryItemModel =
        await _dataSource.createInventoryItem(inventoryItemModel);
    return createdInventoryItemModel.toEntity();
  }

  @override
  Future<InventoryItem> updateInventoryItem(InventoryItem inventoryItem) async {
    final inventoryItemModel = InventoryItemModel.fromEntity(inventoryItem);
    final updatedInventoryItemModel =
        await _dataSource.updateInventoryItem(inventoryItemModel);
    return updatedInventoryItemModel.toEntity();
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    await _dataSource.deleteInventoryItem(id);
  }

  @override
  Future<InventoryItem> updateInventoryItemStatus(
      String id, InventoryItemStatus status) async {
    final inventoryItem = await getInventoryItemById(id);
    if (inventoryItem == null) {
      throw Exception('Envanter öğesi bulunamadı');
    }

    final updatedInventoryItem = inventoryItem.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    return await updateInventoryItem(updatedInventoryItem);
  }

  @override
  Future<InventoryItem> updateStockQuantity(String id, double quantity) async {
    final inventoryItem = await getInventoryItemById(id);
    if (inventoryItem == null) {
      throw Exception('Envanter öğesi bulunamadı');
    }

    final updatedInventoryItem = inventoryItem.copyWith(
      currentStock: quantity,
      updatedAt: DateTime.now(),
    );

    return await updateInventoryItem(updatedInventoryItem);
  }

  @override
  Future<List<InventoryItem>> searchInventoryItems(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final inventoryItemModels = await _dataSource.searchInventoryItems(
      query,
      limit: limit,
      offset: offset,
    );
    return inventoryItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getInventoryItemsCount() async {
    return await _dataSource.getInventoryItemsCount();
  }

  @override
  Future<int> getInventoryItemsCountByType(InventoryItemType type) async {
    final inventoryItems = await getInventoryItemsByType(type);
    return inventoryItems.length;
  }

  @override
  Future<double> getTotalStockValue({String? currency}) async {
    return await _dataSource.getTotalStockValue(currency: currency);
  }

  @override
  Future<double> getTotalStockValueByType(InventoryItemType type,
      {String? currency}) async {
    return await _dataSource.getTotalStockValueByType(type, currency: currency);
  }

  @override
  Future<Map<String, dynamic>> getInventoryItemsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    final inventoryItems = await getAllInventoryItems();

    final report = <String, dynamic>{
      'totalStockValue': 0.0,
      'totalCount': inventoryItems.length,
      'groupedData': <String, dynamic>{},
    };

    for (final inventoryItem in inventoryItems) {
      final stockValue = inventoryItem.currentStock * inventoryItem.unitCost;
      report['totalStockValue'] =
          (report['totalStockValue'] as double) + stockValue;

      if (groupBy != null) {
        String key;
        switch (groupBy) {
          case 'type':
            key = inventoryItem.type.name;
            break;
          case 'category':
            key = inventoryItem.category ?? 'Kategori Yok';
            break;
          case 'supplier':
            key = inventoryItem.supplierName ??
                inventoryItem.supplierId ??
                'Tedarikçi Yok';
            break;
          default:
            key = 'unknown';
        }

        if (!report['groupedData'].containsKey(key)) {
          report['groupedData'][key] = {
            'count': 0,
            'stockValue': 0.0,
          };
        }
        report['groupedData'][key]['count'] += 1;
        report['groupedData'][key]['stockValue'] += stockValue;
      }
    }

    return report;
  }

  @override
  Future<Map<String, dynamic>> getInventoryItemsStatistics() async {
    return await _dataSource.getInventoryItemsStatistics();
  }

  @override
  Future<String> generateInventoryItemNumber(InventoryItemType type) async {
    return await _dataSource.generateInventoryItemNumber(type);
  }

  @override
  Future<InventoryItem> duplicateInventoryItem(String id) async {
    final originalInventoryItem = await getInventoryItemById(id);
    if (originalInventoryItem == null) {
      throw Exception('Envanter öğesi bulunamadı');
    }

    final newItemNumber =
        await generateInventoryItemNumber(originalInventoryItem.type);

    final duplicatedInventoryItem = originalInventoryItem.copyWith(
      id: '', // Yeni ID oluşturulacak
      sku: newItemNumber,
      currentStock: 0.0, // Kopyalanan öğenin stoku sıfırlanır
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createInventoryItem(duplicatedInventoryItem);
  }

  @override
  Future<InventoryItem> archiveInventoryItem(String id) async {
    return await updateInventoryItemStatus(id, InventoryItemStatus.inactive);
  }

  @override
  Future<InventoryItem> activateInventoryItem(String id) async {
    return await updateInventoryItemStatus(id, InventoryItemStatus.active);
  }
}
