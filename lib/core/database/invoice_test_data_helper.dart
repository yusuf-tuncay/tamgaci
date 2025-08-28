// ========== lib/core/database/invoice_test_data_helper.dart ==========

import 'package:flutter/rendering.dart';
import 'package:tamgaci/features/invoices/domain/entities/repositories/invoice_repository.dart';
import 'package:uuid/uuid.dart';
import '../../features/invoices/domain/entities/invoice.dart';
import '../../features/invoices/domain/entities/invoice_item.dart';
import '../../features/invoices/data/models/invoice_status.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';

/// Invoice test verilerini ekleme helper sınıfı
class InvoiceTestDataHelper {
  static const _uuid = Uuid();

  /// Örnek fatura verileri oluşturur
  static Future<void> insertSampleInvoices(
    InvoiceRepository invoiceRepository,
    CustomerRepository customerRepository,
  ) async {
    try {
      // Önce müşterileri getir
      final customers = await customerRepository.getActiveCustomers();
      if (customers.isEmpty) {
        debugPrint('❌ Önce müşteri ekleyin');
        return;
      }

      final sampleInvoices = <Invoice>[];
      final allItems = <List<InvoiceItem>>[];

      // 1. Taslak fatura
      final invoice1 = Invoice(
        id: _uuid.v4(),
        invoiceNumber: await invoiceRepository.getNextInvoiceNumber(),
        customerId: customers[0].id,
        customer: customers[0],
        invoiceDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 25)),
        status: InvoiceStatus.draft,
        subtotal: 1000.0,
        taxAmount: 180.0,
        discountAmount: 0.0,
        totalAmount: 1180.0,
        currencyCode: 'TRY',
        description: 'Web sitesi tasarım hizmeti',
        paymentTerms: '30 gün vadeli',
        notes: 'Müşteri özel istekleri var',
        isPaid: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      );

      final items1 = [
        InvoiceItem.create(
          id: _uuid.v4(),
          invoiceId: invoice1.id,
          itemOrder: 1,
          productName: 'Web Sitesi Tasarımı',
          description: 'Responsive, modern tasarım',
          quantity: 1.0,
          unit: 'adet',
          unitPrice: 1000.0,
          taxRate: 18.0,
        ),
      ];

      sampleInvoices.add(invoice1);
      allItems.add(items1);

      // 2. Gönderilmiş fatura
      if (customers.length > 1) {
        final invoice2 = Invoice(
          id: _uuid.v4(),
          invoiceNumber: await invoiceRepository.getNextInvoiceNumber(),
          customerId: customers[1].id,
          customer: customers[1],
          invoiceDate: DateTime.now().subtract(const Duration(days: 10)),
          dueDate: DateTime.now().add(const Duration(days: 20)),
          status: InvoiceStatus.sent,
          subtotal: 2500.0,
          taxAmount: 450.0,
          discountAmount: 100.0,
          totalAmount: 2850.0,
          currencyCode: 'TRY',
          description: 'Yazılım geliştirme hizmeti',
          isPaid: false,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        );

        final items2 = [
          InvoiceItem.create(
            id: _uuid.v4(),
            invoiceId: invoice2.id,
            itemOrder: 1,
            productName: 'Mobil Uygulama Geliştirme',
            description: 'iOS ve Android uyumlu',
            quantity: 1.0,
            unit: 'adet',
            unitPrice: 2000.0,
            taxRate: 18.0,
          ),
          InvoiceItem.create(
            id: _uuid.v4(),
            invoiceId: invoice2.id,
            itemOrder: 2,
            productName: 'API Entegrasyonu',
            description: 'RESTful API geliştirme',
            quantity: 5.0,
            unit: 'saat',
            unitPrice: 100.0,
            taxRate: 18.0,
          ),
        ];

        sampleInvoices.add(invoice2);
        allItems.add(items2);
      }

      // 3. Ödenen fatura
      final invoice3 = Invoice(
        id: _uuid.v4(),
        invoiceNumber: await invoiceRepository.getNextInvoiceNumber(),
        customerId: customers[0].id,
        customer: customers[0],
        invoiceDate: DateTime.now().subtract(const Duration(days: 20)),
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: InvoiceStatus.paid,
        subtotal: 750.0,
        taxAmount: 135.0,
        discountAmount: 0.0,
        totalAmount: 885.0,
        currencyCode: 'TRY',
        description: 'Danışmanlık hizmeti',
        isPaid: true,
        paidDate: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      );

      final items3 = [
        InvoiceItem.create(
          id: _uuid.v4(),
          invoiceId: invoice3.id,
          itemOrder: 1,
          productName: 'SEO Danışmanlığı',
          description: 'Web sitesi optimizasyonu',
          quantity: 10.0,
          unit: 'saat',
          unitPrice: 75.0,
          taxRate: 18.0,
        ),
      ];

