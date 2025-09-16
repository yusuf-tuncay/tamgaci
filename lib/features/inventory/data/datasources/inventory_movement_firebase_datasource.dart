import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/inventory/data/models/inventory_movement_model.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';

/// InventoryMovement Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class InventoryMovementFirebaseDataSource {
  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth;

  InventoryMovementFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm envanter hareketlerini getirir
  Future<List<InventoryMovementModel>> getAllInventoryMovements({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_movements')
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_movements')
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all inventory movements', e);
      rethrow;
    }
  }

  /// ID'ye göre envanter hareket getirir
  Future<InventoryMovementModel?> getInventoryMovementById(String id) async {
    try {
      final doc =
          await _firestore.collection('inventory_movements').doc(id).get();
      if (doc.exists) {
        return InventoryMovementModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting inventory movement by id: $id', e);
      rethrow;
    }
  }

  /// Hareket numarasına göre envanter hareket getirir
  Future<InventoryMovementModel?> getInventoryMovementByNumber(
      String movementNumber) async {
    try {
      final snapshot = await _firestore
          .collection('inventory_movements')
          .where('movementNumber', isEqualTo: movementNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return InventoryMovementModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error(
          'Error getting inventory movement by number: $movementNumber', e);
      rethrow;
    }
  }

  /// Öğeye göre envanter hareketleri getirir
  Future<List<InventoryMovementModel>> getInventoryMovementsByItem(
    String itemId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_movements')
          .where('itemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_movements')
            .where('itemId', isEqualTo: itemId)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting inventory movements by item: $itemId', e);
      rethrow;
    }
  }

  /// Tarih aralığına göre envanter hareketleri getirir
  Future<List<InventoryMovementModel>> getInventoryMovementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_movements')
          .where('movementDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('movementDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('movementDate', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_movements')
            .where('movementDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('movementDate',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .orderBy('movementDate', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting inventory movements by date range', e);
      rethrow;
    }
  }

  /// Türüne göre envanter hareketleri getirir
  Future<List<InventoryMovementModel>> getInventoryMovementsByType(
    InventoryMovementType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_movements')
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_movements')
            .where('type', isEqualTo: type.name)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting inventory movements by type: ${type.name}', e);
      rethrow;
    }
  }

  /// Duruma göre envanter hareketleri getirir
  Future<List<InventoryMovementModel>> getInventoryMovementsByStatus(
    InventoryMovementStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_movements')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_movements')
            .where('status', isEqualTo: status.name)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting inventory movements by status: ${status.name}', e);
      rethrow;
    }
  }

  /// Lokasyona göre envanter hareketleri getirir
  Future<List<InventoryMovementModel>> getInventoryMovementsByLocation(
    String location, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_movements')
          .where('toLocation', isEqualTo: location)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_movements')
            .where('toLocation', isEqualTo: location)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting inventory movements by location: $location', e);
      rethrow;
    }
  }

  /// Referansa göre envanter hareketleri getirir
  Future<List<InventoryMovementModel>> getInventoryMovementsByReference(
    String referenceType,
    String referenceId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_movements')
          .where('referenceType', isEqualTo: referenceType)
          .where('referenceId', isEqualTo: referenceId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_movements')
            .where('referenceType', isEqualTo: referenceType)
            .where('referenceId', isEqualTo: referenceId)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting inventory movements by reference: $referenceType/$referenceId',
          e);
      rethrow;
    }
  }

  /// Yeni envanter hareket oluşturur
  Future<InventoryMovementModel> createInventoryMovement(
      InventoryMovementModel inventoryMovement) async {
    try {
      final docRef = _firestore.collection('inventory_movements').doc();
      final newInventoryMovement = inventoryMovement.copyWith(id: docRef.id);

      await docRef.set(newInventoryMovement.toFirestore());
      AppLogger.info(
          'Inventory movement created: ${newInventoryMovement.movementNumber}');
      return newInventoryMovement;
    } catch (e) {
      AppLogger.error('Error creating inventory movement', e);
      rethrow;
    }
  }

  /// Envanter hareket günceller
  Future<InventoryMovementModel> updateInventoryMovement(
      InventoryMovementModel inventoryMovement) async {
    try {
      await _firestore
          .collection('inventory_movements')
          .doc(inventoryMovement.id)
          .update(inventoryMovement.toFirestore());

      AppLogger.info(
          'Inventory movement updated: ${inventoryMovement.movementNumber}');
      return inventoryMovement;
    } catch (e) {
      AppLogger.error(
          'Error updating inventory movement: ${inventoryMovement.id}', e);
      rethrow;
    }
  }

  /// Envanter hareket siler
  Future<void> deleteInventoryMovement(String id) async {
    try {
      await _firestore.collection('inventory_movements').doc(id).delete();
      AppLogger.info('Inventory movement deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting inventory movement: $id', e);
      rethrow;
    }
  }

  /// Envanter hareket arama
  Future<List<InventoryMovementModel>> searchInventoryMovements(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - movementNumber ve description'da arama
      final snapshot = await _firestore
          .collection('inventory_movements')
          .where('movementNumber', isGreaterThanOrEqualTo: query)
          .where('movementNumber', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results = snapshot.docs
          .map((doc) => InventoryMovementModel.fromFirestore(doc))
          .toList();

      // Eğer yeterli sonuç yoksa, description'da da ara
      if (results.length < (limit ?? 50)) {
        final descSnapshot = await _firestore
            .collection('inventory_movements')
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThanOrEqualTo: '$query\uf8ff')
            .limit((limit ?? 50) - results.length)
            .get();

        final descResults = descSnapshot.docs
            .map((doc) => InventoryMovementModel.fromFirestore(doc))
            .where((movement) => !results.any((r) => r.id == movement.id))
            .toList();

        results.addAll(descResults);
      }

      return results;
    } catch (e) {
      AppLogger.error('Error searching inventory movements: $query', e);
      rethrow;
    }
  }

  /// Envanter hareket sayısını getirir
  Future<int> getInventoryMovementsCount() async {
    try {
      final snapshot =
          await _firestore.collection('inventory_movements').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting inventory movements count', e);
      rethrow;
    }
  }

  /// Envanter hareket toplamını getirir
  Future<double> getInventoryMovementsTotal({
    DateTime? startDate,
    DateTime? endDate,
    InventoryMovementType? type,
  }) async {
    try {
      Query query = _firestore.collection('inventory_movements');

      if (startDate != null) {
        query = query.where('movementDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('movementDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query.get();
      return snapshot.docs.fold<double>(0.0, (double sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['totalCost'] as num).toDouble();
      });
    } catch (e) {
      AppLogger.error('Error getting inventory movements total', e);
      rethrow;
    }
  }

  /// En çok hareket edilen öğeleri getirir
  Future<List<Map<String, dynamic>>> getTopMovedItems({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('inventory_movements');

      if (startDate != null) {
        query = query.where('movementDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('movementDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final itemStats = <String, Map<String, dynamic>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final itemId = data['itemId'] as String;
        final itemName = data['itemName'] as String? ?? itemId;
        final quantity = (data['quantity'] as num).toDouble();
        final totalCost = (data['totalCost'] as num).toDouble();

        if (itemStats.containsKey(itemId)) {
          itemStats[itemId]!['quantity'] += quantity;
          itemStats[itemId]!['totalCost'] += totalCost;
          itemStats[itemId]!['count'] += 1;
        } else {
          itemStats[itemId] = {
            'itemId': itemId,
            'itemName': itemName,
            'quantity': quantity,
            'totalCost': totalCost,
            'count': 1,
          };
        }
      }

      final sortedItems = itemStats.values.toList()
        ..sort((a, b) =>
            (b['quantity'] as double).compareTo(a['quantity'] as double));

      return sortedItems.take(limit).toList();
    } catch (e) {
      AppLogger.error('Error getting top moved items', e);
      rethrow;
    }
  }

  /// En çok hareket edilen lokasyonları getirir
  Future<List<Map<String, dynamic>>> getTopLocations({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('inventory_movements');

      if (startDate != null) {
        query = query.where('movementDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('movementDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final locationStats = <String, Map<String, dynamic>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final toLocation = data['toLocation'] as String?;
        final fromLocation = data['fromLocation'] as String?;
        final quantity = (data['quantity'] as num).toDouble();
        final totalCost = (data['totalCost'] as num).toDouble();

        // To location
        if (toLocation != null) {
          if (locationStats.containsKey(toLocation)) {
            locationStats[toLocation]!['quantity'] += quantity;
            locationStats[toLocation]!['totalCost'] += totalCost;
            locationStats[toLocation]!['count'] += 1;
          } else {
            locationStats[toLocation] = {
              'location': toLocation,
              'quantity': quantity,
              'totalCost': totalCost,
              'count': 1,
            };
          }
        }

        // From location
        if (fromLocation != null) {
          if (locationStats.containsKey(fromLocation)) {
            locationStats[fromLocation]!['quantity'] += quantity;
            locationStats[fromLocation]!['totalCost'] += totalCost;
            locationStats[fromLocation]!['count'] += 1;
          } else {
            locationStats[fromLocation] = {
              'location': fromLocation,
              'quantity': quantity,
              'totalCost': totalCost,
              'count': 1,
            };
          }
        }
      }

      final sortedLocations = locationStats.values.toList()
        ..sort((a, b) =>
            (b['quantity'] as double).compareTo(a['quantity'] as double));

      return sortedLocations.take(limit).toList();
    } catch (e) {
      AppLogger.error('Error getting top locations', e);
      rethrow;
    }
  }

  /// Envanter hareket istatistiklerini getirir
  Future<Map<String, dynamic>> getInventoryMovementsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('inventory_movements');

      if (startDate != null) {
        query = query.where('movementDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('movementDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final stats = <String, dynamic>{
        'totalCount': snapshot.docs.length,
        'totalCost': 0.0,
        'typeCounts': <String, int>{},
        'statusCounts': <String, int>{},
      };

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final totalCost = (data['totalCost'] as num).toDouble();
        final type = data['type'] as String;
        final status = data['status'] as String;

        stats['totalCost'] = (stats['totalCost'] as double) + totalCost;

        stats['typeCounts'][type] =
            (stats['typeCounts'][type] as int? ?? 0) + 1;
        stats['statusCounts'][status] =
            (stats['statusCounts'][status] as int? ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      AppLogger.error('Error getting inventory movements statistics', e);
      rethrow;
    }
  }

  /// Envanter hareket numarası oluşturur
  Future<String> generateInventoryMovementNumber(
      InventoryMovementType type) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final prefix = type.name.toUpperCase();
      final datePrefix = '$year$month$day';

      // Bugünkü aynı tipte kaç tane hareket var?
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('inventory_movements')
          .where('type', isEqualTo: type.name)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();

      final count = snapshot.docs.length + 1;
      final number = count.toString().padLeft(4, '0');

      return '$prefix-$datePrefix-$number';
    } catch (e) {
      AppLogger.error('Error generating inventory movement number', e);
      rethrow;
    }
  }
}
