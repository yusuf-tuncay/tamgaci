// ========== CASH PROVIDERS ==========
// lib/features/cash/presentation/providers/cash_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/entities/cash_transaction.dart';
import '../../domain/repositories/cash_repository.dart';
import '../../data/repositories/firebase_cash_repository.dart';

// ========== BASE PROVIDERS ==========

/// Cash repository provider
final cashRepositoryProvider = Provider<CashRepository>((ref) {
  // Web platformunda Firebase kullan
  if (kIsWeb) {
    return FirebaseCashRepository();
  }

  // TODO: Gerçek repository implementasyonu eklenecek
  return _EmptyCashRepository();
});

// ========== DATA PROVIDERS ==========

/// Tüm nakit işlemler provider'ı
final cashTransactionsProvider = FutureProvider<List<CashTransaction>>((ref) async {
  final repository = ref.watch(cashRepositoryProvider);
  return await repository.getAllCashTransactions();
});

/// Nakit işlemler stream provider'ı (reactive)
final cashTransactionsStreamProvider = StreamProvider<List<CashTransaction>>((ref) {
  final repository = ref.watch(cashRepositoryProvider);
  return repository.watchAllCashTransactions();
});

/// Belirli nakit işlem provider'ı
final cashTransactionProvider = FutureProvider.family<CashTransaction?, String>((ref, id) async {
  final repository = ref.watch(cashRepositoryProvider);
  return await repository.getCashTransactionById(id);
});

/// Nakit işlem stream provider'ı (tek işlem)
final cashTransactionStreamProvider = StreamProvider.family<CashTransaction?, String>((ref, id) {
  final repository = ref.watch(cashRepositoryProvider);
  return repository.watchCashTransactionById(id);
});

/// Son nakit işlemler provider'ı
final recentCashTransactionsProvider = FutureProvider<List<CashTransaction>>((ref) async {
  final repository = ref.watch(cashRepositoryProvider);
  return await repository.getRecentCashTransactions(10);
});

/// Toplam nakit bakiyesi provider'ı
final totalCashBalanceProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(cashRepositoryProvider);
  return await repository.getTotalCashBalance();
});

/// Nakit istatistikleri provider'ı
final cashStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(cashRepositoryProvider);
  return await repository.getCashStatistics();
});

// ========== FILTER PROVIDERS ==========

/// Nakit işlem arama sorgusu provider'ı
final cashSearchQueryProvider = StateProvider<String>((ref) => '');

/// Seçili nakit işlem tipi provider'ı
final selectedCashTransactionTypeProvider = StateProvider<CashTransactionType?>((ref) => null);

/// Nakit işlem tarih aralığı provider'ı
final cashDateRangeProvider = StateProvider<Map<String, DateTime>?>((ref) => null);

// ========== SEARCH & FILTER PROVIDERS ==========

/// Nakit işlem arama provider'ı
final cashSearchProvider = FutureProvider.family<List<CashTransaction>, String>((ref, query) async {
  if (query.isEmpty) {
    return <CashTransaction>[];
  }

  final repository = ref.watch(cashRepositoryProvider);
  return await repository.searchCashTransactions(query);
});

/// Filtrelenmiş nakit işlemler provider'ı
final filteredCashTransactionsProvider = FutureProvider<List<CashTransaction>>((ref) async {
  final repository = ref.watch(cashRepositoryProvider);
  final selectedType = ref.watch(selectedCashTransactionTypeProvider);
  final dateRange = ref.watch(cashDateRangeProvider);

  List<CashTransaction> transactions = await repository.getAllCashTransactions();

  // Tip filtresi
  if (selectedType != null) {
    transactions = transactions
        .where((transaction) => transaction.type == selectedType)
        .toList();
  }

  // Tarih aralığı filtresi
  if (dateRange != null) {
    final startDate = dateRange['start'];
    final endDate = dateRange['end'];
    if (startDate != null && endDate != null) {
      transactions = transactions.where((transaction) {
        return transaction.transactionDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            transaction.transactionDate.isBefore(
              endDate.add(const Duration(days: 1)),
            );
      }).toList();
    }
  }

  return transactions;
});

// ========== FORM STATE MANAGEMENT ==========

/// Nakit işlem formu state provider'ı
final cashTransactionFormProvider =
    StateNotifierProvider<CashTransactionFormNotifier, CashTransactionFormState>((ref) {
      final repository = ref.watch(cashRepositoryProvider);
      return CashTransactionFormNotifier(repository);
    });

