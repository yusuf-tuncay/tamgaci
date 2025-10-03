// ========== TRANSACTION SERVICE ==========
// lib/core/services/business/transaction_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';

/// İşlem türü enum'u
enum TransactionType {
  sale, // Satış
  purchase, // Alış
  payment, // Ödeme
  refund, // İade
  credit, // Kredi
  debit, // Borç
  invoice, // Fatura
  proforma, // Proforma
  waybill, // İrsaliye
  expense, // Gider
  income, // Gelir
  transfer, // Transfer
  stockIn, // Stok Girişi
  stockOut, // Stok Çıkışı
  adjustment, // Düzeltme
}

/// İşlem durumu enum'u
enum TransactionStatus {
  pending, // Beklemede
  completed, // Tamamlandı
  cancelled, // İptal Edildi
  overdue, // Vadesi Geçti
  paid, // Ödendi
  partial, // Kısmi Ödeme
}

/// İşlem entity'si
class Transaction {
  final String id;
  final String customerId;
  final String? supplierId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String? description;
  final String? reference;
  final DateTime transactionDate;
  final DateTime? dueDate;
  final String? invoiceId;
  final String? paymentMethod;
  final String? documentNumber;
  final TransactionStatus status;
  final String companyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;
  final Map<String, dynamic>? metadata;

  const Transaction({
    required this.id,
    required this.customerId,
    this.supplierId,
    required this.type,
    required this.amount,
    required this.currency,
    this.description,
    this.reference,
    required this.transactionDate,
    this.dueDate,
    this.invoiceId,
    this.paymentMethod,
    this.documentNumber,
    required this.status,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
    this.metadata,
  });

  /// Firebase Firestore'dan entity oluşturma
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Transaction(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      supplierId: data['supplierId'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.sale,
      ),
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      description: data['description'],
      reference: data['reference'],
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      invoiceId: data['invoiceId'],
      paymentMethod: data['paymentMethod'],
      documentNumber: data['documentNumber'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      companyId: data['companyId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'],
      metadata: data['metadata'],
    );
  }

  /// Firebase Firestore'a kaydetme için Map dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'supplierId': supplierId,
      'type': type.name,
      'amount': amount,
      'currency': currency,
      'description': description,
      'reference': reference,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'invoiceId': invoiceId,
      'paymentMethod': paymentMethod,
      'documentNumber': documentNumber,
      'status': status.name,
      'companyId': companyId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'metadata': metadata,
    };
  }
}

