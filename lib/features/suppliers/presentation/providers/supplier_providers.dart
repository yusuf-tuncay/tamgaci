// ========== SUPPLIER PROVIDERS ==========
// lib/features/suppliers/presentation/providers/supplier_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../data/repositories/firebase_supplier_repository.dart';

// ========== BASE PROVIDERS ==========

/// Supplier repository provider - Firebase only
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return FirebaseSupplierRepository();
});

// ========== DATA PROVIDERS ==========

/// Tüm tedarikçiler provider'ı
final suppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  return await repository.getAllSuppliers();
});

/// Tedarikçiler stream provider'ı (reactive)
final suppliersStreamProvider = StreamProvider<List<Supplier>>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.watchAllSuppliers();
});

/// Belirli tedarikçi provider'ı
final supplierProvider = FutureProvider.family<Supplier?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(supplierRepositoryProvider);
  return await repository.getSupplierById(id);
});

/// Tedarikçi stream provider'ı (tek tedarikçi)
final supplierStreamProvider = StreamProvider.family<Supplier?, String>((
  ref,
  id,
) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.watchSupplierById(id);
});

// ========== FORM STATE MANAGEMENT ==========

/// Tedarikçi formu state provider'ı
final supplierFormProvider =
    StateNotifierProvider<SupplierFormNotifier, SupplierFormState>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return SupplierFormNotifier(repository);
});

/// Tedarikçi operasyonları provider'ı
final supplierOperationsProvider =
    StateNotifierProvider<SupplierOperations, SupplierOperationsState>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return SupplierOperations(repository);
});

// ========== STATE CLASSES ==========

/// Tedarikçi operasyonları state sınıfı
class SupplierOperationsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<Supplier> suppliers;

  const SupplierOperationsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.suppliers = const [],
  });

  SupplierOperationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<Supplier>? suppliers,
  }) {
    return SupplierOperationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      suppliers: suppliers ?? this.suppliers,
    );
  }
}

/// Tedarikçi form state sınıfı
class SupplierFormState {
  final Supplier? supplier;
  final bool isLoading;
  final bool isEditing;
  final String? errorMessage;
  final String? successMessage;

  const SupplierFormState({
    this.supplier,
    this.isLoading = false,
    this.isEditing = false,
    this.errorMessage,
    this.successMessage,
  });

  SupplierFormState copyWith({
    Supplier? supplier,
    bool? isLoading,
    bool? isEditing,
    String? errorMessage,
    String? successMessage,
  }) {
    return SupplierFormState(
      supplier: supplier ?? this.supplier,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// ========== NOTIFIER CLASSES ==========

/// Tedarikçi operasyonları sınıfı
class SupplierOperations extends StateNotifier<SupplierOperationsState> {
  final SupplierRepository _repository;

  SupplierOperations(this._repository) : super(const SupplierOperationsState());

  /// Tedarikçileri yükle
  Future<void> loadSuppliers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final suppliers = await _repository.getAllSuppliers();
      state = state.copyWith(isLoading: false, suppliers: suppliers);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Yeni tedarikçi oluştur
  Future<void> createSupplier(Supplier supplier) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.createSupplier(supplier);
      // Tedarikçiler listesini yenile
      final suppliers = await _repository.getAllSuppliers();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tedarikçi başarıyla oluşturuldu',
        suppliers: suppliers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tedarikçi oluşturulamadı: $e',
      );
      rethrow;
    }
  }

