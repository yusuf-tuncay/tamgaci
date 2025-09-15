import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/domain/repositories/sale_repository.dart';
import 'package:tamgaci/features/sales/data/datasources/sale_firebase_datasource.dart';
import 'package:tamgaci/features/sales/data/models/sale_model.dart';

/// Sales repository implementasyonu
/// Firebase Firestore işlemleri için repository
class SaleRepositoryImpl implements SaleRepository {
  final SaleFirebaseDataSource _dataSource;

  SaleRepositoryImpl({
    required SaleFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<Sale>> getAllSales({
    int? limit,
    int? offset,
  }) async {
    final saleModels = await _dataSource.getAllSales(
      limit: limit,
      offset: offset,
    );
    return saleModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Sale?> getSaleById(String id) async {
    final saleModel = await _dataSource.getSaleById(id);
    return saleModel?.toEntity();
  }

  @override
  Future<Sale?> getSaleByNumber(String saleNumber) async {
    final saleModel = await _dataSource.getSaleByNumber(saleNumber);
    return saleModel?.toEntity();
  }

  @override
  Future<List<Sale>> getSalesByCustomer(
    String customerId, {
    int? limit,
    int? offset,
  }) async {
    final saleModels = await _dataSource.getSalesByCustomer(
      customerId,
      limit: limit,
      offset: offset,
    );
    return saleModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Sale>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    final saleModels = await _dataSource.getSalesByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
    return saleModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Sale>> getSalesByStatus(
    SaleStatus status, {
    int? limit,
    int? offset,
  }) async {
    final saleModels = await _dataSource.getSalesByStatus(
      status,
      limit: limit,
      offset: offset,
    );
    return saleModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Sale>> getSalesByPaymentStatus(
    PaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    final saleModels = await _dataSource.getSalesByPaymentStatus(
      paymentStatus,
      limit: limit,
      offset: offset,
    );
    return saleModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Sale>> getOverdueSales({
    int? limit,
    int? offset,
  }) async {
    final saleModels = await _dataSource.getOverdueSales(
      limit: limit,
      offset: offset,
    );
    return saleModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Sale> createSale(Sale sale) async {
    final saleModel = SaleModel.fromEntity(sale);
    final createdSaleModel = await _dataSource.createSale(saleModel);
    return createdSaleModel.toEntity();
  }

  @override
  Future<Sale> updateSale(Sale sale) async {
    final saleModel = SaleModel.fromEntity(sale);
    final updatedSaleModel = await _dataSource.updateSale(saleModel);
    return updatedSaleModel.toEntity();
  }

  @override
  Future<void> deleteSale(String id) async {
    await _dataSource.deleteSale(id);
  }

  @override
  Future<Sale> updateSaleStatus(String id, SaleStatus status) async {
    final sale = await getSaleById(id);
    if (sale == null) {
      throw Exception('Satış bulunamadı');
    }

    final updatedSale = sale.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    return await updateSale(updatedSale);
  }

  @override
  Future<Sale> updatePaymentStatus(
      String id, PaymentStatus paymentStatus) async {
    final sale = await getSaleById(id);
    if (sale == null) {
      throw Exception('Satış bulunamadı');
    }

    final updatedSale = sale.copyWith(
      paymentStatus: paymentStatus,
      updatedAt: DateTime.now(),
    );

    return await updateSale(updatedSale);
  }

  @override
  Future<List<Sale>> searchSales(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final saleModels = await _dataSource.searchSales(
      query,
      limit: limit,
      offset: offset,
    );
    return saleModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getSalesCount() async {
    return await _dataSource.getSalesCount();
  }

  @override
  Future<int> getSalesCountByCustomer(String customerId) async {
    final sales = await getSalesByCustomer(customerId);
    return sales.length;
  }

  @override
  Future<int> getSalesCountByDateRange(
      DateTime startDate, DateTime endDate) async {
    final sales = await getSalesByDateRange(startDate, endDate);
    return sales.length;
  }

  @override
  Future<double> getSalesTotal({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getSalesTotal(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<double> getSalesTotalByCustomer(
    String customerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final sales = await getSalesByCustomer(customerId);

    if (startDate != null && endDate != null) {
      final filteredSales = sales.where((sale) {
        return sale.saleDate.isAfter(startDate) &&
            sale.saleDate.isBefore(endDate);
      }).toList();

      double total = 0.0;
      for (final sale in filteredSales) {
        total += sale.totalAmount;
      }
      return total;
    }

    double total = 0.0;
    for (final sale in sales) {
      total += sale.totalAmount;
    }
    return total;
  }

  @override
  Future<Map<String, dynamic>> getSalesReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    final sales = await getSalesByDateRange(startDate, endDate);

    final report = <String, dynamic>{
      'totalAmount': 0.0,
      'totalCount': sales.length,
      'groupedData': <String, dynamic>{},
    };

    for (final sale in sales) {
      report['totalAmount'] =
          (report['totalAmount'] as double) + sale.totalAmount;

      if (groupBy != null) {
        String key;
        switch (groupBy) {
          case 'customer':
            key = sale.customerName ?? sale.customerId;
            break;
          case 'product':
            // Ürün bazında gruplama için items'ları işle
            for (final item in sale.items) {
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
            key = sale.saleDate.toIso8601String().split('T')[0];
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
        report['groupedData'][key]['amount'] += sale.totalAmount;
      }
    }

    return report;
  }

  @override
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getTopSellingProducts(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getTopCustomers(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getSalesStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<String> generateSaleNumber(SaleType type) async {
    return await _dataSource.generateSaleNumber(type);
  }

  @override
  Future<Sale> duplicateSale(String id) async {
    final originalSale = await getSaleById(id);
    if (originalSale == null) {
      throw Exception('Satış bulunamadı');
    }

    final newSaleNumber = await generateSaleNumber(originalSale.type);

    final duplicatedSale = originalSale.copyWith(
      id: '', // Yeni ID oluşturulacak
      saleNumber: newSaleNumber,
      status: SaleStatus.draft,
      paymentStatus: PaymentStatus.pending,
      saleDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createSale(duplicatedSale);
  }

  @override
  Future<Sale> cancelSale(String id, String reason) async {
    final sale = await getSaleById(id);
    if (sale == null) {
      throw Exception('Satış bulunamadı');
    }

    final cancelledSale = sale.copyWith(
      status: SaleStatus.cancelled,
      notes: '${sale.notes ?? ''}\nİptal nedeni: $reason'.trim(),
      updatedAt: DateTime.now(),
    );

    return await updateSale(cancelledSale);
  }

  @override
  Future<Sale> returnSale(String id, String reason) async {
    final sale = await getSaleById(id);
    if (sale == null) {
      throw Exception('Satış bulunamadı');
    }

    final returnedSale = sale.copyWith(
      status: SaleStatus.returned,
      notes: '${sale.notes ?? ''}\nİade nedeni: $reason'.trim(),
      updatedAt: DateTime.now(),
    );

    return await updateSale(returnedSale);
  }

  @override
  Future<Sale> approveSale(String id) async {
    return await updateSaleStatus(id, SaleStatus.confirmed);
  }

  @override
  Future<Sale> shipSale(String id, String trackingNumber) async {
    final sale = await getSaleById(id);
    if (sale == null) {
      throw Exception('Satış bulunamadı');
    }

    final shippedSale = sale.copyWith(
      status: SaleStatus.shipped,
      notes: '${sale.notes ?? ''}\nTakip numarası: $trackingNumber'.trim(),
      updatedAt: DateTime.now(),
    );

    return await updateSale(shippedSale);
  }

  @override
  Future<Sale> deliverSale(String id) async {
    return await updateSaleStatus(id, SaleStatus.delivered);
  }
}
