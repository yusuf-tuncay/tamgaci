import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/create_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_accounts_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/update_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/delete_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_accounts_statistics_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/duplicate_cash_account_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/create_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_transactions_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/update_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/delete_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/get_cash_transactions_statistics_usecase.dart';
import 'package:tamgaci/features/cash_management/domain/usecases/duplicate_cash_transaction_usecase.dart';
import 'package:tamgaci/features/cash_management/presentation/states/cash_management_state.dart';
import 'package:flutter/foundation.dart';

/// Cash Management state notifier
class CashManagementNotifier extends StateNotifier<CashManagementState> {
  // Cash Account Use Cases
  final CreateCashAccountUseCase _createCashAccountUseCase;
  final GetCashAccountsUseCase _getCashAccountsUseCase;
  final GetCashAccountUseCase _getCashAccountUseCase;
  final UpdateCashAccountUseCase _updateCashAccountUseCase;
  final DeleteCashAccountUseCase _deleteCashAccountUseCase;
  final GetCashAccountsStatisticsUseCase _getCashAccountsStatisticsUseCase;
  final DuplicateCashAccountUseCase _duplicateCashAccountUseCase;

  // Cash Transaction Use Cases
  final CreateCashTransactionUseCase _createCashTransactionUseCase;
  final GetCashTransactionsUseCase _getCashTransactionsUseCase;
  final GetCashTransactionUseCase _getCashTransactionUseCase;
  final UpdateCashTransactionUseCase _updateCashTransactionUseCase;
  final DeleteCashTransactionUseCase _deleteCashTransactionUseCase;
  final GetCashTransactionsStatisticsUseCase
      _getCashTransactionsStatisticsUseCase;
  final DuplicateCashTransactionUseCase _duplicateCashTransactionUseCase;

  CashManagementNotifier({
    required CreateCashAccountUseCase createCashAccountUseCase,
    required GetCashAccountsUseCase getCashAccountsUseCase,
    required GetCashAccountUseCase getCashAccountUseCase,
    required UpdateCashAccountUseCase updateCashAccountUseCase,
    required DeleteCashAccountUseCase deleteCashAccountUseCase,
    required GetCashAccountsStatisticsUseCase getCashAccountsStatisticsUseCase,
    required DuplicateCashAccountUseCase duplicateCashAccountUseCase,
    required CreateCashTransactionUseCase createCashTransactionUseCase,
    required GetCashTransactionsUseCase getCashTransactionsUseCase,
    required GetCashTransactionUseCase getCashTransactionUseCase,
    required UpdateCashTransactionUseCase updateCashTransactionUseCase,
    required DeleteCashTransactionUseCase deleteCashTransactionUseCase,
    required GetCashTransactionsStatisticsUseCase
        getCashTransactionsStatisticsUseCase,
    required DuplicateCashTransactionUseCase duplicateCashTransactionUseCase,
  })  : _createCashAccountUseCase = createCashAccountUseCase,
        _getCashAccountsUseCase = getCashAccountsUseCase,
        _getCashAccountUseCase = getCashAccountUseCase,
        _updateCashAccountUseCase = updateCashAccountUseCase,
        _deleteCashAccountUseCase = deleteCashAccountUseCase,
        _getCashAccountsStatisticsUseCase = getCashAccountsStatisticsUseCase,
        _duplicateCashAccountUseCase = duplicateCashAccountUseCase,
        _createCashTransactionUseCase = createCashTransactionUseCase,
        _getCashTransactionsUseCase = getCashTransactionsUseCase,
        _getCashTransactionUseCase = getCashTransactionUseCase,
        _updateCashTransactionUseCase = updateCashTransactionUseCase,
        _deleteCashTransactionUseCase = deleteCashTransactionUseCase,
        _getCashTransactionsStatisticsUseCase =
            getCashTransactionsStatisticsUseCase,
        _duplicateCashTransactionUseCase = duplicateCashTransactionUseCase,
        super(const CashManagementState());

  // Cash Account Methods

