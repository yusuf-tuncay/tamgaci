import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';

/// Cash Account Repository Interface
/// Bu interface, nakit hesap ile ilgili tüm veri işlemlerini tanımlar.
abstract class CashAccountRepository {
  /// Tüm nakit hesapları getirir
  /// [limit]: Maksimum hesap sayısı
  /// [offset]: Atlanacak hesap sayısı
  /// Returns: Nakit hesap listesi
  Future<List<CashAccount>> getAllCashAccounts({
    int? limit,
    int? offset,
  });

  /// ID'ye göre nakit hesap getirir
  /// [id]: Nakit hesap ID'si
  /// Returns: Nakit hesap veya null
  Future<CashAccount?> getCashAccountById(String id);

  /// Türüne göre nakit hesapları getirir
  /// [type]: Nakit hesap türü
  /// [limit]: Maksimum hesap sayısı
  /// [offset]: Atlanacak hesap sayısı
  /// Returns: Nakit hesap listesi
  Future<List<CashAccount>> getCashAccountsByType(
    CashAccountType type, {
    int? limit,
    int? offset,
  });

  /// Duruma göre nakit hesapları getirir
  /// [status]: Nakit hesap durumu
  /// [limit]: Maksimum hesap sayısı
  /// [offset]: Atlanacak hesap sayısı
  /// Returns: Nakit hesap listesi
  Future<List<CashAccount>> getCashAccountsByStatus(
    CashAccountStatus status, {
    int? limit,
    int? offset,
  });

  /// Varsayılan nakit hesabı getirir
  /// Returns: Varsayılan nakit hesap veya null
  Future<CashAccount?> getDefaultCashAccount();

  /// Yeni nakit hesap oluşturur
  /// [cashAccount]: Oluşturulacak nakit hesap
  /// Returns: Oluşturulan nakit hesap
  Future<CashAccount> createCashAccount(CashAccount cashAccount);

  /// Nakit hesap günceller
  /// [cashAccount]: Güncellenecek nakit hesap
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> updateCashAccount(CashAccount cashAccount);

  /// Nakit hesap siler
  /// [id]: Silinecek nakit hesap ID'si
  Future<void> deleteCashAccount(String id);

  /// Nakit hesap durumunu günceller
  /// [id]: Nakit hesap ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> updateCashAccountStatus(
      String id, CashAccountStatus status);

  /// Nakit hesap bakiyesini günceller
  /// [id]: Nakit hesap ID'si
  /// [balance]: Yeni bakiye
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> updateCashAccountBalance(String id, double balance);

  /// Nakit hesap arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum hesap sayısı
  /// [offset]: Atlanacak hesap sayısı
  /// Returns: Nakit hesap listesi
  Future<List<CashAccount>> searchCashAccounts(
    String query, {
    int? limit,
    int? offset,
  });

  /// Nakit hesap sayısını getirir
  /// Returns: Toplam nakit hesap sayısı
  Future<int> getCashAccountsCount();

  /// Türüne göre nakit hesap sayısını getirir
  /// [type]: Nakit hesap türü
  /// Returns: Nakit hesap sayısı
  Future<int> getCashAccountsCountByType(CashAccountType type);

  /// Toplam bakiyeyi getirir
  /// [currency]: Para birimi (opsiyonel)
  /// Returns: Toplam bakiye
  Future<double> getTotalBalance({String? currency});

  /// Türüne göre toplam bakiyeyi getirir
  /// [type]: Nakit hesap türü
  /// [currency]: Para birimi (opsiyonel)
  /// Returns: Toplam bakiye
  Future<double> getTotalBalanceByType(CashAccountType type,
      {String? currency});

  /// Nakit hesap raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (type, status)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getCashAccountsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  });

  /// Nakit hesap istatistiklerini getirir
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> getCashAccountsStatistics();

  /// Nakit hesap numarası oluşturur
  /// [type]: Nakit hesap türü
  /// Returns: Nakit hesap numarası
  Future<String> generateCashAccountNumber(CashAccountType type);

  /// Nakit hesap kopyalar
  /// [id]: Kopyalanacak nakit hesap ID'si
  /// Returns: Kopyalanan nakit hesap
  Future<CashAccount> duplicateCashAccount(String id);

  /// Nakit hesap arşivler
  /// [id]: Nakit hesap ID'si
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> archiveCashAccount(String id);

  /// Nakit hesap aktifleştirir
  /// [id]: Nakit hesap ID'si
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> activateCashAccount(String id);

  /// Tüm nakit hesapları stream olarak getirir
  /// Returns: Nakit hesap stream'i
  Stream<List<CashAccount>> watchAllCashAccounts();
}
