// ========== lib/features/invoices/presentation/providers/invoice_providers.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tamgaci/features/invoices/domain/entities/repositories/invoice_repository.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/data/models/customer_entity.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../data/repositories/invoice_repository_impl.dart';

import '../../data/models/invoice_status.dart';
import '../../../../core/database/tamgaci_database.dart' as core;

// ========== BASE PROVIDERS ==========

/// Invoice repository provider
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  // Web platformunda boş repository döndür (geçici)
  if (kIsWeb) {
    return _EmptyInvoiceRepository();
  }

  final database = ref.watch(core.databaseProvider).value;
  final customerRepository = ref.watch(customerRepositoryProvider);

  if (database == null) {
    throw Exception('Database not initialized');
  }

  return InvoiceRepositoryImpl(database, customerRepository);
});

// ========== DATA PROVIDERS ==========

/// Tüm faturalar provider'ı
final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getAllInvoices(includeItems: false);
});

/// Faturalar stream provider'ı (reactive)
final invoicesStreamProvider = StreamProvider<List<Invoice>>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.watchAllInvoices();
});

/// Belirli fatura provider'ı
final invoiceProvider = FutureProvider.family<Invoice?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getInvoiceById(id, includeItems: true);
});

/// Fatura stream provider'ı (tek fatura)
final invoiceStreamProvider = StreamProvider.family<Invoice?, String>((
  ref,
  id,
) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.watchInvoiceById(id);
});

/// Müşteri faturları provider'ı
final customerInvoicesProvider = FutureProvider.family<List<Invoice>, String>((
  ref,
  customerId,
) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getInvoicesByCustomerId(
    customerId,
    includeItems: false,
  );
});

/// Duruma göre faturalar provider'ı
final invoicesByStatusProvider =
    FutureProvider.family<List<Invoice>, InvoiceStatus>((ref, status) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getInvoicesByStatus(status, includeItems: false);
});

/// Ödenmemiş faturalar provider'ı
final unpaidInvoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getUnpaidInvoices(includeItems: false);
});

/// Vadesi geçmiş faturalar provider'ı
final overdueInvoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getOverdueInvoices(includeItems: false);
});

/// Son faturalar provider'ı
final recentInvoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getRecentInvoices(limit: 10, includeItems: false);
});

/// Toplam fatura sayısı provider'ı
final invoiceCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getTotalInvoiceCount();
});

/// Toplam gelir provider'ı
final totalRevenueProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getTotalRevenue();
});

/// Bu ay gelir provider'ı
final currentMonthRevenueProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getCurrentMonthRevenue();
});

/// Bekleyen ödeme tutarı provider'ı
final pendingPaymentAmountProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getPendingPaymentAmount();
});

/// Sonraki fatura numarası provider'ı
final nextInvoiceNumberProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.getNextInvoiceNumber();
});

// ========== SEARCH VE FİLTRELEME ==========

/// Arama sorgusu state provider'ı
final invoiceSearchQueryProvider = StateProvider<String>((ref) => '');

/// Seçili fatura durumu filtresi provider'ı
final selectedInvoiceStatusProvider = StateProvider<InvoiceStatus?>(
  (ref) => null,
);

/// Tarih filtresi provider'ı
final invoiceDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Arama sonuçları provider'ı
final invoiceSearchResultsProvider = FutureProvider<List<Invoice>>((ref) async {
  final query = ref.watch(invoiceSearchQueryProvider);
  if (query.isEmpty) {
    return <Invoice>[];
  }

  final repository = ref.watch(invoiceRepositoryProvider);
  return await repository.searchInvoices(query, includeItems: false);
});

