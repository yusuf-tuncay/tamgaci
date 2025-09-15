import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_transaction_repository.dart';

/// Tek nakit işlem getirme use case'i
class GetCashTransactionUseCase {
  final CashTransactionRepository _repository;

  GetCashTransactionUseCase(this._repository);

  /// ID'ye göre nakit işlem getirir
  /// [id]: Nakit işlem ID'si
  /// Returns: Nakit işlem veya null
  Future<CashTransaction?> call(String id) async {
    return await _repository.getCashTransactionById(id);
  }

  /// İşlem numarasına göre nakit işlem getirir
  /// [transactionNumber]: İşlem numarası
  /// Returns: Nakit işlem veya null
  Future<CashTransaction?> getByNumber(String transactionNumber) async {
    return await _repository.getCashTransactionByNumber(transactionNumber);
  }
}
