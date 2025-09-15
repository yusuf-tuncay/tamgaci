// ========== lib/features/customers/presentation/providers/customer_providers.dart ==========

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../data/repositories/firebase_customer_repository.dart';

// ========== BASE PROVIDERS ==========

/// Customer repository provider - Firebase only
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return FirebaseCustomerRepository();
});

// ========== DATA PROVIDERS ==========

/// Tüm müşteriler provider'ı
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return await repository.getActiveCustomers();
});

/// Müşteri stream provider'ı (reactive)
final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchActiveCustomers();
});

/// Belirli müşteri provider'ı
final customerProvider = FutureProvider.family<Customer?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(customerRepositoryProvider);
  return await repository.getCustomerById(id);
});

/// Müşteri stream provider'ı (tek müşteri)
final customerStreamProvider =
    StreamProvider.family<Customer?, String>((ref, id) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchCustomerById(id);
});

// ========== STATE PROVIDERS ==========

/// Müşteri arama sorgusu provider'ı
final customerSearchQueryProvider = StateProvider<String>((ref) => '');

/// Müşteri sayısı provider'ı
final customerCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return await repository.getTotalCustomerCount();
});

/// Son müşteriler provider'ı
final recentCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return await repository.getRecentCustomers(limit: 10);
});

/// Filtrelenmiş müşteriler provider'ı
final filteredCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  final searchQuery = ref.watch(customerSearchQueryProvider);

  if (searchQuery.isEmpty) {
    return await repository.getAllCustomers();
  } else {
    return await repository.searchCustomers(searchQuery);
  }
});

/// Arama sonuçları provider'ı
final searchResultsProvider = FutureProvider<List<Customer>>((ref) async {
  final query = ref.watch(customerSearchQueryProvider);
  if (query.isEmpty) {
    return <Customer>[];
  }

  final repository = ref.watch(customerRepositoryProvider);
  return await repository.searchCustomers(query);
});

/// Müşteri tipi istatistikleri provider'ı
final customerTypeStatsProvider = FutureProvider<Map<CustomerType, int>>((
  ref,
) async {
  final repository = ref.watch(customerRepositoryProvider);
  return await repository.getCustomerTypeStats();
});

// ========== SEARCH VE FİLTRELEME ==========

/// Arama sorgusu state provider'ı
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Seçili müşteri tipi filtresi provider'ı
final selectedCustomerTypeProvider = StateProvider<CustomerType?>(
  (ref) => null,
);

// ========== FORM STATE MANAGEMENT ==========

/// Müşteri formu state provider'ı
final customerFormProvider =
    StateNotifierProvider<CustomerFormNotifier, CustomerFormState>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerFormNotifier(repository);
});

/// Müşteri operasyonları provider'ı
final customerOperationsProvider =
    StateNotifierProvider<CustomerOperations, CustomerOperationsState>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerOperations(repository);
});

/// Müşteri operasyonları state sınıfı
class CustomerOperationsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<Customer> customers;

  const CustomerOperationsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.customers = const [],
  });

  CustomerOperationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<Customer>? customers,
  }) {
    return CustomerOperationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      customers: customers ?? this.customers,
    );
  }
}

/// Müşteri form state sınıfı
class CustomerFormState {
  final Customer? customer;
  final bool isLoading;
  final bool isEditing;
  final String? errorMessage;
  final String? successMessage;

  const CustomerFormState({
    this.customer,
    this.isLoading = false,
    this.isEditing = false,
    this.errorMessage,
    this.successMessage,
  });

  CustomerFormState copyWith({
    Customer? customer,
    bool? isLoading,
    bool? isEditing,
    String? errorMessage,
    String? successMessage,
  }) {
    return CustomerFormState(
      customer: customer ?? this.customer,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Müşteri operasyonları sınıfı
class CustomerOperations extends StateNotifier<CustomerOperationsState> {
  final CustomerRepository _repository;

  CustomerOperations(this._repository) : super(const CustomerOperationsState());

  /// Müşterileri yükle
  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final customers = await _repository.getActiveCustomers();
      state = state.copyWith(isLoading: false, customers: customers);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Yeni müşteri oluştur
  Future<void> createCustomer(Customer customer) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.createCustomer(customer);
      // Müşteriler listesini yenile
      final customers = await _repository.getActiveCustomers();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Müşteri başarıyla oluşturuldu',
        customers: customers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Müşteri oluşturulamadı: $e',
      );
      rethrow;
    }
  }

  /// Müşteri güncelle
  Future<void> updateCustomer(Customer customer) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateCustomer(customer);
      // Müşteriler listesini yenile
      final customers = await _repository.getActiveCustomers();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Müşteri başarıyla güncellendi',
        customers: customers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Müşteri güncellenemedi: $e',
      );
      rethrow;
    }
  }

  /// Müşteri sil
  Future<void> deleteCustomer(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteCustomer(id);
      // Müşteriler listesini yenile
      final customers = await _repository.getActiveCustomers();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Müşteri başarıyla silindi',
        customers: customers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Müşteri silinemedi: $e',
      );
      rethrow;
    }
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

/// Müşteri form state notifier'ı
class CustomerFormNotifier extends StateNotifier<CustomerFormState> {
  final CustomerRepository _repository;

  CustomerFormNotifier(this._repository) : super(const CustomerFormState());

  /// Formu düzenleme modunda başlat
  Future<void> initializeForEdit(String customerId) async {
    state = state.copyWith(isLoading: true, isEditing: true);

    try {
      final customer = await _repository.getCustomerById(customerId);
      state = state.copyWith(
        customer: customer,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Müşteri bilgileri yüklenemedi: $e',
      );
    }
  }

  /// Formu yeni müşteri için başlat
  void initializeForCreate() {
    state = const CustomerFormState(isEditing: false);
  }

  /// Müşteri kaydetme
  Future<String?> saveCustomer(Customer customer) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      String customerId;

      if (state.isEditing) {
        await _repository.updateCustomer(customer);
        customerId = customer.id;
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Müşteri başarıyla güncellendi',
        );
      } else {
        customerId = await _repository.createCustomer(customer);
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Müşteri başarıyla oluşturuldu',
        );
      }

      return customerId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Müşteri kaydedilemedi: $e',
      );
      return null;
    }
  }

  /// Formu temizle
  void clearForm() {
    state = const CustomerFormState();
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
