// ========== PAYMENT COLLECTION STATE ==========
// lib/features/payment_collection/presentation/models/payment_collection_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_transaction.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_source.dart';

enum PaymentCollectionStatus {
  initial,
  loading,
  loaded,
  error,
  submitting,
  success,
  deleted,
  updated,
  created,
  saving,
  deleting,
}

class PaymentCollectionState extends Equatable {
  final PaymentCollectionStatus status;
  final List<PaymentTransaction> transactions;
  final List<PaymentMethod> paymentMethods;
  final List<PaymentSource> paymentSources;
  final PaymentTransaction? selectedTransaction;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final int totalCount;
  final Map<String, dynamic> filters;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isFormVisible;
  final bool isEditMode;

  const PaymentCollectionState({
    this.status = PaymentCollectionStatus.initial,
    this.transactions = const [],
    this.paymentMethods = const [],
    this.paymentSources = const [],
    this.selectedTransaction,
    this.errorMessage,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.totalCount = 0,
    this.filters = const {},
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.isFormVisible = false,
    this.isEditMode = false,
  });

  PaymentCollectionState copyWith({
    PaymentCollectionStatus? status,
    List<PaymentTransaction>? transactions,
    List<PaymentMethod>? paymentMethods,
    List<PaymentSource>? paymentSources,
    PaymentTransaction? selectedTransaction,
    String? errorMessage,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    Map<String, dynamic>? filters,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool? isFormVisible,
    bool? isEditMode,
  }) {
    return PaymentCollectionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      paymentSources: paymentSources ?? this.paymentSources,
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isFormVisible: isFormVisible ?? this.isFormVisible,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  /// Loading durumu ayarla
  PaymentCollectionState setLoading(bool loading) {
    return copyWith(
      status: loading
          ? PaymentCollectionStatus.loading
          : PaymentCollectionStatus.loaded,
    );
  }

  /// Error durumu ayarla
  PaymentCollectionState setError(String? error) {
    return copyWith(
      status: PaymentCollectionStatus.error,
      errorMessage: error,
    );
  }

  /// Success durumu ayarla
  PaymentCollectionState setSuccess(String? message) {
    return copyWith(
      status: PaymentCollectionStatus.success,
      errorMessage: message,
    );
  }

  /// Saving durumu ayarla
  PaymentCollectionState setSaving(bool saving) {
    return copyWith(
      status: saving
          ? PaymentCollectionStatus.submitting
          : PaymentCollectionStatus.loaded,
    );
  }

  /// Deleting durumu ayarla
  PaymentCollectionState setDeleting(bool deleting) {
    return copyWith(
      status: deleting
          ? PaymentCollectionStatus.deleting
          : PaymentCollectionStatus.loaded,
    );
  }

  /// İşlemleri güncelle
  PaymentCollectionState updateTransactions(
      List<PaymentTransaction> transactions) {
    return copyWith(
      transactions: transactions,
      status: PaymentCollectionStatus.loaded,
    );
  }

  /// İşlem ekle
  PaymentCollectionState addTransaction(PaymentTransaction transaction) {
    final updatedTransactions = List<PaymentTransaction>.from(transactions)
      ..add(transaction);
    return copyWith(
      transactions: updatedTransactions,
    );
  }

  /// İşlem güncelle
  PaymentCollectionState updateTransaction(PaymentTransaction transaction) {
    final updatedTransactions = transactions
        .map((t) => t.id == transaction.id ? transaction : t)
        .toList();
    return copyWith(
      transactions: updatedTransactions,
      selectedTransaction: selectedTransaction?.id == transaction.id
          ? transaction
          : selectedTransaction,
    );
  }

  /// İşlem kaldır
  PaymentCollectionState removeTransaction(String id) {
    final updatedTransactions = transactions.where((t) => t.id != id).toList();
    return copyWith(
      transactions: updatedTransactions,
      selectedTransaction:
          selectedTransaction?.id == id ? null : selectedTransaction,
    );
  }

  /// Seçili işlem ayarla
  PaymentCollectionState setSelectedTransaction(
      PaymentTransaction? transaction) {
    return copyWith(
      selectedTransaction: transaction,
    );
  }

  /// Filtre ayarla
  PaymentCollectionState setFilter(String key, dynamic value) {
    final updatedFilters = Map<String, dynamic>.from(filters)..[key] = value;
    return copyWith(filters: updatedFilters);
  }

  /// Filtre temizle
  PaymentCollectionState clearFilter(String key) {
    final updatedFilters = Map<String, dynamic>.from(filters)..remove(key);
    return copyWith(filters: updatedFilters);
  }

  /// Tüm filtreleri temizle
  PaymentCollectionState clearAllFilters() {
    return copyWith(filters: {});
  }

  /// Arama ayarla
  PaymentCollectionState setSearch(String? query) {
    return copyWith(searchQuery: query);
  }

  /// Tarih aralığı ayarla
  PaymentCollectionState setDateRange(DateTime? startDate, DateTime? endDate) {
    return copyWith(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Form görünürlüğü ayarla
  PaymentCollectionState setFormVisible(bool visible) {
    return copyWith(isFormVisible: visible);
  }

  /// Düzenleme modu ayarla
  PaymentCollectionState setEditMode(bool editMode) {
    return copyWith(isEditMode: editMode);
  }

  /// Hata temizle
  PaymentCollectionState clearError() {
    return copyWith(
      status: PaymentCollectionStatus.loaded,
      errorMessage: null,
    );
  }

  /// Başarı mesajı temizle
  PaymentCollectionState clearSuccess() {
    return copyWith(
      status: PaymentCollectionStatus.loaded,
      errorMessage: null,
    );
  }

  /// Loading durumu
  bool get isLoading => status == PaymentCollectionStatus.loading;


  @override
  List<Object?> get props => [
        status,
        transactions,
        paymentMethods,
        paymentSources,
        selectedTransaction,
        errorMessage,
        isLoadingMore,
        hasMore,
        currentPage,
        totalCount,
        filters,
        searchQuery,
        startDate,
        endDate,
        isFormVisible,
        isEditMode,
      ];
}
