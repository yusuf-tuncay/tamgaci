import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import '../../domain/entities/account_transaction.dart';
import '../../domain/repositories/account_transaction_repository.dart';
import '../models/firebase_account_transaction_entity.dart';

/// Firebase Account Transaction Repository Implementation
class FirebaseAccountTransactionRepository
    implements AccountTransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tenant ID'yi al
  Future<String> _tenantId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final tenantId = userData['tenantId'] as String?;

    if (tenantId == null || tenantId.isEmpty) {
      throw Exception('User is not assigned to any tenant');
    }

    return tenantId;
  }

  /// User ID'yi al
  String? _uid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<List<AccountTransaction>> getTransactions() async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .orderBy('transactionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions', e);
      rethrow;
    }
  }

  @override
  Future<AccountTransaction?> getTransactionById(String id) async {
    try {
      final tenantId = await _tenantId();
      final doc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .doc(id)
          .get();

      if (!doc.exists) return null;

      return FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain();
    } catch (e) {
      AppLogger.error('Error getting transaction by id', e);
      rethrow;
    }
  }

  @override
  Future<List<AccountTransaction>> getTransactionsByAccountId(
      String accountId) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .where('accountId', isEqualTo: accountId)
          .orderBy('transactionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by account id', e);
      rethrow;
    }
  }

  @override
  Future<String> createTransaction(AccountTransaction transaction) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final transactionWithTenant = transaction.copyWith(tenantId: tenantId);
      final transactionEntity =
          FirebaseAccountTransactionEntity.fromDomain(transactionWithTenant);

      final docRef = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .add(transactionEntity.toFirestore());

      AppLogger.info('Transaction created successfully: ${transaction.id}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating transaction', e);
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(AccountTransaction transaction) async {
    try {
      final tenantId = await _tenantId();
      final transactionWithTenant = transaction.copyWith(tenantId: tenantId);
      final transactionEntity =
          FirebaseAccountTransactionEntity.fromDomain(transactionWithTenant);

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .doc(transaction.id)
          .update(transactionEntity.toFirestore());

      AppLogger.info('Transaction updated successfully: ${transaction.id}');
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
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .doc(id)
          .delete();

      AppLogger.info('Transaction deleted successfully: $id');
    } catch (e) {
      AppLogger.error('Error deleting transaction', e);
      rethrow;
    }
  }

  @override
  Future<List<AccountTransaction>> searchTransactions(String query) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .where('description', isGreaterThanOrEqualTo: query)
          .where('description', isLessThan: '${query}z')
          .get();

      return snapshot.docs
          .map((doc) =>
              FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error searching transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<AccountTransaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .where('transactionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('transactionDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('transactionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by date range', e);
      rethrow;
    }
  }

  @override
  Future<List<AccountTransaction>> getTransactionsByAccountAndDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .where('accountId', isEqualTo: accountId)
          .where('transactionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('transactionDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('transactionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting transactions by account and date range', e);
      rethrow;
    }
  }

  @override
  Future<List<AccountTransaction>> getTransactionsByCategory(
    TransactionCategory category,
  ) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .where('category', isEqualTo: category.name)
          .orderBy('transactionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by category', e);
      rethrow;
    }
  }

  @override
  Future<List<AccountTransaction>> getTransactionsByType(
    TransactionType type,
  ) async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .where('type', isEqualTo: type.name)
          .orderBy('transactionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by type', e);
      rethrow;
    }
  }

  @override
  Future<List<AccountTransaction>> getUnreconciledTransactions() async {
    try {
      final tenantId = await _tenantId();
      final snapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .where('isReconciled', isEqualTo: false)
          .orderBy('transactionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              FirebaseAccountTransactionEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting unreconciled transactions', e);
      rethrow;
    }
  }

  @override
  Future<void> updateTransactionReconciliation(
    String transactionId,
    bool isReconciled,
    String reconciledBy,
  ) async {
    try {
      final tenantId = await _tenantId();
      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('accountTransactions')
          .doc(transactionId)
          .update({
        'isReconciled': isReconciled,
        'reconciledAt': isReconciled ? FieldValue.serverTimestamp() : null,
        'reconciledBy': reconciledBy,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid() ?? 'system',
      });

      AppLogger.info(
          'Transaction reconciliation updated: $transactionId -> $isReconciled');
    } catch (e) {
      AppLogger.error('Error updating transaction reconciliation', e);
      rethrow;
    }
  }
}
