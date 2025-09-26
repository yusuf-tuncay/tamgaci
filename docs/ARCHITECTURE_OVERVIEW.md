# 🏗️ **TAMGACI ERP - KAPSAMLI MİMARİ DOKÜMANTASYONU**

## 📋 **İÇİNDEKİLER**

- [Genel Bakış](#genel-bakış)
- [Multi-Tenant Mimarisi](#multi-tenant-mimarisi)
- [Clean Architecture](#clean-architecture)
- [Feature-Based Yapı](#feature-based-yapı)
- [Firebase Entegrasyonu](#firebase-entegrasyonu)
- [State Management](#state-management)
- [Güvenlik Mimarisi](#güvenlik-mimarisi)
- [Performance Optimizasyonu](#performance-optimizasyonu)
- [Test Stratejisi](#test-stratejisi)
- [Deployment Pipeline](#deployment-pipeline)
- [Monitoring & Observability](#monitoring--observability)
- [Developer Workflow](#developer-workflow)

---

## 🎯 **GENEL BAKIŞ**

**Tamgaci ERP** modern, cloud-native, multi-tenant bir ön muhasebe ve iş yönetim uygulamasıdır. Flutter framework'ü ile geliştirilmiş, Firebase backend'i ile desteklenen, production-ready durumda olan enterprise-grade bir uygulamadır.

### **Temel Özellikler**
- ✅ **Multi-tenant Architecture** - Her kullanıcı kendi verileriyle çalışır
- ✅ **Clean Architecture** - Domain-driven design prensipleri
- ✅ **Feature-based Structure** - Modüler ve ölçeklenebilir yapı
- ✅ **Firebase Integration** - Real-time, scalable backend
- ✅ **Riverpod State Management** - Reactive programming
- ✅ **Material Design 3** - Modern UI/UX
- ✅ **Cross-platform** - Web, Android, iOS, Windows, macOS, Linux
- ✅ **Production-ready** - Enterprise-grade güvenlik ve performans

---

## 🏢 **MULTI-TENANT MİMARİSİ**

### **Tenant Yapısı**

```dart
// Tenant Entity
class Tenant {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final TenantSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
}

// Tenant Service
class TenantService {
  Future<String> getUserTenantId();
  Future<Tenant> getTenantById(String tenantId);
  Future<String> createTenant(Tenant tenant);
  Future<void> addMemberToTenant(String tenantId, String userId);
  Future<void> removeMemberFromTenant(String tenantId, String userId);
}
```

### **Firestore Collection Yapısı**

```
tenants/
├── {tenantId}/
│   ├── products/
│   ├── customers/
│   ├── suppliers/
│   ├── sales/
│   ├── purchases/
│   ├── incomes/
│   ├── expenses/
│   ├── cash_accounts/
│   ├── cash_transactions/
│   └── inventory_items/
```

### **Security Rules**

```javascript
// Multi-tenant security rules
function isTenantMember(tenantId) {
  return request.auth != null && 
         request.auth.token.tenantId == tenantId;
}

function isTenantOwner(tenantId) {
  return request.auth != null && 
         request.auth.token.tenantId == tenantId &&
         request.auth.token.role == 'owner';
}

// Collection rules
match /tenants/{tenantId}/{collection}/{document} {
  allow read, write: if isTenantMember(tenantId);
  allow delete: if isTenantOwner(tenantId);
}
```

---

## 🏗️ **CLEAN ARCHITECTURE**

### **Katman Yapısı**

```
lib/
├── core/                           # Temel altyapı
│   ├── entities/                   # Core entities
│   ├── services/                   # Business services
│   ├── utils/                      # Utilities
│   ├── errors/                     # Error handling
│   └── constants/                 # Constants
├── features/                       # Feature modules
│   └── {feature_name}/
│       ├── data/                   # Data layer
│       │   ├── models/            # Firebase entities
│       │   ├── repositories/       # Repository implementations
│       │   └── services/          # Data services
│       ├── domain/                 # Domain layer
│       │   ├── entities/          # Domain entities
│       │   ├── repositories/      # Repository interfaces
│       │   └── services/          # Business services
│       └── presentation/           # Presentation layer
│           ├── pages/             # UI pages
│           ├── widgets/           # UI components
│           └── providers/         # State management
└── shared/                        # Shared components
    ├── widgets/                   # Shared widgets
    ├── models/                    # Shared models
    └── utils/                     # Shared utilities
```

### **Dependency Flow**

```
Presentation Layer (UI)
        ↓
Domain Layer (Business Logic)
        ↓
Data Layer (External Data Sources)
```

### **Repository Pattern**

```dart
// Domain Interface
abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<Product?> getProductById(String id);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}

// Firebase Implementation
class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;
  final TenantService _tenantService;
  
  @override
  Future<List<Product>> getAllProducts() async {
    final tenantId = await _tenantService.getUserTenantId();
    if (tenantId.isEmpty) return [];
    
    final querySnapshot = await _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('products')
        .get();
    
    return querySnapshot.docs
        .map((doc) => ProductEntity.fromFirestore(doc).toDomain())
        .toList();
  }
}
```

---

## 🎯 **FEATURE-BASED YAPı**

### **Modül Yapısı**

```
lib/features/
├── auth/                          # Authentication
├── products/                      # Product Management
├── customers/                     # Customer Management
├── suppliers/                     # Supplier Management
├── sales/                        # Sales Management
├── purchases/                    # Purchase Management
├── income/                       # Income Management
├── expenses/                     # Expense Management
├── cash_management/             # Cash Management
├── inventory/                    # Inventory Management
├── reports/                      # Reporting
├── settings/                     # Settings
└── user_profile/                # User Profile
```

### **Her Modül İçin Standart Yapı**

```
{feature_name}/
├── data/
│   ├── models/
│   │   ├── firebase_{entity}_entity.dart
│   │   └── {entity}_entity.dart
│   ├── repositories/
│   │   └── firebase_{entity}_repository.dart
│   └── services/
│       └── {entity}_service.dart
├── domain/
│   ├── entities/
│   │   └── {entity}.dart
│   ├── repositories/
│   │   └── {entity}_repository.dart
│   └── services/
│       └── {entity}_service.dart
└── presentation/
    ├── pages/
    │   ├── {entity}_list_page.dart
    │   ├── create_{entity}_page.dart
    │   └── {entity}_detail_page.dart
    ├── widgets/
    │   └── {entity}_widget.dart
    └── providers/
        └── {entity}_providers.dart
```

---

## 🔥 **FIREBASE ENTEGRASYONU**

### **Firebase Services**

```dart
// Firebase Configuration
class FirebaseConfig {
  static const String projectId = 'tamgaci-prod';
  static const String apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  static const String authDomain = 'tamgaci-prod.firebaseapp.com';
  static const String storageBucket = 'tamgaci-prod.appspot.com';
  static const String messagingSenderId = '123456789012';
  static const String appId = '1:123456789012:web:abcdefghijklmnopqrstuvwxyz';
}

// Firebase Services
class FirebaseServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
}
```

### **Firestore Security Rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Multi-tenant rules
    function isSignedIn() {
      return request.auth != null;
    }
    
    function getUserTenantId() {
      return request.auth.token.tenantId;
    }
    
    function isTenantMember(tenantId) {
      return isSignedIn() && getUserTenantId() == tenantId;
    }
    
    function isTenantOwner(tenantId) {
      return isSignedIn() && 
             getUserTenantId() == tenantId && 
             request.auth.token.role == 'owner';
    }
    
    // Tenant collections
    match /tenants/{tenantId}/{collection}/{document} {
      allow read, write: if isTenantMember(tenantId);
      allow delete: if isTenantOwner(tenantId);
    }
  }
}
```

### **Firebase Storage Rules**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Tenant files
    match /tenants/{tenantId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
                            request.auth.token.tenantId == tenantId;
    }
  }
}
```

---

## 🔄 **STATE MANAGEMENT**

### **Riverpod Providers**

```dart
// Provider Definitions
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirebaseProductRepository();
});

final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(ref.read(productRepositoryProvider));
});

final productDetailProvider = FutureProvider.family<Product?, String>((ref, productId) {
  return ref.read(productRepositoryProvider).getProductById(productId);
});

// State Notifier
class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;
  
  ProductsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _repository.getAllProducts();
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> createProduct(Product product) async {
    try {
      await _repository.createProduct(product);
      await _loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

### **UI Integration**

```dart
class ProductsListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: productsAsync.when(
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text(product.category),
              onTap: () => _navigateToDetail(context, product.id),
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

---

## 🔒 **GÜVENLİK MİMARİSİ**

### **Authentication**

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Tenant setup kontrolü
      await _ensureUserTenantSetup();
      
      return credential;
    } catch (e) {
      AppLogger.error('Sign in failed', e);
      rethrow;
    }
  }
  
  Future<void> _ensureUserTenantSetup() async {
    final tenantService = TenantService();
    await tenantService.ensureUserTenantSetup();
  }
}
```

### **Authorization**

```dart
class AuthorizationService {
  static bool canCreateProduct(String userId, String tenantId) {
    // Business logic for product creation permissions
    return true;
  }
  
  static bool canDeleteProduct(String userId, String productId) {
    // Business logic for product deletion permissions
    return true;
  }
  
  static bool canViewReports(String userId, String tenantId) {
    // Business logic for report viewing permissions
    return true;
  }
}
```

### **Data Validation**

```dart
class ProductValidator {
  static ValidationResult validateCreate(Product product) {
    final errors = <String>[];
    
    if (product.name.isEmpty) {
      errors.add('Product name is required');
    }
    
    if (product.salesPrice <= 0) {
      errors.add('Sales price must be greater than 0');
    }
    
    if (product.salesTaxRate < 0 || product.salesTaxRate > 100) {
      errors.add('Sales tax rate must be between 0 and 100');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
```

---

## ⚡ **PERFORMANCE OPTİMİZASYONU**

### **Caching Strategy**

```dart
class CacheService {
  static final Map<String, dynamic> _cache = {};
  static const Duration _defaultExpiry = Duration(hours: 1);
  
  static void set(String key, dynamic value, {Duration? expiry}) {
    _cache[key] = CacheItem(
      value: value,
      expiry: DateTime.now().add(expiry ?? _defaultExpiry),
    );
  }
  
  static T? get<T>(String key) {
    final item = _cache[key] as CacheItem?;
    if (item == null || item.isExpired) {
      _cache.remove(key);
      return null;
    }
    return item.value as T?;
  }
}

class CacheItem {
  final dynamic value;
  final DateTime expiry;
  
  CacheItem({required this.value, required this.expiry});
  
  bool get isExpired => DateTime.now().isAfter(expiry);
}
```

### **Lazy Loading**

```dart
class LazyLoadingService {
  static const int _pageSize = 20;
  
  static Future<List<Product>> loadProducts({
    required int page,
    String? searchQuery,
  }) async {
    final repository = FirebaseProductRepository();
    final startAfter = page * _pageSize;
    
    return await repository.getProducts(
      limit: _pageSize,
      startAfter: startAfter,
      searchQuery: searchQuery,
    );
  }
}
```

### **Image Optimization**

```dart
class ImageOptimizationService {
  static const int maxImageSize = 1920;
  static const int maxThumbnailSize = 300;
  static const int compressionQuality = 85;
  
  static Future<Uint8List> optimizeImage(Uint8List imageData) async {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;
    
    if (image.width > maxImageSize || image.height > maxImageSize) {
      final resized = img.copyResize(
        image,
        width: maxImageSize,
        height: maxImageSize,
        interpolation: img.Interpolation.average,
      );
      return Uint8List.fromList(img.encodeJpg(resized, quality: compressionQuality));
    }
    
    return Uint8List.fromList(img.encodeJpg(image, quality: compressionQuality));
  }
}
```

---

## 🧪 **TEST STRATEJİSİ**

### **Test Yapısı**

```
test/
├── unit/                          # Unit tests
│   ├── services/                  # Service tests
│   ├── repositories/             # Repository tests
│   └── utils/                     # Utility tests
├── widget/                        # Widget tests
│   ├── pages/                    # Page tests
│   └── widgets/                  # Widget tests
├── integration/                   # Integration tests
│   ├── api/                      # API integration tests
│   └── database/                 # Database integration tests
├── e2e/                          # End-to-end tests
│   ├── user_flows/               # User flow tests
│   └── scenarios/                # Scenario tests
├── mocks/                        # Mock objects
│   ├── repositories/             # Repository mocks
│   └── services/                 # Service mocks
└── utils/                        # Test utilities
    ├── helpers/                  # Test helpers
    └── fixtures/                 # Test data
```

### **Unit Test Örneği**

```dart
void main() {
  group('ProductService', () {
    late ProductService productService;
    late MockProductRepository mockRepository;
    
    setUp(() {
      mockRepository = MockProductRepository();
      productService = ProductService(mockRepository);
    });
    
    test('should create product successfully', () async {
      // Arrange
      final product = Product(
        id: 'test-id',
        name: 'Test Product',
        salesPrice: 100.0,
        salesTaxRate: 20.0,
      );
      
      when(mockRepository.createProduct(any))
          .thenAnswer((_) async {});
      
      // Act
      await productService.createProduct(product);
      
      // Assert
      verify(mockRepository.createProduct(product)).called(1);
    });
  });
}
```

### **Widget Test Örneği**

```dart
void main() {
  group('ProductListPage', () {
    testWidgets('should display product list', (WidgetTester tester) async {
      // Arrange
      final mockProducts = [
        Product(id: '1', name: 'Product 1', salesPrice: 100.0),
        Product(id: '2', name: 'Product 2', salesPrice: 200.0),
      ];
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => 
                ProductsNotifier(MockProductRepository())),
          ],
          child: MaterialApp(home: ProductListPage()),
        ),
      );
      
      // Assert
      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);
    });
  });
}
```

---

## 🚀 **DEPLOYMENT PIPELINE**

### **CI/CD Pipeline**

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.1'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Format check
        run: dart format --set-exit-if-changed .
      
      - name: Build web
        run: flutter build web --release
      
      - name: Build Android
        run: flutter build apk --release
      
      - name: Deploy to Firebase
        if: github.ref == 'refs/heads/main'
        run: |
          firebase deploy --token ${{ secrets.FIREBASE_TOKEN }}
```

### **Environment Configuration**

```dart
// lib/config/environment.dart
class Environment {
  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
  
  static String get firebaseProjectId {
    if (isProduction) return 'tamgaci-prod';
    if (isStaging) return 'tamgaci-staging';
    return 'tamgaci-dev';
  }
}
```

---

## 📊 **MONITORING & OBSERVABILITY**

### **Error Tracking**

```dart
class ErrorTrackingService {
  static Future<void> initialize() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://your-sentry-dsn@sentry.io/project-id';
        options.environment = Environment.isProduction ? 'production' : 'development';
        options.release = '1.0.0';
        options.tracesSampleRate = 0.1;
      },
      appRunner: () => runApp(MyApp()),
    );
  }
  
  static Future<void> captureException(dynamic exception, StackTrace? stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }
}
```

### **Performance Monitoring**

```dart
class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  
  static Future<Trace> startTrace(String name) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    return trace;
  }
  
  static Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }
}
```

### **Analytics**

```dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  static Future<void> trackUserAction(String action, Map<String, dynamic> data) async {
    await logEvent('user_action', {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...data,
    });
  }
}
```

---

## 👨‍💻 **DEVELOPER WORKFLOW**

### **Development Setup**

```bash
# 1. Repository clone
git clone https://github.com/gucluoglu/tamgaci.git
cd tamgaci

# 2. Flutter setup
flutter --version  # Ensure 3.35.1
flutter pub get

# 3. Firebase setup
firebase login
firebase use tamgaci-dev

# 4. Environment setup
cp .env.example .env
# Edit .env with your configuration

# 5. Run application
flutter run -d chrome
```

### **Development Commands**

```bash
# Code formatting
dart format .

# Code analysis
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build for web
flutter build web --release

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

### **Git Workflow**

```bash
# Feature development
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature

# Create pull request
# Code review
# Merge to main
```

---

## 📚 **DOKÜMANTASYON**

### **API Documentation**

```dart
/// Product management service
/// 
/// This service provides business logic for product operations
/// including creation, updates, and deletion.
/// 
/// Example:
/// ```dart
/// final service = ProductService();
/// final product = Product(name: 'Test Product', price: 100.0);
/// await service.createProduct(product);
/// ```
class ProductService {
  /// Creates a new product
  /// 
  /// [product] The product to create
  /// Throws [ValidationException] if product data is invalid
  /// Throws [RepositoryException] if database operation fails
  Future<void> createProduct(Product product) async {
    // Implementation
  }
}
```

### **README Structure**

```markdown
# Tamgaci ERP

## Overview
Modern, cloud-native, multi-tenant ERP application.

## Features
- Multi-tenant architecture
- Real-time data synchronization
- Cross-platform support
- Enterprise-grade security

## Getting Started
1. Clone repository
2. Install dependencies
3. Configure Firebase
4. Run application

## Architecture
- Clean Architecture
- Feature-based structure
- Firebase backend
- Riverpod state management

## Development
- Flutter 3.35.1
- Dart 3.0+
- Firebase
- Riverpod

## Testing
- Unit tests
- Widget tests
- Integration tests
- E2E tests

## Deployment
- Firebase Hosting
- CI/CD pipeline
- Environment management
```

---

## 🎯 **SONUÇ**

Bu dokümantasyon, **Tamgaci ERP** uygulamasının kapsamlı mimari yapısını, geliştirme süreçlerini ve best practice'lerini içermektedir. 

### **Önemli Noktalar**

1. **Multi-tenant Architecture** - Her kullanıcı kendi verileriyle çalışır
2. **Clean Architecture** - Domain-driven design prensipleri
3. **Feature-based Structure** - Modüler ve ölçeklenebilir yapı
4. **Firebase Integration** - Real-time, scalable backend
5. **Riverpod State Management** - Reactive programming
6. **Production-ready** - Enterprise-grade güvenlik ve performans

### **Geliştirme Kuralları**

- ✅ **Clean Code** prensipleri
- ✅ **SOLID** prensipleri
- ✅ **DRY** prensibi
- ✅ **KISS** prensibi
- ✅ **Test-driven Development**
- ✅ **Documentation-driven Development**

### **Kontrol Listesi**

- [ ] **Code Quality** - Lint hataları yok
- [ ] **Test Coverage** - %80+ coverage
- [ ] **Documentation** - Güncel dokümantasyon
- [ ] **Performance** - Optimize edilmiş
- [ ] **Security** - Güvenlik önlemleri
- [ ] **Monitoring** - Error tracking ve analytics

---

**Bu dokümantasyon, AI modelleri ve developerlar için Tamgaci ERP uygulamasının kapsamlı mimari yapısını ve geliştirme süreçlerini detaylandırmaktadır.**
