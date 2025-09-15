import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/cash_management/data/models/cash_transaction_model.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';

/// CashTransaction Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class CashTransactionFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CashTransactionFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm nakit işlemleri getirir
  Future<List<CashTransactionModel>> getAllCashTransactions({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_transactions')
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_transactions')
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
          .map((doc) => CashTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all cash transactions', e);
      rethrow;
    }
  }

  /// ID'ye göre nakit işlem getirir
  Future<CashTransactionModel?> getCashTransactionById(String id) async {
    try {
      final doc =
          await _firestore.collection('cash_transactions').doc(id).get();
      if (doc.exists) {
        return CashTransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting cash transaction by id: $id', e);
      rethrow;
    }
  }

  /// İşlem numarasına göre nakit işlem getirir
  Future<CashTransactionModel?> getCashTransactionByNumber(
      String transactionNumber) async {
    try {
      final snapshot = await _firestore
          .collection('cash_transactions')
          .where('transactionNumber', isEqualTo: transactionNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return CashTransactionModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      AppLogger.error(
          'Error getting cash transaction by number: $transactionNumber', e);
      rethrow;
    }
  }

  /// Hesaba göre nakit işlemleri getirir
  Future<List<CashTransactionModel>> getCashTransactionsByAccount(
    String accountId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_transactions')
          .where('fromAccountId', isEqualTo: accountId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_transactions')
            .where('fromAccountId', isEqualTo: accountId)
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
          .map((doc) => CashTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting cash transactions by account: $accountId', e);
      rethrow;
    }
  }

  /// Tarih aralığına göre nakit işlemleri getirir
  Future<List<CashTransactionModel>> getCashTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_transactions')
          .where('transactionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('transactionDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('transactionDate', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_transactions')
            .where('transactionDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('transactionDate',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .orderBy('transactionDate', descending: true)
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
          .map((doc) => CashTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting cash transactions by date range', e);
      rethrow;
    }
  }

  /// Türüne göre nakit işlemleri getirir
  Future<List<CashTransactionModel>> getCashTransactionsByType(
    CashTransactionType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_transactions')
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_transactions')
            .where('type', isEqualTo: type.name)
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
          .map((doc) => CashTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting cash transactions by type: ${type.name}', e);
      rethrow;
    }
  }

  /// Kategorisine göre nakit işlemleri getirir
  Future<List<CashTransactionModel>> getCashTransactionsByCategory(
    CashTransactionCategory category, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_transactions')
          .where('category', isEqualTo: category.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_transactions')
            .where('category', isEqualTo: category.name)
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
          .map((doc) => CashTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting cash transactions by category: ${category.name}', e);
      rethrow;
    }
  }

  /// Duruma göre nakit işlemleri getirir
  Future<List<CashTransactionModel>> getCashTransactionsByStatus(
    CashTransactionStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('cash_transactions')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_transactions')
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
          .map((doc) => CashTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting cash transactions by status: ${status.name}', e);
      rethrow;
    }
  }

  /// Vadesi geçmiş nakit işlemleri getirir
  Future<List<CashTransactionModel>> getOverdueCashTransactions({
    int? limit,
    int? offset,
  }) async {
    try {
      final now = DateTime.now();
      Query query = _firestore
          .collection('cash_transactions')
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .where('status', whereIn: ['pending', 'completed']).orderBy('dueDate',
              descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('cash_transactions')
            .where('dueDate', isLessThan: Timestamp.fromDate(now))
            .where('status', whereIn: ['pending', 'completed'])
            .orderBy('dueDate', descending: true)
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
          .map((doc) => CashTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting overdue cash transactions', e);
      rethrow;
    }
  }

  /// Yeni nakit işlem oluşturur
  Future<CashTransactionModel> createCashTransaction(
      CashTransactionModel cashTransaction) async {
    try {
      final docRef = _firestore.collection('cash_transactions').doc();
      final newCashTransaction = cashTransaction.copyWith(id: docRef.id);

      await docRef.set(newCashTransaction.toFirestore());
      AppLogger.info(
          'Cash transaction created: ${newCashTransaction.transactionNumber}');
      return newCashTransaction;
    } catch (e) {
      AppLogger.error('Error creating cash transaction', e);
      rethrow;
    }
  }

  /// Nakit işlem günceller
  Future<CashTransactionModel> updateCashTransaction(
      CashTransactionModel cashTransaction) async {
    try {
      await _firestore
          .collection('cash_transactions')
          .doc(cashTransaction.id)
          .update(cashTransaction.toFirestore());

      AppLogger.info(
          'Cash transaction updated: ${cashTransaction.transactionNumber}');
      return cashTransaction;
    } catch (e) {
      AppLogger.error(
          'Error updating cash transaction: ${cashTransaction.id}', e);
      rethrow;
    }
  }

  /// Nakit işlem siler
  Future<void> deleteCashTransaction(String id) async {
    try {
      await _firestore.collection('cash_transactions').doc(id).delete();
      AppLogger.info('Cash transaction deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting cash transaction: $id', e);
      rethrow;
    }
  }

  /// Nakit işlem arama
  Future<List<CashTransactionModel>> searchCashTransactions(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - transactionNumber ve description'da arama
      final snapshot = await _firestore
          .collection('cash_transactions')
          .where('transactionNumber', isGreaterThanOrEqualTo: query)
          .where('transactionNumber', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results = snapshot.docs
          .map((doc) => CashTransactionModel.fromFirestore(doc))
          .toList();

      // Eğer yeterli sonuç yoksa, description'da da ara
      if (results.length < (limit ?? 50)) {
        final descSnapshot = await _firestore
            .collection('cash_transactions')
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThanOrEqualTo: '$query\uf8ff')
            .limit((limit ?? 50) - results.length)
            .get();

        final descResults = descSnapshot.docs
            .map((doc) => CashTransactionModel.fromFirestore(doc))
            .where((transaction) => !results.any((r) => r.id == transaction.id))
            .toList();

        results.addAll(descResults);
      }

      return results;
    } catch (e) {
      AppLogger.error('Error searching cash transactions: $query', e);
      rethrow;
    }
  }

  /// Nakit işlem sayısını getirir
  Future<int> getCashTransactionsCount() async {
    try {
      final snapshot =
          await _firestore.collection('cash_transactions').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting cash transactions count', e);
      rethrow;
    }
  }

  /// Nakit işlem toplamını getirir
  Future<double> getCashTransactionsTotal({
    DateTime? startDate,
    DateTime? endDate,
    CashTransactionType? type,
  }) async {
    try {
      Query query = _firestore.collection('cash_transactions');

      if (startDate != null) {
        query = query.where('transactionDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('transactionDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query.get();
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting cash transactions total', e);
      rethrow;
    }
  }

  /// En çok kullanılan kategorileri getirir
  Future<List<Map<String, dynamic>>> getTopCategories({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('cash_transactions');

      if (startDate != null) {
        query = query.where('transactionDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('transactionDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final categoryStats = <String, Map<String, dynamic>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String;
        final amount = (data['amount'] as num).toDouble();

        if (categoryStats.containsKey(category)) {
          categoryStats[category]!['amount'] += amount;
          categoryStats[category]!['count'] += 1;
        } else {
          categoryStats[category] = {
            'category': category,
            'amount': amount,
            'count': 1,
          };
        }
      }

      final sortedCategories = categoryStats.values.toList()
        ..sort(
            (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

      return sortedCategories.take(limit).toList();
    } catch (e) {
      AppLogger.error('Error getting top categories', e);
      rethrow;
    }
  }

  /// En çok işlem yapılan hesapları getirir
  Future<List<Map<String, dynamic>>> getTopAccounts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('cash_transactions');

      if (startDate != null) {
        query = query.where('transactionDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('transactionDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final accountStats = <String, Map<String, dynamic>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final accountId = data['fromAccountId'] as String;
        final amount = (data['amount'] as num).toDouble();

        if (accountStats.containsKey(accountId)) {
          accountStats[accountId]!['amount'] += amount;
          accountStats[accountId]!['count'] += 1;
        } else {
          accountStats[accountId] = {
            'accountId': accountId,
            'amount': amount,
            'count': 1,
          };
        }
      }

      final sortedAccounts = accountStats.values.toList()
        ..sort(
            (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

      return sortedAccounts.take(limit).toList();
    } catch (e) {
      AppLogger.error('Error getting top accounts', e);
      rethrow;
    }
  }

  /// Nakit işlem istatistiklerini getirir
  Future<Map<String, dynamic>> getCashTransactionsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('cash_transactions');

      if (startDate != null) {
        query = query.where('transactionDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('transactionDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final stats = <String, dynamic>{
        'totalCount': snapshot.docs.length,
        'totalAmount': 0.0,
        'typeCounts': <String, int>{},
        'categoryCounts': <String, int>{},
        'statusCounts': <String, int>{},
      };

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] as num).toDouble();
        final type = data['type'] as String;
        final category = data['category'] as String;
        final status = data['status'] as String;

        stats['totalAmount'] = (stats['totalAmount'] as double) + amount;

        stats['typeCounts'][type] =
            (stats['typeCounts'][type] as int? ?? 0) + 1;
        stats['categoryCounts'][category] =
            (stats['categoryCounts'][category] as int? ?? 0) + 1;
        stats['statusCounts'][status] =
            (stats['statusCounts'][status] as int? ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      AppLogger.error('Error getting cash transactions statistics', e);
      rethrow;
    }
  }

  /// Nakit işlem numarası oluşturur
  Future<String> generateCashTransactionNumber(CashTransactionType type) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final prefix = type.name.toUpperCase();
      final datePrefix = '$year$month$day';

      // Bugünkü aynı tipte kaç tane işlem var?
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('cash_transactions')
          .where('type', isEqualTo: type.name)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();

      final count = snapshot.docs.length + 1;
      final number = count.toString().padLeft(4, '0');

      return '$prefix-$datePrefix-$number';
    } catch (e) {
      AppLogger.error('Error generating cash transaction number', e);
      rethrow;
    }
  }
}
