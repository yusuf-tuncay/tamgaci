import 'package:tamgaci/features/cash_management/domain/repositories/cash_transaction_repository.dart';

/// Nakit işlem silme use case'i
class DeleteCashTransactionUseCase {
  final CashTransactionRepository _repository;

  DeleteCashTransactionUseCase(this._repository);

  /// Nakit işlem siler
  /// [id]: Silinecek nakit işlem ID'si
  Future<void> call(String id) async {
    await _repository.deleteCashTransaction(id);
  }
}
