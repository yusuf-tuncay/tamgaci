# Tamgaci API Documentation

Bu dokümantasyon, Tamgaci uygulamasının API yapısını ve kullanımını detaylı olarak açıklar.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Authentication](#authentication)
- [Core Services](#core-services)
- [Business Services](#business-services)
- [Repository Pattern](#repository-pattern)
- [Error Handling](#error-handling)
- [Caching](#caching)
- [Pagination](#pagination)
- [Examples](#examples)

## 🔍 Genel Bakış

Tamgaci, Flutter tabanlı bir ön muhasebe uygulamasıdır. Firebase Firestore kullanarak gerçek zamanlı veri yönetimi sağlar.

### Mimari Yapı
```
lib/
├── core/                    # Core functionality
│   ├── services/           # Business services
│   ├── repositories/       # Data access layer
│   ├── cache/             # Caching system
│   ├── pagination/        # Pagination system
│   ├── errors/            # Error handling
│   └── security/          # Security utilities
├── features/              # Feature modules
│   ├── customers/         # Customer management
│   ├── suppliers/         # Supplier management
│   ├── products/          # Product management
│   ├── sales/             # Sales management
│   └── purchases/         # Purchase management
└── shared/                # Shared components
```

## 🔐 Authentication

### Firebase Authentication Service

```dart
class FirebaseAuthService {
  // Kullanıcı girişi
  Future<String> signIn(String email, String password);
  
  // Kullanıcı kaydı
  Future<String> signUp(String email, String password);
  
  // Çıkış yapma
  Future<void> signOut();
  
  // Mevcut kullanıcı
  Future<String?> getCurrentUser();
  
  // Giriş durumu kontrolü
  Future<bool> isSignedIn();
  
  // Şifre sıfırlama
  Future<void> resetPassword(String email);
}
```

### Kullanım Örneği

```dart
final authService = FirebaseAuthService();

// Giriş yapma
try {
  final userId = await authService.signIn('user@example.com', 'password');
  print('Giriş başarılı: $userId');
} catch (e) {
  print('Giriş hatası: $e');
}

// Çıkış yapma
await authService.signOut();
```

## 🏗️ Core Services

### Cache Manager

```dart
class CacheManager {
  // Veri kaydetme
  Future<void> set<T>(String key, T data, {Duration? expiry});
  
  // Veri alma
  Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson});
  
  // Veri silme
  Future<void> remove(String key);
  
  // Tüm cache temizleme
  Future<void> clear();
  
  // Veri varlığı kontrolü
  Future<bool> exists(String key);
  
  // Cache boyutu
  Future<int> getCacheSize();
  
  // Cache bilgileri
  Future<CacheInfo> getCacheInfo();
}
```

### Image Cache

```dart
class ImageCache {
  // Resim cache'leme
  Future<void> cacheImage(String imageUrl, Uint8List imageData);
  
  // Cache'den resim alma
  Future<Uint8List?> getCachedImage(String imageUrl);
  
  // Resim cache'den silme
  Future<void> removeCachedImage(String imageUrl);
  
  // Tüm resim cache temizleme
  Future<void> clearAllImages();
  
  // Resim cache durumu
  Future<bool> isImageCached(String imageUrl);
}
```

### Data Cache

```dart
class DataCache {
  // Müşteri verilerini cache'leme
  Future<void> cacheCustomers(List<Map<String, dynamic>> customers);
  Future<List<Map<String, dynamic>>?> getCachedCustomers();
  
  // Ürün verilerini cache'leme
  Future<void> cacheProducts(List<Map<String, dynamic>> products);
  Future<List<Map<String, dynamic>>?> getCachedProducts();
  
  // Dashboard verilerini cache'leme
  Future<void> cacheDashboardData(Map<String, dynamic> dashboardData);
  Future<Map<String, dynamic>?> getCachedDashboardData();
}
```

## 💼 Business Services

### Dashboard Service

```dart
class DashboardService {
  // Dashboard özet verileri
  Future<Map<String, dynamic>> getDashboardSummary();
  
  // Satış grafik verileri
  Future<List<Map<String, dynamic>>> getSalesChartData(ChartPeriod period);
  
  // Alış grafik verileri
  Future<List<Map<String, dynamic>>> getPurchaseChartData(ChartPeriod period);
  
  // En çok satan müşteriler
  Future<List<Map<String, dynamic>>> getTopCustomers(int limit);
  
  // En çok satan ürünler
  Future<List<Map<String, dynamic>>> getTopProducts(int limit);
  
  // Son işlemler
  Future<List<Map<String, dynamic>>> getRecentTransactions(int limit);
}
```

### Inventory Service

```dart
class InventoryService {
  // Stok seviyesi alma
  Future<int> getStockLevel(String productId);
  
  // Stok güncelleme
  Future<void> updateStock(String productId, int quantity);
  
  // Stok hareketleri
  Future<List<Map<String, dynamic>>> getStockMovements(String productId);
  
  // Düşük stok ürünleri
  Future<List<Map<String, dynamic>>> getLowStockProducts();
  
  // Stok raporu
  Future<Map<String, dynamic>> getStockReport(DateTime startDate, DateTime endDate);
}
```

### Transaction Service

```dart
class TransactionService {
  // İşlem kaydetme
  Future<String> recordTransaction(TransactionData transaction);
  
  // Müşteri bakiyesi
  Future<double> getCustomerBalance(String customerId);
  
  // Müşteri bakiyesi güncelleme
  Future<void> updateCustomerBalance(String customerId, double amount);
  
  // İşlem geçmişi
  Future<List<Map<String, dynamic>>> getTransactionHistory(String customerId);
  
  // Toplam bakiye hesaplama
  Future<double> calculateTotalBalance(String customerId);
}
```

## 🗄️ Repository Pattern

### Base Repository

```dart
abstract class BaseRepository<T> {
  // Tüm verileri alma
  Future<List<T>> getAll();
  
  // ID ile veri alma
  Future<T?> getById(String id);
  
  // Veri oluşturma
  Future<String> create(T entity);
  
  // Veri güncelleme
  Future<void> update(T entity);
  
  // Veri silme
  Future<void> delete(String id);
  
  // Veri varlığı kontrolü
  Future<bool> exists(String id);
  
  // Veri sayısı
  Future<int> getCount();
  
  // Arama
  Future<List<T>> search(String query);
  
  // Sayfalama
  Future<List<T>> getPaginated({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  });
}
```

### Customer Repository

```dart
class CustomerRepository extends BaseRepository<Customer> {
  // Müşteri bakiyesi güncelleme
  Future<void> updateCustomerBalance(String customerId, double amount);
  
  // Müşteri bakiyesi hesaplama
  Future<double> calculateCustomerBalance(String customerId);
  
  // Tüm müşteri bakiyelerini yeniden hesaplama
  Future<void> recalculateAllCustomerBalances();
  
  // Müşteri işlemleri
  Future<List<Map<String, dynamic>>> getCustomerTransactions(String customerId);
  
  // Müşteri raporu
  Future<Map<String, dynamic>> getCustomerReport(String customerId, DateTime startDate, DateTime endDate);
}
```

## ⚠️ Error Handling

### Global Error Handler

```dart
class GlobalErrorHandler {
  // Hata yakalama
  static void handleError(dynamic error, StackTrace stackTrace);
  
  // Hata loglama
  static void logError(String message, {dynamic error, String? context});
  
  // Uyarı loglama
  static void logWarning(String message, {String? context});
  
  // Bilgi loglama
  static void logInfo(String message, {String? context});
}
```

### Error Types

```dart
// Validation hatası
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

// Business rule hatası
class BusinessRuleException implements Exception {
  final String message;
  const BusinessRuleException(this.message);
}

// Network hatası
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}
```

## 💾 Caching

### Cache Configuration

```dart
class CacheConfig {
  final int maxSize;           // Maksimum cache boyutu
  final int maxItems;          // Maksimum öğe sayısı
  final Duration defaultExpiry; // Varsayılan süre
  final bool enableMemoryCache; // Bellek cache aktif
  final bool enableDiskCache;   // Disk cache aktif
}
```

### Cache Usage

```dart
// Cache yapılandırması
final config = CacheConfig(
  maxSize: 100 * 1024 * 1024, // 100MB
  maxItems: 1000,
  defaultExpiry: Duration(hours: 1),
  enableMemoryCache: true,
  enableDiskCache: true,
);

cacheManager.configure(config);

// Veri cache'leme
await cacheManager.set('customers', customerList);

// Cache'den veri alma
final customers = await cacheManager.get<List<Customer>>('customers');
```

## 📄 Pagination

### Pagination Controller

```dart
class PaginationController<T> extends ChangeNotifier {
  // İlk veri yükleme
  Future<void> loadInitialData(Future<PaginationResult<T>> Function(int page, int limit, String? searchQuery) fetchData);
  
  // Daha fazla veri yükleme
  Future<void> loadMoreData(Future<PaginationResult<T>> Function(int page, int limit, String? searchQuery) fetchData);
  
  // Belirli sayfaya gitme
  Future<void> goToPage(int page, Future<PaginationResult<T>> Function(int page, int limit, String? searchQuery) fetchData);
  
  // Sayfa bilgileri
  PageInfo getPageInfo();
  
  // İstatistikler
  PaginationStats getStats();
}
```

### Pagination Result

```dart
class PaginationResult<T> {
  final List<T> items;        // Sayfa verileri
  final int totalItems;       // Toplam öğe sayısı
  final bool hasMore;         // Daha fazla veri var mı
  final int currentPage;      // Mevcut sayfa
  final int totalPages;       // Toplam sayfa sayısı
}
```

## 📝 Examples

### Müşteri Yönetimi

```dart
// Müşteri repository'si
final customerRepo = CustomerRepository();

// Yeni müşteri oluşturma
final newCustomer = Customer(
  name: 'Ahmet Yılmaz',
  email: 'example@example.com',
  phone: '+905551234567',
  address: 'İstanbul, Türkiye',
);

final customerId = await customerRepo.create(newCustomer);

// Müşteri listesi alma
final customers = await customerRepo.getAll();

// Müşteri arama
final searchResults = await customerRepo.search('Ahmet');

// Sayfalama ile müşteri listesi
final paginatedCustomers = await customerRepo.getPaginated(
  page: 1,
  limit: 20,
  sortBy: 'name',
  ascending: true,
);
```

### Stok Yönetimi

```dart
// Stok servisi
final inventoryService = InventoryService();

// Stok seviyesi kontrolü
final stockLevel = await inventoryService.getStockLevel('product_123');

// Stok güncelleme
await inventoryService.updateStock('product_123', 50);

// Düşük stok ürünleri
final lowStockProducts = await inventoryService.getLowStockProducts();

// Stok raporu
final stockReport = await inventoryService.getStockReport(
  DateTime.now().subtract(Duration(days: 30)),
  DateTime.now(),
);
```

### Dashboard Verileri

```dart
// Dashboard servisi
final dashboardService = DashboardService();

// Dashboard özeti
final summary = await dashboardService.getDashboardSummary();
print('Toplam Satış: ${summary['totalSales']}');
print('Toplam Alış: ${summary['totalPurchases']}');
print('Toplam Müşteri: ${summary['totalCustomers']}');

// Satış grafik verileri
final salesChartData = await dashboardService.getSalesChartData(ChartPeriod.monthly);

// En çok satan ürünler
final topProducts = await dashboardService.getTopProducts(10);
```

### Cache Kullanımı

```dart
// Cache manager
final cacheManager = CacheManager();

// Veri cache'leme
await cacheManager.set('dashboard_summary', summary, expiry: Duration(minutes: 5));

// Cache'den veri alma
final cachedSummary = await cacheManager.get<Map<String, dynamic>>(
  'dashboard_summary',
  fromJson: (data) => data,
);

// Cache temizleme
await cacheManager.clear();
```

## 🔧 Configuration

### Firebase Configuration

```dart
// Firebase yapılandırması
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Firestore yapılandırması
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Cache Configuration

```dart
// Cache yapılandırması
final cacheConfig = CacheConfig(
  maxSize: 100 * 1024 * 1024, // 100MB
  maxItems: 1000,
  defaultExpiry: Duration(hours: 1),
  enableMemoryCache: true,
  enableDiskCache: true,
);

CacheManager().configure(cacheConfig);
```

## 📊 Performance Tips

### Cache Optimization
- Sık kullanılan verileri cache'leyin
- Cache expiry sürelerini optimize edin
- Memory ve disk cache'i dengeli kullanın

### Pagination Best Practices
- Sayfa boyutunu optimize edin (20-50 öğe)
- Lazy loading kullanın
- Search ve filter işlemlerini optimize edin

### Error Handling
- Tüm async işlemlerde try-catch kullanın
- Kullanıcı dostu hata mesajları gösterin
- Hataları log'layın

## 🚀 Deployment

### Production Configuration
- Firebase production project kullanın
- Cache boyutlarını production için optimize edin
- Error logging'i production seviyesine ayarlayın
- Performance monitoring aktif edin

### Security
- Firebase security rules'ları yapılandırın
- Input validation'ları aktif edin
- Authentication'ı zorunlu hale getirin
- Data encryption'ı aktif edin
