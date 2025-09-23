// ========== FIREBASE CUSTOMER REPOSITORY ==========
// lib/features/customers/data/repositories/firebase_customer_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/firebase_customer_entity.dart';
import 'package:tamgaci/core/services/business/transaction_service.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Firestore tabanlı müşteri repository implementasyonu
class FirebaseCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'customers';
  final TransactionService _transactionService = TransactionService();

  @override
  Future<String> createCustomer(Customer customer) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final customerEntity =
          FirebaseCustomerEntity.fromDomain(customer).copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(customerEntity.toFirestore());
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating customer', e);
      rethrow;
    }
  }

  @override
  Future<void> createCustomers(List<Customer> customers) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();
      for (final customer in customers) {
        final docRef = _firestore.collection(_collectionName).doc();
        final customerEntity =
            FirebaseCustomerEntity.fromDomain(customer).copyWith(
          id: docRef.id,
          createdAt: now,
          updatedAt: now,
        );
        batch.set(docRef, customerEntity.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      AppLogger.error('Error creating customers', e);
      rethrow;
    }
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    try {
      final querySnapshot =
          await _firestore.collection(_collectionName).orderBy('name').get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all customers', e);
      rethrow;
    }
  }

  @override
  Future<List<Customer>> getActiveCustomers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting active customers', e);
      rethrow;
    }
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(id).get();

      if (docSnapshot.exists) {
        return FirebaseCustomerEntity.fromFirestore(docSnapshot).toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting customer by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .where((customer) =>
              customer.isActive &&
              (customer.name.toLowerCase().contains(query.toLowerCase()) ||
                  (customer.email
                          ?.toLowerCase()
                          .contains(query.toLowerCase()) ??
                      true) ||
                  (customer.phone
                          ?.toLowerCase()
                          .contains(query.toLowerCase()) ??
                      true)))
          .toList();
    } catch (e) {
      AppLogger.error('Error searching customers', e);
      rethrow;
    }
  }

  @override
  Future<List<Customer>> getCustomersByType(CustomerType type) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .where(
              (customer) => customer.customerType == type && customer.isActive)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      AppLogger.error('Error getting customers by type', e);
      rethrow;
    }
  }

  @override
  Future<List<Customer>> getCustomersByCity(String city) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .where((customer) => customer.city == city && customer.isActive)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      AppLogger.error('Error getting customers by city', e);
      rethrow;
    }
  }

  @override
  Future<Customer?> getCustomerByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return FirebaseCustomerEntity.fromFirestore(querySnapshot.docs.first)
            .toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting customer by email', e);
      rethrow;
    }
  }

  @override
  Future<Customer?> getCustomerByPhone(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return FirebaseCustomerEntity.fromFirestore(querySnapshot.docs.first)
            .toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting customer by phone', e);
      rethrow;
    }
  }

  @override
  Future<Customer?> getCustomerByTaxNumber(String taxNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('taxNumber', isEqualTo: taxNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return FirebaseCustomerEntity.fromFirestore(querySnapshot.docs.first)
            .toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting customer by tax number', e);
      rethrow;
    }
  }

  @override
  Future<int> getTotalCustomerCount() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting total customer count', e);
      rethrow;
    }
  }

  @override
  Future<int> getActiveCustomerCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting active customer count', e);
      rethrow;
    }
  }

  @override
  Future<int> getInactiveCustomerCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: false)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting inactive customer count', e);
      rethrow;
    }
  }

  @override
  Future<List<Customer>> getRecentCustomers({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting recent customers', e);
      rethrow;
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(customer.id)
          .update(FirebaseCustomerEntity.fromDomain(customer).toFirestore());
    } catch (e) {
      AppLogger.error('Error updating customer', e);
      rethrow;
    }
  }

  @override
  Future<void> updateCustomerStatus(String id, bool isActive) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'isActive': isActive,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      AppLogger.error('Error updating customer status', e);
      rethrow;
    }
  }

  @override
  Future<void> updateCustomerBalance(String id, double newBalance) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'currentBalance': newBalance,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      AppLogger.info('Customer balance updated: $id, new balance: $newBalance');
    } catch (e) {
      AppLogger.error('Error updating customer balance', e);
      rethrow;
    }
  }

  @override
  Future<double> calculateCustomerBalance(String id) async {
    try {
      return await _transactionService.calculateCustomerBalance(id);
    } catch (e) {
      AppLogger.error('Error calculating customer balance', e);
      rethrow;
    }
  }

  @override
  Future<void> recalculateAllCustomerBalances() async {
    try {
      await _transactionService.recalculateAllCustomerBalances();
    } catch (e) {
      AppLogger.error('Error recalculating all customer balances', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      AppLogger.error('Error deleting customer', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteInactiveCustomers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      AppLogger.error('Error deleting inactive customers', e);
      rethrow;
    }
  }

  @override
  Stream<List<Customer>> watchAllCustomers() {
    return _firestore
        .collection(_collectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
            .toList());
  }

  @override
  Stream<List<Customer>> watchActiveCustomers() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
            .where((customer) => customer.isActive)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)));
  }

  @override
  Stream<List<Customer>> watchInactiveCustomers() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: false)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
            .toList());
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    return _firestore.collection(_collectionName).doc(id).snapshots().map(
        (doc) => doc.exists
            ? FirebaseCustomerEntity.fromFirestore(doc).toDomain()
            : null);
  }

  @override
  Stream<int> watchActiveCustomerCount() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Stream<int> watchInactiveCustomerCount() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<Map<CustomerType, int>> getCustomerTypeStats() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final Map<CustomerType, int> stats = {};
      for (final doc in querySnapshot.docs) {
        final customer = FirebaseCustomerEntity.fromFirestore(doc).toDomain();
        stats[customer.customerType] = (stats[customer.customerType] ?? 0) + 1;
      }
      return stats;
    } catch (e) {
      AppLogger.error('Error getting customer type stats', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getCustomerCityStats() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final Map<String, int> stats = {};
      for (final doc in querySnapshot.docs) {
        final customer = FirebaseCustomerEntity.fromFirestore(doc).toDomain();
        if (customer.city != null) {
          stats[customer.city!] = (stats[customer.city!] ?? 0) + 1;
        }
      }
      return stats;
    } catch (e) {
      AppLogger.error('Error getting customer city stats', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getMonthlyCustomerStats() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('createdAt', isGreaterThanOrEqualTo: startOfYear)
          .get();

      final Map<String, int> stats = {};
      for (int i = 1; i <= 12; i++) {
        stats['${now.year}-${i.toString().padLeft(2, '0')}'] = 0;
      }

      for (final doc in querySnapshot.docs) {
        final customer = FirebaseCustomerEntity.fromFirestore(doc).toDomain();
        final month =
            '${customer.createdAt.year}-${customer.createdAt.month.toString().padLeft(2, '0')}';
        stats[month] = (stats[month] ?? 0) + 1;
      }
      return stats;
    } catch (e) {
      AppLogger.error('Error getting monthly customer stats', e);
      rethrow;
    }
  }
}
