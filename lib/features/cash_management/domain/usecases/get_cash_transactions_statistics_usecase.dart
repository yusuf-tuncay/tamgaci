import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_transaction_repository.dart';

/// Nakit işlemler istatistikleri use case'i
class GetCashTransactionsStatisticsUseCase {
  final CashTransactionRepository _repository;

  GetCashTransactionsStatisticsUseCase(this._repository);

  /// Nakit işlemler istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getCashTransactionsStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Nakit işlemler raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (type, category, account)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    return await _repository.getCashTransactionsReport(
      startDate,
      endDate,
      groupBy: groupBy,
    );
  }

  /// En çok kullanılan kategorileri getirir
  /// [limit]: Maksimum kategori sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Kategori listesi
  Future<List<Map<String, dynamic>>> getTopCategories({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTopCategories(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// En çok işlem yapılan hesapları getirir
  /// [limit]: Maksimum hesap sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Hesap listesi
  Future<List<Map<String, dynamic>>> getTopAccounts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTopAccounts(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Nakit işlem toplamını getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// [type]: İşlem türü (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getTotal({
    DateTime? startDate,
    DateTime? endDate,
    CashTransactionType? type,
  }) async {
    return await _repository.getCashTransactionsTotal(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  /// Hesaba göre nakit işlem toplamını getirir
  /// [accountId]: Hesap ID'si
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// [type]: İşlem türü (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getTotalByAccount(
    String accountId, {
    DateTime? startDate,
    DateTime? endDate,
    CashTransactionType? type,
  }) async {
    return await _repository.getCashTransactionsTotalByAccount(
      accountId,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  /// Nakit işlem sayısını getirir
  /// Returns: Toplam nakit işlem sayısı
  Future<int> getCount() async {
    return await _repository.getCashTransactionsCount();
  }

  /// Hesaba göre nakit işlem sayısını getirir
  /// [accountId]: Hesap ID'si
  /// Returns: Nakit işlem sayısı
  Future<int> getCountByAccount(String accountId) async {
    return await _repository.getCashTransactionsCountByAccount(accountId);
  }

  /// Tarih aralığına göre nakit işlem sayısını getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// Returns: Nakit işlem sayısı
  Future<int> getCountByDateRange(DateTime startDate, DateTime endDate) async {
    return await _repository.getCashTransactionsCountByDateRange(
        startDate, endDate);
  }
}
