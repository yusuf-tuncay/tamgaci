import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/accounts/domain/entities/account_transaction.dart';
import 'package:tamgaci/features/accounts/presentation/providers/account_transaction_providers.dart';

// Tüm masrafları getiren provider
final allExpensesProvider = Provider<List<AccountTransaction>>((ref) {
  final allTransactions = ref.watch(allAccountTransactionsProvider);

  return allTransactions.when(
    data: (transactions) => transactions
        .where((transaction) =>
            transaction.category == TransactionCategory.expense)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Masraf istatistikleri provider'ı
final expensesStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final expenses = ref.watch(allExpensesProvider);

  if (expenses.isEmpty) {
    return {
      'totalAmount': 0.0,
      'totalCount': 0,
      'thisMonthAmount': 0.0,
      'thisMonthCount': 0,
    };
  }

  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month);

  final totalAmount =
      expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount.abs());
  final totalCount = expenses.length;

  final thisMonthExpenses = expenses.where((expense) {
    final expenseDate = DateTime.fromMillisecondsSinceEpoch(
        expense.createdAt.millisecondsSinceEpoch);
    return expenseDate.isAfter(thisMonth.subtract(const Duration(days: 1)));
  }).toList();

  final thisMonthAmount = thisMonthExpenses.fold<double>(
      0.0, (sum, expense) => sum + expense.amount.abs());
  final thisMonthCount = thisMonthExpenses.length;

  return {
    'totalAmount': totalAmount,
    'totalCount': totalCount,
    'thisMonthAmount': thisMonthAmount,
    'thisMonthCount': thisMonthCount,
  };
});
