// ========== EXPENSE PROVIDERS ==========
// lib/features/expenses/presentation/providers/expense_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../../../core/database/tamgaci_database.dart';

// ========== BASE PROVIDERS ==========

/// Expense repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  // Web platformunda boş repository döndür
  if (kIsWeb) {
    return _EmptyExpenseRepository();
  }

  try {
    final databaseAsync = ref.watch(databaseProvider);
    return databaseAsync.when(
      data: (database) => ExpenseRepositoryImpl(database),
      loading: () => _EmptyExpenseRepository(),
      error: (error, stack) => _EmptyExpenseRepository(),
    );
  } catch (e) {
    return _EmptyExpenseRepository();
  }
});

// ========== DATA PROVIDERS ==========

/// Tüm giderler provider'ı
final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getAllExpenses();
});

/// Giderler stream provider'ı (reactive)
final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchAllExpenses();
});

/// Belirli gider provider'ı
final expenseProvider = FutureProvider.family<Expense?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpenseById(id);
});

/// Gider stream provider'ı (tek gider)
final expenseStreamProvider = StreamProvider.family<Expense?, String>((
  ref,
  id,
) {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpenseById(id);
});

/// Tarih aralığına göre giderler provider'ı
final expensesByDateRangeProvider =
    FutureProvider.family<List<Expense>, DateTimeRange>((ref, dateRange) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpensesByDateRange(
    dateRange.start,
    dateRange.end,
  );
});

/// Son giderler provider'ı
final recentExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getRecentExpenses(limit: 10);
});

/// Toplam gider sayısı provider'ı
final expenseCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getTotalExpenseCount();
});

/// Toplam gider tutarı provider'ı
final totalExpenseAmountProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getTotalExpenseAmount();
});

/// Bu ay gider tutarı provider'ı
final currentMonthExpenseAmountProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getCurrentMonthExpenseAmount();
});

// ========== CATEGORY PROVIDERS ==========

/// Gider kategorileri provider'ı
final expenseCategoriesProvider = FutureProvider<List<ExpenseCategory>>((
  ref,
) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpenseCategories();
});

/// Gider kategorileri stream provider'ı
final expenseCategoriesStreamProvider = StreamProvider<List<ExpenseCategory>>((
  ref,
) {
  try {
    final repository = ref.watch(expenseRepositoryProvider);
    return repository.watchExpenseCategories();
  } catch (e) {
    // Hata durumunda varsayılan kategorileri döndür
    return Stream.value(DefaultExpenseCategories.categories);
  }
});

/// Belirli kategori provider'ı
final expenseCategoryProvider = FutureProvider.family<ExpenseCategory?, String>(
  (ref, id) async {
    final repository = ref.watch(expenseRepositoryProvider);
    return await repository.getExpenseCategoryById(id);
  },
);

// ========== SEARCH & FILTER PROVIDERS ==========

/// Gider arama provider'ı
final expenseSearchProvider =
    FutureProvider.family<List<Expense>, String>((ref, query) async {
  if (query.isEmpty) {
    return <Expense>[];
  }

  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.searchExpenses(query);
});

/// Kategoriye göre giderler provider'ı
final expensesByCategoryProvider =
    FutureProvider.family<List<Expense>, String>((ref, categoryId) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpensesByCategory(categoryId);
});

/// Duruma göre giderler provider'ı
final expensesByStatusProvider =
    FutureProvider.family<List<Expense>, ExpenseStatus>((ref, status) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpensesByStatus(status);
});

// ========== STATE PROVIDERS ==========

/// Gider arama sorgusu provider'ı
final expenseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Seçili gider kategorisi provider'ı
final selectedExpenseCategoryProvider =
    StateProvider<ExpenseCategory?>((ref) => null);

/// Seçili gider durumu provider'ı
final selectedExpenseStatusProvider =
    StateProvider<ExpenseStatus?>((ref) => null);

/// Gider tarih aralığı provider'ı
final expenseDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Arama sonuçları provider'ı
final expenseSearchResultsProvider = FutureProvider<List<Expense>>((ref) async {
  final query = ref.watch(expenseSearchQueryProvider);
  if (query.isEmpty) {
    return <Expense>[];
  }

  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.searchExpenses(query);
});