/// Nakit işlem operasyonları provider'ı
final cashTransactionOperationsProvider =
    StateNotifierProvider<CashTransactionOperations, CashTransactionOperationsState>((ref) {
      final repository = ref.watch(cashRepositoryProvider);
      return CashTransactionOperations(repository);
    });

// ========== STATE CLASSES ==========

/// Nakit işlem operasyonları state sınıfı
class CashTransactionOperationsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<CashTransaction> transactions;

  const CashTransactionOperationsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.transactions = const [],
  });

  CashTransactionOperationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<CashTransaction>? transactions,
  }) {
    return CashTransactionOperationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      transactions: transactions ?? this.transactions,
    );
  }
}

/// Nakit işlem form state sınıfı
class CashTransactionFormState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final CashTransaction? transaction;

  const CashTransactionFormState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.transaction,
  });

  CashTransactionFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    CashTransaction? transaction,
  }) {
    return CashTransactionFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      transaction: transaction ?? this.transaction,
    );
  }
}

// ========== STATE NOTIFIERS ==========

/// Nakit işlem form notifier'ı
class CashTransactionFormNotifier extends StateNotifier<CashTransactionFormState> {
  final CashRepository _repository;

  CashTransactionFormNotifier(this._repository) : super(const CashTransactionFormState());

  /// Yeni nakit işlem oluştur
  Future<void> createCashTransaction(CashTransaction transaction) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.createCashTransaction(transaction);
      state = state.copyWith(isLoading: false, successMessage: 'Nakit işlem başarıyla oluşturuldu');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Nakit işlem güncelle
  Future<void> updateCashTransaction(CashTransaction transaction) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.updateCashTransaction(transaction);
      state = state.copyWith(isLoading: false, successMessage: 'Nakit işlem başarıyla güncellendi');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Nakit işlem sil
  Future<void> deleteCashTransaction(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteCashTransaction(id);
      state = state.copyWith(isLoading: false, successMessage: 'Nakit işlem başarıyla silindi');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// State'i sıfırla
  void reset() {
    state = const CashTransactionFormState();
  }
}

/// Nakit işlem operasyonları notifier'ı
class CashTransactionOperations extends StateNotifier<CashTransactionOperationsState> {
  final CashRepository _repository;

  CashTransactionOperations(this._repository) : super(const CashTransactionOperationsState());

  /// Nakit işlemleri yükle
  Future<void> loadCashTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final transactions = await _repository.getAllCashTransactions();
      state = state.copyWith(isLoading: false, transactions: transactions);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// State'i sıfırla
  void reset() {
    state = const CashTransactionOperationsState();
  }
}

// ========== EMPTY REPOSITORY ==========

/// Boş nakit repository'si (Native platformu için)
class _EmptyCashRepository implements CashRepository {
  @override
  Future<List<CashTransaction>> getAllCashTransactions() async => [];

  @override
  Future<CashTransaction?> getCashTransactionById(String id) async => null;

  @override
  Future<String> createCashTransaction(CashTransaction transaction) async => '';

  @override
  Future<void> updateCashTransaction(CashTransaction transaction) async {}

  @override
  Future<void> deleteCashTransaction(String id) async {}

  @override
  Future<List<CashTransaction>> getCashTransactionsByDateRange(DateTime startDate, DateTime endDate) async => [];

  @override
  Future<List<CashTransaction>> getCashTransactionsByType(CashTransactionType type) async => [];

  @override
  Future<List<CashTransaction>> getCashTransactionsByCategory(String category) async => [];

  @override
  Future<List<CashTransaction>> getRecentCashTransactions(int limit) async => [];

  @override
  Future<List<CashTransaction>> searchCashTransactions(String query) async => [];

  @override
  Future<double> getTotalCashBalance() async => 0.0;

  @override
  Future<double> getTotalIncomeByDateRange(DateTime startDate, DateTime endDate) async => 0.0;

  @override
  Future<double> getTotalExpenseByDateRange(DateTime startDate, DateTime endDate) async => 0.0;

  @override
  Future<Map<String, dynamic>> getCashStatistics() async => {};

  @override
  Stream<CashTransaction?> watchCashTransactionById(String id) => Stream.value(null);

  @override
  Stream<List<CashTransaction>> watchAllCashTransactions() => Stream.value([]);

  @override
  Stream<List<CashTransaction>> watchCashTransactionsByDateRange(DateTime startDate, DateTime endDate) => Stream.value([]);

  @override
  Stream<List<CashTransaction>> watchCashTransactionsByType(CashTransactionType type) => Stream.value([]);
}
