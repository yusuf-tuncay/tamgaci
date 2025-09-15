import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_transaction_repository.dart';

/// Nakit işlem kopyalama use case'i
class DuplicateCashTransactionUseCase {
  final CashTransactionRepository _repository;

  DuplicateCashTransactionUseCase(this._repository);

  /// Nakit işlem kopyalar
  /// [id]: Kopyalanacak nakit işlem ID'si
  /// Returns: Kopyalanan nakit işlem
  Future<CashTransaction> call(String id) async {
    return await _repository.duplicateCashTransaction(id);
  }
}
