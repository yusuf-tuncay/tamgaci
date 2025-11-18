// ========== PAYMENT COLLECTION PROVIDERS ==========
// lib/features/payment_collection/presentation/providers/payment_collection_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_transaction.dart';
import '../../domain/repositories/payment_transaction_repository.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../../domain/repositories/payment_source_repository.dart';
import '../../domain/services/payment_collection_service.dart';
import '../../data/repositories/simple_payment_transaction_repository.dart';
import '../models/payment_collection_state.dart';
import '../models/payment_transaction_form_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// PaymentTransactionRepository provider
final paymentTransactionRepositoryProvider =
    Provider<PaymentTransactionRepository>((ref) {
  ref.watch(authProvider);
  return SimplePaymentTransactionRepository();
});

/// PaymentMethodRepository provider
final paymentMethodRepositoryProvider =
    Provider<PaymentMethodRepository>((ref) {
  throw UnimplementedError(
      'Ödeme yöntemleri modülü henüz aktif değil. Bu özellik yakında eklenecek.');
});

/// PaymentSourceRepository provider
final paymentSourceRepositoryProvider =
    Provider<PaymentSourceRepository>((ref) {
  throw UnimplementedError(
      'Ödeme kaynakları modülü henüz aktif değil. Bu özellik yakında eklenecek.');
});

/// PaymentCollectionService provider
final paymentCollectionServiceProvider =
    Provider<PaymentCollectionService>((ref) {
  throw UnimplementedError(
      'Ödeme toplama servisi henüz aktif değil. Bu özellik yakında eklenecek.');
});

/// PaymentCollectionState provider
final paymentCollectionStateProvider =
    StateNotifierProvider<PaymentCollectionNotifier, PaymentCollectionState>(
        (ref) {
  return PaymentCollectionNotifier(
    ref.read(paymentTransactionRepositoryProvider),
    null, // PaymentMethodRepository - henüz aktif değil
    null, // PaymentSourceRepository - henüz aktif değil
    null, // PaymentCollectionService - henüz aktif değil
  );
});

/// PaymentTransactionFormModel provider
final paymentTransactionFormProvider = StateNotifierProvider<
    PaymentTransactionFormNotifier, PaymentTransactionFormModel>((ref) {
  return PaymentTransactionFormNotifier();
});

/// Customer PaymentTransactions Stream Provider
final customerPaymentTransactionsProvider =
    FutureProvider.family<List<PaymentTransaction>, String>((ref, customerId) async {
  final repository = ref.read(paymentTransactionRepositoryProvider);
  return await repository.getCustomerTransactions(customerId);
});

/// PaymentCollectionNotifier
class PaymentCollectionNotifier extends StateNotifier<PaymentCollectionState> {
  final PaymentTransactionRepository _transactionRepository;
  final PaymentMethodRepository? _methodRepository;
  final PaymentSourceRepository? _sourceRepository;
  final PaymentCollectionService? _service;

  PaymentCollectionNotifier(
    this._transactionRepository,
    this._methodRepository,
    this._sourceRepository,
    this._service,
  ) : super(const PaymentCollectionState());

