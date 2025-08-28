// ========== lib/features/invoices/data/datasources/invoice_dao.dart ==========

import 'package:floor/floor.dart';
import '../models/invoice_entity.dart';

/// Fatura Data Access Object (DAO)
@dao
abstract class InvoiceDao {
  // ========== CREATE (OLUŞTURMA) ==========

  /// Yeni fatura ekleme
  @Insert()
  Future<void> insertInvoice(InvoiceEntity invoice);

  /// Birden fazla fatura ekleme
  @Insert()
  Future<void> insertInvoices(List<InvoiceEntity> invoices);

  // ========== READ (OKUMA) ==========

  /// Tüm faturaları getirme
  @Query('SELECT * FROM invoices ORDER BY created_at DESC')
  Future<List<InvoiceEntity>> getAllInvoices();

  /// ID ile fatura getirme
  @Query('SELECT * FROM invoices WHERE id = :id')
  Future<InvoiceEntity?> getInvoiceById(String id);

  /// Fatura numarası ile fatura getirme
  @Query('SELECT * FROM invoices WHERE invoice_number = :invoiceNumber')
  Future<InvoiceEntity?> getInvoiceByNumber(String invoiceNumber);

  /// Müşteri ID'sine göre faturaları getirme
  @Query(
    'SELECT * FROM invoices WHERE customer_id = :customerId ORDER BY created_at DESC',
  )
  Future<List<InvoiceEntity>> getInvoicesByCustomerId(String customerId);

  /// Duruma göre faturaları getirme
  @Query(
    'SELECT * FROM invoices WHERE status = :status ORDER BY created_at DESC',
  )
  Future<List<InvoiceEntity>> getInvoicesByStatus(String status);

  /// Tarih aralığına göre faturaları getirme
  @Query(
    'SELECT * FROM invoices WHERE invoice_date >= :startDate AND invoice_date <= :endDate ORDER BY invoice_date DESC',
  )
  Future<List<InvoiceEntity>> getInvoicesByDateRange(
    int startDate,
    int endDate,
  );

  /// Ödenmemiş faturaları getirme
  @Query('SELECT * FROM invoices WHERE is_paid = 0 ORDER BY due_date ASC')
  Future<List<InvoiceEntity>> getUnpaidInvoices();

  /// Vadesi geçmiş faturaları getirme
  @Query(
    'SELECT * FROM invoices WHERE is_paid = 0 AND due_date IS NOT NULL AND due_date < :currentDate ORDER BY due_date ASC',
  )
  Future<List<InvoiceEntity>> getOverdueInvoices(int currentDate);

  /// Son faturaları getirme
  @Query('SELECT * FROM invoices ORDER BY created_at DESC LIMIT :limit')
  Future<List<InvoiceEntity>> getRecentInvoices(int limit);

  /// Fatura arama (fatura numarası veya açıklamaya göre)
  @Query('''
    SELECT * FROM invoices 
    WHERE invoice_number LIKE :searchTerm 
    OR description LIKE :searchTerm 
    ORDER BY created_at DESC
  ''')
  Future<List<InvoiceEntity>> searchInvoices(String searchTerm);

  /// Toplam fatura sayısını getirme
  @Query('SELECT COUNT(*) FROM invoices')
  Future<int?> getTotalInvoiceCount();

  /// Duruma göre fatura sayısını getirme
  @Query('SELECT COUNT(*) FROM invoices WHERE status = :status')
  Future<int?> getInvoiceCountByStatus(String status);

  // ========== UPDATE (GÜNCELLEME) ==========

  /// Fatura güncelleme
  @Update()
  Future<void> updateInvoice(InvoiceEntity invoice);

  /// Fatura durumunu güncelleme
  @Query(
    'UPDATE invoices SET status = :status, updated_at = :updatedAt WHERE id = :id',
  )
  Future<void> updateInvoiceStatus(String id, String status, int updatedAt);

  /// Fatura ödeme durumunu güncelleme
  @Query(
    'UPDATE invoices SET is_paid = :isPaid, paidDate = CASE WHEN :paidDate IS NOT NULL THEN  :paidDate, status = :status, updated_at = :updatedAt WHERE id = :id',
  )
  Future<void> updateInvoicePaymentStatus(
    String id,
    bool isPaid,
    int paidDate,
    String status,
    int updatedAt,
  );

  /// Fatura tutarlarını güncelleme
  @Query('''
    UPDATE invoices 
    SET subtotal = :subtotal, 
        tax_amount = :taxAmount, 
        discount_amount = :discountAmount, 
        total_amount = :totalAmount,
        updated_at = :updatedAt
    WHERE id = :id
  ''')
  Future<void> updateInvoiceAmounts(
    String id,
    int subtotal,
    int taxAmount,
    int discountAmount,
    int totalAmount,
    int updatedAt,
  );

  // ========== DELETE (SİLME) ==========

  /// Fatura silme (fiziksel)
  @delete
  Future<void> deleteInvoice(InvoiceEntity invoice);

  /// ID ile fatura silme
  @Query('DELETE FROM invoices WHERE id = :id')
  Future<void> deleteInvoiceById(String id);

  /// Müşterinin tüm faturalarını silme
  @Query('DELETE FROM invoices WHERE customer_id = :customerId')
  Future<void> deleteInvoicesByCustomerId(String customerId);

  /// Belirli durumda faturalar silme
  @Query('DELETE FROM invoices WHERE status = :status')
  Future<void> deleteInvoicesByStatus(String status);

  // ========== STREAM (REACTIVE) ==========

  /// Tüm faturaları stream olarak izleme
  @Query('SELECT * FROM invoices ORDER BY created_at DESC')
  Stream<List<InvoiceEntity>> watchAllInvoices();

  /// Belirli faturayı stream olarak izleme
  @Query('SELECT * FROM invoices WHERE id = :id')
  Stream<InvoiceEntity?> watchInvoiceById(String id);

  /// Müşteri faturalarını stream olarak izleme
  @Query(
    'SELECT * FROM invoices WHERE customer_id = :customerId ORDER BY created_at DESC',
  )
  Stream<List<InvoiceEntity>> watchInvoicesByCustomerId(String customerId);

  /// Duruma göre faturaları stream olarak izleme
  @Query(
    'SELECT * FROM invoices WHERE status = :status ORDER BY created_at DESC',
  )
  Stream<List<InvoiceEntity>> watchInvoicesByStatus(String status);

  /// Ödenmemiş faturaları stream olarak izleme
  @Query('SELECT * FROM invoices WHERE is_paid = 0 ORDER BY due_date ASC')
  Stream<List<InvoiceEntity>> watchUnpaidInvoices();

  // ========== İSTATİSTİK SORGULARI ==========

  /// Toplam gelir
  @Query('SELECT SUM(total_amount) FROM invoices WHERE is_paid = 1')
  Future<int?> getTotalRevenue();

  /// Bu ay gelir
  @Query('''
    SELECT SUM(total_amount) 
    FROM invoices 
    WHERE is_paid = 1 
    AND strftime('%Y-%m', datetime(invoice_date / 1000, 'unixepoch')) = strftime('%Y-%m', 'now')
  ''')
  Future<int?> getCurrentMonthRevenue();

  /// Bekleyen ödeme tutarı
  @Query('SELECT SUM(total_amount) FROM invoices WHERE is_paid = 0')
  Future<int?> getPendingPaymentAmount();
}
