import 'package:tamgaci/features/sales/domain/repositories/sale_repository.dart';

/// Satış istatistikleri use case'i
class GetSalesStatisticsUseCase {
  final SaleRepository _repository;

  GetSalesStatisticsUseCase(this._repository);

  /// Satış istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getSalesStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Satış raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (customer, product, date)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    return await _repository.getSalesReport(
      startDate,
      endDate,
      groupBy: groupBy,
    );
  }

  /// En çok satan ürünleri getirir
  /// [limit]: Maksimum ürün sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Ürün listesi
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTopSellingProducts(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// En çok alışveriş yapan müşterileri getirir
  /// [limit]: Maksimum müşteri sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Müşteri listesi
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTopCustomers(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Satış toplamını getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getTotal({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getSalesTotal(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Müşteriye göre satış toplamını getirir
  /// [customerId]: Müşteri ID'si
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getTotalByCustomer(
    String customerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getSalesTotalByCustomer(
      customerId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Satış sayısını getirir
  /// Returns: Toplam satış sayısı
  Future<int> getCount() async {
    return await _repository.getSalesCount();
  }

  /// Müşteriye göre satış sayısını getirir
  /// [customerId]: Müşteri ID'si
  /// Returns: Satış sayısı
  Future<int> getCountByCustomer(String customerId) async {
    return await _repository.getSalesCountByCustomer(customerId);
  }

  /// Tarih aralığına göre satış sayısını getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// Returns: Satış sayısı
  Future<int> getCountByDateRange(DateTime startDate, DateTime endDate) async {
    return await _repository.getSalesCountByDateRange(startDate, endDate);
  }
}
