// ========== lib/features/invoices/presentation/providers/invoice_providers.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: unused_element
import 'package:tamgaci/features/invoices/domain/entities/repositories/invoice_repository.dart';
import 'package:tamgaci/features/invoices/data/repositories/invoice_firebase_repository.dart';
// import '../../../customers/domain/entities/customer.dart';
// import '../../../customers/domain/entities/customer_enums.dart';
// import '../../../customers/data/models/customer_entity.dart'; // Removed - using Firebase only
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../data/models/invoice_status.dart';

const List<Invoice> _mockInvoices = [];

// ========== BASE PROVIDERS ==========

/// Invoice repository provider - Firebase implementation (no mocks)
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceFirebaseRepository();
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

/// Müşteri faturaları stream provider'ı (reactive)
final customerInvoicesStreamProvider =
    StreamProvider.family<List<Invoice>, String>((ref, customerId) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.watchInvoicesByCustomerId(customerId);
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

abstract class _EmptyInvoiceRepository implements InvoiceRepository {}
