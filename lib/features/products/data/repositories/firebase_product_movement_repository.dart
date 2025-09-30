// ========== FIREBASE PRODUCT MOVEMENT REPOSITORY ==========
// lib/features/products/data/repositories/firebase_product_movement_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/product_movement.dart';

/// Firebase ürün hareketleri repository'si
class FirebaseProductMovementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'productMovements';

  /// Ürün hareketi oluşturma
  Future<void> createMovement(ProductMovement movement) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(movement.id)
          .set(movement.toJson());
      
      debugPrint('Product movement created: ${movement.id}');
    } catch (e) {
      debugPrint('Error creating product movement: $e');
      rethrow;
    }
  }

  /// Belirli bir ürünün hareketlerini getirme
  Stream<List<ProductMovement>> getProductMovements(String productId) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductMovement.fromJson(data);
      }).toList();
    });
  }

  /// Tüm ürün hareketlerini getirme (admin için)
  Stream<List<ProductMovement>> getAllProductMovements() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(1000) // Son 1000 hareket
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductMovement.fromJson(data);
      }).toList();
    });
  }

  /// Ürün hareketleri istatistikleri
  Stream<Map<String, dynamic>> getProductMovementStats(String productId) async* {
    final movements = await _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .get();

    int totalIn = 0;
    int totalOut = 0;
    Map<String, int> typeCounts = {};
    Map<String, int> monthlyCounts = {};

    for (var doc in movements.docs) {
      final data = doc.data();
      final movement = ProductMovement.fromJson({...data, 'id': doc.id});
      
      // Toplam giriş/çıkış
      if (movement.type == ProductMovementType.stockIn ||
          movement.type == ProductMovementType.purchase ||
          movement.type == ProductMovementType.returnIn ||
          movement.type == ProductMovementType.production) {
        totalIn += movement.quantity;
      } else {
        totalOut += movement.quantity;
      }

      // Tür bazında sayım
      final typeName = movement.type.name;
      typeCounts[typeName] = (typeCounts[typeName] ?? 0) + 1;

      // Aylık sayım
      final monthKey = '${movement.createdAt.year}-${movement.createdAt.month.toString().padLeft(2, '0')}';
      monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;
    }

    yield {
      'totalIn': totalIn,
      'totalOut': totalOut,
      'netMovement': totalIn - totalOut,
      'typeCounts': typeCounts,
      'monthlyCounts': monthlyCounts,
      'totalMovements': movements.docs.length,
    };
  }

  /// Ürün hareketi güncelleme
  Future<void> updateMovement(ProductMovement movement) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(movement.id)
          .update(movement.toJson());
      
      debugPrint('Product movement updated: ${movement.id}');
    } catch (e) {
      debugPrint('Error updating product movement: $e');
      rethrow;
    }
  }

  /// Ürün hareketi silme
  Future<void> deleteMovement(String movementId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(movementId)
          .delete();
      
      debugPrint('Product movement deleted: $movementId');
    } catch (e) {
      debugPrint('Error deleting product movement: $e');
      rethrow;
    }
  }

  /// Belirli tarih aralığındaki hareketleri getirme
  Stream<List<ProductMovement>> getMovementsByDateRange(
    String productId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductMovement.fromJson(data);
      }).toList();
    });
  }

  /// Belirli türdeki hareketleri getirme
  Stream<List<ProductMovement>> getMovementsByType(
    String productId,
    ProductMovementType type,
  ) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .where('type', isEqualTo: type.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductMovement.fromJson(data);
      }).toList();
    });
  }
}
