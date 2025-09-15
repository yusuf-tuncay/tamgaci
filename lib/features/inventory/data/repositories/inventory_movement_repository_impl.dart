import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_movement_repository.dart';
import 'package:tamgaci/features/inventory/data/datasources/inventory_movement_firebase_datasource.dart';
import 'package:tamgaci/features/inventory/data/models/inventory_movement_model.dart';

/// Inventory Movement repository implementasyonu
/// Firebase Firestore işlemleri için repository
class InventoryMovementRepositoryImpl implements InventoryMovementRepository {
  final InventoryMovementFirebaseDataSource _dataSource;

  InventoryMovementRepositoryImpl({
    required InventoryMovementFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<InventoryMovement>> getAllInventoryMovements({
    int? limit,
    int? offset,
  }) async {
    final inventoryMovementModels = await _dataSource.getAllInventoryMovements(
      limit: limit,
      offset: offset,
    );
    return inventoryMovementModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<InventoryMovement?> getInventoryMovementById(String id) async {
    final inventoryMovementModel =
        await _dataSource.getInventoryMovementById(id);
    return inventoryMovementModel?.toEntity();
  }

  @override
  Future<InventoryMovement?> getInventoryMovementByNumber(
      String movementNumber) async {
    final inventoryMovementModel =
        await _dataSource.getInventoryMovementByNumber(movementNumber);
    return inventoryMovementModel?.toEntity();
  }

  @override
  Future<List<InventoryMovement>> getInventoryMovementsByItem(
    String itemId, {
    int? limit,
    int? offset,
  }) async {
    final inventoryMovementModels =
        await _dataSource.getInventoryMovementsByItem(
      itemId,
      limit: limit,
      offset: offset,
    );
    return inventoryMovementModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryMovement>> getInventoryMovementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    final inventoryMovementModels =
        await _dataSource.getInventoryMovementsByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
    return inventoryMovementModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryMovement>> getInventoryMovementsByType(
    InventoryMovementType type, {
    int? limit,
    int? offset,
  }) async {
    final inventoryMovementModels =
        await _dataSource.getInventoryMovementsByType(
      type,
      limit: limit,
      offset: offset,
    );
    return inventoryMovementModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryMovement>> getInventoryMovementsByStatus(
    InventoryMovementStatus status, {
    int? limit,
    int? offset,
  }) async {
    final inventoryMovementModels =
        await _dataSource.getInventoryMovementsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
    return inventoryMovementModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryMovement>> getInventoryMovementsByLocation(
    String location, {
    int? limit,
    int? offset,
  }) async {
    final inventoryMovementModels =
        await _dataSource.getInventoryMovementsByLocation(
      location,
      limit: limit,
      offset: offset,
    );
    return inventoryMovementModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventoryMovement>> getInventoryMovementsByReference(
    String referenceType,
    String referenceId, {
    int? limit,
    int? offset,
  }) async {
    final inventoryMovementModels =
        await _dataSource.getInventoryMovementsByReference(
      referenceType,
      referenceId,
      limit: limit,
      offset: offset,
    );
    return inventoryMovementModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<InventoryMovement> createInventoryMovement(
      InventoryMovement inventoryMovement) async {
    final inventoryMovementModel =
        InventoryMovementModel.fromEntity(inventoryMovement);
    final createdInventoryMovementModel =
        await _dataSource.createInventoryMovement(inventoryMovementModel);
    return createdInventoryMovementModel.toEntity();
  }

  @override
  Future<InventoryMovement> updateInventoryMovement(
      InventoryMovement inventoryMovement) async {
    final inventoryMovementModel =
        InventoryMovementModel.fromEntity(inventoryMovement);
    final updatedInventoryMovementModel =
        await _dataSource.updateInventoryMovement(inventoryMovementModel);
    return updatedInventoryMovementModel.toEntity();
  }

  @override
  Future<void> deleteInventoryMovement(String id) async {
    await _dataSource.deleteInventoryMovement(id);
  }

  @override
  Future<InventoryMovement> updateInventoryMovementStatus(
      String id, InventoryMovementStatus status) async {
    final inventoryMovement = await getInventoryMovementById(id);
    if (inventoryMovement == null) {
      throw Exception('Envanter hareket bulunamadı');
    }

    final updatedInventoryMovement = inventoryMovement.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    return await updateInventoryMovement(updatedInventoryMovement);
  }

  @override
  Future<List<InventoryMovement>> searchInventoryMovements(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final inventoryMovementModels = await _dataSource.searchInventoryMovements(
      query,
      limit: limit,
      offset: offset,
    );
    return inventoryMovementModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getInventoryMovementsCount() async {
    return await _dataSource.getInventoryMovementsCount();
  }

  @override
  Future<int> getInventoryMovementsCountByItem(String itemId) async {
    final inventoryMovements = await getInventoryMovementsByItem(itemId);
    return inventoryMovements.length;
  }

  @override
  Future<int> getInventoryMovementsCountByDateRange(
      DateTime startDate, DateTime endDate) async {
    final inventoryMovements =
        await getInventoryMovementsByDateRange(startDate, endDate);
    return inventoryMovements.length;
  }

  @override
  Future<double> getInventoryMovementsTotal({
    DateTime? startDate,
    DateTime? endDate,
    InventoryMovementType? type,
  }) async {
    return await _dataSource.getInventoryMovementsTotal(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  @override
  Future<double> getInventoryMovementsTotalByItem(
    String itemId, {
    DateTime? startDate,
    DateTime? endDate,
    InventoryMovementType? type,
  }) async {
    final inventoryMovements = await getInventoryMovementsByItem(itemId);

    if (startDate != null && endDate != null) {
      final filteredMovements = inventoryMovements.where((movement) {
        return movement.movementDate.isAfter(startDate) &&
            movement.movementDate.isBefore(endDate);
      }).toList();

      if (type != null) {
        final typeFilteredMovements = filteredMovements.where((movement) {
          return movement.type == type;
        }).toList();

        return typeFilteredMovements.fold<double>(
            0.0, (double sum, movement) => sum + movement.totalCost);
      }

      return filteredMovements.fold<double>(
          0.0, (double sum, movement) => sum + movement.totalCost);
    }

    if (type != null) {
      final typeFilteredMovements = inventoryMovements.where((movement) {
        return movement.type == type;
      }).toList();

      return typeFilteredMovements.fold<double>(
          0.0, (double sum, movement) => sum + movement.totalCost);
    }

    return inventoryMovements.fold<double>(
        0.0, (double sum, movement) => sum + movement.totalCost);
  }

  @override
  Future<Map<String, dynamic>> getInventoryMovementsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    final inventoryMovements =
        await getInventoryMovementsByDateRange(startDate, endDate);

    final report = <String, dynamic>{
      'totalCost': 0.0,
      'totalCount': inventoryMovements.length,
      'groupedData': <String, dynamic>{},
    };

    for (final inventoryMovement in inventoryMovements) {
      report['totalCost'] =
          (report['totalCost'] as double) + inventoryMovement.totalCost;

      if (groupBy != null) {
        String key;
        switch (groupBy) {
          case 'type':
            key = inventoryMovement.type.name;
            break;
          case 'item':
            key = inventoryMovement.itemName ?? inventoryMovement.itemId;
            break;
          case 'location':
            key = inventoryMovement.toLocation ??
                inventoryMovement.fromLocation ??
                'Lokasyon Yok';
            break;
          default:
            key = 'unknown';
        }

        if (!report['groupedData'].containsKey(key)) {
          report['groupedData'][key] = {
            'count': 0,
            'cost': 0.0,
          };
        }
        report['groupedData'][key]['count'] += 1;
        report['groupedData'][key]['cost'] += inventoryMovement.totalCost;
      }
    }

    return report;
  }

  @override
  Future<List<Map<String, dynamic>>> getTopMovedItems({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getTopMovedItems(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTopLocations({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getTopLocations(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Map<String, dynamic>> getInventoryMovementsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getInventoryMovementsStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<String> generateInventoryMovementNumber(
      InventoryMovementType type) async {
    return await _dataSource.generateInventoryMovementNumber(type);
  }

  @override
  Future<InventoryMovement> duplicateInventoryMovement(String id) async {
    final originalInventoryMovement = await getInventoryMovementById(id);
    if (originalInventoryMovement == null) {
      throw Exception('Envanter hareket bulunamadı');
    }

    final newMovementNumber =
        await generateInventoryMovementNumber(originalInventoryMovement.type);

    final duplicatedInventoryMovement = originalInventoryMovement.copyWith(
      id: '', // Yeni ID oluşturulacak
      movementNumber: newMovementNumber,
      status: InventoryMovementStatus.pending,
      movementDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createInventoryMovement(duplicatedInventoryMovement);
  }

  @override
  Future<InventoryMovement> cancelInventoryMovement(
      String id, String reason) async {
    final inventoryMovement = await getInventoryMovementById(id);
    if (inventoryMovement == null) {
      throw Exception('Envanter hareket bulunamadı');
    }

    final cancelledInventoryMovement = inventoryMovement.copyWith(
      status: InventoryMovementStatus.cancelled,
      notes: '${inventoryMovement.notes ?? ''}\nİptal nedeni: $reason'.trim(),
      updatedAt: DateTime.now(),
    );

    return await updateInventoryMovement(cancelledInventoryMovement);
  }

  @override
  Future<InventoryMovement> approveInventoryMovement(String id) async {
    return await updateInventoryMovementStatus(
        id, InventoryMovementStatus.completed);
  }

  @override
  Future<InventoryMovement> completeInventoryMovement(String id) async {
    return await updateInventoryMovementStatus(
        id, InventoryMovementStatus.completed);
  }
}
