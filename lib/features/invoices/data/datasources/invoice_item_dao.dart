// ========== lib/features/invoices/data/datasources/invoice_item_dao.dart ==========

import 'package:floor/floor.dart';
import '../models/invoice_item_entity.dart';

/// Fatura kalemi Data Access Object (DAO)
@dao
abstract class InvoiceItemDao {
  
  // ========== CREATE (OLUŞTURMA) ==========
  
  /// Yeni fatura kalemi ekleme
  @Insert()
  Future<void> insertInvoiceItem(InvoiceItemEntity item);

  /// Birden fazla fatura kalemi ekleme
  @Insert()
  Future<void> insertInvoiceItems(List<InvoiceItemEntity> items);

  // ========== READ (OKUMA) ==========
  
  /// Fatura ID'sine göre kalemleri getirme
  @Query('SELECT * FROM invoice_items WHERE invoice_id = :invoiceId ORDER BY item_order ASC')
  Future<List<InvoiceItemEntity>> getInvoiceItemsByInvoiceId(String invoiceId);

  /// ID ile fatura kalemi getirme
  @Query('SELECT * FROM invoice_items WHERE id = :id')
  Future<InvoiceItemEntity?> getInvoiceItemById(String id);

  /// Faturadaki toplam kalem sayısı
  @Query('SELECT COUNT(*) FROM invoice_items WHERE invoice_id = :invoiceId')
  Future<int?> getItemCountByInvoiceId(String invoiceId);



  // ========== UPDATE (GÜNCELLEME) ==========
  
  /// Fatura kalemi güncelleme
  @Update()
  Future<void> updateInvoiceItem(InvoiceItemEntity item);

  /// Kalem tutarını güncelleme
  @Query('''
    UPDATE invoice_items 
    SET unit_price = :unitPrice,
        tax_amount = :taxAmount,
        line_total = :lineTotal
    WHERE id = :id
  ''')
  Future<void> updateInvoiceItemAmounts(String id, int unitPrice, int taxAmount, int lineTotal);

  // ========== DELETE (SİLME) ==========
  
  /// Fatura kalemi silme
  @delete
  Future<void> deleteInvoiceItem(InvoiceItemEntity item);

  /// ID ile fatura kalemi silme
  @Query('DELETE FROM invoice_items WHERE id = :id')
  Future<void> deleteInvoiceItemById(String id);

  /// Faturanın tüm kalemlerini silme
  @Query('DELETE FROM invoice_items WHERE invoice_id = :invoiceId')
  Future<void> deleteInvoiceItemsByInvoiceId(String invoiceId);

  // ========== STREAM (REACTIVE) ==========
  
  /// Fatura kalemlerini stream olarak izleme
  @Query('SELECT * FROM invoice_items WHERE invoice_id = :invoiceId ORDER BY item_order ASC')
  Stream<List<InvoiceItemEntity>> watchInvoiceItemsByInvoiceId(String invoiceId);

  /// Belirli fatura kalemini stream olarak izleme
  @Query('SELECT * FROM invoice_items WHERE id = :id')
  Stream<InvoiceItemEntity?> watchInvoiceItemById(String id);
}