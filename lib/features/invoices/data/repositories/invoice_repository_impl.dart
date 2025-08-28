// ========== lib/features/invoices/data/repositories/invoice_repository_impl.dart ==========

import 'package:tamgaci/features/invoices/data/models/invoice_entity.dart';
import 'package:tamgaci/features/invoices/domain/entities/repositories/invoice_repository.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';

import '../models/invoice_status.dart';
import '../../../../core/database/tamgaci_database.dart';
import '../../../customers/domain/repositories/customer_repository.dart';

/// Fatura repository implementasyonu - Data katmanı
class InvoiceRepositoryImpl implements InvoiceRepository {
  final TamgaciDatabase _database;
  final CustomerRepository _customerRepository;
  final Uuid _uuid = const Uuid();

  InvoiceRepositoryImpl(this._database, this._customerRepository);

  @override
  Future<String> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final invoiceDao = _database.invoiceDao;
    final itemDao = _database.invoiceItemDao;

    // Yeni ID oluştur
    final id = invoice.id.isEmpty ? _uuid.v4() : invoice.id;
    final now = DateTime.now();

    // Fatura entity'si oluştur
    final invoiceEntity = invoice
        .copyWith(id: id, createdAt: now, updatedAt: now)
        .toEntity();

    // Transaction başlat (pseudo - Floor'da built-in transaction yok)
    try {
      // Önce faturayı kaydet
      await invoiceDao.insertInvoice(invoiceEntity);

      // Sonra kalemleri kaydet
      if (items.isNotEmpty) {
        final itemEntities = items.map((item) {
          return item
              .copyWith(
                id: item.id.isEmpty ? _uuid.v4() : item.id,
                invoiceId: id,
                createdAt: now,
              )
              .toEntity();
        }).toList();

        await itemDao.insertInvoiceItems(itemEntities);
      }

      return id;
    } catch (e) {
      // Hata durumunda rollback (basit implementation)
      try {
        await invoiceDao.deleteInvoiceById(id);
      } catch (_) {
        // Ignore cleanup errors
      }
      rethrow;
    }
  }

  @override
  Future<void> addInvoiceItem(InvoiceItem item) async {
    final itemDao = _database.invoiceItemDao;
    final id = item.id.isEmpty ? _uuid.v4() : item.id;

    final entity = item.copyWith(id: id, createdAt: DateTime.now()).toEntity();

    await itemDao.insertInvoiceItem(entity);

    // Fatura tutarlarını yeniden hesapla
    await recalculateInvoiceAmounts(item.invoiceId);
  }

  @override
  Future<void> addInvoiceItems(List<InvoiceItem> items) async {
    if (items.isEmpty) return;

    final itemDao = _database.invoiceItemDao;
    final now = DateTime.now();

    final entities = items.map((item) {
      final id = item.id.isEmpty ? _uuid.v4() : item.id;
      return item.copyWith(id: id, createdAt: now).toEntity();
    }).toList();

    await itemDao.insertInvoiceItems(entities);

    // İlk kalemin invoice ID'si ile tutarları yeniden hesapla
    if (items.isNotEmpty) {
      await recalculateInvoiceAmounts(items.first.invoiceId);
    }
  }

  @override
  Future<List<Invoice>> getAllInvoices({bool includeItems = false}) async {
    final invoiceDao = _database.invoiceDao;
    final invoiceEntities = await invoiceDao.getAllInvoices();

    return await _mapEntitiesToDomain(
      invoiceEntities,
      includeItems: includeItems,
    );
  }

  @override
  Future<Invoice?> getInvoiceById(String id, {bool includeItems = true}) async {
    final invoiceDao = _database.invoiceDao;
    final invoiceEntity = await invoiceDao.getInvoiceById(id);

    if (invoiceEntity == null) return null;

    final invoices = await _mapEntitiesToDomain([
      invoiceEntity,
    ], includeItems: includeItems);
    return invoices.isNotEmpty ? invoices.first : null;
  }

  @override
  Future<Invoice?> getInvoiceByNumber(
    String number, {
    bool includeItems = true,
  }) async {
    final invoiceDao = _database.invoiceDao;
    final invoiceEntity = await invoiceDao.getInvoiceByNumber(number);

    if (invoiceEntity == null) return null;

    final invoices = await _mapEntitiesToDomain([
      invoiceEntity,
    ], includeItems: includeItems);
    return invoices.isNotEmpty ? invoices.first : null;
  }

  @override
  Future<List<Invoice>> getInvoicesByCustomerId(
    String customerId, {
    bool includeItems = false,
  }) async {
    final invoiceDao = _database.invoiceDao;
    final invoiceEntities = await invoiceDao.getInvoicesByCustomerId(
      customerId,
    );

    return await _mapEntitiesToDomain(
      invoiceEntities,
      includeItems: includeItems,
    );
  }

  @override
  Future<List<Invoice>> getInvoicesByStatus(
    InvoiceStatus status, {
    bool includeItems = false,
  }) async {
    final invoiceDao = _database.invoiceDao;
    final invoiceEntities = await invoiceDao.getInvoicesByStatus(status.value);

    return await _mapEntitiesToDomain(
      invoiceEntities,
      includeItems: includeItems,
    );
  }

  @override
  Future<List<Invoice>> getInvoicesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeItems = false,
  }) async {
    final invoiceDao = _database.invoiceDao;
    final invoiceEntities = await invoiceDao.getInvoicesByDateRange(
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
    );

    return await _mapEntitiesToDomain(
      invoiceEntities,
      includeItems: includeItems,
    );
  }

  @override
  Future<List<Invoice>> getUnpaidInvoices({bool includeItems = false}) async {
    final invoiceDao = _database.invoiceDao;
    final invoiceEntities = await invoiceDao.getUnpaidInvoices();

    return await _mapEntitiesToDomain(
      invoiceEntities,
      includeItems: includeItems,
    );
  }

  @override
  Future<List<Invoice>> getOverdueInvoices({bool includeItems = false}) async {
    final invoiceDao = _database.invoiceDao;
    final currentDate = DateTime.now().millisecondsSinceEpoch;
    final invoiceEntities = await invoiceDao.getOverdueInvoices(currentDate);

    return await _mapEntitiesToDomain(
      invoiceEntities,
      includeItems: includeItems,
    );
  }

  @override
  Future<List<Invoice>> getRecentInvoices({
    int limit = 10,
    bool includeItems = false,
  }) async {
    final invoiceDao = _database.invoiceDao;
    final invoiceEntities = await invoiceDao.getRecentInvoices(limit);

    return await _mapEntitiesToDomain(
      invoiceEntities,
      includeItems: includeItems,
    );
  }

  @override
  Future<List<Invoice>> searchInvoices(
    String query, {
    bool includeItems = false,
  }) async {
    final invoiceDao = _database.invoiceDao;
    final searchTerm = '%$query%';
    final invoiceEntities = await invoiceDao.searchInvoices(searchTerm);

    return await _mapEntitiesToDomain(
      invoiceEntities,
      includeItems: includeItems,
    );
  }

  @override
  Future<int> getTotalInvoiceCount() async {
    final invoiceDao = _database.invoiceDao;
    return await invoiceDao.getTotalInvoiceCount() ?? 0;
  }

  @override
  Future<int> getInvoiceCountByStatus(InvoiceStatus status) async {
    final invoiceDao = _database.invoiceDao;
    return await invoiceDao.getInvoiceCountByStatus(status.value) ?? 0;
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    final invoiceDao = _database.invoiceDao;
    final entity = invoice.copyWith(updatedAt: DateTime.now()).toEntity();
    await invoiceDao.updateInvoice(entity);
  }

  @override
  Future<void> updateInvoiceStatus(String id, InvoiceStatus status) async {
    final invoiceDao = _database.invoiceDao;
    await invoiceDao.updateInvoiceStatus(
      id,
      status.value,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> markInvoiceAsPaid(String id, {DateTime? paidDate}) async {
    final invoiceDao = _database.invoiceDao;
    final paymentDate = paidDate ?? DateTime.now();

    await invoiceDao.updateInvoicePaymentStatus(
      id,
      true,
      paymentDate.millisecondsSinceEpoch,
      InvoiceStatus.paid.value,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> updateInvoiceItem(InvoiceItem item) async {
    final itemDao = _database.invoiceItemDao;
    await itemDao.updateInvoiceItem(item.toEntity());

    // Fatura tutarlarını yeniden hesapla
    await recalculateInvoiceAmounts(item.invoiceId);
  }

  @override
  Future<void> recalculateInvoiceAmounts(String invoiceId) async {
    final invoiceDao = _database.invoiceDao;
    final itemDao = _database.invoiceItemDao;

    // Faturanın kalemlerini getir
    final itemEntities = await itemDao.getInvoiceItemsByInvoiceId(invoiceId);
    final items = itemEntities.map((e) => InvoiceItem.fromEntity(e)).toList();

    // Tutarları hesapla
    double subtotal = 0.0;
    double taxAmount = 0.0;

    for (final item in items) {
      subtotal += item.lineTotal;
      taxAmount += item.taxAmount;
    }

    // Faturayı getir ve indirim tutarını al
    final invoiceEntity = await invoiceDao.getInvoiceById(invoiceId);
    if (invoiceEntity == null) return;

    final discountAmount = invoiceEntity.discountAmount / 100.0;
    final totalAmount = subtotal + taxAmount - discountAmount;

    // Tutarları güncelle
    await invoiceDao.updateInvoiceAmounts(
      invoiceId,
      (subtotal * 100).round(),
      (taxAmount * 100).round(),
      (discountAmount * 100).round(),
      (totalAmount * 100).round(),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> deleteInvoice(String id) async {
    final invoiceDao = _database.invoiceDao;
    await invoiceDao.deleteInvoiceById(id);
    // Cascade delete items (foreign key constraint)
  }

  @override
  Future<void> deleteInvoiceItem(String itemId) async {
    final itemDao = _database.invoiceItemDao;

    // Önce item'ı getir (invoice ID için)
    final item = await itemDao.getInvoiceItemById(itemId);
    if (item == null) return;

    await itemDao.deleteInvoiceItemById(itemId);

    // Fatura tutarlarını yeniden hesapla
    await recalculateInvoiceAmounts(item.invoiceId);
  }

  @override
  Future<void> deleteAllInvoiceItems(String invoiceId) async {
    final itemDao = _database.invoiceItemDao;
    await itemDao.deleteInvoiceItemsByInvoiceId(invoiceId);

    // Fatura tutarlarını sıfırla
    await recalculateInvoiceAmounts(invoiceId);
  }

  @override
  Stream<List<Invoice>> watchAllInvoices() {
    final invoiceDao = _database.invoiceDao;
    return invoiceDao.watchAllInvoices().asyncMap(
      (entities) => _mapEntitiesToDomain(entities, includeItems: false),
    );
  }

  @override
  Stream<Invoice?> watchInvoiceById(String id) {
    final invoiceDao = _database.invoiceDao;
    return invoiceDao.watchInvoiceById(id).asyncMap((entity) async {
      if (entity == null) return null;
      final invoices = await _mapEntitiesToDomain([entity], includeItems: true);
      return invoices.isNotEmpty ? invoices.first : null;
    });
  }

  @override
  Stream<List<Invoice>> watchInvoicesByCustomerId(String customerId) {
    final invoiceDao = _database.invoiceDao;
    return invoiceDao
        .watchInvoicesByCustomerId(customerId)
        .asyncMap(
          (entities) => _mapEntitiesToDomain(entities, includeItems: false),
        );
  }

  @override
  Stream<List<Invoice>> watchInvoicesByStatus(InvoiceStatus status) {
    final invoiceDao = _database.invoiceDao;
    return invoiceDao
        .watchInvoicesByStatus(status.value)
        .asyncMap(
          (entities) => _mapEntitiesToDomain(entities, includeItems: false),
        );
  }

  @override
  Stream<List<Invoice>> watchUnpaidInvoices() {
    final invoiceDao = _database.invoiceDao;
    return invoiceDao.watchUnpaidInvoices().asyncMap(
      (entities) => _mapEntitiesToDomain(entities, includeItems: false),
    );
  }

  @override
  Future<String> getNextInvoiceNumber({String prefix = 'FAT'}) async {
    final invoiceDao = _database.invoiceDao;

    // Bu yılın fatura sayısını getir
    final currentYear = DateTime.now().year;
    final startOfYear = DateTime(currentYear, 1, 1);
    final endOfYear = DateTime(currentYear, 12, 31, 23, 59, 59);

    final yearlyInvoices = await invoiceDao.getInvoicesByDateRange(
      startOfYear.millisecondsSinceEpoch,
      endOfYear.millisecondsSinceEpoch,
    );

    final nextNumber = yearlyInvoices.length + 1;
    return '$prefix${currentYear.toString().substring(2)}${nextNumber.toString().padLeft(4, '0')}';
  }

  // ========== İSTATİSTİKLER ==========

  @override
  Future<double> getTotalRevenue() async {
    final invoiceDao = _database.invoiceDao;
    final totalCents = await invoiceDao.getTotalRevenue() ?? 0;
    return totalCents / 100.0;
  }

  @override
  Future<double> getCurrentMonthRevenue() async {
    final invoiceDao = _database.invoiceDao;
    final totalCents = await invoiceDao.getCurrentMonthRevenue() ?? 0;
    return totalCents / 100.0;
  }

  @override
  Future<double> getPendingPaymentAmount() async {
    final invoiceDao = _database.invoiceDao;
    final totalCents = await invoiceDao.getPendingPaymentAmount() ?? 0;
    return totalCents / 100.0;
  }

  @override
  Future<List<int>?> generateInvoicePDF(String invoiceId) async {
    // TODO: PDF generation implementation
    throw UnimplementedError('PDF generation not implemented yet');
  }

  @override
  Future<bool> sendInvoiceByEmail(String invoiceId, String toEmail) async {
    // TODO: Email sending implementation
    throw UnimplementedError('Email sending not implemented yet');
  }

  // ========== PRIVATE HELPER METODLARI ==========

  /// Entity'leri domain object'lere dönüştürür
  Future<List<Invoice>> _mapEntitiesToDomain(
    List<InvoiceEntity> entities, {
    bool includeItems = false,
  }) async {
    final result = <Invoice>[];

    for (final entity in entities) {
      // Customer bilgilerini getir
      final customer = await _customerRepository.getCustomerById(
        entity.customerId,
      );

      // Invoice items getir (eğer isteniyorsa)
      List<InvoiceItem> items = [];
      if (includeItems) {
        final itemDao = _database.invoiceItemDao;
        final itemEntities = await itemDao.getInvoiceItemsByInvoiceId(
          entity.id,
        );
        items = itemEntities.map((e) => InvoiceItem.fromEntity(e)).toList();
      }

      final invoice = Invoice.fromEntity(
        entity,
        customer: customer,
        items: items,
      );

      result.add(invoice);
    }

    return result;
  }
}
