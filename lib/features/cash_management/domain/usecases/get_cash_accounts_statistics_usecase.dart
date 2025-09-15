import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_account_repository.dart';

/// Nakit hesaplar istatistikleri use case'i
class GetCashAccountsStatisticsUseCase {
  final CashAccountRepository _repository;

  GetCashAccountsStatisticsUseCase(this._repository);

  /// Nakit hesaplar istatistiklerini getirir
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> call() async {
    return await _repository.getCashAccountsStatistics();
  }

  /// Nakit hesaplar raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (type, status)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    return await _repository.getCashAccountsReport(
      startDate,
      endDate,
      groupBy: groupBy,
    );
  }

  /// Toplam bakiyeyi getirir
  /// [currency]: Para birimi (opsiyonel)
  /// Returns: Toplam bakiye
  Future<double> getTotalBalance({String? currency}) async {
    return await _repository.getTotalBalance(currency: currency);
  }

  /// Türüne göre toplam bakiyeyi getirir
  /// [type]: Nakit hesap türü
  /// [currency]: Para birimi (opsiyonel)
  /// Returns: Toplam bakiye
  Future<double> getTotalBalanceByType(CashAccountType type,
      {String? currency}) async {
    return await _repository.getTotalBalanceByType(type, currency: currency);
  }

  /// Nakit hesap sayısını getirir
  /// Returns: Toplam nakit hesap sayısı
  Future<int> getCount() async {
    return await _repository.getCashAccountsCount();
  }

  /// Türüne göre nakit hesap sayısını getirir
  /// [type]: Nakit hesap türü
  /// Returns: Nakit hesap sayısı
  Future<int> getCountByType(CashAccountType type) async {
    return await _repository.getCashAccountsCountByType(type);
  }
}
