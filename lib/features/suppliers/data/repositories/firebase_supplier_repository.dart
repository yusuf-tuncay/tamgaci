// ========== FIREBASE SUPPLIER REPOSITORY - FIXED ==========
// lib/features/suppliers/data/repositories/firebase_supplier_repository_fixed.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_enums.dart';
import '../../domain/repositories/supplier_repository.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tamgaci/core/services/tenant_service.dart';

/// Firebase Firestore tabanlı tedarikçi repository implementasyonu - Multi-tenant
class FirebaseSupplierRepository implements SupplierRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TenantService _tenantService = TenantService();

  String? _uid() {
    try {
      return firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<String> _tenantId() async {
    return await _tenantService.getUserTenantIdString();
  }

  // ========== SUPPLIER OPERATIONS ==========

  @override
  Future<String> createSupplier(Supplier supplier) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .doc();
      final supplierData = _supplierToMap(supplier.copyWith(id: docRef.id));
      supplierData['tenantId'] = tenantId;
      supplierData['createdBy'] = _uid();
      await docRef.set(supplierData);
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating supplier', e);
      rethrow;
    }
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .doc(supplier.id)
          .update(_supplierToMap(supplier));
    } catch (e) {
      AppLogger.error('Error updating supplier', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .doc(id)
          .delete();
    } catch (e) {
      AppLogger.error('Error deleting supplier', e);
      rethrow;
    }
  }

  @override
  Future<Supplier?> getSupplierById(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final docSnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .doc(id)
          .get();
      if (!docSnapshot.exists) return null;
      return _supplierFromMap(docSnapshot);
    } catch (e) {
      AppLogger.error('Error getting supplier by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<Supplier>> getAllSuppliers() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) => _supplierFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting all suppliers', e);
      rethrow;
    }
  }

  Future<List<Supplier>> getActiveSuppliers() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) => _supplierFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting active suppliers', e);
      rethrow;
    }
  }

  Future<List<Supplier>> getSuppliersByType(String type) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('type', isEqualTo: type)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) => _supplierFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting suppliers by type', e);
      rethrow;
    }
  }

  Future<List<Supplier>> getSuppliersByCity(String city) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('city', isEqualTo: city)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) => _supplierFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting suppliers by city', e);
      rethrow;
    }
  }

  Future<Supplier?> getSupplierByEmail(String email) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _supplierFromMap(querySnapshot.docs.first);
    } catch (e) {
      AppLogger.error('Error getting supplier by email', e);
      rethrow;
    }
  }

  Future<Supplier?> getSupplierByPhone(String phone) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _supplierFromMap(querySnapshot.docs.first);
    } catch (e) {
      AppLogger.error('Error getting supplier by phone', e);
      rethrow;
    }
  }

  Future<Supplier?> getSupplierByTaxNumber(String taxNumber) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('taxNumber', isEqualTo: taxNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _supplierFromMap(querySnapshot.docs.first);
    } catch (e) {
      AppLogger.error('Error getting supplier by tax number', e);
      rethrow;
    }
  }

  Future<int> getTotalSupplierCount() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting total supplier count', e);
      rethrow;
    }
  }

  Future<int> getActiveSupplierCount() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting active supplier count', e);
      rethrow;
    }
  }

  Future<int> getInactiveSupplierCount() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0;

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('isActive', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting inactive supplier count', e);
      rethrow;
    }
  }

  Future<List<Supplier>> getRecentSuppliers(int limit) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => _supplierFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting recent suppliers', e);
      rethrow;
    }
  }

  Future<void> updateSupplierStatus(String id, bool isActive) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .doc(id)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('Error updating supplier status', e);
      rethrow;
    }
  }

  Future<void> updateSupplierBalance(String id, double amount) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .doc(id)
          .update({
        'balance': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('Error updating supplier balance', e);
      rethrow;
    }
  }

  Future<double> calculateSupplierBalance(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return 0.0;

      final docSnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .doc(id)
          .get();

      if (!docSnapshot.exists) return 0.0;
      final data = docSnapshot.data() as Map<String, dynamic>;
      return (data['balance'] ?? 0.0).toDouble();
    } catch (e) {
      AppLogger.error('Error calculating supplier balance', e);
      rethrow;
    }
  }

  Future<void> deleteInactiveSuppliers() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('isActive', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      AppLogger.error('Error deleting inactive suppliers', e);
      rethrow;
    }
  }

  // ========== STREAM OPERATIONS ==========

  @override
  Stream<List<Supplier>> watchAllSuppliers() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Supplier>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .orderBy('name')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _supplierFromMap(doc)).toList());
    });
  }

  Stream<List<Supplier>> watchActiveSuppliers() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Supplier>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _supplierFromMap(doc)).toList());
    });
  }

  Stream<List<Supplier>> watchInactiveSuppliers() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Supplier>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('isActive', isEqualTo: false)
          .orderBy('name')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _supplierFromMap(doc)).toList());
    });
  }

  @override
  Stream<Supplier?> watchSupplierById(String id) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(null);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .doc(id)
          .snapshots()
          .map((snapshot) =>
              snapshot.exists ? _supplierFromMap(snapshot) : null);
    });
  }

  Stream<int> watchActiveSupplierCount() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(0);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    });
  }

  Stream<int> watchInactiveSupplierCount() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(0);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('isActive', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    });
  }

  // ========== STATISTICS ==========

  Future<Map<String, int>> getSupplierTypeStats() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return {};

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .get();

      final stats = <String, int>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final type = data['supplierType'] as String? ?? 'Unknown';
        stats[type] = (stats[type] ?? 0) + 1;
      }
      return stats;
    } catch (e) {
      AppLogger.error('Error getting supplier type stats', e);
      rethrow;
    }
  }

  Future<Map<String, int>> getSupplierCityStats() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return {};

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .get();

      final stats = <String, int>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final city = data['city'] as String? ?? 'Unknown';
        stats[city] = (stats[city] ?? 0) + 1;
      }
      return stats;
    } catch (e) {
      AppLogger.error('Error getting supplier city stats', e);
      rethrow;
    }
  }

  Future<Map<String, int>> getMonthlySupplierStats() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return {};

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('suppliers')
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
          .where('createdAt', isLessThanOrEqualTo: endOfMonth)
          .get();

      return {'current_month': querySnapshot.docs.length};
    } catch (e) {
      AppLogger.error('Error getting monthly supplier stats', e);
      rethrow;
    }
  }

  // ========== HELPER METHODS ==========

  Map<String, dynamic> _supplierToMap(Supplier supplier) {
    return {
      'id': supplier.id,
      'name': supplier.name,
      'email': supplier.email,
      'phone': supplier.phone,
      'address': supplier.address,
      'city': supplier.city,
      'country': supplier.country,
      'taxNumber': supplier.taxNumber,
      'supplierType': supplier.supplierType.name,
      'balance': supplier.balance,
      'createdAt': Timestamp.fromDate(supplier.createdAt),
      'updatedAt': Timestamp.fromDate(supplier.updatedAt),
      'companyId': supplier.companyId,
      'status': supplier.status.name,
      'createdBy': supplier.createdBy,
      'isActive': supplier.isActive,
    };
  }

  Supplier _supplierFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: doc.id,
      tenantId: data['tenantId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      taxNumber: data['taxNumber'] ?? '',
      supplierType: SupplierType.values.firstWhere(
        (e) => e.name == data['supplierType'],
        orElse: () => SupplierType.individual,
      ),
      balance: (data['balance'] ?? 0.0).toDouble(),
      companyId: data['companyId'] ?? '',
      status: SupplierStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SupplierStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}
