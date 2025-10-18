// ========== INVOICES ROUTES ==========
// lib/core/router/invoices_routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/guards/subscription_guard.dart';
import '../../features/invoices/presentation/pages/invoices_list_page.dart';
import '../../features/invoices/presentation/pages/create_invoice_page.dart';
import '../../features/invoices/presentation/pages/invoice_preview_page.dart';
import '../../features/invoices/domain/entities/invoice.dart';
import '../../features/invoices/domain/entities/invoice_item.dart';
import '../../features/invoices/data/models/invoice_status.dart';
import '../../features/sales/domain/entities/sale.dart';
// SaleItem is defined in sale.dart

/// Invoices routes
class InvoicesRoutes {
  static List<GoRoute> get routes => [
        // ========== INVOICES ROUTES ==========

        GoRoute(
          path: '/invoices',
          name: 'invoices-list',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: InvoicesListPage(),
          ),
        ),

        GoRoute(
          path: '/invoices/create',
          name: 'create-invoice',
          builder: (context, state) => const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateInvoicePage(),
          ),
        ),

        GoRoute(
          path: '/invoices/preview/:id',
          name: 'invoice-preview',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: _InvoicePreviewWrapper(saleId: id),
            );
          },
        ),
      ];
}

/// Fatura ön izleme wrapper widget'ı
class _InvoicePreviewWrapper extends StatefulWidget {
  final String saleId;

  const _InvoicePreviewWrapper({required this.saleId});

  @override
  State<_InvoicePreviewWrapper> createState() => _InvoicePreviewWrapperState();
}

