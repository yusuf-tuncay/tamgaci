import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tamgaci/core/repositories/base_repository.dart';
import 'package:tamgaci/features/customers/domain/repositories/customer_repository.dart';
import 'package:tamgaci/features/suppliers/domain/repositories/supplier_repository.dart';
import 'package:tamgaci/features/products/domain/repositories/product_repository.dart';

// Generate mocks for repositories
@GenerateMocks([
  CustomerRepository,
  SupplierRepository,
  ProductRepository,
])
void main() {}

/// Mock customer repository for testing
class MockCustomerRepository extends Mock implements CustomerRepository {}

/// Mock supplier repository for testing
class MockSupplierRepository extends Mock implements SupplierRepository {}

/// Mock product repository for testing
class MockProductRepository extends Mock implements ProductRepository {}

/// Mock base repository for testing
class MockBaseRepository<T> extends Mock implements BaseRepository<T> {}

/// Repository test helpers
class RepositoryTestHelpers {
  /// Setup mock customer repository with default responses
  static void setupMockCustomerRepository(
      MockCustomerRepository mockRepository) {
    // Setup default mock responses
    when(mockRepository.getAllCustomers()).thenAnswer((_) async => []);
    when(mockRepository.getCustomerById(any)).thenAnswer((_) async => null);
    when(mockRepository.createCustomer(any)).thenAnswer((_) async => 'test_id');
    when(mockRepository.updateCustomer(any)).thenAnswer((_) async {});
    when(mockRepository.deleteCustomer(any)).thenAnswer((_) async {});
    when(mockRepository.customerExists(any)).thenAnswer((_) async => false);
    when(mockRepository.getCustomerCount()).thenAnswer((_) async => 0);
    when(mockRepository.searchCustomers(any)).thenAnswer((_) async => []);
    when(mockRepository.getCustomersPaginated(
      page: anyNamed('page'),
      limit: anyNamed('limit'),
      sortBy: anyNamed('sortBy'),
      ascending: anyNamed('ascending'),
    )).thenAnswer((_) async => []);
  }

  /// Setup mock supplier repository with default responses
  static void setupMockSupplierRepository(
      MockSupplierRepository mockRepository) {
    // Setup default mock responses
    when(mockRepository.getAllSuppliers()).thenAnswer((_) async => []);
    when(mockRepository.getSupplierById(any)).thenAnswer((_) async => null);
    when(mockRepository.createSupplier(any)).thenAnswer((_) async => 'test_id');
    when(mockRepository.updateSupplier(any)).thenAnswer((_) async {});
    when(mockRepository.deleteSupplier(any)).thenAnswer((_) async {});
    when(mockRepository.supplierExists(any)).thenAnswer((_) async => false);
    when(mockRepository.getSupplierCount()).thenAnswer((_) async => 0);
    when(mockRepository.searchSuppliers(any)).thenAnswer((_) async => []);
    when(mockRepository.getSuppliersPaginated(
      page: anyNamed('page'),
      limit: anyNamed('limit'),
      sortBy: anyNamed('sortBy'),
      ascending: anyNamed('ascending'),
    )).thenAnswer((_) async => []);
  }

  /// Setup mock product repository with default responses
  static void setupMockProductRepository(MockProductRepository mockRepository) {
    // Setup default mock responses
    when(mockRepository.getAllProducts()).thenAnswer((_) async => []);
    when(mockRepository.getProductById(any)).thenAnswer((_) async => null);
    when(mockRepository.createProduct(any)).thenAnswer((_) async => 'test_id');
    when(mockRepository.updateProduct(any)).thenAnswer((_) async {});
    when(mockRepository.deleteProduct(any)).thenAnswer((_) async {});
    when(mockRepository.productExists(any)).thenAnswer((_) async => false);
    when(mockRepository.getProductCount()).thenAnswer((_) async => 0);
    when(mockRepository.searchProducts(any)).thenAnswer((_) async => []);
    when(mockRepository.getProductsPaginated(
      page: anyNamed('page'),
      limit: anyNamed('limit'),
      sortBy: anyNamed('sortBy'),
      ascending: anyNamed('ascending'),
    )).thenAnswer((_) async => []);
  }

