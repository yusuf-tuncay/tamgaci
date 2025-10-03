import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/purchases/data/models/purchase_model.dart';
import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/core/firebase/firebase_service.dart';
import 'package:tamgaci/core/services/tenant_service.dart';

/// Purchase Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class PurchaseFirebaseDataSource {
  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth;
  final FirebaseService _firebaseService = FirebaseService();
  final TenantService _tenantService = TenantService();

  PurchaseFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Get tenant-scoped purchases collection
  Future<CollectionReference<Map<String, dynamic>>> _tenantPurchases() async {
    final tenantId = await _tenantService.getUserTenantId();
    if (tenantId == null) {
      AppLogger.error('Tenant ID is null, cannot access purchases collection.');
      throw Exception('Tenant ID is null');
    }
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('purchases');
  }

  /// Tüm satın almaları getirir
  Future<List<PurchaseModel>> getAllPurchases({
    int? limit,
    int? offset,
  }) async {
    try {
      final col = await _tenantPurchases();
      Query query = col.orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await col
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
      final col = await _tenantPurchases();
      final doc = await col.doc(id).get();
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
      final col = await _tenantPurchases();
      final snapshot = await col
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
      final col = await _tenantPurchases();
      Query query = col
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await col
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
      final col = await _tenantPurchases();
      Query query = col
          .where('purchaseDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('purchaseDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('purchaseDate', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await col
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
      final col = await _tenantPurchases();
      Query query = col
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await col
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
      final col = await _tenantPurchases();
      Query query = col
          .where('paymentStatus', isEqualTo: paymentStatus.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await col
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
      final col = await _tenantPurchases();
      Query query = col
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .where('paymentStatus', whereIn: ['pending', 'partial']).orderBy(
              'dueDate',
              descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await col
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
      final col = await _tenantPurchases();
      final docRef = col.doc();
      final tenantId = await _tenantService.getUserTenantId();
      final newPurchase = purchase.copyWith(id: docRef.id);
      final data = newPurchase.toFirestore();
      data['tenantId'] = tenantId;
      data['createdBy'] = _firebaseAuth.currentUser?.uid;
      await docRef.set(data);
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
      final col = await _tenantPurchases();
      final data = purchase.toFirestore();
      data['tenantId'] = await _tenantService.getUserTenantId();
      await col.doc(purchase.id).update(data);

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
      final col = await _tenantPurchases();
      await col.doc(id).delete();
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
      final col = await _tenantPurchases();
      // Basit arama - purchaseNumber ve supplierName'de arama
      final snapshot = await col
          .where('purchaseNumber', isGreaterThanOrEqualTo: query)
          .where('purchaseNumber', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results =
          snapshot.docs.map((doc) => PurchaseModel.fromFirestore(doc)).toList();

      // Eğer yeterli sonuç yoksa, supplierName'de de ara
      if (results.length < (limit ?? 50)) {
        final supplierSnapshot = await col
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
      final col = await _tenantPurchases();
      final snapshot = await col.count().get();
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
      final col = await _tenantPurchases();
      Query query = col;

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
      final col = await _tenantPurchases();
      Query query = col;

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
      final col = await _tenantPurchases();
      Query query = col;

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
      final col = await _tenantPurchases();
      Query query = col;

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

      // Firebase index hatası nedeniyle basit fallback kullan
      final timestamp = now.millisecondsSinceEpoch;
      final randomSuffix = (timestamp % 10000).toString().padLeft(4, '0');

      return '$prefix-$datePrefix-$randomSuffix';
    } catch (e) {
      AppLogger.error('Error generating purchase number', e);
      // Son çare olarak timestamp kullan
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      final prefix = type.name.toUpperCase();
      final datePrefix = '$year$month$day';
      final timestamp = now.millisecondsSinceEpoch;
      final fallbackNumber = (timestamp % 10000).toString().padLeft(4, '0');
      return '$prefix-$datePrefix-$fallbackNumber';
    }
  }

  /// Satın alma onaylar
  Future<PurchaseModel> approvePurchase(String id) async {
    try {
      final col = await _tenantPurchases();
      final doc = await col.doc(id).get();

      if (!doc.exists) {
        throw Exception('Satın alma bulunamadı');
      }

      final data = doc.data()!;
      data['status'] = 'PurchaseStatus.confirmed';
      data['updatedAt'] = FieldValue.serverTimestamp();

      await col.doc(id).update(data);
      return PurchaseModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Error approving purchase', e);
      rethrow;
    }
  }

  /// Satın alma teslim alır
  Future<PurchaseModel> receivePurchase(String id) async {
    try {
      final col = await _tenantPurchases();
      final doc = await col.doc(id).get();

      if (!doc.exists) {
        throw Exception('Satın alma bulunamadı');
      }

      final data = doc.data()!;
      data['status'] = 'PurchaseStatus.received';
      data['updatedAt'] = FieldValue.serverTimestamp();

      await col.doc(id).update(data);
      return PurchaseModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Error receiving purchase', e);
      rethrow;
    }
  }

  /// Satın alma iptal eder
  Future<PurchaseModel> cancelPurchase(String id, String reason) async {
    try {
      final col = await _tenantPurchases();
      final doc = await col.doc(id).get();

      if (!doc.exists) {
        throw Exception('Satın alma bulunamadı');
      }

      final data = doc.data()!;
      data['status'] = 'PurchaseStatus.cancelled';
      data['notes'] = '${data['notes'] ?? ''}\nİptal nedeni: $reason'.trim();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await col.doc(id).update(data);
      return PurchaseModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Error cancelling purchase', e);
      rethrow;
    }
  }

  /// Satın alma iade eder
  Future<PurchaseModel> returnPurchase(String id, String reason) async {
    try {
      final col = await _tenantPurchases();
      final doc = await col.doc(id).get();

      if (!doc.exists) {
        throw Exception('Satın alma bulunamadı');
      }

      final data = doc.data()!;
      data['status'] = 'PurchaseStatus.returned';
      data['notes'] = '${data['notes'] ?? ''}\nİade nedeni: $reason'.trim();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await col.doc(id).update(data);
      return PurchaseModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Error returning purchase', e);
      rethrow;
    }
  }

  /// Satın alma kopyalar
  Future<PurchaseModel> duplicatePurchase(String id) async {
    try {
      final col = await _tenantPurchases();
      final doc = await col.doc(id).get();

      if (!doc.exists) {
        throw Exception('Satın alma bulunamadı');
      }

      final data = doc.data()!;
      data['id'] = null; // Yeni ID oluşturulacak
      data['purchaseNumber'] =
          await generatePurchaseNumber(PurchaseType.purchase);
      data['status'] = 'PurchaseStatus.draft';
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final newDoc = await col.add(data);
      final newDocData = await newDoc.get();
      return PurchaseModel.fromFirestore(newDocData);
    } catch (e) {
      AppLogger.error('Error duplicating purchase', e);
      rethrow;
    }
  }

  /// Satın alma raporu oluşturur
  Future<Map<String, dynamic>> getPurchasesReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    try {
      final col = await _tenantPurchases();
      final snapshot = await col
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final purchases = snapshot.docs.map((doc) => doc.data()).toList();

      // Rapor verilerini oluştur
      final report = <String, dynamic>{
        'startDate': startDate,
        'endDate': endDate,
        'totalCount': purchases.length,
        'totalAmount': purchases.fold<double>(0, (total, purchase) {
          return total + (purchase['totalAmount'] as num? ?? 0).toDouble();
        }),
        'purchases': purchases,
      };

      return report;
    } catch (e) {
      AppLogger.error('Error getting purchases report', e);
      rethrow;
    }
  }
}
