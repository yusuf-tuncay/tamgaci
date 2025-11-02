# SMTP Ayarları Kurulumu

## ✅ SMTP Ayarları Eklendi

SMTP yapılandırması Firebase Config'e eklendi. Şimdi **gerçek email şifresini** güncellemeniz gerekiyor.

## 🔐 Email Şifresini Güncelleme

### Gmail Kullanıyorsanız:

1. **Google App Password Oluşturun:**
   - Google Account > Security > 2-Step Verification (aktif olmalı)
   - App Passwords > Select app: Mail > Select device: Other (Custom name: "Tamgaci Email")
   - Oluşturulan 16 haneli şifreyi kopyalayın

2. **Firebase Config'i Güncelleyin:**
   ```bash
   firebase functions:config:set smtp.password="your-16-digit-app-password"
   ```

### Diğer SMTP Servisleri İçin:

Eğer Gmail dışında bir SMTP servisi kullanıyorsanız:

```bash
firebase functions:config:set \
  smtp.user="your-email@domain.com" \
  smtp.password="your-password" \
  smtp.host="smtp.yourdomain.com" \
  smtp.port="587" \
  smtp.service="custom"
```

## 📋 Mevcut SMTP Ayarları

```bash
firebase functions:config:get smtp
```

Mevcut ayarlar:
- `smtp.user`: info@seekitapps.com
- `smtp.password`: **GÜNCELLENMELİ** (şu anda placeholder)
- `smtp.host`: smtp.gmail.com
- `smtp.port`: 587
- `smtp.service`: gmail

## 🚀 Deploy Sonrası

SMTP şifresini güncelledikten sonra function'ı deploy edin:

```bash
cd functions
npm run build
cd ..
firebase deploy --only functions:sendAIPingEmails
```

## ✅ Test Etme

Deploy sonrası test:

```powershell
.\scripts\call-send-ai-ping.ps1 -FunctionUrl "https://us-central1-tamgaci.cloudfunctions.net/sendAIPingEmails" -Action "perplexity"
```

## ⚠️ Güvenlik Notu

- SMTP şifresini asla kod içine yazmayın
- App Password kullanın (Gmail için)
- Firebase Config güvenli bir şekilde şifreleri saklar
- Şifreler runtime'da şifrelenmiş olarak saklanır

## 🔍 Gmail App Password Nasıl Alınır?

1. Google Account'unuza gidin: https://myaccount.google.com/
2. Security sekmesine gidin
3. 2-Step Verification'ın aktif olduğundan emin olun (değilse aktif edin)
4. App Passwords bölümüne gidin
5. "Select app" > "Mail" seçin
6. "Select device" > "Other (Custom name)" seçin
7. İsim verin: "Tamgaci Email"
8. Generate butonuna tıklayın
9. Oluşturulan 16 haneli şifreyi kopyalayın (boşluksuz)
10. Bu şifreyi Firebase Config'e ekleyin

## 📝 Örnek Komut

```bash
# Gmail App Password ile güncelleme
firebase functions:config:set smtp.password="abcd efgh ijkl mnop"

# Tüm ayarları birlikte güncelleme
firebase functions:config:set \
  smtp.user="info@seekitapps.com" \
  smtp.password="your-app-password-here" \
  smtp.host="smtp.gmail.com" \
  smtp.port="587" \
  smtp.service="gmail"
```

## 🔄 Ayarları Kontrol Etme

```bash
# Tüm SMTP ayarlarını görüntüle
firebase functions:config:get smtp

# Tüm config'i görüntüle
firebase functions:config:get
```

