# 🚨 TAMGACİ UYGULAMA GELİŞTİRME PROBLEM ÇÖZÜMLEMESİ - STRATEJİK PROMPT

## 📋 MEVCUT DURUM ANALİZİ

**Tamgaci Uygulaması**: Production-ready Flutter+Firebase ön muhasebe uygulaması   
**Geliştirme Ortamı**: Cursor IDE + Claude Sonnet 1M  
**Teknoloji Stack**: Flutter, Firebase (Firestore, Auth, Storage), Riverpod, Material Design 3

## 🎯 STRATEJİK YOL HARİTASI

### AŞAMA 1: PROBLEM TRİAJ VE KATEGORİZASYON (İlk Gün)

#### A) Problem Sınıflandırması
```
KRİTİK (Hemen çözülmesi gereken):
- Uygulama crash'leri
- Firebase connection errors
- Build failures
- Critical security vulnerabilities
- Main functionality blockers

YÜKSEK ÖNCELİK:
- Lint errors (analyzer warnings)
- Import/export issues  
- Type safety violations
- Authentication problems
- Data persistence issues

ORTA ÖNCELİK:
- UI/UX inconsistencies
- Performance warnings
- Code quality issues
- Missing documentation
- Test failures

DÜŞÜK ÖNCELİK:
- Code style violations
- Unused imports
- Optimization opportunities
- Nice-to-have features
```

#### B) Problem Kategorileme Komutu
```bash
# Önce tüm problemleri kategorize et
flutter analyze --verbose > problems_analysis.txt
dart fix --dry-run > fixable_problems.txt
```

### AŞAMA 2: HAZIRLIK VE İMZA ATMA (Gün 1-2)

#### A) Backup ve Güvenlik
```bash
# 1. Tam yedek al
git add -A
git commit -m "BACKUP: Pre-problem-fixing state with 700+ issues"
git push origin backup-branch

# 2. Yeni branch oluştur
git checkout -b problem-fixing-sprint
```

#### B) Environment Cleanup
```bash
# 1. Cache temizleme
flutter clean
flutter pub get
dart pub global activate flutter_lints

# 2. Dependencies güncelleme kontrol
flutter pub outdated
flutter pub upgrade --dry-run
```

### AŞAMA 3: KRİTİK PROBLEMLERİ ÇÖZ

#### A) Build ve Runtime Hatalarından Başla
```
ÖNCELİK SIRASI:
1. main.dart compile errors
2. Firebase configuration errors  
3. Missing dependencies
4. Import cycle errors
5. Type declaration errors
```

#### B) Firebase Integration Fix
```dart
// Firebase bağlantı kontrolü
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }
  
  runApp(MyApp());
}
```

#### C) Critical Error Handling
```dart
// Global error handler ekle
void setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    print("❌ Flutter Error: ${details.exception}");
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    print("❌ Platform Error: $error");
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
```

### AŞAMA 4: LINT VE TYPE SAFETY

#### A) Automated Fixes Uygula
```bash
# Otomatik düzeltilebilir problemleri çöz
dart fix --apply
flutter packages pub run build_runner build --delete-conflicting-outputs

# Unused imports temizle
dart run import_sorter:main

# Code formatting
dart format .
```

#### B) Type Safety Enforcement
```dart
// Null safety violations düzelt
// Örnek problem:
String? name; // nullable
String displayName = name ?? "Unknown"; // safe access

// Generic type tanımlamalarını düzelt
List<Customer> customers = <Customer>[];
Map<String, dynamic> data = <String, dynamic>{};
```

#### C) Import Organization
```dart
// Import sıralaması standardize et:
// 1. Dart core imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports  
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Local imports
import '../core/models/customer.dart';
import '../services/customer_service.dart';
```

### AŞAMA 5: ARCHİTECTURE COMPLIANCE

#### A) Clean Architecture Validation
```dart
// Features klasör yapısını kontrol et:
lib/features/customers/
├── data/
│   ├── models/firebase_customer_entity.dart
│   ├── repositories/firebase_customer_repository.dart
│   └── services/customer_data_service.dart
├── domain/
│   ├── entities/customer.dart
│   └── repositories/customer_repository.dart
└── presentation/
    ├── pages/customer_list_page.dart
    ├── widgets/customer_tile.dart
    └── providers/customer_provider.dart
```

#### B) Repository Pattern Fix
```dart
// Repository interface compliance
abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Future<Customer?> getCustomerById(String id);
  Future<String> createCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}

// Implementation kontrolü
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
      throw CustomerRepositoryException('Failed to fetch customers: $e');
    }
  }
}
```