/// Filtrelenmiş faturalar provider'ı
final filteredInvoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final selectedStatus = ref.watch(selectedInvoiceStatusProvider);
  final dateRange = ref.watch(invoiceDateRangeProvider);

  List<Invoice> invoices;

  // Durum filtresi
  if (selectedStatus != null) {
    invoices = await repository.getInvoicesByStatus(
      selectedStatus,
      includeItems: false,
    );
  } else {
    invoices = await repository.getAllInvoices(includeItems: false);
  }

  // Tarih filtresi
  if (dateRange != null) {
    invoices = invoices.where((invoice) {
      return invoice.invoiceDate.isAfter(
            dateRange.start.subtract(const Duration(days: 1)),
          ) &&
          invoice.invoiceDate.isBefore(
            dateRange.end.add(const Duration(days: 1)),
          );
    }).toList();
  }

  return invoices;
});

// ========== FORM STATE MANAGEMENT ==========

/// Fatura formu state provider'ı
final invoiceFormProvider =
    StateNotifierProvider<InvoiceFormNotifier, InvoiceFormState>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return InvoiceFormNotifier(repository);
});

/// Fatura form state sınıfı
class InvoiceFormState {
  final Invoice? invoice;
  final List<InvoiceItem> items;
  final bool isLoading;
  final bool isEditing;
  final String? errorMessage;
  final String? successMessage;

  const InvoiceFormState({
    this.invoice,
    this.items = const [],
    this.isLoading = false,
    this.isEditing = false,
    this.errorMessage,
    this.successMessage,
  });

  InvoiceFormState copyWith({
    Invoice? invoice,
    List<InvoiceItem>? items,
    bool? isLoading,
    bool? isEditing,
    String? errorMessage,
    String? successMessage,
  }) {
    return InvoiceFormState(
      invoice: invoice ?? this.invoice,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// Toplam tutar hesapla
  double get totalAmount {
    return items.fold(
      0.0,
      (sum, item) => sum + item.lineTotal + item.taxAmount,
    );
  }

  /// Alt toplam hesapla
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  /// KDV tutarı hesapla
  double get taxAmount {
    return items.fold(0.0, (sum, item) => sum + item.taxAmount);
  }
}

/// Fatura form state notifier'ı
class InvoiceFormNotifier extends StateNotifier<InvoiceFormState> {
  final InvoiceRepository _repository;

  InvoiceFormNotifier(this._repository) : super(const InvoiceFormState());

  /// Formu düzenleme modunda başlat
  Future<void> initializeForEdit(String invoiceId) async {
    state = state.copyWith(isLoading: true, isEditing: true);

    try {
      final invoice = await _repository.getInvoiceById(
        invoiceId,
        includeItems: true,
      );
      state = state.copyWith(
        invoice: invoice,
        items: invoice?.items ?? [],
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Fatura bilgileri yüklenemedi: $e',
      );
    }
  }

  /// Formu yeni fatura için başlat
  void initializeForCreate() {
    state = const InvoiceFormState(isEditing: false);
  }

  /// Fatura kaydetme
  Future<String?> saveInvoice(Invoice invoice) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      String invoiceId;

      if (state.isEditing) {
        await _repository.updateInvoice(invoice);
        invoiceId = invoice.id;
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Fatura başarıyla güncellendi',
        );
      } else {
        invoiceId = await _repository.createInvoice(invoice, state.items);
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Fatura başarıyla oluşturuldu',
        );
      }

