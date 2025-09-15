# Services API Documentation

Bu dokümantasyon, Tamgaci uygulamasının servis katmanı API'lerini detaylı olarak açıklar.

## 📋 İçindekiler

- [Business Services](#business-services)
- [Firebase Services](#firebase-services)
- [Utility Services](#utility-services)
- [Cache Services](#cache-services)
- [Error Handling](#error-handling)
- [Configuration](#configuration)

## 💼 Business Services

### Dashboard Service

Dashboard servisi, uygulamanın ana sayfası için gerekli tüm verileri sağlar.

#### Methods

##### `getDashboardSummary()`
Dashboard özet verilerini getirir.

**Return Type:** `Future<Map<String, dynamic>>`

**Response:**
```json
{
  "totalSales": 10000.0,
  "totalPurchases": 8000.0,
  "totalCustomers": 50,
  "totalProducts": 100,
  "lowStockProducts": 5,
  "pendingInvoices": 10,
  "monthlyGrowth": 15.5,
  "yearlyGrowth": 25.3
}
```

**Usage:**
```dart
final dashboardService = DashboardService();
final summary = await dashboardService.getDashboardSummary();
print('Toplam Satış: ${summary['totalSales']}');
```

##### `getSalesChartData(ChartPeriod period)`
Satış grafik verilerini getirir.

**Parameters:**
- `period` (ChartPeriod): Grafik periyodu (daily, weekly, monthly, yearly)

**Return Type:** `Future<List<Map<String, dynamic>>>`

**Response:**
```json
[
  {
    "date": "2024-01-01",
    "amount": 1500.0,
    "count": 25
  },
  {
    "date": "2024-01-02",
    "amount": 2000.0,
    "count": 30
  }
]
```

##### `getPurchaseChartData(ChartPeriod period)`
Alış grafik verilerini getirir.

**Parameters:**
- `period` (ChartPeriod): Grafik periyodu

**Return Type:** `Future<List<Map<String, dynamic>>>`

##### `getTopCustomers(int limit)`
En çok satış yapılan müşterileri getirir.

**Parameters:**
- `limit` (int): Maksimum müşteri sayısı

**Return Type:** `Future<List<Map<String, dynamic>>>`

**Response:**
```json
[
  {
    "id": "customer_1",
    "name": "Ahmet Yılmaz",
    "totalSales": 5000.0,
    "orderCount": 15
  }
]
```

##### `getTopProducts(int limit)`
En çok satılan ürünleri getirir.

**Parameters:**
- `limit` (int): Maksimum ürün sayısı

**Return Type:** `Future<List<Map<String, dynamic>>>`

##### `getRecentTransactions(int limit)`
Son işlemleri getirir.

**Parameters:**
- `limit` (int): Maksimum işlem sayısı

**Return Type:** `Future<List<Map<String, dynamic>>>`

### Inventory Service

Stok yönetimi için gerekli tüm işlemleri sağlar.

#### Methods

##### `getStockLevel(String productId)`
Belirli bir ürünün stok seviyesini getirir.

**Parameters:**
- `productId` (String): Ürün ID'si

**Return Type:** `Future<int>`

**Usage:**
```dart
final inventoryService = InventoryService();
final stockLevel = await inventoryService.getStockLevel('product_123');
print('Stok Seviyesi: $stockLevel');
```

##### `updateStock(String productId, int quantity)`
Ürün stok seviyesini günceller.

**Parameters:**
- `productId` (String): Ürün ID'si
- `quantity` (int): Yeni stok miktarı

**Return Type:** `Future<void>`

**Usage:**
```dart
await inventoryService.updateStock('product_123', 50);
```

##### `getStockMovements(String productId)`
Ürünün stok hareketlerini getirir.

**Parameters:**
- `productId` (String): Ürün ID'si

**Return Type:** `Future<List<Map<String, dynamic>>>`

**Response:**
```json
[
  {
    "id": "movement_1",
    "type": "in",
    "quantity": 100,
    "date": "2024-01-01T10:00:00Z",
    "reason": "purchase"
  },
  {
    "id": "movement_2",
    "type": "out",
    "quantity": 25,
    "date": "2024-01-02T14:30:00Z",
    "reason": "sale"
  }
]
```

##### `getLowStockProducts()`
Düşük stok seviyesindeki ürünleri getirir.

**Return Type:** `Future<List<Map<String, dynamic>>>`

**Response:**
```json
[
  {
    "id": "product_1",
    "name": "Ürün 1",
    "currentStock": 5,
    "minStock": 10,
    "category": "Kategori 1"
  }
]
```

##### `getStockReport(DateTime startDate, DateTime endDate)`
Belirli tarih aralığındaki stok raporunu getirir.

**Parameters:**
- `startDate` (DateTime): Başlangıç tarihi
- `endDate` (DateTime): Bitiş tarihi

**Return Type:** `Future<Map<String, dynamic>>`

**Response:**
```json
{
  "totalProducts": 100,
  "lowStockProducts": 5,
  "outOfStockProducts": 2,
  "totalValue": 50000.0,
  "movements": [
    {
      "date": "2024-01-01",
      "in": 1000,
      "out": 500,
      "net": 500
    }
  ]
}
```

### Transaction Service

Finansal işlemler ve müşteri bakiyeleri için gerekli işlemleri sağlar.

#### Methods

##### `recordTransaction(TransactionData transaction)`
Yeni bir işlem kaydeder.

**Parameters:**
- `transaction` (TransactionData): İşlem verisi

**Return Type:** `Future<String>` (Transaction ID)

**Usage:**
```dart
final transaction = TransactionData(
  customerId: 'customer_123',
  type: TransactionType.sale,
  amount: 1000.0,
  description: 'Satış işlemi',
);

final transactionId = await transactionService.recordTransaction(transaction);
```

##### `getCustomerBalance(String customerId)`
Müşterinin güncel bakiyesini getirir.

**Parameters:**
- `customerId` (String): Müşteri ID'si

**Return Type:** `Future<double>`

**Usage:**
```dart
final balance = await transactionService.getCustomerBalance('customer_123');
print('Müşteri Bakiyesi: $balance');
```

##### `updateCustomerBalance(String customerId, double amount)`
Müşteri bakiyesini günceller.

**Parameters:**
- `customerId` (String): Müşteri ID'si
- `amount` (double): Bakiye değişimi

**Return Type:** `Future<void>`

##### `getTransactionHistory(String customerId)`
Müşterinin işlem geçmişini getirir.

**Parameters:**
- `customerId` (String): Müşteri ID'si

**Return Type:** `Future<List<Map<String, dynamic>>>`

**Response:**
```json
[
  {
    "id": "transaction_1",
    "type": "sale",
    "amount": 1000.0,
    "date": "2024-01-01T10:00:00Z",
    "description": "Satış işlemi",
    "balance": 1000.0
  }
]
```

##### `calculateTotalBalance(String customerId)`
Müşterinin toplam bakiyesini hesaplar.

**Parameters:**
- `customerId` (String): Müşteri ID'si

**Return Type:** `Future<double>`

## 🔥 Firebase Services

### Firebase Auth Service

Firebase Authentication işlemlerini yönetir.

#### Methods

##### `signIn(String email, String password)`
Kullanıcı girişi yapar.

**Parameters:**
- `email` (String): Kullanıcı e-postası
- `password` (String): Kullanıcı şifresi

**Return Type:** `Future<String>` (User ID)

**Usage:**
```dart
final authService = FirebaseAuthService();
try {
  final userId = await authService.signIn('user@example.com', 'password');
  print('Giriş başarılı: $userId');
} catch (e) {
  print('Giriş hatası: $e');
}
```

##### `signUp(String email, String password)`
Yeni kullanıcı kaydı yapar.

**Parameters:**
- `email` (String): Kullanıcı e-postası
- `password` (String): Kullanıcı şifresi

**Return Type:** `Future<String>` (User ID)

##### `signOut()`
Kullanıcı çıkışı yapar.

**Return Type:** `Future<void>`

##### `getCurrentUser()`
Mevcut kullanıcıyı getirir.

**Return Type:** `Future<String?>` (User ID)

##### `isSignedIn()`
Kullanıcının giriş yapıp yapmadığını kontrol eder.

**Return Type:** `Future<bool>`

##### `resetPassword(String email)`
Şifre sıfırlama e-postası gönderir.

**Parameters:**
- `email` (String): Kullanıcı e-postası

**Return Type:** `Future<void>`

### Firebase Data Service

Firebase Firestore veri işlemlerini yönetir.

#### Methods

##### `getCollection(String collectionName)`
Belirli bir koleksiyondaki tüm belgeleri getirir.

**Parameters:**
- `collectionName` (String): Koleksiyon adı

**Return Type:** `Future<List<Map<String, dynamic>>>`

##### `getDocument(String collectionName, String documentId)`
Belirli bir belgeyi getirir.

**Parameters:**
- `collectionName` (String): Koleksiyon adı
- `documentId` (String): Belge ID'si

**Return Type:** `Future<Map<String, dynamic>?>`

##### `setDocument(String collectionName, String documentId, Map<String, dynamic> data)`
Belgeyi oluşturur veya günceller.

**Parameters:**
- `collectionName` (String): Koleksiyon adı
- `documentId` (String): Belge ID'si
- `data` (Map<String, dynamic>): Belge verisi

**Return Type:** `Future<void>`

##### `updateDocument(String collectionName, String documentId, Map<String, dynamic> data)`
Belgeyi günceller.

**Parameters:**
- `collectionName` (String): Koleksiyon adı
- `documentId` (String): Belge ID'si
- `data` (Map<String, dynamic>): Güncellenecek veri

**Return Type:** `Future<void>`

##### `deleteDocument(String collectionName, String documentId)`
Belgeyi siler.

**Parameters:**
- `collectionName` (String): Koleksiyon adı
- `documentId` (String): Belge ID'si

**Return Type:** `Future<void>`

##### `queryCollection(String collectionName, Map<String, dynamic> query)`
Koleksiyonda sorgu yapar.

**Parameters:**
- `collectionName` (String): Koleksiyon adı
- `query` (Map<String, dynamic>): Sorgu parametreleri

**Return Type:** `Future<List<Map<String, dynamic>>>`

## 🛠️ Utility Services

### Export Service

Veri dışa aktarma işlemlerini yönetir.

#### Methods

##### `exportCustomersToExcel()`
Müşteri verilerini Excel formatında dışa aktarır.

**Return Type:** `Future<String>` (File path)

**Usage:**
```dart
final exportService = ExportService();
final filePath = await exportService.exportCustomersToExcel();
print('Excel dosyası: $filePath');
```

##### `exportProductsToExcel()`
Ürün verilerini Excel formatında dışa aktarır.

**Return Type:** `Future<String>` (File path)

##### `exportSalesToExcel()`
Satış verilerini Excel formatında dışa aktarır.

**Return Type:** `Future<String>` (File path)

##### `exportStockReportToPDF()`
Stok raporunu PDF formatında dışa aktarır.

**Return Type:** `Future<String>` (File path)

##### `exportToCSV(String dataType, List<Map<String, dynamic>> data)`
Verileri CSV formatında dışa aktarır.

**Parameters:**
- `dataType` (String): Veri türü
- `data` (List<Map<String, dynamic>>): Dışa aktarılacak veri

**Return Type:** `Future<String>` (File path)

### Notification Service

Bildirim işlemlerini yönetir.

#### Methods

##### `showNotification(String title, String body)`
Genel bildirim gösterir.

**Parameters:**
- `title` (String): Bildirim başlığı
- `body` (String): Bildirim içeriği

**Return Type:** `Future<void>`

##### `showSuccessNotification(String message)`
Başarı bildirimi gösterir.

**Parameters:**
- `message` (String): Bildirim mesajı

**Return Type:** `Future<void>`

##### `showErrorNotification(String message)`
Hata bildirimi gösterir.

**Parameters:**
- `message` (String): Hata mesajı

**Return Type:** `Future<void>`

##### `showWarningNotification(String message)`
Uyarı bildirimi gösterir.

**Parameters:**
- `message` (String): Uyarı mesajı

**Return Type:** `Future<void>`

##### `showInfoNotification(String message)`
Bilgi bildirimi gösterir.

**Parameters:**
- `message` (String): Bilgi mesajı

**Return Type:** `Future<void>`

### Permission Service

İzin yönetimi işlemlerini yönetir.

#### Methods

##### `requestPermission(PermissionType permission)`
Belirli bir izin ister.

**Parameters:**
- `permission` (PermissionType): İzin türü

**Return Type:** `Future<bool>`

**Usage:**
```dart
final permissionService = PermissionService();
final granted = await permissionService.requestPermission(PermissionType.storage);
if (granted) {
  print('İzin verildi');
} else {
  print('İzin reddedildi');
}
```

##### `checkPermission(PermissionType permission)`
İzin durumunu kontrol eder.

**Parameters:**
- `permission` (PermissionType): İzin türü

**Return Type:** `Future<bool>`

##### `isPermissionGranted(PermissionType permission)`
İznin verilip verilmediğini kontrol eder.

**Parameters:**
- `permission` (PermissionType): İzin türü

**Return Type:** `Future<bool>`

##### `openAppSettings()`
Uygulama ayarlarını açar.

**Return Type:** `Future<void>`

## 💾 Cache Services

### Cache Manager

Merkezi cache yönetimi sağlar.

#### Methods

##### `set<T>(String key, T data, {Duration? expiry})`
Veriyi cache'e kaydeder.

**Parameters:**
- `key` (String): Cache anahtarı
- `data` (T): Cache'lenecek veri
- `expiry` (Duration?): Cache süresi

**Return Type:** `Future<void>`

**Usage:**
```dart
final cacheManager = CacheManager();
await cacheManager.set('customers', customerList, expiry: Duration(hours: 1));
```

##### `get<T>(String key, {T Function(Map<String, dynamic>)? fromJson})`
Cache'den veri getirir.

**Parameters:**
- `key` (String): Cache anahtarı
- `fromJson` (Function?): JSON'dan obje dönüştürme fonksiyonu

**Return Type:** `Future<T?>`

**Usage:**
```dart
final customers = await cacheManager.get<List<Customer>>('customers');
```

##### `remove(String key)`
Cache'den veri siler.

**Parameters:**
- `key` (String): Cache anahtarı

**Return Type:** `Future<void>`

##### `clear()`
Tüm cache'i temizler.

**Return Type:** `Future<void>`

##### `exists(String key)`
Cache'de veri olup olmadığını kontrol eder.

**Parameters:**
- `key` (String): Cache anahtarı

**Return Type:** `Future<bool>`

##### `getCacheSize()`
Cache boyutunu getirir.

**Return Type:** `Future<int>`

##### `getCacheInfo()`
Cache bilgilerini getirir.

**Return Type:** `Future<CacheInfo>`

**Response:**
```json
{
  "totalSize": 1024000,
  "memoryItems": 50,
  "diskItems": 100,
  "totalItems": 150,
  "hitRate": 0.85,
  "memoryHitRate": 0.60,
  "diskHitRate": 0.25
}
```

##### `cleanup()`
Süresi dolmuş cache öğelerini temizler.

**Return Type:** `Future<void>`

### Image Cache

Resim cache yönetimi sağlar.

#### Methods

##### `cacheImage(String imageUrl, Uint8List imageData)`
Resmi cache'e kaydeder.

**Parameters:**
- `imageUrl` (String): Resim URL'si
- `imageData` (Uint8List): Resim verisi

**Return Type:** `Future<void>`

##### `getCachedImage(String imageUrl)`
Cache'den resim getirir.

**Parameters:**
- `imageUrl` (String): Resim URL'si

**Return Type:** `Future<Uint8List?>`

##### `removeCachedImage(String imageUrl)`
Cache'den resim siler.

**Parameters:**
- `imageUrl` (String): Resim URL'si

**Return Type:** `Future<void>`

##### `clearAllImages()`
Tüm resim cache'ini temizler.

**Return Type:** `Future<void>`

##### `isImageCached(String imageUrl)`
Resmin cache'de olup olmadığını kontrol eder.

**Parameters:**
- `imageUrl` (String): Resim URL'si

**Return Type:** `Future<bool>`

##### `getImageCacheInfo(String imageUrl)`
Resim cache bilgilerini getirir.

**Parameters:**
- `imageUrl` (String): Resim URL'si

**Return Type:** `Future<ImageCacheInfo?>`

##### `getAllCachedImagesInfo()`
Tüm cache'lenmiş resim bilgilerini getirir.

**Return Type:** `Future<List<ImageCacheInfo>>`

##### `getCacheSize()`
Resim cache boyutunu getirir.

**Return Type:** `Future<int>`

##### `cleanupExpiredImages()`
Süresi dolmuş resimleri temizler.

**Return Type:** `Future<void>`

##### `preloadImages(List<String> imageUrls)`
Resimleri önceden yükler.

**Parameters:**
- `imageUrls` (List<String>): Resim URL'leri

**Return Type:** `Future<void>`

### Data Cache

Veri cache yönetimi sağlar.

#### Methods

##### `cacheCustomers(List<Map<String, dynamic>> customers)`
Müşteri verilerini cache'e kaydeder.

**Parameters:**
- `customers` (List<Map<String, dynamic>>): Müşteri listesi

**Return Type:** `Future<void>`

##### `getCachedCustomers()`
Cache'den müşteri verilerini getirir.

**Return Type:** `Future<List<Map<String, dynamic>>?>`

##### `cacheCustomer(String customerId, Map<String, dynamic> customer)`
Tek müşteri verisini cache'e kaydeder.

**Parameters:**
- `customerId` (String): Müşteri ID'si
- `customer` (Map<String, dynamic>): Müşteri verisi

**Return Type:** `Future<void>`

##### `getCachedCustomer(String customerId)`
Cache'den tek müşteri verisini getirir.

**Parameters:**
- `customerId` (String): Müşteri ID'si

**Return Type:** `Future<Map<String, dynamic>?>`

##### `cacheProducts(List<Map<String, dynamic>> products)`
Ürün verilerini cache'e kaydeder.

**Parameters:**
- `products` (List<Map<String, dynamic>>): Ürün listesi

**Return Type:** `Future<void>`

##### `getCachedProducts()`
Cache'den ürün verilerini getirir.

**Return Type:** `Future<List<Map<String, dynamic>>?>`

##### `cacheDashboardData(Map<String, dynamic> dashboardData)`
Dashboard verilerini cache'e kaydeder.

**Parameters:**
- `dashboardData` (Map<String, dynamic>): Dashboard verisi

**Return Type:** `Future<void>`

##### `getCachedDashboardData()`
Cache'den dashboard verilerini getirir.

**Return Type:** `Future<Map<String, dynamic>?>`

##### `cacheSearchResults(String query, List<Map<String, dynamic>> results)`
Arama sonuçlarını cache'e kaydeder.

**Parameters:**
- `query` (String): Arama sorgusu
- `results` (List<Map<String, dynamic>>): Arama sonuçları

**Return Type:** `Future<void>`

##### `getCachedSearchResults(String query)`
Cache'den arama sonuçlarını getirir.

**Parameters:**
- `query` (String): Arama sorgusu

**Return Type:** `Future<List<Map<String, dynamic>>?>`

##### `cacheUserPreferences(Map<String, dynamic> preferences)`
Kullanıcı tercihlerini cache'e kaydeder.

**Parameters:**
- `preferences` (Map<String, dynamic>): Kullanıcı tercihleri

**Return Type:** `Future<void>`

##### `getCachedUserPreferences()`
Cache'den kullanıcı tercihlerini getirir.

**Return Type:** `Future<Map<String, dynamic>?>`

##### `clearDataTypeCache(DataType dataType)`
Belirli veri türünün cache'ini temizler.

**Parameters:**
- `dataType` (DataType): Veri türü

**Return Type:** `Future<void>`

##### `clearAllDataCache()`
Tüm veri cache'ini temizler.

**Return Type:** `Future<void>`

##### `getCacheStatistics()`
Cache istatistiklerini getirir.

**Return Type:** `Future<DataCacheStats>`

##### `preloadCriticalData()`
Kritik verileri önceden yükler.

**Return Type:** `Future<void>`

## ⚠️ Error Handling

### Global Error Handler

Tüm hataları merkezi olarak yönetir.

#### Methods

##### `handleError(dynamic error, StackTrace stackTrace)`
Hatayı yakalar ve işler.

**Parameters:**
- `error` (dynamic): Hata objesi
- `stackTrace` (StackTrace): Hata stack trace'i

**Return Type:** `void`

##### `logError(String message, {dynamic error, String? context})`
Hata loglar.

**Parameters:**
- `message` (String): Hata mesajı
- `error` (dynamic?): Hata objesi
- `context` (String?): Hata bağlamı

**Return Type:** `void`

##### `logWarning(String message, {String? context})`
Uyarı loglar.

**Parameters:**
- `message` (String): Uyarı mesajı
- `context` (String?): Uyarı bağlamı

**Return Type:** `void`

##### `logInfo(String message, {String? context})`
Bilgi loglar.

**Parameters:**
- `message` (String): Bilgi mesajı
- `context` (String?): Bilgi bağlamı

**Return Type:** `void`

### Error Types

#### ValidationException
Veri doğrulama hataları için kullanılır.

```dart
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}
```

#### BusinessRuleException
İş kuralları hataları için kullanılır.

```dart
class BusinessRuleException implements Exception {
  final String message;
  const BusinessRuleException(this.message);
}
```

#### NetworkException
Ağ hataları için kullanılır.

```dart
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}
```

## ⚙️ Configuration

### Cache Configuration

Cache yapılandırması.

```dart
class CacheConfig {
  final int maxSize;           // Maksimum cache boyutu (bytes)
  final int maxItems;          // Maksimum öğe sayısı
  final Duration defaultExpiry; // Varsayılan süre
  final bool enableMemoryCache; // Bellek cache aktif
  final bool enableDiskCache;   // Disk cache aktif
}
```

### Service Configuration

Servis yapılandırması.

```dart
class ServiceConfig {
  final String firebaseProjectId;
  final String firebaseApiKey;
  final Duration requestTimeout;
  final int maxRetries;
  final bool enableLogging;
}
```

## 📊 Performance Tips

### Cache Optimization
- Sık kullanılan verileri cache'leyin
- Cache expiry sürelerini optimize edin
- Memory ve disk cache'i dengeli kullanın

### Service Optimization
- Async/await kullanın
- Error handling'i doğru yapın
- Timeout'ları ayarlayın
- Retry mekanizmaları ekleyin

### Data Optimization
- Pagination kullanın
- Lazy loading uygulayın
- Search ve filter işlemlerini optimize edin
- Batch operations kullanın
