// ========== EXPENSE DAO ==========
// lib/features/expenses/data/datasources/expense_dao.dart

import 'package:floor/floor.dart';
import '../models/expense_entity.dart';

@dao
abstract class ExpenseDao {
  // Tüm giderleri getir
  @Query('SELECT * FROM expenses ORDER BY date DESC')
  Stream<List<ExpenseEntity>> getAllExpenses();

  // Aktif giderleri getir
  @Query('SELECT * FROM expenses WHERE status = "active" ORDER BY date DESC')
  Stream<List<ExpenseEntity>> getActiveExpenses();

  // ID'ye göre gider getir
  @Query('SELECT * FROM expenses WHERE id = :id')
  Future<ExpenseEntity?> getExpenseById(int id);

  // Kategoriye göre giderleri getir
  @Query(
    'SELECT * FROM expenses WHERE categoryId = :categoryId ORDER BY date DESC',
  )
  Stream<List<ExpenseEntity>> getExpensesByCategory(int categoryId);

  // Tarih aralığına göre giderleri getir
  @Query(
    'SELECT * FROM expenses WHERE date BETWEEN :startDate AND :endDate ORDER BY date DESC',
  )
  Stream<List<ExpenseEntity>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  // Duruma göre giderleri getir
  @Query('SELECT * FROM expenses WHERE status = :status ORDER BY date DESC')
  Stream<List<ExpenseEntity>> getExpensesByStatus(String status);

  // Arama yap
  @Query('''
    SELECT * FROM expenses 
    WHERE title LIKE '%' || :query || '%' 
    OR description LIKE '%' || :query || '%'
    ORDER BY date DESC
  ''')
  Stream<List<ExpenseEntity>> searchExpenses(String query);

  // Toplam gider tutarını getir
  @Query('SELECT SUM(amount) FROM expenses WHERE status = "active"')
  Future<double?> getTotalExpenseAmount();

  // Kategoriye göre toplam tutar
  @Query(
    'SELECT SUM(amount) FROM expenses WHERE categoryId = :categoryId AND status = "active"',
  )
  Future<double?> getTotalAmountByCategory(int categoryId);

  // Tarih aralığına göre toplam tutar
  @Query(
    'SELECT SUM(amount) FROM expenses WHERE date BETWEEN :startDate AND :endDate AND status = "active"',
  )
  Future<double?> getTotalAmountByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  // Gider ekle
  @insert
  Future<int> insertExpense(ExpenseEntity expense);

  // Gider güncelle
  @update
  Future<int> updateExpense(ExpenseEntity expense);

  // Gider sil
  @delete
  Future<int> deleteExpense(ExpenseEntity expense);

  // ID'ye göre gider sil
  @Query('DELETE FROM expenses WHERE id = :id')
  Future<int?> deleteExpenseById(int id);

  // Tüm giderleri sil
  @Query('DELETE FROM expenses')
  Future<int?> deleteAllExpenses();
}
