import 'package:tamgaci/features/cash_management/domain/repositories/cash_account_repository.dart';

/// Nakit hesap silme use case'i
class DeleteCashAccountUseCase {
  final CashAccountRepository _repository;

  DeleteCashAccountUseCase(this._repository);

  /// Nakit hesap siler
  /// [id]: Silinecek nakit hesap ID'si
  Future<void> call(String id) async {
    await _repository.deleteCashAccount(id);
  }
}
