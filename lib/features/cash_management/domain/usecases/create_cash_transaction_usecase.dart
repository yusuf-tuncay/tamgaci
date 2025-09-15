import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_transaction_repository.dart';

/// Nakit işlem oluşturma use case'i
class CreateCashTransactionUseCase {
  final CashTransactionRepository _repository;

  CreateCashTransactionUseCase(this._repository);

  /// Yeni nakit işlem oluşturur
  /// [cashTransaction]: Oluşturulacak nakit işlem
  /// Returns: Oluşturulan nakit işlem
  Future<CashTransaction> call(CashTransaction cashTransaction) async {
    // Nakit işlem numarası otomatik oluşturulacak
    final transactionNumber =
        await _repository.generateCashTransactionNumber(cashTransaction.type);

    final newCashTransaction = cashTransaction.copyWith(
      transactionNumber: transactionNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createCashTransaction(newCashTransaction);
  }
}
