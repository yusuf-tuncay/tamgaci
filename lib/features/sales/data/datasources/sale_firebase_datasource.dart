import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/sales/data/models/sale_model.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/core/errors/failures.dart';
import 'package:tamgaci/core/firebase/firebase_service.dart';
import 'package:tamgaci/core/services/tenant_service.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Sales Firebase datasource
/// Firebase Firestore işlemleri için datasource
abstract class SaleFirebaseDataSource {
  /// Tüm satışları getirir
  Future<List<SaleModel>> getAllSales({
    int? limit,
    int? offset,
  });

  /// ID'ye göre satış getirir
  Future<SaleModel?> getSaleById(String id);

  /// Satış numarasına göre satış getirir
  Future<SaleModel?> getSaleByNumber(String saleNumber);

  /// Müşteriye göre satışları getirir
  Future<List<SaleModel>> getSalesByCustomer(
    String customerId, {
    int? limit,
    int? offset,
  });

  /// Tarih aralığına göre satışları getirir
  Future<List<SaleModel>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  });

  /// Satış durumuna göre satışları getirir
  Future<List<SaleModel>> getSalesByStatus(
    SaleStatus status, {
    int? limit,
    int? offset,
  });

  /// Ödeme durumuna göre satışları getirir
  Future<List<SaleModel>> getSalesByPaymentStatus(
    PaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  });

  /// Vadesi geçmiş satışları getirir
  Future<List<SaleModel>> getOverdueSales({
    int? limit,
    int? offset,
  });

  /// Yeni satış oluşturur
  Future<SaleModel> createSale(SaleModel sale);

  /// Satış günceller
  Future<SaleModel> updateSale(SaleModel sale);

  /// Satış siler
  Future<void> deleteSale(String id);

  /// Satış arama yapar
  Future<List<SaleModel>> searchSales(
    String query, {
    int? limit,
    int? offset,
  });

  /// Satış sayısını getirir
  Future<int> getSalesCount();

  /// Satış toplamını getirir
  Future<double> getSalesTotal({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// En çok satan ürünleri getirir
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// En çok satış yapılan müşterileri getirir
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Satış istatistiklerini getirir
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Satış numarası oluşturur
  Future<String> generateSaleNumber(SaleType type);
}

/// Sales Firebase datasource implementasyonu
class SaleFirebaseDataSourceImpl implements SaleFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseService _firebaseService = FirebaseService();
  final TenantService _tenantService = TenantService();

  SaleFirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  /// Get tenant-scoped sales collection
  Future<CollectionReference<Map<String, dynamic>>> _tenantSales() async {
    final tenantId = await _tenantService.getUserTenantId();
    if (tenantId == null) {
      AppLogger.error('Tenant ID is null, cannot access sales collection.');
      throw Exception('Tenant ID is null');
    }
    return _firestore.collection('tenants').doc(tenantId).collection('sales');
  }

  @override
  Future<List<SaleModel>> getAllSales({
    int? limit,
    int? offset,
  }) async {
    try {
      final col = await _tenantSales();
      Query query = col.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw DatabaseFailure(
          'Satışlar getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<SaleModel?> getSaleById(String id) async {
    try {
      final col = await _tenantSales();
      final doc = await col.doc(id).get();
      if (!doc.exists) {
        return null;
      }
      return SaleModel.fromFirestore(doc);
    } catch (e) {
      throw DatabaseFailure(
          'Satış getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<SaleModel?> getSaleByNumber(String saleNumber) async {
    try {
      final col = await _tenantSales();
      final snapshot =
          await col.where('saleNumber', isEqualTo: saleNumber).limit(1).get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return SaleModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw DatabaseFailure(
          'Satış numarasına göre satış getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<SaleModel>> getSalesByCustomer(
    String customerId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final companyIds = await _firebaseService.getUserCompanyIds();
      Query query = _firestore
          .collection('sales')
          .where('companyId',
              isEqualTo: companyIds.isNotEmpty ? companyIds.first : null)
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true);

      // Firestore'da offset yok, pagination için startAfter kullanılmalı
      // Şimdilik offset'i ignore ediyoruz

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw DatabaseFailure(
          'Müşteriye göre satışlar getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<SaleModel>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      final companyIds = await _firebaseService.getUserCompanyIds();
      Query query = _firestore
          .collection('sales')
          .where('companyId',
              isEqualTo: companyIds.isNotEmpty ? companyIds.first : null)
          .where('saleDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('saleDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('saleDate', descending: true);

      // Firestore'da offset yok, pagination için startAfter kullanılmalı
      // Şimdilik offset'i ignore ediyoruz

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw DatabaseFailure(
          'Tarih aralığına göre satışlar getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<SaleModel>> getSalesByStatus(
    SaleStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      final companyIds = await _firebaseService.getUserCompanyIds();
      Query query = _firestore
          .collection('sales')
          .where('companyId',
              isEqualTo: companyIds.isNotEmpty ? companyIds.first : null)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      // Firestore'da offset yok, pagination için startAfter kullanılmalı
      // Şimdilik offset'i ignore ediyoruz

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw DatabaseFailure(
          'Duruma göre satışlar getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<SaleModel>> getSalesByPaymentStatus(
    PaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    try {
      final companyIds = await _firebaseService.getUserCompanyIds();
      Query query = _firestore
          .collection('sales')
          .where('companyId',
              isEqualTo: companyIds.isNotEmpty ? companyIds.first : null)
          .where('paymentStatus', isEqualTo: paymentStatus.name)
          .orderBy('createdAt', descending: true);

      // Firestore'da offset yok, pagination için startAfter kullanılmalı
      // Şimdilik offset'i ignore ediyoruz

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw DatabaseFailure(
          'Ödeme durumuna göre satışlar getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<SaleModel>> getOverdueSales({
    int? limit,
    int? offset,
  }) async {
    try {
      final now = DateTime.now();
      final companyIds = await _firebaseService.getUserCompanyIds();
      Query query = _firestore
          .collection('sales')
          .where('companyId',
              isEqualTo: companyIds.isNotEmpty ? companyIds.first : null)
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .where('paymentStatus', whereIn: ['pending', 'overdue']).orderBy(
              'dueDate',
              descending: true);

      // Firestore'da offset yok, pagination için startAfter kullanılmalı
      // Şimdilik offset'i ignore ediyoruz

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw DatabaseFailure(
          'Vadesi geçmiş satışlar getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<SaleModel> createSale(SaleModel sale) async {
    try {
      final col = await _tenantSales();
      final docRef = col.doc();
      final tenantId = await _tenantService.getUserTenantId();
      final saleWithId = sale.copyWith(id: docRef.id);
      final data = saleWithId.toFirestore();
      data['tenantId'] = tenantId;
      data['createdBy'] = _firebaseService.currentUserId;
      await docRef.set(data);
      return saleWithId;
    } catch (e) {
      throw DatabaseFailure(
          'Satış oluşturulurken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<SaleModel> updateSale(SaleModel sale) async {
    try {
      final col = await _tenantSales();
      await col.doc(sale.id).update(sale.toFirestore());
      return sale;
    } catch (e) {
      throw DatabaseFailure(
          'Satış güncellenirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    try {
      final col = await _tenantSales();
      await col.doc(id).delete();
    } catch (e) {
      throw DatabaseFailure(
          'Satış silinirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<SaleModel>> searchSales(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Firestore'da text search için algolia veya elasticsearch kullanılmalı
      // Şimdilik basit bir arama yapıyoruz
      final companyIds = await _firebaseService.getUserCompanyIds();
      final snapshot = await _firestore
          .collection('sales')
          .where('companyId',
              isEqualTo: companyIds.isNotEmpty ? companyIds.first : null)
          .where('saleNumber', isGreaterThanOrEqualTo: query)
          .where('saleNumber', isLessThan: '$query\uf8ff')
          .orderBy('saleNumber')
          .limit(limit ?? 20)
          .get();

      return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw DatabaseFailure(
          'Satış arama yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<int> getSalesCount() async {
    try {
      final companyIds = await _firebaseService.getUserCompanyIds();
      final snapshot = await _firestore
          .collection('sales')
          .where('companyId',
              isEqualTo: companyIds.isNotEmpty ? companyIds.first : null)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw DatabaseFailure(
          'Satış sayısı getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<double> getSalesTotal({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final companyIds = await _firebaseService.getUserCompanyIds();
      Query query = _firestore.collection('sales').where('companyId',
          isEqualTo: companyIds.isNotEmpty ? companyIds.first : null);

      if (startDate != null) {
        query = query.where('saleDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('saleDate',
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
      throw DatabaseFailure(
          'Satış toplamı getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Bu işlem için Firestore'da aggregation query'ler kullanılmalı
      // Şimdilik basit bir implementasyon yapıyoruz
      final sales = await getSalesByDateRange(
        startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate ?? DateTime.now(),
      );

      final productCounts = <String, Map<String, dynamic>>{};

      for (final sale in sales) {
        for (final item in sale.items) {
          final productId = item.productId;
          if (productCounts.containsKey(productId)) {
            productCounts[productId]!['quantity'] += item.quantity;
            productCounts[productId]!['total'] += item.totalAmount;
          } else {
            productCounts[productId] = {
              'productId': productId,
              'productName': item.productName,
              'quantity': item.quantity,
              'total': item.totalAmount,
            };
          }
        }
      }

      final sortedProducts = productCounts.values.toList()
        ..sort(
            (a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

      return sortedProducts.take(limit).toList();
    } catch (e) {
      throw DatabaseFailure(
          'En çok satan ürünler getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sales = await getSalesByDateRange(
        startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate ?? DateTime.now(),
      );

      final customerCounts = <String, Map<String, dynamic>>{};

      for (final sale in sales) {
        final customerId = sale.customerId;
        if (customerCounts.containsKey(customerId)) {
          customerCounts[customerId]!['count'] += 1;
          customerCounts[customerId]!['total'] += sale.totalAmount;
        } else {
          customerCounts[customerId] = {
            'customerId': customerId,
            'customerName': sale.customerName,
            'count': 1,
            'total': sale.totalAmount,
          };
        }
      }

      final sortedCustomers = customerCounts.values.toList()
        ..sort(
            (a, b) => (b['total'] as double).compareTo(a['total'] as double));

      return sortedCustomers.take(limit).toList();
    } catch (e) {
      throw DatabaseFailure(
          'En çok satış yapılan müşteriler getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sales = await getSalesByDateRange(
        startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate ?? DateTime.now(),
      );

      double totalAmount = 0.0;
      int totalCount = sales.length;
      int paidCount = 0;
      int pendingCount = 0;
      int overdueCount = 0;

      for (final sale in sales) {
        totalAmount += sale.totalAmount;

        switch (sale.paymentStatus) {
          case PaymentStatus.paid:
            paidCount++;
            break;
          case PaymentStatus.pending:
            pendingCount++;
            break;
          case PaymentStatus.overdue:
            overdueCount++;
            break;
          default:
            break;
        }
      }

      return {
        'totalAmount': totalAmount,
        'totalCount': totalCount,
        'paidCount': paidCount,
        'pendingCount': pendingCount,
        'overdueCount': overdueCount,
        'averageAmount': totalCount > 0 ? totalAmount / totalCount : 0.0,
      };
    } catch (e) {
      throw DatabaseFailure(
          'Satış istatistikleri getirilirken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<String> generateSaleNumber(SaleType type) async {
    try {
      final now = DateTime.now();
      final year = now.year;
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      // Bugünkü aynı türdeki satış sayısını al
      final startOfDay = DateTime(year, now.month, now.day);
      final endOfDay = DateTime(year, now.month, now.day, 23, 59, 59);

      final col = await _tenantSales();

      // Önce composite index ile deneyelim
      try {
        final snapshot = await col
            .where('type', isEqualTo: type.name)
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .get();

        final count = snapshot.docs.length + 1;
        final countStr = count.toString().padLeft(4, '0');

        // Satış türüne göre prefix
        String prefix;
        switch (type) {
          case SaleType.sale:
            prefix = 'SAL';
            break;
          case SaleType.invoice:
            prefix = 'FAT';
            break;
          case SaleType.proforma:
            prefix = 'PRO';
            break;
          case SaleType.waybill:
            prefix = 'IRS';
            break;
          case SaleType.receipt:
            prefix = 'FIS';
            break;
          case SaleType.estimate:
            prefix = 'TEK';
            break;
        }

        return '$prefix$year$month$day$countStr';
      } on FirebaseException catch (e) {
        // Composite index hatası alınırsa, fallback olarak tüm satışları çekip filtrele
        if (e.code == 'failed-precondition' ||
            e.message?.contains('index') == true) {
          final allSnapshot = await col
              .where('createdAt',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('createdAt',
                  isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .get();

          final filteredDocs = allSnapshot.docs
              .where((doc) => doc.data()['type'] == type.name)
              .toList();

          final count = filteredDocs.length + 1;
          final countStr = count.toString().padLeft(4, '0');

          // Satış türüne göre prefix
          String prefix;
          switch (type) {
            case SaleType.sale:
              prefix = 'SAL';
              break;
            case SaleType.invoice:
              prefix = 'FAT';
              break;
            case SaleType.proforma:
              prefix = 'PRO';
              break;
            case SaleType.waybill:
              prefix = 'IRS';
              break;
            case SaleType.receipt:
              prefix = 'FIS';
              break;
            case SaleType.estimate:
              prefix = 'TEK';
              break;
          }

          return '$prefix$year$month$day$countStr';
        }
        rethrow;
      }
    } catch (e) {
      throw DatabaseFailure(
          'Satış numarası oluşturulurken bir hata oluştu: ${e.toString()}');
    }
  }
}