  /// Tüm nakit hesapları getirir
  Future<void> getCashAccounts({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashAccounts = await _getCashAccountsUseCase.call(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashAccounts: cashAccounts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Türüne göre nakit hesapları getirir
  Future<void> getCashAccountsByType(
    CashAccountType type, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashAccounts = await _getCashAccountsUseCase.getByType(
        type,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashAccounts: cashAccounts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Duruma göre nakit hesapları getirir
  Future<void> getCashAccountsByStatus(
    CashAccountStatus status, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashAccounts = await _getCashAccountsUseCase.getByStatus(
        status,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashAccounts: cashAccounts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Varsayılan nakit hesabı getirir
  Future<void> getDefaultCashAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashAccount = await _getCashAccountsUseCase.getDefault();

      state = state.copyWith(
        isLoading: false,
        selectedCashAccount: cashAccount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesap arama
  Future<void> searchCashAccounts(
    String query, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashAccounts = await _getCashAccountsUseCase.search(
        query,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashAccounts: cashAccounts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tek nakit hesap getirir
  Future<void> getCashAccount(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashAccount = await _getCashAccountUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        selectedCashAccount: cashAccount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeni nakit hesap oluşturur
  Future<void> createCashAccount(CashAccount cashAccount) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdCashAccount =
          await _createCashAccountUseCase.call(cashAccount);

      state = state.copyWith(
        isLoading: false,
        cashAccounts: [...state.cashAccounts, createdCashAccount],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesap günceller
  Future<void> updateCashAccount(CashAccount cashAccount) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashAccount =
          await _updateCashAccountUseCase.call(cashAccount);

      final updatedCashAccounts = state.cashAccounts.map((ca) {
        return ca.id == updatedCashAccount.id ? updatedCashAccount : ca;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashAccounts: updatedCashAccounts,
        selectedCashAccount:
            state.selectedCashAccount?.id == updatedCashAccount.id
                ? updatedCashAccount
                : state.selectedCashAccount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesap durumunu günceller
  Future<void> updateCashAccountStatus(
      String id, CashAccountStatus status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashAccount =
          await _updateCashAccountUseCase.updateStatus(id, status);

      final updatedCashAccounts = state.cashAccounts.map((ca) {
        return ca.id == updatedCashAccount.id ? updatedCashAccount : ca;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashAccounts: updatedCashAccounts,
        selectedCashAccount:
            state.selectedCashAccount?.id == updatedCashAccount.id
                ? updatedCashAccount
                : state.selectedCashAccount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesap bakiyesini günceller
  Future<void> updateCashAccountBalance(String id, double balance) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashAccount =
          await _updateCashAccountUseCase.updateBalance(id, balance);

      final updatedCashAccounts = state.cashAccounts.map((ca) {
        return ca.id == updatedCashAccount.id ? updatedCashAccount : ca;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashAccounts: updatedCashAccounts,
        selectedCashAccount:
            state.selectedCashAccount?.id == updatedCashAccount.id
                ? updatedCashAccount
                : state.selectedCashAccount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesap siler
  Future<void> deleteCashAccount(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteCashAccountUseCase.call(id);

      final updatedCashAccounts =
          state.cashAccounts.where((ca) => ca.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        cashAccounts: updatedCashAccounts,
        selectedCashAccount: state.selectedCashAccount?.id == id
            ? null
            : state.selectedCashAccount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesap kopyalar
  Future<void> duplicateCashAccount(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final duplicatedCashAccount = await _duplicateCashAccountUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        cashAccounts: [...state.cashAccounts, duplicatedCashAccount],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesap arşivler
  Future<void> archiveCashAccount(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashAccount = await _updateCashAccountUseCase.archive(id);

      final updatedCashAccounts = state.cashAccounts.map((ca) {
        return ca.id == updatedCashAccount.id ? updatedCashAccount : ca;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashAccounts: updatedCashAccounts,
        selectedCashAccount:
            state.selectedCashAccount?.id == updatedCashAccount.id
                ? updatedCashAccount
                : state.selectedCashAccount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesap aktifleştirir
  Future<void> activateCashAccount(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashAccount = await _updateCashAccountUseCase.activate(id);

      final updatedCashAccounts = state.cashAccounts.map((ca) {
        return ca.id == updatedCashAccount.id ? updatedCashAccount : ca;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashAccounts: updatedCashAccounts,
        selectedCashAccount:
            state.selectedCashAccount?.id == updatedCashAccount.id
                ? updatedCashAccount
                : state.selectedCashAccount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesaplar istatistiklerini getirir
  Future<void> getCashAccountsStatistics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _getCashAccountsStatisticsUseCase.call();

      state = state.copyWith(
        isLoading: false,
        cashAccountsStatistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit hesaplar raporu oluşturur
  Future<void> getCashAccountsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _getCashAccountsStatisticsUseCase.getReport(
        startDate,
        endDate,
        groupBy: groupBy,
      );

      state = state.copyWith(
        isLoading: false,
        cashAccountsReport: report,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cash Transaction Methods

  /// Tüm nakit işlemleri getirir
  Future<void> getCashTransactions({
    int? limit,
    int? offset,
  }) async {
    if (!mounted) return;
    if (kDebugMode) {
      print('🔄 Starting to load cash transactions...');
    }
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (kDebugMode) {
        print('📞 Calling getCashTransactionsUseCase...');
      }
      final cashTransactions = await _getCashTransactionsUseCase.call(
        limit: limit,
        offset: offset,
      );

      if (!mounted) return;

      if (kDebugMode) {
        print(
          '✅ Successfully loaded ${cashTransactions.length} cash transactions');
      }
      state = state.copyWith(
        isLoading: false,
        cashTransactions: cashTransactions,
        hasLoadedTransactions: true,
      );
      debugPrint('🐛 hasLoadedTransactions set to: ${state.hasLoadedTransactions}');
    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) {
        print('❌ Error loading cash transactions: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Hesaba göre nakit işlemleri getirir
  Future<void> getCashTransactionsByAccount(
    String accountId, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransactions = await _getCashTransactionsUseCase.getByAccount(
        accountId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactions: cashTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tarih aralığına göre nakit işlemleri getirir
  Future<void> getCashTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransactions = await _getCashTransactionsUseCase.getByDateRange(
        startDate,
        endDate,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactions: cashTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Türüne göre nakit işlemleri getirir
  Future<void> getCashTransactionsByType(
    CashTransactionType type, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransactions = await _getCashTransactionsUseCase.getByType(
        type,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactions: cashTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Kategorisine göre nakit işlemleri getirir
  Future<void> getCashTransactionsByCategory(
    CashTransactionCategory category, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransactions = await _getCashTransactionsUseCase.getByCategory(
        category,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactions: cashTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Duruma göre nakit işlemleri getirir
  Future<void> getCashTransactionsByStatus(
    CashTransactionStatus status, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransactions = await _getCashTransactionsUseCase.getByStatus(
        status,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactions: cashTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Vadesi geçmiş nakit işlemleri getirir
  Future<void> getOverdueCashTransactions({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransactions = await _getCashTransactionsUseCase.getOverdue(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactions: cashTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlem arama
  Future<void> searchCashTransactions(
    String query, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransactions = await _getCashTransactionsUseCase.search(
        query,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactions: cashTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tek nakit işlem getirir
  Future<void> getCashTransaction(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransaction = await _getCashTransactionUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        selectedCashTransaction: cashTransaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// İşlem numarasına göre nakit işlem getirir
  Future<void> getCashTransactionByNumber(String transactionNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashTransaction =
          await _getCashTransactionUseCase.getByNumber(transactionNumber);

      state = state.copyWith(
        isLoading: false,
        selectedCashTransaction: cashTransaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeni nakit işlem oluşturur
  Future<void> createCashTransaction(CashTransaction cashTransaction) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdCashTransaction =
          await _createCashTransactionUseCase.call(cashTransaction);

      state = state.copyWith(
        isLoading: false,
        cashTransactions: [...state.cashTransactions, createdCashTransaction],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlem günceller
  Future<void> updateCashTransaction(CashTransaction cashTransaction) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashTransaction =
          await _updateCashTransactionUseCase.call(cashTransaction);

      final updatedCashTransactions = state.cashTransactions.map((ct) {
        return ct.id == updatedCashTransaction.id ? updatedCashTransaction : ct;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashTransactions: updatedCashTransactions,
        selectedCashTransaction:
            state.selectedCashTransaction?.id == updatedCashTransaction.id
                ? updatedCashTransaction
                : state.selectedCashTransaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlem durumunu günceller
  Future<void> updateCashTransactionStatus(
      String id, CashTransactionStatus status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashTransaction =
          await _updateCashTransactionUseCase.updateStatus(id, status);

      final updatedCashTransactions = state.cashTransactions.map((ct) {
        return ct.id == updatedCashTransaction.id ? updatedCashTransaction : ct;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashTransactions: updatedCashTransactions,
        selectedCashTransaction:
            state.selectedCashTransaction?.id == updatedCashTransaction.id
                ? updatedCashTransaction
                : state.selectedCashTransaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlem onaylar
  Future<void> approveCashTransaction(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashTransaction =
          await _updateCashTransactionUseCase.approve(id);

      final updatedCashTransactions = state.cashTransactions.map((ct) {
        return ct.id == updatedCashTransaction.id ? updatedCashTransaction : ct;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashTransactions: updatedCashTransactions,
        selectedCashTransaction:
            state.selectedCashTransaction?.id == updatedCashTransaction.id
                ? updatedCashTransaction
                : state.selectedCashTransaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlem tamamlar
  Future<void> completeCashTransaction(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashTransaction =
          await _updateCashTransactionUseCase.complete(id);

      final updatedCashTransactions = state.cashTransactions.map((ct) {
        return ct.id == updatedCashTransaction.id ? updatedCashTransaction : ct;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashTransactions: updatedCashTransactions,
        selectedCashTransaction:
            state.selectedCashTransaction?.id == updatedCashTransaction.id
                ? updatedCashTransaction
                : state.selectedCashTransaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlem iptal eder
  Future<void> cancelCashTransaction(String id, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedCashTransaction =
          await _updateCashTransactionUseCase.cancel(id, reason);

      final updatedCashTransactions = state.cashTransactions.map((ct) {
        return ct.id == updatedCashTransaction.id ? updatedCashTransaction : ct;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cashTransactions: updatedCashTransactions,
        selectedCashTransaction:
            state.selectedCashTransaction?.id == updatedCashTransaction.id
                ? updatedCashTransaction
                : state.selectedCashTransaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlem siler
  Future<void> deleteCashTransaction(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteCashTransactionUseCase.call(id);

      final updatedCashTransactions =
          state.cashTransactions.where((ct) => ct.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        cashTransactions: updatedCashTransactions,
        selectedCashTransaction: state.selectedCashTransaction?.id == id
            ? null
            : state.selectedCashTransaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlem kopyalar
  Future<void> duplicateCashTransaction(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final duplicatedCashTransaction =
          await _duplicateCashTransactionUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        cashTransactions: [
          ...state.cashTransactions,
          duplicatedCashTransaction
        ],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlemler istatistiklerini getirir
  Future<void> getCashTransactionsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _getCashTransactionsStatisticsUseCase.call(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactionsStatistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Nakit işlemler raporu oluşturur
  Future<void> getCashTransactionsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _getCashTransactionsStatisticsUseCase.getReport(
        startDate,
        endDate,
        groupBy: groupBy,
      );

      state = state.copyWith(
        isLoading: false,
        cashTransactionsReport: report,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// En çok kullanılan kategorileri getirir
  Future<void> getTopCategories({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topCategories =
          await _getCashTransactionsStatisticsUseCase.getTopCategories(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        topCategories: topCategories,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// En çok işlem yapılan hesapları getirir
  Future<void> getTopAccounts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topAccounts =
          await _getCashTransactionsStatisticsUseCase.getTopAccounts(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        topAccounts: topAccounts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Seçili nakit hesap temizler
  void clearSelectedCashAccount() {
    state = state.copyWith(selectedCashAccount: null);
  }

  /// Seçili nakit işlem temizler
  void clearSelectedCashTransaction() {
    state = state.copyWith(selectedCashTransaction: null);
  }

  /// Hata mesajını temizler
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Cash accounts stream'i döndürür
  Stream<List<CashAccount>> watchCashAccounts() {
    return _getCashAccountsUseCase.watchAll();
  }
}
