import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_transaction_repository.dart';

/// Nakit işlem güncelleme use case'i
class UpdateCashTransactionUseCase {
  final CashTransactionRepository _repository;

  UpdateCashTransactionUseCase(this._repository);

  /// Nakit işlem günceller
  /// [cashTransaction]: Güncellenecek nakit işlem
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> call(CashTransaction cashTransaction) async {
    final updatedCashTransaction = cashTransaction.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateCashTransaction(updatedCashTransaction);
  }

  /// Nakit işlem durumunu günceller
  /// [id]: Nakit işlem ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> updateStatus(
      String id, CashTransactionStatus status) async {
    return await _repository.updateCashTransactionStatus(id, status);
  }

  /// Nakit işlem onaylar
  /// [id]: Nakit işlem ID'si
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> approve(String id) async {
    return await _repository.approveCashTransaction(id);
  }

  /// Nakit işlem tamamlar
  /// [id]: Nakit işlem ID'si
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> complete(String id) async {
    return await _repository.completeCashTransaction(id);
  }

  /// Nakit işlem iptal eder
  /// [id]: Nakit işlem ID'si
  /// [reason]: İptal nedeni
  /// Returns: Güncellenmiş nakit işlem
  Future<CashTransaction> cancel(String id, String reason) async {
    return await _repository.cancelCashTransaction(id, reason);
  }
}
