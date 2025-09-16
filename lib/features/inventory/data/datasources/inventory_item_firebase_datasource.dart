import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/inventory/data/models/inventory_item_model.dart';
import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';

/// InventoryItem Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class InventoryItemFirebaseDataSource {
  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth;

  InventoryItemFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm envanter öğelerini getirir
  Future<List<InventoryItemModel>> getAllInventoryItems({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_items')
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_items')
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
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all inventory items', e);
      rethrow;
    }
  }

  /// ID'ye göre envanter öğesi getirir
  Future<InventoryItemModel?> getInventoryItemById(String id) async {
    try {
      final doc = await _firestore.collection('inventory_items').doc(id).get();
      if (doc.exists) {
        return InventoryItemModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting inventory item by id: $id', e);
      rethrow;
    }
  }

  /// SKU'ya göre envanter öğesi getirir
  Future<InventoryItemModel?> getInventoryItemBySku(String sku) async {
    try {
      final snapshot = await _firestore
          .collection('inventory_items')
          .where('sku', isEqualTo: sku)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return InventoryItemModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting inventory item by sku: $sku', e);
      rethrow;
    }
  }

  /// Barkod'a göre envanter öğesi getirir
  Future<InventoryItemModel?> getInventoryItemByBarcode(String barcode) async {
    try {
      final snapshot = await _firestore
          .collection('inventory_items')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return InventoryItemModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting inventory item by barcode: $barcode', e);
      rethrow;
    }
  }

  /// Türüne göre envanter öğelerini getirir
  Future<List<InventoryItemModel>> getInventoryItemsByType(
    InventoryItemType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_items')
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_items')
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
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting inventory items by type: ${type.name}', e);
      rethrow;
    }
  }

  /// Duruma göre envanter öğelerini getirir
  Future<List<InventoryItemModel>> getInventoryItemsByStatus(
    InventoryItemStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_items')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_items')
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
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting inventory items by status: ${status.name}', e);
      rethrow;
    }
  }

  /// Kategoriye göre envanter öğelerini getirir
  Future<List<InventoryItemModel>> getInventoryItemsByCategory(
    String category, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_items')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_items')
            .where('category', isEqualTo: category)
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
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting inventory items by category: $category', e);
      rethrow;
    }
  }

  /// Tedarikçiye göre envanter öğelerini getirir
  Future<List<InventoryItemModel>> getInventoryItemsBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_items')
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('inventory_items')
            .where('supplierId', isEqualTo: supplierId)
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
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting inventory items by supplier: $supplierId', e);
      rethrow;
    }
  }

  /// Stok seviyesine göre envanter öğelerini getirir
  Future<List<InventoryItemModel>> getInventoryItemsByStockLevel(
    String stockLevel, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query;

      switch (stockLevel) {
        case 'low':
          query = _firestore
              .collection('inventory_items')
              .where('currentStock',
                  isLessThanOrEqualTo: FieldPath(const ['reorderPoint']))
              .orderBy('currentStock', descending: false);
          break;
        case 'high':
          query = _firestore
              .collection('inventory_items')
              .where('currentStock',
                  isGreaterThanOrEqualTo: FieldPath(const ['maximumStock']))
              .orderBy('currentStock', descending: true);
          break;
        default: // normal
          query = _firestore
              .collection('inventory_items')
              .where('currentStock',
                  isGreaterThan: FieldPath(const ['reorderPoint']))
              .where('currentStock',
                  isLessThan: FieldPath(const ['maximumStock']))
              .orderBy('currentStock', descending: true);
      }

      if (offset != null && offset > 0) {
        final offsetDoc = await query.limit(offset).get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting inventory items by stock level: $stockLevel', e);
      rethrow;
    }
  }

  /// Yeniden sipariş noktasına ulaşan öğeleri getirir
  Future<List<InventoryItemModel>> getInventoryItemsAtReorderPoint({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_items')
          .where('currentStock',
              isLessThanOrEqualTo: FieldPath(const ['reorderPoint']))
          .orderBy('currentStock', descending: false);

      if (offset != null && offset > 0) {
        final offsetDoc = await query.limit(offset).get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting inventory items at reorder point', e);
      rethrow;
    }
  }

  /// Stokta olmayan öğeleri getirir
  Future<List<InventoryItemModel>> getOutOfStockItems({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory_items')
          .where('currentStock', isEqualTo: 0)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await query.limit(offset).get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting out of stock items', e);
      rethrow;
    }
  }

  /// Son kullanma tarihi yaklaşan öğeleri getirir
  Future<List<InventoryItemModel>> getExpiringItems(
    int days, {
    int? limit,
    int? offset,
  }) async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: days));

      Query query = _firestore
          .collection('inventory_items')
          .where('expiryDate',
              isLessThanOrEqualTo: Timestamp.fromDate(expiryDate))
          .where('expiryDate',
              isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .orderBy('expiryDate', descending: false);

      if (offset != null && offset > 0) {
        final offsetDoc = await query.limit(offset).get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting expiring items', e);
      rethrow;
    }
  }

  /// Yeni envanter öğesi oluşturur
  Future<InventoryItemModel> createInventoryItem(
      InventoryItemModel inventoryItem) async {
    try {
      final docRef = _firestore.collection('inventory_items').doc();
      final newInventoryItem = inventoryItem.copyWith(id: docRef.id);

      await docRef.set(newInventoryItem.toFirestore());
      AppLogger.info('Inventory item created: ${newInventoryItem.name}');
      return newInventoryItem;
    } catch (e) {
      AppLogger.error('Error creating inventory item', e);
      rethrow;
    }
  }

  /// Envanter öğesi günceller
  Future<InventoryItemModel> updateInventoryItem(
      InventoryItemModel inventoryItem) async {
    try {
      await _firestore
          .collection('inventory_items')
          .doc(inventoryItem.id)
          .update(inventoryItem.toFirestore());

      AppLogger.info('Inventory item updated: ${inventoryItem.name}');
      return inventoryItem;
    } catch (e) {
      AppLogger.error('Error updating inventory item: ${inventoryItem.id}', e);
      rethrow;
    }
  }

  /// Envanter öğesi siler
  Future<void> deleteInventoryItem(String id) async {
    try {
      await _firestore.collection('inventory_items').doc(id).delete();
      AppLogger.info('Inventory item deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting inventory item: $id', e);
      rethrow;
    }
  }

  /// Envanter öğesi arama
  Future<List<InventoryItemModel>> searchInventoryItems(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - name, sku ve barcode'da arama
      final snapshot = await _firestore
          .collection('inventory_items')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results = snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();

      // Eğer yeterli sonuç yoksa, SKU'da da ara
      if (results.length < (limit ?? 50)) {
        final skuSnapshot = await _firestore
            .collection('inventory_items')
            .where('sku', isGreaterThanOrEqualTo: query)
            .where('sku', isLessThanOrEqualTo: '$query\uf8ff')
            .limit((limit ?? 50) - results.length)
            .get();

        final skuResults = skuSnapshot.docs
            .map((doc) => InventoryItemModel.fromFirestore(doc))
            .where((item) => !results.any((r) => r.id == item.id))
            .toList();

        results.addAll(skuResults);
      }

      return results;
    } catch (e) {
      AppLogger.error('Error searching inventory items: $query', e);
      rethrow;
    }
  }

  /// Envanter öğesi sayısını getirir
  Future<int> getInventoryItemsCount() async {
    try {
      final snapshot =
          await _firestore.collection('inventory_items').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting inventory items count', e);
      rethrow;
    }
  }

  /// Toplam stok değerini getirir
  Future<double> getTotalStockValue({String? currency}) async {
    try {
      Query query = _firestore.collection('inventory_items');

      if (currency != null) {
        query = query.where('currency', isEqualTo: currency);
      }

      final snapshot = await query.get();
      return snapshot.docs.fold<double>(0.0, (double sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        final currentStock = (data['currentStock'] as num).toDouble();
        final unitCost = (data['unitCost'] as num).toDouble();
        return sum + (currentStock * unitCost);
      });
    } catch (e) {
      AppLogger.error('Error getting total stock value', e);
      rethrow;
    }
  }

  /// Türüne göre toplam stok değerini getirir
  Future<double> getTotalStockValueByType(InventoryItemType type,
      {String? currency}) async {
    try {
      Query query = _firestore
          .collection('inventory_items')
          .where('type', isEqualTo: type.name);

      if (currency != null) {
        query = query.where('currency', isEqualTo: currency);
      }

      final snapshot = await query.get();
      return snapshot.docs.fold<double>(0.0, (double sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        final currentStock = (data['currentStock'] as num).toDouble();
        final unitCost = (data['unitCost'] as num).toDouble();
        return sum + (currentStock * unitCost);
      });
    } catch (e) {
      AppLogger.error('Error getting total stock value by type', e);
      rethrow;
    }
  }

  /// Envanter öğesi istatistiklerini getirir
  Future<Map<String, dynamic>> getInventoryItemsStatistics() async {
    try {
      final snapshot = await _firestore.collection('inventory_items').get();
      final stats = <String, dynamic>{
        'totalCount': snapshot.docs.length,
        'totalStockValue': 0.0,
        'typeCounts': <String, int>{},
        'statusCounts': <String, int>{},
        'lowStockCount': 0,
        'outOfStockCount': 0,
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final currentStock = (data['currentStock'] as num).toDouble();
        final reorderPoint = (data['reorderPoint'] as num).toDouble();
        final unitCost = (data['unitCost'] as num).toDouble();
        final type = data['type'] as String;
        final status = data['status'] as String;

        stats['totalStockValue'] =
            (stats['totalStockValue'] as double) + (currentStock * unitCost);

        stats['typeCounts'][type] =
            (stats['typeCounts'][type] as int? ?? 0) + 1;
        stats['statusCounts'][status] =
            (stats['statusCounts'][status] as int? ?? 0) + 1;

        if (currentStock == 0) {
          stats['outOfStockCount'] = (stats['outOfStockCount'] as int) + 1;
        } else if (currentStock <= reorderPoint) {
          stats['lowStockCount'] = (stats['lowStockCount'] as int) + 1;
        }
      }

      return stats;
    } catch (e) {
      AppLogger.error('Error getting inventory items statistics', e);
      rethrow;
    }
  }

  /// Envanter öğesi numarası oluşturur
  Future<String> generateInventoryItemNumber(InventoryItemType type) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final prefix = type.name.toUpperCase();
      final datePrefix = '$year$month$day';

      // Bugünkü aynı tipte kaç tane öğe var?
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('inventory_items')
          .where('type', isEqualTo: type.name)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();

      final count = snapshot.docs.length + 1;
      final number = count.toString().padLeft(4, '0');

      return '$prefix-$datePrefix-$number';
    } catch (e) {
      AppLogger.error('Error generating inventory item number', e);
      rethrow;
    }
  }
}
