# Firebase Rules Güncelleme Talimatları

## Stok Sayımı İçin Gerekli Güncelleme

Stok sayımı özelliğinin çalışması için Firebase Firestore Security Rules'ı güncellemeniz gerekmektedir.

### Yöntem 1: Firebase Console (Önerilen)

1. https://console.firebase.google.com/ adresine gidin
2. Projenizi seçin
3. Sol menüden **Firestore Database** → **Rules** sekmesine gidin
4. Aşağıdaki kuralı rules dosyanıza ekleyin:

```javascript
// Stock Counts - Stok sayımları
match /tenants/{tenantId}/stockCounts/{id} {
  allow read, write: if isSignedIn();
}
```

5. **Publish** butonuna tıklayın
6. Kuralların yayınlanmasını bekleyin (birkaç saniye sürer)

### Yöntem 2: Firebase CLI

```bash
firebase deploy --only firestore:rules
```

### Yöntem 3: Firebase CLI ile İndexler

Eğer index hataları da alıyorsanız:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## Doğrulama

Rules başarıyla güncellendiğinde:
- Stok sayımı oluşturabileceksiniz
- "Permission denied" hatası almayacaksınız
- Depo detay sayfasından "Stok Sayımı" özelliği çalışacak

## Not

Bu geçici bir rule'dur. Production ortamında daha güvenli kurallar kullanılmalıdır:
- Sadece kendi tenant'ınıza erişim
- Sadece yetkili kullanıcılar stok sayımı yapabilsin
- Audit logging eklensin
