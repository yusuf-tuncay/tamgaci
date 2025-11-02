# PayTR API Configuration

## PayTR Panel Bilgileri

```
Merchant ID: 622887
Merchant Key: uePB6f7AfxtAAyqZ
Merchant Salt: ejdEC3ReZay7QxE8
Callback URL: https://us-central1-tamgaci.cloudfunctions.net/paytrCallback
Site URL: https://www.tamgaci.online/
```

## Hash Oluşturma Mantığı (PayTR Resmi Dökümantasyonu)

PayTR callback'inde hash doğrulaması için kullanılan format:

```typescript
// PayTR RESMİ DÖKÜMANTASYONUNA GÖRE
const hash_str = merchant_oid + merchant_salt + status + total_amount;
const hash = crypto.createHmac('sha256', merchant_key).update(hash_str).digest('base64');
```

## Firebase Functions v2 Konfigürasyonu

```bash
# Environment variables
firebase functions:config:set paytr.merchant_id="622887"
firebase functions:config:set paytr.merchant_key="uePB6f7AfxtAAyqZ"
firebase functions:config:set paytr.merchant_salt="ejdEC3ReZay7QxE8"
firebase functions:config:set paytr.callback_url="https://us-central1-tamgaci.cloudfunctions.net/paytrCallback"
firebase functions:config:set paytr.test_mode="1"
```

## Önemli Notlar

1. **Firebase Functions v2** kullanılmalıdır (v1 deprecated)
2. **Hash doğrulaması** PayTR resmi formülü ile yapılmalıdır
3. **Callback URL** PayTR panelinde doğru şekilde ayarlanmalıdır
4. **Test Mode**: `test_mode: 1` ile test edilebilir
5. **Gerçek Ödemeler**: `test_mode: 0` ile yapılır

## Güvenlik

- **Hash verification** asla devre dışı bırakılmamalıdır
- Merchant Key ve Salt değerleri **asla** client-side'da kullanılmamalıdır
- Tüm PayTR işlemleri **backend (Firebase Functions)** üzerinden yapılmalıdır
- **HTTPS** callback URL kullanılmalıdır

## Troubleshooting

### Yaygın Sorunlar
- **Hash verification failed**: PayTR resmi formülünü kullan
- **Invalid order ID**: Order ID formatını kontrol et
- **Callback URL yanlış**: Gerçek URL'yi kontrol et

### Debug Komutları
```bash
# Gerçek URL'yi kontrol et
gcloud functions describe paytrCallback --region=us-central1 --format="value(url)"

# Logları görüntüle
firebase functions:log --only paytrCallback
```

## Son Güncelleme

- **Tarih**: 2025-10-16
- **Versiyon**: Firebase Functions v2
- **Hash Formülü**: PayTR resmi dökümantasyonuna uygun
- **Güvenlik**: Hash verification aktif ve güvenli

