// ========== EXPENSE REPOSITORY IMPLEMENTATION ==========
// lib/features/expenses/data/repositories/expense_repository_impl.dart

import '../../../../core/database/tamgaci_database.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_entity.dart';
import '../models/expense_category_entity.dart';
import '../datasources/expense_dao.dart';
import '../datasources/expense_category_dao.dart';

/// Gider repository implementation'ı
class ExpenseRepositoryImpl implements ExpenseRepository {
  final TamgaciDatabase _database;
  late final ExpenseDao _expenseDao;
  late final ExpenseCategoryDao _categoryDao;

  ExpenseRepositoryImpl(this._database) {
    _expenseDao = _database.expenseDao;
    _categoryDao = _database.expenseCategoryDao;
  }

  // ========== EXPENSE OPERATIONS ==========

  @override
  Future<String> createExpense(Expense expense) async {
    final expenseEntity = ExpenseEntity(
      title: expense.title,
      description: expense.description,
      amount: expense.amount,
      categoryId: int.parse(expense.categoryId),
      date: expense.expenseDate,
      status: expense.status.name,
      paymentMethod: expense.paymentMethod,
      receiptPath:
          expense.attachments.isNotEmpty ? expense.attachments.first : null,
      notes: expense.description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await _expenseDao.insertExpense(expenseEntity);
    return id.toString();
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final expenseEntity = ExpenseEntity(
      id: int.parse(expense.id),
      title: expense.title,
      description: expense.description,
      amount: expense.amount,
      categoryId: int.parse(expense.categoryId),
      date: expense.expenseDate,
      status: expense.status.name,
      paymentMethod: expense.paymentMethod,
      receiptPath:
          expense.attachments.isNotEmpty ? expense.attachments.first : null,
      notes: expense.description,
      createdAt: expense.createdAt,
      updatedAt: DateTime.now(),
    );

    await _expenseDao.updateExpense(expenseEntity);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _expenseDao.deleteExpenseById(int.parse(id));
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final expenseEntity = await _expenseDao.getExpenseById(int.parse(id));
    if (expenseEntity == null) return null;

    return _mapExpenseEntityToExpense(expenseEntity);
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final expenseEntities = await _expenseDao.getAllExpenses().first;
      return expenseEntities
          .map((entity) => _mapExpenseEntityToExpense(entity))
          .toList();
    } catch (e) {
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    try {
      final expenseEntities =
          await _expenseDao.getExpensesByCategory(int.parse(categoryId)).first;
      return expenseEntities
          .map((entity) => _mapExpenseEntityToExpense(entity))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Expense>> getExpensesByStatus(ExpenseStatus status) async {
    try {
      final expenseEntities =
          await _expenseDao.getExpensesByStatus(status.name).first;
      return expenseEntities
          .map((entity) => _mapExpenseEntityToExpense(entity))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenseEntities =
          await _expenseDao.getExpensesByDateRange(startDate, endDate).first;
      return expenseEntities
          .map((entity) => _mapExpenseEntityToExpense(entity))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Expense>> getRecentExpenses({int limit = 10}) async {
    try {
      final allExpenses = await getAllExpenses();
      return allExpenses.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> getTotalExpenseCount() async {
    try {
      final allExpenses = await getAllExpenses();
      return allExpenses.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<double> getTotalExpenseAmount() async {
    try {
      final totalAmount = await _expenseDao.getTotalExpenseAmount();
      return totalAmount ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<double> getCurrentMonthExpenseAmount() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final totalAmount =
          await _expenseDao.getTotalAmountByDateRange(startOfMonth, endOfMonth);
      return totalAmount ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<List<Expense>> searchExpenses(String query) async {
    try {
      final expenseEntities = await _expenseDao.searchExpenses(query).first;
      return expenseEntities
          .map((entity) => _mapExpenseEntityToExpense(entity))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateExpenseStatus(String id, ExpenseStatus status) async {
    try {
      final expense = await getExpenseById(id);
      if (expense != null) {
        final updatedExpense =
            expense.copyWith(status: status, updatedAt: DateTime.now());
        await updateExpense(updatedExpense);
      }
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // ========== STREAM OPERATIONS ==========

  @override
  Stream<Expense?> watchExpenseById(String id) {
    try {
      return _expenseDao.getExpenseById(int.parse(id)).asStream().map((entity) {
        return entity != null ? _mapExpenseEntityToExpense(entity) : null;
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  @override
  Stream<List<Expense>> watchAllExpenses() {
    try {
      return _expenseDao.getAllExpenses().map((entities) {
        return entities
            .map((entity) => _mapExpenseEntityToExpense(entity))
            .toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  @override
  Stream<List<Expense>> watchExpensesByCategory(String categoryId) {
    try {
      return _expenseDao
          .getExpensesByCategory(int.parse(categoryId))
          .map((entities) {
        return entities
            .map((entity) => _mapExpenseEntityToExpense(entity))
            .toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // ========== CATEGORY OPERATIONS ==========

  @override
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      final categoryEntities = await _categoryDao.getActiveCategories().first;
      return categoryEntities
          .map((entity) => _mapCategoryEntityToCategory(entity))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ExpenseCategory?> getExpenseCategoryById(String id) async {
    try {
      final categoryEntity = await _categoryDao.getCategoryById(int.parse(id));
      return categoryEntity != null
          ? _mapCategoryEntityToCategory(categoryEntity)
          : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> createExpenseCategory(ExpenseCategory category) async {
    try {
      final categoryEntity = ExpenseCategoryEntity(
        name: category.name,
        description: category.description,
        color: category.color,
        icon: category.icon,
        isActive: category.isActive,
        isDefault: false,
        sortOrder: 0,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
      );

      final id = await _categoryDao.insertCategory(categoryEntity);
      return id.toString();
    } catch (e) {
      return 'category_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  Future<void> updateExpenseCategory(ExpenseCategory category) async {
    try {
      final categoryEntity = ExpenseCategoryEntity(
        id: int.parse(category.id),
        name: category.name,
        description: category.description,
        color: category.color,
        icon: category.icon,
        isActive: category.isActive,
        isDefault: false,
        sortOrder: 0,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
      );

      await _categoryDao.updateCategory(categoryEntity);
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  @override
  Future<void> deleteExpenseCategory(String id) async {
    try {
      await _categoryDao.deleteCategoryById(int.parse(id));
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  @override
  Stream<List<ExpenseCategory>> watchExpenseCategories() {
    try {
      return _categoryDao.getActiveCategories().map((entities) {
        return entities
            .map((entity) => _mapCategoryEntityToCategory(entity))
            .toList();
      });
    } catch (e) {
      // Hata durumunda boş liste döndür
      return Stream.value([]);
    }
  }

  // ========== MAPPING METHODS ==========

  /// ExpenseEntity'yi Expense'e dönüştürür
  Expense _mapExpenseEntityToExpense(ExpenseEntity entity) {
    return Expense(
      id: entity.id.toString(),
      title: entity.title,
      description: entity.description,
      amount: entity.amount,
      categoryId: entity.categoryId.toString(),
      categoryName: 'Kategori', // TODO: Get from category
      expenseDate: entity.date,
      paymentMethod: entity.paymentMethod ?? 'Nakit',
      status: _mapStatusFromString(entity.status),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: 'system', // TODO: Get from user
      attachments: entity.receiptPath != null ? [entity.receiptPath!] : [],
    );
  }

  /// ExpenseCategoryEntity'yi ExpenseCategory'ye dönüştürür
  ExpenseCategory _mapCategoryEntityToCategory(ExpenseCategoryEntity entity) {
    return ExpenseCategory(
      id: entity.id.toString(),
      name: entity.name,
      description: entity.description,
      color: entity.color ?? '#9E9E9E',
      icon: entity.icon ?? 'category',
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// String'den ExpenseStatus'e dönüştürür
  ExpenseStatus _mapStatusFromString(String status) {
    switch (status) {
      case 'active':
        return ExpenseStatus.paid;
      case 'pending':
        return ExpenseStatus.pending;
      case 'cancelled':
        return ExpenseStatus.cancelled;
      default:
        return ExpenseStatus.paid;
    }
  }
}