  /// Tedarikçi güncelle
  Future<void> updateSupplier(Supplier supplier) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateSupplier(supplier);
      // Tedarikçiler listesini yenile
      final suppliers = await _repository.getAllSuppliers();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tedarikçi başarıyla güncellendi',
        suppliers: suppliers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tedarikçi güncellenemedi: $e',
      );
      rethrow;
    }
  }

  /// Tedarikçi sil
  Future<void> deleteSupplier(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteSupplier(id);
      // Tedarikçiler listesini yenile
      final suppliers = await _repository.getAllSuppliers();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tedarikçi başarıyla silindi',
        suppliers: suppliers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tedarikçi silinemedi: $e',
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

/// Tedarikçi form state notifier'ı
class SupplierFormNotifier extends StateNotifier<SupplierFormState> {
  final SupplierRepository _repository;

  SupplierFormNotifier(this._repository) : super(const SupplierFormState());

  /// Formu düzenleme modunda başlat
  Future<void> initializeForEdit(String supplierId) async {
    state = state.copyWith(isLoading: true, isEditing: true);

    try {
      final supplier = await _repository.getSupplierById(supplierId);
      state = state.copyWith(
        supplier: supplier,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tedarikçi bilgileri yüklenemedi: $e',
      );
    }
  }

  /// Formu yeni tedarikçi için başlat
  void initializeForCreate() {
    state = const SupplierFormState(isEditing: false);
  }

  /// Tedarikçi kaydetme
  Future<String?> saveSupplier(Supplier supplier) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      String supplierId;

      if (state.isEditing) {
        await _repository.updateSupplier(supplier);
        supplierId = supplier.id;
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Tedarikçi başarıyla güncellendi',
        );
      } else {
        supplierId = await _repository.createSupplier(supplier);
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Tedarikçi başarıyla oluşturuldu',
        );
      }

      return supplierId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tedarikçi kaydedilemedi: $e',
      );
      return null;
    }
  }

  /// Formu temizle
  void clearForm() {
    state = const SupplierFormState();
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

// ========== WEB PLATFORM EMPTY REPOSITORY ==========

/// Web platformu için boş tedarikçi repository sınıfı
// ignore: unused_element
class _EmptySupplierRepository implements SupplierRepository {
  // Mock verileri saklamak için static liste
  static final List<Supplier> _mockSuppliers = [
    Supplier(
      id: '1',
      name: 'ABC Tedarik Ltd.',
      contactPerson: 'Ahmet Yılmaz',
      email: 'ahmet@abctedarik.com',
      phone: '+90 555 123 45 67',
      address: 'Atatürk Caddesi No:123, İstanbul',
      taxNumber: '1234567890',
      taxOffice: 'Kadıköy',
      bankName: 'Ziraat Bankası',
      bankAccount: 'TR12 3456 7890 1234 5678 90',
      creditLimit: 50000.0,
      currentBalance: 15000.0,
      currency: 'TRY',
      status: SupplierStatus.active,
      supplierType: SupplierType.company,
      companyId: 'company_1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Supplier(
      id: '2',
      name: 'XYZ Malzeme A.Ş.',
      contactPerson: 'Fatma Demir',
      email: 'fatma@xyzmalzeme.com',
      phone: '+90 555 987 65 43',
      address: 'İnönü Caddesi No:456, Ankara',
      taxNumber: '9876543210',
      taxOffice: 'Çankaya',
      bankName: 'İş Bankası',
      bankAccount: 'TR98 7654 3210 9876 5432 10',
      creditLimit: 75000.0,
      currentBalance: 25000.0,
      currency: 'TRY',
      status: SupplierStatus.active,
      supplierType: SupplierType.company,
      companyId: 'company_2',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<String> createSupplier(Supplier supplier) async {
    final newSupplier = supplier.copyWith(
      id: 'supplier_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockSuppliers.add(newSupplier);
    return newSupplier.id;
  }

  @override
  Future<void> deleteSupplier(String id) async {
    _mockSuppliers.removeWhere((supplier) => supplier.id == id);
  }

  @override
  Future<Supplier?> getSupplierById(String id) async {
    try {
      return _mockSuppliers.firstWhere((supplier) => supplier.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Supplier>> getAllSuppliers() async {
    return List.from(_mockSuppliers);
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    final index = _mockSuppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      final updatedSupplier = supplier.copyWith(updatedAt: DateTime.now());
      _mockSuppliers[index] = updatedSupplier;
    }
  }

  @override
  Stream<Supplier?> watchSupplierById(String id) {
    final supplier = _mockSuppliers.where((s) => s.id == id).firstOrNull;
    return Stream.value(supplier);
  }

  @override
  Stream<List<Supplier>> watchAllSuppliers() {
    return Stream.value(List.from(_mockSuppliers));
  }
}
