// ========== EXPENSE REPOSITORY INTERFACE ==========
// lib/features/expenses/domain/repositories/expense_repository.dart

import '../entities/expense.dart';
import '../entities/expense_category.dart';

/// Gider repository interface'i
abstract class ExpenseRepository {
  // ========== EXPENSE OPERATIONS ==========

  /// Yeni gider oluşturur
  Future<String> createExpense(Expense expense);

  /// Gideri günceller
  Future<void> updateExpense(Expense expense);

  /// Gideri siler
  Future<void> deleteExpense(String id);

  /// ID'ye göre gider getirir
  Future<Expense?> getExpenseById(String id);

  /// Tüm giderleri getirir
  Future<List<Expense>> getAllExpenses();

  /// Kategoriye göre giderleri getirir
  Future<List<Expense>> getExpensesByCategory(String categoryId);

  /// Duruma göre giderleri getirir
  Future<List<Expense>> getExpensesByStatus(ExpenseStatus status);

  /// Tarih aralığına göre giderleri getirir
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Son giderleri getirir
  Future<List<Expense>> getRecentExpenses({int limit = 10});

  /// Toplam gider sayısını getirir
  Future<int> getTotalExpenseCount();

  /// Toplam gider tutarını getirir
  Future<double> getTotalExpenseAmount();

  /// Bu ay gider tutarını getirir
  Future<double> getCurrentMonthExpenseAmount();

  /// Gider arama yapar
  Future<List<Expense>> searchExpenses(String query);

  /// Gider durumunu günceller
  Future<void> updateExpenseStatus(String id, ExpenseStatus status);

  // ========== STREAM OPERATIONS ==========

  /// ID'ye göre gider stream'i
  Stream<Expense?> watchExpenseById(String id);

  /// Tüm giderler stream'i
  Stream<List<Expense>> watchAllExpenses();

  /// Kategoriye göre giderler stream'i
  Stream<List<Expense>> watchExpensesByCategory(String categoryId);

  // ========== CATEGORY OPERATIONS ==========

  /// Tüm gider kategorilerini getirir
  Future<List<ExpenseCategory>> getExpenseCategories();

  /// ID'ye göre kategori getirir
  Future<ExpenseCategory?> getExpenseCategoryById(String id);

  /// Yeni kategori oluşturur
  Future<String> createExpenseCategory(ExpenseCategory category);

  /// Kategoriyi günceller
  Future<void> updateExpenseCategory(ExpenseCategory category);

  /// Kategoriyi siler
  Future<void> deleteExpenseCategory(String id);

  /// Kategoriler stream'i
  Stream<List<ExpenseCategory>> watchExpenseCategories();
}
