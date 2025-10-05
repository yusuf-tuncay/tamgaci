import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/invoices/domain/entities/invoice.dart' as inv;
import 'package:tamgaci/features/invoices/domain/entities/invoice_item.dart'
    as inv_item;
import 'package:tamgaci/features/invoices/data/models/invoice_status.dart'
    as inv_status;

/// Unified invoice converter service - hem satış hem alış için
class UnifiedInvoiceConverter {
  /// Sale'ı Invoice'a dönüştür
  static inv.Invoice convertSaleToInvoice(Sale sale) {
    final invoiceItems = sale.items.asMap().entries.map((entry) {
      final index = entry.key;
      final saleItem = entry.value;
      return inv_item.InvoiceItem(
        id: '',
        invoiceId: '',
        itemOrder: index + 1,
        productId: saleItem.productId,
        productName: saleItem.productName ?? 'N/A',
        quantity: saleItem.quantity,
        unitPrice: saleItem.unitPrice,
        taxRate: saleItem.taxRate,
        taxAmount: saleItem.taxAmount,
        lineTotal: saleItem.unitPrice * saleItem.quantity,
        currencyCode: saleItem.currency,
        createdAt: DateTime.now(),
      );
    }).toList();

    return inv.Invoice(
      id: '',
      invoiceNumber: sale.saleNumber,
      customerId: sale.customerId,
      customerName: sale.customerName,
      customerAddress: null, // Müşteri adres bilgisi eklenebilir
      invoiceDate: sale.saleDate,
      dueDate: sale.dueDate,
      status: sale.status == SaleStatus.draft
          ? inv_status.InvoiceStatus.draft
          : inv_status.InvoiceStatus.sent,
      subtotal: sale.subtotal,
      taxAmount: sale.taxAmount,
      discountAmount: sale.discountAmount,
      totalAmount: sale.totalAmount,
      currencyCode: sale.currency,
      isPaid: sale.isPaid,
      items: invoiceItems,
      createdAt: sale.createdAt,
      updatedAt: sale.updatedAt,
    );
  }

  /// Purchase'ı Invoice'a dönüştür
  static inv.Invoice convertPurchaseToInvoice(Purchase purchase) {
    final invoiceItems = purchase.items.asMap().entries.map((entry) {
      final index = entry.key;
      final purchaseItem = entry.value;
      return inv_item.InvoiceItem(
        id: '',
        invoiceId: '',
        itemOrder: index + 1,
        productId: purchaseItem.productId,
        productName: purchaseItem.productName ?? 'N/A',
        quantity: purchaseItem.quantity,
        unitPrice: purchaseItem.unitPrice,
        taxRate: purchaseItem.taxRate,
        taxAmount: purchaseItem.taxAmount,
        lineTotal: purchaseItem.unitPrice * purchaseItem.quantity,
        currencyCode: purchaseItem.currency ?? 'TRY',
        createdAt: DateTime.now(),
      );
    }).toList();

    return inv.Invoice(
      id: '',
      invoiceNumber: purchase.purchaseNumber,
      customerId: purchase.supplierId,
      customerName: purchase.supplierName,
      customerAddress: null, // Tedarikçi adres bilgisi eklenebilir
      invoiceDate: purchase.purchaseDate,
      dueDate: purchase.dueDate,
      status: purchase.status == PurchaseStatus.draft
          ? inv_status.InvoiceStatus.draft
          : inv_status.InvoiceStatus.sent,
      subtotal: purchase.subtotal,
      taxAmount: purchase.taxAmount,
      discountAmount: purchase.discountAmount,
      totalAmount: purchase.totalAmount,
      currencyCode: purchase.currency,
      isPaid: false, // Alış faturaları genelde ödenmemiş olarak başlar
      items: invoiceItems,
      createdAt: purchase.createdAt,
      updatedAt: purchase.updatedAt,
    );
  }
}
