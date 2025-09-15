// ========== DASHBOARD SERVICE ==========
// lib/core/services/dashboard_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Dashboard veri servisi
class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Dashboard özet verilerini getirme
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);

      // Paralel olarak tüm verileri çek
      final results = await Future.wait([
        _getCustomerStats(),
        _getProductStats(),
        _getSalesStats(startOfMonth, now),
        _getExpenseStats(startOfMonth, now),
        _getIncomeStats(startOfMonth, now),
        _getTransactionStats(startOfMonth, now),
        _getLowStockProducts(),
        _getOverdueInvoices(),
      ]);

      return {
        'customers': results[0],
        'products': results[1],
        'sales': results[2],
        'expenses': results[3],
        'income': results[4],
        'transactions': results[5],
        'lowStockProducts': results[6],
        'overdueInvoices': results[7],
        'lastUpdated': now,
      };
    } catch (e) {
      AppLogger.error('Error getting dashboard summary', e);
      rethrow;
    }
  }

  /// Müşteri istatistikleri
  Future<Map<String, dynamic>> _getCustomerStats() async {
    try {
      final customersSnapshot = await _firestore.collection('customers').get();
      final customers = customersSnapshot.docs;

      int totalCustomers = customers.length;
      int activeCustomers =
          customers.where((doc) => doc.data()['isActive'] == true).length;
      int individualCustomers = customers
          .where((doc) => doc.data()['customerType'] == 'individual')
          .length;
      int companyCustomers = customers
          .where((doc) => doc.data()['customerType'] == 'company')
          .length;

      // Bu ay eklenen müşteriler
      final startOfMonth =
          DateTime(DateTime.now().year, DateTime.now().month, 1);
      int newCustomersThisMonth = customers.where((doc) {
        final createdAt = (doc.data()['createdAt'] as Timestamp).toDate();
        return createdAt.isAfter(startOfMonth);
      }).length;

      // Toplam bakiye
      double totalBalance = customers.fold<double>(0, (sum, doc) {
        return sum + ((doc.data()['currentBalance'] ?? 0.0).toDouble());
      });

      return {
        'total': totalCustomers,
        'active': activeCustomers,
        'individual': individualCustomers,
        'company': companyCustomers,
        'newThisMonth': newCustomersThisMonth,
        'totalBalance': totalBalance,
      };
    } catch (e) {
      AppLogger.error('Error getting customer stats', e);
      return {
        'total': 0,
        'active': 0,
        'individual': 0,
        'company': 0,
        'newThisMonth': 0,
        'totalBalance': 0.0,
      };
    }
  }

  /// Ürün istatistikleri
  Future<Map<String, dynamic>> _getProductStats() async {
    try {
      final productsSnapshot = await _firestore.collection('products').get();
      final products = productsSnapshot.docs;

      int totalProducts = products.length;
      int activeProducts =
          products.where((doc) => doc.data()['isActive'] == true).length;
      int lowStockProducts = products.where((doc) {
        final stock = (doc.data()['stockQuantity'] ?? 0).toInt();
        final minStock = (doc.data()['minStockLevel'] ?? 0).toInt();
        return stock <= minStock;
      }).length;
      int outOfStockProducts = products
          .where((doc) => (doc.data()['stockQuantity'] ?? 0).toInt() == 0)
          .length;

      // Toplam stok değeri
      double totalStockValue = products.fold<double>(0, (sum, doc) {
        final stock = (doc.data()['stockQuantity'] ?? 0).toInt();
        final price = (doc.data()['unitPrice'] ?? 0.0).toDouble();
        return sum + (stock * price);
      });

      return {
        'total': totalProducts,
        'active': activeProducts,
        'lowStock': lowStockProducts,
        'outOfStock': outOfStockProducts,
        'totalValue': totalStockValue,
      };
    } catch (e) {
      AppLogger.error('Error getting product stats', e);
      return {
        'total': 0,
        'active': 0,
        'lowStock': 0,
        'outOfStock': 0,
        'totalValue': 0.0,
      };
    }
  }

  /// Satış istatistikleri
  Future<Map<String, dynamic>> _getSalesStats(
      DateTime startDate, DateTime endDate) async {
    try {
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('invoiceDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('invoiceDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final invoices = invoicesSnapshot.docs;

      int totalSales = invoices.length;
      int paidSales =
          invoices.where((doc) => doc.data()['isPaid'] == true).length;
      int pendingSales =
          invoices.where((doc) => doc.data()['isPaid'] == false).length;

      double totalAmount = invoices.fold<double>(0, (sum, doc) {
        return sum + ((doc.data()['totalAmount'] ?? 0.0).toDouble());
      });

      double paidAmount = invoices
          .where((doc) => doc.data()['isPaid'] == true)
          .fold<double>(0, (sum, doc) {
        return sum + ((doc.data()['totalAmount'] ?? 0.0).toDouble());
      });

      double pendingAmount = totalAmount - paidAmount;

      return {
        'total': totalSales,
        'paid': paidSales,
        'pending': pendingSales,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'pendingAmount': pendingAmount,
      };
    } catch (e) {
      AppLogger.error('Error getting sales stats', e);
      return {
        'total': 0,
        'paid': 0,
        'pending': 0,
        'totalAmount': 0.0,
        'paidAmount': 0.0,
        'pendingAmount': 0.0,
      };
    }
  }

  /// Gider istatistikleri
  Future<Map<String, dynamic>> _getExpenseStats(
      DateTime startDate, DateTime endDate) async {
    try {
      final expensesSnapshot = await _firestore
          .collection('expenses')
          .where('expenseDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('expenseDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final expenses = expensesSnapshot.docs;

      int totalExpenses = expenses.length;
      int paidExpenses =
          expenses.where((doc) => doc.data()['status'] == 'paid').length;
      int pendingExpenses =
          expenses.where((doc) => doc.data()['status'] == 'pending').length;

      double totalAmount = expenses.fold<double>(0, (sum, doc) {
        return sum + ((doc.data()['amount'] ?? 0.0).toDouble());
      });

      return {
        'total': totalExpenses,
        'paid': paidExpenses,
        'pending': pendingExpenses,
        'totalAmount': totalAmount,
      };
    } catch (e) {
      AppLogger.error('Error getting expense stats', e);
      return {
        'total': 0,
        'paid': 0,
        'pending': 0,
        'totalAmount': 0.0,
      };
    }
  }

  /// Gelir istatistikleri
  Future<Map<String, dynamic>> _getIncomeStats(
      DateTime startDate, DateTime endDate) async {
    try {
      final incomesSnapshot = await _firestore
          .collection('incomes')
          .where('incomeDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final incomes = incomesSnapshot.docs;

      int totalIncomes = incomes.length;
      int receivedIncomes =
          incomes.where((doc) => doc.data()['status'] == 'received').length;
      int pendingIncomes =
          incomes.where((doc) => doc.data()['status'] == 'pending').length;

      double totalAmount = incomes.fold<double>(0, (sum, doc) {
        return sum + ((doc.data()['amount'] ?? 0.0).toDouble());
      });

      return {
        'total': totalIncomes,
        'received': receivedIncomes,
        'pending': pendingIncomes,
        'totalAmount': totalAmount,
      };
    } catch (e) {
      AppLogger.error('Error getting income stats', e);
      return {
        'total': 0,
        'received': 0,
        'pending': 0,
        'totalAmount': 0.0,
      };
    }
  }

  /// İşlem istatistikleri
  Future<Map<String, dynamic>> _getTransactionStats(
      DateTime startDate, DateTime endDate) async {
    try {
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('transactionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('transactionDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final transactions = transactionsSnapshot.docs;

      int totalTransactions = transactions.length;
      int completedTransactions = transactions
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      int pendingTransactions =
          transactions.where((doc) => doc.data()['status'] == 'pending').length;

      double totalAmount = transactions.fold<double>(0, (sum, doc) {
        return sum + ((doc.data()['amount'] ?? 0.0).toDouble());
      });

      return {
        'total': totalTransactions,
        'completed': completedTransactions,
        'pending': pendingTransactions,
        'totalAmount': totalAmount,
      };
    } catch (e) {
      AppLogger.error('Error getting transaction stats', e);
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'totalAmount': 0.0,
      };
    }
  }

  /// Düşük stoklu ürünler
  Future<List<Map<String, dynamic>>> _getLowStockProducts() async {
    try {
      final productsSnapshot = await _firestore.collection('products').get();

      return productsSnapshot.docs.where((doc) {
        final data = doc.data();
        final stock = (data['stockQuantity'] ?? 0).toInt();
        final minStock = (data['minStockLevel'] ?? 0).toInt();
        return stock <= minStock && data['isActive'] == true;
      }).map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'stock': (data['stockQuantity'] ?? 0).toInt(),
          'minStock': (data['minStockLevel'] ?? 0).toInt(),
          'price': (data['unitPrice'] ?? 0.0).toDouble(),
        };
      }).toList();
    } catch (e) {
      AppLogger.error('Error getting low stock products', e);
      return [];
    }
  }

  /// Vadesi geçmiş faturalar
  Future<List<Map<String, dynamic>>> _getOverdueInvoices() async {
    try {
      final now = DateTime.now();
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('isPaid', isEqualTo: false)
          .get();

      return invoicesSnapshot.docs.where((doc) {
        final data = doc.data();
        final dueDate = data['dueDate'] != null
            ? (data['dueDate'] as Timestamp).toDate()
            : null;
        return dueDate != null && dueDate.isBefore(now);
      }).map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'invoiceNumber': data['invoiceNumber'] ?? '',
          'customerName': data['customerName'] ?? '',
          'totalAmount': (data['totalAmount'] ?? 0.0).toDouble(),
          'dueDate': (data['dueDate'] as Timestamp).toDate(),
          'daysOverdue':
              now.difference((data['dueDate'] as Timestamp).toDate()).inDays,
        };
      }).toList();
    } catch (e) {
      AppLogger.error('Error getting overdue invoices', e);
      return [];
    }
  }

  /// Aylık satış trendi
  Future<List<Map<String, dynamic>>> getMonthlySalesTrend() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);

      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('invoiceDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .get();

      final monthlyData = <String, double>{};

      // Tüm ayları sıfırla
      for (int i = 1; i <= 12; i++) {
        monthlyData['${now.year}-${i.toString().padLeft(2, '0')}'] = 0.0;
      }

      // Satış verilerini aylara göre grupla
      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final invoiceDate = (data['invoiceDate'] as Timestamp).toDate();
        final month =
            '${invoiceDate.year}-${invoiceDate.month.toString().padLeft(2, '0')}';
        final amount = (data['totalAmount'] ?? 0.0).toDouble();

        monthlyData[month] = (monthlyData[month] ?? 0.0) + amount;
      }

      return monthlyData.entries
          .map((entry) => {
                'month': entry.key,
                'amount': entry.value,
              })
          .toList();
    } catch (e) {
      AppLogger.error('Error getting monthly sales trend', e);
      return [];
    }
  }

  /// Kategori bazlı satış analizi
  Future<List<Map<String, dynamic>>> getCategorySalesAnalysis() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('invoiceDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      final categoryData = <String, double>{};

      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'Diğer';
        final amount = (data['totalAmount'] ?? 0.0).toDouble();

        categoryData[category] = (categoryData[category] ?? 0.0) + amount;
      }

      return categoryData.entries
          .map((entry) => {
                'category': entry.key,
                'amount': entry.value,
                'percentage': 0.0, // Hesaplanacak
              })
          .toList();
    } catch (e) {
      AppLogger.error('Error getting category sales analysis', e);
      return [];
    }
  }
}
