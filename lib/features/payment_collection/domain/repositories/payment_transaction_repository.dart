// ========== PAYMENT TRANSACTION REPOSITORY ==========
// lib/features/payment_collection/domain/repositories/payment_transaction_repository.dart

import '../entities/payment_transaction.dart';
import '../entities/payment_enums.dart';

/// Ödeme işlemi repository interface'i
abstract class PaymentTransactionRepository {
  /// Tüm ödeme işlemlerini getir
  Future<List<PaymentTransaction>> getAllTransactions({
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// ID'ye göre ödeme işlemi getir
  Future<PaymentTransaction?> getTransactionById(String id);

  /// İşlem numarasına göre ödeme işlemi getir
  Future<PaymentTransaction?> getTransactionByNumber(String transactionNumber);

  /// Müşteri işlemlerini getir
  Future<List<PaymentTransaction>> getCustomerTransactions(
    String customerId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Tedarikçi işlemlerini getir
  Future<List<PaymentTransaction>> getSupplierTransactions(
    String supplierId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Tarih aralığına göre işlemleri getir
  Future<List<PaymentTransaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// İşlem türüne göre işlemleri getir
  Future<List<PaymentTransaction>> getTransactionsByType(
    PaymentTransactionType type, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// İşlem kategorisine göre işlemleri getir
  Future<List<PaymentTransaction>> getTransactionsByCategory(
    PaymentTransactionCategory category, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// İşlem durumuna göre işlemleri getir
  Future<List<PaymentTransaction>> getTransactionsByStatus(
    PaymentTransactionStatus status, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// İşlem yönüne göre işlemleri getir
  Future<List<PaymentTransaction>> getTransactionsByDirection(
    PaymentDirection direction, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Hesap işlemlerini getir
  Future<List<PaymentTransaction>> getAccountTransactions(
    String accountId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Gelir fişi işlemlerini getir
  Future<List<PaymentTransaction>> getRevenueTransactions(
    String revenueId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Gider fişi işlemlerini getir
  Future<List<PaymentTransaction>> getExpenseTransactions(
    String expenseId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Ödeme yöntemi işlemlerini getir
  Future<List<PaymentTransaction>> getPaymentMethodTransactions(
    String paymentMethodId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Ödeme kaynağı işlemlerini getir
  Future<List<PaymentTransaction>> getPaymentSourceTransactions(
    String paymentSourceId, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Bekleyen işlemleri getir
  Future<List<PaymentTransaction>> getPendingTransactions({
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Vadesi geçmiş işlemleri getir
  Future<List<PaymentTransaction>> getOverdueTransactions({
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Arama yap
  Future<List<PaymentTransaction>> searchTransactions(
    String query, {
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  });

  /// Filtreleme ile işlemleri getir
  Future<List<PaymentTransaction>> getFilteredTransactions({
    String? companyId,
    String? tenantId,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? currency,
    int? limit,
    int? offset,
  });

  /// Ödeme işlemi oluştur
  Future<PaymentTransaction> createTransaction(PaymentTransaction transaction);

  /// Ödeme işlemi güncelle
  Future<PaymentTransaction> updateTransaction(PaymentTransaction transaction);

  /// Ödeme işlemi sil
  Future<void> deleteTransaction(String id);

  /// Ödeme işlemi durumunu güncelle
  Future<PaymentTransaction> updateTransactionStatus(
    String id,
    PaymentTransactionStatus status,
  );

  /// Toplam tutar hesapla
  Future<double> calculateTotalAmount({
    String? companyId,
    String? tenantId,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
  });

  /// İşlem sayısını getir
  Future<int> getTransactionCount({
    String? companyId,
    String? tenantId,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
  });

  /// Günlük işlem özeti
  Future<Map<String, dynamic>> getDailySummary(
    DateTime date, {
    String? companyId,
    String? tenantId,
  });

  /// Aylık işlem özeti
  Future<Map<String, dynamic>> getMonthlySummary(
    int year,
    int month, {
    String? companyId,
    String? tenantId,
  });

  /// Yıllık işlem özeti
  Future<Map<String, dynamic>> getYearlySummary(
    int year, {
    String? companyId,
    String? tenantId,
  });

  /// Müşteri bakiye özeti
  Future<Map<String, dynamic>> getCustomerBalanceSummary(
    String customerId, {
    String? companyId,
    String? tenantId,
  });

  /// Tedarikçi bakiye özeti
  Future<Map<String, dynamic>> getSupplierBalanceSummary(
    String supplierId, {
    String? companyId,
    String? tenantId,
  });

  /// Hesap bakiye özeti
  Future<Map<String, dynamic>> getAccountBalanceSummary(
    String accountId, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem istatistikleri
  Future<Map<String, dynamic>> getTransactionStatistics({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Rapor verileri
  Future<Map<String, dynamic>> getReportData({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? accountId,
    String? currency,
  });

  /// Toplu işlem oluştur
  Future<List<PaymentTransaction>> createBulkTransactions(
    List<PaymentTransaction> transactions,
  );

  /// Toplu işlem güncelle
  Future<List<PaymentTransaction>> updateBulkTransactions(
    List<PaymentTransaction> transactions,
  );

  /// Toplu işlem sil
  Future<void> deleteBulkTransactions(List<String> ids);

  /// İşlem numarası oluştur
  Future<String> generateTransactionNumber({
    PaymentTransactionType? type,
    String? companyId,
    String? tenantId,
  });

  /// İşlem doğrula
  Future<bool> validateTransaction(PaymentTransaction transaction);

  /// İşlem onayla
  Future<PaymentTransaction> approveTransaction(
    String id,
    String approvedBy,
  );

  /// İşlem reddet
  Future<PaymentTransaction> rejectTransaction(
    String id,
    String rejectedBy,
    String reason,
  );

  /// İşlem iptal et
  Future<PaymentTransaction> cancelTransaction(
    String id,
    String cancelledBy,
    String reason,
  );

  /// İşlem geri al
  Future<PaymentTransaction> reverseTransaction(
    String id,
    String reversedBy,
    String reason,
  );

  /// İşlem kopyala
  Future<PaymentTransaction> duplicateTransaction(
    String id,
    String duplicatedBy,
  );

  /// İşlem yazdır
  Future<String> printTransaction(String id);

  /// İşlem PDF oluştur
  Future<String> generateTransactionPDF(String id);

  /// İşlem Excel export
  Future<String> exportTransactionsToExcel({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? accountId,
    String? currency,
  });

  /// İşlem CSV export
  Future<String> exportTransactionsToCSV({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    String? customerId,
    String? supplierId,
    String? accountId,
    String? currency,
  });
}
