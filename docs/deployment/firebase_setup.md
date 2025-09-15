# Firebase Setup Kılavuzu

Bu kılavuz, Tamgaci uygulaması için Firebase projesinin kurulumunu detaylı olarak açıklar.

## 📋 İçindekiler

- [Firebase Projesi Oluşturma](#firebase-projesi-oluşturma)
- [Firebase Services Kurulumu](#firebase-services-kurulumu)
- [Security Rules](#security-rules)
- [Configuration Files](#configuration-files)
- [Environment Setup](#environment-setup)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## 🔥 Firebase Projesi Oluşturma

### 1. Firebase Console'a Giriş

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. Google hesabınızla giriş yapın
3. "Create a project" butonuna tıklayın

### 2. Proje Oluşturma

1. **Proje Adı**: `tamgaci-prod` (production için)
2. **Proje ID**: `tamgaci-prod` (otomatik oluşturulur)
3. **Google Analytics**: Aktif edin
4. **Analytics Account**: Varsayılan hesabı seçin
5. "Create project" butonuna tıklayın

### 3. Proje Ayarları

1. **Project Settings** > **General** sekmesine gidin
2. **Project ID**: `tamgaci-prod` (not edin)
3. **Web API Key**: (not edin)
4. **Project Number**: (not edin)

## 🛠️ Firebase Services Kurulumu

### 1. Authentication

#### Email/Password Authentication
1. **Authentication** > **Sign-in method** sekmesine gidin
2. **Email/Password** seçeneğini aktif edin
3. **Enable** butonuna tıklayın

#### Google Authentication
1. **Google** seçeneğini aktif edin
2. **Project support email** seçin
3. **Web SDK configuration** bölümünden:
   - **Web client ID**: (not edin)
   - **Web client secret**: (not edin)

#### Apple Authentication (iOS için)
1. **Apple** seçeneğini aktif edin
2. **Services ID** oluşturun
3. **Key ID** ve **Team ID** girin

### 2. Firestore Database

#### Database Oluşturma
1. **Firestore Database** > **Create database** butonuna tıklayın
2. **Start in test mode** seçin (güvenlik kuralları sonra ayarlanacak)
3. **Location** seçin: `europe-west1` (Türkiye'ye en yakın)
4. **Done** butonuna tıklayın

#### Collections Oluşturma
```javascript
// Firestore Collections
users/
  {userId}/
    profile: { name, email, phone, ... }
    settings: { theme, language, ... }

customers/
  {customerId}/
    name: string
    email: string
    phone: string
    address: string
    balance: number
    creditLimit: number
    category: string
    createdAt: timestamp
    updatedAt: timestamp
    createdBy: string

suppliers/
  {supplierId}/
    name: string
    email: string
    phone: string
    address: string
    balance: number
    creditLimit: number
    category: string
    createdAt: timestamp
    updatedAt: timestamp
    createdBy: string

products/
  {productId}/
    code: string
    name: string
    description: string
    category: string
    unit: string
    purchasePrice: number
    salePrice: number
    stock: number
    minStock: number
    vatRate: number
    createdAt: timestamp
    updatedAt: timestamp
    createdBy: string

sales/
  {saleId}/
    customerId: string
    customerName: string
    total: number
    discount: number
    vat: number
    status: string
    items: array
    createdAt: timestamp
    updatedAt: timestamp
    createdBy: string

purchases/
  {purchaseId}/
    supplierId: string
    supplierName: string
    total: number
    discount: number
    vat: number
    status: string
    items: array
    createdAt: timestamp
    updatedAt: timestamp
    createdBy: string

transactions/
  {transactionId}/
    type: string
    customerId: string
    amount: number
    description: string
    balance: number
    createdAt: timestamp
    createdBy: string

accounts/
  {accountId}/
    name: string
    type: string
    balance: number
    currency: string
    createdAt: timestamp
    updatedAt: timestamp
    createdBy: string

employees/
  {employeeId}/
    name: string
    email: string
    phone: string
    position: string
    salary: number
    startDate: timestamp
    createdAt: timestamp
    updatedAt: timestamp
    createdBy: string

expenses/
  {expenseId}/
    category: string
    amount: number
    description: string
    date: timestamp
    accountId: string
    createdAt: timestamp
    createdBy: string

loans/
  {loanId}/
    bank: string
    amount: number
    interestRate: number
    term: number
    startDate: timestamp
    endDate: timestamp
    status: string
    createdAt: timestamp
    createdBy: string

projects/
  {projectId}/
    name: string
    description: string
    startDate: timestamp
    endDate: timestamp
    budget: number
    status: string
    createdAt: timestamp
    createdBy: string

cheques/
  {chequeId}/
    type: string
    bank: string
    accountNumber: string
    chequeNumber: string
    amount: number
    dueDate: timestamp
    status: string
    createdAt: timestamp
    createdBy: string

notes/
  {noteId}/
    type: string
    customerId: string
    amount: number
    dueDate: timestamp
    status: string
    createdAt: timestamp
    createdBy: string
```

### 3. Storage

#### Storage Oluşturma
1. **Storage** > **Get started** butonuna tıklayın
2. **Start in test mode** seçin
3. **Location** seçin: `europe-west1`
4. **Done** butonuna tıklayın

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Kullanıcılar sadece kendi dosyalarına erişebilir
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Genel dosyalar (ürün resimleri, belgeler)
    match /public/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Geçici dosyalar
    match /temp/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Hosting (Web için)

#### Hosting Kurulumu
1. **Hosting** > **Get started** butonuna tıklayın
2. **Continue** butonuna tıklayın
3. **Continue** butonuna tıklayın

#### Hosting Configuration
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

### 5. Functions (Opsiyonel)

#### Functions Kurulumu
1. **Functions** > **Get started** butonuna tıklayın
2. **Continue** butonuna tıklayın
3. **Continue** butonuna tıklayın

#### Functions Configuration
```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Müşteri bakiyesi güncelleme
exports.updateCustomerBalance = functions.firestore
  .document('transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const customerId = transaction.customerId;
    const amount = transaction.amount;
    
    const customerRef = admin.firestore().collection('customers').doc(customerId);
    await customerRef.update({
      balance: admin.firestore.FieldValue.increment(amount),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  });

// Stok güncelleme
exports.updateStock = functions.firestore
  .document('sales/{saleId}')
  .onCreate(async (snap, context) => {
    const sale = snap.data();
    const items = sale.items;
    
    for (const item of items) {
      const productRef = admin.firestore().collection('products').doc(item.productId);
      await productRef.update({
        stock: admin.firestore.FieldValue.increment(-item.quantity),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });
```

## 🔒 Security Rules

### 1. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar sadece kendi verilerine erişebilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Müşteriler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /customers/{customerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Tedarikçiler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /suppliers/{supplierId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Ürünler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Satışlar - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /sales/{saleId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Alışlar - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /purchases/{purchaseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // İşlemler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /transactions/{transactionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Hesaplar - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /accounts/{accountId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Personeller - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /employees/{employeeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Giderler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /expenses/{expenseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Krediler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /loans/{loanId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Projeler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /projects/{projectId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Çekler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /cheques/{chequeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
    
    // Senetler - tüm kullanıcılar okuyabilir, sadece sahibi yazabilir
    match /notes/{noteId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.createdBy == request.auth.uid);
    }
  }
}
```

### 2. Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Kullanıcılar sadece kendi dosyalarına erişebilir
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Genel dosyalar (ürün resimleri, belgeler)
    match /public/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Geçici dosyalar
    match /temp/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
    
    // Yedek dosyalar
    match /backups/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## ⚙️ Configuration Files

### 1. firebase.json

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
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
  },
  "functions": {
    "source": "functions",
    "runtime": "nodejs18"
  }
}
```

### 2. firestore.indexes.json

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
    },
    {
      "collectionGroup": "purchases",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "supplierId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "transactions",
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
  ],
  "fieldOverrides": []
}
```

### 3. .firebaserc

```json
{
  "projects": {
    "default": "tamgaci-prod",
    "development": "tamgaci-dev",
    "staging": "tamgaci-staging",
    "production": "tamgaci-prod"
  }
}
```

## 🌍 Environment Setup

### 1. Development Environment

```bash
# Development Firebase projesi
firebase use development

# Development configuration
export FIREBASE_PROJECT_ID=tamgaci-dev
export FIREBASE_API_KEY=dev-api-key
export FIREBASE_AUTH_DOMAIN=tamgaci-dev.firebaseapp.com
export FIREBASE_STORAGE_BUCKET=tamgaci-dev.appspot.com
export FIREBASE_MESSAGING_SENDER_ID=dev-sender-id
export FIREBASE_APP_ID=dev-app-id
```

### 2. Staging Environment

```bash
# Staging Firebase projesi
firebase use staging

# Staging configuration
export FIREBASE_PROJECT_ID=tamgaci-staging
export FIREBASE_API_KEY=staging-api-key
export FIREBASE_AUTH_DOMAIN=tamgaci-staging.firebaseapp.com
export FIREBASE_STORAGE_BUCKET=tamgaci-staging.appspot.com
export FIREBASE_MESSAGING_SENDER_ID=staging-sender-id
export FIREBASE_APP_ID=staging-app-id
```

### 3. Production Environment

```bash
# Production Firebase projesi
firebase use production

# Production configuration
export FIREBASE_PROJECT_ID=tamgaci-prod
export FIREBASE_API_KEY=prod-api-key
export FIREBASE_AUTH_DOMAIN=tamgaci-prod.firebaseapp.com
export FIREBASE_STORAGE_BUCKET=tamgaci-prod.appspot.com
export FIREBASE_MESSAGING_SENDER_ID=prod-sender-id
export FIREBASE_APP_ID=prod-app-id
```

## 🧪 Testing

### 1. Firebase Emulator

```bash
# Emulator kurulumu
firebase init emulators

# Emulator başlatma
firebase emulators:start

# Emulator test
firebase emulators:exec --only firestore,storage "flutter test"
```

### 2. Security Rules Test

```bash
# Security rules test
firebase emulators:exec --only firestore "firebase firestore:rules:test"
```

### 3. Functions Test

```bash
# Functions test
firebase emulators:exec --only functions "npm test"
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Firebase Project Not Found

**Problem**: Firebase projesi bulunamıyor
**Solution**:
```bash
# Proje listesini kontrol et
firebase projects:list

# Proje seç
firebase use tamgaci-prod

# Proje durumunu kontrol et
firebase use --list
```

#### 2. Authentication Issues

**Problem**: Authentication çalışmıyor
**Solution**:
```bash
# Firebase CLI ile giriş
firebase login

# Proje seçimi
firebase use tamgaci-prod

# Authentication durumunu kontrol et
firebase auth:export users.json
```

#### 3. Firestore Connection Issues

**Problem**: Firestore bağlantı sorunu
**Solution**:
```bash
# Firestore durumunu kontrol et
firebase firestore:indexes

# Security rules'ları kontrol et
firebase firestore:rules:get

# Emulator ile test et
firebase emulators:start --only firestore
```

#### 4. Storage Issues

**Problem**: Storage erişim sorunu
**Solution**:
```bash
# Storage durumunu kontrol et
firebase storage:get

# Storage rules'ları kontrol et
firebase storage:rules:get

# Emulator ile test et
firebase emulators:start --only storage
```

### Debug Commands

```bash
# Firebase durumu
firebase --version
firebase projects:list
firebase use --list

# Proje bilgileri
firebase projects:list
firebase use tamgaci-prod
firebase apps:list

# Service durumları
firebase firestore:indexes
firebase storage:get
firebase hosting:channel:list

# Emulator durumu
firebase emulators:start --only firestore,storage
```

### Log Analysis

```bash
# Firebase logs
firebase functions:log
firebase hosting:channel:open live

# Firestore logs
firebase firestore:indexes
firebase firestore:rules:get

# Storage logs
firebase storage:get
firebase storage:rules:get
```

## 📚 Additional Resources

### Documentation
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Authentication Documentation](https://firebase.google.com/docs/auth)
- [Storage Documentation](https://firebase.google.com/docs/storage)
- [Hosting Documentation](https://firebase.google.com/docs/hosting)

### Tools
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Firebase Emulator](https://firebase.google.com/docs/emulator-suite)
- [Firebase Security Rules Simulator](https://firebase.google.com/docs/firestore/security/test-rules-emulator)

### Support
- [Firebase Support](https://firebase.google.com/support)
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase)
- [GitHub Issues](https://github.com/firebase/firebase-tools/issues)
