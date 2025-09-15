import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_account_repository.dart';

/// Nakit hesap oluşturma use case'i
class CreateCashAccountUseCase {
  final CashAccountRepository _repository;

  CreateCashAccountUseCase(this._repository);

  /// Yeni nakit hesap oluşturur
  /// [cashAccount]: Oluşturulacak nakit hesap
  /// Returns: Oluşturulan nakit hesap
  Future<CashAccount> call(CashAccount cashAccount) async {
    // Nakit hesap numarası otomatik oluşturulacak
    final accountNumber =
        await _repository.generateCashAccountNumber(cashAccount.type);

    final newCashAccount = cashAccount.copyWith(
      accountNumber: accountNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createCashAccount(newCashAccount);
  }
}