class _InvoicePreviewWrapperState extends State<_InvoicePreviewWrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Invoice?>(
      future: _loadInvoiceFromSale(widget.saleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hata')),
            body: Center(
              child: Text('Fatura yüklenirken hata oluştu: ${snapshot.error}'),
            ),
          );
        }

        final invoice = snapshot.data!;
        return InvoicePreviewPage(
          invoice: invoice,
          isEditable: true,
          isFromSale: true,
        );
      },
    );
  }

  /// Satış ID'sinden fatura yükleme fonksiyonu
  Future<Invoice?> _loadInvoiceFromSale(String saleId) async {
    try {
      // Firebase'den satış verilerini yükle
      final sale = await _loadSaleFromFirebase(saleId);
      if (sale == null) {
        throw Exception('Satış bulunamadı');
      }

      // Satış verilerinden fatura oluştur
      final invoice = _convertSaleToInvoice(sale);
      return invoice;
    } catch (e) {
      throw Exception('Fatura yüklenirken hata oluştu: $e');
    }
  }

  /// Firebase'den satış verilerini yükle
  Future<Sale?> _loadSaleFromFirebase(String saleId) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Kullanıcının tenant ID'sini al
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Kullanıcı bilgileri bulunamadı');
      }

      final tenantId = userDoc.data()?['tenantId'];
      if (tenantId == null) {
        throw Exception('Tenant ID bulunamadı');
      }

      // Firebase Firestore'dan satış verilerini yükle
      final doc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('sales')
          .doc(saleId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;

      // Sale entity'sini oluştur
      return Sale(
        id: doc.id,
        tenantId: data['tenantId'] ?? '',
        saleNumber: data['saleNumber'] ?? '',
        type: SaleType.values.firstWhere(
          (e) => e.name == data['type'],
          orElse: () => SaleType.sale,
        ),
        status: SaleStatus.values.firstWhere(
          (e) => e.name == data['status'],
          orElse: () => SaleStatus.draft,
        ),
        paymentStatus: PaymentStatus.values.firstWhere(
          (e) => e.name == data['paymentStatus'],
          orElse: () => PaymentStatus.pending,
        ),
        isPaid: data['isPaid'] ?? false,
        customerId: data['customerId'] ?? '',
        customerName: data['customerName'],
        saleDate: (data['saleDate'] as Timestamp).toDate(),
        dueDate: data['dueDate'] != null
            ? (data['dueDate'] as Timestamp).toDate()
            : null,
        subtotal: (data['subtotal'] ?? 0.0).toDouble(),
        taxRate: (data['taxRate'] ?? 18.0).toDouble(),
        taxAmount: (data['taxAmount'] ?? 0.0).toDouble(),
        discountAmount: (data['discountAmount'] ?? 0.0).toDouble(),
        totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
        currency: data['currency'] ?? 'TRY',
        notes: data['notes'],
        items: _parseSaleItems(data['items'] ?? []),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      throw Exception('Satış verileri yüklenirken hata oluştu: $e');
    }
  }

  /// Sale items'ları parse et
  List<SaleItem> _parseSaleItems(List<dynamic> itemsData) {
    return itemsData
        .map((item) => SaleItem(
              id: item['id'] ?? '',
              saleId: item['saleId'] ?? '',
              productId: item['productId'] ?? '',
              productName: item['productName'],
              productDescription: item['productDescription'],
              productSku: item['productSku'],
              quantity: (item['quantity'] ?? 0.0).toDouble(),
              unitPrice: (item['unitPrice'] ?? 0.0).toDouble(),
              discountRate: (item['discountRate'] ?? 0.0).toDouble(),
              discountAmount: (item['discountAmount'] ?? 0.0).toDouble(),
              taxRate: (item['taxRate'] ?? 0.0).toDouble(),
              taxAmount: (item['taxAmount'] ?? 0.0).toDouble(),
              totalAmount: (item['totalAmount'] ?? 0.0).toDouble(),
              currency: item['currency'] ?? 'TRY',
            ))
        .toList();
  }

  /// Sale'den Invoice'a dönüştür
  Invoice _convertSaleToInvoice(Sale sale) {
    return Invoice(
      id: sale.id,
      invoiceNumber: sale.saleNumber,
      customerId: sale.customerId,
      customerName: sale.customerName,
      customerAddress: sale.billingAddress,
      customer: null, // Lazy loading için null
      invoiceDate: sale.saleDate,
      dueDate: sale.dueDate,
      status: _convertSaleStatusToInvoiceStatus(sale.status),
      subtotal: sale.subtotal,
      taxAmount: sale.taxAmount,
      discountAmount: sale.discountAmount,
      totalAmount: sale.totalAmount,
      currencyCode: sale.currency,
      notes: sale.notes,
      isPaid: sale.isPaid,
      items: _convertSaleItemsToInvoiceItems(sale.items),
      createdAt: sale.createdAt,
      updatedAt: sale.updatedAt,
    );
  }

  /// Sale status'u Invoice status'a dönüştür
  InvoiceStatus _convertSaleStatusToInvoiceStatus(SaleStatus saleStatus) {
    switch (saleStatus) {
      case SaleStatus.draft:
        return InvoiceStatus.draft;
      case SaleStatus.pending:
        return InvoiceStatus.unpaid;
      case SaleStatus.confirmed:
        return InvoiceStatus.sent;
      case SaleStatus.shipped:
        return InvoiceStatus.sent;
      case SaleStatus.delivered:
        return InvoiceStatus.sent;
      case SaleStatus.paid:
        return InvoiceStatus.paid;
      case SaleStatus.cancelled:
        return InvoiceStatus.cancelled;
      case SaleStatus.returned:
        return InvoiceStatus.cancelled;
    }
  }

  /// Sale items'ları Invoice items'lara dönüştür
  List<InvoiceItem> _convertSaleItemsToInvoiceItems(List<SaleItem> saleItems) {
    return saleItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return InvoiceItem(
        id: item.id,
        invoiceId: item.saleId,
        itemOrder: index + 1,
        productId: item.productId,
        productName: item.productName ?? '',
        description: item.productDescription,
        quantity: item.quantity,
        unit: null,
        unitPrice: item.unitPrice,
        discountRate: item.discountRate,
        discountAmount: item.discountAmount,
        taxRate: item.taxRate,
        taxAmount: item.taxAmount,
        lineTotal: item.totalAmount,
        currencyCode: item.currency,
        createdAt: DateTime.now(),
      );
    }).toList();
  }
}
