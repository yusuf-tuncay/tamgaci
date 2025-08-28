// ========== INCOME REPOSITORY INTERFACE ==========
// lib/features/income/domain/repositories/income_repository.dart

import '../entities/income.dart';
import '../entities/income_category.dart';

/// Gelir repository interface'i
abstract class IncomeRepository {
  // ========== INCOME OPERATIONS ==========

  /// Tüm gelirleri getir
  Future<List<Income>> getAllIncomes();

  /// Tüm gelirleri stream olarak izle
  Stream<List<Income>> watchAllIncomes();

  /// ID'ye göre gelir getir
  Future<Income?> getIncomeById(String id);

  /// ID'ye göre geliri stream olarak izle
  Stream<Income?> watchIncomeById(String id);

  /// Yeni gelir oluştur
  Future<void> createIncome(Income income);

  /// Gelir güncelle
  Future<void> updateIncome(Income income);

  /// Gelir sil
  Future<void> deleteIncome(String id);

  /// Gelir durumunu güncelle
  Future<void> updateIncomeStatus(String id, IncomeStatus status);

  /// Gelir ara
  Future<List<Income>> searchIncomes(String query);

  // ========== CATEGORY OPERATIONS ==========

  /// Tüm gelir kategorilerini getir
  Future<List<IncomeCategory>> getAllIncomeCategories();

  /// Tüm gelir kategorilerini stream olarak izle
  Stream<List<IncomeCategory>> watchAllIncomeCategories();

  /// Yeni gelir kategorisi oluştur
  Future<void> createIncomeCategory(IncomeCategory category);

  /// Gelir kategorisi güncelle
  Future<void> updateIncomeCategory(IncomeCategory category);

  /// Gelir kategorisi sil
  Future<void> deleteIncomeCategory(String id);
}
