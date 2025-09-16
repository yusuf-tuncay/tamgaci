// ========== CUSTOMER FIREBASE SERVICE ==========
// lib/features/customers/data/services/customer_firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../../../core/firebase/collections.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/entities/customer_transaction.dart';

/// Müşteri Firebase servis sınıfı
class CustomerFirebaseService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Müşteri oluştur
  Future<String> createCustomer(Customer customer) async {
    try {
      final data = _customerToMap(customer);
      final docRef = await _firebaseService.createDocument(
        FirebaseCollections.customers,
        data,
      );
      return docRef.id;
    } catch (e) {
      _firebaseService.logger.e('Müşteri oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Müşteri güncelle
  Future<void> updateCustomer(String customerId, Customer customer) async {
    try {
      final data = _customerToMap(customer);
      await _firebaseService.updateDocument(
        FirebaseCollections.customers,
        customerId,
        data,
      );
    } catch (e) {
      _firebaseService.logger.e('Müşteri güncellenirken hata: $e');
      rethrow;
    }
  }

  /// Müşteri sil
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firebaseService.deleteDocument(
        FirebaseCollections.customers,
        customerId,
      );
    } catch (e) {
      _firebaseService.logger.e('Müşteri silinirken hata: $e');
      rethrow;
    }
  }

  /// Müşteri getir
  Future<Customer?> getCustomer(String customerId) async {
    try {
      final doc = await _firebaseService.getDocumentById(
        FirebaseCollections.customers,
        customerId,
      );

      if (doc.exists && doc.data() != null) {
        return _mapToCustomer(doc.id, doc.data()! as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _firebaseService.logger.e('Müşteri getirilirken hata: $e');
      rethrow;
    }
  }

  /// Müşterileri listele
  Future<List<Customer>> getCustomers({
    int? limit,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
    String? searchQuery,
    CustomerType? type,
    CustomerStatus? status,
  }) async {
    try {
      final whereConditions = <String, dynamic>{
        FirebaseFields.isDeleted: false,
        FirebaseFields.isActive: true,
      };

      // Arama sorgusu
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Firestore'da text search için özel index gerekli
        // Şimdilik basit filtreleme yapıyoruz
      }

      // Tip filtresi
      if (type != null) {
        whereConditions[FirebaseFields.customerType] = type.name;
      }

      // Durum filtresi
      if (status != null) {
        whereConditions[FirebaseFields.customerStatus] = status.name;
      }

      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.customers,
        limit: limit,
        startAfter: startAfter,
        orderBy: orderBy ?? FirebaseFields.createdAt,
        descending: descending,
        whereConditions: whereConditions,
      );

      final customers = snapshot.docs
          .map((doc) =>
              _mapToCustomer(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Arama sorgusu varsa filtrele
      if (searchQuery != null && searchQuery.isNotEmpty) {
        return customers
            .where((customer) =>
                customer.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                customer.email
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ==
                    true ||
                customer.phone?.contains(searchQuery) == true)
            .toList();
      }

      return customers;
    } catch (e) {
      _firebaseService.logger.e('Müşteriler listelenirken hata: $e');
      rethrow;
    }
  }

  /// Müşterileri gerçek zamanlı dinle
  Stream<List<Customer>> listenToCustomers({
    int? limit,
    String? orderBy,
    bool descending = false,
    String? searchQuery,
    CustomerType? type,
    CustomerStatus? status,
  }) {
    try {
      final whereConditions = <String, dynamic>{
        FirebaseFields.isDeleted: false,
        FirebaseFields.isActive: true,
      };

      // Tip filtresi
      if (type != null) {
        whereConditions[FirebaseFields.customerType] = type.name;
      }

      // Durum filtresi
      if (status != null) {
        whereConditions[FirebaseFields.customerStatus] = status.name;
      }

      return _firebaseService
          .listenToCollection(
        FirebaseCollections.customers,
        limit: limit,
        orderBy: orderBy ?? FirebaseFields.createdAt,
        descending: descending,
        whereConditions: whereConditions,
      )
          .map((snapshot) {
        final customers = snapshot.docs
            .map((doc) =>
                _mapToCustomer(doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        // Arama sorgusu varsa filtrele
        if (searchQuery != null && searchQuery.isNotEmpty) {
          return customers
              .where((customer) =>
                  customer.name
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  customer.email
                          ?.toLowerCase()
                          .contains(searchQuery.toLowerCase()) ==
                      true ||
                  customer.phone?.contains(searchQuery) == true)
              .toList();
        }

        return customers;
      });
    } catch (e) {
      _firebaseService.logger.e('Müşteriler dinlenirken hata: $e');
      rethrow;
    }
  }

  /// Müşteri işlemlerini getir
  Future<List<CustomerTransaction>> getCustomerTransactions(
    String customerId, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.customerTransactions,
        limit: limit,
        startAfter: startAfter,
        orderBy: FirebaseFields.createdAt,
        descending: true,
        whereConditions: {
          'customerId': customerId,
          FirebaseFields.isDeleted: false,
        },
      );

      return snapshot.docs
          .map((doc) => _mapToCustomerTransaction(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _firebaseService.logger.e('Müşteri işlemleri getirilirken hata: $e');
      rethrow;
    }
  }

  /// Müşteri işlemlerini gerçek zamanlı dinle
  Stream<List<CustomerTransaction>> listenToCustomerTransactions(
      String customerId) {
    try {
      return _firebaseService.listenToCollection(
        FirebaseCollections.customerTransactions,
        orderBy: FirebaseFields.createdAt,
        descending: true,
        whereConditions: {
          'customerId': customerId,
          FirebaseFields.isDeleted: false,
        },
      ).map((snapshot) {
        return snapshot.docs
            .map((doc) => _mapToCustomerTransaction(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      _firebaseService.logger.e('Müşteri işlemleri dinlenirken hata: $e');
      rethrow;
    }
  }

  /// Müşteri istatistiklerini getir
  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      final snapshot = await _firebaseService.getCollectionData(
        FirebaseCollections.customers,
        whereConditions: {
          FirebaseFields.isDeleted: false,
          FirebaseFields.isActive: true,
        },
      );

      final customers = snapshot.docs
          .map((doc) =>
              _mapToCustomer(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final totalCustomers = customers.length;
      final activeCustomers =
          customers.where((c) => c.status == CustomerStatus.active).length;
      final inactiveCustomers =
          customers.where((c) => c.status == CustomerStatus.inactive).length;
      final totalBalance =
          customers.fold<double>(0, (acc, c) => acc + c.currentBalance);

      return {
        'totalCustomers': totalCustomers,
        'activeCustomers': activeCustomers,
        'inactiveCustomers': inactiveCustomers,
        'totalBalance': totalBalance,
      };
    } catch (e) {
      _firebaseService.logger.e('Müşteri istatistikleri getirilirken hata: $e');
      rethrow;
    }
  }

  /// Customer entity'sini Map'e çevir
  Map<String, dynamic> _customerToMap(Customer customer) {
    return {
      FirebaseFields.customerName: customer.name,
      FirebaseFields.customerEmail: customer.email,
      FirebaseFields.customerPhone: customer.phone,
      FirebaseFields.customerAddress: customer.address,
      FirebaseFields.customerTaxNumber: customer.taxNumber,
      FirebaseFields.customerType: customer.customerType.name,
      FirebaseFields.customerStatus: customer.status.name,
      FirebaseFields.customerCreditLimit: customer.creditLimit,
      FirebaseFields.customerCurrentBalance: customer.currentBalance,
      FirebaseFields.companyId: customer.companyId,
    };
  }

  /// Map'i Customer entity'sine çevir
  Customer _mapToCustomer(String id, Map<String, dynamic> data) {
    return Customer(
      id: id,
      name: data[FirebaseFields.customerName] ?? '',
      email: data[FirebaseFields.customerEmail],
      phone: data[FirebaseFields.customerPhone],
      address: data[FirebaseFields.customerAddress],
      taxNumber: data[FirebaseFields.customerTaxNumber],
      customerType: CustomerType.values.firstWhere(
        (e) => e.name == data[FirebaseFields.customerType],
        orElse: () => CustomerType.individual,
      ),
      status: CustomerStatus.values.firstWhere(
        (e) => e.name == data[FirebaseFields.customerStatus],
        orElse: () => CustomerStatus.active,
      ),
      creditLimit: (data[FirebaseFields.customerCreditLimit] ?? 0).toDouble(),
      currentBalance:
          (data[FirebaseFields.customerCurrentBalance] ?? 0).toDouble(),
      companyId: data[FirebaseFields.companyId] ?? '',
      createdAt: (data[FirebaseFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (data[FirebaseFields.updatedAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdBy: data[FirebaseFields.createdBy] ?? '',
      updatedBy: data[FirebaseFields.updatedBy],
    );
  }

  /// Map'i CustomerTransaction entity'sine çevir
  CustomerTransaction _mapToCustomerTransaction(
      String id, Map<String, dynamic> data) {
    return CustomerTransaction(
      id: id,
      customerId: data['customerId'] ?? '',
      type: CustomerTransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CustomerTransactionType.sale,
      ),
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      description: data['description'],
      reference: data['reference'],
      transactionDate:
          (data['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      invoiceId: data['invoiceId'],
      paymentMethod: data['paymentMethod'],
      companyId: data[FirebaseFields.companyId] ?? '',
      createdAt: (data[FirebaseFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (data[FirebaseFields.updatedAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdBy: data[FirebaseFields.createdBy] ?? '',
      updatedBy: data[FirebaseFields.updatedBy],
    );
  }
}
