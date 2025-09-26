// ========== INVOICE DOCUMENT TYPE ENUM ==========
// lib/features/invoices/domain/entities/invoice_document_type.dart

/// Fatura belge türü enum'u
enum InvoiceDocumentType {
  /// Normal fatura
  invoice,

  /// İrsaliye
  waybill,

  /// Proforma fatura
  proforma,

  /// İade alışı
  returnPurchase,
}

/// InvoiceDocumentType extension'ları
extension InvoiceDocumentTypeExtension on InvoiceDocumentType {
  /// Enum'u string'e çevir
  String get value {
    switch (this) {
      case InvoiceDocumentType.invoice:
        return 'invoice';
      case InvoiceDocumentType.waybill:
        return 'waybill';
      case InvoiceDocumentType.proforma:
        return 'proforma';
      case InvoiceDocumentType.returnPurchase:
        return 'returnPurchase';
    }
  }

  /// String'den enum'a çevir
  static InvoiceDocumentType fromString(String value) {
    switch (value) {
      case 'invoice':
        return InvoiceDocumentType.invoice;
      case 'waybill':
        return InvoiceDocumentType.waybill;
      case 'proforma':
        return InvoiceDocumentType.proforma;
      case 'returnPurchase':
        return InvoiceDocumentType.returnPurchase;
      default:
        return InvoiceDocumentType.invoice;
    }
  }
}
