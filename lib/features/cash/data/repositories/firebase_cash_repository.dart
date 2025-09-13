// ========== FIREBASE CASH REPOSITORY ==========
// lib/features/cash/data/repositories/firebase_cash_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cash_transaction.dart';
import '../../domain/repositories/cash_repository.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Firestore tabanlı nakit repository implementasyonu
class FirebaseCashRepository implements CashRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'cash_transactions';

  // ========== CASH TRANSACTION OPERATIONS ==========

  @override
  Future<String> createCashTransaction(CashTransaction transaction) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final transactionData =
          _transactionToMap(transaction.copyWith(id: docRef.id));
      await docRef.set(transactionData);
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating cash transaction', e);
      rethrow;
    }
  }

  @override
  Future<void> updateCashTransaction(CashTransaction transaction) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(transaction.id)
          .update(_transactionToMap(transaction));
    } catch (e) {
      AppLogger.error('Error updating cash transaction', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCashTransaction(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      AppLogger.error('Error deleting cash transaction', e);
      rethrow;
    }
  }

  @override
  Future<CashTransaction?> getCashTransactionById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(id).get();
      if (!docSnapshot.exists) return null;
      return _transactionFromMap(docSnapshot);
    } catch (e) {
      AppLogger.error('Error getting cash transaction by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<CashTransaction>> getAllCashTransactions() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('transactionDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _transactionFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting all cash transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<CashTransaction>> getCashTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('transactionDate', isGreaterThanOrEqualTo: startDate)
          .where('transactionDate', isLessThanOrEqualTo: endDate)
          .orderBy('transactionDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _transactionFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting cash transactions by date range', e);
      rethrow;
    }
  }

  @override
  Future<List<CashTransaction>> getCashTransactionsByType(
      CashTransactionType type) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => _transactionFromMap(doc))
          .where((transaction) => transaction.type == type)
          .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    } catch (e) {
      AppLogger.error('Error getting cash transactions by type', e);
      rethrow;
    }
  }

  @override
  Future<List<CashTransaction>> getCashTransactionsByCategory(
      String category) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => _transactionFromMap(doc))
          .where((transaction) => transaction.category == category)
          .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    } catch (e) {
      AppLogger.error('Error getting cash transactions by category', e);
      rethrow;
    }
  }

  @override
  Future<List<CashTransaction>> getRecentCashTransactions(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('transactionDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => _transactionFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting recent cash transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<CashTransaction>> searchCashTransactions(String query) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      final lowercaseQuery = query.toLowerCase();
      return querySnapshot.docs
          .map((doc) => _transactionFromMap(doc))
          .where((transaction) =>
              transaction.title.toLowerCase().contains(lowercaseQuery) ||
              transaction.description.toLowerCase().contains(lowercaseQuery) ||
              (transaction.notes?.toLowerCase().contains(lowercaseQuery) ??
                  false))
          .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    } catch (e) {
      AppLogger.error('Error searching cash transactions', e);
      rethrow;
    }
  }

  @override
  Future<double> getTotalCashBalance() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      final transactions =
          querySnapshot.docs.map((doc) => _transactionFromMap(doc)).toList();

      double balance = 0.0;
      for (final transaction in transactions) {
        if (transaction.type == CashTransactionType.income) {
          balance += transaction.amount;
        } else if (transaction.type == CashTransactionType.expense) {
          balance -= transaction.amount;
        }
      }
      return balance;
    } catch (e) {
      AppLogger.error('Error getting total cash balance', e);
      rethrow;
    }
  }

  @override
  Future<double> getTotalIncomeByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('transactionDate', isGreaterThanOrEqualTo: startDate)
          .where('transactionDate', isLessThanOrEqualTo: endDate)
          .get();

      final transactions =
          querySnapshot.docs.map((doc) => _transactionFromMap(doc)).toList();
      double total = 0.0;
      for (final transaction in transactions) {
        if (transaction.type == CashTransactionType.income) {
          total += transaction.amount;
        }
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting total income by date range', e);
      rethrow;
    }
  }

  @override
  Future<double> getTotalExpenseByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('transactionDate', isGreaterThanOrEqualTo: startDate)
          .where('transactionDate', isLessThanOrEqualTo: endDate)
          .get();

      final transactions =
          querySnapshot.docs.map((doc) => _transactionFromMap(doc)).toList();
      double total = 0.0;
      for (final transaction in transactions) {
        if (transaction.type == CashTransactionType.expense) {
          total += transaction.amount;
        }
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting total expense by date range', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCashStatistics() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      final transactions =
          querySnapshot.docs.map((doc) => _transactionFromMap(doc)).toList();

      final totalIncome = transactions
          .where((t) => t.type == CashTransactionType.income)
          .fold(0.0, (total, t) => total + t.amount);

      final totalExpense = transactions
          .where((t) => t.type == CashTransactionType.expense)
          .fold(0.0, (total, t) => total + t.amount);

      final totalTransfer = transactions
          .where((t) => t.type == CashTransactionType.transfer)
          .fold(0.0, (total, t) => total + t.amount);

      final balance = totalIncome - totalExpense;

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'totalTransfer': totalTransfer,
        'balance': balance,
        'transactionCount': transactions.length,
        'incomeCount': transactions
            .where((t) => t.type == CashTransactionType.income)
            .length,
        'expenseCount': transactions
            .where((t) => t.type == CashTransactionType.expense)
            .length,
        'transferCount': transactions
            .where((t) => t.type == CashTransactionType.transfer)
            .length,
      };
    } catch (e) {
      AppLogger.error('Error getting cash statistics', e);
      rethrow;
    }
  }

  // ========== STREAM OPERATIONS ==========

  @override
  Stream<CashTransaction?> watchCashTransactionById(String id) {
    return _firestore
        .collection(_collectionName)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? _transactionFromMap(doc) : null);
  }

  @override
  Stream<List<CashTransaction>> watchAllCashTransactions() {
    return _firestore
        .collection(_collectionName)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _transactionFromMap(doc)).toList());
  }

  @override
  Stream<List<CashTransaction>> watchCashTransactionsByDateRange(
      DateTime startDate, DateTime endDate) {
    return _firestore
        .collection(_collectionName)
        .where('transactionDate', isGreaterThanOrEqualTo: startDate)
        .where('transactionDate', isLessThanOrEqualTo: endDate)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _transactionFromMap(doc)).toList());
  }

  @override
  Stream<List<CashTransaction>> watchCashTransactionsByType(
      CashTransactionType type) {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => _transactionFromMap(doc))
            .where((transaction) => transaction.type == type)
            .toList()
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate)));
  }

  // Helper methods for data conversion
  Map<String, dynamic> _transactionToMap(CashTransaction transaction) {
    return {
      'id': transaction.id,
      'title': transaction.title,
      'description': transaction.description,
      'amount': transaction.amount,
      'currency': transaction.currency,
      'type': transaction.type.name,
      'category': transaction.category,
      'transactionDate': transaction.transactionDate,
      'referenceNumber': transaction.referenceNumber,
      'notes': transaction.notes,
      'createdAt': transaction.createdAt,
      'updatedAt': transaction.updatedAt,
    };
  }

  CashTransaction _transactionFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CashTransaction(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      type: CashTransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CashTransactionType.income,
      ),
      category: data['category'] ?? '',
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      referenceNumber: data['referenceNumber'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
