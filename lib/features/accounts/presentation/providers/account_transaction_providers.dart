import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_account_transaction_repository.dart';
import '../../domain/entities/account_transaction.dart';
import '../../domain/repositories/account_transaction_repository.dart';

/// Account Transaction Repository Provider
final accountTransactionRepositoryProvider =
    Provider<AccountTransactionRepository>((ref) {
  return FirebaseAccountTransactionRepository();
});

/// Transactions List Provider
final transactionsProvider =
    FutureProvider<List<AccountTransaction>>((ref) async {
  final repository = ref.read(accountTransactionRepositoryProvider);
  return await repository.getTransactions();
});

/// Transaction by ID Provider
final transactionByIdProvider =
    FutureProvider.family<AccountTransaction?, String>((ref, id) async {
  final repository = ref.read(accountTransactionRepositoryProvider);
  return await repository.getTransactionById(id);
});

/// Transactions by Account ID Provider
final transactionsByAccountIdProvider =
    FutureProvider.family<List<AccountTransaction>, String>(
        (ref, accountId) async {
  final repository = ref.read(accountTransactionRepositoryProvider);
  return await repository.getTransactionsByAccountId(accountId);
});

/// Transactions by Type Provider
final transactionsByTypeProvider =
    FutureProvider.family<List<AccountTransaction>, TransactionType>(
        (ref, type) async {
  final repository = ref.read(accountTransactionRepositoryProvider);
  return await repository.getTransactionsByType(type);
});

/// Transactions by Category Provider
final transactionsByCategoryProvider =
    FutureProvider.family<List<AccountTransaction>, TransactionCategory>(
        (ref, category) async {
  final repository = ref.read(accountTransactionRepositoryProvider);
  return await repository.getTransactionsByCategory(category);
});

/// Unreconciled Transactions Provider
final unreconciledTransactionsProvider =
    FutureProvider<List<AccountTransaction>>((ref) async {
  final repository = ref.read(accountTransactionRepositoryProvider);
  return await repository.getUnreconciledTransactions();
});

/// Transaction Statistics Provider
final transactionStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final transactions = await ref.watch(transactionsProvider.future);

  double totalCredit = 0;
  double totalDebit = 0;
  int totalTransactions = transactions.length;

  Map<TransactionType, int> transactionsByType = {};
  Map<TransactionCategory, int> transactionsByCategory = {};

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.deposit) {
      totalCredit += transaction.amount;
    } else if (transaction.type == TransactionType.withdrawal) {
      totalDebit += transaction.amount;
    }

    // İşlem türüne göre sayım
    transactionsByType[transaction.type] =
        (transactionsByType[transaction.type] ?? 0) + 1;

    // Kategoriye göre sayım
    transactionsByCategory[transaction.category] =
        (transactionsByCategory[transaction.category] ?? 0) + 1;
  }

  return {
    'totalTransactions': totalTransactions,
    'totalCredit': totalCredit,
    'totalDebit': totalDebit,
    'netAmount': totalCredit - totalDebit,
    'transactionsByType': transactionsByType,
    'transactionsByCategory': transactionsByCategory,
  };
});

/// Account Transaction Notifier Provider
final accountTransactionNotifierProvider = StateNotifierProvider<
    AccountTransactionNotifier, AsyncValue<List<AccountTransaction>>>((ref) {
  return AccountTransactionNotifier(
      ref.read(accountTransactionRepositoryProvider));
});

/// Account Transaction Notifier
class AccountTransactionNotifier
    extends StateNotifier<AsyncValue<List<AccountTransaction>>> {
  final AccountTransactionRepository _repository;

  AccountTransactionNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _repository.getTransactions();
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createTransaction(AccountTransaction transaction) async {
    try {
      await _repository.createTransaction(transaction);
      _loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTransaction(AccountTransaction transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      _loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      _loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    _loadTransactions();
  }
}
