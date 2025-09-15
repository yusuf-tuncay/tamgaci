import 'package:tamgaci/features/purchases/domain/repositories/purchase_repository.dart';

/// Satın alma istatistikleri use case'i
class GetPurchasesStatisticsUseCase {
  final PurchaseRepository _repository;

  GetPurchasesStatisticsUseCase(this._repository);

  /// Satın alma istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getPurchasesStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Satın alma raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (supplier, product, date)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    return await _repository.getPurchasesReport(
      startDate,
      endDate,
      groupBy: groupBy,
    );
  }

  /// En çok satın alınan ürünleri getirir
  /// [limit]: Maksimum ürün sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Ürün listesi
  Future<List<Map<String, dynamic>>> getTopPurchasedProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTopPurchasedProducts(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// En çok satın alma yapılan tedarikçileri getirir
  /// [limit]: Maksimum tedarikçi sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Tedarikçi listesi
  Future<List<Map<String, dynamic>>> getTopSuppliers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTopSuppliers(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Satın alma toplamını getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getTotal({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getPurchasesTotal(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Tedarikçiye göre satın alma toplamını getirir
  /// [supplierId]: Tedarikçi ID'si
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getTotalBySupplier(
    String supplierId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getPurchasesTotalBySupplier(
      supplierId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Satın alma sayısını getirir
  /// Returns: Toplam satın alma sayısı
  Future<int> getCount() async {
    return await _repository.getPurchasesCount();
  }

  /// Tedarikçiye göre satın alma sayısını getirir
  /// [supplierId]: Tedarikçi ID'si
  /// Returns: Satın alma sayısı
  Future<int> getCountBySupplier(String supplierId) async {
    return await _repository.getPurchasesCountBySupplier(supplierId);
  }

  /// Tarih aralığına göre satın alma sayısını getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// Returns: Satın alma sayısı
  Future<int> getCountByDateRange(DateTime startDate, DateTime endDate) async {
    return await _repository.getPurchasesCountByDateRange(startDate, endDate);
  }
}
