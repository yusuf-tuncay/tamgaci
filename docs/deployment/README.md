# Tamgaci Deployment Kılavuzu

Bu kılavuz, Tamgaci uygulamasının production ortamına deploy edilmesi için gerekli adımları içerir.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Ön Gereksinimler](#ön-gereksinimler)
- [Firebase Configuration](#firebase-configuration)
- [PayTR Entegrasyonu](#paytr-entegrasyonu)
- [Build Configuration](#build-configuration)
- [Deployment Strategies](#deployment-strategies)
- [Environment Setup](#environment-setup)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## 🔍 Genel Bakış

Tamgaci, Flutter tabanlı bir ön muhasebe uygulamasıdır ve aşağıdaki platformlarda deploy edilebilir:

- **Web**: Firebase Hosting
- **Android**: Google Play Store
- **iOS**: Apple App Store
- **Desktop**: Windows, macOS, Linux

### Deployment Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Firebase      │    │   External      │
│                 │    │   Services      │    │   Services      │
│ • Web           │◄──►│ • Firestore     │    │ • Google Play   │
│ • Mobile        │    │ • Auth          │    │ • App Store     │
│ • Desktop       │    │ • Storage       │    │ • Analytics     │
└─────────────────┘    │ • Functions     │    │ • Crashlytics   │
                       │ • Hosting       │    └─────────────────┘
                       └─────────────────┘
```

## 📋 Ön Gereksinimler

### Geliştirme Ortamı

1. **Flutter SDK**
   ```bash
   # Flutter SDK kurulumu
   flutter --version  # 3.0.0 veya üzeri
   ```

2. **Dart SDK**
   ```bash
   # Dart SDK kurulumu
   dart --version  # 3.0.0 veya üzeri
   ```

3. **Firebase CLI**
   ```bash
   # Firebase CLI kurulumu
   npm install -g firebase-tools
   firebase --version
   ```

4. **Platform Specific Tools**
   ```bash
   # Android
   android-studio
   
   # iOS
   xcode
   
   # Web
   chrome
   
   # Desktop
   visual-studio-code
   ```

### Gerekli Hesaplar

1. **Firebase Console**
   - Google hesabı
   - Firebase projesi
   - Billing hesabı (production için)

2. **App Store Accounts**
   - Google Play Console (Android)
   - Apple Developer (iOS)

3. **CI/CD Services**
   - GitHub Actions
   - GitLab CI
   - Azure DevOps

## 🔥 Firebase Configuration

### 1. Firebase Projesi Oluşturma

```bash
# Firebase CLI ile giriş
firebase login

# Yeni proje oluşturma
firebase projects:create tamgaci-prod

# Proje seçme
firebase use tamgaci-prod
```

### 2. Firebase Services Kurulumu

#### Firestore Database
```bash
# Firestore kurulumu
firebase init firestore

# Security rules
firestore.rules:
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar sadece kendi verilerine erişebilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Müşteriler
    match /customers/{customerId} {
      allow read, write: if request.auth != null;
    }
    
    // Ürünler
    match /products/{productId} {
      allow read, write: if request.auth != null;
    }
    
    // Satışlar
    match /sales/{saleId} {
      allow read, write: if request.auth != null;
    }
    
    // Alışlar
    match /purchases/{purchaseId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Authentication
```bash
# Authentication kurulumu
firebase init auth

# Authentication providers
- Email/Password
- Google
- Apple (iOS için)
```

#### Storage
```bash
# Storage kurulumu
firebase init storage

# Storage rules
storage.rules:
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Hosting (Web için)
```bash
# Hosting kurulumu
firebase init hosting

# firebase.json
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
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### 3. Firebase Configuration Files

#### firebase_options.dart
```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'tamgaci-prod',
    authDomain: 'tamgaci-prod.firebaseapp.com',
    storageBucket: 'tamgaci-prod.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'tamgaci-prod',
    storageBucket: 'tamgaci-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'tamgaci-prod',
    storageBucket: 'tamgaci-prod.appspot.com',
    iosBundleId: 'com.tamgaci.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'tamgaci-prod',
    storageBucket: 'tamgaci-prod.appspot.com',
    iosBundleId: 'com.tamgaci.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key',
    appId: 'your-windows-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'tamgaci-prod',
    storageBucket: 'tamgaci-prod.appspot.com',
  );
}
```

## 💳 PayTR Entegrasyonu

### PayTR Konfigürasyonu

PayTR ödeme sistemi entegrasyonu için gerekli konfigürasyon:

```bash
# Firebase Functions config
firebase functions:config:set paytr.merchant_id="622887"
firebase functions:config:set paytr.merchant_key="uePB6f7AfxtAAyqZ"
firebase functions:config:set paytr.merchant_salt="ejdEC3ReZay7QxE8"
firebase functions:config:set paytr.callback_url="https://us-central1-tamgaci.cloudfunctions.net/paytrCallback"
firebase functions:config:set paytr.test_mode="1"
```

### PayTR Panel Ayarları

PayTR panelinde şu URL'ler ayarlanmalıdır:

```
Bildirim URL (Callback URL): https://us-central1-tamgaci.cloudfunctions.net/paytrCallback
Site Adresi: https://tamgaci.online/
```

### Hash Verification

PayTR resmi dökümantasyonuna göre hash doğrulaması:

```typescript
// PayTR RESMİ DÖKÜMANTASYONUNA GÖRE
const hash_str = merchant_oid + merchant_salt + status + total_amount;
const hash = crypto.createHmac('sha256', merchant_key).update(hash_str).digest('base64');
```

### Detaylı Dökümantasyon

- [PayTR Entegrasyon Rehberi](paytr_integration_guide.md)
- [PayTR Hızlı Referans](paytr_quick_reference.md)
- [PayTR Konfigürasyon](paytr_config.md)

## 🔧 Build Configuration

### 1. Flutter Build Configuration

#### pubspec.yaml
```yaml
name: tamgaci
description: Ön Muhasebe Uygulaması
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_messaging: ^14.7.10
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # UI
  cupertino_icons: ^1.0.2
  material_design_icons_flutter: ^7.0.7296
  
  # Utils
  intl: ^0.19.0
  uuid: ^4.2.1
  shared_preferences: ^2.2.2
  
  # Export
  excel: ^4.0.6
  pdf: ^3.10.7
  path_provider: ^2.1.1
  
  # Image
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  
  # Network
  dio: ^5.4.0
  
  # Validation
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code Generation
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

#### android/app/build.gradle
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
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
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

#### ios/Runner/Info.plist
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
</dict>
</plist>
```

### 2. Build Scripts

#### build.sh
```bash
#!/bin/bash

# Build script for Tamgaci
set -e

echo "🚀 Starting Tamgaci build process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Generate code
echo "🔧 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests
echo "🧪 Running tests..."
flutter test

# Build for different platforms
echo "📱 Building for Android..."
flutter build apk --release

echo "🍎 Building for iOS..."
flutter build ios --release

echo "🌐 Building for Web..."
flutter build web --release

echo "🖥️ Building for Windows..."
flutter build windows --release

echo "🐧 Building for Linux..."
flutter build linux --release

echo "🍎 Building for macOS..."
flutter build macos --release

echo "✅ Build process completed successfully!"
```

#### build.bat (Windows)
```batch
@echo off
echo 🚀 Starting Tamgaci build process...

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean
flutter pub get

REM Generate code
echo 🔧 Generating code...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Run tests
echo 🧪 Running tests...
flutter test

REM Build for different platforms
echo 📱 Building for Android...
flutter build apk --release

echo 🌐 Building for Web...
flutter build web --release

echo 🖥️ Building for Windows...
flutter build windows --release

echo ✅ Build process completed successfully!
pause
```

## 🚀 Deployment Strategies

### 1. Web Deployment (Firebase Hosting)

```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Deploy with specific project
firebase deploy --only hosting --project tamgaci-prod
```

### 2. Android Deployment

#### Google Play Store
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended)
flutter build appbundle --release

# Upload to Play Console
# Use Google Play Console web interface
```

#### APK Distribution
```bash
# Build APK for distribution
flutter build apk --release --split-per-abi

# APK files will be in:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### 3. iOS Deployment

#### App Store
```bash
# Build for iOS
flutter build ios --release

# Archive and upload using Xcode
# 1. Open ios/Runner.xcworkspace in Xcode
# 2. Select "Any iOS Device" as target
# 3. Product > Archive
# 4. Distribute App > App Store Connect
```

#### TestFlight
```bash
# Build for TestFlight
flutter build ios --release

# Upload to TestFlight using Xcode
# 1. Archive in Xcode
# 2. Distribute App > TestFlight
```

### 4. Desktop Deployment

#### Windows
```bash
# Build for Windows
flutter build windows --release

# Create installer
# Use tools like Inno Setup or NSIS
```

#### macOS
```bash
# Build for macOS
flutter build macos --release

# Create DMG
# Use tools like create-dmg
```

#### Linux
```bash
# Build for Linux
flutter build linux --release

# Create AppImage or DEB package
# Use tools like linuxdeploy
```

## 🌍 Environment Setup

### 1. Development Environment

#### .env.development
```env
# Development Environment
ENVIRONMENT=development
FIREBASE_PROJECT_ID=tamgaci-dev
FIREBASE_API_KEY=dev-api-key
FIREBASE_AUTH_DOMAIN=tamgaci-dev.firebaseapp.com
FIREBASE_STORAGE_BUCKET=tamgaci-dev.appspot.com
FIREBASE_MESSAGING_SENDER_ID=dev-sender-id
FIREBASE_APP_ID=dev-app-id

# API Configuration
API_BASE_URL=https://api-dev.tamgaci.com
API_TIMEOUT=30000

# Logging
LOG_LEVEL=debug
ENABLE_LOGGING=true

# Features
ENABLE_ANALYTICS=false
ENABLE_CRASHLYTICS=false
ENABLE_PERFORMANCE_MONITORING=false
```

### 2. Staging Environment

#### .env.staging
```env
# Staging Environment
ENVIRONMENT=staging
FIREBASE_PROJECT_ID=tamgaci-staging
FIREBASE_API_KEY=staging-api-key
FIREBASE_AUTH_DOMAIN=tamgaci-staging.firebaseapp.com
FIREBASE_STORAGE_BUCKET=tamgaci-staging.appspot.com
FIREBASE_MESSAGING_SENDER_ID=staging-sender-id
FIREBASE_APP_ID=staging-app-id

# API Configuration
API_BASE_URL=https://api-staging.tamgaci.com
API_TIMEOUT=30000

# Logging
LOG_LEVEL=info
ENABLE_LOGGING=true

# Features
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
ENABLE_PERFORMANCE_MONITORING=true
```

### 3. Production Environment

#### .env.production
```env
# Production Environment
ENVIRONMENT=production
FIREBASE_PROJECT_ID=tamgaci-prod
FIREBASE_API_KEY=prod-api-key
FIREBASE_AUTH_DOMAIN=tamgaci-prod.firebaseapp.com
FIREBASE_STORAGE_BUCKET=tamgaci-prod.appspot.com
FIREBASE_MESSAGING_SENDER_ID=prod-sender-id
FIREBASE_APP_ID=prod-app-id

# API Configuration
API_BASE_URL=https://api.tamgaci.com
API_TIMEOUT=30000

# Logging
LOG_LEVEL=error
ENABLE_LOGGING=true

# Features
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
ENABLE_PERFORMANCE_MONITORING=true
```

### 4. Environment Configuration

#### lib/config/environment.dart
```dart
class Environment {
  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  static String get environment => _environment;
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
  
  static String get firebaseProjectId {
    switch (_environment) {
      case 'development':
        return 'tamgaci-dev';
      case 'staging':
        return 'tamgaci-staging';
      case 'production':
        return 'tamgaci-prod';
      default:
        return 'tamgaci-dev';
    }
  }
  
  static String get apiBaseUrl {
    switch (_environment) {
      case 'development':
        return 'https://api-dev.tamgaci.com';
      case 'staging':
        return 'https://api-staging.tamgaci.com';
      case 'production':
        return 'https://api.tamgaci.com';
      default:
        return 'https://api-dev.tamgaci.com';
    }
  }
  
  static bool get enableLogging {
    switch (_environment) {
      case 'development':
        return true;
      case 'staging':
        return true;
      case 'production':
        return false;
      default:
        return true;
    }
  }
  
  static bool get enableAnalytics {
    switch (_environment) {
      case 'development':
        return false;
      case 'staging':
        return true;
      case 'production':
        return true;
      default:
        return false;
    }
  }
}
```

## 🔄 CI/CD Pipeline

### 1. GitHub Actions

#### .github/workflows/build.yml
```yaml
name: Build and Deploy

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
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
    
    - name: Run tests
      run: flutter test
    
    - name: Run integration tests
      run: flutter test integration_test/
    
    - name: Analyze code
      run: flutter analyze

  build-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
    
    - name: Build web
      run: flutter build web --release
    
    - name: Deploy to Firebase Hosting
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        channelId: live
        projectId: tamgaci-prod

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Build App Bundle
      run: flutter build appbundle --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: apk
        path: build/app/outputs/flutter-apk/app-release.apk
    
    - name: Upload App Bundle
      uses: actions/upload-artifact@v3
      with:
        name: app-bundle
        path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
    
    - name: Upload iOS build
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app
```

### 2. GitLab CI

#### .gitlab-ci.yml
```yaml
stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.16.0"

test:
  stage: test
  image: cirrusci/flutter:3.16.0
  script:
    - flutter pub get
    - flutter packages pub run build_runner build --delete-conflicting-outputs
    - flutter test
    - flutter analyze
  only:
    - merge_requests
    - main

build-web:
  stage: build
  image: cirrusci/flutter:3.16.0
  script:
    - flutter pub get
    - flutter packages pub run build_runner build --delete-conflicting-outputs
    - flutter build web --release
  artifacts:
    paths:
      - build/web/
    expire_in: 1 hour
  only:
    - main

build-android:
  stage: build
  image: cirrusci/flutter:3.16.0
  script:
    - flutter pub get
    - flutter packages pub run build_runner build --delete-conflicting-outputs
    - flutter build apk --release
    - flutter build appbundle --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk
      - build/app/outputs/bundle/release/app-release.aab
    expire_in: 1 hour
  only:
    - main

deploy-web:
  stage: deploy
  image: node:16
  script:
    - npm install -g firebase-tools
    - firebase deploy --only hosting --token $FIREBASE_TOKEN
  dependencies:
    - build-web
  only:
    - main
```

### 3. Azure DevOps

#### azure-pipelines.yml
```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  flutterVersion: '3.16.0'

stages:
- stage: Test
  displayName: 'Test Stage'
  jobs:
  - job: Test
    displayName: 'Run Tests'
    steps:
    - task: FlutterInstall@0
      inputs:
        channel: 'stable'
        version: '3.16.0'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'pub get'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'packages pub run build_runner build --delete-conflicting-outputs'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'test'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'analyze'

- stage: Build
  displayName: 'Build Stage'
  dependsOn: Test
  condition: succeeded()
  jobs:
  - job: BuildWeb
    displayName: 'Build Web'
    steps:
    - task: FlutterInstall@0
      inputs:
        channel: 'stable'
        version: '3.16.0'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'pub get'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'packages pub run build_runner build --delete-conflicting-outputs'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'build web --release'
    
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: 'build/web'
        artifactName: 'web-build'

  - job: BuildAndroid
    displayName: 'Build Android'
    steps:
    - task: FlutterInstall@0
      inputs:
        channel: 'stable'
        version: '3.16.0'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'pub get'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'packages pub run build_runner build --delete-conflicting-outputs'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'build apk --release'
    
    - task: FlutterCommand@0
      inputs:
        arguments: 'build appbundle --release'
    
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: 'build/app/outputs/flutter-apk'
        artifactName: 'android-apk'
    
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: 'build/app/outputs/bundle/release'
        artifactName: 'android-bundle'

- stage: Deploy
  displayName: 'Deploy Stage'
  dependsOn: Build
  condition: succeeded()
  jobs:
  - job: DeployWeb
    displayName: 'Deploy Web'
    steps:
    - task: DownloadBuildArtifacts@0
      inputs:
        buildType: 'current'
        artifactName: 'web-build'
        downloadPath: '$(System.ArtifactsDirectory)'
    
    - task: NodeTool@0
      inputs:
        versionSpec: '16.x'
    
    - script: |
        npm install -g firebase-tools
        firebase deploy --only hosting --token $(FIREBASE_TOKEN)
      displayName: 'Deploy to Firebase Hosting'
```

## 📊 Monitoring

### 1. Firebase Analytics

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
}
```

### 2. Firebase Crashlytics

```dart
// lib/services/crashlytics_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  static Future<void> initialize() async {
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  static Future<void> recordError(dynamic error, StackTrace? stackTrace) async {
    await _crashlytics.recordError(error, stackTrace);
  }
  
  static Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }
  
  static Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
}
```

### 3. Performance Monitoring

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
}
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Build Failures

**Problem**: Flutter build fails
**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter build web --release
```

#### 2. Firebase Configuration Issues

**Problem**: Firebase not initialized
**Solution**:
```dart
// Check firebase_options.dart
// Ensure all required fields are filled
// Verify project ID matches Firebase console
```

#### 3. Deployment Failures

**Problem**: Firebase deployment fails
**Solution**:
```bash
# Check Firebase CLI version
firebase --version

# Re-authenticate
firebase logout
firebase login

# Check project selection
firebase use --list
firebase use tamgaci-prod
```

#### 4. Performance Issues

**Problem**: Slow app performance
**Solution**:
```dart
// Enable performance monitoring
// Check for memory leaks
// Optimize image loading
// Use lazy loading for lists
```

### Debug Commands

```bash
# Flutter doctor
flutter doctor -v

# Check dependencies
flutter pub deps

# Analyze code
flutter analyze

# Run tests
flutter test

# Check Firebase status
firebase projects:list
firebase use --list
```

### Log Analysis

```bash
# View Firebase logs
firebase functions:log

# View hosting logs
firebase hosting:channel:open live

# View Firestore logs
firebase firestore:indexes
```

## 📚 Additional Resources

### Documentation
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)
- [Firebase Hosting Guide](https://firebase.google.com/docs/hosting)
- [Google Play Console](https://play.google.com/console)
- [Apple App Store Connect](https://appstoreconnect.apple.com)

### Tools
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Flutter CLI](https://docs.flutter.dev/reference/flutter-cli)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitLab CI](https://docs.gitlab.com/ee/ci/)

### Support
- [Flutter Community](https://flutter.dev/community)
- [Firebase Support](https://firebase.google.com/support)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Issues](https://github.com/flutter/flutter/issues)
