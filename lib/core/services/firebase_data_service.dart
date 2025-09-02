// ========== FIREBASE DATA SERVICE ==========
// lib/core/services/firebase_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


/// Firebase veri yönetim servisi
class FirebaseDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mock ürün verilerini Firebase'e ekle
  static Future<void> addMockProducts() async {
    if (!kIsWeb) return; // Sadece web platformunda çalışsın

    try {
      final productsCollection = _firestore.collection('products');

      // Mevcut ürünleri kontrol et
      final existingProducts = await productsCollection.get();
      if (existingProducts.docs.isNotEmpty) {
        print('Ürünler zaten mevcut, mock veri eklenmeyecek');
        return;
      }

      final mockProducts = [
        {
          'name': 'iPhone 15 Pro',
          'description': 'Apple iPhone 15 Pro 128GB Titanium',
          'sku': 'IP15P-128-TI',
          'barcode': '1234567890123',
          'category': 'Elektronik',
          'unitPrice': 89999.99,
          'stockQuantity': 25,
          'minStockLevel': 5,
          'unit': 'Adet',
          'taxRate': 20.0,
          'isActive': true,
          'imageUrl': null,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'Samsung Galaxy S24',
          'description': 'Samsung Galaxy S24 256GB Phantom Black',
          'sku': 'SGS24-256-PB',
          'barcode': '1234567890124',
          'category': 'Elektronik',
          'unitPrice': 74999.99,
          'stockQuantity': 18,
          'minStockLevel': 3,
          'unit': 'Adet',
          'taxRate': 20.0,
          'isActive': true,
          'imageUrl': null,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'MacBook Air M3',
          'description': 'Apple MacBook Air M3 13" 256GB Space Gray',
          'sku': 'MBA-M3-13-256-SG',
          'barcode': '1234567890125',
          'category': 'Bilgisayar',
          'unitPrice': 129999.99,
          'stockQuantity': 8,
          'minStockLevel': 2,
          'unit': 'Adet',
          'taxRate': 20.0,
          'isActive': true,
          'imageUrl': null,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'Dell XPS 13',
          'description': 'Dell XPS 13 13.4" Intel i7 512GB SSD',
          'sku': 'DXPS13-I7-512',
          'barcode': '1234567890126',
          'category': 'Bilgisayar',
          'unitPrice': 89999.99,
          'stockQuantity': 12,
          'minStockLevel': 4,
          'unit': 'Adet',
          'taxRate': 20.0,
          'isActive': true,
          'imageUrl': null,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'AirPods Pro',
          'description': 'Apple AirPods Pro 2. Nesil',
          'sku': 'APP-2GEN',
          'barcode': '1234567890127',
          'category': 'Aksesuar',
          'unitPrice': 8999.99,
          'stockQuantity': 45,
          'minStockLevel': 10,
          'unit': 'Adet',
          'taxRate': 20.0,
          'isActive': true,
          'imageUrl': null,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      // Batch write kullanarak tüm ürünleri ekle
      final batch = _firestore.batch();

      for (final product in mockProducts) {
        final docRef = productsCollection.doc();
        batch.set(docRef, product);
      }

      await batch.commit();
      print('${mockProducts.length} adet mock ürün Firebase\'e eklendi');
    } catch (e) {
      print('Mock ürün eklenirken hata: $e');
    }
  }

  /// Mock müşteri verilerini Firebase'e ekle
  static Future<void> addMockCustomers() async {
    if (!kIsWeb) return;

    try {
      final customersCollection = _firestore.collection('customers');

      final existingCustomers = await customersCollection.get();
      if (existingCustomers.docs.isNotEmpty) {
        print('Müşteriler zaten mevcut, mock veri eklenmeyecek');
        return;
      }

      final mockCustomers = [
        {
          'name': 'ABC Teknoloji Ltd. Şti.',
          'email': 'info@abcteknoloji.com',
          'phone': '+90 212 555 0101',
          'address': 'Levent Mah. Büyükdere Cad. No:123 Şişli/İstanbul',
          'taxNumber': '1234567890',
          'taxOffice': 'Şişli',
          'customerType': 'company',
          'city': 'İstanbul',
          'country': 'Türkiye',
          'postalCode': '34330',
          'notes': 'Kurumsal müşteri, düzenli alım yapar',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'XYZ Elektronik A.Ş.',
          'email': 'satis@xyzelektronik.com',
          'phone': '+90 216 555 0202',
          'address': 'Kadıköy Mah. Moda Cad. No:456 Kadıköy/İstanbul',
          'taxNumber': '9876543210',
          'taxOffice': 'Kadıköy',
          'customerType': 'company',
          'city': 'İstanbul',
          'country': 'Türkiye',
          'postalCode': '34710',
          'notes': 'Elektronik mağaza zinciri',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'Ahmet Yılmaz',
          'email': 'ahmet.yilmaz@email.com',
          'phone': '+90 532 555 0303',
          'address': 'Çankaya Mah. Atatürk Bulvarı No:789 Ankara',
          'taxNumber': null,
          'taxOffice': null,
          'customerType': 'individual',
          'city': 'Ankara',
          'country': 'Türkiye',
          'postalCode': '06690',
          'notes': 'Bireysel müşteri',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'Fatma Demir',
          'email': 'fatma.demir@email.com',
          'phone': '+90 533 555 0404',
          'address': 'Alsancak Mah. Kıbrıs Şehitleri Cad. No:321 İzmir',
          'taxNumber': null,
          'taxOffice': null,
          'customerType': 'individual',
          'city': 'İzmir',
          'country': 'Türkiye',
          'postalCode': '35220',
          'notes': 'Düzenli müşteri',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'DEF Bilgisayar Sistemleri',
          'email': 'info@defbilgisayar.com',
          'phone': '+90 224 555 0505',
          'address': 'Nilüfer Mah. FSM Bulvarı No:654 Bursa',
          'taxNumber': '1122334455',
          'taxOffice': 'Nilüfer',
          'customerType': 'company',
          'city': 'Bursa',
          'country': 'Türkiye',
          'postalCode': '16110',
          'notes': 'Bilgisayar sistemleri satışı',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      final batch = _firestore.batch();

      for (final customer in mockCustomers) {
        final docRef = customersCollection.doc();
        batch.set(docRef, customer);
      }

      await batch.commit();
      print('${mockCustomers.length} adet mock müşteri Firebase\'e eklendi');
    } catch (e) {
      print('Mock müşteri eklenirken hata: $e');
    }
  }

  /// Mock fatura verilerini Firebase'e ekle
  static Future<void> addMockInvoices() async {
    if (!kIsWeb) return; // Sadece web platformunda çalışsın
    try {
      final invoicesCollection = _firestore.collection('invoices');
      final existingInvoices = await invoicesCollection.get();
      if (existingInvoices.docs.isNotEmpty) {
        print('Faturalar zaten mevcut, mock veri eklenmeyecek');
        return;
      }

      final mockInvoices = [
        {
          'invoiceNumber': 'INV-2024-001',
          'customerId': 'customer_1',
          'customerName': 'ABC Elektronik Ltd. Şti.',
          'description': 'Elektronik ürün satışı',
          'subtotal': 15000.0,
          'taxAmount': 2700.0,
          'discountAmount': 0.0,
          'totalAmount': 17700.0,
          'currencyCode': 'TRY',
          'status': 'sent',
          'invoiceDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 10))),
          'dueDate':
              Timestamp.fromDate(DateTime.now().add(const Duration(days: 20))),
          'paymentTerms': '30 gün',
          'notes': 'Ödeme 30 gün içinde yapılacaktır',
          'isPaid': false,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'invoiceNumber': 'INV-2024-002',
          'customerId': 'customer_2',
          'customerName': 'XYZ Teknoloji A.Ş.',
          'description': 'Bilgisayar donanımı satışı',
          'subtotal': 25000.0,
          'taxAmount': 4500.0,
          'discountAmount': 1000.0,
          'totalAmount': 28500.0,
          'currencyCode': 'TRY',
          'status': 'paid',
          'invoiceDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 15))),
          'dueDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
          'paidDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
          'paymentTerms': '15 gün',
          'notes': 'Ödeme tamamlandı',
          'isPaid': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'invoiceNumber': 'INV-2024-003',
          'customerId': 'customer_3',
          'customerName': 'Mehmet Yılmaz',
          'description': 'Logo tasarım hizmeti',
          'subtotal': 2500.0,
          'taxAmount': 450.0,
          'discountAmount': 0.0,
          'totalAmount': 2950.0,
          'currencyCode': 'TRY',
          'status': 'draft',
          'invoiceDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
          'dueDate':
              Timestamp.fromDate(DateTime.now().add(const Duration(days: 25))),
          'paymentTerms': '30 gün',
          'notes': 'Taslak fatura',
          'isPaid': false,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (final invoice in mockInvoices) {
        await invoicesCollection.add(invoice);
      }
      print('Mock fatura verileri başarıyla eklendi!');
    } catch (e) {
      print('Error adding mock invoices: $e');
    }
  }

  /// Mock gider verilerini Firebase'e ekle
  static Future<void> addMockExpenses() async {
    if (!kIsWeb) return; // Sadece web platformunda çalışsın
    try {
      final expensesCollection = _firestore.collection('expenses');
      final existingExpenses = await expensesCollection.get();
      if (existingExpenses.docs.isNotEmpty) {
        print('Giderler zaten mevcut, mock veri eklenmeyecek');
        return;
      }

      final mockExpenses = [
        {
          'title': 'Ofis Kirası',
          'description': 'Aylık ofis kirası ödemesi',
          'amount': 3000.0,
          'categoryId': '1',
          'categoryName': 'Kira',
          'expenseDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
          'status': 'paid',
          'paymentMethod': 'Banka Transferi',
          'attachments': [],
          'invoiceNumber': 'INV-2024-001',
          'supplierId': null,
          'supplierName': null,
          'createdBy': 'system',
          'updatedBy': null,
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
          'updatedAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
        },
        {
          'title': 'Elektrik Faturası',
          'description': 'Ocak ayı elektrik faturası',
          'amount': 450.0,
          'categoryId': '2',
          'categoryName': 'Elektrik',
          'expenseDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 3))),
          'status': 'paid',
          'paymentMethod': 'Kredi Kartı',
          'attachments': [],
          'invoiceNumber': 'INV-2024-002',
          'supplierId': null,
          'supplierName': null,
          'createdBy': 'system',
          'updatedBy': null,
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 3))),
          'updatedAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 3))),
        },
        {
          'title': 'İnternet Faturası',
          'description': 'Aylık internet ve telefon faturası',
          'amount': 250.0,
          'categoryId': '4',
          'categoryName': 'İnternet',
          'expenseDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
          'status': 'pending',
          'paymentMethod': 'Banka Transferi',
          'attachments': [],
          'invoiceNumber': 'INV-2024-003',
          'supplierId': null,
          'supplierName': null,
          'createdBy': 'system',
          'updatedBy': null,
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
          'updatedAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
        },
      ];

      for (final expense in mockExpenses) {
        await expensesCollection.add(expense);
      }
      print('Mock gider verileri başarıyla eklendi!');
    } catch (e) {
      print('Error adding mock expenses: $e');
    }
  }

  /// Mock gelir verilerini Firebase'e ekle
  static Future<void> addMockIncomes() async {
    if (!kIsWeb) return; // Sadece web platformunda çalışsın
    try {
      final incomesCollection = _firestore.collection('incomes');
      final existingIncomes = await incomesCollection.get();
      if (existingIncomes.docs.isNotEmpty) {
        print('Gelirler zaten mevcut, mock veri eklenmeyecek');
        return;
      }

      final mockIncomes = [
        {
          'title': 'iPhone 15 Pro Satışı',
          'description': 'ABC Teknoloji Ltd. Şti. için iPhone 15 Pro satışı',
          'amount': 89999.99,
          'categoryId': '1',
          'categoryName': 'Satış Geliri',
          'incomeDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
          'status': 'received',
          'paymentMethod': 'Banka Transferi',
          'attachments': [],
          'invoiceNumber': 'INV-2024-001',
          'customerId': 'customer1',
          'customerName': 'ABC Teknoloji Ltd. Şti.',
          'notes': 'Kurumsal müşteri satışı',
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
          'updatedAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
        },
        {
          'title': 'MacBook Air M3 Satışı',
          'description': 'XYZ Elektronik A.Ş. için MacBook Air M3 satışı',
          'amount': 129999.99,
          'categoryId': '1',
          'categoryName': 'Satış Geliri',
          'incomeDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 3))),
          'status': 'received',
          'paymentMethod': 'Kredi Kartı',
          'attachments': [],
          'invoiceNumber': 'INV-2024-002',
          'customerId': 'customer2',
          'customerName': 'XYZ Elektronik A.Ş.',
          'notes': 'Elektronik mağaza satışı',
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 3))),
          'updatedAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 3))),
        },
        {
          'title': 'Danışmanlık Hizmeti',
          'description': 'Ahmet Yılmaz için yazılım danışmanlık hizmeti',
          'amount': 5000.0,
          'categoryId': '2',
          'categoryName': 'Hizmet Geliri',
          'incomeDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
          'status': 'pending',
          'paymentMethod': 'Nakit',
          'attachments': [],
          'invoiceNumber': 'INV-2024-003',
          'customerId': 'customer3',
          'customerName': 'Ahmet Yılmaz',
          'notes': 'Bireysel müşteri hizmeti',
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
          'updatedAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
        },
      ];

      for (final income in mockIncomes) {
        await incomesCollection.add(income);
      }
      print('Mock gelir verileri başarıyla eklendi!');
    } catch (e) {
      print('Error adding mock incomes: $e');
    }
  }

  /// Mock tedarikçi verilerini Firebase'e ekle
  static Future<void> addMockSuppliers() async {
    if (!kIsWeb) return; // Sadece web platformunda çalışsın
    try {
      final suppliersCollection = _firestore.collection('suppliers');
      final existingSuppliers = await suppliersCollection.get();
      if (existingSuppliers.docs.isNotEmpty) {
        print('Tedarikçiler zaten mevcut, mock veri eklenmeyecek');
        return;
      }

      final mockSuppliers = [
        {
          'name': 'ABC Elektronik Ltd. Şti.',
          'contactPerson': 'Mehmet Yılmaz',
          'email': 'info@abcelektronik.com',
          'phone': '+90 212 555 0101',
          'address': 'Levent Mah. Büyükdere Cad. No:123 Şişli/İstanbul',
          'taxNumber': '1234567890',
          'taxOffice': 'Şişli',
          'bankName': 'Garanti BBVA',
          'bankAccount': 'TR123456789012345678901234',
          'creditLimit': 100000.0,
          'currentBalance': 25000.0,
          'status': 'active',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'XYZ Teknoloji A.Ş.',
          'contactPerson': 'Ayşe Demir',
          'email': 'satis@xyzteknoloji.com',
          'phone': '+90 216 555 0202',
          'address': 'Kadıköy Mah. Moda Cad. No:456 Kadıköy/İstanbul',
          'taxNumber': '9876543210',
          'taxOffice': 'Kadıköy',
          'bankName': 'İş Bankası',
          'bankAccount': 'TR987654321098765432109876',
          'creditLimit': 75000.0,
          'currentBalance': 15000.0,
          'status': 'active',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'DEF Bilgisayar Sistemleri',
          'contactPerson': 'Ali Kaya',
          'email': 'info@defbilgisayar.com',
          'phone': '+90 224 555 0303',
          'address': 'Nilüfer Mah. FSM Bulvarı No:789 Bursa',
          'taxNumber': '1122334455',
          'taxOffice': 'Nilüfer',
          'bankName': 'Yapı Kredi',
          'bankAccount': 'TR112233445566778899001122',
          'creditLimit': 50000.0,
          'currentBalance': 0.0,
          'status': 'active',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (final supplier in mockSuppliers) {
        await suppliersCollection.add(supplier);
      }
      print('Mock tedarikçi verileri başarıyla eklendi!');
    } catch (e) {
      print('Error adding mock suppliers: $e');
    }
  }

  /// Mock rehber verilerini Firebase'e ekle
  static Future<void> addMockContacts() async {
    if (!kIsWeb) return; // Sadece web platformunda çalışsın
    try {
      final contactsCollection = _firestore.collection('contacts');
      final existingContacts = await contactsCollection.get();
      if (existingContacts.docs.isNotEmpty) {
        print('Rehber verileri zaten mevcut, mock veri eklenmeyecek');
        return;
      }

      final mockContacts = [
        {
          'name': 'Ahmet Yılmaz',
          'email': 'ahmet.yilmaz@email.com',
          'phone': '+90 532 555 0101',
          'address': 'Çankaya Mah. Atatürk Bulvarı No:123 Ankara',
          'city': 'Ankara',
          'country': 'Türkiye',
          'taxNumber': null,
          'taxOffice': null,
          'website': null,
          'type': 0, // Müşteri
          'isFavorite': true,
          'isActive': true,
          'notes': 'Düzenli müşteri',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'Fatma Demir',
          'email': 'fatma.demir@email.com',
          'phone': '+90 533 555 0202',
          'address': 'Alsancak Mah. Kıbrıs Şehitleri Cad. No:456 İzmir',
          'city': 'İzmir',
          'country': 'Türkiye',
          'taxNumber': null,
          'taxOffice': null,
          'website': null,
          'type': 0, // Müşteri
          'isFavorite': false,
          'isActive': true,
          'notes': 'Yeni müşteri',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'ABC Elektronik Ltd. Şti.',
          'email': 'info@abcelektronik.com',
          'phone': '+90 212 555 0303',
          'address': 'Levent Mah. Büyükdere Cad. No:789 İstanbul',
          'city': 'İstanbul',
          'country': 'Türkiye',
          'taxNumber': '1234567890',
          'taxOffice': 'Şişli',
          'website': 'www.abcelektronik.com',
          'type': 1, // Tedarikçi
          'isFavorite': true,
          'isActive': true,
          'notes': 'Elektronik tedarikçisi',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'XYZ Teknoloji A.Ş.',
          'email': 'satis@xyzteknoloji.com',
          'phone': '+90 216 555 0404',
          'address': 'Kadıköy Mah. Moda Cad. No:321 İstanbul',
          'city': 'İstanbul',
          'country': 'Türkiye',
          'taxNumber': '9876543210',
          'taxOffice': 'Kadıköy',
          'website': 'www.xyzteknoloji.com',
          'type': 2, // Müşteri & Tedarikçi
          'isFavorite': false,
          'isActive': true,
          'notes': 'Hem müşteri hem tedarikçi',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (final contact in mockContacts) {
        await contactsCollection.add(contact);
      }
      print('Mock rehber verileri başarıyla eklendi!');
    } catch (e) {
      print('Error adding mock contacts: $e');
    }
  }

  /// Mock nakit işlem verilerini Firebase'e ekle
  static Future<void> addMockCashTransactions() async {
    if (!kIsWeb) return; // Sadece web platformunda çalışsın
    try {
      final cashCollection = _firestore.collection('cash_transactions');
      final existingTransactions = await cashCollection.get();
      if (existingTransactions.docs.isNotEmpty) {
        print('Nakit işlemler zaten mevcut, mock veri eklenmeyecek');
        return;
      }

      final mockTransactions = [
        {
          'title': 'Müşteri ödemesi',
          'description': 'ABC Elektronik müşteri ödemesi',
          'amount': 15000.0,
          'type': 'income',
          'category': 'Müşteri Ödemesi',
          'transactionDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 2))),
          'referenceNumber': 'REF-001',
          'notes': 'Nakit ödeme',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'title': 'Kira ödemesi',
          'description': 'Ofis kirası ödemesi',
          'amount': 8000.0,
          'type': 'expense',
          'category': 'Kira',
          'transactionDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 5))),
          'referenceNumber': 'REF-002',
          'notes': 'Aylık kira',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'title': 'Elektrik faturası',
          'description': 'Elektrik faturası ödemesi',
          'amount': 1200.0,
          'type': 'expense',
          'category': 'Faturalar',
          'transactionDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
          'referenceNumber': 'REF-003',
          'notes': 'Elektrik faturası',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'title': 'Satış geliri',
          'description': 'Ürün satışı geliri',
          'amount': 25000.0,
          'type': 'income',
          'category': 'Satış',
          'transactionDate': Timestamp.fromDate(DateTime.now()),
          'referenceNumber': 'REF-004',
          'notes': 'Online satış',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'title': 'Banka transferi',
          'description': 'Banka hesabına transfer',
          'amount': 5000.0,
          'type': 'transfer',
          'category': 'Transfer',
          'transactionDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 2))),
          'referenceNumber': 'REF-005',
          'notes': 'Banka transferi',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (final transaction in mockTransactions) {
        await cashCollection.add(transaction);
      }
      print('Mock nakit işlem verileri başarıyla eklendi!');
    } catch (e) {
      print('Error adding mock cash transactions: $e');
    }
  }



  /// Tüm mock verileri ekle
  static Future<void> addAllMockData() async {
    await addMockProducts();
    await addMockCustomers();
    await addMockInvoices();
    await addMockExpenses();
    await addMockIncomes();
    await addMockSuppliers();
    await addMockContacts();
    await addMockCashTransactions();

    print('Tüm mock veriler başarıyla eklendi!');
  }

  /// Firebase'deki tüm verileri temizle
  static Future<void> clearAllData() async {
    if (!kIsWeb) return;

    try {
      final collections = ['products', 'customers', 'invoices'];

      for (final collectionName in collections) {
        final collection = _firestore.collection(collectionName);
        final snapshot = await collection.get();

        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      print('Tüm veriler temizlendi');
    } catch (e) {
      print('Veri temizlenirken hata: $e');
    }
  }
}