  /// İşlemleri yükle
  Future<void> loadTransactions({
    String? companyId,
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    state = state.setLoading(true);
    try {
      final transactions = await _transactionRepository.getAllTransactions(
        companyId: companyId,
        tenantId: tenantId,
        limit: limit,
        offset: offset,
      );
      state = state.updateTransactions(transactions);
    } catch (e) {
      state = state.setError('İşlemler yüklenirken hata oluştu: $e');
    }
  }

  /// Filtrelenmiş işlemleri yükle
  Future<void> loadFilteredTransactions({
    String? companyId,
    String? tenantId,
    String? customerId,
    String? supplierId,
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? paymentMethodId,
    String? paymentSourceId,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    int? limit,
    int? offset,
  }) async {
    state = state.setLoading(true);
    try {
      final transactions = await _transactionRepository.getFilteredTransactions(
        companyId: companyId,
        tenantId: tenantId,
        customerId: customerId,
        supplierId: supplierId,
        revenueId: revenueId,
        expenseId: expenseId,
        accountId: accountId,
        paymentMethodId: paymentMethodId,
        paymentSourceId: paymentSourceId,
        startDate: startDate,
        endDate: endDate,
        currency: currency,
        limit: limit,
        offset: offset,
      );
      state = state.updateTransactions(transactions);
    } catch (e) {
      state =
          state.setError('Filtrelenmiş işlemler yüklenirken hata oluştu: $e');
    }
  }

  /// İşlem oluştur
  Future<PaymentTransaction?> createTransaction(
      PaymentTransaction transaction) async {
    state = state.setSaving(true);
    try {
      // Service henüz aktif değil, doğrudan repository kullan
      final createdTransaction =
          await _transactionRepository.createTransaction(transaction);
      state = state.addTransaction(createdTransaction);
      state = state.setSuccess('İşlem başarıyla oluşturuldu');
      return createdTransaction;
    } catch (e) {
      state = state.setError('İşlem oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      state = state.setSaving(false);
    }
  }

  /// İşlem güncelle
  Future<void> updateTransaction(PaymentTransaction transaction) async {
    state = state.setSaving(true);
    try {
      // Service henüz aktif değil, doğrudan repository kullan
      final updatedTransaction =
          await _transactionRepository.updateTransaction(transaction);
      state = state.updateTransaction(updatedTransaction);
      state = state.setSuccess('İşlem başarıyla güncellendi');
    } catch (e) {
      state = state.setError('İşlem güncellenirken hata oluştu: $e');
    } finally {
      state = state.setSaving(false);
    }
  }

  /// İşlem sil
  Future<void> deleteTransaction(String id) async {
    state = state.setDeleting(true);
    try {
      // Service henüz aktif değil, doğrudan repository kullan
      await _transactionRepository.deleteTransaction(id);
      state = state.removeTransaction(id);
      state = state.setSuccess('İşlem başarıyla silindi');
    } catch (e) {
      state = state.setError('İşlem silinirken hata oluştu: $e');
    } finally {
      state = state.setDeleting(false);
    }
  }

  /// İşlem detayını yükle
  Future<void> loadTransactionDetail(String id) async {
    state = state.setLoading(true);
    try {
      final transaction = await _transactionRepository.getTransactionById(id);
      if (transaction != null) {
        state = state.setSelectedTransaction(transaction);
      } else {
        state = state.setError('İşlem bulunamadı');
      }
    } catch (e) {
      state = state.setError('İşlem detayı yüklenirken hata oluştu: $e');
    }
  }

  /// Ödeme yöntemlerini yükle
  Future<void> loadPaymentMethods({
    String? companyId,
    String? tenantId,
  }) async {
    try {
      if (_methodRepository != null) {
        final methods = await _methodRepository!.getActiveMethods(
          companyId: companyId,
          tenantId: tenantId,
        );
        state = state.copyWith(paymentMethods: methods);
      } else {
        // Henüz aktif değil, boş liste döndür
        state = state.copyWith(paymentMethods: []);
      }
    } catch (e) {
      state = state.setError('Ödeme yöntemleri yüklenirken hata oluştu: $e');
    }
  }

  /// Ödeme kaynaklarını yükle
  Future<void> loadPaymentSources({
    String? companyId,
    String? tenantId,
  }) async {
    try {
      if (_sourceRepository != null) {
        final sources = await _sourceRepository!.getActiveSources(
          companyId: companyId,
          tenantId: tenantId,
        );
        state = state.copyWith(paymentSources: sources);
      } else {
        // Henüz aktif değil, boş liste döndür
        state = state.copyWith(paymentSources: []);
      }
    } catch (e) {
      state = state.setError('Ödeme kaynakları yüklenirken hata oluştu: $e');
    }
  }

  /// Filtre ayarla
  void setFilter(String key, dynamic value) {
    state = state.setFilter(key, value);
  }

  /// Filtre temizle
  void clearFilter(String key) {
    state = state.clearFilter(key);
  }

  /// Tüm filtreleri temizle
  void clearAllFilters() {
    state = state.clearAllFilters();
  }

  /// Arama ayarla
  void setSearch(String? query) {
    state = state.setSearch(query);
  }

  /// Tarih aralığı ayarla
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.setDateRange(startDate, endDate);
  }

  /// Form görünürlüğü ayarla
  void setFormVisible(bool visible) {
    state = state.setFormVisible(visible);
  }

  /// Düzenleme modu ayarla
  void setEditMode(bool editMode) {
    state = state.setEditMode(editMode);
  }

  /// Seçili işlem ayarla
  void setSelectedTransaction(PaymentTransaction? transaction) {
    state = state.setSelectedTransaction(transaction);
  }

  /// Hata temizle
  void clearError() {
    state = state.clearError();
  }

  /// Başarı mesajı temizle
  void clearSuccess() {
    state = state.clearSuccess();
  }
}

/// PaymentTransactionFormNotifier
class PaymentTransactionFormNotifier
    extends StateNotifier<PaymentTransactionFormModel> {
  PaymentTransactionFormNotifier() : super(PaymentTransactionFormModel());

  /// Form alanlarını güncelle
  void updateField(String field, dynamic value) {
    switch (field) {
      case 'type':
        state = state.copyWith(type: value);
        break;
      case 'category':
        state = state.copyWith(category: value);
        break;
      case 'direction':
        state = state.copyWith(direction: value);
        break;
      case 'amount':
        state = state.copyWith(amount: value);
        break;
      case 'currency':
        state = state.copyWith(currency: value);
        break;
      case 'transactionDate':
        state = state.copyWith(transactionDate: value);
        break;
      case 'dueDate':
        state = state.copyWith(dueDate: value);
        break;
      case 'description':
        state = state.copyWith(description: value);
        break;
      case 'referenceNumber':
        state = state.copyWith(referenceNumber: value);
        break;
      case 'notes':
        state = state.copyWith(notes: value);
        break;
      case 'customerId':
        state = state.copyWith(customerId: value);
        break;
      case 'supplierId':
        state = state.copyWith(supplierId: value);
        break;
      case 'revenueId':
        state = state.copyWith(revenueId: value);
        break;
      case 'expenseId':
        state = state.copyWith(expenseId: value);
        break;
      case 'accountId':
        state = state.copyWith(accountId: value);
        break;
      case 'targetAccountId':
        state = state.copyWith(targetAccountId: value);
        break;
      case 'paymentMethodId':
        state = state.copyWith(paymentMethodId: value);
        break;
      case 'paymentSourceId':
        state = state.copyWith(paymentSourceId: value);
        break;
      case 'relatedDocumentId':
        state = state.copyWith(relatedDocumentId: value);
        break;
      case 'relatedDocumentType':
        state = state.copyWith(relatedDocumentType: value);
        break;
      case 'metadata':
        final newMetadata = value == null
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(value as Map);
        state = state.copyWith(metadata: newMetadata);
        break;
    }
  }

  /// Form doğrula
  void validateForm() {
    state.validate();
  }

  /// Form temizle
  void clearForm() {
    state = PaymentTransactionFormModel();
  }

  /// Form sıfırla
  void resetForm() {
    state = PaymentTransactionFormModel();
  }

  /// Hata temizle
  void clearError(String field) {
    state.clearError(field);
  }

  /// Tüm hataları temizle
  void clearAllErrors() {
    state.clearAllErrors();
  }
}