/// İşlem yönetim servisi
class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Yeni işlem oluşturma - Multi-tenant
  Future<String> createTransaction(Transaction transaction) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppLogger.error('No authenticated user found');
        throw Exception('No authenticated user found');
      }

      AppLogger.info('Creating transaction for user: ${user.uid}');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        AppLogger.error('User document not found for user: ${user.uid}');
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      AppLogger.info('User tenant ID: $tenantId');

      if (tenantId == null || tenantId.isEmpty) {
        AppLogger.error('No tenant ID found for user: ${user.uid}');
        throw Exception('No tenant ID found for user');
      }

      // Multi-tenant collection path
      final docRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('transactions')
          .doc();
      
      final transactionWithId = Transaction(
        id: docRef.id,
        customerId: transaction.customerId,
        supplierId: transaction.supplierId,
        type: transaction.type,
        amount: transaction.amount,
        currency: transaction.currency,
        description: transaction.description,
        reference: transaction.reference,
        transactionDate: transaction.transactionDate,
        dueDate: transaction.dueDate,
        invoiceId: transaction.invoiceId,
        paymentMethod: transaction.paymentMethod,
        documentNumber: transaction.documentNumber,
        status: transaction.status,
        companyId: transaction.companyId,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
        createdBy: transaction.createdBy,
        updatedBy: transaction.updatedBy,
        metadata: transaction.metadata,
      );

      // Multi-tenant data with tenantId and createdBy
      final transactionData = transactionWithId.toFirestore();
      transactionData['tenantId'] = tenantId;
      transactionData['createdBy'] = user.uid;

      await docRef.set(transactionData);

      // Müşteri bakiyesini güncelle
      await _updateCustomerBalance(transaction.customerId, transaction);

      AppLogger.info('Transaction created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating transaction', e);
      rethrow;
    }
  }

  /// Müşteri bakiyesini güncelleme - Multi-tenant
  Future<void> _updateCustomerBalance(
      String customerId, Transaction transaction) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppLogger.warning('No authenticated user found');
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        AppLogger.warning('User document not found');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found for user');
        return;
      }

      final customerRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc(customerId);
      final customerDoc = await customerRef.get();

      if (!customerDoc.exists) {
        AppLogger.warning('Customer not found: $customerId');
        return;
      }

      final customerData = customerDoc.data()!;
      double currentBalance =
          (customerData['currentBalance'] ?? 0.0).toDouble();

      // İşlem türüne göre bakiye hesaplama
      switch (transaction.type) {
        case TransactionType.sale:
        case TransactionType.invoice:
        case TransactionType.payment:
          // Müşteri borcu artar (negatif bakiye)
          currentBalance -= transaction.amount;
          break;
        case TransactionType.refund:
        case TransactionType.credit:
          // Müşteri alacağı artar (pozitif bakiye)
          currentBalance += transaction.amount;
          break;
        case TransactionType.purchase:
          // Tedarikçi işlemi, müşteri bakiyesini etkilemez
          break;
        default:
          break;
      }

      await customerRef.update({
        'currentBalance': currentBalance,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      AppLogger.info(
          'Customer balance updated: $customerId, new balance: $currentBalance');
    } catch (e) {
      AppLogger.error('Error updating customer balance', e);
      rethrow;
    }
  }

  /// Müşteri işlemlerini getirme - Multi-tenant
  Future<List<Transaction>> getCustomerTransactions(String customerId) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        throw Exception('No tenant ID found for user');
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('transactions')
          .where('customerId', isEqualTo: customerId)
          .orderBy('transactionDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting customer transactions', e);
      rethrow;
    }
  }

  /// Müşteri işlemlerini stream olarak getirme - Multi-tenant
  Stream<List<Transaction>> watchCustomerTransactions(String customerId) {
    return Stream.fromFuture(_getTenantId()).asyncExpand((tenantId) {
      if (tenantId == null) return Stream.value(<Transaction>[]);
      
      return _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('transactions')
          .where('customerId', isEqualTo: customerId)
          .orderBy('transactionDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Transaction.fromFirestore(doc))
              .toList());
    });
  }

  /// Tenant ID'yi getirme helper metodu
  Future<String?> _getTenantId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['tenantId'] as String?;
    } catch (e) {
      AppLogger.error('Error getting tenant ID', e);
      return null;
    }
  }

  /// Müşteri bakiyesini hesaplama - Multi-tenant
  Future<double> calculateCustomerBalance(String customerId) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        throw Exception('No tenant ID found for user');
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('transactions')
          .where('customerId', isEqualTo: customerId)
          .get();

      double balance = 0.0;

      for (final doc in querySnapshot.docs) {
        final transaction = Transaction.fromFirestore(doc);

        switch (transaction.type) {
          case TransactionType.sale:
          case TransactionType.invoice:
          case TransactionType.payment:
            balance -= transaction.amount;
            break;
          case TransactionType.refund:
          case TransactionType.credit:
            balance += transaction.amount;
            break;
          default:
            break;
        }
      }

      return balance;
    } catch (e) {
      AppLogger.error('Error calculating customer balance', e);
      rethrow;
    }
  }

  /// Tarih aralığına göre işlemleri getirme - Multi-tenant
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? customerId,
    TransactionType? type,
  }) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        throw Exception('No tenant ID found for user');
      }

      Query query = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('transactions')
          .where('transactionDate', isGreaterThanOrEqualTo: startDate)
          .where('transactionDate', isLessThanOrEqualTo: endDate);

      if (customerId != null) {
        query = query.where('customerId', isEqualTo: customerId);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final querySnapshot =
          await query.orderBy('transactionDate', descending: true).get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting transactions by date range', e);
      rethrow;
    }
  }

  /// İşlem güncelleme - Multi-tenant
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        throw Exception('No tenant ID found for user');
      }

      final transactionData = transaction.toFirestore();
      transactionData['updatedAt'] = Timestamp.fromDate(DateTime.now());
      transactionData['updatedBy'] = user.uid;

      await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('transactions')
          .doc(transaction.id)
          .update(transactionData);

      AppLogger.info('Transaction updated: ${transaction.id}');
    } catch (e) {
      AppLogger.error('Error updating transaction', e);
      rethrow;
    }
  }

  /// İşlem silme - Multi-tenant
  Future<void> deleteTransaction(String transactionId) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        throw Exception('No tenant ID found for user');
      }

      final transactionDoc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (transactionDoc.exists) {
        final transaction = Transaction.fromFirestore(transactionDoc);

        // İşlemi sil
        await _firestore
            .collection('tenants')
            .doc(tenantId)
            .collection('transactions')
            .doc(transactionId)
            .delete();

        // Müşteri bakiyesini geri al
        await _reverseCustomerBalance(transaction.customerId, transaction);

        AppLogger.info('Transaction deleted: $transactionId');
      }
    } catch (e) {
      AppLogger.error('Error deleting transaction', e);
      rethrow;
    }
  }

  /// Müşteri bakiyesini geri alma (işlem silindiğinde)
  Future<void> _reverseCustomerBalance(
      String customerId, Transaction transaction) async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppLogger.warning('No authenticated user found');
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        AppLogger.warning('User document not found');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found for user');
        return;
      }

      final customerRef = _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .doc(customerId);
      final customerDoc = await customerRef.get();

      if (!customerDoc.exists) return;

      final customerData = customerDoc.data()!;
      double currentBalance =
          (customerData['currentBalance'] ?? 0.0).toDouble();

      // İşlem türüne göre ters işlem yap
      switch (transaction.type) {
        case TransactionType.sale:
        case TransactionType.invoice:
        case TransactionType.payment:
          // Müşteri borcu azalır
          currentBalance += transaction.amount;
          break;
        case TransactionType.refund:
        case TransactionType.credit:
          // Müşteri alacağı azalır
          currentBalance -= transaction.amount;
          break;
        default:
          break;
      }

      await customerRef.update({
        'currentBalance': currentBalance,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      AppLogger.info(
          'Customer balance reversed: $customerId, new balance: $currentBalance');
    } catch (e) {
      AppLogger.error('Error reversing customer balance', e);
      rethrow;
    }
  }

  /// Tüm müşteri bakiyelerini yeniden hesaplama - Multi-tenant
  Future<void> recalculateAllCustomerBalances() async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppLogger.warning('No authenticated user found');
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        AppLogger.warning('User document not found');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found for user');
        return;
      }

      final customersSnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .get();

      for (final customerDoc in customersSnapshot.docs) {
        final customerId = customerDoc.id;
        final balance = await calculateCustomerBalance(customerId);

        await customerDoc.reference.update({
          'currentBalance': balance,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      AppLogger.info('All customer balances recalculated');
    } catch (e) {
      AppLogger.error('Error recalculating customer balances', e);
      rethrow;
    }
  }
}
