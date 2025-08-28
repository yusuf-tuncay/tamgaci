// ========== EXPENSE CATEGORY DAO ==========
// lib/features/expenses/data/datasources/expense_category_dao.dart

import 'package:floor/floor.dart';
import '../models/expense_category_entity.dart';

@dao
abstract class ExpenseCategoryDao {
  // Tüm kategorileri getir
  @Query('SELECT * FROM expense_categories ORDER BY name ASC')
  Stream<List<ExpenseCategoryEntity>> getAllCategories();

  // Aktif kategorileri getir
  @Query(
    'SELECT * FROM expense_categories WHERE isActive = 1 ORDER BY name ASC',
  )
  Stream<List<ExpenseCategoryEntity>> getActiveCategories();

  // ID'ye göre kategori getir
  @Query('SELECT * FROM expense_categories WHERE id = :id')
  Future<ExpenseCategoryEntity?> getCategoryById(int id);

  // Varsayılan kategorileri getir
  @Query(
    'SELECT * FROM expense_categories WHERE isDefault = 1 ORDER BY name ASC',
  )
  Stream<List<ExpenseCategoryEntity>> getDefaultCategories();

  // Kategori ekle
  @insert
  Future<int> insertCategory(ExpenseCategoryEntity category);

  // Kategori güncelle
  @update
  Future<int> updateCategory(ExpenseCategoryEntity category);

  // Kategori sil
  @delete
  Future<int> deleteCategory(ExpenseCategoryEntity category);

  // ID'ye göre kategori sil
  @Query('DELETE FROM expense_categories WHERE id = :id')
  Future<int?> deleteCategoryById(int id);

  // Tüm kategorileri sil
  @Query('DELETE FROM expense_categories')
  Future<int?> deleteAllCategories();

  // Kategori adına göre ara
  @Query(
    'SELECT * FROM expense_categories WHERE name LIKE "%" || :query || "%" ORDER BY name ASC',
  )
  Stream<List<ExpenseCategoryEntity>> searchCategories(String query);

  // Kategori sayısını getir
  @Query('SELECT COUNT(*) FROM expense_categories WHERE isActive = 1')
  Future<int?> getActiveCategoryCount();
}
