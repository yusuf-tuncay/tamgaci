import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:tamgaci/features/purchases/data/datasources/purchase_firebase_datasource.dart';
import 'package:tamgaci/features/purchases/data/models/purchase_model.dart';

/// Purchases repository implementasyonu
/// Firebase Firestore işlemleri için repository
class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseFirebaseDataSource _dataSource;

  PurchaseRepositoryImpl({
    required PurchaseFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<Purchase>> getAllPurchases({
    bool includeItems = true,
  }) async {
    final purchaseModels = await _dataSource.getAllPurchases();
    return purchaseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Purchase?> getPurchaseById(String id) async {
    final purchaseModel = await _dataSource.getPurchaseById(id);
    return purchaseModel?.toEntity();
  }

  @override
  Future<Purchase?> getPurchaseByNumber(String purchaseNumber) async {
    final purchaseModel = await _dataSource.getPurchaseByNumber(purchaseNumber);
    return purchaseModel?.toEntity();
  }

  @override
  Future<List<Purchase>> getPurchasesBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  }) async {
    final purchaseModels = await _dataSource.getPurchasesBySupplier(
      supplierId,
      limit: limit,
      offset: offset,
    );
    return purchaseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Purchase>> getPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    final purchaseModels = await _dataSource.getPurchasesByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
    return purchaseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Purchase>> getPurchasesByStatus(
    PurchaseStatus status, {
    int? limit,
    int? offset,
  }) async {
    final purchaseModels = await _dataSource.getPurchasesByStatus(
      status,
      limit: limit,
      offset: offset,
    );
    return purchaseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Purchase>> getPurchasesByPaymentStatus(
    PurchasePaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    final purchaseModels = await _dataSource.getPurchasesByPaymentStatus(
      paymentStatus,
      limit: limit,
      offset: offset,
    );
    return purchaseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Purchase>> getOverduePurchases({
    int? limit,
    int? offset,
  }) async {
    final purchaseModels = await _dataSource.getOverduePurchases(
      limit: limit,
      offset: offset,
    );
    return purchaseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<String> createPurchase(Purchase purchase) async {
    final purchaseModel = PurchaseModel.fromEntity(purchase);
    final createdPurchaseModel =
        await _dataSource.createPurchase(purchaseModel);
    return createdPurchaseModel.id;
  }

  @override
  Future<Purchase> updatePurchase(Purchase purchase) async {
    final purchaseModel = PurchaseModel.fromEntity(purchase);
    final updatedPurchaseModel =
        await _dataSource.updatePurchase(purchaseModel);
    return updatedPurchaseModel.toEntity();
  }

  @override
  Future<void> deletePurchase(String id) async {
    await _dataSource.deletePurchase(id);
  }

  @override
  Future<Purchase> updatePurchaseStatus(
      String id, PurchaseStatus status) async {
    final purchase = await getPurchaseById(id);
    if (purchase == null) {
      throw Exception('Satın alma bulunamadı');
    }

    final updatedPurchase = purchase.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    return await updatePurchase(updatedPurchase);
  }

  @override
  Future<Purchase> updatePaymentStatus(
      String id, PurchasePaymentStatus paymentStatus) async {
    final purchase = await getPurchaseById(id);
    if (purchase == null) {
      throw Exception('Satın alma bulunamadı');
    }

    final updatedPurchase = purchase.copyWith(
      paymentStatus: paymentStatus,
      updatedAt: DateTime.now(),
    );

    return await updatePurchase(updatedPurchase);
  }

  @override
  Future<List<Purchase>> searchPurchases(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final purchaseModels = await _dataSource.searchPurchases(
      query,
      limit: limit,
      offset: offset,
    );
    return purchaseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getPurchasesCount() async {
    return await _dataSource.getPurchasesCount();
  }

  @override
  Future<int> getPurchasesCountBySupplier(String supplierId) async {
    final purchases = await getPurchasesBySupplier(supplierId);
    return purchases.length;
  }

  @override
  Future<int> getPurchasesCountByDateRange(
      DateTime startDate, DateTime endDate) async {
    final purchases = await getPurchasesByDateRange(startDate, endDate);
    return purchases.length;
  }

  @override
  Future<double> getPurchasesTotal({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getPurchasesTotal(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<double> getPurchasesTotalBySupplier(
    String supplierId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final purchases = await getPurchasesBySupplier(supplierId);

    if (startDate != null && endDate != null) {
      final filteredPurchases = purchases.where((purchase) {
        return purchase.purchaseDate.isAfter(startDate) &&
            purchase.purchaseDate.isBefore(endDate);
      }).toList();

      double total = 0.0;
      for (final purchase in filteredPurchases) {
        total += purchase.totalAmount;
      }
      return total;
    }

    double total = 0.0;
    for (final purchase in purchases) {
      total += purchase.totalAmount;
    }
    return total;
  }

  @override
  Future<Map<String, dynamic>> getPurchasesReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    final purchases = await getPurchasesByDateRange(startDate, endDate);

    final report = <String, dynamic>{
      'totalAmount': 0.0,
      'totalCount': purchases.length,
      'groupedData': <String, dynamic>{},
    };

    for (final purchase in purchases) {
      report['totalAmount'] =
          (report['totalAmount'] as double) + purchase.totalAmount;

      if (groupBy != null) {
        String key;
        switch (groupBy) {
          case 'supplier':
            key = purchase.supplierName ?? purchase.supplierId;
            break;
          case 'product':
            // Ürün bazında gruplama için items'ları işle
            for (final item in purchase.items) {
              final productKey = item.productName ?? item.productId;
              if (!report['groupedData'].containsKey(productKey)) {
                report['groupedData'][productKey] = {
                  'count': 0,
                  'amount': 0.0,
                };
              }
              report['groupedData'][productKey]['count'] += item.quantity;
              report['groupedData'][productKey]['amount'] += item.totalAmount;
            }
            continue;
          case 'date':
            key = purchase.purchaseDate.toIso8601String().split('T')[0];
            break;
          default:
            key = 'unknown';
        }

        if (!report['groupedData'].containsKey(key)) {
          report['groupedData'][key] = {
            'count': 0,
            'amount': 0.0,
          };
        }
        report['groupedData'][key]['count'] += 1;
        report['groupedData'][key]['amount'] += purchase.totalAmount;
      }
    }

    return report;
  }

  @override
  Future<List<Map<String, dynamic>>> getTopPurchasedProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getTopPurchasedProducts(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTopSuppliers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getTopSuppliers(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Map<String, dynamic>> getPurchasesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getPurchasesStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<String> generatePurchaseNumber() async {
    return await _dataSource.generatePurchaseNumber(PurchaseType.purchase);
  }

  @override
  Future<Purchase> duplicatePurchase(String id) async {
    final originalPurchase = await getPurchaseById(id);
    if (originalPurchase == null) {
      throw Exception('Satın alma bulunamadı');
    }

    final newPurchaseNumber = await generatePurchaseNumber();

    final duplicatedPurchase = originalPurchase.copyWith(
      id: '', // Yeni ID oluşturulacak
      purchaseNumber: newPurchaseNumber,
      status: PurchaseStatus.draft,
      paymentStatus: PurchasePaymentStatus.pending,
      purchaseDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final purchaseId = await createPurchase(duplicatedPurchase);
    return duplicatedPurchase.copyWith(id: purchaseId);
  }

  @override
  Future<Purchase> cancelPurchase(String id, String reason) async {
    final purchase = await getPurchaseById(id);
    if (purchase == null) {
      throw Exception('Satın alma bulunamadı');
    }

    final cancelledPurchase = purchase.copyWith(
      status: PurchaseStatus.cancelled,
      notes: '${purchase.notes ?? ''}\nİptal nedeni: $reason'.trim(),
      updatedAt: DateTime.now(),
    );

    return await updatePurchase(cancelledPurchase);
  }

  @override
  Future<Purchase> returnPurchase(String id, String reason) async {
    final purchase = await getPurchaseById(id);
    if (purchase == null) {
      throw Exception('Satın alma bulunamadı');
    }

    final returnedPurchase = purchase.copyWith(
      status: PurchaseStatus.returned,
      notes: '${purchase.notes ?? ''}\nİade nedeni: $reason'.trim(),
      updatedAt: DateTime.now(),
    );

    return await updatePurchase(returnedPurchase);
  }

  @override
  Future<Purchase> approvePurchase(String id) async {
    return await updatePurchaseStatus(id, PurchaseStatus.confirmed);
  }

  @override
  Future<Purchase> receivePurchase(String id) async {
    return await updatePurchaseStatus(id, PurchaseStatus.received);
  }

  @override
  Future<List<Purchase>> getPurchasesBySupplierId(String supplierId) async {
    final purchaseModels = await _dataSource.getPurchasesBySupplier(supplierId);
    return purchaseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<Purchase>> watchAllPurchases() async* {
    // Stream implementation - şimdilik boş
    yield [];
  }

  @override
  Stream<Purchase?> watchPurchaseById(String id) async* {
    // Stream implementation - şimdilik boş
    yield null;
  }

  @override
  Stream<List<Purchase>> watchPurchasesBySupplierId(String supplierId) async* {
    // Stream implementation - şimdilik boş
    yield [];
  }
}
