# PayTR Entegrasyon Hızlı Referans

## 🚨 Acil Durum Çözümleri

### Hash Verification Failed
```typescript
// PayTR resmi formülü
const hash_str = post.merchant_oid + merchantSalt + post.status + post.total_amount;
const hash = crypto.createHmac('sha256', merchantKey).update(hash_str).digest('base64');
```

### Invalid Order ID
```typescript
// Order ID formatı
const orderId = `TAMGACI${userId}${planType}${timestamp}`;
```

### Callback URL Sorunu
```bash
# Gerçek URL'yi kontrol et
gcloud functions describe paytrCallback --region=us-central1 --format="value(url)"

# PayTR panelinde bu URL'yi kullan:
https://us-central1-tamgaci.cloudfunctions.net/paytrCallback
```

## 🔧 Hızlı Komutlar

### Firebase Functions
```bash
# Deploy
firebase deploy --only functions

# Logları görüntüle
firebase functions:log --only paytrCallback

# Config kontrol
firebase functions:config:get
```

### PayTR Panel Bilgileri
```
merchant_id: 622887
merchant_key: uePB6f7AfxtAAyqZ
merchant_salt: ejdEC3ReZay7QxE8
callback_url: https://us-central1-tamgaci.cloudfunctions.net/paytrCallback
```

## 📋 Kontrol Listesi

### Deploy Öncesi
- [ ] Firebase Functions v2 kullanılıyor
- [ ] Hash verification aktif
- [ ] Merchant bilgileri doğru
- [ ] Callback URL doğru

### Deploy Sonrası
- [ ] Gerçek URL kontrol edildi
- [ ] PayTR panelinde URL güncellendi
- [ ] Test ödeme yapıldı

## 🐛 Yaygın Hatalar

| Hata | Sebep | Çözüm |
|------|-------|-------|
| Hash verification failed | Yanlış hash formülü | PayTR resmi formülünü kullan |
| Invalid order ID | Order ID formatı yanlış | `TAMGACI{userId}{planType}{timestamp}` |
| Invalid method | GET isteği | GET isteklerini handle et |
| Callback URL yanlış | Eski URL kullanılıyor | `us-central1-tamgaci.cloudfunctions.net` |

## 🔐 Güvenlik

### ❌ Yapma
- Hash verification'ı devre dışı bırakma
- Hardcoded merchant bilgileri kullanma
- HTTP callback URL kullanma

### ✅ Yap
- Her zaman hash verification yap
- Environment variables kullan
- HTTPS callback URL kullan
