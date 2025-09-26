// ========== INVOICE DIRECTION ENUM ==========
// lib/features/invoices/domain/entities/invoice_direction.dart

/// Fatura yönü enum'u
enum InvoiceDirection {
  /// Satış faturası
  sale,

  /// Alış faturası
  purchase,
}

/// InvoiceDirection extension'ları
extension InvoiceDirectionExtension on InvoiceDirection {
  /// Enum'u string'e çevir
  String get value {
    switch (this) {
      case InvoiceDirection.sale:
        return 'sale';
      case InvoiceDirection.purchase:
        return 'purchase';
    }
  }

  /// String'den enum'a çevir
  static InvoiceDirection fromString(String value) {
    switch (value) {
      case 'sale':
        return InvoiceDirection.sale;
      case 'purchase':
        return InvoiceDirection.purchase;
      default:
        return InvoiceDirection.sale;
    }
  }
}