  /// Verify repository method was called
  static void verifyRepositoryMethodCalled(
      MockBaseRepository mockRepository, String methodName) {
    switch (methodName) {
      case 'getAll':
        verify(mockRepository.getAll()).called(1);
        break;
      case 'getById':
        verify(mockRepository.getById(any)).called(1);
        break;
      case 'create':
        verify(mockRepository.create(any)).called(1);
        break;
      case 'update':
        verify(mockRepository.update(any)).called(1);
        break;
      case 'delete':
        verify(mockRepository.delete(any)).called(1);
        break;
      case 'exists':
        verify(mockRepository.exists(any)).called(1);
        break;
      case 'getCount':
        verify(mockRepository.getCount()).called(1);
        break;
      case 'search':
        verify(mockRepository.search(any)).called(1);
        break;
      case 'getPaginated':
        verify(mockRepository.getPaginated(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
        )).called(1);
        break;
    }
  }

  /// Verify repository method was not called
  static void verifyRepositoryMethodNotCalled(
      MockBaseRepository mockRepository, String methodName) {
    switch (methodName) {
      case 'getAll':
        verifyNever(mockRepository.getAll());
        break;
      case 'getById':
        verifyNever(mockRepository.getById(any));
        break;
      case 'create':
        verifyNever(mockRepository.create(any));
        break;
      case 'update':
        verifyNever(mockRepository.update(any));
        break;
      case 'delete':
        verifyNever(mockRepository.delete(any));
        break;
      case 'exists':
        verifyNever(mockRepository.exists(any));
        break;
      case 'getCount':
        verifyNever(mockRepository.getCount());
        break;
      case 'search':
        verifyNever(mockRepository.search(any));
        break;
      case 'getPaginated':
        verifyNever(mockRepository.getPaginated(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
        ));
        break;
    }
  }

  /// Reset all mocks
  static void resetAllMocks(List<MockBaseRepository> mocks) {
    for (final mock in mocks) {
      reset(mock);
    }
  }

  /// Clear all mocks
  static void clearAllMocks(List<MockBaseRepository> mocks) {
    for (final mock in mocks) {
      clearInteractions(mock);
    }
  }

  /// Create mock customer data
  static Customer createMockCustomer({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    String? city,
    String? district,
    String? postalCode,
    String? country,
    String? notes,
    bool? isActive,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? 'test_customer_id',
      name: name ?? 'Test Customer',
      email: email ?? 'test@example.com',
      phone: phone ?? '+905551234567',
      address: address ?? 'Test Address',
      taxNumber: taxNumber ?? '1234567890',
      taxOffice: taxOffice ?? 'Test Tax Office',
      city: city ?? 'Istanbul',
      district: district ?? 'Test District',
      postalCode: postalCode ?? '34000',
      country: country ?? 'Turkey',
      notes: notes ?? 'Test notes',
      isActive: isActive ?? true,
      isFavorite: isFavorite ?? false,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Create mock supplier data
  static Supplier createMockSupplier({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? taxOffice,
    String? city,
    String? district,
    String? postalCode,
    String? country,
    String? notes,
    bool? isActive,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? 'test_supplier_id',
      name: name ?? 'Test Supplier',
      email: email ?? 'supplier@example.com',
      phone: phone ?? '+905551234567',
      address: address ?? 'Test Address',
      taxNumber: taxNumber ?? '1234567890',
      taxOffice: taxOffice ?? 'Test Tax Office',
      city: city ?? 'Istanbul',
      district: district ?? 'Test District',
      postalCode: postalCode ?? '34000',
      country: country ?? 'Turkey',
      notes: notes ?? 'Test notes',
      isActive: isActive ?? true,
      isFavorite: isFavorite ?? false,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Create mock product data
  static Product createMockProduct({
    String? id,
    String? name,
    String? description,
    String? barcode,
    String? sku,
    double? purchasePrice,
    double? salePrice,
    String? currency,
    String? category,
    String? brand,
    String? unit,
    double? stockQuantity,
    double? minimumStock,
    String? location,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? 'test_product_id',
      name: name ?? 'Test Product',
      description: description ?? 'Test description',
      barcode: barcode ?? '1234567890123',
      sku: sku ?? 'TEST-SKU-001',
      purchasePrice: purchasePrice ?? 100.0,
      salePrice: salePrice ?? 150.0,
      currency: currency ?? 'TRY',
      category: category ?? 'Test Category',
      brand: brand ?? 'Test Brand',
      unit: unit ?? 'Adet',
      stockQuantity: stockQuantity ?? 10.0,
      minimumStock: minimumStock ?? 5.0,
      location: location ?? 'A-1-1',
      notes: notes ?? 'Test notes',
      isActive: isActive ?? true,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