      sampleInvoices.add(invoice3);
      allItems.add(items3);

      // 4. Vadesi geçmiş fatura
      final invoice4 = Invoice(
        id: _uuid.v4(),
        invoiceNumber: await invoiceRepository.getNextInvoiceNumber(),
        customerId: customers[0].id,
        customer: customers[0],
        invoiceDate: DateTime.now().subtract(const Duration(days: 45)),
        dueDate: DateTime.now().subtract(const Duration(days: 15)),
        status: InvoiceStatus.sent, // Overdue otomatik tespit edilecek
        subtotal: 1500.0,
        taxAmount: 270.0,
        discountAmount: 50.0,
        totalAmount: 1720.0,
        currencyCode: 'TRY',
        description: 'E-ticaret sitesi geliştirme',
        notes: 'Acil ödeme gerekiyor',
        isPaid: false,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      );

      final items4 = [
        InvoiceItem.create(
          id: _uuid.v4(),
          invoiceId: invoice4.id,
          itemOrder: 1,
          productName: 'E-ticaret Sitesi',
          description: 'Ürün katalogu ve ödeme sistemi',
          quantity: 1.0,
          unit: 'adet',
          unitPrice: 1500.0,
          taxRate: 18.0,
        ),
      ];

      sampleInvoices.add(invoice4);
      allItems.add(items4);

      // Faturaları ve kalemlerini kaydet
      for (int i = 0; i < sampleInvoices.length; i++) {
        await invoiceRepository.createInvoice(sampleInvoices[i], allItems[i]);
      }

      debugPrint(
        '✅ ${sampleInvoices.length} örnek fatura başarıyla eklendi',
      );
    } catch (e) {
      debugPrint('❌ Test faturalar eklenirken hata: $e');
    }
  }

  /// Tüm test faturalarını siler
  static Future<void> clearAllInvoices(InvoiceRepository repository) async {
    try {
      final invoices = await repository.getAllInvoices();
      for (final invoice in invoices) {
        await repository.deleteInvoice(invoice.id);
      }
      debugPrint('✅ Tüm test faturaları temizlendi');
    } catch (e) {
      debugPrint('❌ Test faturaları silinirken hata: $e');
    }
  }
}

// ========== DOSYA YERLEŞTİRME TALİMATLARI ==========

/*
📁 Bu dosyaların yerleştirilmesi gereken konumlar:

1. 📄 invoice_detail_page.dart
   → lib/features/invoices/presentation/pages/invoice_detail_page.dart
   (Mevcut placeholder'ı değiştir)

2. 📄 tamgaci_database.dart güncelleme
   → lib/core/database/tamgaci_database.dart
   (Mevcut dosyayı güncelle)

3. 📄 invoice_test_data_helper.dart
   → lib/core/database/invoice_test_data_helper.dart
   (Yeni dosya oluştur)

========== CODE GENERATION ==========

Database güncellemelerinden sonra şu komutu çalıştırın:
flutter packages pub run build_runner build --delete-conflicting-outputs

========== TEST VERİ EKLEME ==========

Dashboard'a test verisi eklemek için şu kodu ekleyin:

```dart
ElevatedButton(
  onPressed: () async {
    final db = await DatabaseHelper.getDatabase();
    final customerRepo = CustomerRepositoryImpl(db);
    final invoiceRepo = InvoiceRepositoryImpl(db, customerRepo);
    
    await InvoiceTestDataHelper.insertSampleInvoices(invoiceRepo, customerRepo);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Test faturaları eklendi!')),
    );
  },
  child: Text('Test Faturalarını Ekle'),
),
```

========== TAMAMLANAN INVOICE MODÜLÜ ✅ ==========

✅ Database Layer (Entity, DAO, Migration)
✅ Domain Layer (Business Logic)
✅ Repository Implementation
✅ Riverpod State Management
✅ Invoice List Page (Filtering, Status management)
✅ Create Invoice Page (Complex form, Items, Calculations)
✅ Invoice Detail Page (Professional display)
✅ Test Data Helper
✅ Database Migration
✅ Error Handling
✅ Loading States
✅ Status Management

Artık tamamen fonksiyonel bir INVOICE YÖNETİM SİSTEMİNİZ var! 🎉🧾💼

Bu sistem:
- Customer relationship management
- Complex calculations (tax, subtotal, total)
- Status workflow (draft → sent → paid)
- Items management
- Search & filtering
- Professional UI/UX
- Reactive updates

Paraşüt ve BizimHesap seviyesinde professional invoice management! 🚀
*/
