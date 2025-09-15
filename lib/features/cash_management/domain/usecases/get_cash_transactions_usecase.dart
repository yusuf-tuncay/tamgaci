import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_transaction_repository.dart';

/// Nakit işlemleri getirme use case'i
class GetCashTransactionsUseCase {
  final CashTransactionRepository _repository;

  GetCashTransactionsUseCase(this._repository);

  /// Tüm nakit işlemleri getirir
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> call({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getAllCashTransactions(
      limit: limit,
      offset: offset,
    );
  }

  /// Hesaba göre nakit işlemleri getirir
  /// [accountId]: Hesap ID'si
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getByAccount(
    String accountId, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getCashTransactionsByAccount(
      accountId,
      limit: limit,
      offset: offset,
    );
  }

  /// Tarih aralığına göre nakit işlemleri getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getCashTransactionsByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Türüne göre nakit işlemleri getirir
  /// [type]: Nakit işlem türü
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getByType(
    CashTransactionType type, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getCashTransactionsByType(
      type,
      limit: limit,
      offset: offset,
    );
  }

  /// Kategorisine göre nakit işlemleri getirir
  /// [category]: Nakit işlem kategorisi
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getByCategory(
    CashTransactionCategory category, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getCashTransactionsByCategory(
      category,
      limit: limit,
      offset: offset,
    );
  }

  /// Duruma göre nakit işlemleri getirir
  /// [status]: Nakit işlem durumu
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getByStatus(
    CashTransactionStatus status, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getCashTransactionsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
  }

  /// Vadesi geçmiş nakit işlemleri getirir
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> getOverdue({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getOverdueCashTransactions(
      limit: limit,
      offset: offset,
    );
  }

  /// Nakit işlem arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum işlem sayısı
  /// [offset]: Atlanacak işlem sayısı
  /// Returns: Nakit işlem listesi
  Future<List<CashTransaction>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.searchCashTransactions(
      query,
      limit: limit,
      offset: offset,
    );
  }
}
