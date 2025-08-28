import 'package:floor/floor.dart';
import '../models/income_category_entity.dart';

/// Gelir kategorisi veritabanı erişim nesnesi (DAO)
@dao
abstract class IncomeCategoryDao {
  /// Tüm kategorileri getir
  @Query('SELECT * FROM income_categories ORDER BY name ASC')
  Stream<List<IncomeCategoryEntity>> getAllCategories();

  /// Aktif kategorileri getir
  @Query(
    'SELECT * FROM income_categories WHERE is_active = 1 ORDER BY name ASC',
  )
  Stream<List<IncomeCategoryEntity>> getActiveCategories();

  /// ID'ye göre kategori getir
  @Query('SELECT * FROM income_categories WHERE id = :id')
  Future<IncomeCategoryEntity?> getCategoryById(int id);

  /// Kategori ekle
  @Insert()
  Future<int> insertCategory(IncomeCategoryEntity category);

  /// Kategori güncelle
  @Update()
  Future<int> updateCategory(IncomeCategoryEntity category);

  /// Kategori sil
  @delete
  Future<int> deleteCategory(IncomeCategoryEntity category);

  /// ID'ye göre kategori sil
  @Query('DELETE FROM income_categories WHERE id = :id')
  Future<int?> deleteCategoryById(int id);

  /// Kategori sayısını getir
  @Query('SELECT COUNT(*) FROM income_categories')
  Future<int?> getCategoryCount();

  /// Aktif kategori sayısını getir
  @Query('SELECT COUNT(*) FROM income_categories WHERE is_active = 1')
  Future<int?> getActiveCategoryCount();
}
