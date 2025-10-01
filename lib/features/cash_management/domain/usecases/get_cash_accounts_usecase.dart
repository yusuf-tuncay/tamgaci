import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_account_repository.dart';

/// Nakit hesapları getirme use case'i
class GetCashAccountsUseCase {
  final CashAccountRepository _repository;

  GetCashAccountsUseCase(this._repository);

  /// Tüm nakit hesapları getirir
  /// [limit]: Maksimum hesap sayısı
  /// [offset]: Atlanacak hesap sayısı
  /// Returns: Nakit hesap listesi
  Future<List<CashAccount>> call({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getAllCashAccounts(
      limit: limit,
      offset: offset,
    );
  }

  /// Türüne göre nakit hesapları getirir
  /// [type]: Nakit hesap türü
  /// [limit]: Maksimum hesap sayısı
  /// [offset]: Atlanacak hesap sayısı
  /// Returns: Nakit hesap listesi
  Future<List<CashAccount>> getByType(
    CashAccountType type, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getCashAccountsByType(
      type,
      limit: limit,
      offset: offset,
    );
  }

  /// Duruma göre nakit hesapları getirir
  /// [status]: Nakit hesap durumu
  /// [limit]: Maksimum hesap sayısı
  /// [offset]: Atlanacak hesap sayısı
  /// Returns: Nakit hesap listesi
  Future<List<CashAccount>> getByStatus(
    CashAccountStatus status, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getCashAccountsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
  }

  /// Varsayılan nakit hesabı getirir
  /// Returns: Varsayılan nakit hesap veya null
  Future<CashAccount?> getDefault() async {
    return await _repository.getDefaultCashAccount();
  }

  /// Nakit hesap arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum hesap sayısı
  /// [offset]: Atlanacak hesap sayısı
  /// Returns: Nakit hesap listesi
  Future<List<CashAccount>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.searchCashAccounts(
      query,
      limit: limit,
      offset: offset,
    );
  }

  /// Tüm nakit hesapları stream olarak getirir
  /// Returns: Nakit hesap stream'i
  Stream<List<CashAccount>> watchAll() {
    return _repository.watchAllCashAccounts();
  }
}
