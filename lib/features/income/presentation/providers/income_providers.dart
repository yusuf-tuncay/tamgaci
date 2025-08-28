// ========== INCOME PROVIDERS ==========
// lib/features/income/presentation/providers/income_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/income_category.dart';
import '../../domain/repositories/income_repository.dart';
import '../../data/repositories/income_repository_impl.dart';
import '../../../../core/database/tamgaci_database.dart';

// ========== BASE PROVIDERS ==========

/// Income repository provider
final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  // Web platformunda boş repository döndür
  if (kIsWeb) {
    return _EmptyIncomeRepository();
  }

  try {
    final databaseAsync = ref.watch(databaseProvider);
    return databaseAsync.when(
      data: (database) => IncomeRepositoryImpl(database),
      loading: () => _EmptyIncomeRepository(),
      error: (error, stack) => _EmptyIncomeRepository(),
    );
  } catch (e) {
    return _EmptyIncomeRepository();
  }
});

// ========== DATA PROVIDERS ==========

/// Tüm gelirler provider'ı
final incomesProvider = FutureProvider<List<Income>>((ref) async {
  final repository = ref.watch(incomeRepositoryProvider);
  return await repository.getAllIncomes();
});

/// Gelirler stream provider'ı (reactive)
final incomesStreamProvider = StreamProvider<List<Income>>((ref) {
  final repository = ref.watch(incomeRepositoryProvider);
  return repository.watchAllIncomes();
});

/// Belirli gelir provider'ı
final incomeProvider = FutureProvider.family<Income?, String>((ref, id) async {
  final repository = ref.watch(incomeRepositoryProvider);
  return await repository.getIncomeById(id);
});

/// Gelir stream provider'ı (tek gelir)
final incomeStreamProvider = StreamProvider.family<Income?, String>((ref, id) {
  final repository = ref.watch(incomeRepositoryProvider);
  return repository.watchIncomeById(id);
});

// ========== CATEGORY PROVIDERS ==========

/// Gelir kategorileri provider'ı
final incomeCategoriesProvider = FutureProvider<List<IncomeCategory>>((
  ref,
) async {
  final repository = ref.watch(incomeRepositoryProvider);
  return await repository.getAllIncomeCategories();
});

/// Gelir kategorileri stream provider'ı
final incomeCategoriesStreamProvider = StreamProvider<List<IncomeCategory>>((
  ref,
) {
  final repository = ref.watch(incomeRepositoryProvider);
  return repository.watchAllIncomeCategories();
});

// ========== FILTER PROVIDERS ==========

/// Gelir arama sorgusu provider'ı
final incomeSearchQueryProvider = StateProvider<String>((ref) => '');

/// Seçili gelir kategorisi provider'ı
final selectedIncomeCategoryProvider = StateProvider<IncomeCategory?>(
  (ref) => null,
);

/// Seçili gelir durumu provider'ı
final selectedIncomeStatusProvider = StateProvider<IncomeStatus?>(
  (ref) => null,
);

/// Gelir tarih aralığı provider'ı
final incomeDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// ========== SEARCH & FILTER PROVIDERS ==========

/// Gelir arama provider'ı
final incomeSearchProvider = FutureProvider.family<List<Income>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) {
    return <Income>[];
  }

  final repository = ref.watch(incomeRepositoryProvider);
  return await repository.searchIncomes(query);
});

/// Filtrelenmiş gelirler provider'ı
final filteredIncomesProvider = FutureProvider<List<Income>>((ref) async {
  final repository = ref.watch(incomeRepositoryProvider);
  final selectedCategory = ref.watch(selectedIncomeCategoryProvider);
  final selectedStatus = ref.watch(selectedIncomeStatusProvider);
  final dateRange = ref.watch(incomeDateRangeProvider);

  List<Income> incomes = await repository.getAllIncomes();

  // Kategori filtresi
  if (selectedCategory != null) {
    incomes = incomes
        .where((income) => income.categoryId == selectedCategory.id)
        .toList();
  }

  // Durum filtresi
  if (selectedStatus != null) {
    incomes = incomes
        .where((income) => income.status == selectedStatus)
        .toList();
  }

  // Tarih aralığı filtresi
  if (dateRange != null) {
    incomes = incomes.where((income) {
      return income.incomeDate.isAfter(
            dateRange.start.subtract(const Duration(days: 1)),
          ) &&
          income.incomeDate.isBefore(
            dateRange.end.add(const Duration(days: 1)),
          );
    }).toList();
  }

  return incomes;
});

// ========== FORM STATE MANAGEMENT ==========

/// Gelir formu state provider'ı
final incomeFormProvider =
    StateNotifierProvider<IncomeFormNotifier, IncomeFormState>((ref) {
      final repository = ref.watch(incomeRepositoryProvider);
      return IncomeFormNotifier(repository);
    });

