import '../entities/account.dart';

/// Hesap repository interface'i
abstract class AccountRepository {
  /// Tüm hesapları getir
  Future<List<Account>> getAccounts();

  /// ID'ye göre hesap getir
  Future<Account?> getAccountById(String id);

  /// ID'ye göre hesabı realtime olarak dinle
  Stream<Account?> getAccountStream(String id);

  /// Hesap oluştur
  Future<String> createAccount(Account account);

  /// Hesap güncelle
  Future<void> updateAccount(Account account);

  /// Hesap sil
  Future<void> deleteAccount(String id);

  /// Hesap ara
  Future<List<Account>> searchAccounts(String query);

  /// Para birimine göre hesapları getir
  Future<List<Account>> getAccountsByCurrency(String currency);

  /// Aktif hesapları getir
  Future<List<Account>> getActiveAccounts();

  /// Hesap bakiyesini güncelle
  Future<void> updateAccountBalance(String accountId, double newBalance);

  /// Hesap durumunu güncelle
  Future<void> updateAccountStatus(String accountId, AccountStatus status);
}