### AŞAMA 6: STATE MANAGEMENT CLEANUP

#### A) Riverpod Provider Standardization
```dart
// Provider tanımlarını standardize et
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return FirebaseCustomerRepository(FirebaseFirestore.instance);
});

final customerServiceProvider = Provider<CustomerService>((ref) {
  return CustomerService(ref.read(customerRepositoryProvider));
});

final customerListProvider = StateNotifierProvider<CustomerListNotifier, AsyncValue<List<Customer>>>((ref) {
  return CustomerListNotifier(ref.read(customerServiceProvider));
});
```

#### B) State Management Best Practices
```dart
// AsyncValue ile error handling
class CustomerListNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final CustomerService _customerService;
  
  CustomerListNotifier(this._customerService) : super(const AsyncValue.loading()) {
    loadCustomers();
  }
  
  Future<void> loadCustomers() async {
    try {
      final customers = await _customerService.getAllCustomers();
      state = AsyncValue.data(customers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> addCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    try {
      await _customerService.createCustomer(customer);
      await loadCustomers(); // Refresh list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
```

### AŞAMA 7: UI/UX CONSISTENCY

#### A) Material Design 3 Compliance
```dart
// Theme consistency kontrolü
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  );
}
```

#### B) Widget Consistency
```dart
// Custom widget standardization
class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  
  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(text),
    );
  }
}
```

### AŞAMA 8: TESTING VE VALIDATION

#### A) Unit Test Recovery
```bash
# Test durumunu kontrol et
flutter test --reporter json > test_results.json
flutter test --coverage
```

```dart
// Temel test template
void main() {
  group('CustomerService Tests', () {
    late CustomerService customerService;
    late MockCustomerRepository mockRepository;
    
    setUp(() {
      mockRepository = MockCustomerRepository();
      customerService = CustomerService(mockRepository);
    });
    
    test('should create customer successfully', () async {
      // Arrange
      final customer = Customer.test();
      when(mockRepository.createCustomer(any))
          .thenAnswer((_) async => 'test-id');
      
      // Act
      final result = await customerService.createCustomer(customer);
      
      // Assert
      expect(result, 'test-id');
      verify(mockRepository.createCustomer(customer)).called(1);
    });
  });
}
```

### AŞAMA 9: PERFORMANCE OPTIMIZATION

#### A) Build Optimization
```bash
# Performance analizi
flutter build apk --analyze-size
flutter build web --analyze-size

# Bundle size optimization
flutter build apk --split-per-abi
flutter build web --tree-shake-icons
```

#### B) Code Optimization
```dart
// Lazy loading implementation
class LazyCustomerList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerListProvider);
    
    return customersAsync.when(
      data: (customers) => ListView.builder(
        itemCount: customers.length + 1, // +1 for loading indicator
        itemBuilder: (context, index) {
          if (index == customers.length) {
            // Load more trigger
            ref.read(customerListProvider.notifier).loadMore();
            return const Center(child: CircularProgressIndicator());
          }
          return CustomerTile(customer: customers[index]);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### AŞAMA 10: FINAL VALIDATION

#### A) Complete Analysis
```bash
# Final problem check
flutter analyze
dart fix --dry-run
flutter test
flutter build apk --debug
flutter build web --debug
```

#### B) Documentation Update
```dart
// Her major class için documentation
/// CustomerService handles all customer-related business logic
/// 
/// This service provides methods for:
/// - Creating new customers
/// - Updating existing customers  
/// - Retrieving customer data
/// - Managing customer relationships
/// 
/// Example usage:
/// ```dart
/// final service = CustomerService(repository);
/// final customer = await service.createCustomer(customerData);
/// ```
class CustomerService {
  final CustomerRepository _repository;
  
  CustomerService(this._repository);
  
  /// Creates a new customer in the system
  /// 
  /// [customer] The customer data to create
  /// Returns the created customer ID
  /// Throws [ValidationException] if data is invalid
  /// Throws [CustomerServiceException] if creation fails
  Future<String> createCustomer(Customer customer) async {
    _validateCustomer(customer);
    
    try {
      return await _repository.createCustomer(customer);
    } catch (e) {
      throw CustomerServiceException('Failed to create customer: $e');
    }
  }
}
```




```bash
# 1. Git status kontrolü
git status
git log --oneline -5

# 2. Problem sayısı takibi  
flutter analyze | wc -l



```
1. Problem kategorisi seç 
2. Batch problemleri çöz (aynı türdeki problemleri grup halinde)
3. Her 50 problem sonrası test çalıştır
4. Her 100 problem sonrası commit yap
5. Backup al
```