/// Gelir operasyonları provider'ı
final incomeOperationsProvider =
    StateNotifierProvider<IncomeOperations, IncomeOperationsState>((ref) {
      final repository = ref.watch(incomeRepositoryProvider);
      return IncomeOperations(repository);
    });

/// Gelir operasyonları state sınıfı
class IncomeOperationsState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final List<Income> incomes;

  const IncomeOperationsState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.incomes = const [],
  });

  IncomeOperationsState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    List<Income>? incomes,
  }) {
    return IncomeOperationsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      incomes: incomes ?? this.incomes,
    );
  }
}

/// Gelir form state sınıfı
class IncomeFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final Income? income;

  const IncomeFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.income,
  });

  IncomeFormState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    Income? income,
  }) {
    return IncomeFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      income: income ?? this.income,
    );
  }
}

// ========== STATE NOTIFIERS ==========

/// Gelir form notifier'ı
class IncomeFormNotifier extends StateNotifier<IncomeFormState> {
  final IncomeRepository _repository;

  IncomeFormNotifier(this._repository) : super(const IncomeFormState());

  /// Yeni gelir oluştur
  Future<void> createIncome(Income income) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createIncome(income);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Gelir güncelle
  Future<void> updateIncome(Income income) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateIncome(income);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Gelir sil
  Future<void> deleteIncome(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteIncome(id);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// State'i sıfırla
  void reset() {
    state = const IncomeFormState();
  }
}

/// Gelir operasyonları notifier'ı
class IncomeOperations extends StateNotifier<IncomeOperationsState> {
  final IncomeRepository _repository;

  IncomeOperations(this._repository) : super(const IncomeOperationsState());

  /// Gelirleri yükle
  Future<void> loadIncomes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final incomes = await _repository.getAllIncomes();
      state = state.copyWith(isLoading: false, incomes: incomes);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Gelir durumunu güncelle
  Future<void> updateIncomeStatus(String id, IncomeStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateIncomeStatus(id, status);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// State'i sıfırla
  void reset() {
    state = const IncomeOperationsState();
  }
}

// ========== EMPTY REPOSITORY ==========

/// Boş gelir repository'si (Web platformu için)
class _EmptyIncomeRepository implements IncomeRepository {
  // Mock verileri saklamak için static liste
  static final List<Income> _mockIncomes = [
    Income(
      id: '1',
      title: 'Müşteri Ödemesi',
      description: 'Aylık hizmet ödemesi',
      amount: 5000.0,
      categoryId: '1',
      categoryName: 'Hizmet Gelirleri',
      incomeDate: DateTime.now().subtract(const Duration(days: 5)),
      paymentMethod: 'Banka Transferi',
      status: IncomeStatus.received,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Income(
      id: '2',
      title: 'Ürün Satışı',
      description: 'Elektronik ürün satışı',
      amount: 2500.0,
      categoryId: '2',
      categoryName: 'Ürün Satışları',
      incomeDate: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: 'Nakit',
      status: IncomeStatus.received,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Income(
      id: '3',
      title: 'Danışmanlık Hizmeti',
      description: 'Proje danışmanlığı',
      amount: 8000.0,
      categoryId: '1',
      categoryName: 'Hizmet Gelirleri',
      incomeDate: DateTime.now(),
      paymentMethod: 'Çek',
      status: IncomeStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Income>> getAllIncomes() async {
    return List.from(_mockIncomes);
  }

  @override
  Stream<List<Income>> watchAllIncomes() =>
      Stream.value(List.from(_mockIncomes));

  @override
  Future<Income?> getIncomeById(String id) async {
    try {
      return _mockIncomes.firstWhere((income) => income.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<Income?> watchIncomeById(String id) {
    final income = _mockIncomes.where((income) => income.id == id).firstOrNull;
    return Stream.value(income);
  }

  @override
  Future<void> createIncome(Income income) async {
    _mockIncomes.add(income);
  }

  @override
  Future<void> updateIncome(Income income) async {
    final index = _mockIncomes.indexWhere((i) => i.id == income.id);
    if (index != -1) {
      _mockIncomes[index] = income;
    }
  }

  @override
  Future<void> deleteIncome(String id) async {
    _mockIncomes.removeWhere((income) => income.id == id);
  }

  @override
  Future<void> updateIncomeStatus(String id, IncomeStatus status) async {
    final index = _mockIncomes.indexWhere((income) => income.id == id);
    if (index != -1) {
      final updatedIncome = _mockIncomes[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _mockIncomes[index] = updatedIncome;
    }
  }

  @override
  Future<List<Income>> searchIncomes(String query) async => [];

  @override
  Future<List<IncomeCategory>> getAllIncomeCategories() async => [];

  @override
  Stream<List<IncomeCategory>> watchAllIncomeCategories() => Stream.value([]);

  @override
  Future<void> createIncomeCategory(IncomeCategory category) async {}

  @override
  Future<void> updateIncomeCategory(IncomeCategory category) async {}

  @override
  Future<void> deleteIncomeCategory(String id) async {}
}
