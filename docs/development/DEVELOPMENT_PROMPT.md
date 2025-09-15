# 🚀 **TAMGACI UYGULAMASI - GELİŞTİRME PROMPT**

## 📋 **UYGULAMA GENEL BİLGİLERİ**

**Tamgaci** ön muhasebe ve iş yönetim uygulaması, **7 faze** boyunca geliştirilmiş **production-ready** durumda olan profesyonel bir Flutter uygulamasıdır. Uygulama **Firebase** tabanlı gerçek veri yönetimi ile çalışmakta ve **para kazanmaya hazır** durumdadır.

### **Uygulama Özellikleri**
- **Ön Muhasebe**: Müşteri, tedarikçi, ürün, satış/alış yönetimi
- **Finansal İşlemler**: Gelir-gider takibi, nakit yönetimi
- **Raporlama**: Excel/PDF export, dashboard analitikleri
- **Multi-platform**: Web, Android, iOS, Windows, macOS, Linux
- **Real-time**: Firebase Firestore ile anlık veri senkronizasyonu
- **Professional**: Enterprise-grade güvenlik ve performans

---

## 🏗️ **MİMARİ YAPISI VE PRENSİPLER**

### **1. Clean Architecture**

```
lib/
├── core/                    # Temel altyapı
│   ├── cache/              # Caching system
│   ├── database/           # SQLite (legacy)
│   ├── errors/             # Error handling
│   ├── firebase/           # Firebase configuration
│   ├── images/             # Image optimization
│   ├── network/            # Network utilities
│   ├── pagination/         # Pagination system
│   ├── providers/          # Base providers
│   ├── repositories/       # Repository interfaces
│   ├── routes/             # Navigation
│   ├── security/           # Security utilities
│   ├── services/           # Business services
│   ├── theme/              # UI themes
│   ├── utils/              # Utilities
│   └── validation/         # Input validation
├── features/               # Özellik modülleri
│   ├── auth/              # Authentication
│   ├── cash_management/   # Cash transactions
│   ├── customers/         # Customer management
│   ├── dashboard/         # Dashboard
│   ├── directory/         # Contacts
│   ├── expenses/          # Expense management
│   ├── income/            # Income management
│   ├── inventory/         # Inventory management
│   ├── invoices/          # Invoice management
│   ├── notifications/     # Notifications
│   ├── products/          # Product management
│   ├── purchases/         # Purchase management
│   ├── reports/           # Reporting
│   ├── sales/             # Sales management
│   ├── settings/          # Settings
│   ├── splash/            # Splash screen
│   ├── suppliers/         # Supplier management
│   └── user_profile/      # User profile
├── shared/                # Paylaşılan bileşenler
│   ├── models/            # Shared models
│   ├── pages/             # Shared pages
│   └── widgets/           # Shared widgets
└── main.dart              # Uygulama giriş noktası
```

**ÖNEMLİ**: Her yeni özellik için **feature-based** klasör yapısı kullanılmalıdır:

```
lib/features/[feature_name]/
├── data/
│   ├── models/            # Firebase entity'leri
│   ├── repositories/      # Repository implementasyonları
│   └── services/          # Data services
├── domain/
│   ├── entities/          # Domain entity'leri
│   └── repositories/      # Repository interfaces
└── presentation/
    ├── pages/             # UI sayfaları
    ├── widgets/           # UI bileşenleri
    └── providers/         # State management
```

### **2. State Management - Riverpod**

- **Provider pattern** kullanılmalı
- **AsyncValue** ile loading/error/success states
- **StateNotifier** ile complex state management
- **Consumer** ile UI'da state dinleme

**ÖRNEK**:
```dart
// Provider tanımı
final customerProvider = StateNotifierProvider<CustomerNotifier, AsyncValue<List<Customer>>>((ref) {
  return CustomerNotifier(ref.read(customerRepositoryProvider));
});

// UI'da kullanım
Consumer(
  builder: (context, ref, child) {
    final customersAsync = ref.watch(customerProvider);
    return customersAsync.when(
      data: (customers) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  },
)
```

### **3. Firebase Integration**

