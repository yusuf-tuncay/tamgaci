// ========== lib/features/invoices/domain/repositories/invoice_repository.dart ==========

import 'package:tamgaci/features/invoices/data/models/invoice_status.dart';
import 'package:tamgaci/features/invoices/domain/entities/invoice.dart';
import 'package:tamgaci/features/invoices/domain/entities/invoice_item.dart';

/// Fatura repository interface'i - Domain katmanı
abstract class InvoiceRepository {
  // ========== CREATE ==========

  /// Yeni fatura oluşturma (kalemlerle birlikte)
  Future<String> createInvoice(Invoice invoice, List<InvoiceItem> items);

  /// Fatura kalemine ekleme
  Future<void> addInvoiceItem(InvoiceItem item);

  /// Birden fazla kalem ekleme
  Future<void> addInvoiceItems(List<InvoiceItem> items);

  // ========== READ ==========

  /// Tüm faturaları getirme
  Future<List<Invoice>> getAllInvoices({bool includeItems = false});

  /// ID ile fatura getirme
  Future<Invoice?> getInvoiceById(String id, {bool includeItems = true});

  /// Fatura numarası ile getirme
  Future<Invoice?> getInvoiceByNumber(
    String number, {
    bool includeItems = true,
  });

  /// Müşteri ID'sine göre faturaları getirme
  Future<List<Invoice>> getInvoicesByCustomerId(
    String customerId, {
    bool includeItems = false,
  });

  /// Duruma göre faturaları getirme
  Future<List<Invoice>> getInvoicesByStatus(
    InvoiceStatus status, {
    bool includeItems = false,
  });

  /// Tarih aralığına göre faturaları getirme
  Future<List<Invoice>> getInvoicesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeItems = false,
  });

  /// Ödenmemiş faturaları getirme
  Future<List<Invoice>> getUnpaidInvoices({bool includeItems = false});

  /// Vadesi geçmiş faturaları getirme
  Future<List<Invoice>> getOverdueInvoices({bool includeItems = false});

  /// Son faturaları getirme
  Future<List<Invoice>> getRecentInvoices({
    int limit = 10,
    bool includeItems = false,
  });

  /// Fatura arama
  Future<List<Invoice>> searchInvoices(
    String query, {
    bool includeItems = false,
  });

  /// Fatura sayısını getirme
  Future<int> getTotalInvoiceCount();

  /// Duruma göre fatura sayısını getirme
  Future<int> getInvoiceCountByStatus(InvoiceStatus status);

  // ========== UPDATE ==========

  /// Fatura güncelleme
  Future<void> updateInvoice(Invoice invoice);

  /// Fatura durumunu güncelleme
  Future<void> updateInvoiceStatus(String id, InvoiceStatus status);

  /// Fatura ödeme durumunu güncelleme
  Future<void> markInvoiceAsPaid(String id, {DateTime? paidDate});

  /// Fatura kalemini güncelleme
  Future<void> updateInvoiceItem(InvoiceItem item);

  /// Fatura tutarlarını yeniden hesaplama
  Future<void> recalculateInvoiceAmounts(String invoiceId);

  // ========== DELETE ==========

  /// Fatura silme
  Future<void> deleteInvoice(String id);

  /// Fatura kalemini silme
  Future<void> deleteInvoiceItem(String itemId);

  /// Faturanın tüm kalemlerini silme
  Future<void> deleteAllInvoiceItems(String invoiceId);

  // ========== STREAM/REACTIVE ==========

  /// Tüm faturaları stream olarak izleme
  Stream<List<Invoice>> watchAllInvoices();

  /// Belirli faturayı stream olarak izleme
  Stream<Invoice?> watchInvoiceById(String id);

  /// Müşteri faturalarını stream olarak izleme
  Stream<List<Invoice>> watchInvoicesByCustomerId(String customerId);

  /// Duruma göre faturaları stream olarak izleme
  Stream<List<Invoice>> watchInvoicesByStatus(InvoiceStatus status);

  /// Ödenmemiş faturaları stream olarak izleme
  Stream<List<Invoice>> watchUnpaidInvoices();

  // ========== İSTATİSTİKLER ==========

  /// Toplam gelir
  Future<double> getTotalRevenue();

  /// Bu ay gelir
  Future<double> getCurrentMonthRevenue();

  /// Bekleyen ödeme tutarı
  Future<double> getPendingPaymentAmount();

  // ========== UTILITY ==========

  /// Sonraki fatura numarasını getirme
  Future<String> getNextInvoiceNumber({String prefix = 'FAT'});

  /// Faturanın PDF'ini oluşturma (gelecek için)
  Future<List<int>?> generateInvoicePDF(String invoiceId);

  /// E-posta gönderme (gelecek için)
  Future<bool> sendInvoiceByEmail(String invoiceId, String toEmail);
}

// ========== DOSYA YERLEŞTİRME TALİMATLARI ==========

/*
📁 Bu dosyaların yerleştirilmesi gereken konumlar:

1. 📄 invoice.dart (domain entity)
   → lib/features/invoices/domain/entities/invoice.dart

2. 📄 invoice_item.dart (domain entity)  
   → lib/features/invoices/domain/entities/invoice_item.dart

3. 📄 invoice_repository.dart (interface)
   → lib/features/invoices/domain/repositories/invoice_repository.dart

========== ÖNEMLİ NOTLAR ==========

✅ Business logic entity'lerde
✅ Money handling (kuruş/lira conversion)
✅ DateTime proper handling  
✅ Proper nullability
✅ Copy with methods
✅ Calculation methods
✅ Status management
✅ Validation logic
✅ Formatting methods
✅ Clean architecture uyumlu

Bu domain layer production-ready ve business rules içeriyor! 💼

Sonraki adım: Repository implementation ve Riverpod providers 🚀
*/