      return invoiceId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Fatura kaydedilemedi: $e',
      );
      return null;
    }
  }

  /// Kalem ekleme
  void addItem(InvoiceItem item) {
    final newItems = [...state.items, item];
    state = state.copyWith(items: newItems);
  }

  /// Kalem güncelleme
  void updateItem(int index, InvoiceItem item) {
    if (index >= 0 && index < state.items.length) {
      final newItems = [...state.items];
      newItems[index] = item;
      state = state.copyWith(items: newItems);
    }
  }

  /// Kalem silme
  void removeItem(int index) {
    if (index >= 0 && index < state.items.length) {
      final newItems = [...state.items];
      newItems.removeAt(index);
      state = state.copyWith(items: newItems);
    }
  }

  /// Tüm kalemleri temizle
  void clearItems() {
    state = state.copyWith(items: []);
  }

  /// Formu temizle
  void clearForm() {
    state = const InvoiceFormState();
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Başarı mesajını temizle
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

/// Web platformu için boş fatura repository sınıfı
class _EmptyInvoiceRepository implements InvoiceRepository {
  // Mock verileri saklamak için static listeler
  static final List<Invoice> _mockInvoices = [
    Invoice(
      id: 'invoice_1',
      invoiceNumber: 'INV-2024-001',
      customerId: 'customer_1',
      customer: Customer(
        id: 'customer_1',
        name: 'ABC Teknoloji Ltd. Şti.',
        email: 'info@abcteknoloji.com',
        phone: '+90 212 555 0123',
        address: 'İstanbul, Türkiye',
        taxNumber: '1234567890',
        taxOffice: 'Kadıköy',
        customerType: CustomerType.company,
        city: 'İstanbul',
        country: 'Türkiye',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      invoiceDate: DateTime.now().subtract(const Duration(days: 15)),
      dueDate: DateTime.now().add(const Duration(days: 15)),
      status: InvoiceStatus.sent,
      subtotal: 8500.0,
      taxAmount: 1530.0,
      discountAmount: 0.0,
      totalAmount: 10030.0,
      currencyCode: 'TRY',
      paymentTerms: '30 gün',
      notes: 'Ödeme için teşekkürler',
      description: 'Web sitesi geliştirme hizmeti',
      isPaid: false,
      items: [
        InvoiceItem(
          id: 'item_1',
          invoiceId: 'invoice_1',
          itemOrder: 1,
          productName: 'Web Sitesi Tasarımı',
          description: 'Responsive web sitesi tasarımı ve geliştirme',
          quantity: 1,
          unit: 'Proje',
          unitPrice: 5000.0,
          taxRate: 18.0,
          taxAmount: 900.0,
          lineTotal: 5900.0,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        InvoiceItem(
          id: 'item_2',
          invoiceId: 'invoice_1',
          itemOrder: 2,
          productName: 'SEO Optimizasyonu',
          description: 'Arama motoru optimizasyonu hizmeti',
          quantity: 1,
          unit: 'Paket',
          unitPrice: 3500.0,
          taxRate: 18.0,
          taxAmount: 630.0,
          lineTotal: 4130.0,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Invoice(
      id: 'invoice_2',
      invoiceNumber: 'INV-2024-002',
      customerId: 'customer_2',
      customer: Customer(
        id: 'customer_2',
        name: 'XYZ Danışmanlık',
        email: 'iletisim@xyz.com',
        phone: '+90 216 555 0456',
        address: 'Ankara, Türkiye',
        taxNumber: '9876543210',
        taxOffice: 'Çankaya',
        customerType: CustomerType.company,
        city: 'Ankara',
        country: 'Türkiye',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      invoiceDate: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().add(const Duration(days: 20)),
      status: InvoiceStatus.paid,
      subtotal: 12000.0,
      taxAmount: 2160.0,
      discountAmount: 500.0,
      totalAmount: 13660.0,
      currencyCode: 'TRY',
      paymentTerms: '15 gün',
      notes: 'Ödeme alındı',
      description: 'Dijital pazarlama kampanyası',
      isPaid: true,
      paidDate: DateTime.now().subtract(const Duration(days: 5)),
      items: [
        InvoiceItem(
          id: 'item_3',
          invoiceId: 'invoice_2',
          itemOrder: 1,
          productName: 'Google Ads Yönetimi',
          description: 'Aylık Google Ads kampanya yönetimi',
          quantity: 3,
          unit: 'Ay',
          unitPrice: 4000.0,
          taxRate: 18.0,
          taxAmount: 2160.0,
          lineTotal: 14160.0,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Invoice(
      id: 'invoice_3',
      invoiceNumber: 'INV-2024-003',
      customerId: 'customer_3',
      customer: Customer(
        id: 'customer_3',
        name: 'Mehmet Yılmaz',
        email: 'mehmet@email.com',
        phone: '+90 532 555 0789',
        address: 'İzmir, Türkiye',
        customerType: CustomerType.individual,
        city: 'İzmir',
        country: 'Türkiye',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      invoiceDate: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(days: 25)),
      status: InvoiceStatus.draft,
      subtotal: 2500.0,
      taxAmount: 450.0,
      discountAmount: 0.0,
      totalAmount: 2950.0,
      currencyCode: 'TRY',
      paymentTerms: '30 gün',
      notes: 'Taslak fatura',
      description: 'Logo tasarım hizmeti',
      isPaid: false,
      items: [
        InvoiceItem(
          id: 'item_4',
          invoiceId: 'invoice_3',
          itemOrder: 1,
          productName: 'Logo Tasarımı',
          description: 'Kurumsal logo tasarımı ve vektör dosyaları',
          quantity: 1,
          unit: 'Adet',
          unitPrice: 2500.0,
          taxRate: 18.0,
          taxAmount: 450.0,
          lineTotal: 2950.0,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<String> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final newInvoice = invoice.copyWith(
      id: 'invoice_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: items,
    );
    _mockInvoices.add(newInvoice);
    return newInvoice.id;
  }

  @override
  Future<void> deleteInvoice(String id) async {
    _mockInvoices.removeWhere((invoice) => invoice.id == id);
  }

  @override
  Future<Invoice?> getInvoiceById(
    String id, {
    bool includeItems = false,
  }) async {
    try {
      return _mockInvoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Invoice>> getAllInvoices({bool includeItems = false}) async {
    return List.from(_mockInvoices);
  }

  @override
  Future<List<Invoice>> getInvoicesByCustomerId(
    String customerId, {
    bool includeItems = false,
  }) async {
    return _mockInvoices
        .where((invoice) => invoice.customerId == customerId)
        .toList();
  }

  @override
  Future<List<Invoice>> getInvoicesByStatus(
    InvoiceStatus status, {
    bool includeItems = false,
  }) async {
    return _mockInvoices.where((invoice) => invoice.status == status).toList();
  }

  @override
  Future<List<Invoice>> getUnpaidInvoices({bool includeItems = false}) async {
    return _mockInvoices.where((invoice) => !invoice.isPaid).toList();
  }

  @override
  Future<List<Invoice>> getOverdueInvoices({bool includeItems = false}) async {
    final now = DateTime.now();
    return _mockInvoices
        .where(
          (invoice) =>
              !invoice.isPaid &&
              invoice.dueDate != null &&
              invoice.dueDate!.isBefore(now),
        )
        .toList();
  }

  @override
  Future<List<Invoice>> getRecentInvoices({
    int limit = 10,
    bool includeItems = false,
  }) async {
    final sortedInvoices = List<Invoice>.from(_mockInvoices)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedInvoices.take(limit).toList();
  }

  @override
  Future<int> getTotalInvoiceCount() async => _mockInvoices.length;

  Future<double> getTotalInvoiceAmount() async {
    double total = 0.0;
    for (final invoice in _mockInvoices) {
      total += invoice.totalAmount;
    }
    return total;
  }

  Future<double> getTotalUnpaidAmount() async {
    double total = 0.0;
    for (final invoice in _mockInvoices) {
      if (!invoice.isPaid) {
        total += invoice.totalAmount;
      }
    }
    return total;
  }

  @override
  Future<String> getNextInvoiceNumber({String prefix = 'INV'}) async {
    final lastInvoice = _mockInvoices
        .where((invoice) => invoice.invoiceNumber.startsWith(prefix))
        .map((invoice) {
      final numberPart = invoice.invoiceNumber.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      return int.tryParse(numberPart) ?? 0;
    }).reduce((a, b) => a > b ? a : b);

    return '$prefix-${DateTime.now().year}-${(lastInvoice + 1).toString().padLeft(3, '0')}';
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    final index = _mockInvoices.indexWhere((inv) => inv.id == invoice.id);
    if (index != -1) {
      final updatedInvoice = invoice.copyWith(updatedAt: DateTime.now());
      _mockInvoices[index] = updatedInvoice;
    }
  }

  @override
  Future<void> updateInvoiceStatus(String id, InvoiceStatus status) async {
    final index = _mockInvoices.indexWhere((inv) => inv.id == id);
    if (index != -1) {
      final updatedInvoice = _mockInvoices[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _mockInvoices[index] = updatedInvoice;
    }
  }

  @override
  Future<void> addInvoiceItem(InvoiceItem item) async {
    // Bu metod mock data için kullanılmıyor
  }

  @override
  Future<void> addInvoiceItems(List<InvoiceItem> items) async {
    // Bu metod mock data için kullanılmıyor
  }

  @override
  Future<void> updateInvoiceItem(InvoiceItem item) async {
    // Bu metod mock data için kullanılmıyor
  }

  @override
  Future<void> deleteInvoiceItem(String itemId) async {
    // Bu metod mock data için kullanılmıyor
  }

  @override
  Future<void> deleteAllInvoiceItems(String invoiceId) async {
    // Bu metod mock data için kullanılmıyor
  }

  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    final invoice = _mockInvoices.firstWhere(
      (inv) => inv.id == invoiceId,
      orElse: () => throw Exception('Invoice not found'),
    );
    return invoice.items;
  }

  Future<InvoiceItem?> getInvoiceItem(String invoiceId, String itemId) async {
    final invoice = _mockInvoices.firstWhere(
      (inv) => inv.id == invoiceId,
      orElse: () => throw Exception('Invoice not found'),
    );
    try {
      return invoice.items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  Future<double> getInvoiceTotal(String invoiceId) async {
    final invoice = _mockInvoices.firstWhere(
      (inv) => inv.id == invoiceId,
      orElse: () => throw Exception('Invoice not found'),
    );
    return invoice.totalAmount;
  }

  Future<double> getInvoiceTaxTotal(String invoiceId) async {
    final invoice = _mockInvoices.firstWhere(
      (inv) => inv.id == invoiceId,
      orElse: () => throw Exception('Invoice not found'),
    );
    return invoice.taxAmount;
  }

  Future<double> getInvoiceSubtotal(String invoiceId) async {
    final invoice = _mockInvoices.firstWhere(
      (inv) => inv.id == invoiceId,
      orElse: () => throw Exception('Invoice not found'),
    );
    return invoice.subtotal;
  }

  Future<void> recalculateInvoiceTotals(String invoiceId) async {
    // Mock data için gerekli değil
  }

  @override
  Future<Invoice?> getInvoiceByNumber(
    String number, {
    bool includeItems = false,
  }) async {
    try {
      return _mockInvoices.firstWhere(
        (invoice) => invoice.invoiceNumber == number,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getInvoiceCountByStatus(InvoiceStatus status) async {
    return _mockInvoices.where((invoice) => invoice.status == status).length;
  }

  @override
  Future<double> getCurrentMonthRevenue() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    double total = 0.0;
    for (final invoice in _mockInvoices) {
      if (invoice.isPaid &&
          invoice.paidDate != null &&
          invoice.paidDate!.isAfter(startOfMonth) &&
          invoice.paidDate!.isBefore(endOfMonth)) {
        total += invoice.totalAmount;
      }
    }
    return total;
  }

  @override
  Future<List<int>?> generateInvoicePDF(String invoiceId) async => null;

  Future<void> sendInvoiceEmail(String invoiceId, String email) async {
    // Mock implementation
  }

  Future<Map<InvoiceStatus, int>> getInvoiceStatusStats() async {
    final stats = <InvoiceStatus, int>{};
    for (final status in InvoiceStatus.values) {
      stats[status] = _mockInvoices.where((inv) => inv.status == status).length;
    }
    return stats;
  }

  Future<Map<String, double>> getMonthlyRevenueStats() async {
    // Basit mock implementation
    return {'2024-01': 15000.0, '2024-02': 22000.0, '2024-03': 18000.0};
  }

  Future<List<Map<String, dynamic>>> getTopCustomersByInvoiceCount({
    int limit = 10,
  }) async {
    // Mock implementation
    return [
      {
        'customerId': 'customer_1',
        'name': 'ABC Teknoloji',
        'count': 5,
        'total': 25000.0,
      },
      {
        'customerId': 'customer_2',
        'name': 'XYZ Danışmanlık',
        'count': 3,
        'total': 15000.0,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getDailyRevenueReport({
    int days = 30,
  }) async {
    // Mock implementation
    return [
      {'date': '2024-01-15', 'revenue': 5000.0},
      {'date': '2024-01-16', 'revenue': 3000.0},
    ];
  }

  @override
  Future<List<Invoice>> getInvoicesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeItems = false,
  }) async {
    return _mockInvoices.where((invoice) {
      return invoice.invoiceDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          invoice.invoiceDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<double> getPendingPaymentAmount() async {
    double total = 0.0;
    for (final invoice in _mockInvoices) {
      if (!invoice.isPaid) {
        total += invoice.totalAmount;
      }
    }
    return total;
  }

  @override
  Future<double> getTotalRevenue() async {
    double total = 0.0;
    for (final invoice in _mockInvoices) {
      if (invoice.isPaid) {
        total += invoice.totalAmount;
      }
    }
    return total;
  }

  @override
  Future<void> markInvoiceAsPaid(String invoiceId, {DateTime? paidDate}) async {
    final index = _mockInvoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final updatedInvoice = _mockInvoices[index].copyWith(
        isPaid: true,
        paidDate: paidDate ?? DateTime.now(),
        status: InvoiceStatus.paid,
        updatedAt: DateTime.now(),
      );
      _mockInvoices[index] = updatedInvoice;
    }
  }

  Future<void> markInvoiceAsUnpaid(String invoiceId) async {
    final index = _mockInvoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final updatedInvoice = _mockInvoices[index].copyWith(
        isPaid: false,
        paidDate: null,
        status: InvoiceStatus.sent,
        updatedAt: DateTime.now(),
      );
      _mockInvoices[index] = updatedInvoice;
    }
  }

  Future<void> markInvoiceAsCancelled(String invoiceId) async {
    final index = _mockInvoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final updatedInvoice = _mockInvoices[index].copyWith(
        status: InvoiceStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      _mockInvoices[index] = updatedInvoice;
    }
  }

  Future<void> markInvoiceAsDraft(String invoiceId) async {
    final index = _mockInvoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final updatedInvoice = _mockInvoices[index].copyWith(
        status: InvoiceStatus.draft,
        updatedAt: DateTime.now(),
      );
      _mockInvoices[index] = updatedInvoice;
    }
  }

  @override
  Future<void> recalculateInvoiceAmounts(String invoiceId) async {
    // Mock data için gerekli değil
  }

  @override
  Future<List<Invoice>> searchInvoices(
    String query, {
    bool includeItems = false,
  }) async {
    final lowercaseQuery = query.toLowerCase();
    return _mockInvoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(lowercaseQuery) ||
          (invoice.description?.toLowerCase().contains(lowercaseQuery) ??
              false) ||
          (invoice.customer?.name.toLowerCase().contains(lowercaseQuery) ??
              false);
    }).toList();
  }

  @override
  Future<bool> sendInvoiceByEmail(String invoiceId, String email) async => true;

  @override
  Stream<List<Invoice>> watchUnpaidInvoices() => Stream.value([]);

  @override
  Stream<Invoice?> watchInvoiceById(String id) => Stream.value(null);

  @override
  Stream<List<Invoice>> watchAllInvoices() => Stream.value([]);

  @override
  Stream<List<Invoice>> watchInvoicesByCustomerId(String customerId) =>
      Stream.value([]);

  @override
  Stream<List<Invoice>> watchInvoicesByStatus(InvoiceStatus status) =>
      Stream.value([]);

  Stream<List<InvoiceItem>> watchInvoiceItems(String invoiceId) =>
      Stream.value([]);
}
