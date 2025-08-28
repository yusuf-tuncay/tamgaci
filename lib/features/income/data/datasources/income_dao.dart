import 'package:floor/floor.dart';
import '../models/income_entity.dart';

/// Gelir veritabanı erişim nesnesi (DAO)
@dao
abstract class IncomeDao {
  /// Tüm gelirleri getir
  @Query('SELECT * FROM incomes ORDER BY created_at DESC')
  Stream<List<IncomeEntity>> getAllIncomes();

  /// Aktif gelirleri getir
  @Query(
    'SELECT * FROM incomes WHERE status != "deleted" ORDER BY created_at DESC',
  )
  Stream<List<IncomeEntity>> getActiveIncomes();

  /// ID'ye göre gelir getir
  @Query('SELECT * FROM incomes WHERE id = :id')
  Future<IncomeEntity?> getIncomeById(int id);

  /// String ID'ye göre gelir getir
  @Query('SELECT * FROM incomes WHERE id = :id')
  Future<IncomeEntity?> getIncomeByStringId(String id);

  /// Kategoriye göre gelirleri getir
  @Query(
    'SELECT * FROM incomes WHERE category_id = :categoryId ORDER BY created_at DESC',
  )
  Stream<List<IncomeEntity>> getIncomesByCategory(String categoryId);

  /// Duruma göre gelirleri getir
  @Query(
    'SELECT * FROM incomes WHERE status = :status ORDER BY created_at DESC',
  )
  Stream<List<IncomeEntity>> getIncomesByStatus(String status);

  /// Tarih aralığına göre gelirleri getir
  @Query(
    'SELECT * FROM incomes WHERE created_at BETWEEN :startDate AND :endDate ORDER BY created_at DESC',
  )
  Stream<List<IncomeEntity>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Arama yap
  @Query('''
    SELECT * FROM incomes 
    WHERE title LIKE :query 
    OR description LIKE :query 
    OR customer_name LIKE :query 
    OR invoice_number LIKE :query
    ORDER BY created_at DESC
  ''')
  Stream<List<IncomeEntity>> searchIncomes(String query);

  /// Gelir ekle
  @Insert()
  Future<int> insertIncome(IncomeEntity income);

  /// Gelir güncelle
  @Update()
  Future<int> updateIncome(IncomeEntity income);

  /// Gelir sil
  @delete
  Future<int> deleteIncome(IncomeEntity income);

  /// ID'ye göre gelir sil
  @Query('DELETE FROM incomes WHERE id = :id')
  Future<int?> deleteIncomeById(int id);

  /// String ID'ye göre gelir sil
  @Query('DELETE FROM incomes WHERE id = :id')
  Future<int?> deleteIncomeByStringId(String id);

  /// Toplam gelir miktarını getir
  @Query('SELECT SUM(amount) FROM incomes WHERE status = "paid"')
  Future<double?> getTotalIncome();

  /// Kategoriye göre toplam gelir miktarını getir
  @Query(
    'SELECT SUM(amount) FROM incomes WHERE category_id = :categoryId AND status = "paid"',
  )
  Future<double?> getTotalIncomeByCategory(String categoryId);

  /// Tarih aralığına göre toplam gelir miktarını getir
  @Query(
    'SELECT SUM(amount) FROM incomes WHERE created_at BETWEEN :startDate AND :endDate AND status = "paid"',
  )
  Future<double?> getTotalIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gelir sayısını getir
  @Query('SELECT COUNT(*) FROM incomes')
  Future<int?> getIncomeCount();

  /// Duruma göre gelir sayısını getir
  @Query('SELECT COUNT(*) FROM incomes WHERE status = :status')
  Future<int?> getIncomeCountByStatus(String status);
}
