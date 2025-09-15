import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';
import 'package:tamgaci/features/cash_management/domain/repositories/cash_transaction_repository.dart';
import 'package:tamgaci/features/cash_management/data/datasources/cash_transaction_firebase_datasource.dart';
import 'package:tamgaci/features/cash_management/data/models/cash_transaction_model.dart';

/// Cash Transaction repository implementasyonu
/// Firebase Firestore işlemleri için repository
class CashTransactionRepositoryImpl implements CashTransactionRepository {
  final CashTransactionFirebaseDataSource _dataSource;

  CashTransactionRepositoryImpl({
    required CashTransactionFirebaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<CashTransaction>> getAllCashTransactions({
    int? limit,
    int? offset,
  }) async {
    final cashTransactionModels = await _dataSource.getAllCashTransactions(
      limit: limit,
      offset: offset,
    );
    return cashTransactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CashTransaction?> getCashTransactionById(String id) async {
    final cashTransactionModel = await _dataSource.getCashTransactionById(id);
    return cashTransactionModel?.toEntity();
  }

  @override
  Future<CashTransaction?> getCashTransactionByNumber(
      String transactionNumber) async {
    final cashTransactionModel =
        await _dataSource.getCashTransactionByNumber(transactionNumber);
    return cashTransactionModel?.toEntity();
  }

  @override
  Future<List<CashTransaction>> getCashTransactionsByAccount(
    String accountId, {
    int? limit,
    int? offset,
  }) async {
    final cashTransactionModels =
        await _dataSource.getCashTransactionsByAccount(
      accountId,
      limit: limit,
      offset: offset,
    );
    return cashTransactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CashTransaction>> getCashTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    final cashTransactionModels =
        await _dataSource.getCashTransactionsByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
    return cashTransactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CashTransaction>> getCashTransactionsByType(
    CashTransactionType type, {
    int? limit,
    int? offset,
  }) async {
    final cashTransactionModels = await _dataSource.getCashTransactionsByType(
      type,
      limit: limit,
      offset: offset,
    );
    return cashTransactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CashTransaction>> getCashTransactionsByCategory(
    CashTransactionCategory category, {
    int? limit,
    int? offset,
  }) async {
    final cashTransactionModels =
        await _dataSource.getCashTransactionsByCategory(
      category,
      limit: limit,
      offset: offset,
    );
    return cashTransactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CashTransaction>> getCashTransactionsByStatus(
    CashTransactionStatus status, {
    int? limit,
    int? offset,
  }) async {
    final cashTransactionModels = await _dataSource.getCashTransactionsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
    return cashTransactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CashTransaction>> getOverdueCashTransactions({
    int? limit,
    int? offset,
  }) async {
    final cashTransactionModels = await _dataSource.getOverdueCashTransactions(
      limit: limit,
      offset: offset,
    );
    return cashTransactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CashTransaction> createCashTransaction(
      CashTransaction cashTransaction) async {
    final cashTransactionModel =
        CashTransactionModel.fromEntity(cashTransaction);
    final createdCashTransactionModel =
        await _dataSource.createCashTransaction(cashTransactionModel);
    return createdCashTransactionModel.toEntity();
  }

  @override
  Future<CashTransaction> updateCashTransaction(
      CashTransaction cashTransaction) async {
    final cashTransactionModel =
        CashTransactionModel.fromEntity(cashTransaction);
    final updatedCashTransactionModel =
        await _dataSource.updateCashTransaction(cashTransactionModel);
    return updatedCashTransactionModel.toEntity();
  }

  @override
  Future<void> deleteCashTransaction(String id) async {
    await _dataSource.deleteCashTransaction(id);
  }

  @override
  Future<CashTransaction> updateCashTransactionStatus(
      String id, CashTransactionStatus status) async {
    final cashTransaction = await getCashTransactionById(id);
    if (cashTransaction == null) {
      throw Exception('Nakit işlem bulunamadı');
    }

    final updatedCashTransaction = cashTransaction.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    return await updateCashTransaction(updatedCashTransaction);
  }

  @override
  Future<List<CashTransaction>> searchCashTransactions(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final cashTransactionModels = await _dataSource.searchCashTransactions(
      query,
      limit: limit,
      offset: offset,
    );
    return cashTransactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getCashTransactionsCount() async {
    return await _dataSource.getCashTransactionsCount();
  }

  @override
  Future<int> getCashTransactionsCountByAccount(String accountId) async {
    final cashTransactions = await getCashTransactionsByAccount(accountId);
    return cashTransactions.length;
  }

  @override
  Future<int> getCashTransactionsCountByDateRange(
      DateTime startDate, DateTime endDate) async {
    final cashTransactions =
        await getCashTransactionsByDateRange(startDate, endDate);
    return cashTransactions.length;
  }

  @override
  Future<double> getCashTransactionsTotal({
    DateTime? startDate,
    DateTime? endDate,
    CashTransactionType? type,
  }) async {
    return await _dataSource.getCashTransactionsTotal(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  @override
  Future<double> getCashTransactionsTotalByAccount(
    String accountId, {
    DateTime? startDate,
    DateTime? endDate,
    CashTransactionType? type,
  }) async {
    final cashTransactions = await getCashTransactionsByAccount(accountId);

    if (startDate != null && endDate != null) {
      final filteredTransactions = cashTransactions.where((transaction) {
        return transaction.transactionDate.isAfter(startDate) &&
            transaction.transactionDate.isBefore(endDate);
      }).toList();

      if (type != null) {
        final typeFilteredTransactions =
            filteredTransactions.where((transaction) {
          return transaction.type == type;
        }).toList();

        double total = 0.0;
        for (final transaction in typeFilteredTransactions) {
          total += transaction.amount;
        }
        return total;
      }

      double total = 0.0;
      for (final transaction in filteredTransactions) {
        total += transaction.amount;
      }
      return total;
    }

    if (type != null) {
      final typeFilteredTransactions = cashTransactions.where((transaction) {
        return transaction.type == type;
      }).toList();

      double total = 0.0;
      for (final transaction in typeFilteredTransactions) {
        total += transaction.amount;
      }
      return total;
    }

    double total = 0.0;
    for (final transaction in cashTransactions) {
      total += transaction.amount;
    }
    return total;
  }

  @override
  Future<Map<String, dynamic>> getCashTransactionsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    final cashTransactions =
        await getCashTransactionsByDateRange(startDate, endDate);

    final report = <String, dynamic>{
      'totalAmount': 0.0,
      'totalCount': cashTransactions.length,
      'groupedData': <String, dynamic>{},
    };

    for (final cashTransaction in cashTransactions) {
      report['totalAmount'] =
          (report['totalAmount'] as double) + cashTransaction.amount;

      if (groupBy != null) {
        String key;
        switch (groupBy) {
          case 'type':
            key = cashTransaction.type.name;
            break;
          case 'category':
            key = cashTransaction.category.name;
            break;
          case 'account':
            key = cashTransaction.fromAccountId;
            break;
          default:
            key = 'unknown';
        }

        if (!report['groupedData'].containsKey(key)) {
          report['groupedData'][key] = {
            'count': 0,
            'amount': 0.0,
          };
        }
        report['groupedData'][key]['count'] += 1;
        report['groupedData'][key]['amount'] += cashTransaction.amount;
      }
    }

    return report;
  }

  @override
  Future<List<Map<String, dynamic>>> getTopCategories({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getTopCategories(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAccounts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getTopAccounts(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Map<String, dynamic>> getCashTransactionsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dataSource.getCashTransactionsStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<String> generateCashTransactionNumber(CashTransactionType type) async {
    return await _dataSource.generateCashTransactionNumber(type);
  }

  @override
  Future<CashTransaction> duplicateCashTransaction(String id) async {
    final originalCashTransaction = await getCashTransactionById(id);
    if (originalCashTransaction == null) {
      throw Exception('Nakit işlem bulunamadı');
    }

    final newTransactionNumber =
        await generateCashTransactionNumber(originalCashTransaction.type);

    final duplicatedCashTransaction = originalCashTransaction.copyWith(
      id: '', // Yeni ID oluşturulacak
      transactionNumber: newTransactionNumber,
      status: CashTransactionStatus.pending,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createCashTransaction(duplicatedCashTransaction);
  }

  @override
  Future<CashTransaction> cancelCashTransaction(
      String id, String reason) async {
    final cashTransaction = await getCashTransactionById(id);
    if (cashTransaction == null) {
      throw Exception('Nakit işlem bulunamadı');
    }

    final cancelledCashTransaction = cashTransaction.copyWith(
      status: CashTransactionStatus.cancelled,
      notes: '${cashTransaction.notes ?? ''}\nİptal nedeni: $reason'.trim(),
      updatedAt: DateTime.now(),
    );

    return await updateCashTransaction(cancelledCashTransaction);
  }

  @override
  Future<CashTransaction> approveCashTransaction(String id) async {
    return await updateCashTransactionStatus(
        id, CashTransactionStatus.completed);
  }

  @override
  Future<CashTransaction> completeCashTransaction(String id) async {
    return await updateCashTransactionStatus(
        id, CashTransactionStatus.completed);
  }
}
