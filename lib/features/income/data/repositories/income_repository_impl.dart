// ========== INCOME REPOSITORY IMPLEMENTATION ==========
// lib/features/income/data/repositories/income_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/core/repositories/firebase_repository.dart';
import 'package:tamgaci/features/income/domain/entities/income.dart';
import 'package:tamgaci/features/income/domain/entities/income_category.dart';
import 'package:tamgaci/features/income/domain/repositories/income_repository.dart';

/// Firebase Income Repository Implementation
class IncomeRepositoryImpl extends FirebaseRepository<Income>
    implements IncomeRepository {
  static const String _incomesCollection = 'incomes';
  static const String _categoriesCollection = 'income_categories';

  @override
  String get collectionName => _incomesCollection;

  @override
  String get entityTypeName => 'Income';

  @override
  Map<String, dynamic> entityToMap(Income entity) => entity.toJson();

  @override
  Income mapToEntity(Map<String, dynamic> map) => Income.fromJson(map);

  @override
  String getEntityId(Income entity) => entity.id;

  @override
  Income setEntityId(Income entity, String id) => entity.copyWith(id: id);

  @override
  DateTime getEntityCreatedAt(Income entity) => entity.createdAt;

  @override
  DateTime getEntityUpdatedAt(Income entity) => entity.updatedAt;

  @override
  Income setEntityUpdatedAt(Income entity, DateTime timestamp) =>
      entity.copyWith(updatedAt: timestamp);

  @override
  String getEntityCreatedBy(Income entity) => entity.createdBy;

  @override
  String? getEntityUpdatedBy(Income entity) => entity.updatedBy;

  @override
  Income setEntityUpdatedBy(Income entity, String userId) =>
      entity.copyWith(updatedBy: userId);

  // ========== INCOME OPERATIONS ==========

  @override
  Future<List<Income>> getAllIncomes() async {
    try {
      final snapshot = await firestore
          .collection(_incomesCollection)
          .orderBy('incomeDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => Income.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get all incomes: $e');
    }
  }

  @override
  Stream<List<Income>> watchAllIncomes() {
    return firestore
        .collection(_incomesCollection)
        .orderBy('incomeDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Income.fromJson(doc.data())).toList());
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    try {
      final doc = await firestore.collection(_incomesCollection).doc(id).get();

      if (doc.exists) {
        return Income.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get income by id: $e');
    }
  }

  @override
  Stream<Income?> watchIncomeById(String id) {
    return firestore
        .collection(_incomesCollection)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Income.fromJson(doc.data()!) : null);
  }

  @override
  Future<void> createIncome(Income income) async {
    try {
      await firestore
          .collection(_incomesCollection)
          .doc(income.id)
          .set(income.toJson());
    } catch (e) {
      throw Exception('Failed to create income: $e');
    }
  }

  @override
  Future<void> updateIncome(Income income) async {
    try {
      await firestore
          .collection(_incomesCollection)
          .doc(income.id)
          .update(income.toJson());
    } catch (e) {
      throw Exception('Failed to update income: $e');
    }
  }

  @override
  Future<void> deleteIncome(String id) async {
    try {
      await firestore.collection(_incomesCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete income: $e');
    }
  }

  @override
  Future<void> updateIncomeStatus(String id, IncomeStatus status) async {
    try {
      await firestore.collection(_incomesCollection).doc(id).update({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update income status: $e');
    }
  }

  @override
  Future<List<Income>> searchIncomes(String query) async {
    try {
      final snapshot = await firestore
          .collection(_incomesCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) => Income.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to search incomes: $e');
    }
  }

  // ========== CATEGORY OPERATIONS ==========

  @override
  Future<List<IncomeCategory>> getAllIncomeCategories() async {
    try {
      final snapshot = await firestore
          .collection(_categoriesCollection)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => IncomeCategory.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all income categories: $e');
    }
  }

  @override
  Stream<List<IncomeCategory>> watchAllIncomeCategories() {
    return firestore
        .collection(_categoriesCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncomeCategory.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> createIncomeCategory(IncomeCategory category) async {
    try {
      await firestore
          .collection(_categoriesCollection)
          .doc(category.id)
          .set(category.toJson());
    } catch (e) {
      throw Exception('Failed to create income category: $e');
    }
  }

  @override
  Future<void> updateIncomeCategory(IncomeCategory category) async {
    try {
      await firestore
          .collection(_categoriesCollection)
          .doc(category.id)
          .update(category.toJson());
    } catch (e) {
      throw Exception('Failed to update income category: $e');
    }
  }

  @override
  Future<void> deleteIncomeCategory(String id) async {
    try {
      await firestore.collection(_categoriesCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete income category: $e');
    }
  }

  // ========== FIREBASE REPOSITORY IMPLEMENTATION ==========

  // These helpers are not overrides; keep as convenience mappers.
  Income fromFirestore(Map<String, dynamic> data) {
    return Income.fromJson(data);
  }

  Map<String, dynamic> toFirestore(Income entity) {
    return entity.toJson();
  }
}