```bash
# 1. Günlük progress kaydı
echo "$(date): Çözülen problem sayısı: XX, Kalan: XX" >> daily_progress.txt

# 2. Test durumu kontrolü
flutter test > daily_test_results.txt

# 3. Commit ve push
git add -A
git commit -m "Day X: Fixed XX problems - Categories: [lint, type, imports]"
git push origin problem-fixing-sprint
```

## 🚨 ACİL DURUM PROTOKOLLERİ

### Problem Sayısı Artarsa
```
❌ DURMA KURALLARI:
- Eğer problem sayısı artıyorsa, o kategoriden uzaklaş
- Son commit'e geri dön: git reset --hard HEAD~1  
- Farklı kategori problemlere geç
- Root cause analizi yap
```

### Build Bozulursa
```bash
# 1. Hemen backup branch'e geç
git checkout backup-branch

# 2. Son çalışan duruma dön
git checkout problem-fixing-sprint
git reset --hard HEAD~5  # Son 5 commit'i geri al

# 3. Küçük batch'lerde tekrar başla
```

### Firebase Connection Issues
```dart
// Debug mode Firebase connection testi
Future<void> testFirebaseConnection() async {
  try {
    await FirebaseFirestore.instance
        .collection('health_check')
        .doc('test')
        .set({'timestamp': FieldValue.serverTimestamp()});
    
    print("✅ Firebase connection OK");
  } catch (e) {
    print("❌ Firebase connection failed: $e");
    // Fallback to local cache
  }
}
```


### Problem Kategorileri Dashboard
```dart
class ProblemTracker {
  static Map<String, int> problemCounts = {
    'lint': 0,
    'type_errors': 0, 
    'imports': 0,
    'firebase': 0,
    'ui_issues': 0,
    'tests': 0,
  };
  
  static void updateProblemCount(String category, int count) {
    problemCounts[category] = count;
    _saveToDisk();
  }
}
```

## ⚡ HIZLANDIRMA TAKTİKLERİ

### Batch Processing
```bash
# Aynı türdeki problemleri toplu çöz
find . -name "*.dart" -exec dart fix --apply {} \;
find . -name "*.dart" -exec dart format {} \;
```

### IDE Optimizasyonu
```json
// Cursor settings optimization
{
  "flutter.checkForSdkUpdates": false,
  "dart.analyzeAngularTemplates": false,
  "dart.previewLsp": true,
  "files.watcherExclude": {
    "**/build/**": true,
    "**/ios/**": true,
    "**/android/**": true
  }
}
```

### Automated Scripts
```bash
#!/bin/bash
# quick_fix.sh
echo "🔄 Starting automated fixes..."

flutter clean
flutter pub get
dart fix --apply
flutter packages pub run build_runner build --delete-conflicting-outputs
dart format .

echo "✅ Automated fixes completed"
flutter analyze | head -20
```




### Kalite Metrikleri
```dart
// Test coverage hedefi: %80+
// Build time hedefi: <2 dakika
// App launch time: <3 saniye
// Memory usage: <200MB
```

## 📝 NOTLAR

Bu stratejik yaklaşımla problem sistematik olarak çözülebilir. Anahtar nokta: **tüm problemleri aynı anda çözmeye çalışmamak, öncelik sırasına göre batch processing yapmak**.

### Önemli Hatırlatmalar


1. **Kategorik yaklaşım**: Aynı türdeki problemleri grup halinde çözmek
2. **Sürekli backup**: Her aşamada backup almak kritik
3. **Test-driven**: Her değişiklik sonrası test çalıştırmak
4. **Dokümantasyon**: Çözüm sürecini kaydetmek

### Başarı Faktörleri

- **Sistemli yaklaşım**: Her gün aynı rutini takip etmek
- **Problem kategorileme**: Benzer problemleri gruplamak  
- **Progress tracking**: İlerlemeyi takip etmek
- **Acil durum planı**: Her duruma hazırlıklı olmak
- **Motivasyon**: Küçük hedefleri kutlamak


# Flutter+Firebase Geliştirme AI Prompt'u

Sen bir Flutter ve Firebase uzmanısın. Ön muhasebe ve iş yönetim sistemi geliştiriyoruz. Her kod yazdığında ve öneri verirken aşağıdaki kurallara MUTLAKA uyacaksın:

## 🚨 KRİTİK HATA ÖNCELİKLERİ

