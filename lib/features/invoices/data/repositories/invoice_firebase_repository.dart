import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/invoices/domain/entities/invoice.dart';
import 'package:tamgaci/features/invoices/domain/entities/invoice_item.dart';
import 'package:tamgaci/features/invoices/domain/entities/repositories/invoice_repository.dart';
import 'package:tamgaci/features/invoices/data/models/invoice_status.dart';
import 'package:tamgaci/core/services/tenant_service.dart';

/// Firebase Invoice Repository Implementation
class InvoiceFirebaseRepository implements InvoiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TenantService _tenantService = TenantService();
  static const String _invoicesCollection = 'invoices';
  static const String _invoiceItemsCollection = 'invoice_items';

  Future<String?> _currentTenantId() async {
    try {
      final tenantId = await _tenantService.getUserTenantId();
      AppLogger.info('Invoice tenantId lookup via TenantService: $tenantId');
      return tenantId;
    } catch (e) {
      AppLogger.error('Error getting tenantId for invoices via TenantService', e);
      return null;
    }
  }

  Future<CollectionReference<Map<String, dynamic>>> _tenantInvoices() async {
    final tenantId = await _currentTenantId();
    if (tenantId == null) {
      // fallback: root collection (will likely be blocked by security rules)
      AppLogger.warning('No tenantId found; using root invoices collection');
      return _firestore.collection(_invoicesCollection);
    }
    final col = _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection(_invoicesCollection);
    return col;
  }

  Future<CollectionReference<Map<String, dynamic>>>
      _tenantInvoiceItems() async {
    final tenantId = await _currentTenantId();
    if (tenantId == null) {
      AppLogger.warning(
          'No tenantId found; using root invoice_items collection');
      return _firestore.collection(_invoiceItemsCollection);
    }
    final col = _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection(_invoiceItemsCollection);
    return col;
  }

  String? _currentUid() {
    try {
      return firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Returns a base query scoped to current tenant (no createdBy filter).
  Future<Query<Map<String, dynamic>>> _scopedInvoicesCollection() async {
    final col = await _tenantInvoices();
    return col;
  }

  /// Backfill createdBy for invoices missing this field (best-effort)
  Future<void> backfillCreatedByForCurrentUser() async {
    final uid = _currentUid();
    if (uid == null || uid.isEmpty) return;
    try {
      // Fetch a limited set to avoid heavy writes at once
      final snapshot = await _firestore
          .collection(_invoicesCollection)
          .where('createdBy', isNull: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'createdBy': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      AppLogger.info(
          'Backfilled createdBy for ${snapshot.docs.length} invoices.');
    } catch (e) {
      AppLogger.warning('Backfill createdBy failed (non-blocking)', e);
    }
  }

  @override
  Future<List<Invoice>> getAllInvoices({bool includeItems = false}) async {
    try {
      final snapshot = await (await _scopedInvoicesCollection())
          .orderBy('createdAt', descending: true)
          .get();

      final invoices = <Invoice>[];
      for (final doc in snapshot.docs) {
        final invoice = _invoiceFromFirestore(doc);
        if (includeItems) {
          final items = await getInvoiceItems(invoice.id);
          invoices.add(invoice.copyWith(items: items));
        } else {
          invoices.add(invoice);
        }
      }

      return invoices;
    } catch (e) {
      // Permission denied hatası için boş liste döndür ve hata seviyesini düşür
      if (e.toString().contains('permission-denied')) {
        AppLogger.warning(
            'Firebase permission denied for invoices, returning empty list');
        return [];
      }
      AppLogger.error('Error getting all invoices', e);
      rethrow;
    }
  }

  @override
  Stream<List<Invoice>> watchAllInvoices() {
    return _tenantInvoices().asStream().asyncExpand((col) {
      return col
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _invoiceFromFirestore(doc)).toList())
          .handleError(
        (error) {
          if (error.toString().contains('permission-denied')) {
            AppLogger.warning(
                'Firebase permission denied for invoices stream (suppressed)');
            // suppress error event
            return;
          }
          AppLogger.error('Error in watchAllInvoices stream', error);
        },
        test: (error) => error.toString().contains('permission-denied'),
      );
    });
  }

  @override
  Future<Invoice?> getInvoiceById(String id, {bool includeItems = true}) async {
    try {
      final col = await _tenantInvoices();
      final doc = await col.doc(id).get();

      if (!doc.exists) return null;

      final invoice = _invoiceFromFirestore(doc);
      if (includeItems) {
        final items = await getInvoiceItems(id);
        return invoice.copyWith(items: items);
      }

      return invoice;
    } catch (e) {
      AppLogger.error('Error getting invoice by id: $id', e);
      // Permission denied hatası için null döndür
      if (e.toString().contains('permission-denied')) {
        AppLogger.warning(
            'Firebase permission denied for invoice $id, returning null');
        return null;
      }
      rethrow;
    }
  }

  @override
  Stream<Invoice?> watchInvoiceById(String id) {
    return _tenantInvoices().asStream().asyncExpand((col) {
      return col
          .doc(id)
          .snapshots()
          .map((doc) => doc.exists ? _invoiceFromFirestore(doc) : null)
          .handleError(
        (error) {
          if (error.toString().contains('permission-denied')) {
            AppLogger.warning(
                'Firebase permission denied for invoice $id stream (suppressed)');
            return;
          }
          AppLogger.error('Error in watchInvoiceById stream for $id', error);
        },
        test: (error) => error.toString().contains('permission-denied'),
      );
    });
  }

  @override
  Stream<List<Invoice>> watchInvoicesByCustomerId(String customerId) {
    return _tenantInvoices().asStream().asyncExpand((col) {
      return col
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _invoiceFromFirestore(doc)).toList())
          .handleError(
        (error) {
          if (error.toString().contains('permission-denied')) {
            AppLogger.warning(
                'Firebase permission denied for customer invoices $customerId stream (suppressed)');
            return; // suppress
          }
          AppLogger.error(
              'Error in watchInvoicesByCustomerId stream for $customerId',
              error);
        },
        test: (error) => error.toString().contains('permission-denied'),
      );
    });
  }

  @override
  Stream<List<Invoice>> watchInvoicesByStatus(InvoiceStatus status) {
    return _tenantInvoices().asStream().asyncExpand((col) {
      return col
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _invoiceFromFirestore(doc)).toList());
    });
  }

  @override
  Stream<List<Invoice>> watchUnpaidInvoices() {
    return _tenantInvoices().asStream().asyncExpand((col) {
      return col
          .where('isPaid', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => _invoiceFromFirestore(doc)).toList());
    });
  }

  @override
  Future<List<Invoice>> getInvoicesByCustomerId(String customerId,
      {bool includeItems = false}) async {
    try {
      final snapshot = await (await _scopedInvoicesCollection())
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      final invoices = <Invoice>[];
      for (final doc in snapshot.docs) {
        final invoice = _invoiceFromFirestore(doc);
        if (includeItems) {
          final items = await getInvoiceItems(invoice.id);
          invoices.add(invoice.copyWith(items: items));
        } else {
          invoices.add(invoice);
        }
      }

      return invoices;
    } catch (e) {
      AppLogger.error('Error getting invoices by customer: $customerId', e);
      rethrow;
    }
  }

  @override
  Future<List<Invoice>> getInvoicesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeItems = false,
  }) async {
    try {
      final snapshot = await (await _scopedInvoicesCollection())
          .where('invoiceDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('invoiceDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('invoiceDate', descending: true)
          .get();

      final invoices = <Invoice>[];
      for (final doc in snapshot.docs) {
        final invoice = _invoiceFromFirestore(doc);
        if (includeItems) {
          final items = await getInvoiceItems(invoice.id);
          invoices.add(invoice.copyWith(items: items));
        } else {
          invoices.add(invoice);
        }
      }

      return invoices;
    } catch (e) {
      AppLogger.error('Error getting invoices by date range', e);
      rethrow;
    }
  }

  @override
  Future<List<Invoice>> getInvoicesByStatus(InvoiceStatus status,
      {bool includeItems = false}) async {
    try {
      final snapshot = await (await _scopedInvoicesCollection())
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      final invoices = <Invoice>[];
      for (final doc in snapshot.docs) {
        final invoice = _invoiceFromFirestore(doc);
        if (includeItems) {
          final items = await getInvoiceItems(invoice.id);
          invoices.add(invoice.copyWith(items: items));
        } else {
          invoices.add(invoice);
        }
      }

      return invoices;
    } catch (e) {
      AppLogger.error('Error getting invoices by status: ${status.name}', e);
      rethrow;
    }
  }

  @override
  Future<List<Invoice>> getOverdueInvoices({bool includeItems = false}) async {
    try {
      final now = DateTime.now();
      final snapshot = await (await _scopedInvoicesCollection())
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .where('isPaid', isEqualTo: false)
          .orderBy('dueDate', descending: false)
          .get();

      final invoices = <Invoice>[];
      for (final doc in snapshot.docs) {
        final invoice = _invoiceFromFirestore(doc);
        if (includeItems) {
          final items = await getInvoiceItems(invoice.id);
          invoices.add(invoice.copyWith(items: items));
        } else {
          invoices.add(invoice);
        }
      }

      return invoices;
    } catch (e) {
      AppLogger.error('Error getting overdue invoices', e);
      rethrow;
    }
  }

  @override
  Future<List<Invoice>> getUnpaidInvoices({bool includeItems = false}) async {
    try {
      final snapshot = await (await _scopedInvoicesCollection())
          .where('isPaid', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      final invoices = <Invoice>[];
      for (final doc in snapshot.docs) {
        final invoice = _invoiceFromFirestore(doc);
        if (includeItems) {
          final items = await getInvoiceItems(invoice.id);
          invoices.add(invoice.copyWith(items: items));
        } else {
          invoices.add(invoice);
        }
      }

      return invoices;
    } catch (e) {
      AppLogger.error('Error getting unpaid invoices', e);
      rethrow;
    }
  }

  @override
  Future<String> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    try {
      final batch = _firestore.batch();
      final invoicesCol = await _tenantInvoices();
      final itemsCol = await _tenantInvoiceItems();

      // Create invoice
      final invoiceRef = invoicesCol.doc();
      final tenantId = await _currentTenantId();
      final invoiceData = {
        ..._invoiceToFirestore(invoice.copyWith(id: invoiceRef.id)),
        'createdBy': _currentUid(),
        'tenantId': tenantId,
      };
      batch.set(invoiceRef, invoiceData);

      // Create invoice items
      for (final item in items) {
        final itemRef = itemsCol.doc();
        final itemData = _invoiceItemToFirestore(item.copyWith(
          id: itemRef.id,
          invoiceId: invoiceRef.id,
        ));
        itemData['tenantId'] = tenantId;
        batch.set(itemRef, itemData);
      }

      await batch.commit();
      AppLogger.info('Invoice created: ${invoice.invoiceNumber}');
      return invoiceRef.id;
    } catch (e) {
      AppLogger.error('Error creating invoice', e);
      rethrow;
    }
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    try {
      final invoicesCol = await _tenantInvoices();
      await invoicesCol.doc(invoice.id).update(_invoiceToFirestore(invoice));

      AppLogger.info('Invoice updated: ${invoice.invoiceNumber}');
    } catch (e) {
      AppLogger.error('Error updating invoice: ${invoice.id}', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    try {
      final batch = _firestore.batch();

      // Delete invoice
      final invoicesCol = await _tenantInvoices();
      batch.delete(invoicesCol.doc(id));

      // Delete associated items
      final itemsCol = await _tenantInvoiceItems();
      final itemsSnapshot =
          await itemsCol.where('invoiceId', isEqualTo: id).get();

      for (final doc in itemsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      AppLogger.info('Invoice deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting invoice: $id', e);
      rethrow;
    }
  }

  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    try {
      final itemsCol = await _tenantInvoiceItems();
      final snapshot = await itemsCol
          .where('invoiceId', isEqualTo: invoiceId)
          .orderBy('itemOrder')
          .get();

      return snapshot.docs
          .map((doc) => _invoiceItemFromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting invoice items: $invoiceId', e);
      rethrow;
    }
  }

  @override
  Future<void> updateInvoiceStatus(String id, InvoiceStatus status) async {
    try {
      final invoicesCol = await _tenantInvoices();
      await invoicesCol.doc(id).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Invoice status updated: $id -> ${status.name}');
    } catch (e) {
      AppLogger.error('Error updating invoice status: $id', e);
      rethrow;
    }
  }

  @override
  Future<void> markInvoiceAsPaid(String id, {DateTime? paidDate}) async {
    try {
      final invoicesCol = await _tenantInvoices();
      await invoicesCol.doc(id).update({
        'isPaid': true,
        'status': InvoiceStatus.paid.name,
        'paidDate': Timestamp.fromDate(paidDate ?? DateTime.now()),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Invoice marked as paid: $id');
    } catch (e) {
      AppLogger.error('Error marking invoice as paid: $id', e);
      rethrow;
    }
  }

  @override
  Future<List<Invoice>> searchInvoices(String query,
      {bool includeItems = false}) async {
    try {
      final snapshot = await (await _scopedInvoicesCollection())
          .where('invoiceNumber', isGreaterThanOrEqualTo: query)
          .where('invoiceNumber', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final invoices = <Invoice>[];
      for (final doc in snapshot.docs) {
        final invoice = _invoiceFromFirestore(doc);
        if (includeItems) {
          final items = await getInvoiceItems(invoice.id);
          invoices.add(invoice.copyWith(items: items));
        } else {
          invoices.add(invoice);
        }
      }

      return invoices;
    } catch (e) {
      AppLogger.error('Error searching invoices: $query', e);
      rethrow;
    }
  }

  @override
  Future<Invoice?> getInvoiceByNumber(String number,
      {bool includeItems = true}) async {
    try {
      final col = await _scopedInvoicesCollection();
      final snapshot =
          await col.where('invoiceNumber', isEqualTo: number).limit(1).get();
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final invoice = _invoiceFromFirestore(doc);
      if (includeItems) {
        final items = await getInvoiceItems(invoice.id);
        return invoice.copyWith(items: items);
      }
      return invoice;
    } catch (e) {
      AppLogger.error('Error getting invoice by number: $number', e);
      rethrow;
    }
  }

  @override
  Future<int> getInvoiceCountByStatus(InvoiceStatus status) async {
    try {
      final col = await _scopedInvoicesCollection();
      final snapshot =
          await col.where('status', isEqualTo: status.name).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting invoice count by status', e);
      rethrow;
    }
  }

  @override
  Future<List<Invoice>> getRecentInvoices({
    int limit = 10,
    bool includeItems = false,
  }) async {
    try {
      final snapshot = await (await _scopedInvoicesCollection())
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final invoices = <Invoice>[];
      for (final doc in snapshot.docs) {
        final invoice = _invoiceFromFirestore(doc);
        if (includeItems) {
          final items = await getInvoiceItems(invoice.id);
          invoices.add(invoice.copyWith(items: items));
        } else {
          invoices.add(invoice);
        }
      }
      return invoices;
    } catch (e) {
      AppLogger.error('Error getting recent invoices', e);
      rethrow;
    }
  }

  @override
  Future<int> getTotalInvoiceCount() async {
    try {
      final col = await _scopedInvoicesCollection();
      final snapshot = await col.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting invoice count', e);
      rethrow;
    }
  }

  @override
  Future<double> getTotalRevenue() async {
    try {
      final col = await _scopedInvoicesCollection();
      final snapshot = await col.where('isPaid', isEqualTo: true).get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += (data['totalAmount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting total revenue', e);
      rethrow;
    }
  }

  @override
  Future<double> getCurrentMonthRevenue() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final col = await _scopedInvoicesCollection();
      final snapshot = await col
          .where('invoiceDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('invoiceDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .where('isPaid', isEqualTo: true)
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += (data['totalAmount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting current month revenue', e);
      rethrow;
    }
  }

  @override
  Future<double> getPendingPaymentAmount() async {
    try {
      final col = await _scopedInvoicesCollection();
      final snapshot = await col.where('isPaid', isEqualTo: false).get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += (data['totalAmount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      AppLogger.error('Error getting pending payment amount', e);
      rethrow;
    }
  }

  @override
  Future<String> getNextInvoiceNumber({String prefix = 'FAT'}) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');

      // Bu ay kaç fatura var?
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final snapshot = await _firestore
          .collection(_invoicesCollection)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final count = snapshot.docs.length + 1;
      final number = count.toString().padLeft(4, '0');

      return '$prefix-$year$month-$number';
    } catch (e) {
      AppLogger.error('Error generating invoice number', e);
      rethrow;
    }
  }

  @override
  Future<List<int>?> generateInvoicePDF(String invoiceId) async {
    // TODO: PDF generation implementation
    AppLogger.info(
        'PDF generation not implemented yet for invoice: $invoiceId');
    return null;
  }

  @override
  Future<bool> sendInvoiceByEmail(String invoiceId, String toEmail) async {
    // TODO: Email sending implementation
    AppLogger.info(
        'Email sending not implemented yet for invoice: $invoiceId to $toEmail');
    return false;
  }

  @override
  Future<void> addInvoiceItem(InvoiceItem item) async {
    final itemsCol = await _tenantInvoiceItems();
    final itemRef = itemsCol.doc();
    final itemData = _invoiceItemToFirestore(item.copyWith(id: itemRef.id));
    itemData['tenantId'] = await _currentTenantId();
    await itemRef.set(itemData);
  }

  @override
  Future<void> addInvoiceItems(List<InvoiceItem> items) async {
    final batch = _firestore.batch();
    final itemsCol = await _tenantInvoiceItems();
    final tenantId = await _currentTenantId();

    for (final item in items) {
      final itemRef = itemsCol.doc();
      final itemData = _invoiceItemToFirestore(item.copyWith(id: itemRef.id));
      itemData['tenantId'] = tenantId;
      batch.set(itemRef, itemData);
    }
    await batch.commit();
  }

  @override
  Future<void> deleteInvoiceItem(String itemId) async {
    final itemsCol = await _tenantInvoiceItems();
    await itemsCol.doc(itemId).delete();
  }

  @override
  Future<void> deleteAllInvoiceItems(String invoiceId) async {
    final itemsCol = await _tenantInvoiceItems();
    final snapshot =
        await itemsCol.where('invoiceId', isEqualTo: invoiceId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> updateInvoiceItem(InvoiceItem item) async {
    final itemsCol = await _tenantInvoiceItems();
    final itemData = _invoiceItemToFirestore(item);
    itemData['tenantId'] = await _currentTenantId();
    await itemsCol.doc(item.id).update(itemData);
  }

  @override
  Future<void> recalculateInvoiceAmounts(String invoiceId) async {
    final items = await getInvoiceItems(invoiceId);
    double subtotal = 0.0;
    double taxAmount = 0.0;
    for (final item in items) {
      subtotal += item.lineTotal;
      taxAmount += item.taxAmount;
    }
    await _firestore.collection(_invoicesCollection).doc(invoiceId).update({
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalAmount': subtotal + taxAmount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Helper methods
  Invoice _invoiceFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      invoiceNumber: data['invoiceNumber'] ?? '',
      customerId: data['customerId'] ?? '',
      invoiceDate: (data['invoiceDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      status: InvoiceStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      subtotal: (data['subtotal'] as num).toDouble(),
      taxAmount: (data['taxAmount'] as num).toDouble(),
      discountAmount: (data['discountAmount'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      currencyCode: data['currencyCode'] ?? 'TRY',
      paymentTerms: data['paymentTerms'],
      notes: data['notes'],
      description: data['description'],
      isPaid: data['isPaid'] ?? false,
      items: const [], // Items loaded separately
      direction: data['direction'] as String?,
      documentType: data['documentType'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _invoiceToFirestore(Invoice invoice) {
    return {
      'invoiceNumber': invoice.invoiceNumber,
      'customerId': invoice.customerId,
      'invoiceDate': Timestamp.fromDate(invoice.invoiceDate),
      'dueDate':
          invoice.dueDate != null ? Timestamp.fromDate(invoice.dueDate!) : null,
      'status': invoice.status.name,
      'subtotal': invoice.subtotal,
      'taxAmount': invoice.taxAmount,
      'discountAmount': invoice.discountAmount,
      'totalAmount': invoice.totalAmount,
      'currencyCode': invoice.currencyCode,
      'paymentTerms': invoice.paymentTerms,
      'notes': invoice.notes,
      'description': invoice.description,
      'isPaid': invoice.isPaid,
      'direction': invoice.direction,
      'documentType': invoice.documentType,
      'createdAt': Timestamp.fromDate(invoice.createdAt),
      'updatedAt': Timestamp.fromDate(invoice.updatedAt),
    };
  }

  InvoiceItem _invoiceItemFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvoiceItem(
      id: doc.id,
      invoiceId: data['invoiceId'] ?? '',
      itemOrder: data['itemOrder'] ?? 0,
      productName: data['productName'] ?? '',
      description: data['description'],
      quantity: (data['quantity'] as num).toDouble(),
      unit: data['unit'] ?? '',
      unitPrice: (data['unitPrice'] as num).toDouble(),
      taxRate: (data['taxRate'] as num).toDouble(),
      taxAmount: (data['taxAmount'] as num).toDouble(),
      lineTotal: (data['lineTotal'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _invoiceItemToFirestore(InvoiceItem item) {
    return {
      'invoiceId': item.invoiceId,
      'itemOrder': item.itemOrder,
      'productName': item.productName,
      'description': item.description,
      'quantity': item.quantity,
      'unit': item.unit,
      'unitPrice': item.unitPrice,
      'taxRate': item.taxRate,
      'taxAmount': item.taxAmount,
      'lineTotal': item.lineTotal,
      'createdAt': Timestamp.fromDate(item.createdAt),
    };
  }
}
