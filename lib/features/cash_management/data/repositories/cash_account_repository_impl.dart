import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_account_repository.dart';
import 'package:tamgaci/features/cash_management/data/datasources/cash_account_firebase_datasource.dart';
import 'package:tamgaci/features/cash_management/data/models/cash_account_model.dart';

/// Cash Account repository implementasyonu
/// Firebase Firestore işlemleri için repository
class CashAccountRepositoryImpl implements CashAccountRepository {
  final CashAccountFirebaseDataSource _dataSource;

  CashAccountRepositoryImpl({
    required CashAccountFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<CashAccount>> getAllCashAccounts({
    int? limit,
    int? offset,
  }) async {
    final cashAccountModels = await _dataSource.getAllCashAccounts(
      limit: limit,
      offset: offset,
    );
    return cashAccountModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CashAccount?> getCashAccountById(String id) async {
    final cashAccountModel = await _dataSource.getCashAccountById(id);
    return cashAccountModel?.toEntity();
  }

  @override
  Future<List<CashAccount>> getCashAccountsByType(
    CashAccountType type, {
    int? limit,
    int? offset,
  }) async {
    final cashAccountModels = await _dataSource.getCashAccountsByType(
      type,
      limit: limit,
      offset: offset,
    );
    return cashAccountModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CashAccount>> getCashAccountsByStatus(
    CashAccountStatus status, {
    int? limit,
    int? offset,
  }) async {
    final cashAccountModels = await _dataSource.getCashAccountsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
    return cashAccountModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CashAccount?> getDefaultCashAccount() async {
    final cashAccountModel = await _dataSource.getDefaultCashAccount();
    return cashAccountModel?.toEntity();
  }

  @override
  Future<CashAccount> createCashAccount(CashAccount cashAccount) async {
    final cashAccountModel = CashAccountModel.fromEntity(cashAccount);
    final createdCashAccountModel =
        await _dataSource.createCashAccount(cashAccountModel);
    return createdCashAccountModel.toEntity();
  }

  @override
  Future<CashAccount> updateCashAccount(CashAccount cashAccount) async {
    final cashAccountModel = CashAccountModel.fromEntity(cashAccount);
    final updatedCashAccountModel =
        await _dataSource.updateCashAccount(cashAccountModel);
    return updatedCashAccountModel.toEntity();
  }

  @override
  Future<void> deleteCashAccount(String id) async {
    await _dataSource.deleteCashAccount(id);
  }

  @override
  Future<CashAccount> updateCashAccountStatus(
      String id, CashAccountStatus status) async {
    final cashAccount = await getCashAccountById(id);
    if (cashAccount == null) {
      throw Exception('Nakit hesap bulunamadı');
    }

    final updatedCashAccount = cashAccount.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    return await updateCashAccount(updatedCashAccount);
  }

  @override
  Future<CashAccount> updateCashAccountBalance(
      String id, double balance) async {
    final cashAccount = await getCashAccountById(id);
    if (cashAccount == null) {
      throw Exception('Nakit hesap bulunamadı');
    }

    final updatedCashAccount = cashAccount.copyWith(
      balance: balance,
      updatedAt: DateTime.now(),
    );

    return await updateCashAccount(updatedCashAccount);
  }

  @override
  Future<List<CashAccount>> searchCashAccounts(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final cashAccountModels = await _dataSource.searchCashAccounts(
      query,
      limit: limit,
      offset: offset,
    );
    return cashAccountModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getCashAccountsCount() async {
    return await _dataSource.getCashAccountsCount();
  }

  @override
  Future<int> getCashAccountsCountByType(CashAccountType type) async {
    final cashAccounts = await getCashAccountsByType(type);
    return cashAccounts.length;
  }

  @override
  Future<double> getTotalBalance({String? currency}) async {
    return await _dataSource.getTotalBalance(currency: currency);
  }

  @override
  Future<double> getTotalBalanceByType(CashAccountType type,
      {String? currency}) async {
    return await _dataSource.getTotalBalanceByType(type, currency: currency);
  }

  @override
  Future<Map<String, dynamic>> getCashAccountsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    final cashAccounts = await getAllCashAccounts();

    final report = <String, dynamic>{
      'totalBalance': 0.0,
      'totalCount': cashAccounts.length,
      'groupedData': <String, dynamic>{},
    };

    for (final cashAccount in cashAccounts) {
      report['totalBalance'] =
          (report['totalBalance'] as double) + cashAccount.balance;

      if (groupBy != null) {
        String key;
        switch (groupBy) {
          case 'type':
            key = cashAccount.type.name;
            break;
          case 'status':
            key = cashAccount.status.name;
            break;
          default:
            key = 'unknown';
        }

        if (!report['groupedData'].containsKey(key)) {
          report['groupedData'][key] = {
            'count': 0,
            'balance': 0.0,
          };
        }
        report['groupedData'][key]['count'] += 1;
        report['groupedData'][key]['balance'] += cashAccount.balance;
      }
    }

    return report;
  }

  @override
  Future<Map<String, dynamic>> getCashAccountsStatistics() async {
    return await _dataSource.getCashAccountsStatistics();
  }

  @override
  Future<String> generateCashAccountNumber(CashAccountType type) async {
    return await _dataSource.generateCashAccountNumber(type);
  }

  @override
  Future<CashAccount> duplicateCashAccount(String id) async {
    final originalCashAccount = await getCashAccountById(id);
    if (originalCashAccount == null) {
      throw Exception('Nakit hesap bulunamadı');
    }

    final newAccountNumber =
        await generateCashAccountNumber(originalCashAccount.type);

    final duplicatedCashAccount = originalCashAccount.copyWith(
      id: '', // Yeni ID oluşturulacak
      accountNumber: newAccountNumber,
      balance: 0.0, // Kopyalanan hesabın bakiyesi sıfırlanır
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createCashAccount(duplicatedCashAccount);
  }

  @override
  Future<CashAccount> archiveCashAccount(String id) async {
    return await updateCashAccountStatus(id, CashAccountStatus.inactive);
  }

  @override
  Future<CashAccount> activateCashAccount(String id) async {
    return await updateCashAccountStatus(id, CashAccountStatus.active);
  }

  @override
  Stream<List<CashAccount>> watchAllCashAccounts() {
    return _dataSource.watchAllCashAccounts().map((models) =>
        models.map((model) => model.toEntity()).toList());
  }
}
