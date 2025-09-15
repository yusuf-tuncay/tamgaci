import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';

/// Cash Transaction Repository Interface
/// Bu interface, nakit işlem ile ilgili tüm veri işlemlerini tanımlar.
abstract class CashTransactionRepository {
  /// Tüm nakit işlemleri getirir
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getAllCashTransactions({
    int? limit,
    int? offset,
  });

  /// ID'ye göre nakit işlem getirir
  /// [id]: Nakit işlem ID'si
  /// Returns: Nakit işlem veya null
  Future<CashTransaction?> getCashTransactionById(String id);

  /// İşlem numarasına göre nakit işlem getirir
  /// [transactionNumber]: İşlem numarası
  /// Returns: Nakit işlem veya null
  Future<CashTransaction?> getCashTransactionByNumber(String transactionNumber);

  /// Hesaba göre nakit işlemleri getirir
  /// [accountId]: Hesap ID'si
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getCashTransactionsByAccount(
    String accountId, {
    int? limit,
    int? offset,
  });

  /// Tarih aralığına göre nakit işlemleri getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getCashTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  });

  /// Türüne göre nakit işlemleri getirir
  /// [type]: Nakit işlem türü
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getCashTransactionsByType(
    CashTransactionType type, {
    int? limit,
    int? offset,
  });

  /// Kategorisine göre nakit işlemleri getirir
  /// [category]: Nakit işlem kategorisi
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getCashTransactionsByCategory(
    CashTransactionCategory category, {
    int? limit,
    int? offset,
  });

  /// Duruma göre nakit işlemleri getirir
  /// [status]: Nakit işlem durumu
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getCashTransactionsByStatus(
    CashTransactionStatus status, {
    int? limit,
    int? offset,
  });

  /// Vadesi geçmiş nakit işlemleri getirir
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getOverdueCashTransactions({
    int? limit,
    int? offset,
  });

  /// Yeni nakit işlem oluşturur
  /// [cashTransaction]: Oluşturulacak nakit işlem
  /// Returns: Oluşturulan nakit işlem
  Future<CashTransaction> createCashTransaction(
      CashTransaction cashTransaction);

  /// Nakit işlem günceller
  /// [cashTransaction]: Güncellenecek nakit işlem
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> updateCashTransaction(
      CashTransaction cashTransaction);

  /// Nakit işlem siler
  /// [id]: Silinecek nakit işlem ID'si
  Future<void> deleteCashTransaction(String id);

  /// Nakit işlem durumunu günceller
  /// [id]: Nakit işlem ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> updateCashTransactionStatus(
      String id, CashTransactionStatus status);

  /// Nakit işlem arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> searchCashTransactions(
    String query, {
    int? limit,
    int? offset,
  });

  /// Nakit işlem sayısını getirir
  /// Returns: Toplam nakit işlem sayısı
  Future<int> getCashTransactionsCount();

  /// Hesaba göre nakit işlem sayısını getirir
  /// [accountId]: Hesap ID'si
  /// Returns: Nakit işlem sayısı
  Future<int> getCashTransactionsCountByAccount(String accountId);

  /// Tarih aralığına göre nakit işlem sayısını getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// Returns: Nakit işlem sayısı
  Future<int> getCashTransactionsCountByDateRange(
      DateTime startDate, DateTime endDate);

  /// Nakit işlem toplamını getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// [type]: İşlem türü (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getCashTransactionsTotal({
    DateTime? startDate,
    DateTime? endDate,
    CashTransactionType? type,
  });

  /// Hesaba göre nakit işlem toplamını getirir
  /// [accountId]: Hesap ID'si
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// [type]: İşlem türü (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getCashTransactionsTotalByAccount(
    String accountId, {
    DateTime? startDate,
    DateTime? endDate,
    CashTransactionType? type,
  });

  /// Nakit işlem raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (type, category, account)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getCashTransactionsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  });

  /// En çok kullanılan kategorileri getirir
  /// [limit]: Maksimum kategori sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Kategori listesi
  Future<List<Map<String, dynamic>>> getTopCategories({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// En çok işlem yapılan hesapları getirir
  /// [limit]: Maksimum hesap sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Hesap listesi
  Future<List<Map<String, dynamic>>> getTopAccounts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Nakit işlem istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> getCashTransactionsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Nakit işlem numarası oluşturur
  /// [type]: Nakit işlem türü
  /// Returns: Nakit işlem numarası
  Future<String> generateCashTransactionNumber(CashTransactionType type);

  /// Nakit işlem kopyalar
  /// [id]: Kopyalanacak nakit işlem ID'si
  /// Returns: Kopyalanan nakit işlem
  Future<CashTransaction> duplicateCashTransaction(String id);

  /// Nakit işlem iptal eder
  /// [id]: Nakit işlem ID'si
  /// [reason]: İptal nedeni
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> cancelCashTransaction(String id, String reason);

  /// Nakit işlem onaylar
  /// [id]: Nakit işlem ID'si
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> approveCashTransaction(String id);

  /// Nakit işlem tamamlar
  /// [id]: Nakit işlem ID'si
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> completeCashTransaction(String id);
}
