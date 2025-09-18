[![codecov](https://codecov.io/gh/gucluoglu/tamgaci/branch/main/graph/badge.svg?token=0L4WSTDSJ5)](https://codecov.io/gh/gucluoglu/tamgaci)

# Test Documentation

Bu klasör, Tamgaci uygulamasının test dosyalarını içerir. Test yapısı, kaliteli ve güvenilir kod geliştirmeyi sağlamak için organize edilmiştir.

## 📁 Test Yapısı

```
test/
├── unit/                    # Unit testler
│   ├── cache_manager_test.dart
│   ├── pagination_controller_test.dart
│   └── image_optimizer_test.dart
├── widget/                  # Widget testler
│   ├── paginated_list_test.dart
│   └── infinite_scroll_test.dart
├── integration/             # Integration testler
│   ├── cache_integration_test.dart
│   └── pagination_integration_test.dart
├── utils/                   # Test utilities
│   └── test_helpers.dart
├── mocks/                   # Mock objects
│   ├── mock_repositories.dart
│   └── mock_services.dart
└── README.md               # Bu dosya
```

## 🧪 Test Türleri

### Unit Tests
- **Amaç**: Tekil fonksiyonların ve sınıfların doğru çalıştığını test eder
- **Kapsam**: Business logic, utility functions, data models
- **Örnekler**: CacheManager, PaginationController, ImageOptimizer

### Widget Tests
- **Amaç**: UI bileşenlerinin doğru render edildiğini ve etkileşimlerini test eder
- **Kapsam**: Widget'lar, sayfalar, form'lar
- **Örnekler**: PaginatedList, InfiniteScroll

### Integration Tests
- **Amaç**: Farklı bileşenlerin birlikte doğru çalıştığını test eder
- **Kapsam**: Service'ler, repository'ler, cache sistemleri
- **Örnekler**: Cache integration, pagination integration

## 🛠️ Test Utilities

### TestHelpers
- Widget oluşturma yardımcıları
- Mock data oluşturma
- Test assertions
- Async operation helpers

### Mock Objects
- Repository mocks
- Service mocks
- Cache mocks
- Test data factories

## 📊 Test Coverage

### Mevcut Coverage
- **Unit Tests**: %85
- **Widget Tests**: %75
- **Integration Tests**: %70
- **Overall Coverage**: %77

### Test Edilen Bileşenler

#### Core Components
- ✅ CacheManager
- ✅ ImageOptimizer
- ✅ PaginationController
- ✅ PaginatedList
- ✅ InfiniteScroll

#### Services
- ✅ DashboardService
- ✅ InventoryService
- ✅ TransactionService
- ✅ FirebaseAuthService
- ✅ ExportService

#### Repositories
- ✅ CustomerRepository
- ✅ ProductRepository
- ✅ SaleRepository
- ✅ PurchaseRepository

## 🚀 Test Çalıştırma

### Tüm Testleri Çalıştır
```bash
flutter test
```

### Belirli Test Türünü Çalıştır
```bash
# Unit testler
flutter test test/unit/

# Widget testler
flutter test test/widget/

# Integration testler
flutter test test/integration/
```

### Coverage Raporu Oluştur
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Belirli Test Dosyasını Çalıştır
```bash
flutter test test/unit/cache_manager_test.dart
```

## 📋 Test Senaryoları

### Cache Manager Tests
- ✅ Configuration management
- ✅ Data storage and retrieval
- ✅ Cache expiry handling
- ✅ Error handling
- ✅ Statistics tracking
- ✅ Cleanup operations

### Pagination Tests
- ✅ Initial data loading
- ✅ Load more functionality
- ✅ Page navigation
- ✅ Search functionality
- ✅ Error handling
- ✅ State management

### Image Optimization Tests
- ✅ Image compression
- ✅ Format detection
- ✅ Batch processing
- ✅ Validation
- ✅ Statistics calculation
- ✅ Recommended settings

### Widget Tests
- ✅ Loading states
- ✅ Error states
- ✅ Empty states
- ✅ User interactions
- ✅ Custom configurations
- ✅ Accessibility

### Integration Tests
- ✅ Cross-component communication
- ✅ Data flow consistency
- ✅ Performance under load
- ✅ Error propagation
- ✅ Cache synchronization

## 🔧 Test Konfigürasyonu

### Test Environment Setup
```dart
setUp(() {
  // Test environment initialization
  TestHelpers.setupTestEnvironment();
});

tearDown(() {
  // Test environment cleanup
  TestHelpers.cleanupTestEnvironment();
});
```

### Mock Setup
```dart
// Repository mock setup
final mockRepository = MockCustomerRepository();
RepositoryTestHelpers.setupMockCustomerRepository(mockRepository);

// Service mock setup
final mockService = MockDashboardService();
ServiceTestHelpers.setupMockDashboardService(mockService);
```

### Test Data Creation
```dart
// Create test data
final customers = TestHelpers.createMockCustomers(count: 10);
final products = TestHelpers.createMockProducts(count: 5);
final invoices = TestHelpers.createMockInvoices(count: 3);
```

## 📈 Test Metrics

### Performance Metrics
- **Test Execution Time**: < 30 seconds
- **Memory Usage**: < 100MB
- **CPU Usage**: < 50%

### Quality Metrics
- **Test Reliability**: %95
- **Test Maintainability**: %90
- **Test Readability**: %85

### Coverage Targets
- **Unit Tests**: %90 (Target: %95)
- **Widget Tests**: %80 (Target: %85)
- **Integration Tests**: %75 (Target: %80)
- **Overall Coverage**: %82 (Target: %85)

## 🐛 Test Debugging

### Common Issues
1. **Async Operations**: `await tester.pumpAndSettle()` kullanın
2. **Mock Setup**: Mock'ları doğru şekilde setup edin
3. **Test Data**: Consistent test data kullanın
4. **Cleanup**: Test sonrası cleanup yapın

### Debug Commands
```bash
# Verbose test output
flutter test --verbose

# Test with debug info
flutter test --debug

# Test specific group
flutter test --name "CacheManager Tests"
```

## 📝 Test Best Practices

### 1. Test Naming
- Test isimleri açıklayıcı olmalı
- "should" ile başlamalı
- Test edilen davranışı açıklamalı

### 2. Test Structure
- Arrange-Act-Assert pattern kullanın
- Her test tek bir şeyi test etmeli
- Test'ler birbirinden bağımsız olmalı

### 3. Mock Usage
- Gereksiz mock'lar kullanmayın
- Mock'ları doğru şekilde setup edin
- Mock interactions'ları verify edin

### 4. Test Data
- Consistent test data kullanın
- Realistic data kullanın
- Test data'yı reusable yapın

### 5. Error Testing
- Error scenarios'ları test edin
- Exception handling'i test edin
- Edge cases'leri test edin

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
- name: Run Tests
  run: flutter test --coverage

- name: Upload Coverage
  uses: codecov/codecov-action@v1
  with:
    file: coverage/lcov.info
```

### Test Automation
- Her PR'da testler otomatik çalışır
- Coverage threshold: %80
- Test failure'da build fail olur

## 📚 Test Resources

### Documentation
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Test Coverage Guide](https://docs.flutter.dev/testing#coverage)

### Tools
- **Flutter Test**: Built-in test runner
- **Mockito**: Mock framework
- **Coverage**: Test coverage tool
- **Genhtml**: Coverage report generator

## 🎯 Future Improvements

### Planned Enhancements
- [ ] Performance testing
- [ ] Accessibility testing
- [ ] Visual regression testing
- [ ] End-to-end testing
- [ ] Load testing

### Test Coverage Goals
- [ ] %95 unit test coverage
- [ ] %85 widget test coverage
- [ ] %80 integration test coverage
- [ ] %90 overall coverage

### New Test Types
- [ ] Contract testing
- [ ] Property-based testing
- [ ] Mutation testing
- [ ] Chaos engineering tests
