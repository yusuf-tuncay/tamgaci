# İletişim Formu Email Gönderme - Kurulum Rehberi

## 📧 Gmail SMTP Kurulumu

Firebase Function'ın email gönderebilmesi için Gmail App Password oluşturmanız gerekiyor.

### 1. Gmail 2-Factor Authentication'ı Aktifleştirin

1. Google Hesabınıza giriş yapın: https://myaccount.google.com/
2. **Güvenlik** sekmesine gidin
3. **2 Adımlı Doğrulama**'yı açın (eğer açık değilse)

### 2. App Password Oluşturun

1. **2 Adımlı Doğrulama** ayarlarında **Uygulama şifreleri** bölümüne gidin
2. Veya direkt: https://myaccount.google.com/apppasswords
3. **Uygulama seçin**: "Posta" veya "Diğer (Özel ad)"
4. **Cihaz seçin**: "Diğer (Özel ad)" → "Firebase Functions" yazın
5. **Oluştur** butonuna tıklayın
6. 16 haneli şifreyi kopyalayın (boşluksuz olarak, örnek: `abcd efgh ijkl mnop` → `abcdefghijklmnop`)

### 3. Firebase Functions Environment Variable Ayarlayın

Firebase Functions'ta environment variable olarak App Password'u ekleyin:

```bash
# Firebase Functions dizinine gidin
cd functions

# Environment variable ekleyin
firebase functions:config:set gmail.app_password="YOUR_16_DIGIT_APP_PASSWORD"

# Veya Firebase Console'dan:
# Firebase Console > Functions > Configuration > Runtime Configuration > Environment Variables
```

**Not:** Firebase Functions v2 için environment variable farklı şekilde ayarlanır:

```bash
# Firebase Functions v2 için (functions/src/send-contact-email.ts içinde)
# process.env.GMAIL_APP_PASSWORD kullanılıyor

# Deploy sırasında environment variable'ı ayarlayın:
firebase functions:config:set gmail.app_password="YOUR_16_DIGIT_APP_PASSWORD"

# Veya .env dosyası kullanarak (local development için):
# functions/.env dosyası oluşturun:
# GMAIL_APP_PASSWORD=your_16_digit_app_password
```

### 4. Firebase Functions Deploy

```bash
cd functions
npm install  # nodemailer ve @types/nodemailer'ı yükler
npm run build  # TypeScript'i compile eder
firebase deploy --only functions:sendContactEmail
```

## 🔧 Kod Değişiklikleri

### Functions
- ✅ `functions/src/send-contact-email.ts` - Email gönderme function'ı oluşturuldu
- ✅ `functions/src/index.ts` - Function export edildi
- ✅ `functions/package.json` - nodemailer ve @types/nodemailer eklendi

### Frontend
- ✅ `lib/features/landing/presentation/pages/faq_page.dart` - Form submit güncellendi
- ✅ Dio kullanarak Firebase Function'a HTTP POST isteği gönderiliyor

## 📝 Email Formatı

Gönderilen email şu bilgileri içerir:
- Ad Soyad
- E-posta adresi
- Telefon numarası
- Mesaj içeriği
- Gönderim zamanı (Türkiye saati)

Email HTML formatında, profesyonel bir tasarıma sahiptir.

## ✅ Test Etme

1. FAQ sayfasına gidin: `/faq`
2. "İletişime Geç" butonuna tıklayın
3. Formu doldurup gönderin
4. `ugur.gucluoglu@gmail.com` adresine email gelip gelmediğini kontrol edin

## 🐛 Sorun Giderme

### Email gönderilmiyor
- Gmail App Password'un doğru ayarlandığından emin olun
- Firebase Functions loglarını kontrol edin: `firebase functions:log`
- Environment variable'ın doğru ayarlandığını kontrol edin

### "Invalid login" hatası
- Gmail App Password'un doğru olduğundan emin olun (16 hane, boşluksuz)
- 2-Factor Authentication'ın aktif olduğundan emin olun

### CORS hatası
- Function'un `cors: true` ve `invoker: 'public'` ayarlarının olduğundan emin olun

## 📞 Firebase Function URL

Production: `https://us-central1-tamgaci.cloudfunctions.net/sendContactEmail`

