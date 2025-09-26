import 'package:equatable/equatable.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';

/// Cash Management state
class CashManagementState extends Equatable {
  final List<CashAccount> cashAccounts;
  final List<CashTransaction> cashTransactions;
  final CashAccount? selectedCashAccount;
  final CashTransaction? selectedCashTransaction;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? cashAccountsStatistics;
  final Map<String, dynamic>? cashTransactionsStatistics;
  final Map<String, dynamic>? cashAccountsReport;
  final Map<String, dynamic>? cashTransactionsReport;
  final List<Map<String, dynamic>> topCategories;
  final List<Map<String, dynamic>> topAccounts;
  final bool hasLoadedTransactions;

  const CashManagementState({
    this.cashAccounts = const [],
    this.cashTransactions = const [],
    this.selectedCashAccount,
    this.selectedCashTransaction,
    this.isLoading = false,
    this.error,
    this.cashAccountsStatistics,
    this.cashTransactionsStatistics,
    this.cashAccountsReport,
    this.cashTransactionsReport,
    this.topCategories = const [],
    this.topAccounts = const [],
    this.hasLoadedTransactions = false,
  });

  CashManagementState copyWith({
    List<CashAccount>? cashAccounts,
    List<CashTransaction>? cashTransactions,
    CashAccount? selectedCashAccount,
    CashTransaction? selectedCashTransaction,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? cashAccountsStatistics,
    Map<String, dynamic>? cashTransactionsStatistics,
    Map<String, dynamic>? cashAccountsReport,
    Map<String, dynamic>? cashTransactionsReport,
    List<Map<String, dynamic>>? topCategories,
    List<Map<String, dynamic>>? topAccounts,
    bool? hasLoadedTransactions,
  }) {
    return CashManagementState(
      cashAccounts: cashAccounts ?? this.cashAccounts,
      cashTransactions: cashTransactions ?? this.cashTransactions,
      selectedCashAccount: selectedCashAccount ?? this.selectedCashAccount,
      selectedCashTransaction:
          selectedCashTransaction ?? this.selectedCashTransaction,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      cashAccountsStatistics:
          cashAccountsStatistics ?? this.cashAccountsStatistics,
      cashTransactionsStatistics:
          cashTransactionsStatistics ?? this.cashTransactionsStatistics,
      cashAccountsReport: cashAccountsReport ?? this.cashAccountsReport,
      cashTransactionsReport:
          cashTransactionsReport ?? this.cashTransactionsReport,
      topCategories: topCategories ?? this.topCategories,
      topAccounts: topAccounts ?? this.topAccounts,
      hasLoadedTransactions:
          hasLoadedTransactions ?? this.hasLoadedTransactions,
    );
  }

  @override
  List<Object?> get props => [
        cashAccounts,
        cashTransactions,
        selectedCashAccount,
        selectedCashTransaction,
        isLoading,
        error,
        cashAccountsStatistics,
        cashTransactionsStatistics,
        cashAccountsReport,
        cashTransactionsReport,
        topCategories,
        topAccounts,
        hasLoadedTransactions,
      ];
}
