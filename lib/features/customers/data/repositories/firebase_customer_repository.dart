// ========== FIREBASE CUSTOMER REPOSITORY - TENANT BASED ==========
// lib/features/customers/data/repositories/firebase_customer_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/firebase_customer_entity.dart';
import 'package:tamgaci/core/services/business/transaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Firestore tabanlı müşteri repository implementasyonu - Multi-tenant
class FirebaseCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();

  String? _uid() {
    try {
      return firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<String> _tenantId() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return '';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['tenantId'] as String? ?? '';
      }
      return '';
    } catch (e) {
      AppLogger.error('Error getting tenant ID', e);
      return '';
    }
  }

  @override
  Future<String> createCustomer(Customer customer) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc();
      final now = DateTime.now();
      final customerEntity =
          FirebaseCustomerEntity.fromDomain(customer).copyWith(
        id: docRef.id,
        createdAt: now,
        updatedAt: now,
        companyId: tenantId,
        createdBy: _uid(),
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
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      for (final customer in customers) {
        final docRef = _firestore
            .collection('tenants')
            .doc(tenantId)
            .collection('customers')
            .doc();
        final customerEntity =
            FirebaseCustomerEntity.fromDomain(customer).copyWith(
          id: docRef.id,
          createdAt: now,
          updatedAt: now,
          companyId: tenantId,
          createdBy: _uid(),
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
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all customers', e);
      return [];
    }
  }

  @override
  Future<List<Customer>> getActiveCustomers() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting active customers', e);
      return [];
    }
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final docSnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc(id)
          .get();

      if (docSnapshot.exists) {
        return FirebaseCustomerEntity.fromFirestore(docSnapshot).toDomain();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting customer by ID', e);
      return null;
    }
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error searching customers', e);
      return [];
    }
  }

  @override
  Future<List<Customer>> getCustomersByType(CustomerType type) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('type', isEqualTo: type.name)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting customers by type', e);
      return [];
    }
  }

  @override
  Future<List<Customer>> getCustomersByCity(String city) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('city', isEqualTo: city)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting customers by city', e);
      return [];
    }
  }

  @override
  Future<Customer?> getCustomerByEmail(String email) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
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
      return null;
    }
  }

  @override
  Future<Customer?> getCustomerByPhone(String phone) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
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
      return null;
    }
  }

  @override
  Future<Customer?> getCustomerByTaxNumber(String taxNumber) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
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
      return null;
    }
  }

  @override
  Future<int> getTotalCustomerCount() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting total customer count', e);
      return 0;
    }
  }

  @override
  Future<int> getActiveCustomerCount() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting active customer count', e);
      return 0;
    }
  }

  @override
  Future<int> getInactiveCustomerCount() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('isActive', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting inactive customer count', e);
      return 0;
    }
  }

  @override
  Future<List<Customer>> getRecentCustomers({int limit = 10}) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting recent customers', e);
      return [];
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final customerEntity =
          FirebaseCustomerEntity.fromDomain(customer).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: _uid(),
      );

      // Debug: Firestore'a kayıt öncesi
      debugPrint('DEBUG: Firestore\'a kayıt öncesi - maturityDays: ${customerEntity.maturityDays}');
      debugPrint('DEBUG: Firestore\'a kayıt öncesi - fixedDiscountRate: ${customerEntity.fixedDiscountRate}');
      
      final firestoreData = customerEntity.toFirestore();
      debugPrint('DEBUG: Firestore data - maturityDays: ${firestoreData['maturityDays']}');
      debugPrint('DEBUG: Firestore data - fixedDiscountRate: ${firestoreData['fixedDiscountRate']}');

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc(customer.id)
          .update(firestoreData);
          
      // Debug: Firestore'a kayıt sonrası
      debugPrint('DEBUG: Firestore\'a kayıt başarılı!');
    } catch (e) {
      AppLogger.error('Error updating customer', e);
      debugPrint('DEBUG: Firestore kayıt hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCustomerStatus(String id, bool isActive) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc(id)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });
    } catch (e) {
      AppLogger.error('Error updating customer status', e);
      rethrow;
    }
  }

  @override
  Future<void> updateCustomerBalance(String id, double newBalance) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc(id)
          .update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _uid(),
      });
    } catch (e) {
      AppLogger.error('Error updating customer balance', e);
      rethrow;
    }
  }

  @override
  Future<double> calculateCustomerBalance(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0.0;

      final customer = await getCustomerById(id);
      return customer?.balance ?? 0.0;
    } catch (e) {
      AppLogger.error('Error calculating customer balance', e);
      return 0.0;
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc(id)
          .delete();
    } catch (e) {
      AppLogger.error('Error deleting customer', e);
      rethrow;
    }
  }

  Stream<Customer?> getCustomerStream(String id) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(null);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc(id)
          .snapshots()
          .map((doc) {
        if (doc.exists) {
          return FirebaseCustomerEntity.fromFirestore(doc).toDomain();
        }
        return null;
      });
    });
  }

  Stream<List<Customer>> getCustomersStream() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Customer>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
              .toList());
    });
  }

  Stream<List<Customer>> getActiveCustomersStream() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Customer>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
              .toList());
    });
  }

  Stream<List<Customer>> searchCustomersStream(String query) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Customer>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
              .toList());
    });
  }

  // ========== EKSİK METODLAR ==========

  @override
  Future<void> recalculateAllCustomerBalances() async {
    // Bu metod şimdilik boş - gelecekte implement edilecek
    AppLogger.info('Recalculate all customer balances - not implemented yet');
  }

  @override
  Future<void> deleteInactiveCustomers() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
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
    return getCustomersStream();
  }

  @override
  Stream<List<Customer>> watchActiveCustomers() {
    return getActiveCustomersStream();
  }

  @override
  Stream<List<Customer>> watchInactiveCustomers() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Customer>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('isActive', isEqualTo: false)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
              .toList());
    });
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    return getCustomerStream(id);
  }

  @override
  Stream<int> watchActiveCustomerCount() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(0);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    });
  }

  @override
  Stream<int> watchInactiveCustomerCount() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(0);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .where('isActive', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    });
  }

  @override
  Future<Map<CustomerType, int>> getCustomerTypeStats() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return {};

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
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
      return {};
    }
  }

  @override
  Future<Map<String, int>> getCustomerCityStats() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return {};

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
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
      return {};
    }
  }

  @override
  Future<Map<String, int>> getMonthlyCustomerStats() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);

      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return {};

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
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
      return {};
    }
  }
}
