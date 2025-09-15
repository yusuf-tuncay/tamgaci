// ========== CUSTOMER TRANSACTION SERVICE ==========
// lib/features/customers/data/services/customer_transaction_service.dart

// import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction; // Removed - not needed
import 'package:tamgaci/core/services/business/transaction_service.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// Müşteri işlem servisi
class CustomerTransactionService {
  final TransactionService _transactionService = TransactionService();

  /// Müşteri işlemlerini getirme
  Future<List<Transaction>> getCustomerTransactions(String customerId) async {
    try {
      return await _transactionService.getCustomerTransactions(customerId);
    } catch (e) {
      AppLogger.error('Error getting customer transactions', e);
      rethrow;
    }
  }

  /// Müşteri işlemlerini stream olarak getirme
  Stream<List<Transaction>> watchCustomerTransactions(String customerId) {
    return _transactionService.watchCustomerTransactions(customerId);
  }

  /// Müşteri işlem özeti
  Future<Map<String, dynamic>> getCustomerTransactionSummary(
      String customerId) async {
    try {
      final transactions = await getCustomerTransactions(customerId);

      double totalSales = 0.0;
      double totalPayments = 0.0;
      double totalRefunds = 0.0;
      int transactionCount = transactions.length;

      for (final transaction in transactions) {
        switch (transaction.type) {
          case TransactionType.sale:
          case TransactionType.invoice:
            totalSales += transaction.amount;
            break;
          case TransactionType.payment:
            totalPayments += transaction.amount;
            break;
          case TransactionType.refund:
          case TransactionType.credit:
            totalRefunds += transaction.amount;
            break;
          default:
            break;
        }
      }

      final currentBalance = totalSales - totalPayments + totalRefunds;

      return {
        'totalSales': totalSales,
        'totalPayments': totalPayments,
        'totalRefunds': totalRefunds,
        'currentBalance': currentBalance,
        'transactionCount': transactionCount,
        'lastTransactionDate':
            transactions.isNotEmpty ? transactions.first.transactionDate : null,
      };
    } catch (e) {
      AppLogger.error('Error getting customer transaction summary', e);
      rethrow;
    }
  }

  /// Müşteri işlem geçmişi (tarih aralığına göre)
  Future<List<Transaction>> getCustomerTransactionHistory(
    String customerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _transactionService.getTransactionsByDateRange(
        startDate,
        endDate,
        customerId: customerId,
      );
    } catch (e) {
      AppLogger.error('Error getting customer transaction history', e);
      rethrow;
    }
  }

  /// Müşteri bakiyesini hesaplama
  Future<double> calculateCustomerBalance(String customerId) async {
    try {
      return await _transactionService.calculateCustomerBalance(customerId);
    } catch (e) {
      AppLogger.error('Error calculating customer balance', e);
      rethrow;
    }
  }

  /// Müşteri işlem ekleme
  Future<String> addCustomerTransaction({
    required String customerId,
    required TransactionType type,
    required double amount,
    required String currency,
    String? description,
    String? reference,
    DateTime? transactionDate,
    DateTime? dueDate,
    String? invoiceId,
    String? paymentMethod,
    String? documentNumber,
    String? companyId,
    String? createdBy,
  }) async {
    try {
      final transaction = Transaction(
        id: '', // TransactionService tarafından oluşturulacak
        customerId: customerId,
        type: type,
        amount: amount,
        currency: currency,
        description: description,
        reference: reference,
        transactionDate: transactionDate ?? DateTime.now(),
        dueDate: dueDate,
        invoiceId: invoiceId,
        paymentMethod: paymentMethod,
        documentNumber: documentNumber,
        status: TransactionStatus.completed,
        companyId: companyId ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: createdBy ?? 'system',
      );

      return await _transactionService.createTransaction(transaction);
    } catch (e) {
      AppLogger.error('Error adding customer transaction', e);
      rethrow;
    }
  }

  /// Müşteri işlem güncelleme
  Future<void> updateCustomerTransaction(Transaction transaction) async {
    try {
      await _transactionService.updateTransaction(transaction);
    } catch (e) {
      AppLogger.error('Error updating customer transaction', e);
      rethrow;
    }
  }

  /// Müşteri işlem silme
  Future<void> deleteCustomerTransaction(String transactionId) async {
    try {
      await _transactionService.deleteTransaction(transactionId);
    } catch (e) {
      AppLogger.error('Error deleting customer transaction', e);
      rethrow;
    }
  }

  /// Müşteri ödeme kaydı
  Future<String> recordCustomerPayment({
    required String customerId,
    required double amount,
    required String currency,
    String? description,
    String? reference,
    String? paymentMethod,
    String? invoiceId,
    String? companyId,
    String? createdBy,
  }) async {
    try {
      return await addCustomerTransaction(
        customerId: customerId,
        type: TransactionType.payment,
        amount: amount,
        currency: currency,
        description: description ?? 'Müşteri ödemesi',
        reference: reference,
        paymentMethod: paymentMethod,
        invoiceId: invoiceId,
        companyId: companyId,
        createdBy: createdBy,
      );
    } catch (e) {
      AppLogger.error('Error recording customer payment', e);
      rethrow;
    }
  }

  /// Müşteri satış kaydı
  Future<String> recordCustomerSale({
    required String customerId,
    required double amount,
    required String currency,
    String? description,
    String? reference,
    String? invoiceId,
    String? documentNumber,
    DateTime? dueDate,
    String? companyId,
    String? createdBy,
  }) async {
    try {
      return await addCustomerTransaction(
        customerId: customerId,
        type: TransactionType.sale,
        amount: amount,
        currency: currency,
        description: description ?? 'Müşteri satışı',
        reference: reference,
        invoiceId: invoiceId,
        documentNumber: documentNumber,
        dueDate: dueDate,
        companyId: companyId,
        createdBy: createdBy,
      );
    } catch (e) {
      AppLogger.error('Error recording customer sale', e);
      rethrow;
    }
  }

  /// Müşteri iade kaydı
  Future<String> recordCustomerRefund({
    required String customerId,
    required double amount,
    required String currency,
    String? description,
    String? reference,
    String? invoiceId,
    String? companyId,
    String? createdBy,
  }) async {
    try {
      return await addCustomerTransaction(
        customerId: customerId,
        type: TransactionType.refund,
        amount: amount,
        currency: currency,
        description: description ?? 'Müşteri iadesi',
        reference: reference,
        invoiceId: invoiceId,
        companyId: companyId,
        createdBy: createdBy,
      );
    } catch (e) {
      AppLogger.error('Error recording customer refund', e);
      rethrow;
    }
  }
}
