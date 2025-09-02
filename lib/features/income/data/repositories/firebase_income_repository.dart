// ========== FIREBASE INCOME REPOSITORY ==========
// lib/features/income/data/repositories/firebase_income_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/income_category.dart';
import '../../domain/repositories/income_repository.dart';

/// Firebase Firestore tabanlı gelir repository implementasyonu
class FirebaseIncomeRepository implements IncomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'incomes';
  final String _categoriesCollectionName = 'income_categories';

  // ========== INCOME OPERATIONS ==========

  @override
  Future<String> createIncome(Income income) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final incomeData = _incomeToMap(income.copyWith(id: docRef.id));
      await docRef.set(incomeData);
      return docRef.id;
    } catch (e) {
      print('Error creating income: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateIncome(Income income) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(income.id)
          .update(_incomeToMap(income));
    } catch (e) {
      print('Error updating income: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteIncome(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      print('Error deleting income: $e');
      rethrow;
    }
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    try {
      final docSnapshot = await _firestore.collection(_collectionName).doc(id).get();
      if (!docSnapshot.exists) return null;
      return _incomeFromMap(docSnapshot);
    } catch (e) {
      print('Error getting income by ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<Income>> getAllIncomes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('incomeDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => _incomeFromMap(doc))
          .toList();
    } catch (e) {
      print('Error getting all incomes: $e');
      rethrow;
    }
  }

  @override
  Future<List<Income>> getIncomesByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('incomeDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => _incomeFromMap(doc))
          .toList();
    } catch (e) {
      print('Error getting incomes by category: $e');
      rethrow;
    }
  }

  @override
  Future<List<Income>> getIncomesByStatus(IncomeStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: status.name)
          .orderBy('incomeDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => _incomeFromMap(doc))
          .toList();
    } catch (e) {
      print('Error getting incomes by status: $e');
      rethrow;
    }
  }

  @override
  Future<List<Income>> getIncomesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('incomeDate', isGreaterThanOrEqualTo: startDate)
          .where('incomeDate', isLessThanOrEqualTo: endDate)
          .orderBy('incomeDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => _incomeFromMap(doc))
          .toList();
    } catch (e) {
      print('Error getting incomes by date range: $e');
      rethrow;
    }
  }

  @override
  Future<List<Income>> getRecentIncomes({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('incomeDate', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => _incomeFromMap(doc))
          .toList();
    } catch (e) {
      print('Error getting recent incomes: $e');
      rethrow;
    }
  }

  @override
  Future<int> getTotalIncomeCount() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting total income count: $e');
      rethrow;
    }
  }

  @override
  Future<double> getTotalIncomeAmount() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      double total = 0;
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        total += (data['amount'] ?? 0).toDouble();
      }
      
      return total;
    } catch (e) {
      print('Error getting total income amount: $e');
      rethrow;
    }
  }

  @override
  Future<double> getCurrentMonthIncomeAmount() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('incomeDate', isGreaterThanOrEqualTo: startOfMonth)
          .where('incomeDate', isLessThanOrEqualTo: endOfMonth)
          .get();
      
      double total = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        total += (data['amount'] ?? 0).toDouble();
      }
      
      return total;
    } catch (e) {
      print('Error getting current month income amount: $e');
      rethrow;
    }
  }

  @override
  Future<List<Income>> searchIncomes(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();
      
      final lowercaseQuery = query.toLowerCase();
      return querySnapshot.docs
          .map((doc) => _incomeFromMap(doc))
          .where((income) =>
              income.title.toLowerCase().contains(lowercaseQuery) ||
              (income.description?.toLowerCase().contains(lowercaseQuery) ?? false))
          .toList();
    } catch (e) {
      print('Error searching incomes: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateIncomeStatus(String id, IncomeStatus status) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update({'status': status.name});
    } catch (e) {
      print('Error updating income status: $e');
      rethrow;
    }
  }

  // ========== STREAM OPERATIONS ==========

  @override
  Stream<Income?> watchIncomeById(String id) {
    return _firestore
        .collection(_collectionName)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? _incomeFromMap(doc) : null);
  }

  @override
  Stream<List<Income>> watchAllIncomes() {
    return _firestore
        .collection(_collectionName)
        .orderBy('incomeDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _incomeFromMap(doc))
            .toList());
  }

  @override
  Stream<List<Income>> watchIncomesByCategory(String categoryId) {
    return _firestore
        .collection(_collectionName)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('incomeDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _incomeFromMap(doc))
            .toList());
  }

  // ========== CATEGORY OPERATIONS ==========

  @override
  Future<List<IncomeCategory>> getAllIncomeCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(_categoriesCollectionName)
          .orderBy('name')
          .get();
      
      return querySnapshot.docs
          .map((doc) => _categoryFromMap(doc))
          .toList();
    } catch (e) {
      print('Error getting income categories: $e');
      // Varsayılan kategorileri döndür
      return DefaultIncomeCategories.categories;
    }
  }

  @override
  Future<IncomeCategory?> getIncomeCategoryById(String id) async {
    try {
      final docSnapshot = await _firestore.collection(_categoriesCollectionName).doc(id).get();
      if (!docSnapshot.exists) return null;
      return _categoryFromMap(docSnapshot);
    } catch (e) {
      print('Error getting income category by ID: $e');
      rethrow;
    }
  }

  @override
  Future<String> createIncomeCategory(IncomeCategory category) async {
    try {
      final docRef = _firestore.collection(_categoriesCollectionName).doc();
      final categoryData = _categoryToMap(category.copyWith(id: docRef.id));
      await docRef.set(categoryData);
      return docRef.id;
    } catch (e) {
      print('Error creating income category: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateIncomeCategory(IncomeCategory category) async {
    try {
      await _firestore
          .collection(_categoriesCollectionName)
          .doc(category.id)
          .update(_categoryToMap(category));
    } catch (e) {
      print('Error updating income category: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteIncomeCategory(String id) async {
    try {
      await _firestore.collection(_categoriesCollectionName).doc(id).delete();
    } catch (e) {
      print('Error deleting income category: $e');
      rethrow;
    }
  }

  @override
  Stream<List<IncomeCategory>> watchAllIncomeCategories() {
    return _firestore
        .collection(_categoriesCollectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _categoryFromMap(doc))
            .toList());
  }

  // Helper methods for data conversion
  Map<String, dynamic> _incomeToMap(Income income) {
    return {
      'id': income.id,
      'title': income.title,
      'description': income.description,
      'amount': income.amount,
      'categoryId': income.categoryId,
      'categoryName': income.categoryName,
      'incomeDate': income.incomeDate,
      'status': income.status.name,
      'paymentMethod': income.paymentMethod,
      'attachments': income.attachments,
      'invoiceNumber': income.invoiceNumber,
      'customerId': income.customerId,
      'customerName': income.customerName,
      'notes': income.notes,
      'createdAt': income.createdAt,
      'updatedAt': income.updatedAt,
    };
  }

  Income _incomeFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Income(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      amount: (data['amount'] ?? 0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      incomeDate: (data['incomeDate'] as Timestamp).toDate(),
      status: IncomeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => IncomeStatus.received,
      ),
      paymentMethod: data['paymentMethod'] ?? '',
      attachments: List<String>.from(data['attachments'] ?? []),
      invoiceNumber: data['invoiceNumber'],
      customerId: data['customerId'],
      customerName: data['customerName'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _categoryToMap(IncomeCategory category) {
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

  IncomeCategory _categoryFromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncomeCategory(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      color: data['color'] ?? '#4CAF50',
      icon: data['icon'] ?? 'attach_money',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

// Varsayılan gelir kategorileri
class DefaultIncomeCategories {
  static final List<IncomeCategory> categories = [
    IncomeCategory(
      id: '1',
      name: 'Satış Geliri',
      description: 'Ürün ve hizmet satışlarından elde edilen gelirler',
      color: '#4CAF50',
      icon: 'shopping_cart',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '2',
      name: 'Hizmet Geliri',
      description: 'Danışmanlık ve hizmet gelirleri',
      color: '#2196F3',
      icon: 'business',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '3',
      name: 'Kira Geliri',
      description: 'Gayrimenkul kiralarından elde edilen gelirler',
      color: '#FF9800',
      icon: 'home',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '4',
      name: 'Faiz Geliri',
      description: 'Bankacılık ve yatırım faiz gelirleri',
      color: '#9C27B0',
      icon: 'account_balance',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '5',
      name: 'Komisyon Geliri',
      description: 'Aracılık ve komisyon gelirleri',
      color: '#607D8B',
      icon: 'trending_up',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeCategory(
      id: '6',
      name: 'Diğer Gelirler',
      description: 'Diğer gelir kalemleri',
      color: '#795548',
      icon: 'more_horiz',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}