/// Filtrelenmiş giderler provider'ı
final filteredExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final selectedCategory = ref.watch(selectedExpenseCategoryProvider);
  final selectedStatus = ref.watch(selectedExpenseStatusProvider);
  final dateRange = ref.watch(expenseDateRangeProvider);

  List<Expense> expenses = await repository.getAllExpenses();

  // Kategori filtresi
  if (selectedCategory != null) {
    expenses = expenses
        .where((expense) => expense.categoryId == selectedCategory)
        .toList();
  }

  // Durum filtresi
  if (selectedStatus != null) {
    expenses =
        expenses.where((expense) => expense.status == selectedStatus).toList();
  }

  // Tarih aralığı filtresi
  if (dateRange != null) {
    expenses = expenses.where((expense) {
      return expense.expenseDate.isAfter(
            dateRange.start.subtract(const Duration(days: 1)),
          ) &&
          expense.expenseDate.isBefore(
            dateRange.end.add(const Duration(days: 1)),
          );
    }).toList();
  }

  return expenses;
});

// ========== FORM STATE MANAGEMENT ==========

/// Gider formu state provider'ı
final expenseFormProvider =
    StateNotifierProvider<ExpenseFormNotifier, ExpenseFormState>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpenseFormNotifier(repository);
});

/// Gider operasyonları provider'ı
final expenseOperationsProvider =
    StateNotifierProvider<ExpenseOperations, ExpenseOperationsState>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpenseOperations(repository);
});

/// Gider operasyonları state sınıfı
class ExpenseOperationsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<Expense> expenses;

  const ExpenseOperationsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.expenses = const [],
  });

  ExpenseOperationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<Expense>? expenses,
  }) {
    return ExpenseOperationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      expenses: expenses ?? this.expenses,
    );
  }
}

/// Gider operasyonları sınıfı
class ExpenseOperations extends StateNotifier<ExpenseOperationsState> {
  final ExpenseRepository _repository;

  ExpenseOperations(this._repository) : super(const ExpenseOperationsState());

  /// Giderleri yükle
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final expenses = await _repository.getAllExpenses();
      state = state.copyWith(isLoading: false, expenses: expenses);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Yeni gider oluştur
  Future<void> createExpense(Expense expense) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.createExpense(expense);
      // Giderler listesini yenile
      final expenses = await _repository.getAllExpenses();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Gider başarıyla oluşturuldu',
        expenses: expenses,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gider oluşturulamadı: $e',
      );
      rethrow;
    }
  }

  /// Gider güncelle
  Future<void> updateExpense(Expense expense) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateExpense(expense);
      // Giderler listesini yenile
      final expenses = await _repository.getAllExpenses();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Gider başarıyla güncellendi',
        expenses: expenses,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gider güncellenemedi: $e',
      );
      rethrow;
    }
  }

  /// Gider sil
  Future<void> deleteExpense(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteExpense(id);
      // Giderler listesini yenile
      final expenses = await _repository.getAllExpenses();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Gider başarıyla silindi',
        expenses: expenses,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gider silinemedi: $e',
      );
      rethrow;
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Başarı mesajını temizle
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

/// Gider form state sınıfı
class ExpenseFormState {
  final Expense? expense;
  final bool isLoading;
  final bool isEditing;
  final String? errorMessage;
  final String? successMessage;

  const ExpenseFormState({
    this.expense,
    this.isLoading = false,
    this.isEditing = false,
    this.errorMessage,
    this.successMessage,
  });

  ExpenseFormState copyWith({
    Expense? expense,
    bool? isLoading,
    bool? isEditing,
    String? errorMessage,
    String? successMessage,
  }) {
    return ExpenseFormState(
      expense: expense ?? this.expense,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Gider form state notifier'ı
class ExpenseFormNotifier extends StateNotifier<ExpenseFormState> {
  final ExpenseRepository _repository;

  ExpenseFormNotifier(this._repository) : super(const ExpenseFormState());

  /// Formu düzenleme modunda başlat
  Future<void> initializeForEdit(String expenseId) async {
    state = state.copyWith(isLoading: true, isEditing: true);

    try {
      final expense = await _repository.getExpenseById(expenseId);
      state = state.copyWith(
        expense: expense,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gider bilgileri yüklenemedi: $e',
      );
    }
  }

  /// Formu yeni gider için başlat
  void initializeForCreate() {
    state = const ExpenseFormState(isEditing: false);
  }

  /// Gider kaydetme
  Future<String?> saveExpense(Expense expense) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      String expenseId;

      if (state.isEditing) {
        await _repository.updateExpense(expense);
        expenseId = expense.id;
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Gider başarıyla güncellendi',
        );
      } else {
        expenseId = await _repository.createExpense(expense);
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Gider başarıyla oluşturuldu',
        );
      }

      return expenseId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gider kaydedilemedi: $e',
      );
      return null;
    }
  }

  /// Formu temizle
  void clearForm() {
    state = const ExpenseFormState();
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Başarı mesajını temizle
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  /// Gider silme
  Future<void> deleteExpense(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteExpense(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Gider başarıyla silindi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gider silinemedi: $e',
      );
    }
  }

  /// Gider durumu güncelleme
  Future<void> updateExpenseStatus(String id, ExpenseStatus status) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.updateExpenseStatus(id, status);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Durum başarıyla güncellendi',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Durum güncellenemedi: $e',
      );
    }
  }
}
// ========== WEB PLATFORM EMPTY REPOSITORY ==========

