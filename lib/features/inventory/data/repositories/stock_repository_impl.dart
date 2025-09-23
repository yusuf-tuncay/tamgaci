// ========== STOCK REPOSITORY IMPLEMENTATION ==========
// lib/features/inventory/data/repositories/stock_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/core/repositories/firebase_repository.dart';
import 'package:tamgaci/features/inventory/domain/entities/stock.dart';
import 'package:tamgaci/features/inventory/domain/repositories/stock_repository.dart';

/// Firebase Stock Repository Implementation
class StockRepositoryImpl extends FirebaseRepository<Stock>
    implements StockRepository {
  static const String _stocksCollection = 'stocks';

  @override
  String get collectionName => _stocksCollection;

  @override
  String get entityTypeName => 'Stock';

  @override
  Map<String, dynamic> entityToMap(Stock entity) => entity.toMap();

  @override
  Stock mapToEntity(Map<String, dynamic> map) => Stock.fromMap(map);

  @override
  String getEntityId(Stock entity) => entity.id;

  @override
  Stock setEntityId(Stock entity, String id) => entity.copyWith(id: id);

  @override
  DateTime getEntityCreatedAt(Stock entity) => entity.createdAt;

  @override
  DateTime getEntityUpdatedAt(Stock entity) => entity.updatedAt;

  @override
  Stock setEntityUpdatedAt(Stock entity, DateTime timestamp) =>
      entity.copyWith(updatedAt: timestamp);

  @override
  String getEntityCreatedBy(Stock entity) => '';

  @override
  String? getEntityUpdatedBy(Stock entity) => null;

  @override
  Stock setEntityUpdatedBy(Stock entity, String userId) => entity;

  @override
  Future<List<Stock>> getAllStocks() async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Stock.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get all stocks: $e');
    }
  }

  @override
  Future<List<Stock>> getActiveStocks() async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Stock.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get active stocks: $e');
    }
  }

  @override
  Future<Stock?> getStockById(String id) async {
    try {
      final doc = await firestore
          .collection(_stocksCollection)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return Stock.fromMap(doc.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get stock by id: $e');
    }
  }

  @override
  Future<List<Stock>> getStocksByProductId(String productId) async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Stock.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get stocks by product id: $e');
    }
  }

  @override
  Future<List<Stock>> getStocksByWarehouseId(String warehouseId) async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .where('warehouseId', isEqualTo: warehouseId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Stock.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get stocks by warehouse id: $e');
    }
  }

  @override
  Future<Stock?> getStockByProductAndWarehouse(
      String productId, String warehouseId) async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .where('productId', isEqualTo: productId)
          .where('warehouseId', isEqualTo: warehouseId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Stock.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get stock by product and warehouse: $e');
    }
  }

  @override
  Future<List<Stock>> getLowStocks() async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final stocks =
          snapshot.docs.map((doc) => Stock.fromMap(doc.data())).toList();

      // Filter low stocks based on quantity <= minimumQuantity
      return stocks.where((stock) => stock.isCritical).toList();
    } catch (e) {
      throw Exception('Failed to get low stocks: $e');
    }
  }

  @override
  Future<List<Stock>> getOverstockedItems() async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final stocks =
          snapshot.docs.map((doc) => Stock.fromMap(doc.data())).toList();

      // Filter overstocked items based on quantity >= maximumQuantity
      return stocks.where((stock) => stock.isOverstocked).toList();
    } catch (e) {
      throw Exception('Failed to get overstocked items: $e');
    }
  }

  @override
  Future<Stock> createStock(Stock stock) async {
    try {
      // Generate new ID
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final newStock = stock.copyWith(
        id: newId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection(_stocksCollection)
          .doc(newId.toString())
          .set(newStock.toMap());

      return newStock;
    } catch (e) {
      throw Exception('Failed to create stock: $e');
    }
  }

  @override
  Future<Stock> updateStock(Stock stock) async {
    try {
      final updatedStock = stock.copyWith(updatedAt: DateTime.now());

      await firestore
          .collection(_stocksCollection)
          .doc(stock.id.toString())
          .update(updatedStock.toMap());

      return updatedStock;
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  @override
  Future<void> deleteStock(String id) async {
    try {
      await firestore.collection(_stocksCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete stock: $e');
    }
  }

  @override
  Future<void> updateStockQuantity(String id, double quantity) async {
    try {
      await firestore.collection(_stocksCollection).doc(id).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update stock quantity: $e');
    }
  }

  @override
  Future<void> updateStockPrice(String id, double unitPrice) async {
    try {
      await firestore.collection(_stocksCollection).doc(id).update({
        'unitPrice': unitPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update stock price: $e');
    }
  }

  @override
  Future<int> getStockCount() async {
    try {
      final snapshot = await firestore.collection(_stocksCollection).get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get stock count: $e');
    }
  }

  @override
  Future<int> getActiveStockCount() async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get active stock count: $e');
    }
  }

  @override
  Future<int> getLowStockCount() async {
    try {
      final lowStocks = await getLowStocks();
      return lowStocks.length;
    } catch (e) {
      throw Exception('Failed to get low stock count: $e');
    }
  }

  @override
  Future<double> getTotalStockValue() async {
    try {
      final snapshot = await firestore
          .collection(_stocksCollection)
          .where('isActive', isEqualTo: true)
          .get();

      double totalValue = 0.0;
      for (final doc in snapshot.docs) {
        final stock = Stock.fromMap(doc.data());
        totalValue += stock.totalValue;
      }

      return totalValue;
    } catch (e) {
      throw Exception('Failed to get total stock value: $e');
    }
  }

  // ========== FIREBASE REPOSITORY IMPLEMENTATION ==========

  // These methods are not part of the base interface; keep non-override helpers.
  Stock fromFirestore(Map<String, dynamic> data) {
    return Stock.fromMap(data);
  }

  Map<String, dynamic> toFirestore(Stock entity) {
    return entity.toMap();
  }
}
