// ========== FIREBASE SUPPLIER REPOSITORY ==========
// lib/features/suppliers/data/repositories/firebase_supplier_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Firebase Firestore tabanlı tedarikçi repository implementasyonu
class FirebaseSupplierRepository implements SupplierRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'suppliers';

  // ========== SUPPLIER OPERATIONS ==========

  @override
  Future<String> createSupplier(Supplier supplier) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final supplierData = _supplierToMap(supplier.copyWith(id: docRef.id));
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
      await _firestore
          .collection(_collectionName)
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
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      AppLogger.error('Error deleting supplier', e);
      rethrow;
    }
  }

  @override
  Future<Supplier?> getSupplierById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(id).get();
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
      final querySnapshot =
          await _firestore.collection(_collectionName).orderBy('name').get();

      return querySnapshot.docs.map((doc) => _supplierFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting all suppliers', e);
      rethrow;
    }
  }

  Future<List<Supplier>> getActiveSuppliers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) => _supplierFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting active suppliers', e);
      rethrow;
    }
  }

  Future<List<Supplier>> searchSuppliers(String query) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      final lowercaseQuery = query.toLowerCase();
      return querySnapshot.docs
          .map((doc) => _supplierFromMap(doc))
          .where((supplier) =>
              supplier.name.toLowerCase().contains(lowercaseQuery) ||
              supplier.email.toLowerCase().contains(lowercaseQuery) ||
              supplier.phone.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e) {
      AppLogger.error('Error searching suppliers', e);
      rethrow;
    }
  }

  Future<List<Supplier>> getSuppliersByCity(String city) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('city', isEqualTo: city)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) => _supplierFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting suppliers by city', e);
      rethrow;
    }
  }

  Future<int> getTotalSupplierCount() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting total supplier count', e);
      rethrow;
    }
  }

  Future<int> getActiveSupplierCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting active supplier count', e);
      rethrow;
    }
  }

  // ========== STREAM OPERATIONS ==========

  @override
  Stream<Supplier?> watchSupplierById(String id) {
    return _firestore
        .collection(_collectionName)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? _supplierFromMap(doc) : null);
  }

  @override
  Stream<List<Supplier>> watchAllSuppliers() {
    return _firestore
        .collection(_collectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _supplierFromMap(doc)).toList());
  }

  Stream<List<Supplier>> watchActiveSuppliers() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _supplierFromMap(doc)).toList());
  }

  // Helper methods for data conversion
  Map<String, dynamic> _supplierToMap(Supplier supplier) {
    return {
      'id': supplier.id,
      'name': supplier.name,
      'contactPerson': supplier.contactPerson,
      'email': supplier.email,
      'phone': supplier.phone,
      'address': supplier.address,
      'taxNumber': supplier.taxNumber,
      'taxOffice': supplier.taxOffice,
      'bankName': supplier.bankName,
      'bankAccount': supplier.bankAccount,
      'creditLimit': supplier.creditLimit,
      'currentBalance': supplier.currentBalance,
      'currency': supplier.currency,
      'status': supplier.status.name,
      'createdAt': supplier.createdAt,
      'updatedAt': supplier.updatedAt,
    };
  }

  Supplier _supplierFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      taxNumber: data['taxNumber'] ?? '',
      taxOffice: data['taxOffice'] ?? '',
      bankName: data['bankName'] ?? '',
      bankAccount: data['bankAccount'] ?? '',
      creditLimit: (data['creditLimit'] ?? 0).toDouble(),
      currentBalance: (data['currentBalance'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      status: SupplierStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SupplierStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
