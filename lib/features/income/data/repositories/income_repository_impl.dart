// ========== INCOME REPOSITORY IMPLEMENTATION ==========
// lib/features/income/data/repositories/income_repository_impl.dart

import '../../domain/repositories/income_repository.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/income_category.dart';
import '../../../../core/database/tamgaci_database.dart';
import '../models/income_entity.dart';
import '../models/income_category_entity.dart';

/// Gelir repository implementation'ı
class IncomeRepositoryImpl implements IncomeRepository {
  final TamgaciDatabase _database;

  IncomeRepositoryImpl(this._database);

  // ========== INCOME OPERATIONS ==========

  @override
  Future<List<Income>> getAllIncomes() async {
    try {
      final incomeEntities = await _database.incomeDao.getAllIncomes().first;
      return incomeEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      throw Exception('Gelirler getirilirken hata oluştu: $e');
    }
  }

  @override
  Stream<List<Income>> watchAllIncomes() {
    try {
      return _database.incomeDao.getAllIncomes().map(
        (entities) => entities.map((entity) => entity.toDomain()).toList(),
      );
    } catch (e) {
      throw Exception('Gelirler izlenirken hata oluştu: $e');
    }
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return null;

      final entity = await _database.incomeDao.getIncomeById(intId);
      return entity?.toDomain();
    } catch (e) {
      throw Exception('Gelir getirilirken hata oluştu: $e');
    }
  }

  @override
  Stream<Income?> watchIncomeById(String id) {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return Stream.value(null);

      return _database.incomeDao.getAllIncomes().map(
        (entities) => entities
            .where((entity) => entity.id == intId)
            .firstOrNull
            ?.toDomain(),
      );
    } catch (e) {
      throw Exception('Gelir izlenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> createIncome(Income income) async {
    try {
      final entity = IncomeEntity.fromDomain(income);
      await _database.incomeDao.insertIncome(entity);
    } catch (e) {
      throw Exception('Gelir oluşturulurken hata oluştu: $e');
    }
  }

  @override
  Future<void> updateIncome(Income income) async {
    try {
      final entity = IncomeEntity.fromDomain(income);
      await _database.incomeDao.updateIncome(entity);
    } catch (e) {
      throw Exception('Gelir güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteIncome(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return;

      await _database.incomeDao.deleteIncomeById(intId);
    } catch (e) {
      throw Exception('Gelir silinirken hata oluştu: $e');
    }
  }

  @override
  Future<void> updateIncomeStatus(String id, IncomeStatus status) async {
    try {
      final income = await getIncomeById(id);
      if (income == null) return;

      final updatedIncome = income.copyWith(status: status);
      await updateIncome(updatedIncome);
    } catch (e) {
      throw Exception('Gelir durumu güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Income>> searchIncomes(String query) async {
    try {
      final entities = await _database.incomeDao
          .searchIncomes('%$query%')
          .first;
      return entities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      throw Exception('Gelir arama yapılırken hata oluştu: $e');
    }
  }

  @override
  Future<List<Income>> getIncomesByCategory(String categoryId) async {
    try {
      final entities = await _database.incomeDao
          .getIncomesByCategory(categoryId)
          .first;
      return entities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      throw Exception('Kategoriye göre gelirler getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Income>> getIncomesByStatus(IncomeStatus status) async {
    try {
      final entities = await _database.incomeDao
          .getIncomesByStatus(status.value)
          .first;
      return entities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      throw Exception('Duruma göre gelirler getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<List<Income>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final entities = await _database.incomeDao
          .getIncomesByDateRange(startDate, endDate)
          .first;
      return entities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      throw Exception(
        'Tarih aralığına göre gelirler getirilirken hata oluştu: $e',
      );
    }
  }

  // ========== INCOME CATEGORY OPERATIONS ==========

  @override
  Future<List<IncomeCategory>> getAllIncomeCategories() async {
    try {
      final categoryEntities = await _database.incomeCategoryDao
          .getAllCategories()
          .first;
      return categoryEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      throw Exception('Gelir kategorileri getirilirken hata oluştu: $e');
    }
  }

  @override
  Stream<List<IncomeCategory>> watchAllIncomeCategories() {
    try {
      return _database.incomeCategoryDao.getAllCategories().map(
        (entities) => entities.map((entity) => entity.toDomain()).toList(),
      );
    } catch (e) {
      throw Exception('Gelir kategorileri izlenirken hata oluştu: $e');
    }
  }

  @override
  Future<IncomeCategory?> getIncomeCategoryById(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return null;

      final entity = await _database.incomeCategoryDao.getCategoryById(intId);
      return entity?.toDomain();
    } catch (e) {
      throw Exception('Gelir kategorisi getirilirken hata oluştu: $e');
    }
  }

  @override
  Future<void> createIncomeCategory(IncomeCategory category) async {
    try {
      final entity = IncomeCategoryEntity.fromDomain(category);
      await _database.incomeCategoryDao.insertCategory(entity);
    } catch (e) {
      throw Exception('Gelir kategorisi oluşturulurken hata oluştu: $e');
    }
  }

  @override
  Future<void> updateIncomeCategory(IncomeCategory category) async {
    try {
      final entity = IncomeCategoryEntity.fromDomain(category);
      await _database.incomeCategoryDao.updateCategory(entity);
    } catch (e) {
      throw Exception('Gelir kategorisi güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteIncomeCategory(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return;

      await _database.incomeCategoryDao.deleteCategoryById(intId);
    } catch (e) {
      throw Exception('Gelir kategorisi silinirken hata oluştu: $e');
    }
  }

  // ========== STATISTICS OPERATIONS ==========

  @override
  Future<double> getTotalIncome() async {
    try {
      final total = await _database.incomeDao.getTotalIncome();
      return total ?? 0.0;
    } catch (e) {
      throw Exception('Toplam gelir hesaplanırken hata oluştu: $e');
    }
  }

  @override
  Future<double> getTotalIncomeByCategory(String categoryId) async {
    try {
      final total = await _database.incomeDao.getTotalIncomeByCategory(
        categoryId,
      );
      return total ?? 0.0;
    } catch (e) {
      throw Exception(
        'Kategoriye göre toplam gelir hesaplanırken hata oluştu: $e',
      );
    }
  }

  @override
  Future<double> getTotalIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final total = await _database.incomeDao.getTotalIncomeByDateRange(
        startDate,
        endDate,
      );
      return total ?? 0.0;
    } catch (e) {
      throw Exception(
        'Tarih aralığına göre toplam gelir hesaplanırken hata oluştu: $e',
      );
    }
  }

  @override
  Future<int> getIncomeCount() async {
    try {
      final count = await _database.incomeDao.getIncomeCount();
      return count ?? 0;
    } catch (e) {
      throw Exception('Gelir sayısı hesaplanırken hata oluştu: $e');
    }
  }

  @override
  Future<int> getIncomeCountByStatus(IncomeStatus status) async {
    try {
      final count = await _database.incomeDao.getIncomeCountByStatus(
        status.value,
      );
      return count ?? 0;
    } catch (e) {
      throw Exception('Duruma göre gelir sayısı hesaplanırken hata oluştu: $e');
    }
  }
}
