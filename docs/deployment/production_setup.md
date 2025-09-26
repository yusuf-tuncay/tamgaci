# Production Setup Kılavuzu

Bu kılavuz, Tamgaci uygulamasının production ortamına deploy edilmesi için gerekli adımları içerir.

**GÜNCEL DURUM**: Multi-tenant mimarisi tamamlandı, Firebase security rules güncellendi, production-ready durumda.

## 📋 İçindekiler

- [Production Checklist](#production-checklist)
- [Environment Configuration](#environment-configuration)
- [Security Configuration](#security-configuration)
- [Performance Optimization](#performance-optimization)
- [Monitoring Setup](#monitoring-setup)
- [Backup Strategy](#backup-strategy)
- [Deployment Process](#deployment-process)
- [Post-Deployment](#post-deployment)

## ✅ Production Checklist

### Pre-Deployment Checklist

- [ ] **Code Quality**
  - [ ] Tüm testler geçiyor
  - [ ] Code coverage %80 üzerinde
  - [ ] Lint hataları yok
  - [ ] Security vulnerabilities yok

- [ ] **Firebase Configuration**
  - [ ] Production Firebase projesi oluşturuldu
  - [ ] Security rules yapılandırıldı
  - [ ] Authentication aktif edildi
  - [ ] Firestore database hazır
  - [ ] Storage yapılandırıldı
  - [ ] Hosting yapılandırıldı

- [ ] **Environment Variables**
  - [ ] Production API keys
  - [ ] Firebase configuration
  - [ ] Third-party service keys
  - [ ] Database connection strings

- [ ] **Security**
  - [ ] HTTPS aktif
  - [ ] CORS yapılandırıldı
  - [ ] Input validation
  - [ ] Rate limiting
  - [ ] Authentication required

- [ ] **Performance**
  - [ ] Image optimization
  - [ ] Code splitting
  - [ ] Caching strategy
  - [ ] CDN configuration
  - [ ] Database indexing

- [ ] **Monitoring**
  - [ ] Error tracking
  - [ ] Performance monitoring
  - [ ] Analytics
  - [ ] Logging
  - [ ] Alerts

### Post-Deployment Checklist

- [ ] **Verification**
  - [ ] Uygulama erişilebilir
  - [ ] Authentication çalışıyor
  - [ ] Database bağlantısı
  - [ ] File upload çalışıyor
  - [ ] Email gönderimi çalışıyor

- [ ] **Testing**
  - [ ] Smoke tests
  - [ ] Integration tests
  - [ ] Performance tests
  - [ ] Security tests
  - [ ] User acceptance tests

- [ ] **Documentation**
  - [ ] API documentation güncel
  - [ ] User guide güncel
  - [ ] Deployment guide güncel
  - [ ] Troubleshooting guide

## 🌍 Environment Configuration

### 1. Production Environment Variables

#### .env.production
```env
# Production Environment
ENVIRONMENT=production
NODE_ENV=production

# Firebase Configuration
FIREBASE_PROJECT_ID=tamgaci-prod
FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FIREBASE_AUTH_DOMAIN=tamgaci-prod.firebaseapp.com
FIREBASE_STORAGE_BUCKET=tamgaci-prod.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:web:abcdefghijklmnopqrstuvwxyz

# API Configuration
API_BASE_URL=https://api.tamgaci.com
API_TIMEOUT=30000
API_RATE_LIMIT=1000

# Database Configuration
DATABASE_URL=https://tamgaci-prod-default-rtdb.firebaseio.com
DATABASE_TIMEOUT=30000

# Security Configuration
JWT_SECRET=your-super-secret-jwt-key
ENCRYPTION_KEY=your-32-character-encryption-key
CORS_ORIGIN=https://tamgaci.com

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@tamgaci.com
SMTP_PASS=your-smtp-password
EMAIL_FROM=noreply@tamgaci.com

# File Storage
STORAGE_BUCKET=tamgaci-prod.appspot.com
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES=jpg,jpeg,png,pdf,doc,docx,xls,xlsx

# Logging Configuration
LOG_LEVEL=error
LOG_FILE_PATH=/var/log/tamgaci
LOG_MAX_SIZE=10485760
LOG_MAX_FILES=5

# Monitoring Configuration
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
ENABLE_PERFORMANCE_MONITORING=true
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id

# Cache Configuration
REDIS_URL=redis://localhost:6379
CACHE_TTL=3600
CACHE_MAX_SIZE=1000

# Rate Limiting
RATE_LIMIT_WINDOW=900000
RATE_LIMIT_MAX_REQUESTS=100

# Backup Configuration
BACKUP_SCHEDULE=0 2 * * *
BACKUP_RETENTION_DAYS=30
BACKUP_STORAGE_PATH=/var/backups/tamgaci
```

### 2. Flutter Production Configuration

#### lib/config/production_config.dart
```dart
class ProductionConfig {
  // Firebase Configuration
  static const String firebaseProjectId = 'tamgaci-prod';
  static const String firebaseApiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  static const String firebaseAuthDomain = 'tamgaci-prod.firebaseapp.com';
  static const String firebaseStorageBucket = 'tamgaci-prod.appspot.com';
  static const String firebaseMessagingSenderId = '123456789012';
  static const String firebaseAppId = '1:123456789012:web:abcdefghijklmnopqrstuvwxyz';
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.tamgaci.com';
  static const int apiTimeout = 30000;
  static const int apiRateLimit = 1000;
  
  // Security Configuration
  static const bool enableHttps = true;
  static const bool enableCors = true;
  static const bool requireAuthentication = true;
  
  // Performance Configuration
  static const bool enableImageOptimization = true;
  static const bool enableCodeSplitting = true;
  static const bool enableCaching = true;
  static const int cacheSize = 100 * 1024 * 1024; // 100MB
  
  // Monitoring Configuration
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;
  static const String sentryDsn = 'https://your-sentry-dsn@sentry.io/project-id';
  
  // Logging Configuration
  static const String logLevel = 'error';
  static const bool enableLogging = true;
  static const bool enableRemoteLogging = true;
  
  // Feature Flags
  static const bool enableNewFeatures = false;
  static const bool enableBetaFeatures = false;
  static const bool enableDebugMode = false;
  
  // Backup Configuration
  static const bool enableAutoBackup = true;
  static const String backupSchedule = '0 2 * * *';
  static const int backupRetentionDays = 30;
}
```

### 3. Build Configuration

#### android/app/build.gradle (Production)
```gradle
android {
    compileSdkVersion 34
    ndkVersion "25.1.8937393"

    defaultConfig {
        applicationId "com.tamgaci.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        
        multiDexEnabled true
        
        // Production configuration
        buildConfigField "String", "API_BASE_URL", "\"https://api.tamgaci.com\""
        buildConfigField "boolean", "ENABLE_ANALYTICS", "true"
        buildConfigField "boolean", "ENABLE_CRASHLYTICS", "true"
        buildConfigField "boolean", "ENABLE_DEBUG", "false"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            // Production optimizations
            debuggable false
            jniDebuggable false
            renderscriptDebuggable false
            zipAlignEnabled true
        }
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

#### ios/Runner/Info.plist (Production)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>Tamgaci</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>tamgaci</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    
    <!-- Production Configuration -->
    <key>API_BASE_URL</key>
    <string>https://api.tamgaci.com</string>
    <key>ENABLE_ANALYTICS</key>
    <true/>
    <key>ENABLE_CRASHLYTICS</key>
    <true/>
    <key>ENABLE_DEBUG</key>
    <false/>
</dict>
</plist>
```

## 🔒 Security Configuration

### 1. Firebase Security Rules

#### Firestore Security Rules (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar sadece kendi verilerine erişebilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Müşteriler - sadece authenticated kullanıcılar
    match /customers/{customerId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Ürünler - sadece authenticated kullanıcılar
    match /products/{productId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Satışlar - sadece authenticated kullanıcılar
    match /sales/{saleId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Alışlar - sadece authenticated kullanıcılar
    match /purchases/{purchaseId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // İşlemler - sadece authenticated kullanıcılar
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Diğer koleksiyonlar için benzer kurallar
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage Security Rules (Production)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Kullanıcılar sadece kendi dosyalarına erişebilir
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Genel dosyalar - sadece authenticated kullanıcılar
    match /public/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Geçici dosyalar - sadece authenticated kullanıcılar
    match /temp/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
    
    // Yedek dosyalar - sadece authenticated kullanıcılar
    match /backups/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 2. HTTPS Configuration

#### Firebase Hosting HTTPS
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Strict-Transport-Security",
            "value": "max-age=31536000; includeSubDomains"
          },
          {
            "key": "X-Content-Type-Options",
            "value": "nosniff"
          },
          {
            "key": "X-Frame-Options",
            "value": "DENY"
          },
          {
            "key": "X-XSS-Protection",
            "value": "1; mode=block"
          }
        ]
      }
    ]
  }
}
```

### 3. CORS Configuration

#### CORS Policy
```dart
// lib/config/cors_config.dart
class CorsConfig {
  static const List<String> allowedOrigins = [
    'https://tamgaci.com',
    'https://www.tamgaci.com',
    'https://app.tamgaci.com',
  ];
  
  static const List<String> allowedMethods = [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'OPTIONS',
  ];
  
  static const List<String> allowedHeaders = [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'Accept',
    'Origin',
  ];
  
  static const bool allowCredentials = true;
  static const int maxAge = 86400; // 24 hours
}
```

## ⚡ Performance Optimization

### 1. Image Optimization

#### Image Compression
```dart
// lib/services/image_optimization_service.dart
class ImageOptimizationService {
  static const int maxImageSize = 1920;
  static const int maxThumbnailSize = 300;
  static const int compressionQuality = 85;
  
  static Future<Uint8List> optimizeImage(Uint8List imageData) async {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;
    
    // Resize if too large
    if (image.width > maxImageSize || image.height > maxImageSize) {
      final resized = img.copyResize(
        image,
        width: maxImageSize,
        height: maxImageSize,
        interpolation: img.Interpolation.average,
      );
      return Uint8List.fromList(img.encodeJpg(resized, quality: compressionQuality));
    }
    
    // Compress
    return Uint8List.fromList(img.encodeJpg(image, quality: compressionQuality));
  }
  
  static Future<Uint8List> createThumbnail(Uint8List imageData) async {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;
    
    final thumbnail = img.copyResize(
      image,
      width: maxThumbnailSize,
      height: maxThumbnailSize,
      interpolation: img.Interpolation.average,
    );
    
    return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 70));
  }
}
```

### 2. Caching Strategy

#### Cache Configuration
```dart
// lib/config/cache_config.dart
class CacheConfig {
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxCacheItems = 1000;
  static const Duration defaultExpiry = Duration(hours: 1);
  static const Duration longExpiry = Duration(days: 7);
  static const Duration shortExpiry = Duration(minutes: 15);
  
  // Cache keys
  static const String customersKey = 'customers';
  static const String productsKey = 'products';
  static const String salesKey = 'sales';
  static const String purchasesKey = 'purchases';
  static const String dashboardKey = 'dashboard';
  
  // Cache expiry times
  static const Map<String, Duration> cacheExpiry = {
    customersKey: Duration(hours: 2),
    productsKey: Duration(hours: 1),
    salesKey: Duration(minutes: 30),
    purchasesKey: Duration(minutes: 30),
    dashboardKey: Duration(minutes: 15),
  };
}
```

### 3. Database Optimization

#### Firestore Indexes
```json
{
  "indexes": [
    {
      "collectionGroup": "customers",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "name",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "products",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "category",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "name",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "sales",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "customerId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

## 📊 Monitoring Setup

### 1. Error Tracking

#### Sentry Configuration
```dart
// lib/services/sentry_service.dart
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static const String dsn = 'https://your-sentry-dsn@sentry.io/project-id';
  
  static Future<void> initialize() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.environment = 'production';
        options.release = '1.0.0';
        options.tracesSampleRate = 0.1;
        options.profilesSampleRate = 0.1;
      },
      appRunner: () => runApp(MyApp()),
    );
  }
  
  static Future<void> captureException(dynamic exception, StackTrace? stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }
  
  static Future<void> captureMessage(String message) async {
    await Sentry.captureMessage(message);
  }
  
  static Future<void> setUser(String userId, String email) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId, email: email));
    });
  }
}
```

### 2. Performance Monitoring

#### Firebase Performance
```dart
// lib/services/performance_service.dart
import 'package:firebase_performance/firebase_performance.dart';

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
  
  static Future<void> incrementCounter(Trace trace, String counterName) async {
    await trace.incrementCounter(counterName);
  }
  
  static Future<void> setMetric(Trace trace, String metricName, int value) async {
    await trace.setMetric(metricName, value);
  }
  
  // Custom metrics
  static Future<void> trackPageLoad(String pageName) async {
    final trace = await startTrace('page_load_$pageName');
    await stopTrace(trace);
  }
  
  static Future<void> trackApiCall(String endpoint, Duration duration) async {
    final trace = await startTrace('api_call_$endpoint');
    await setMetric(trace, 'duration_ms', duration.inMilliseconds);
    await stopTrace(trace);
  }
}
```

### 3. Analytics

#### Firebase Analytics
```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }
  
  static Future<void> logPurchase(double value, String currency, String itemId) async {
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      parameters: {'item_id': itemId},
    );
  }
  
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
  
  // Custom events
  static Future<void> trackCustomerCreated() async {
    await logEvent('customer_created', {});
  }
  
  static Future<void> trackProductCreated() async {
    await logEvent('product_created', {});
  }
  
  static Future<void> trackSaleCompleted(double amount) async {
    await logEvent('sale_completed', {'amount': amount});
  }
}
```

## 💾 Backup Strategy

### 1. Automated Backup

#### Backup Script
```bash
#!/bin/bash

# Backup script for Tamgaci production data
set -e

BACKUP_DIR="/var/backups/tamgaci"
DATE=$(date +%Y%m%d_%H%M%S)
PROJECT_ID="tamgaci-prod"

echo "Starting backup process..."

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup Firestore
echo "Backing up Firestore..."
gcloud firestore export gs://$PROJECT_ID-backups/firestore/$DATE \
  --project=$PROJECT_ID

# Backup Storage
echo "Backing up Storage..."
gsutil -m cp -r gs://$PROJECT_ID.appspot.com gs://$PROJECT_ID-backups/storage/$DATE

# Backup configuration
echo "Backing up configuration..."
firebase projects:list > $BACKUP_DIR/config_$DATE.txt
firebase firestore:indexes > $BACKUP_DIR/indexes_$DATE.json
firebase firestore:rules:get > $BACKUP_DIR/rules_$DATE.txt

# Cleanup old backups (keep 30 days)
echo "Cleaning up old backups..."
find $BACKUP_DIR -name "*.txt" -mtime +30 -delete
find $BACKUP_DIR -name "*.json" -mtime +30 -delete

echo "Backup completed successfully!"
```

### 2. Manual Backup

#### Export Data
```bash
# Export Firestore data
gcloud firestore export gs://tamgaci-prod-backups/manual/$(date +%Y%m%d_%H%M%S) \
  --project=tamgaci-prod

# Export Storage data
gsutil -m cp -r gs://tamgaci-prod.appspot.com gs://tamgaci-prod-backups/storage/manual/$(date +%Y%m%d_%H%M%S)

# Export configuration
firebase firestore:indexes > firestore_indexes_$(date +%Y%m%d_%H%M%S).json
firebase firestore:rules:get > firestore_rules_$(date +%Y%m%d_%H%M%S).txt
```

### 3. Restore Process

#### Restore Data
```bash
# Restore Firestore data
gcloud firestore import gs://tamgaci-prod-backups/firestore/20240101_120000 \
  --project=tamgaci-prod

# Restore Storage data
gsutil -m cp -r gs://tamgaci-prod-backups/storage/20240101_120000 gs://tamgaci-prod.appspot.com

# Restore configuration
firebase firestore:rules:set firestore_rules_20240101_120000.txt
firebase firestore:indexes:set firestore_indexes_20240101_120000.json
```

## 🚀 Deployment Process

### 1. Pre-Deployment

```bash
# 1. Code review and testing
flutter test
flutter analyze
flutter test integration_test/

# 2. Build verification
flutter build web --release
flutter build apk --release
flutter build appbundle --release

# 3. Security check
firebase firestore:rules:test
firebase storage:rules:test

# 4. Backup current data
./backup.sh
```

### 2. Deployment

```bash
# 1. Deploy to staging first
firebase use staging
firebase deploy

# 2. Test staging environment
# Run smoke tests
# Verify functionality
# Check performance

# 3. Deploy to production
firebase use production
firebase deploy

# 4. Verify production deployment
# Check application accessibility
# Verify database connectivity
# Test authentication
# Check file uploads
```

### 3. Post-Deployment

```bash
# 1. Health checks
curl -f https://tamgaci.com/health
curl -f https://api.tamgaci.com/health

# 2. Performance monitoring
# Check response times
# Monitor error rates
# Verify analytics

# 3. User acceptance testing
# Test critical user flows
# Verify data integrity
# Check email notifications
```

## 🔍 Post-Deployment

### 1. Health Monitoring

#### Health Check Endpoint
```dart
// lib/services/health_check_service.dart
class HealthCheckService {
  static Future<Map<String, dynamic>> performHealthCheck() async {
    final healthStatus = <String, dynamic>{};
    
    try {
      // Check Firebase connection
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('health').doc('check').get();
      healthStatus['firestore'] = 'healthy';
    } catch (e) {
      healthStatus['firestore'] = 'unhealthy: $e';
    }
    
    try {
      // Check Storage connection
      final storage = FirebaseStorage.instance;
      await storage.ref('health/check.txt').getDownloadURL();
      healthStatus['storage'] = 'healthy';
    } catch (e) {
      healthStatus['storage'] = 'unhealthy: $e';
    }
    
    try {
      // Check Authentication
      final auth = FirebaseAuth.instance;
      await auth.signInAnonymously();
      await auth.signOut();
      healthStatus['auth'] = 'healthy';
    } catch (e) {
      healthStatus['auth'] = 'unhealthy: $e';
    }
    
    return healthStatus;
  }
}
```

### 2. Performance Monitoring

#### Performance Metrics
```dart
// lib/services/performance_monitor.dart
class PerformanceMonitor {
  static final Map<String, List<Duration>> _metrics = {};
  
  static void recordMetric(String name, Duration duration) {
    _metrics[name] ??= [];
    _metrics[name]!.add(duration);
    
    // Keep only last 100 measurements
    if (_metrics[name]!.length > 100) {
      _metrics[name]!.removeAt(0);
    }
  }
  
  static double getAverageMetric(String name) {
    final durations = _metrics[name];
    if (durations == null || durations.isEmpty) return 0.0;
    
    final total = durations.fold(0, (sum, duration) => sum + duration.inMilliseconds);
    return total / durations.length;
  }
  
  static Map<String, double> getAllMetrics() {
    final result = <String, double>{};
    for (final name in _metrics.keys) {
      result[name] = getAverageMetric(name);
    }
    return result;
  }
}
```

### 3. Error Monitoring

#### Error Tracking
```dart
// lib/services/error_monitor.dart
class ErrorMonitor {
  static final List<ErrorReport> _errors = [];
  
  static void recordError(dynamic error, StackTrace? stackTrace, {String? context}) {
    final errorReport = ErrorReport(
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
      timestamp: DateTime.now(),
    );
    
    _errors.add(errorReport);
    
    // Send to monitoring service
    SentryService.captureException(error, stackTrace);
    
    // Keep only last 100 errors
    if (_errors.length > 100) {
      _errors.removeAt(0);
    }
  }
  
  static List<ErrorReport> getRecentErrors({int count = 10}) {
    final sortedErrors = List<ErrorReport>.from(_errors);
    sortedErrors.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedErrors.take(count).toList();
  }
}

class ErrorReport {
  final String error;
  final String? stackTrace;
  final String? context;
  final DateTime timestamp;
  
  ErrorReport({
    required this.error,
    this.stackTrace,
    this.context,
    required this.timestamp,
  });
}
```

## 📚 Additional Resources

### Documentation
- [Firebase Production Guide](https://firebase.google.com/docs/production)
- [Flutter Production Guide](https://docs.flutter.dev/deployment)
- [Security Best Practices](https://firebase.google.com/docs/security)
- [Performance Optimization](https://firebase.google.com/docs/perf-mon)

### Tools
- [Firebase Console](https://console.firebase.google.com/)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Sentry](https://sentry.io/)
- [Firebase Performance](https://firebase.google.com/docs/perf-mon)

### Support
- [Firebase Support](https://firebase.google.com/support)
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase)
- [GitHub Issues](https://github.com/firebase/firebase-tools/issues)