- **Firestore** - Real-time database
- **Firebase Auth** - Authentication
- **Firebase Storage** - File storage
- **Firebase Messaging** - Push notifications

**ÖNEMLİ**: Mock data kullanılmamalı, her zaman **gerçek Firebase verisi** kullanılmalıdır.

---

## 🔧 **GELİŞTİRME KURALLARI**

### **1. Kod Yazım Kuralları**

- **Dart/Flutter** best practices takip edilmeli
- **Clean Code** prensipleri uygulanmalı
- **SOLID** prensipleri gözetilmeli
- **DRY** (Don't Repeat Yourself) prensibi
- **KISS** (Keep It Simple, Stupid) prensibi

### **2. Naming Conventions**

```dart
// Classes: PascalCase
class CustomerRepository {}

// Variables/Functions: camelCase
String customerName = '';
void updateCustomer() {}

// Constants: UPPER_SNAKE_CASE
const String API_BASE_URL = '';

// Files: snake_case
customer_repository.dart
customer_list_page.dart
```

### **3. Error Handling**

```dart
// Global error handling kullanılmalı
try {
  await someOperation();
} catch (e) {
  AppLogger.error('Operation failed', e);
  // Global error handler'a yönlendir
  ref.read(errorProvider.notifier).setError(e, stackTrace);
}
```

### **4. Logging**

```dart
// Her önemli işlem loglanmalı
AppLogger.info('Customer created: ${customer.id}');
AppLogger.warning('Low stock alert: ${product.name}');
AppLogger.error('Database connection failed', error);
```

---

## 📱 **UI/UX GELİŞTİRME KURALLARI**

### **1. Material Design 3**

- **Google Fonts** (Poppins) kullanılmalı
- **AppColors** constants kullanılmalı
- **Responsive design** uygulanmalı
- **Dark/Light theme** desteği

### **2. Widget Yapısı**

```dart
// Custom widget oluştururken
class CustomWidget extends ConsumerWidget {
  const CustomWidget({super.key, required this.parameter});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // Widget implementation
    );
  }
}
```

### **3. Form Validation**

```dart
// Form validation kullanılmalı
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan zorunludur';
    }
    return null;
  },
)
```

### **4. Responsive Design**

```dart
// Responsive design için
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 768) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  },
)
```

---

## 🗄️ **VERİ YÖNETİMİ KURALLARI**

### **1. Firebase Entity'leri**

```dart
// Firebase entity oluştururken
class FirebaseCustomerEntity {
  // toFirestore() ve fromFirestore() metodları olmalı
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'isActive': isActive,
      // ...
    };
  }
  
  factory FirebaseCustomerEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseCustomerEntity(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      isActive: data['isActive'] ?? true,
      // ...
    );
  }
}
```

### **2. Repository Pattern**

```dart
// Repository interface
abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Future<Customer> getCustomerById(String id);
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<void> updateCustomerBalance(String customerId, double amount);
  Future<double> calculateCustomerBalance(String customerId);
}

// Firebase implementation
class FirebaseCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _firestore;
  
  FirebaseCustomerRepository(this._firestore);
  
  @override
  Future<List<Customer>> getAllCustomers() async {
    try {
      final querySnapshot = await _firestore
          .collection('customers')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return querySnapshot.docs
          .map((doc) => FirebaseCustomerEntity.fromFirestore(doc).toDomain())
          .toList();
    } catch (e) {
      AppLogger.error('Error getting customers', e);
      rethrow;
    }
  }
}
```

### **3. Service Layer**

```dart
// Business logic için service kullanılmalı
class CustomerService {
  final CustomerRepository _repository;
  final TransactionService _transactionService;
  
  CustomerService(this._repository, this._transactionService);
  
  Future<void> createCustomer(Customer customer) async {
    try {
      // Business logic
      await _validateCustomer(customer);
      await _repository.addCustomer(customer);
      await _updateCustomerBalance(customer);
      
      AppLogger.info('Customer created: ${customer.id}');
    } catch (e) {
      AppLogger.error('Error creating customer', e);
      rethrow;
    }
  }
  
  Future<void> _validateCustomer(Customer customer) async {
    if (customer.name.isEmpty) {
      throw Exception('Customer name is required');
    }
    if (customer.email.isNotEmpty && !_isValidEmail(customer.email)) {
      throw Exception('Invalid email format');
    }
  }
}
```

---

## 🧪 **TEST YAZMA KURALLARI**

### **1. Test Yapısı**

```
test/
├── unit/              # Unit tests
│   ├── services/      # Service tests
│   ├── repositories/  # Repository tests
│   └── utils/         # Utility tests
├── widget/            # Widget tests
│   ├── pages/         # Page tests
│   └── widgets/       # Widget tests
├── integration/       # Integration tests
│   ├── api/           # API integration tests
│   └── database/      # Database integration tests
├── e2e/               # End-to-end tests
│   ├── user_flows/    # User flow tests
│   └── scenarios/     # Scenario tests
├── mocks/             # Mock objects
│   ├── repositories/  # Repository mocks
│   └── services/      # Service mocks
└── utils/             # Test utilities
    ├── helpers/       # Test helpers
    └── fixtures/      # Test data
```

### **2. Test Yazımı**

```dart
// Unit test örneği
void main() {
  group('CustomerService', () {
    late CustomerService customerService;
    late MockCustomerRepository mockRepository;
    late MockTransactionService mockTransactionService;
    
    setUp(() {
      mockRepository = MockCustomerRepository();
      mockTransactionService = MockTransactionService();
      customerService = CustomerService(mockRepository, mockTransactionService);
    });
    
    tearDown(() {
      reset(mockRepository);
      reset(mockTransactionService);
    });
    
    test('should create customer successfully', () async {
      // Arrange
      final customer = Customer(
        id: 'test-id',
        name: 'Test Customer',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'test-user',
      );
      
      when(mockRepository.addCustomer(any))
          .thenAnswer((_) async {});
      
      // Act
      await customerService.createCustomer(customer);
      
      // Assert
      verify(mockRepository.addCustomer(customer)).called(1);
      verify(mockTransactionService.updateCustomerBalance(any, any)).called(1);
    });
    
    test('should throw exception when customer name is empty', () async {
      // Arrange
      final customer = Customer(
        id: 'test-id',
        name: '',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'test-user',
      );
      
      // Act & Assert
      expect(
        () => customerService.createCustomer(customer),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### **3. Widget Test**

```dart
// Widget test örneği
void main() {
  group('CustomerListPage', () {
    testWidgets('should display customer list', (WidgetTester tester) async {
      // Arrange
      final mockCustomers = [
        Customer(
          id: '1',
          name: 'Test Customer 1',
          email: 'test1@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'test-user',
        ),
        Customer(
          id: '2',
          name: 'Test Customer 2',
          email: 'test2@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'test-user',
        ),
      ];
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerProvider.overrideWith((ref) => 
                CustomerNotifier(MockCustomerRepository())),
          ],
          child: MaterialApp(
            home: CustomerListPage(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Test Customer 1'), findsOneWidget);
      expect(find.text('Test Customer 2'), findsOneWidget);
    });
  });
}
```

---

## 📚 **DOKÜMANTASYON KURALLARI**

### **1. Kod Dokümantasyonu**

```dart
/// Müşteri yönetimi için repository interface'i
/// 
/// Bu interface, müşteri verilerinin CRUD işlemlerini tanımlar.
/// Firebase, SQLite gibi farklı veri kaynakları için implementasyon sağlar.
/// 
/// Example:
/// ```dart
/// final repository = FirebaseCustomerRepository();
/// final customers = await repository.getAllCustomers();
/// ```
abstract class CustomerRepository {
  /// Tüm aktif müşterileri getirir
  /// 
  /// Returns: Müşteri listesi (boş liste dönebilir)
  /// Throws: [Exception] Veri getirilemezse
  /// 
  /// Example:
  /// ```dart
  /// final customers = await repository.getAllCustomers();
  /// for (final customer in customers) {
  ///   print(customer.name);
  /// }
  /// ```
  Future<List<Customer>> getAllCustomers();
  
  /// ID'ye göre müşteri getirir
  /// 
  /// [customerId] Müşteri ID'si
  /// Returns: Müşteri entity'si
  /// Throws: [Exception] Müşteri bulunamazsa
  Future<Customer> getCustomerById(String customerId);
}
```

### **2. README Dosyaları**

Her önemli klasör için README.md dosyası oluşturulmalı:

```markdown
# Customer Management

Bu modül müşteri yönetimi işlevlerini içerir.

## Özellikler
- Müşteri CRUD işlemleri
- Bakiye takibi
- İşlem geçmişi
- Dual role (müşteri-tedarikçi)

## Kullanım

### Müşteri Oluşturma
```dart
final customerService = CustomerService();
final customer = Customer(
  name: 'ABC Şirketi',
  email: 'info@abc.com',
  // ...
);
await customerService.createCustomer(customer);
```

### Müşteri Listesi
```dart
final customers = await customerService.getAllCustomers();
```

## API Reference

### CustomerService
- `createCustomer(Customer customer)`: Yeni müşteri oluşturur
- `updateCustomer(Customer customer)`: Müşteri günceller
- `deleteCustomer(String id)`: Müşteri siler
- `getAllCustomers()`: Tüm müşterileri getirir

## Test
```bash
flutter test test/unit/customer_service_test.dart
```
```

### **3. API Documentation**

```markdown
# API Documentation

## Customer API

### GET /customers
Tüm müşterileri getirir.

**Response:**
```json
{
  "customers": [
    {
      "id": "customer-id",
      "name": "ABC Şirketi",
      "email": "info@abc.com",
      "phone": "+90 212 555 0101",
      "address": "İstanbul, Türkiye",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### POST /customers
Yeni müşteri oluşturur.

**Request:**
```json
{
  "name": "ABC Şirketi",
  "email": "info@abc.com",
  "phone": "+90 212 555 0101",
  "address": "İstanbul, Türkiye"
}
```

**Response:**
```json
{
  "id": "new-customer-id",
  "message": "Customer created successfully"
}
```
```

---

## 🚀 **DEPLOYMENT KURALLARI**

### **1. Production Hazırlık**

- **Lint hataları** olmamalı
- **Test coverage** %80+ olmalı
- **Security vulnerabilities** olmamalı
- **Performance** optimize edilmeli

### **2. Version Control**

```bash
# Commit mesajları
feat: add customer balance calculation
fix: resolve invoice generation bug
docs: update API documentation
test: add unit tests for customer service
refactor: improve error handling
perf: optimize database queries
style: format code according to lint rules
chore: update dependencies
```

### **3. Firebase Configuration**

```dart
// Firebase options doğru yapılandırılmalı
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Firestore settings
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### **4. Build Configuration**

```yaml
# pubspec.yaml
version: 1.0.0+1

# Build flavors
flutter build apk --release
flutter build web --release
flutter build windows --release
```

---

## ⚠️ **DİKKAT EDİLMESİ GEREKEN NOKTALAR**

### **1. Mock Data Kullanımı**

- **ASLA** mock data kullanılmamalı
- Her zaman **gerçek Firebase verisi** kullanılmalı
- Test ortamında bile gerçek veri kullanılmalı
- Mock data sadece test dosyalarında kullanılmalı

### **2. Performance**

- **Lazy loading** uygulanmalı
- **Pagination** kullanılmalı
- **Image optimization** yapılmalı
- **Caching** stratejisi uygulanmalı
- **Database indexing** optimize edilmeli

```dart
// Lazy loading örneği
ListView.builder(
  itemCount: customers.length,
  itemBuilder: (context, index) {
    if (index == customers.length - 1) {
      // Load more data
      ref.read(customerProvider.notifier).loadMore();
    }
    return CustomerTile(customer: customers[index]);
  },
)
```

### **3. Security**

- **Input validation** yapılmalı
- **Data sanitization** uygulanmalı
- **Authentication** kontrol edilmeli
- **Authorization** kontrol edilmeli
- **HTTPS** kullanılmalı

```dart
// Input validation örneği
class InputValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi zorunludur';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir email adresi giriniz';
    }
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası zorunludur';
    }
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }
}
```

### **4. Error Handling**

- **Global error handler** kullanılmalı
- **User-friendly** error mesajları
- **Logging** yapılmalı
- **Recovery** mekanizmaları

```dart
// Global error handling
class GlobalErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    AppLogger.error('Global error occurred', error, stackTrace);
    
    // Firebase Crashlytics'e gönder
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    
    // User-friendly mesaj göster
    _showErrorDialog(error);
  }
  
  static void _showErrorDialog(dynamic error) {
    // Error dialog implementation
  }
}
```

---

## 🎯 **GELİŞTİRME SÜRECİ**

### **1. Yeni Özellik Ekleme**

1. **Feature branch** oluştur
   ```bash
   git checkout -b feature/customer-balance-calculation
   ```

2. **Domain entities** tanımla
   ```dart
   // lib/features/customers/domain/entities/customer_balance.dart
   class CustomerBalance {
     final String customerId;
     final double currentBalance;
     final double creditLimit;
     final DateTime lastUpdated;
   }
   ```

3. **Repository interface** oluştur
   ```dart
   // lib/features/customers/domain/repositories/customer_balance_repository.dart
   abstract class CustomerBalanceRepository {
     Future<CustomerBalance> getCustomerBalance(String customerId);
     Future<void> updateCustomerBalance(String customerId, double amount);
   }
   ```

4. **Firebase implementation** yaz
   ```dart
   // lib/features/customers/data/repositories/firebase_customer_balance_repository.dart
   class FirebaseCustomerBalanceRepository implements CustomerBalanceRepository {
     // Implementation
   }
   ```

5. **Service layer** ekle
   ```dart
   // lib/features/customers/data/services/customer_balance_service.dart
   class CustomerBalanceService {
     // Business logic
   }
   ```

6. **UI components** oluştur
   ```dart
   // lib/features/customers/presentation/widgets/customer_balance_widget.dart
   class CustomerBalanceWidget extends ConsumerWidget {
     // UI implementation
   }
   ```

7. **Tests** yaz
   ```dart
   // test/unit/customer_balance_service_test.dart
   void main() {
     group('CustomerBalanceService', () {
       // Tests
     });
   }
   ```

8. **Documentation** güncelle
   ```markdown
   # Customer Balance Feature
   
   Bu özellik müşteri bakiyelerini takip eder.
   ```

### **2. Bug Fix**

1. **Issue** tanımla
   ```markdown
   ## Bug Report
   
   **Description**: Customer balance calculation is incorrect
   **Steps to reproduce**: 
   1. Create a customer
   2. Add a transaction
   3. Check balance
   
   **Expected**: Balance should be updated correctly
   **Actual**: Balance shows 0
   ```

2. **Root cause** analiz et
   ```dart
   // Debug logging ekle
   AppLogger.debug('Customer balance calculation', {
     'customerId': customerId,
     'transactionAmount': amount,
     'currentBalance': currentBalance,
   });
   ```

3. **Fix** uygula
   ```dart
   // Fix implementation
   Future<void> updateCustomerBalance(String customerId, double amount) async {
     final currentBalance = await getCurrentBalance(customerId);
     final newBalance = currentBalance + amount;
     await _updateBalance(customerId, newBalance);
   }
   ```

4. **Test** et
   ```dart
   test('should update customer balance correctly', () async {
     // Test implementation
   });
   ```

5. **Documentation** güncelle
   ```markdown
   ## Fixed Issues
   
   - Customer balance calculation now works correctly
   - Added proper error handling for balance updates
   ```

### **3. Refactoring**

1. **Code smell** tespit et
   ```dart
   // Code smell: Long method
   Future<void> processCustomerData() async {
     // 100+ lines of code
   }
   ```

2. **Refactoring plan** oluştur
   ```dart
   // Refactored: Break into smaller methods
   Future<void> processCustomerData() async {
     await _validateCustomerData();
     await _saveCustomerData();
     await _updateCustomerBalance();
     await _sendNotification();
   }
   ```

3. **Tests** yaz
   ```dart
   test('should process customer data successfully', () async {
     // Test implementation
   });
   ```

4. **Refactor** uygula
   ```dart
   // Refactored implementation
   Future<void> _validateCustomerData() async {
     // Validation logic
   }
   
   Future<void> _saveCustomerData() async {
     // Save logic
   }
   ```

5. **Verify** et
   ```bash
   flutter test
   flutter analyze
   ```

---

## 📋 **KONTROL LİSTESİ**

Her geliştirme sonrası kontrol edilmesi gerekenler:

### **Kod Kalitesi**
- [ ] **Lint hataları** yok (`flutter analyze`)
- [ ] **Code formatting** uygulandı (`dart format`)
- [ ] **Naming conventions** takip edildi
- [ ] **SOLID principles** uygulandı
- [ ] **DRY principle** uygulandı

### **Test Coverage**
- [ ] **Unit tests** yazıldı
- [ ] **Widget tests** yazıldı
- [ ] **Integration tests** yazıldı
- [ ] **Test coverage** %80+ (`flutter test --coverage`)
- [ ] **All tests pass** (`flutter test`)

### **Documentation**
- [ ] **Code documentation** güncel
- [ ] **README files** güncel
- [ ] **API documentation** güncel
- [ ] **Changelog** güncel

### **Performance**
- [ ] **Performance** optimize edildi
- [ ] **Memory usage** kontrol edildi
- [ ] **Database queries** optimize edildi
- [ ] **Image optimization** uygulandı
- [ ] **Caching** stratejisi uygulandı

### **Security**
- [ ] **Input validation** uygulandı
- [ ] **Data sanitization** uygulandı
- [ ] **Authentication** kontrol edildi
- [ ] **Authorization** kontrol edildi
- [ ] **HTTPS** kullanıldı

### **Error Handling**
- [ ] **Global error handling** uygulandı
- [ ] **User-friendly messages** eklendi
- [ ] **Logging** eklendi
- [ ] **Recovery mechanisms** uygulandı

### **Firebase Integration**
- [ ] **Firebase connection** çalışıyor
- [ ] **Real data** kullanılıyor
- [ ] **Security rules** güncel
- [ ] **Indexes** optimize edildi

### **UI/UX**
- [ ] **Material Design 3** uygulandı
- [ ] **Responsive design** uygulandı
- [ ] **Dark/Light theme** destekleniyor
- [ ] **Accessibility** kontrol edildi
- [ ] **User experience** test edildi

### **Code Review**
- [ ] **Code review** yapıldı
- [ ] **Peer review** alındı
- [ ] **Architecture review** yapıldı
- [ ] **Security review** yapıldı

---

## 🎯 **SONUÇ**

Bu prompt, **Tamgaci uygulamasının** mevcut yapısını bozmadan, profesyonellikten uzaklaşmadan geliştirme yapılmasını sağlar. Her geliştirme bu kurallara uygun olarak yapılmalı ve uygulamanın **production-ready** durumu korunmalıdır.

### **Önemli Hatırlatmalar**

1. **Mock data kullanma** - Her zaman gerçek Firebase verisi kullan
2. **Test yazma** - Her yeni özellik için test yaz
3. **Documentation** - Kod ve API dokümantasyonunu güncel tut
4. **Performance** - Performansı göz önünde bulundur
5. **Security** - Güvenlik önlemlerini al
6. **Error handling** - Hata yönetimini uygula
7. **Code review** - Kod incelemesi yap

### **Geliştirme Öncesi Kontrol**

Her geliştirme öncesi bu prompt'u okuyarak:
- Uygulamanın mevcut yapısını anla
- Geliştirme kurallarını takip et
- Kontrol listesini kullan
- Production-ready durumu koru

**ÖNEMLİ**: Bu prompt'u her geliştirme öncesi okuyarak, uygulamanın tutarlılığını ve kalitesini koruyun.

---

## 📞 **DESTEK**

Geliştirme sürecinde sorularınız için:
- **Documentation**: `docs/` klasörüne bakın
- **Examples**: Mevcut kod örneklerini inceleyin
- **Tests**: Test dosyalarını referans alın
- **Issues**: GitHub issues'ları kontrol edin

**Başarılı geliştirmeler! 🚀**
