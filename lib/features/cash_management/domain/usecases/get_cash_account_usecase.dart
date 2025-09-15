import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_account_repository.dart';

/// Tek nakit hesap getirme use case'i
class GetCashAccountUseCase {
  final CashAccountRepository _repository;

  GetCashAccountUseCase(this._repository);

  /// ID'ye göre nakit hesap getirir
  /// [id]: Nakit hesap ID'si
  /// Returns: Nakit hesap veya null
  Future<CashAccount?> call(String id) async {
    return await _repository.getCashAccountById(id);
  }
}
