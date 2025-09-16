import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/income/data/models/income_model.dart';
import 'package:tamgaci/features/income/domain/entities/income.dart';

/// Income Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class IncomeFirebaseDataSource {
  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth;

  IncomeFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm gelirleri getirir
  Future<List<IncomeModel>> getAllIncomes({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('income')
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('income')
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
          .map((doc) => IncomeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all incomes', e);
      rethrow;
    }
  }

  /// ID'ye göre gelir getirir
  Future<IncomeModel?> getIncomeById(String id) async {
    try {
      final doc = await _firestore.collection('income').doc(id).get();
      if (doc.exists) {
        return IncomeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting income by id: $id', e);
      rethrow;
    }
  }

  /// Kategoriye göre gelirleri getirir
  Future<List<IncomeModel>> getIncomesByCategory(
    String categoryId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('income')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('income')
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
          .map((doc) => IncomeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting incomes by category: $categoryId', e);
      rethrow;
    }
  }

  /// Tarih aralığına göre gelirleri getirir
  Future<List<IncomeModel>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('income')
          .where('incomeDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('incomeDate', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('income')
            .where('incomeDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('incomeDate',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .orderBy('incomeDate', descending: true)
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
          .map((doc) => IncomeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting incomes by date range', e);
      rethrow;
    }
  }

  /// Duruma göre gelirleri getirir
  Future<List<IncomeModel>> getIncomesByStatus(
    IncomeStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('income')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('income')
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
          .map((doc) => IncomeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting incomes by status: ${status.name}', e);
      rethrow;
    }
  }

  /// Yeni gelir oluşturur
  Future<IncomeModel> createIncome(IncomeModel income) async {
    try {
      final docRef = _firestore.collection('income').doc();
      final newIncome = income.copyWith(id: docRef.id);

      await docRef.set(newIncome.toFirestore());
      AppLogger.info('Income created: ${newIncome.title}');
      return newIncome;
    } catch (e) {
      AppLogger.error('Error creating income', e);
      rethrow;
    }
  }

  /// Gelir günceller
  Future<IncomeModel> updateIncome(IncomeModel income) async {
    try {
      await _firestore
          .collection('income')
          .doc(income.id)
          .update(income.toFirestore());

      AppLogger.info('Income updated: ${income.title}');
      return income;
    } catch (e) {
      AppLogger.error('Error updating income: ${income.id}', e);
      rethrow;
    }
  }

  /// Gelir siler
  Future<void> deleteIncome(String id) async {
    try {
      await _firestore.collection('income').doc(id).delete();
      AppLogger.info('Income deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting income: $id', e);
      rethrow;
    }
  }

  /// Gelir arama
  Future<List<IncomeModel>> searchIncomes(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - title ve description'da arama
      final snapshot = await _firestore
          .collection('income')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results =
          snapshot.docs.map((doc) => IncomeModel.fromFirestore(doc)).toList();

      return results;
    } catch (e) {
      AppLogger.error('Error searching incomes: $query', e);
      rethrow;
    }
  }

  /// Gelir sayısını getirir
  Future<int> getIncomesCount() async {
    try {
      final snapshot = await _firestore.collection('income').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting incomes count', e);
      rethrow;
    }
  }

  /// Toplam gelir tutarını getirir
  Future<double> getTotalIncomeAmount({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('income');

      if (startDate != null) {
        query = query.where('incomeDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('incomeDate',
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
      AppLogger.error('Error getting total income amount', e);
      rethrow;
    }
  }

  /// Gelir istatistiklerini getirir
  Future<Map<String, dynamic>> getIncomesStatistics() async {
    try {
      final snapshot = await _firestore.collection('income').get();
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
      AppLogger.error('Error getting incomes statistics', e);
      rethrow;
    }
  }
}
