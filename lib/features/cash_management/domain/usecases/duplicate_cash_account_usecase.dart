import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_account_repository.dart';

/// Nakit hesap kopyalama use case'i
class DuplicateCashAccountUseCase {
  final CashAccountRepository _repository;

  DuplicateCashAccountUseCase(this._repository);

  /// Nakit hesap kopyalar
  /// [id]: Kopyalanacak nakit hesap ID'si
  /// Returns: Kopyalanan nakit hesap
  Future<CashAccount> call(String id) async {
    return await _repository.duplicateCashAccount(id);
  }
}
