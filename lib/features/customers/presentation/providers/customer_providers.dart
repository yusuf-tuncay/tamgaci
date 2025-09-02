// ========== lib/features/customers/presentation/providers/customer_providers.dart ==========

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tamgaci/features/customers/data/models/customer_entity.dart';
import '../../../../core/database/tamgaci_database.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/firebase_customer_repository.dart';

// ========== BASE PROVIDERS ==========

/// Database provider
final databaseProvider = FutureProvider<TamgaciDatabase>((ref) async {
  return await DatabaseHelper.getDatabase();
});

/// Customer repository provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  try {
    // Web platformunda Firebase kullan
    if (kIsWeb) {
      return FirebaseCustomerRepository();
    }
    
    // Diğer platformlarda SQLite kullan
    final databaseAsync = ref.watch(databaseProvider);
    return databaseAsync.when(
      data: (database) => CustomerRepositoryImpl(database),
      loading: () => throw Exception('Database loading'),
      error: (error, stack) => throw Exception('Database error: $error'),
    );
  } catch (e) {
    throw Exception('Customer repository initialization failed: $e');
  }
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

/// Web platformu için boş müşteri repository sınıfı
class _EmptyCustomerRepository implements CustomerRepository {
  // Mock verileri saklamak için static liste
  static final List<Customer> _mockCustomers = [
    Customer(
      id: '1',
      name: 'ABC Şirketi A.Ş.',
      email: 'info@abc.com',
      phone: '+90 212 555 0101',
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
    Customer(
      id: '2',
      name: 'XYZ Ticaret Ltd.',
      email: 'satis@xyz.com',
      phone: '+90 216 555 0202',
      address: 'Ankara, Türkiye',
      taxNumber: '9876543210',
      taxOffice: 'Çankaya',
      customerType: CustomerType.company,
      city: 'Ankara',
      country: 'Türkiye',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    Customer(
      id: '3',
      name: 'Mehmet Kaya',
      email: 'mehmet@email.com',
      phone: '+90 232 555 0303',
      address: 'İzmir, Türkiye',
      taxNumber: '',
      taxOffice: '',
      customerType: CustomerType.individual,
      city: 'İzmir',
      country: 'Türkiye',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<String> createCustomer(Customer customer) async {
    final newCustomer = customer.copyWith(
      id: 'customer_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockCustomers.add(newCustomer);
    return newCustomer.id;
  }

  @override
  Future<void> createCustomers(List<Customer> customers) async {
    for (final customer in customers) {
      await createCustomer(customer);
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    _mockCustomers.removeWhere((customer) => customer.id == id);
  }

  @override
  Future<void> deleteInactiveCustomers() async {
    _mockCustomers.removeWhere((customer) => !customer.isActive);
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      return _mockCustomers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Customer?> getCustomerByEmail(String email) async {
    try {
      return _mockCustomers.firstWhere((customer) => customer.email == email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Customer?> getCustomerByPhone(String phone) async {
    try {
      return _mockCustomers.firstWhere((customer) => customer.phone == phone);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Customer?> getCustomerByTaxNumber(String taxNumber) async {
    try {
      return _mockCustomers.firstWhere(
        (customer) => customer.taxNumber == taxNumber,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    return List.from(_mockCustomers);
  }

  @override
  Future<List<Customer>> getActiveCustomers() async {
    return _mockCustomers.where((customer) => customer.isActive).toList();
  }

  Future<List<Customer>> getInactiveCustomers() async {
    return _mockCustomers.where((customer) => !customer.isActive).toList();
  }

  @override
  Future<List<Customer>> getCustomersByType(CustomerType type) async {
    return _mockCustomers
        .where((customer) => customer.customerType == type)
        .toList();
  }

  @override
  Future<List<Customer>> getCustomersByCity(String city) async {
    return _mockCustomers
        .where((customer) => customer.address?.contains(city) == true)
        .toList();
  }

  @override
  Future<int> getActiveCustomerCount() async {
    return _mockCustomers.where((customer) => customer.isActive).length;
  }

  @override
  Future<int> getInactiveCustomerCount() async {
    return _mockCustomers.where((customer) => !customer.isActive).length;
  }

  @override
  Future<int> getTotalCustomerCount() async {
    return _mockCustomers.length;
  }

  @override
  Future<List<Customer>> getRecentCustomers({int limit = 10}) async {
    final sortedCustomers = List<Customer>.from(_mockCustomers);
    sortedCustomers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedCustomers.take(limit).toList();
  }

  @override
  Future<Map<CustomerType, int>> getCustomerTypeStats() async {
    final stats = <CustomerType, int>{};
    for (final customer in _mockCustomers) {
      stats[customer.customerType] = (stats[customer.customerType] ?? 0) + 1;
    }
    return stats;
  }

  Future<Map<String, int>> getCityCustomerStats() async {
    final stats = <String, int>{};
    for (final customer in _mockCustomers) {
      if (customer.address != null) {
        final city = customer.address!.split(',').first.trim();
        stats[city] = (stats[city] ?? 0) + 1;
      }
    }
    return stats;
  }

  @override
  Future<Map<String, int>> getCustomerCityStats() async {
    return getCityCustomerStats();
  }

  @override
  Future<Map<String, int>> getMonthlyCustomerStats() async {
    final stats = <String, int>{};
    for (final customer in _mockCustomers) {
      final month =
          '${customer.createdAt.year}-${customer.createdAt.month.toString().padLeft(2, '0')}';
      stats[month] = (stats[month] ?? 0) + 1;
    }
    return stats;
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _mockCustomers.where((customer) {
      return customer.name.toLowerCase().contains(lowercaseQuery) ||
          (customer.email?.toLowerCase().contains(lowercaseQuery) == true) ||
          (customer.phone?.contains(query) == true);
    }).toList();
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final index = _mockCustomers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      final updatedCustomer = customer.copyWith(updatedAt: DateTime.now());
      _mockCustomers[index] = updatedCustomer;
    }
  }

  @override
  Future<void> updateCustomerStatus(String id, bool isActive) async {
    final index = _mockCustomers.indexWhere((customer) => customer.id == id);
    if (index != -1) {
      final updatedCustomer = _mockCustomers[index].copyWith(
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
      _mockCustomers[index] = updatedCustomer;
    }
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    final customer = _mockCustomers.where((c) => c.id == id).firstOrNull;
    return Stream.value(customer);
  }

  @override
  Stream<List<Customer>> watchAllCustomers() {
    return Stream.value(List.from(_mockCustomers));
  }

  @override
  Stream<List<Customer>> watchActiveCustomers() {
    return Stream.value(
      _mockCustomers.where((customer) => customer.isActive).toList(),
    );
  }

  @override
  Stream<List<Customer>> watchInactiveCustomers() {
    return Stream.value(
      _mockCustomers.where((customer) => !customer.isActive).toList(),
    );
  }

  @override
  Stream<int> watchActiveCustomerCount() {
    return Stream.value(
      _mockCustomers.where((customer) => customer.isActive).length,
    );
  }

  @override
  Stream<int> watchInactiveCustomerCount() {
    return Stream.value(
      _mockCustomers.where((customer) => !customer.isActive).length,
    );
  }
}

// ========== DOSYA YERLEŞTİRME TALİMATLARI ==========

/*
📁 Bu dosyaların yerleştirilmesi gereken konumlar:

1. 📄 customer.dart (domain entity)
   → lib/features/customers/domain/entities/customer.dart

2. 📄 customer_repository.dart (interface)  
   → lib/features/customers/domain/repositories/customer_repository.dart

3. 📄 customer_repository_impl.dart (implementation)
   → lib/features/customers/data/repositories/customer_repository_impl.dart

4. 📄 customer_providers.dart (Riverpod providers)
   → lib/features/customers/presentation/providers/customer_providers.dart

========== SONRAKI ADIM: UI SAYFALARININ HAZIRLANMASI ==========

Repository ve providers hazır! Şimdi gerçek UI sayfalarını hazırlayacağım:
- Customer List Page (fonksiyonel liste)
- Create Customer Page (form sayfası) 
- Customer Detail Page (detay görünümü)
- Edit Customer Page (düzenleme formu)

Code generation'ı çalıştırmayı unutmayın:
flutter packages pub run build_runner build
*/
