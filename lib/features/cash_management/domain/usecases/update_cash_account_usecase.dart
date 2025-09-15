import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_account_repository.dart';

/// Nakit hesap güncelleme use case'i
class UpdateCashAccountUseCase {
  final CashAccountRepository _repository;

  UpdateCashAccountUseCase(this._repository);

  /// Nakit hesap günceller
  /// [cashAccount]: Güncellenecek nakit hesap
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> call(CashAccount cashAccount) async {
    final updatedCashAccount = cashAccount.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateCashAccount(updatedCashAccount);
  }

  /// Nakit hesap durumunu günceller
  /// [id]: Nakit hesap ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> updateStatus(String id, CashAccountStatus status) async {
    return await _repository.updateCashAccountStatus(id, status);
  }

  /// Nakit hesap bakiyesini günceller
  /// [id]: Nakit hesap ID'si
  /// [balance]: Yeni bakiye
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> updateBalance(String id, double balance) async {
    return await _repository.updateCashAccountBalance(id, balance);
  }

  /// Nakit hesap arşivler
  /// [id]: Nakit hesap ID'si
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> archive(String id) async {
    return await _repository.archiveCashAccount(id);
  }

  /// Nakit hesap aktifleştirir
  /// [id]: Nakit hesap ID'si
  /// Returns: Güncellenmiş nakit hesap
  Future<CashAccount> activate(String id) async {
    return await _repository.activateCashAccount(id);
  }
}
