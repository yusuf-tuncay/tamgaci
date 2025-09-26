// ========== FIREBASE EXPENSE REPOSITORY ==========
// lib/features/expenses/data/repositories/firebase_expense_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/expense_repository.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/core/firebase/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Firebase Firestore tabanlı gider repository implementasyonu
class FirebaseExpenseRepository implements ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'expenses';
  final String _categoriesCollectionName = 'expense_categories';
  final FirebaseService _firebaseService = FirebaseService();

  String? _uid() {
    try {
      return firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<String> _companyId() async {
    final ids = await _firebaseService.getUserCompanyIds();
    return ids.isNotEmpty ? ids.first : '';
  }

  Future<String> _tenantId() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return '';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data()?['tenantId'] ?? '';
      }
      return '';
    } catch (e) {
      AppLogger.error('Error getting tenant ID', e);
      return '';
    }
  }

  // ========== EXPENSE OPERATIONS ==========

  @override
  Future<String> createExpense(Expense expense) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final companyId = await _companyId();
      final expenseData = _expenseToMap(expense.copyWith(id: docRef.id));
      if (companyId.isNotEmpty) expenseData['companyId'] = companyId;
      expenseData['createdBy'] = _uid();
      await docRef.set(expenseData);
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating expense', e);
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(expense.id)
          .update(_expenseToMap(expense));
    } catch (e) {
      AppLogger.error('Error updating expense', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      AppLogger.error('Error deleting expense', e);
      rethrow;
    }
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(id).get();
      if (!docSnapshot.exists) return null;
      return _expenseFromMap(docSnapshot);
    } catch (e) {
      AppLogger.error('Error getting expense by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final tenantId = await _tenantId();
      if (tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found, returning empty list');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('expenses')
          .orderBy('expenseDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _expenseFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting all expenses', e);
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    try {
      final companyId = await _companyId();
      Query<Map<String, dynamic>> q = _firestore
          .collection(_collectionName)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('expenseDate', descending: true);
      if (companyId.isNotEmpty) {
        q = q.where('companyId', isEqualTo: companyId);
      }
      final querySnapshot = await q.get();

      return querySnapshot.docs.map((doc) => _expenseFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting expenses by category', e);
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpensesByStatus(ExpenseStatus status) async {
    try {
      final companyId = await _companyId();
      Query<Map<String, dynamic>> q = _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: status.name)
          .orderBy('expenseDate', descending: true);
      if (companyId.isNotEmpty) {
        q = q.where('companyId', isEqualTo: companyId);
      }
      final querySnapshot = await q.get();

      return querySnapshot.docs.map((doc) => _expenseFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting expenses by status', e);
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final companyId = await _companyId();
      Query<Map<String, dynamic>> q = _firestore
          .collection(_collectionName)
          .where('expenseDate', isGreaterThanOrEqualTo: startDate)
          .where('expenseDate', isLessThanOrEqualTo: endDate)
          .orderBy('expenseDate', descending: true);
      if (companyId.isNotEmpty) {
        q = q.where('companyId', isEqualTo: companyId);
      }
      final querySnapshot = await q.get();

      return querySnapshot.docs.map((doc) => _expenseFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting expenses by date range', e);
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getRecentExpenses({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('expenseDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => _expenseFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting recent expenses', e);
      rethrow;
    }
  }

  @override
  Future<int> getTotalExpenseCount() async {
    try {
      final companyId = await _companyId();
      Query<Map<String, dynamic>> q = _firestore.collection(_collectionName);
      if (companyId.isNotEmpty) {
        q = q.where('companyId', isEqualTo: companyId);
      }
      final querySnapshot = await q.get();
      return querySnapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error getting total expense count', e);
      rethrow;
    }
  }

  @override
  Future<double> getTotalExpenseAmount() async {
    try {
      final companyId = await _companyId();
      Query<Map<String, dynamic>> q = _firestore.collection(_collectionName);
      if (companyId.isNotEmpty) {
        q = q.where('companyId', isEqualTo: companyId);
      }
      final querySnapshot = await q.get();
      double total = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        total += (data['amount'] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      AppLogger.error('Error getting total expense amount', e);
      rethrow;
    }
  }

  @override
  Future<double> getCurrentMonthExpenseAmount() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final companyId = await _companyId();
      Query<Map<String, dynamic>> q = _firestore
          .collection(_collectionName)
          .where('expenseDate', isGreaterThanOrEqualTo: startOfMonth)
          .where('expenseDate', isLessThanOrEqualTo: endOfMonth);
      if (companyId.isNotEmpty) {
        q = q.where('companyId', isEqualTo: companyId);
      }
      final querySnapshot = await q.get();

      double total = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        total += (data['amount'] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      AppLogger.error('Error getting current month expense amount', e);
      rethrow;
    }
  }

  @override
  Future<List<Expense>> searchExpenses(String query) async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      final lowercaseQuery = query.toLowerCase();
      return querySnapshot.docs
          .map((doc) => _expenseFromMap(doc))
          .where((expense) =>
              expense.title.toLowerCase().contains(lowercaseQuery) ||
              (expense.description?.toLowerCase().contains(lowercaseQuery) ??
                  false))
          .toList();
    } catch (e) {
      AppLogger.error('Error searching expenses', e);
      rethrow;
    }
  }

  @override
  Future<void> updateExpenseStatus(String id, ExpenseStatus status) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update({'status': status.name});
    } catch (e) {
      AppLogger.error('Error updating expense status', e);
      rethrow;
    }
  }

  // ========== STREAM OPERATIONS ==========

  @override
  Stream<Expense?> watchExpenseById(String id) {
    return _firestore
        .collection(_collectionName)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? _expenseFromMap(doc) : null);
  }

  @override
  Stream<List<Expense>> watchAllExpenses() {
    return _firestore
        .collection(_collectionName)
        .orderBy('expenseDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _expenseFromMap(doc)).toList());
  }

  @override
  Stream<List<Expense>> watchExpensesByCategory(String categoryId) {
    return _firestore
        .collection(_collectionName)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('expenseDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _expenseFromMap(doc)).toList());
  }

  // ========== CATEGORY OPERATIONS ==========

  @override
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(_categoriesCollectionName)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) => _categoryFromMap(doc)).toList();
    } catch (e) {
      AppLogger.error('Error getting expense categories', e);
      // Varsayılan kategorileri döndür
      return DefaultExpenseCategories.categories;
    }
  }

  @override
  Future<ExpenseCategory?> getExpenseCategoryById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_categoriesCollectionName).doc(id).get();
      if (!docSnapshot.exists) return null;
      return _categoryFromMap(docSnapshot);
    } catch (e) {
      AppLogger.error('Error getting expense category by ID', e);
      rethrow;
    }
  }

  @override
  Future<String> createExpenseCategory(ExpenseCategory category) async {
    try {
      final docRef = _firestore.collection(_categoriesCollectionName).doc();
      final categoryData = _categoryToMap(category.copyWith(id: docRef.id));
      await docRef.set(categoryData);
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating expense category', e);
      rethrow;
    }
  }

  @override
  Future<void> updateExpenseCategory(ExpenseCategory category) async {
    try {
      await _firestore
          .collection(_categoriesCollectionName)
          .doc(category.id)
          .update(_categoryToMap(category));
    } catch (e) {
      AppLogger.error('Error updating expense category', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteExpenseCategory(String id) async {
    try {
      await _firestore.collection(_categoriesCollectionName).doc(id).delete();
    } catch (e) {
      AppLogger.error('Error deleting expense category', e);
      rethrow;
    }
  }

  @override
  Stream<List<ExpenseCategory>> watchExpenseCategories() {
    return _firestore
        .collection(_categoriesCollectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _categoryFromMap(doc)).toList());
  }

  // Helper methods for data conversion
  Map<String, dynamic> _expenseToMap(Expense expense) {
    return {
      'id': expense.id,
      'title': expense.title,
      'description': expense.description,
      'amount': expense.amount,
      'currency': expense.currency,
      'categoryId': expense.categoryId,
      'categoryName': expense.categoryName,
      'expenseDate': expense.expenseDate,
      'status': expense.status.name,
      'paymentMethod': expense.paymentMethod,
      'attachments': expense.attachments,
      'invoiceNumber': expense.invoiceNumber,
      'supplierId': expense.supplierId,
      'supplierName': expense.supplierName,
      'createdBy': expense.createdBy,
      'updatedBy': expense.updatedBy,
      'createdAt': expense.createdAt,
      'updatedAt': expense.updatedAt,
    };
  }

  Expense _expenseFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      expenseDate: (data['expenseDate'] as Timestamp).toDate(),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      paymentMethod: data['paymentMethod'] ?? '',
      attachments: List<String>.from(data['attachments'] ?? []),
      invoiceNumber: data['invoiceNumber'],
      supplierId: data['supplierId'],
      supplierName: data['supplierName'],
      createdBy: data['createdBy'] ?? 'system',
      updatedBy: data['updatedBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _categoryToMap(ExpenseCategory category) {
    return {
      'id': category.id,
      'name': category.name,
      'description': category.description,
      'color': category.color,
      'icon': category.icon,
      'isActive': category.isActive,
      'createdAt': category.createdAt,
      'updatedAt': category.updatedAt,
    };
  }

  ExpenseCategory _categoryFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseCategory(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      color: data['color'] ?? '#2196F3',
      icon: data['icon'] ?? 'business',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
