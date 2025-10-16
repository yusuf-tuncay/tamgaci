# PayTR Entegrasyon Rehberi

Bu dökümantasyon, PayTR ödeme sistemi entegrasyonunun doğru şekilde kurulması ve yönetilmesi için gerekli tüm bilgileri içerir.

## 📋 İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [PayTR Panel Konfigürasyonu](#paytr-panel-konfigürasyonu)
3. [Firebase Functions Konfigürasyonu](#firebase-functions-konfigürasyonu)
4. [Hash Verification](#hash-verification)
5. [Callback URL Yönetimi](#callback-url-yönetimi)
6. [Troubleshooting](#troubleshooting)
7. [Güvenlik Notları](#güvenlik-notları)

## 🎯 Genel Bakış

PayTR entegrasyonu 3 ana bileşenden oluşur:
- **Flutter Uygulaması**: Ödeme başlatma
- **Firebase Functions**: PayTR API ile iletişim
- **PayTR Callback**: Ödeme sonucu bildirimi

## 🔧 PayTR Panel Konfigürasyonu

### Gerekli Bilgiler

PayTR panelinden alınması gereken bilgiler:

```bash
# PayTR Panel > Ayarlar > API Bilgileri
merchant_id: "622887"
merchant_key: "uePB6f7AfxtAAyqZ"  
merchant_salt: "ejdEC3ReZay7QxE8"
```

### Callback URL Ayarları

PayTR panelinde şu URL'ler ayarlanmalıdır:

```
Bildirim URL (Callback URL): https://us-central1-tamgaci.cloudfunctions.net/paytrCallback
Site Adresi: https://tamgaci.online/
```

## 🔥 Firebase Functions Konfigürasyonu

### Environment Variables

```bash
# Firebase Functions config
firebase functions:config:set paytr.merchant_id="622887"
firebase functions:config:set paytr.merchant_key="uePB6f7AfxtAAyqZ"
firebase functions:config:set paytr.merchant_salt="ejdEC3ReZay7QxE8"
firebase functions:config:set paytr.callback_url="https://us-central1-tamgaci.cloudfunctions.net/paytrCallback"
firebase functions:config:set paytr.test_mode="1"
```

### Functions Versiyonu

**ÖNEMLİ**: Firebase Functions v2 kullanılmalıdır.

```typescript
// ✅ DOĞRU (v2)
import { onRequest } from 'firebase-functions/v2/https';
export const paytrCallback = onRequest((request, response) => { ... });

// ❌ YANLIŞ (v1) 
import * as functions from 'firebase-functions';
export const paytrCallback = functions.https.onRequest((request, response) => { ... });
```

### Package.json Versiyonu

```json
{
  "dependencies": {
    "firebase-functions": "^6.5.0"
  }
}
```

## 🔐 Hash Verification

### PayTR Resmi Hash Formülü

PayTR'nin resmi dökümantasyonuna göre hash hesaplama:

```typescript
// PayTR callback hash formülü
const hash_str = merchant_oid + merchant_salt + status + total_amount;
const hash = crypto.createHmac('sha256', merchant_key).update(hash_str).digest('base64');
```

### Hash Verification Kodu

```typescript
// PayTR RESMİ DÖKÜMANTASYONUNA GÖRE HASH DOĞRULAMASI
const hash_str = post.merchant_oid + merchantSalt + post.status + post.total_amount;
const hash = crypto.createHmac('sha256', merchantKey).update(hash_str).digest('base64');

if (hash !== post.hash) {
    console.error('❌ PayTR Hash verification failed');
    response.status(400).json({ error: 'Invalid hash' });
    return;
} else {
    console.log('✅ PayTR Hash verification successful');
}
```

### Hash Debug Logları

```typescript
console.log('🔍 PAYTR HASH DEBUG (RESMİ DÖKÜMANTASYON):');
console.log('merchant_oid:', post.merchant_oid);
console.log('merchant_salt:', merchantSalt);
console.log('status:', post.status);
console.log('total_amount:', post.total_amount);
console.log('merchant_key:', merchantKey);
console.log('Hash String:', hash_str);
console.log('Generated Hash:', hash);
console.log('Received Hash:', post.hash);
```

## 🔗 Callback URL Yönetimi

### URL Formatları

```bash
# Firebase Functions v2 URL (DOĞRU)
https://us-central1-tamgaci.cloudfunctions.net/paytrCallback

# Firebase Functions v1 URL (YANLIŞ - Deploy sırasında gösterilir ama kullanılmamalı)
https://paytrcallback-n5c3skxfhq-uc.a.run.app
```

### URL Kontrolü

```bash
# Gerçek URL'yi kontrol et
gcloud functions describe paytrCallback --region=us-central1 --format="value(url)"
```

### PayTR Panelinde URL Güncelleme

1. PayTR panelinde **Ayarlar > API Bilgileri** bölümüne gidin
2. **Bildirim URL** alanını güncelleyin:
   ```
   https://us-central1-tamgaci.cloudfunctions.net/paytrCallback
   ```

## 🐛 Troubleshooting

### Yaygın Sorunlar

#### 1. "Hash verification failed" Hatası

**Sebep**: Hash formülü yanlış veya merchant bilgileri hatalı

**Çözüm**:
```typescript
// PayTR resmi formülünü kullan
const hash_str = post.merchant_oid + merchantSalt + post.status + post.total_amount;
const hash = crypto.createHmac('sha256', merchantKey).update(hash_str).digest('base64');
```

#### 2. "Invalid order ID" Hatası

**Sebep**: Order ID formatı yanlış veya subscription bulunamıyor

**Çözüm**:
```typescript
// Order ID formatı: TAMGACI{userId}{planType}{timestamp}
const orderId = `TAMGACI${userId}${planType}${timestamp}`;
```

#### 3. Deploy Sırasında Eski URL Gösterilmesi

**Sebep**: Firebase CLI'nin bilinen sorunu

**Çözüm**: Gerçek URL'yi kontrol edin:
```bash
gcloud functions describe paytrCallback --region=us-central1 --format="value(url)"
```

#### 4. "Invalid method" Hatası

**Sebep**: PayTR GET isteği gönderiyor

**Çözüm**:
```typescript
if (request.method === 'GET') {
    response.status(200).send('PayTR Callback Handler is ready');
    return;
}
```

### Debug Logları

```typescript
console.log('=== PayTR Callback Started ===');
console.log('Method:', request.method);
console.log('Headers:', request.headers);
console.log('Body:', request.body);
console.log('POST data received:', post);
```

## 🔒 Güvenlik Notları

### 1. Hash Verification Zorunlu

```typescript
// ❌ ASLA hash verification'ı devre dışı bırakma
// console.log('🚨 HASH VERIFICATION DISABLED'); // YANLIŞ!

// ✅ Her zaman hash verification yap
if (hash !== post.hash) {
    response.status(400).json({ error: 'Invalid hash' });
    return;
}
```

### 2. Merchant Bilgileri Güvenliği

```typescript
// ✅ Environment variables kullan
const merchantKey = process.env.PAYTR_MERCHANT_KEY || 'uePB6f7AfxtAAyqZ';
const merchantSalt = process.env.PAYTR_MERCHANT_SALT || 'ejdEC3ReZay7QxE8';

// ❌ Hardcoded değerler kullanma (production'da)
const merchantKey = 'uePB6f7AfxtAAyqZ'; // YANLIŞ!
```

### 3. Callback URL Güvenliği

- Callback URL sadece HTTPS olmalı
- PayTR panelinde doğru URL ayarlanmalı
- URL değişikliklerinde PayTR paneli güncellenmeli

## 📊 Monitoring ve Loglar

### Firebase Console Logları

```bash
# Functions loglarını görüntüle
firebase functions:log --only paytrCallback
```

### Kritik Log Mesajları

```typescript
// Başarılı hash verification
console.log('✅ PayTR Hash verification successful - PROCEEDING');

// Başarısız hash verification  
console.error('❌ PayTR Hash verification failed - MISMATCH DETECTED');

// Ödeme başarılı
console.log('Payment successful - updating subscription');

// Abonelik güncellendi
console.log('Subscription updated successfully');
```

## 🚀 Deployment Checklist

### Pre-Deployment

- [ ] PayTR panel bilgileri doğru
- [ ] Firebase Functions v2 kullanılıyor
- [ ] Hash verification aktif
- [ ] Callback URL doğru
- [ ] Environment variables ayarlanmış

### Post-Deployment

- [ ] Deploy başarılı
- [ ] Gerçek URL kontrol edildi
- [ ] PayTR panelinde URL güncellendi
- [ ] Test ödeme yapıldı
- [ ] Loglar kontrol edildi

## 📞 Destek

### PayTR Destek

- **Dökümantasyon**: https://dev.paytr.com
- **Destek**: PayTR paneli üzerinden

### Firebase Destek

- **Dökümantasyon**: https://firebase.google.com/docs/functions
- **Console**: https://console.firebase.google.com

---

**Son Güncelleme**: 16 Ekim 2025  
**Versiyon**: 1.0  
**Yazar**: TAMGACI Development Team
