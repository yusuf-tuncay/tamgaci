import '../entities/account_transaction.dart';

/// Hesap işlemi repository interface'i
abstract class AccountTransactionRepository {
  /// Tüm işlemleri getir
  Future<List<AccountTransaction>> getTransactions();

  /// ID'ye göre işlem getir
  Future<AccountTransaction?> getTransactionById(String id);

  /// Hesap ID'sine göre işlemleri getir
  Future<List<AccountTransaction>> getTransactionsByAccountId(String accountId);

  /// İşlem oluştur
  Future<String> createTransaction(AccountTransaction transaction);

  /// İşlem güncelle
  Future<void> updateTransaction(AccountTransaction transaction);

  /// İşlem sil
  Future<void> deleteTransaction(String id);

  /// İşlem ara
  Future<List<AccountTransaction>> searchTransactions(String query);

  /// Tarih aralığına göre işlemleri getir
  Future<List<AccountTransaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Hesap ID'sine göre tarih aralığında işlemleri getir
  Future<List<AccountTransaction>> getTransactionsByAccountAndDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Kategoriye göre işlemleri getir
  Future<List<AccountTransaction>> getTransactionsByCategory(
    TransactionCategory category,
  );

  /// Türe göre işlemleri getir
  Future<List<AccountTransaction>> getTransactionsByType(
    TransactionType type,
  );

  /// İşlem durumuna göre işlemleri getir

  /// Mutabakat yapılmamış işlemleri getir
  Future<List<AccountTransaction>> getUnreconciledTransactions();

  /// İşlem mutabakatını güncelle
  Future<void> updateTransactionReconciliation(
    String transactionId,
    bool isReconciled,
    String reconciledBy,
  );
}