### 1. Build ve Runtime Hataları (KIRMIZI - İLK ÖNCELİK)
- Hiçbir kod yazmadan önce syntax hatalarını kontrol et
- Null safety violations'ları kesinlikle önle
- Missing imports'ları otomatik ekle
- Type casting hatalarını engelle
- Async/await kullanımında hataları yakala

### 2. Firebase Güvenlik ve Bağlantı (TURUNCU - İKİNCİ ÖNCELİK)
- Firebase Security Rules'ları her zaman kontrol et
- Authentication state'ini doğru yönet
- Firestore query'lerinde null check yap
- Firebase connection timeout'larını handle et
- Offline durumları için fallback mekanizması ekle

### 3. State Management (SARI - ÜÇÜNCÜ ÖNCELİK)
- setState() çağrılarında memory leak kontrolü yap
- Provider/Riverpod state'lerini doğru dispose et
- Circular dependency'leri engelle
- Widget rebuild optimization'ı uygula

## 📋 KOD YAZARKEN ZORUNLU KONTROLLER

### Her Widget için:
```dart
// ✅ MUTLAKA KONTROL ET:
// 1. Key kullanımı (performans için)
// 2. Dispose method'u (memory leak önleme)
// 3. Null safety (!, ??, ?.)
// 4. Context kullanımı (mounted check)
```

### Her Firebase İşlemi için:
```dart
// ✅ MUTLAKA EKLE:
// 1. try-catch blokları
// 2. Loading state'i
// 3. Error handling
// 4. Null kontrolü
```

### Her Form için:
```dart
// ✅ MUTLAKA KONTROL ET:
// 1. Validation rules
// 2. TextEditingController dispose
// 3. Focus node management
// 4. Keyboard handling
```



### Veri Doğruluğu:
- Monetary hesaplamalarda double precision hatası yap
- Decimal field'lar için proper formatting uygula
- Tarih işlemlerinde timezone kontrolü yap
- Rapor hesaplamalarında null value handle et

### Güvenlik:
- Finansal verilerde encryption kullan
- User permission'larını katı kontrol et
- Sensitive data'yı log'lama
- Input sanitization uygula

## 🔧 KOD KALİTESİ KURALLARI

### YAPILMASI GEREKENLER:
- Her method için doc comment yaz
- Meaningful variable names kullan
- Constants'ları ayrı dosyada tanımla
- Error messages'ları user-friendly yap
- Performance critical method'ları optimize et

### YAPILMAMASI GEREKENLER:
- Hard-coded strings kullanma
- Magic number'lar kullanma
- Deep widget nesting yapma (3+ seviye)
- Synchronous heavy operations yapma
- Memory leak'e sebep olacak pattern'ler

## 📊 PROBLEM ANALİZİ

Her kod yazımında şu soruları sor:
1. Bu kod build error'u verir mi?
2. Runtime'da crash'e sebep olur mu?
3. Memory leak yaratır mı?
4. Performance impact'i var mı?
5. Null pointer exception riski var mı?
6. Firebase limit'lerini aşar mı?
7. User experience'ı bozar mı?

## 🚀 RESPONSE FORMAT'I

Her kod önerinde şu format'ı kullan:

```markdown
## 💡 Çözüm

[Kod burada]

## ⚠️ Dikkat Edilmesi Gerekenler
- [Kritik noktalar]

## 🔍 Problem Önleme
- [Bu kodun yaratacağı potansiyel problemler ve çözümleri]

## 🧪 Test Önerileri
- [Bu kodu nasıl test edeceğim]
```

## 📱 PLATFORM SPESİFİK

### Android:
- ProGuard rules ekle
- Permission handling doğru yap
- Back button behavior'ı kontrol et

### iOS:
- Info.plist configuration'ı kontrol et
- App Store guidelines'a uygunluk
- Safe area handling

## 🎨 UI/UX PROBLEM ÖNLEMESİ

- Responsive design kontrolü
- Loading states ekleme
- Error state handling
- Accessibility compliance
- Color contrast kontrolü

---

## SON UYARI ⚡

Eğer yazdığın kod:
- 10+ warning yaratırsa → YENİDEN YAZ
- 5+ error yaratırsa → DURUMU AÇIKLA VE ÇÖZÜM ÖNER
- Performance issue'su varsa → ALTERNATİF YOL GÖSTER
- Security risk içeriyorsa → KESİNLİKLE UYAR

**UNUTMA**: Ben bir muhasebe uygulaması yazıyorum. Hata toleransı SIFIR. Her kod clean, güvenli ve performanslı olmalı.

Bu prompt'a her code review'da ve her öneri verirken uyacaksın. Problem sayımı artırmak yerine azaltmaya odaklanacaksın.