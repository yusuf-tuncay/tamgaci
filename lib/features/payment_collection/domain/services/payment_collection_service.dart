// ========== PAYMENT COLLECTION SERVICE ==========
// lib/features/payment_collection/domain/services/payment_collection_service.dart

import '../entities/payment_transaction.dart';
import '../entities/payment_enums.dart';
import '../entities/payment_method.dart';
import '../entities/payment_source.dart';

/// Tahsilat ve ödeme işlemleri için ana service
abstract class PaymentCollectionService {
  /// Yeni ödeme işlemi oluştur
  Future<PaymentTransaction> createPaymentTransaction({
    required PaymentTransactionType type,
    required PaymentTransactionCategory category,
    required PaymentDirection direction,
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? description,
    String? referenceNumber,
    String? notes,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    PaymentMethod? paymentMethod,
    PaymentSource? paymentSource,
    String? relatedDocumentId,
    String? relatedDocumentType,
    DateTime? dueDate,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Ödeme işlemi güncelle
  Future<PaymentTransaction> updatePaymentTransaction(
    String id,
    Map<String, dynamic> updates,
  );

  /// Ödeme işlemi sil
  Future<void> deletePaymentTransaction(String id);

  /// Ödeme işlemi durumunu güncelle
  Future<PaymentTransaction> updateTransactionStatus(
    String id,
    PaymentTransactionStatus status,
  );

  /// Ödeme işlemi onayla
  Future<PaymentTransaction> approveTransaction(
    String id,
    String approvedBy,
  );

  /// Ödeme işlemi reddet
  Future<PaymentTransaction> rejectTransaction(
    String id,
    String rejectedBy,
    String reason,
  );

  /// Ödeme işlemi iptal et
  Future<PaymentTransaction> cancelTransaction(
    String id,
    String cancelledBy,
    String reason,
  );

  /// Ödeme işlemi geri al
  Future<PaymentTransaction> reverseTransaction(
    String id,
    String reversedBy,
    String reason,
  );

  /// Nakit ödeme işlemi
  Future<PaymentTransaction> processCashPayment({
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? description,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Kredi kartı ödeme işlemi
  Future<PaymentTransaction> processCreditCardPayment({
    required double amount,
    required String currency,
    required DateTime transactionDate,
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String cvv,
    String? description,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// EFT/Havale işlemi
  Future<PaymentTransaction> processEFTTransfer({
    required double amount,
    required String currency,
    required DateTime transactionDate,
    required String bankName,
    required String accountNumber,
    required String iban,
    String? description,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Çek işlemi
  Future<PaymentTransaction> processCheckPayment({
    required double amount,
    required String currency,
    required DateTime transactionDate,
    required DateTime dueDate,
    required String checkNumber,
    required String bankName,
    required String branchName,
    required String accountNumber,
    String? iban,
    String? description,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Senet işlemi
  Future<PaymentTransaction> processPromissoryNote({
    required double amount,
    required String currency,
    required DateTime transactionDate,
    required DateTime dueDate,
    required String noteNumber,
    double? interestRate,
    String? description,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Borç fişi işlemi
  Future<PaymentTransaction> processDebtReceipt({
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? description,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Alacak fişi işlemi
  Future<PaymentTransaction> processCreditReceipt({
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? description,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Cari virman işlemi
  Future<PaymentTransaction> processAccountTransfer({
    required double amount,
    required String currency,
    required DateTime transactionDate,
    required String fromAccountId,
    required String toAccountId,
    String? description,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Müşteri tahsilatı
  Future<PaymentTransaction> processCustomerPayment({
    required String customerId,
    required double amount,
    required String currency,
    required PaymentTransactionType type,
    required DateTime transactionDate,
    String? description,
    String? sourceAccountId,
    String? targetAccountId,
    PaymentMethod? paymentMethod,
    PaymentSource? paymentSource,
    String? relatedDocumentId,
    String? relatedDocumentType,
    DateTime? dueDate,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Tedarikçi ödemesi
  Future<PaymentTransaction> processSupplierPayment({
    required String supplierId,
    required double amount,
    required String currency,
    required PaymentTransactionType type,
    required DateTime transactionDate,
    String? description,
    String? sourceAccountId,
    String? targetAccountId,
    PaymentMethod? paymentMethod,
    PaymentSource? paymentSource,
    String? relatedDocumentId,
    String? relatedDocumentType,
    DateTime? dueDate,
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// İşlem doğrula
  Future<bool> validateTransaction(PaymentTransaction transaction);

  /// İlişki doğrula
  Future<bool> validateRelationships(PaymentTransaction transaction);

  /// Müşteri ilişkisini doğrula
  Future<bool> validateCustomerRelationship(String customerId);

  /// Tedarikçi ilişkisini doğrula
  Future<bool> validateSupplierRelationship(String supplierId);

  /// Gelir fişi ilişkisini doğrula
  Future<bool> validateRevenueRelationship(String revenueId);

  /// Gider fişi ilişkisini doğrula
  Future<bool> validateExpenseRelationship(String expenseId);

  /// Hesap ilişkisini doğrula
  Future<bool> validateAccountRelationship(String accountId);

  /// Ödeme yöntemi ilişkisini doğrula
  Future<bool> validatePaymentMethodRelationship(String paymentMethodId);

  /// Ödeme kaynağı ilişkisini doğrula
  Future<bool> validatePaymentSourceRelationship(String paymentSourceId);

  /// İşlem onay seviyesi kontrolü
  Future<bool> checkApprovalRequired(
    PaymentTransaction transaction,
    PaymentMethod paymentMethod,
  );

  /// Limit kontrolü
  Future<bool> checkLimits(
    PaymentTransaction transaction,
    PaymentSource paymentSource,
  );

  /// Bakiye kontrolü
  Future<bool> checkBalance(
    PaymentSource paymentSource,
    double amount,
  );

  /// İşlem numarası oluştur
  Future<String> generateTransactionNumber({
    PaymentTransactionType? type,
    String? companyId,
    String? tenantId,
  });

  /// İşlem özeti
  Future<Map<String, dynamic>> getTransactionSummary(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// Müşteri işlem özeti
  Future<Map<String, dynamic>> getCustomerTransactionSummary(
    String customerId, {
    String? companyId,
    String? tenantId,
  });

  /// Tedarikçi işlem özeti
  Future<Map<String, dynamic>> getSupplierTransactionSummary(
    String supplierId, {
    String? companyId,
    String? tenantId,
  });

  /// Hesap işlem özeti
  Future<Map<String, dynamic>> getAccountTransactionSummary(
    String accountId, {
    String? companyId,
    String? tenantId,
  });

  /// Günlük işlem özeti
  Future<Map<String, dynamic>> getDailyTransactionSummary(
    DateTime date, {
    String? companyId,
    String? tenantId,
  });

  /// Aylık işlem özeti
  Future<Map<String, dynamic>> getMonthlyTransactionSummary(
    int year,
    int month, {
    String? companyId,
    String? tenantId,
  });

  /// Yıllık işlem özeti
  Future<Map<String, dynamic>> getYearlyTransactionSummary(
    int year, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem raporu
  Future<Map<String, dynamic>> generateTransactionReport({
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
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    String? currency,
  });

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
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
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
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    String? currency,
  });

  /// Toplu işlem oluştur
  Future<List<PaymentTransaction>> createBulkTransactions(
    List<Map<String, dynamic>> transactionData, {
    String? companyId,
    String? tenantId,
    String? createdBy,
  });

  /// Toplu işlem güncelle
  Future<List<PaymentTransaction>> updateBulkTransactions(
    List<Map<String, dynamic>> transactionUpdates,
  );

  /// Toplu işlem sil
  Future<void> deleteBulkTransactions(List<String> ids);

  /// Toplu işlem onayla
  Future<List<PaymentTransaction>> approveBulkTransactions(
    List<String> ids,
    String approvedBy,
  );

  /// Toplu işlem reddet
  Future<List<PaymentTransaction>> rejectBulkTransactions(
    List<String> ids,
    String rejectedBy,
    String reason,
  );

  /// Toplu işlem iptal et
  Future<List<PaymentTransaction>> cancelBulkTransactions(
    List<String> ids,
    String cancelledBy,
    String reason,
  );

  /// Toplu işlem geri al
  Future<List<PaymentTransaction>> reverseBulkTransactions(
    List<String> ids,
    String reversedBy,
    String reason,
  );

  /// İşlem senkronizasyonu
  Future<void> syncTransactions({
    String? companyId,
    String? tenantId,
  });

  /// İşlem yedekleme
  Future<String> backupTransactions({
    String? companyId,
    String? tenantId,
  });

  /// İşlem geri yükleme
  Future<void> restoreTransactions(String backupId);

  /// İşlem temizleme
  Future<void> cleanupTransactions({
    String? companyId,
    String? tenantId,
  });

  /// İşlem arşivleme
  Future<void> archiveTransactions({
    String? companyId,
    String? tenantId,
  });

  /// İşlem geri alma
  Future<void> unarchiveTransactions({
    String? companyId,
    String? tenantId,
  });

  /// İşlem kalıcı silme
  Future<void> permanentlyDeleteTransactions(List<String> ids);

  /// İşlem istatistikleri
  Future<Map<String, dynamic>> getTransactionStatistics({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// İşlem performans analizi
  Future<Map<String, dynamic>> analyzeTransactionPerformance({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// İşlem güvenlik analizi
  Future<Map<String, dynamic>> analyzeTransactionSecurity({
    String? companyId,
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// İşlem uyumluluk kontrolü
  Future<Map<String, dynamic>> checkTransactionCompatibility({
    String? companyId,
    String? tenantId,
  });

  /// İşlem migrasyon
  Future<void> migrateTransactions({
    String? companyId,
    String? tenantId,
  });

  /// İşlem optimizasyonu
  Future<void> optimizeTransactions({
    String? companyId,
    String? tenantId,
  });

  /// İşlem önerileri
  Future<List<Map<String, dynamic>>> getTransactionRecommendations({
    String? companyId,
    String? tenantId,
  });

  /// İşlem uyarıları
  Future<List<Map<String, dynamic>>> getTransactionAlerts({
    String? companyId,
    String? tenantId,
  });

  /// İşlem bildirimleri
  Future<List<Map<String, dynamic>>> getTransactionNotifications({
    String? companyId,
    String? tenantId,
  });

  /// İşlem geçmişi
  Future<List<Map<String, dynamic>>> getTransactionHistory(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem değişiklikleri
  Future<List<Map<String, dynamic>>> getTransactionChanges(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem versiyonları
  Future<List<Map<String, dynamic>>> getTransactionVersions(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem karşılaştırma
  Future<Map<String, dynamic>> compareTransactions(
    String id1,
    String id2, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem bağımlılıkları
  Future<List<String>> getTransactionDependencies(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem kullanım yerleri
  Future<List<String>> getTransactionUsageLocations(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem etkisi analizi
  Future<Map<String, dynamic>> analyzeTransactionImpact(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem rollback
  Future<PaymentTransaction> rollbackTransaction(
    String id,
    String version, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem güncelleme kontrolü
  Future<bool> checkForTransactionUpdates(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem güncelleme
  Future<PaymentTransaction> updateTransactionVersion(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem sağlık kontrolü
  Future<Map<String, dynamic>> getTransactionHealthCheck(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem durumu
  Future<Map<String, dynamic>> getTransactionStatus(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem test
  Future<bool> testTransaction(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem doğrulama
  Future<Map<String, dynamic>> validateTransactionSettings(
    PaymentTransaction transaction, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem senkronizasyonu
  Future<void> syncTransaction(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem yedekleme
  Future<String> backupTransaction(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem geri yükleme
  Future<PaymentTransaction> restoreTransaction(
    String backupId, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem temizleme
  Future<void> cleanupTransaction(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem arşivleme
  Future<void> archiveTransaction(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem geri alma
  Future<PaymentTransaction> unarchiveTransaction(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// İşlem kalıcı silme
  Future<void> permanentlyDeleteTransaction(
    String id, {
    String? companyId,
    String? tenantId,
  });

  /// Müşteri silindiğinde işlemleri soft delete yap
  Future<void> handleCustomerDeletion(String customerId);

  /// Tedarikçi silindiğinde işlemleri soft delete yap
  Future<void> handleSupplierDeletion(String supplierId);

  /// Gelir fişi silindiğinde işlemleri soft delete yap
  Future<void> handleRevenueDeletion(String revenueId);

  /// Gider fişi silindiğinde işlemleri soft delete yap
  Future<void> handleExpenseDeletion(String expenseId);

  /// Hesap silindiğinde işlemleri soft delete yap
  Future<void> handleAccountDeletion(String accountId);

  /// Ödeme yöntemi silindiğinde işlemleri soft delete yap
  Future<void> handlePaymentMethodDeletion(String paymentMethodId);

  /// Ödeme kaynağı silindiğinde işlemleri soft delete yap
  Future<void> handlePaymentSourceDeletion(String paymentSourceId);

  /// İlişki senkronizasyonu
  Future<void> syncRelationships(String transactionId);

  /// Tüm ilişkileri senkronize et
  Future<void> syncAllRelationships({
    String? companyId,
    String? tenantId,
  });

  /// İlişki tutarlılığını kontrol et
  Future<Map<String, dynamic>> checkRelationshipConsistency({
    String? companyId,
    String? tenantId,
  });

  /// İlişki tutarsızlıklarını düzelt
  Future<void> fixRelationshipInconsistencies({
    String? companyId,
    String? tenantId,
  });
}
