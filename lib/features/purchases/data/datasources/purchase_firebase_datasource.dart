import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/purchases/data/models/purchase_model.dart';
import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';

/// Purchase Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class PurchaseFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  PurchaseFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm satın almaları getirir
  Future<List<PurchaseModel>> getAllPurchases({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('purchases')
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('purchases')
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
          .map((doc) => PurchaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all purchases', e);
      rethrow;
    }
  }

  /// ID'ye göre satın alma getirir
  Future<PurchaseModel?> getPurchaseById(String id) async {
    try {
      final doc = await _firestore.collection('purchases').doc(id).get();
      if (doc.exists) {
        return PurchaseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting purchase by id: $id', e);
      rethrow;
    }
  }

  /// Satın alma numarasına göre satın alma getirir
  Future<PurchaseModel?> getPurchaseByNumber(String purchaseNumber) async {
    try {
      final snapshot = await _firestore
          .collection('purchases')
          .where('purchaseNumber', isEqualTo: purchaseNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PurchaseModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting purchase by number: $purchaseNumber', e);
      rethrow;
    }
  }

  /// Tedarikçiye göre satın almaları getirir
  Future<List<PurchaseModel>> getPurchasesBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('purchases')
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('purchases')
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
          .map((doc) => PurchaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting purchases by supplier: $supplierId', e);
      rethrow;
    }
  }

  /// Tarih aralığına göre satın almaları getirir
  Future<List<PurchaseModel>> getPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('purchases')
          .where('purchaseDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('purchaseDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('purchaseDate', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('purchases')
            .where('purchaseDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('purchaseDate',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .orderBy('purchaseDate', descending: true)
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
          .map((doc) => PurchaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting purchases by date range', e);
      rethrow;
    }
  }

  /// Duruma göre satın almaları getirir
  Future<List<PurchaseModel>> getPurchasesByStatus(
    PurchaseStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('purchases')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('purchases')
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
          .map((doc) => PurchaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting purchases by status: ${status.name}', e);
      rethrow;
    }
  }

  /// Ödeme durumuna göre satın almaları getirir
  Future<List<PurchaseModel>> getPurchasesByPaymentStatus(
    PurchasePaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('purchases')
          .where('paymentStatus', isEqualTo: paymentStatus.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('purchases')
            .where('paymentStatus', isEqualTo: paymentStatus.name)
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
          .map((doc) => PurchaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting purchases by payment status: ${paymentStatus.name}',
          e);
      rethrow;
    }
  }

  /// Vadesi geçmiş satın almaları getirir
  Future<List<PurchaseModel>> getOverduePurchases({
    int? limit,
    int? offset,
  }) async {
    try {
      final now = DateTime.now();
      Query query = _firestore
          .collection('purchases')
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .where('paymentStatus', whereIn: ['pending', 'partial']).orderBy(
              'dueDate',
              descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('purchases')
            .where('dueDate', isLessThan: Timestamp.fromDate(now))
            .where('paymentStatus', whereIn: ['pending', 'partial'])
            .orderBy('dueDate', descending: true)
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
          .map((doc) => PurchaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting overdue purchases', e);
      rethrow;
    }
  }

  /// Yeni satın alma oluşturur
  Future<PurchaseModel> createPurchase(PurchaseModel purchase) async {
    try {
      final docRef = _firestore.collection('purchases').doc();
      final newPurchase = purchase.copyWith(id: docRef.id);

      await docRef.set(newPurchase.toFirestore());
      AppLogger.info('Purchase created: ${newPurchase.purchaseNumber}');
      return newPurchase;
    } catch (e) {
      AppLogger.error('Error creating purchase', e);
      rethrow;
    }
  }

  /// Satın alma günceller
  Future<PurchaseModel> updatePurchase(PurchaseModel purchase) async {
    try {
      await _firestore
          .collection('purchases')
          .doc(purchase.id)
          .update(purchase.toFirestore());

      AppLogger.info('Purchase updated: ${purchase.purchaseNumber}');
      return purchase;
    } catch (e) {
      AppLogger.error('Error updating purchase: ${purchase.id}', e);
      rethrow;
    }
  }

  /// Satın alma siler
  Future<void> deletePurchase(String id) async {
    try {
      await _firestore.collection('purchases').doc(id).delete();
      AppLogger.info('Purchase deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting purchase: $id', e);
      rethrow;
    }
  }

  /// Satın alma arama
  Future<List<PurchaseModel>> searchPurchases(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - purchaseNumber ve supplierName'de arama
      final snapshot = await _firestore
          .collection('purchases')
          .where('purchaseNumber', isGreaterThanOrEqualTo: query)
          .where('purchaseNumber', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results =
          snapshot.docs.map((doc) => PurchaseModel.fromFirestore(doc)).toList();

      // Eğer yeterli sonuç yoksa, supplierName'de de ara
      if (results.length < (limit ?? 50)) {
        final supplierSnapshot = await _firestore
            .collection('purchases')
            .where('supplierName', isGreaterThanOrEqualTo: query)
            .where('supplierName', isLessThanOrEqualTo: '$query\uf8ff')
            .limit((limit ?? 50) - results.length)
            .get();

        final supplierResults = supplierSnapshot.docs
            .map((doc) => PurchaseModel.fromFirestore(doc))
            .where((purchase) => !results.any((r) => r.id == purchase.id))
            .toList();

        results.addAll(supplierResults);
      }

      return results;
    } catch (e) {
      AppLogger.error('Error searching purchases: $query', e);
      rethrow;
    }
  }

  /// Satın alma sayısını getirir
  Future<int> getPurchasesCount() async {
    try {
      final snapshot = await _firestore.collection('purchases').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting purchases count', e);
      rethrow;
    }
  }

  /// Satın alma toplamını getirir
  Future<double> getPurchasesTotal({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('purchases');

      if (startDate != null) {
        query = query.where('purchaseDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('purchaseDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['totalAmount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting purchases total', e);
      rethrow;
    }
  }

  /// En çok satın alınan ürünleri getirir
  Future<List<Map<String, dynamic>>> getTopPurchasedProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('purchases');

      if (startDate != null) {
        query = query.where('purchaseDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('purchaseDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final productStats = <String, Map<String, dynamic>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final itemData = item as Map<String, dynamic>;
          final productId = itemData['productId'] as String;
          final productName = itemData['productName'] as String? ?? productId;
          final quantity = (itemData['quantity'] as num).toDouble();
          final totalAmount = (itemData['totalAmount'] as num).toDouble();

          if (productStats.containsKey(productId)) {
            productStats[productId]!['quantity'] += quantity;
            productStats[productId]!['totalAmount'] += totalAmount;
            productStats[productId]!['count'] += 1;
          } else {
            productStats[productId] = {
              'productId': productId,
              'productName': productName,
              'quantity': quantity,
              'totalAmount': totalAmount,
              'count': 1,
            };
          }
        }
      }

      final sortedProducts = productStats.values.toList()
        ..sort((a, b) =>
            (b['totalAmount'] as double).compareTo(a['totalAmount'] as double));

      return sortedProducts.take(limit).toList();
    } catch (e) {
      AppLogger.error('Error getting top purchased products', e);
      rethrow;
    }
  }

  /// En çok satın alma yapılan tedarikçileri getirir
  Future<List<Map<String, dynamic>>> getTopSuppliers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('purchases');

      if (startDate != null) {
        query = query.where('purchaseDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('purchaseDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final supplierStats = <String, Map<String, dynamic>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final supplierId = data['supplierId'] as String;
        final supplierName = data['supplierName'] as String? ?? supplierId;
        final totalAmount = (data['totalAmount'] as num).toDouble();

        if (supplierStats.containsKey(supplierId)) {
          supplierStats[supplierId]!['totalAmount'] += totalAmount;
          supplierStats[supplierId]!['count'] += 1;
        } else {
          supplierStats[supplierId] = {
            'supplierId': supplierId,
            'supplierName': supplierName,
            'totalAmount': totalAmount,
            'count': 1,
          };
        }
      }

      final sortedSuppliers = supplierStats.values.toList()
        ..sort((a, b) =>
            (b['totalAmount'] as double).compareTo(a['totalAmount'] as double));

      return sortedSuppliers.take(limit).toList();
    } catch (e) {
      AppLogger.error('Error getting top suppliers', e);
      rethrow;
    }
  }

  /// Satın alma istatistiklerini getirir
  Future<Map<String, dynamic>> getPurchasesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('purchases');

      if (startDate != null) {
        query = query.where('purchaseDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('purchaseDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final stats = <String, dynamic>{
        'totalCount': snapshot.docs.length,
        'totalAmount': 0.0,
        'statusCounts': <String, int>{},
        'paymentStatusCounts': <String, int>{},
      };

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final totalAmount = (data['totalAmount'] as num).toDouble();
        final status = data['status'] as String;
        final paymentStatus = data['paymentStatus'] as String;

        stats['totalAmount'] = (stats['totalAmount'] as double) + totalAmount;

        stats['statusCounts'][status] =
            (stats['statusCounts'][status] as int? ?? 0) + 1;
        stats['paymentStatusCounts'][paymentStatus] =
            (stats['paymentStatusCounts'][paymentStatus] as int? ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      AppLogger.error('Error getting purchases statistics', e);
      rethrow;
    }
  }

  /// Satın alma numarası oluşturur
  Future<String> generatePurchaseNumber(PurchaseType type) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final prefix = type.name.toUpperCase();
      final datePrefix = '$year$month$day';

      // Bugünkü aynı tipte kaç tane satın alma var?
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('purchases')
          .where('type', isEqualTo: type.name)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();

      final count = snapshot.docs.length + 1;
      final number = count.toString().padLeft(4, '0');

      return '$prefix-$datePrefix-$number';
    } catch (e) {
      AppLogger.error('Error generating purchase number', e);
      rethrow;
    }
  }
}
