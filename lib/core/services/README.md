# Service Layer Architecture

Bu klasör, uygulamanın service layer'ını organize eder. Servisler işlevlerine göre kategorilere ayrılmıştır.

## 📁 Klasör Yapısı

### 🔥 `firebase/`
Firebase ile ilgili tüm servisler burada bulunur.

- **`firebase_auth_service.dart`** - Firebase Authentication işlemleri
- **`firebase_data_service.dart`** - Firebase Firestore veri işlemleri
- **`firebase_notification_service.dart`** - Firebase Cloud Messaging

### 💼 `business/`
İş mantığı ile ilgili servisler burada bulunur.

- **`dashboard_service.dart`** - Dashboard verileri ve istatistikler
- **`inventory_service.dart`** - Stok yönetimi ve hareketleri
- **`transaction_service.dart`** - Finansal işlemler ve müşteri bakiyeleri

### 🛠️ `utils/`
Yardımcı ve utility servisler burada bulunur.

- **`exchange_rate_service.dart`** - Döviz kurları
- **`export_import_service.dart`** - Veri dışa/içe aktarma
- **`export_service.dart`** - Excel, PDF, CSV export
- **`notification_service.dart`** - Yerel bildirimler
- **`permission_service.dart`** - İzin yönetimi

## 🏗️ Mimari Prensipler

### 1. **Separation of Concerns**
Her servis belirli bir sorumluluğa sahiptir ve diğer servislerden bağımsızdır.

### 2. **Dependency Injection**
Servisler, bağımlılıklarını constructor üzerinden alır.

### 3. **Error Handling**
Tüm servisler merkezi error handling sistemini kullanır.

### 4. **Logging**
Tüm servis işlemleri detaylı olarak loglanır.

### 5. **Validation**
Servisler, gelen verileri validate eder ve business rules'ları uygular.

## 📋 Kullanım Örnekleri

### Firebase Service Kullanımı
```dart
final authService = FirebaseAuthService();
await authService.signIn(email, password);
```

### Business Service Kullanımı
```dart
final dashboardService = DashboardService();
final summary = await dashboardService.getDashboardSummary();
```

### Utility Service Kullanımı
```dart
final exportService = ExportService();
await exportService.exportCustomersToExcel();
```

## 🔄 Service Lifecycle

1. **Initialization** - Servis başlatılır
2. **Configuration** - Servis yapılandırılır
3. **Operation** - İşlemler gerçekleştirilir
4. **Cleanup** - Servis temizlenir

## 🧪 Testing

Her servis için unit testler yazılmalıdır:
- `test/services/firebase/`
- `test/services/business/`
- `test/services/utils/`

## 📝 Notlar

- Servisler singleton pattern kullanabilir
- Async işlemler için Future/Stream kullanılır
- Error handling için try-catch blokları kullanılır
- Logging için AppLogger kullanılır
