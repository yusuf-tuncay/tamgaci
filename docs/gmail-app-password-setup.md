# Gmail App Password Kurulumu - ugur.gucluoglu@gmail.com

## 🔐 App Password Oluşturma Adımları

### 1. 2-Step Verification'ı Aktif Edin (Eğer yoksa)

1. Google Account'unuza gidin: https://myaccount.google.com/
2. **Security** sekmesine gidin
3. **2-Step Verification** bölümünü bulun
4. Eğer aktif değilse, **Turn On** butonuna tıklayın ve adımları takip edin

### 2. App Password Oluşturun

1. Google Account > **Security** sekmesine gidin
2. **2-Step Verification** bölümüne tıklayın
3. Sayfanın en altında **App passwords** linkine tıklayın
   - Veya direkt link: https://myaccount.google.com/apppasswords
4. **Select app** dropdown'dan **Mail** seçin
5. **Select device** dropdown'dan **Other (Custom name)** seçin
6. İsim verin: **"Tamgaci AI Ping Email"** veya **"Firebase Functions"**
7. **Generate** butonuna tıklayın
8. **16 haneli şifreyi kopyalayın** (boşluksuz, örnek: `abcd efgh ijkl mnop` → `abcdefghijklmnop`)
9. Bu şifreyi güvenli bir yere kaydedin (sadece bir kez gösterilir!)

### 3. Firebase Config'e App Password Ekleyin

```bash
firebase functions:config:set smtp.password="abcdefghijklmnop"
```

**Önemli:** 
- 16 haneli şifreyi **boşluksuz** olarak girin
- Şifreyi **tırnak içinde** girin
- Şifreyi asla kod içine yazmayın, sadece Firebase Config'de saklayın

### 4. Mevcut Ayarları Kontrol Edin

```bash
firebase functions:config:get smtp
```

Beklenen çıktı:
```json
{
  "user": "ugur.gucluoglu@gmail.com",
  "password": "your-app-password-here",
  "host": "smtp.gmail.com",
  "port": "587",
  "service": "gmail"
}
```

## ✅ Tam Kurulum Komutu (Tüm Ayarlar)

App Password'ü aldıktan sonra tüm ayarları birlikte güncelleyin:

```bash
firebase functions:config:set \
  smtp.user="ugur.gucluoglu@gmail.com" \
  smtp.password="YOUR_16_DIGIT_APP_PASSWORD" \
  smtp.host="smtp.gmail.com" \
  smtp.port="587" \
  smtp.service="gmail"
```

**Windows PowerShell için:**
```powershell
firebase functions:config:set smtp.user="ugur.gucluoglu@gmail.com" smtp.password="YOUR_16_DIGIT_APP_PASSWORD" smtp.host="smtp.gmail.com" smtp.port="587" smtp.service="gmail"
```

## 🚀 Deploy ve Test

1. **Function'ı Deploy Edin:**
   ```bash
   cd functions
   npm run build
   cd ..
   firebase deploy --only functions:sendAIPingEmails
   ```

2. **Test Edin:**
   ```powershell
   .\scripts\call-send-ai-ping.ps1 -FunctionUrl "https://us-central1-tamgaci.cloudfunctions.net/sendAIPingEmails" -Action "perplexity"
   ```

## ⚠️ Güvenlik Notları

- App Password sadece **bir kez gösterilir**, kaydedin!
- App Password'ü **asla kod içine yazmayın**
- App Password'ü **paylaşmayın**
- İhtiyaç halinde App Password'ü **silip yeniden oluşturabilirsiniz**

## 🔍 Sorun Giderme

### "Invalid login" hatası alıyorsanız:
- App Password'ün doğru kopyalandığından emin olun (boşluksuz)
- 2-Step Verification'ın aktif olduğundan emin olun
- App Password'ün silinmediğinden emin olun

### Email gönderilemiyorsa:
- Function logs'u kontrol edin: `firebase functions:log`
- SMTP ayarlarını kontrol edin: `firebase functions:config:get smtp`
- App Password'ü yeniden oluşturmayı deneyin

## 📧 Email Gönderim Bilgileri

- **Gönderen Email:** ugur.gucluoglu@gmail.com
- **SMTP Servisi:** Gmail
- **Port:** 587 (TLS)
- **Host:** smtp.gmail.com

## ✅ Checklist

- [ ] 2-Step Verification aktif
- [ ] App Password oluşturuldu
- [ ] App Password Firebase Config'e eklendi
- [ ] SMTP ayarları kontrol edildi
- [ ] Function deploy edildi
- [ ] Test email gönderildi