/// Web platformu için boş gider repository sınıfı
class _EmptyExpenseRepository implements ExpenseRepository {
  // Mock verileri saklamak için static liste
  static final List<Expense> _mockExpenses = [
    Expense(
      id: '1',
      title: 'Ofis Kirası',
      description: 'Aylık ofis kirası ödemesi',
      amount: 3000.0,
      categoryId: '1',
      categoryName: 'Kira',
      expenseDate: DateTime.now().subtract(const Duration(days: 5)),
      paymentMethod: 'Banka Transferi',
      status: ExpenseStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      createdBy: 'user1',
    ),
    Expense(
      id: '2',
      title: 'Elektrik Faturası',
      description: 'Aylık elektrik faturası',
      amount: 500.0,
      categoryId: '2',
      categoryName: 'Faturalar',
      expenseDate: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: 'Otomatik Ödeme',
      status: ExpenseStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdBy: 'user1',
    ),
    Expense(
      id: '3',
      title: 'Yazılım Lisansı',
      description: 'Yıllık yazılım lisans ücreti',
      amount: 1200.0,
      categoryId: '3',
      categoryName: 'Yazılım',
      expenseDate: DateTime.now(),
      paymentMethod: 'Kredi Kartı',
      status: ExpenseStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      createdBy: 'user1',
    ),
  ];

  @override
  Future<String> createExpense(Expense expense) async {
    _mockExpenses.add(expense);
    return expense.id;
  }

  @override
  Future<void> deleteExpense(String id) async {
    _mockExpenses.removeWhere((expense) => expense.id == id);
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    try {
      return _mockExpenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    return List.from(_mockExpenses);
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String categoryId) async => [];

  @override
  Future<List<Expense>> getExpensesByStatus(ExpenseStatus status) async => [];

  @override
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async =>
      [];

  @override
  Future<List<Expense>> getRecentExpenses({int limit = 10}) async => [];

  @override
  Future<int> getTotalExpenseCount() async => 0;

  @override
  Future<double> getTotalExpenseAmount() async => 0.0;

  @override
  Future<double> getCurrentMonthExpenseAmount() async => 0.0;

  @override
  Future<List<Expense>> searchExpenses(String query) async => [];

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = _mockExpenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _mockExpenses[index] = expense;
    }
  }

  @override
  Future<void> updateExpenseStatus(String id, ExpenseStatus status) async {
    final index = _mockExpenses.indexWhere((expense) => expense.id == id);
    if (index != -1) {
      final updatedExpense = _mockExpenses[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _mockExpenses[index] = updatedExpense;
    }
  }

  @override
  Stream<Expense?> watchExpenseById(String id) => Stream.value(null);

  @override
  Stream<List<Expense>> watchAllExpenses() =>
      Stream.value(List.from(_mockExpenses));

  @override
  Stream<List<Expense>> watchExpensesByCategory(String categoryId) =>
      Stream.value([]);

  @override
  Future<List<ExpenseCategory>> getExpenseCategories() async => [];

  @override
  Future<ExpenseCategory?> getExpenseCategoryById(String id) async => null;

  @override
  Future<String> createExpenseCategory(ExpenseCategory category) async => '';

  @override
  Future<void> updateExpenseCategory(ExpenseCategory category) async {}

  @override
  Future<void> deleteExpenseCategory(String id) async {}

  @override
  Stream<List<ExpenseCategory>> watchExpenseCategories() => Stream.value([]);
}
