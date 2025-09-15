// ========== INVENTORY SERVICE ==========
// lib/core/services/inventory_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Stok hareket türü enum'u
enum StockMovementType {
  stockIn, // Stok girişi
  stockOut, // Stok çıkışı
  adjustment, // Stok düzeltmesi
  transfer, // Depo transferi
  production, // Üretim
  consumption, // Tüketim
  returnIn, // İade girişi
  returnOut, // İade çıkışı
}

/// Stok hareket modeli
class StockMovement {
  final String id;
  final String productId;
  final String warehouseId;
  final StockMovementType type;
  final int quantity;
  final String? reason;
  final String? reference;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.type,
    required this.quantity,
    this.reason,
    this.reference,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'type': type.name,
      'quantity': quantity,
      'reason': reason,
      'reference': reference,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      warehouseId: map['warehouseId'] ?? '',
      type: StockMovementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => StockMovementType.stockIn,
      ),
      quantity: map['quantity'] ?? 0,
      reason: map['reason'],
      reference: map['reference'],
      notes: map['notes'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

/// Stok yönetim servisi
class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stok hareketi kaydetme
  Future<String> recordStockMovement(StockMovement movement) async {
    try {
      final docRef = _firestore.collection('stock_movements').doc();
      final movementWithId = StockMovement(
        id: docRef.id,
        productId: movement.productId,
        warehouseId: movement.warehouseId,
        type: movement.type,
        quantity: movement.quantity,
        reason: movement.reason,
        reference: movement.reference,
        notes: movement.notes,
        createdBy: movement.createdBy,
        createdAt: movement.createdAt,
      );

      await docRef.set(movementWithId.toMap());
      await _updateProductStock(
          movement.productId, movement.quantity, movement.type);

      AppLogger.info('Stock movement recorded: ${movement.type.name}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error recording stock movement', e);
      rethrow;
    }
  }

  /// Ürün stok güncelleme
  Future<void> _updateProductStock(
      String productId, int quantity, StockMovementType type) async {
    try {
      final productRef = _firestore.collection('products').doc(productId);

      await _firestore.runTransaction((transaction) async {
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('Product not found');
        }

        final currentStock = productDoc.data()?['stockQuantity'] ?? 0;
        int newStock = currentStock;

        switch (type) {
          case StockMovementType.stockIn:
          case StockMovementType.production:
          case StockMovementType.returnIn:
            newStock += quantity;
            break;
          case StockMovementType.stockOut:
          case StockMovementType.consumption:
          case StockMovementType.returnOut:
            newStock -= quantity;
            break;
          case StockMovementType.adjustment:
            newStock = quantity;
            break;
          case StockMovementType.transfer:
            // Transfer işlemleri için özel mantık gerekebilir
            break;
        }

        transaction.update(productRef, {
          'stockQuantity': newStock,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      AppLogger.error('Error updating product stock', e);
      rethrow;
    }
  }

  /// Ürün stok seviyesi getirme
  Future<int> getProductStock(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return doc.data()?['stockQuantity'] ?? 0;
      }
      return 0;
    } catch (e) {
      AppLogger.error('Error getting product stock', e);
      return 0;
    }
  }

  /// Stok hareketleri getirme
  Future<List<StockMovement>> getStockMovements({
    String? productId,
    String? warehouseId,
    StockMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore.collection('stock_movements');

      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }
      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              StockMovement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting stock movements', e);
      return [];
    }
  }

  /// Stok raporu oluşturma
  Future<Map<String, dynamic>> generateStockReport() async {
    try {
      final productsSnapshot = await _firestore.collection('products').get();

      int totalProducts = productsSnapshot.docs.length;
      int lowStockProducts = 0;
      int outOfStockProducts = 0;
      double totalStockValue = 0.0;
      int totalStockQuantity = 0;

      for (final doc in productsSnapshot.docs) {
        final data = doc.data();
        final currentStock = ((data['stockQuantity'] ?? 0) as num).toInt();
        final minStock = ((data['minStockLevel'] ?? 0) as num).toInt();
        final unitPrice = (data['unitPrice'] ?? 0.0).toDouble();

        totalStockQuantity += currentStock;
        totalStockValue += currentStock * unitPrice;

        if (currentStock == 0) {
          outOfStockProducts++;
        } else if (currentStock <= minStock) {
          lowStockProducts++;
        }
      }

      return {
        'totalProducts': totalProducts,
        'totalStockQuantity': totalStockQuantity,
        'totalStockValue': totalStockValue,
        'lowStockProducts': lowStockProducts,
        'outOfStockProducts': outOfStockProducts,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppLogger.error('Error generating stock report', e);
      return {};
    }
  }

  /// Stok seviyesi kontrolü
  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    try {
      final productsSnapshot = await _firestore.collection('products').get();
      final lowStockProducts = <Map<String, dynamic>>[];

      for (final doc in productsSnapshot.docs) {
        final data = doc.data();
        final currentStock = (data['stockQuantity'] ?? 0).toInt();
        final minStock = (data['minStockLevel'] ?? 0).toInt();

        if (currentStock <= minStock) {
          lowStockProducts.add({
            'id': doc.id,
            'name': data['name'] ?? '',
            'currentStock': currentStock,
            'minStock': minStock,
            'unit': data['unit'] ?? '',
          });
        }
      }

      return lowStockProducts;
    } catch (e) {
      AppLogger.error('Error getting low stock products', e);
      return [];
    }
  }

  /// Stok hareketi silme
  Future<void> deleteStockMovement(String movementId) async {
    try {
      await _firestore.collection('stock_movements').doc(movementId).delete();
      AppLogger.info('Stock movement deleted: $movementId');
    } catch (e) {
      AppLogger.error('Error deleting stock movement', e);
      rethrow;
    }
  }

  /// Stok hareketi güncelleme
  Future<void> updateStockMovement(
      String movementId, StockMovement movement) async {
    try {
      await _firestore
          .collection('stock_movements')
          .doc(movementId)
          .update(movement.toMap());
      AppLogger.info('Stock movement updated: $movementId');
    } catch (e) {
      AppLogger.error('Error updating stock movement', e);
      rethrow;
    }
  }

  /// Stok hareketi detayı getirme
  Future<StockMovement?> getStockMovement(String movementId) async {
    try {
      final doc =
          await _firestore.collection('stock_movements').doc(movementId).get();
      if (doc.exists) {
        return StockMovement.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting stock movement', e);
      return null;
    }
  }

  /// Stok hareketi arama
  Future<List<StockMovement>> searchStockMovements(String query) async {
    try {
      final snapshot = await _firestore
          .collection('stock_movements')
          .where('reason', isGreaterThanOrEqualTo: query)
          .where('reason', isLessThan: '${query}z')
          .get();

      return snapshot.docs
          .map((doc) =>
              StockMovement.fromMap(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Error searching stock movements', e);
      return [];
    }
  }

  /// Stok hareketi istatistikleri
  Future<Map<String, dynamic>> getStockMovementStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('stock_movements');

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final movements = snapshot.docs
          .map((doc) =>
              StockMovement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      final stats = <String, int>{};
      for (final type in StockMovementType.values) {
        stats[type.name] = 0;
      }

      for (final movement in movements) {
        stats[movement.type.name] = (stats[movement.type.name] ?? 0) + 1;
      }

      return {
        'totalMovements': movements.length,
        'movementsByType': stats,
        'period': {
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
        },
      };
    } catch (e) {
      AppLogger.error('Error getting stock movement stats', e);
      return {};
    }
  }
}
