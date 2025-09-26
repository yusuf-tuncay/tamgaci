// ========== FIREBASE INCOME REPOSITORY - FIXED ==========
// lib/features/income/data/repositories/firebase_income_repository_fixed.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/income_category.dart';
import '../../domain/repositories/income_repository.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tamgaci/core/services/tenant_service.dart';

/// Firebase Firestore tabanlı gelir repository implementasyonu - Multi-tenant
class FirebaseIncomeRepository implements IncomeRepository {
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

  // ========== INCOME OPERATIONS ==========

  @override
  Future<void> createIncome(Income income) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .doc();
      final incomeData = _incomeToMap(income.copyWith(id: docRef.id));
      incomeData['tenantId'] = tenantId;
      incomeData['createdBy'] = _uid();
      await docRef.set(incomeData);
    } catch (e) {
      AppLogger.error('Error creating income', e);
      rethrow;
    }
  }

  @override
  Future<void> updateIncome(Income income) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .doc(income.id)
          .update(_incomeToMap(income));
    } catch (e) {
      AppLogger.error('Error updating income', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteIncome(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .doc(id)
          .delete();
    } catch (e) {
      AppLogger.error('Error deleting income', e);
      rethrow;
    }
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final docSnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .doc(id)
          .get();
      if (!docSnapshot.exists) return null;
      return _incomeFromMap(docSnapshot);
    } catch (e) {
      AppLogger.error('Error getting income by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<Income>> getAllIncomes() async {
    try {
      final tenantId = await _tenantId();
      AppLogger.info('Getting incomes for tenant: $tenantId');

      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .orderBy('incomeDate', descending: true)
          .get();

      AppLogger.info('Found ${querySnapshot.docs.length} income documents');
      return querySnapshot.docs.map((doc) => _incomeFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting all incomes', e);
      rethrow;
    }
  }

  Future<List<Income>> getIncomesByCategory(String categoryId) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('incomeDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _incomeFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting incomes by category', e);
      rethrow;
    }
  }

  Future<List<Income>> getIncomesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .where('incomeDate', isGreaterThanOrEqualTo: startDate)
          .where('incomeDate', isLessThanOrEqualTo: endDate)
          .orderBy('incomeDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _incomeFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting incomes by date range', e);
      rethrow;
    }
  }

  Future<List<Income>> getRecentIncomes(int limit) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .orderBy('incomeDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => _incomeFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting recent incomes', e);
      rethrow;
    }
  }

  // ========== INCOME CATEGORY OPERATIONS ==========

  @override
  Future<List<IncomeCategory>> getAllIncomeCategories() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('income_categories')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _incomeCategoryFromMap(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting income categories', e);
      rethrow;
    }
  }

  @override
  Future<void> createIncomeCategory(IncomeCategory category) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('income_categories')
          .doc();
      final categoryData =
          _incomeCategoryToMap(category.copyWith(id: docRef.id));
      categoryData['tenantId'] = tenantId;
      categoryData['createdBy'] = _uid();
      await docRef.set(categoryData);
    } catch (e) {
      AppLogger.error('Error creating income category', e);
      rethrow;
    }
  }

  @override
  Future<void> updateIncomeCategory(IncomeCategory category) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('income_categories')
          .doc(category.id)
          .update(_incomeCategoryToMap(category));
    } catch (e) {
      AppLogger.error('Error updating income category', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteIncomeCategory(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('income_categories')
          .doc(id)
          .delete();
    } catch (e) {
      AppLogger.error('Error deleting income category', e);
      rethrow;
    }
  }

  Future<IncomeCategory?> getIncomeCategoryById(String id) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) return null;

      final docSnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('income_categories')
          .doc(id)
          .get();
      if (!docSnapshot.exists) return null;
      return _incomeCategoryFromMap(docSnapshot);
    } catch (e) {
      AppLogger.error('Error getting income category by ID', e);
      rethrow;
    }
  }

  // ========== STREAM OPERATIONS ==========

  @override
  Stream<List<Income>> watchAllIncomes() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<Income>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .orderBy('incomeDate', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _incomeFromMap(doc)).toList());
    });
  }

  @override
  Stream<Income?> watchIncomeById(String id) {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(null);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .doc(id)
          .snapshots()
          .map((snapshot) => snapshot.exists ? _incomeFromMap(snapshot) : null);
    });
  }

  @override
  Stream<List<IncomeCategory>> watchAllIncomeCategories() {
    return Stream.fromFuture(_tenantId()).asyncExpand((tenantId) {
      if (tenantId.isEmpty) {
        return Stream.value(<IncomeCategory>[]);
      }

      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('income_categories')
          .orderBy('name')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _incomeCategoryFromMap(doc)).toList());
    });
  }

  // ========== HELPER METHODS ==========

  Map<String, dynamic> _incomeToMap(Income income) {
    return {
      'id': income.id,
      'title': income.title,
      'description': income.description,
      'amount': income.amount,
      'currency': income.currency,
      'categoryId': income.categoryId,
      'categoryName': income.categoryName,
      'incomeDate': Timestamp.fromDate(income.incomeDate),
      'customerId': income.customerId,
      'customerName': income.customerName,
      'paymentMethod': income.paymentMethod,
      'invoiceNumber': income.invoiceNumber,
      'status': income.status.value,
      'notes': income.notes,
      'attachments': income.attachments,
      'createdAt': Timestamp.fromDate(income.createdAt),
      'updatedAt': Timestamp.fromDate(income.updatedAt),
      'createdBy': income.createdBy,
      'updatedBy': income.updatedBy,
    };
  }

  Income _incomeFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Income(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      incomeDate: (data['incomeDate'] as Timestamp).toDate(),
      customerId: data['customerId'],
      customerName: data['customerName'],
      paymentMethod: data['paymentMethod'] ?? '',
      invoiceNumber: data['invoiceNumber'],
      status: IncomeStatus.fromString(data['status'] ?? 'pending'),
      notes: data['notes'],
      attachments: List<String>.from(data['attachments'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> _incomeCategoryToMap(IncomeCategory category) {
    return {
      'id': category.id,
      'name': category.name,
      'description': category.description,
      'icon': category.icon,
      'color': category.color,
      'isActive': category.isActive,
      'createdAt': Timestamp.fromDate(category.createdAt),
      'updatedAt': Timestamp.fromDate(category.updatedAt),
    };
  }

  IncomeCategory _incomeCategoryFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncomeCategory(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      icon: data['icon'] ?? 'attach_money',
      color: data['color'] ?? '#4CAF50',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  Future<void> updateIncomeStatus(String id, IncomeStatus status) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        throw Exception('Tenant ID is required for multi-tenant architecture');
      }

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .doc(id)
          .update({'status': status.value});
    } catch (e) {
      AppLogger.error('Error updating income status', e);
      rethrow;
    }
  }

  @override
  Future<List<Income>> searchIncomes(String query) async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('incomes')
          .get();

      final lowercaseQuery = query.toLowerCase();
      return querySnapshot.docs
          .map((doc) => _incomeFromMap(doc))
          .where((income) =>
              income.title.toLowerCase().contains(lowercaseQuery) ||
              (income.description?.toLowerCase().contains(lowercaseQuery) ??
                  false))
          .toList();
    } catch (e) {
      AppLogger.error('Error searching incomes', e);
      rethrow;
    }
  }
}
