# PayTR API Configuration

## PayTR Panel Bilgileri

```
Merchant ID: 622887
Merchant Key: uePB6f7AfxtAAyqZ
Merchant Salt: ejdEC3ReZay7QxE8
Callback URL: https://us-central1-tamgaci.cloudfunctions.net/paytrCallback
Site URL: https://tamgaci.online/
```

## Hash Oluşturma Mantığı

PayTR callback'inde hash doğrulaması için kullanılan format:

```
paytr_token = merchant_oid + merchant_salt + status + total_amount
hash = HMAC-SHA256(paytr_token, merchant_key) -> Base64
```

## Önemli Notlar

1. **Merchant Key ve Salt değerleri** PayTR panelinden alınmalıdır
2. **Hash doğrulaması** her callback için yapılmalıdır
3. **Callback URL** PayTR panelinde doğru şekilde ayarlanmalıdır
4. **Test Mode**: `test_mode: 1` ile test edilebilir
5. **Gerçek Ödemeler**: `test_mode: 0` ile yapılır

## Güvenlik

- Merchant Key ve Salt değerleri **asla** client-side'da kullanılmamalıdır
- Tüm PayTR işlemleri **backend (Firebase Functions)** üzerinden yapılmalıdır
- Hash doğrulaması **her zaman** yapılmalıdır

## Son Güncelleme

- Tarih: 2025-10-15
- Merchant Key düzeltildi: `uePB67AfxtAAyqZ` -> `uePB6f7AfxtAAyqZ`

