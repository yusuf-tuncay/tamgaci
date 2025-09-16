import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/expenses/data/models/expense_model.dart';
import 'package:tamgaci/features/expenses/domain/entities/expense.dart';

/// Expense Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class ExpenseFirebaseDataSource {
  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth;

  ExpenseFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm giderleri getirir
  Future<List<ExpenseModel>> getAllExpenses({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('expenses')
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('expenses')
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all expenses', e);
      rethrow;
    }
  }

  /// ID'ye göre gider getirir
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final doc = await _firestore.collection('expenses').doc(id).get();
      if (doc.exists) {
        return ExpenseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting expense by id: $id', e);
      rethrow;
    }
  }

  /// Kategoriye göre giderleri getirir
  Future<List<ExpenseModel>> getExpensesByCategory(
    String categoryId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('expenses')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('expenses')
            .where('categoryId', isEqualTo: categoryId)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting expenses by category: $categoryId', e);
      rethrow;
    }
  }

  /// Tarih aralığına göre giderleri getirir
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('expenses')
          .where('expenseDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('expenseDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('expenseDate', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('expenses')
            .where('expenseDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('expenseDate',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .orderBy('expenseDate', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting expenses by date range', e);
      rethrow;
    }
  }

  /// Duruma göre giderleri getirir
  Future<List<ExpenseModel>> getExpensesByStatus(
    ExpenseStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('expenses')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('expenses')
            .where('status', isEqualTo: status.name)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting expenses by status: ${status.name}', e);
      rethrow;
    }
  }

  /// Yeni gider oluşturur
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      final docRef = _firestore.collection('expenses').doc();
      final newExpense = expense.copyWith(id: docRef.id);

      await docRef.set(newExpense.toFirestore());
      AppLogger.info('Expense created: ${newExpense.title}');
      return newExpense;
    } catch (e) {
      AppLogger.error('Error creating expense', e);
      rethrow;
    }
  }

  /// Gider günceller
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toFirestore());

      AppLogger.info('Expense updated: ${expense.title}');
      return expense;
    } catch (e) {
      AppLogger.error('Error updating expense: ${expense.id}', e);
      rethrow;
    }
  }

  /// Gider siler
  Future<void> deleteExpense(String id) async {
    try {
      await _firestore.collection('expenses').doc(id).delete();
      AppLogger.info('Expense deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting expense: $id', e);
      rethrow;
    }
  }

  /// Gider arama
  Future<List<ExpenseModel>> searchExpenses(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - title ve description'da arama
      final snapshot = await _firestore
          .collection('expenses')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results =
          snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();

      return results;
    } catch (e) {
      AppLogger.error('Error searching expenses: $query', e);
      rethrow;
    }
  }

  /// Gider sayısını getirir
  Future<int> getExpensesCount() async {
    try {
      final snapshot = await _firestore.collection('expenses').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting expenses count', e);
      rethrow;
    }
  }

  /// Toplam gider tutarını getirir
  Future<double> getTotalExpenseAmount({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('expenses');

      if (startDate != null) {
        query = query.where('expenseDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('expenseDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting total expense amount', e);
      rethrow;
    }
  }

  /// Gider istatistiklerini getirir
  Future<Map<String, dynamic>> getExpensesStatistics() async {
    try {
      final snapshot = await _firestore.collection('expenses').get();
      final stats = <String, dynamic>{
        'totalCount': snapshot.docs.length,
        'totalAmount': 0.0,
        'categoryCounts': <String, int>{},
        'statusCounts': <String, int>{},
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num).toDouble();
        final categoryId = data['categoryId'] as String;
        final status = data['status'] as String;

        stats['totalAmount'] = (stats['totalAmount'] as double) + amount;

        stats['categoryCounts'][categoryId] =
            (stats['categoryCounts'][categoryId] as int? ?? 0) + 1;
        stats['statusCounts'][status] =
            (stats['statusCounts'][status] as int? ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      AppLogger.error('Error getting expenses statistics', e);
      rethrow;
    }
  }
}
