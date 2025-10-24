// ========== SIMPLE PAYMENT TRANSACTION REPOSITORY ==========
// lib/features/payment_collection/data/repositories/simple_payment_transaction_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_transaction.dart';
import '../../domain/entities/payment_enums.dart';
import '../../domain/repositories/payment_transaction_repository.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Basit PaymentTransaction repository - sadece temel CRUD operasyonları
class SimplePaymentTransactionRepository
    implements PaymentTransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCollectionPath(String tenantId) =>
      'tenants/$tenantId/payment_transactions';

  Future<String> _tenantId() async {
    // Basit tenant ID - gerçek implementasyonda auth'dan gelecek
    return 'default_tenant';
  }

  @override
  Future<List<PaymentTransaction>> getAllTransactions({
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore.collection(_getCollectionPath(actualTenantId));

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions', e);
      rethrow;
    }
  }

  @override
  Future<PaymentTransaction?> getTransactionById(String id) async {
    try {
      final tenantId = await _tenantId();
      final doc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (!doc.exists) return null;
      return _fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      AppLogger.error('Error getting transaction by id', e);
      rethrow;
    }
  }

  @override
  Future<PaymentTransaction> createTransaction(
      PaymentTransaction transaction) async {
    try {
      final tenantId = await _tenantId();
      final docRef = _firestore.collection(_getCollectionPath(tenantId)).doc();

      final transactionData = _toFirestore(transaction);
      transactionData['id'] = docRef.id;
      transactionData['transactionNumber'] =
          'TXN-${DateTime.now().millisecondsSinceEpoch}';

      await docRef.set(transactionData);

      return _fromFirestore(transactionData, docRef.id);
    } catch (e) {
      AppLogger.error('Error creating transaction', e);
      rethrow;
    }
  }

  @override
  Future<PaymentTransaction> updateTransaction(
      PaymentTransaction transaction) async {
    try {
      final tenantId = await _tenantId();
      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(transaction.id)
          .update(_toFirestore(transaction));

      return transaction;
    } catch (e) {
      AppLogger.error('Error updating transaction', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final tenantId = await _tenantId();
      await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .delete();
    } catch (e) {
      AppLogger.error('Error deleting transaction', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDailySummary(DateTime date,
      {String? companyId, String? tenantId}) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('transactionDate', isGreaterThanOrEqualTo: startOfDay)
          .where('transactionDate', isLessThan: endOfDay);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      final snapshot = await query.get();
      final transactions = snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      double totalIncoming = 0;
      double totalOutgoing = 0;
      int transactionCount = transactions.length;

      for (final transaction in transactions) {
        if (transaction.direction == PaymentDirection.incoming) {
          totalIncoming += transaction.amount;
        } else {
          totalOutgoing += transaction.amount;
        }
      }

      return {
        'date': date.toIso8601String(),
        'totalIncoming': totalIncoming,
        'totalOutgoing': totalOutgoing,
        'netAmount': totalIncoming - totalOutgoing,
        'transactionCount': transactionCount,
      };
    } catch (e) {
      AppLogger.error('Error getting daily summary', e);
      rethrow;
    }
  }

  // Diğer metodlar için basit implementasyon
  // Bu methodlar aşağıda implement edildi

  // Bu methodlar aşağıda implement edildi

  // Bu methodlar aşağıda implement edildi

  // Bu methodlar aşağıda implement edildi

  @override
  Future<PaymentTransaction> duplicateTransaction(
      String id, String duplicatedBy) async {
    try {
      final originalTransaction = await getTransactionById(id);
      if (originalTransaction == null) {
        throw Exception('Transaction not found');
      }

      final duplicatedTransaction = originalTransaction.copyWith(
        id: '', // Yeni ID oluşturulacak
        transactionNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        createdBy: duplicatedBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        updatedBy: duplicatedBy,
      );

      return await createTransaction(duplicatedTransaction);
    } catch (e) {
      AppLogger.error('Error duplicating transaction', e);
      rethrow;
    }
  }

  @override
  Future<String> exportTransactionsToCSV({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? accountId,
    String? currency,
  }) async {
    try {
      final transactions = await getAllTransactions(
        companyId: companyId,
        tenantId: tenantId,
      );

      // Basit filtreleme
      var filteredTransactions = transactions;
      if (startDate != null && endDate != null) {
        filteredTransactions = transactions
            .where((t) =>
                t.transactionDate.isAfter(startDate) &&
                t.transactionDate.isBefore(endDate))
            .toList();
      }

      final csv = StringBuffer();
      csv.writeln(
          'ID,Transaction Number,Type,Category,Status,Direction,Amount,Currency,Date,Description');

      for (final transaction in filteredTransactions) {
        csv.writeln(
            '${transaction.id},${transaction.transactionNumber},${transaction.type.name},${transaction.category.name},${transaction.status.name},${transaction.direction.name},${transaction.amount},${transaction.currency},${transaction.transactionDate.toIso8601String()},${transaction.description ?? ''}');
      }

      return csv.toString();
    } catch (e) {
      AppLogger.error('Error exporting transactions to CSV', e);
      rethrow;
    }
  }

  @override
  Future<String> exportTransactionsToExcel({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? accountId,
    String? currency,
  }) async {
    // Excel export için basit implementasyon
    return await exportTransactionsToCSV(
      companyId: companyId,
      tenantId: tenantId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      category: category,
      status: status,
      direction: direction,
      customerId: customerId,
      supplierId: supplierId,
      accountId: accountId,
      currency: currency,
    );
  }

  @override
  Future<String> generateTransactionNumber({
    PaymentTransactionType? type,
    String? companyId,
    String? tenantId,
  }) async {
    return 'TXN-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Bu methodlar yukarıda implement edildi

  // Interface'de tanımlı olan eksik methodlar

  @override
  Future<PaymentTransaction?> getTransactionByNumber(
      String transactionNumber) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection(_getCollectionPath(tenantId))
          .where('transactionNumber', isEqualTo: transactionNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return _fromFirestore(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting transaction by number', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getCustomerTransactions(
    String customerId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('customerId', isEqualTo: customerId);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting customer transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getSupplierTransactions(
    String supplierId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('supplierId', isEqualTo: supplierId);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting supplier transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('transactionDate', isGreaterThanOrEqualTo: startDate)
          .where('transactionDate', isLessThanOrEqualTo: endDate);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by date range', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getTransactionsByType(
    PaymentTransactionType type, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('type', isEqualTo: type.name);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by type', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getTransactionsByCategory(
    PaymentTransactionCategory category, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('category', isEqualTo: category.name);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by category', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getTransactionsByStatus(
    PaymentTransactionStatus status, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('status', isEqualTo: status.name);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by status', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getTransactionsByDirection(
    PaymentDirection direction, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('direction', isEqualTo: direction.name);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by direction', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getAccountTransactions(
    String accountId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('accountId', isEqualTo: accountId);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting account transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getRevenueTransactions(
    String revenueId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('revenueId', isEqualTo: revenueId);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting revenue transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getExpenseTransactions(
    String expenseId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('expenseId', isEqualTo: expenseId);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting expense transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getPaymentMethodTransactions(
    String paymentMethodId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('paymentMethodId', isEqualTo: paymentMethodId);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting payment method transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getPaymentSourceTransactions(
    String paymentSourceId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('paymentSourceId', isEqualTo: paymentSourceId);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting payment source transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getPendingTransactions({
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('status', isEqualTo: PaymentTransactionStatus.pending.name);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting pending transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getOverdueTransactions({
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      final now = DateTime.now();
      Query query = _firestore
          .collection(_getCollectionPath(actualTenantId))
          .where('dueDate', isLessThan: now)
          .where('status', isEqualTo: PaymentTransactionStatus.pending.name);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting overdue transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> searchTransactions(
    String query, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query firestoreQuery =
          _firestore.collection(_getCollectionPath(actualTenantId));

      if (companyId != null) {
        firestoreQuery =
            firestoreQuery.where('companyId', isEqualTo: companyId);
      }

      if (limit != null) {
        firestoreQuery = firestoreQuery.limit(limit);
      }

      final snapshot = await firestoreQuery.get();
      final allTransactions = snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Client-side filtering
      return allTransactions.where((transaction) {
        final searchLower = query.toLowerCase();
        return transaction.description?.toLowerCase().contains(searchLower) ==
                true ||
            transaction.referenceNumber?.toLowerCase().contains(searchLower) ==
                true ||
            transaction.transactionNumber.toLowerCase().contains(searchLower) ==
                true;
      }).toList();
    } catch (e) {
      AppLogger.error('Error searching transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> getFilteredTransactions({
    String? companyId,
    String? tenantId,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? currency,
    int? limit,
    int? offset,
  }) async {
    try {
      final actualTenantId = tenantId ?? await _tenantId();
      Query query = _firestore.collection(_getCollectionPath(actualTenantId));

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      if (direction != null) {
        query = query.where('direction', isEqualTo: direction.name);
      }
      if (customerId != null) {
        query = query.where('customerId', isEqualTo: customerId);
      }
      if (supplierId != null) {
        query = query.where('supplierId', isEqualTo: supplierId);
      }
      if (revenueId != null) {
        query = query.where('revenueId', isEqualTo: revenueId);
      }
      if (expenseId != null) {
        query = query.where('expenseId', isEqualTo: expenseId);
      }
      if (accountId != null) {
        query = query.where('accountId', isEqualTo: accountId);
      }
      if (paymentMethodId != null) {
        query = query.where('paymentMethodId', isEqualTo: paymentMethodId);
      }
      if (paymentSourceId != null) {
        query = query.where('paymentSourceId', isEqualTo: paymentSourceId);
      }
      if (startDate != null) {
        query =
            query.where('transactionDate', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('transactionDate', isLessThanOrEqualTo: endDate);
      }
      if (currency != null) {
        query = query.where('currency', isEqualTo: currency);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      var transactions = snapshot.docs
          .map((doc) =>
              _fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Amount filtering (client-side)
      if (minAmount != null) {
        transactions =
            transactions.where((t) => t.amount >= minAmount).toList();
      }
      if (maxAmount != null) {
        transactions =
            transactions.where((t) => t.amount <= maxAmount).toList();
      }

      return transactions;
    } catch (e) {
      AppLogger.error('Error getting filtered transactions', e);
      rethrow;
    }
  }

  @override
  Future<PaymentTransaction> updateTransactionStatus(
      String id, PaymentTransactionStatus status) async {
    try {
      final tenantId = await _tenantId();
      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(
            updatedDoc.data() as Map<String, dynamic>, updatedDoc.id);
      } else {
        throw Exception('Transaction not found after update');
      }
    } catch (e) {
      AppLogger.error('Error updating transaction status', e);
      rethrow;
    }
  }

  @override
  Future<double> calculateTotalAmount({
    String? companyId,
    String? tenantId,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
  }) async {
    try {
      final transactions = await getFilteredTransactions(
        companyId: companyId,
        tenantId: tenantId,
        type: type,
        category: category,
        status: status,
        direction: direction,
        customerId: customerId,
        supplierId: supplierId,
        revenueId: revenueId,
        expenseId: expenseId,
        accountId: accountId,
        paymentMethodId: paymentMethodId,
        paymentSourceId: paymentSourceId,
        startDate: startDate,
        endDate: endDate,
        currency: currency,
      );

      return transactions.fold<double>(
          0.0, (total, transaction) => total + transaction.amount);
    } catch (e) {
      AppLogger.error('Error calculating total amount', e);
      rethrow;
    }
  }

  @override
  Future<int> getTransactionCount({
    String? companyId,
    String? tenantId,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
  }) async {
    try {
      final transactions = await getFilteredTransactions(
        companyId: companyId,
        tenantId: tenantId,
        type: type,
        category: category,
        status: status,
        direction: direction,
        customerId: customerId,
        supplierId: supplierId,
        revenueId: revenueId,
        expenseId: expenseId,
        accountId: accountId,
        paymentMethodId: paymentMethodId,
        paymentSourceId: paymentSourceId,
        startDate: startDate,
        endDate: endDate,
        currency: currency,
      );

      return transactions.length;
    } catch (e) {
      AppLogger.error('Error getting transaction count', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getMonthlySummary(
    int year,
    int month, {
    String? companyId,
    String? tenantId,
  }) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final transactions = await getTransactionsByDateRange(startDate, endDate,
          companyId: companyId, tenantId: tenantId);

      double totalIncoming = 0.0;
      double totalOutgoing = 0.0;
      int transactionCount = transactions.length;

      for (final transaction in transactions) {
        if (transaction.direction == PaymentDirection.incoming) {
          totalIncoming += transaction.amount;
        } else {
          totalOutgoing += transaction.amount;
        }
      }

      return {
        'year': year,
        'month': month,
        'totalIncoming': totalIncoming,
        'totalOutgoing': totalOutgoing,
        'netAmount': totalIncoming - totalOutgoing,
        'transactionCount': transactionCount,
      };
    } catch (e) {
      AppLogger.error('Error getting monthly summary', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getYearlySummary(
    int year, {
    String? companyId,
    String? tenantId,
  }) async {
    try {
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year + 1, 1, 1);

      final transactions = await getTransactionsByDateRange(startDate, endDate,
          companyId: companyId, tenantId: tenantId);

      double totalIncoming = 0.0;
      double totalOutgoing = 0.0;
      int transactionCount = transactions.length;

      for (final transaction in transactions) {
        if (transaction.direction == PaymentDirection.incoming) {
          totalIncoming += transaction.amount;
        } else {
          totalOutgoing += transaction.amount;
        }
      }

      return {
        'year': year,
        'totalIncoming': totalIncoming,
        'totalOutgoing': totalOutgoing,
        'netAmount': totalIncoming - totalOutgoing,
        'transactionCount': transactionCount,
      };
    } catch (e) {
      AppLogger.error('Error getting yearly summary', e);
      rethrow;
    }
  }

  // Diğer eksik methodlar için basit implementasyonlar

  @override
  Future<Map<String, dynamic>> getCustomerBalanceSummary(
    String customerId, {
    String? companyId,
    String? tenantId,
  }) async {
    try {
      final transactions = await getCustomerTransactions(customerId,
          companyId: companyId, tenantId: tenantId);

      double totalIncoming = 0.0;
      double totalOutgoing = 0.0;

      for (final transaction in transactions) {
        if (transaction.direction == PaymentDirection.incoming) {
          totalIncoming += transaction.amount;
        } else {
          totalOutgoing += transaction.amount;
        }
      }

      return {
        'customerId': customerId,
        'totalIncoming': totalIncoming,
        'totalOutgoing': totalOutgoing,
        'balance': totalIncoming - totalOutgoing,
        'transactionCount': transactions.length,
      };
    } catch (e) {
      AppLogger.error('Error getting customer balance summary', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getSupplierBalanceSummary(
    String supplierId, {
    String? companyId,
    String? tenantId,
  }) async {
    try {
      final transactions = await getSupplierTransactions(supplierId,
          companyId: companyId, tenantId: tenantId);

      double totalIncoming = 0.0;
      double totalOutgoing = 0.0;

      for (final transaction in transactions) {
        if (transaction.direction == PaymentDirection.incoming) {
          totalIncoming += transaction.amount;
        } else {
          totalOutgoing += transaction.amount;
        }
      }

      return {
        'supplierId': supplierId,
        'totalIncoming': totalIncoming,
        'totalOutgoing': totalOutgoing,
        'balance': totalIncoming - totalOutgoing,
        'transactionCount': transactions.length,
      };
    } catch (e) {
      AppLogger.error('Error getting supplier balance summary', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAccountBalanceSummary(
    String accountId, {
    String? companyId,
    String? tenantId,
  }) async {
    try {
      final transactions = await getAccountTransactions(accountId,
          companyId: companyId, tenantId: tenantId);

      double totalIncoming = 0.0;
      double totalOutgoing = 0.0;

      for (final transaction in transactions) {
        if (transaction.direction == PaymentDirection.incoming) {
          totalIncoming += transaction.amount;
        } else {
          totalOutgoing += transaction.amount;
        }
      }

      return {
        'accountId': accountId,
        'totalIncoming': totalIncoming,
        'totalOutgoing': totalOutgoing,
        'balance': totalIncoming - totalOutgoing,
        'transactionCount': transactions.length,
      };
    } catch (e) {
      AppLogger.error('Error getting account balance summary', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactionStatistics({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await getFilteredTransactions(
        companyId: companyId,
        tenantId: tenantId,
        startDate: startDate,
        endDate: endDate,
      );

      double totalAmount = 0.0;
      int totalCount = transactions.length;
      Map<String, int> statusCounts = {};
      Map<String, int> typeCounts = {};

      for (final transaction in transactions) {
        totalAmount += transaction.amount;
        statusCounts[transaction.status.name] =
            (statusCounts[transaction.status.name] ?? 0) + 1;
        typeCounts[transaction.type.name] =
            (typeCounts[transaction.type.name] ?? 0) + 1;
      }

      return {
        'totalAmount': totalAmount,
        'totalCount': totalCount,
        'statusCounts': statusCounts,
        'typeCounts': typeCounts,
        'averageAmount': totalCount > 0 ? totalAmount / totalCount : 0.0,
      };
    } catch (e) {
      AppLogger.error('Error getting transaction statistics', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getReportData({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? accountId,
    String? currency,
  }) async {
    try {
      final transactions = await getFilteredTransactions(
        companyId: companyId,
        tenantId: tenantId,
        type: type,
        category: category,
        status: status,
        direction: direction,
        customerId: customerId,
        supplierId: supplierId,
        accountId: accountId,
        currency: currency,
        startDate: startDate,
        endDate: endDate,
      );

      double totalAmount = 0.0;
      Map<String, double> currencyTotals = {};
      Map<String, int> statusCounts = {};

      for (final transaction in transactions) {
        totalAmount += transaction.amount;
        currencyTotals[transaction.currency] =
            (currencyTotals[transaction.currency] ?? 0.0) + transaction.amount;
        statusCounts[transaction.status.name] =
            (statusCounts[transaction.status.name] ?? 0) + 1;
      }

      return {
        'totalAmount': totalAmount,
        'transactionCount': transactions.length,
        'currencyTotals': currencyTotals,
        'statusCounts': statusCounts,
        'transactions': transactions
            .map((t) => {
                  'id': t.id,
                  'transactionNumber': t.transactionNumber,
                  'amount': t.amount,
                  'currency': t.currency,
                  'status': t.status.name,
                  'date': t.transactionDate.toIso8601String(),
                })
            .toList(),
      };
    } catch (e) {
      AppLogger.error('Error getting report data', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> createBulkTransactions(
      List<PaymentTransaction> transactions) async {
    try {
      final results = <PaymentTransaction>[];
      for (final transaction in transactions) {
        final created = await createTransaction(transaction);
        results.add(created);
      }
      return results;
    } catch (e) {
      AppLogger.error('Error creating bulk transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<PaymentTransaction>> updateBulkTransactions(
      List<PaymentTransaction> transactions) async {
    try {
      final results = <PaymentTransaction>[];
      for (final transaction in transactions) {
        final updated = await updateTransaction(transaction);
        results.add(updated);
      }
      return results;
    } catch (e) {
      AppLogger.error('Error updating bulk transactions', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteBulkTransactions(List<String> ids) async {
    try {
      for (final id in ids) {
        await deleteTransaction(id);
      }
    } catch (e) {
      AppLogger.error('Error deleting bulk transactions', e);
      rethrow;
    }
  }

  @override
  Future<bool> validateTransaction(PaymentTransaction transaction) async {
    try {
      if (transaction.amount <= 0) return false;
      if (transaction.transactionNumber.isEmpty) return false;
      if (transaction.currency.isEmpty) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<PaymentTransaction> approveTransaction(
      String id, String approvedBy) async {
    try {
      final tenantId = await _tenantId();
      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'status': PaymentTransactionStatus.approved.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': approvedBy,
        'approvedBy': approvedBy,
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(
            updatedDoc.data() as Map<String, dynamic>, updatedDoc.id);
      } else {
        throw Exception('Transaction not found after update');
      }
    } catch (e) {
      AppLogger.error('Error approving transaction', e);
      rethrow;
    }
  }

  @override
  Future<PaymentTransaction> rejectTransaction(
      String id, String rejectedBy, String reason) async {
    try {
      final tenantId = await _tenantId();
      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'status': PaymentTransactionStatus.rejected.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': rejectedBy,
        'rejectionReason': reason,
        'rejectedBy': rejectedBy,
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(
            updatedDoc.data() as Map<String, dynamic>, updatedDoc.id);
      } else {
        throw Exception('Transaction not found after update');
      }
    } catch (e) {
      AppLogger.error('Error rejecting transaction', e);
      rethrow;
    }
  }

  @override
  Future<PaymentTransaction> cancelTransaction(
      String id, String cancelledBy, String reason) async {
    try {
      final tenantId = await _tenantId();
      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'status': PaymentTransactionStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': cancelledBy,
        'cancellationReason': reason,
        'cancelledBy': cancelledBy,
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(
            updatedDoc.data() as Map<String, dynamic>, updatedDoc.id);
      } else {
        throw Exception('Transaction not found after update');
      }
    } catch (e) {
      AppLogger.error('Error cancelling transaction', e);
      rethrow;
    }
  }

  @override
  Future<PaymentTransaction> reverseTransaction(
      String id, String reversedBy, String reason) async {
    try {
      final tenantId = await _tenantId();
      await _firestore.collection(_getCollectionPath(tenantId)).doc(id).update({
        'status': PaymentTransactionStatus.reversed.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': reversedBy,
        'reversalReason': reason,
        'reversedBy': reversedBy,
      });

      final updatedDoc = await _firestore
          .collection(_getCollectionPath(tenantId))
          .doc(id)
          .get();

      if (updatedDoc.exists) {
        return _fromFirestore(
            updatedDoc.data() as Map<String, dynamic>, updatedDoc.id);
      } else {
        throw Exception('Transaction not found after update');
      }
    } catch (e) {
      AppLogger.error('Error reversing transaction', e);
      rethrow;
    }
  }

  @override
  Future<String> printTransaction(String id) async {
    try {
      final transaction = await getTransactionById(id);
      if (transaction == null) {
        throw Exception('Transaction not found');
      }

      return 'Transaction Print: ${transaction.transactionNumber}';
    } catch (e) {
      AppLogger.error('Error printing transaction', e);
      rethrow;
    }
  }

  @override
  Future<String> generateTransactionPDF(String id) async {
    try {
      final transaction = await getTransactionById(id);
      if (transaction == null) {
        throw Exception('Transaction not found');
      }

      return 'Transaction PDF: ${transaction.transactionNumber}';
    } catch (e) {
      AppLogger.error('Error generating transaction PDF', e);
      rethrow;
    }
  }

  PaymentTransaction _fromFirestore(Map<String, dynamic> data, String id) {
    return PaymentTransaction(
      id: id,
      transactionNumber: data['transactionNumber'] as String? ?? '',
      type: PaymentTransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PaymentTransactionType.cash,
      ),
      category: PaymentTransactionCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => PaymentTransactionCategory.customerPayment,
      ),
      status: PaymentTransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PaymentTransactionStatus.pending,
      ),
      direction: PaymentDirection.values.firstWhere(
        (e) => e.name == data['direction'],
        orElse: () => PaymentDirection.incoming,
      ),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'TRY',
      transactionDate:
          (data['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      description: data['description'] as String?,
      referenceNumber: data['referenceNumber'] as String?,
      notes: data['notes'] as String?,
      customerId: data['customerId'] as String?,
      supplierId: data['supplierId'] as String?,
      revenueId: data['revenueId'] as String?,
      expenseId: data['expenseId'] as String?,
      accountId: data['accountId'] as String? ?? '',
      targetAccountId: data['targetAccountId'] as String?,
      paymentMethodId: data['paymentMethodId'] as String? ?? '',
      paymentSourceId: data['paymentSourceId'] as String?,
      relatedDocumentId: data['relatedDocumentId'] as String?,
      relatedDocumentType: data['relatedDocumentType'] as String?,
      attachments: List<String>.from(data['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      companyId: data['companyId'] as String? ?? '',
      tenantId: data['tenantId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      updatedBy: data['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> _toFirestore(PaymentTransaction transaction) {
    return {
      'transactionNumber': transaction.transactionNumber,
      'type': transaction.type.name,
      'category': transaction.category.name,
      'status': transaction.status.name,
      'direction': transaction.direction.name,
      'amount': transaction.amount,
      'currency': transaction.currency,
      'transactionDate': Timestamp.fromDate(transaction.transactionDate),
      'dueDate': transaction.dueDate != null
          ? Timestamp.fromDate(transaction.dueDate!)
          : null,
      'description': transaction.description,
      'referenceNumber': transaction.referenceNumber,
      'notes': transaction.notes,
      'customerId': transaction.customerId,
      'supplierId': transaction.supplierId,
      'revenueId': transaction.revenueId,
      'expenseId': transaction.expenseId,
      'accountId': transaction.accountId,
      'targetAccountId': transaction.targetAccountId,
      'paymentMethodId': transaction.paymentMethodId,
      'paymentSourceId': transaction.paymentSourceId,
      'relatedDocumentId': transaction.relatedDocumentId,
      'relatedDocumentType': transaction.relatedDocumentType,
      'attachments': transaction.attachments,
      'metadata': transaction.metadata,
      'companyId': transaction.companyId,
      'tenantId': transaction.tenantId,
      'isActive': transaction.isActive,
      'createdAt': Timestamp.fromDate(transaction.createdAt),
      'updatedAt': Timestamp.fromDate(transaction.updatedAt),
      'createdBy': transaction.createdBy,
      'updatedBy': transaction.updatedBy,
    };
  }
}
