# AI Ping Email Gönderme Kurulumu

## Adımlar

### 1. Firebase Environment Variables Ayarlama

SMTP bilgilerini Firebase Config'e ekleyin:

```bash
# Gmail için örnek
firebase functions:config:set smtp.user="info@seekitapps.com"
firebase functions:config:set smtp.password="your-app-password-here"
```

**Gmail App Password oluşturma:**
1. Google Account > Security > 2-Step Verification (aktif olmalı)
2. App Passwords > Select app: Mail > Select device: Other
3. Oluşturulan 16 haneli şifreyi kullanın

### 2. Cloud Function Deploy

```bash
cd functions
npm install  # Eğer nodemailer yüklü değilse
npm run build
cd ..
firebase deploy --only functions:sendAIPingEmails
```

### 3. Function URL'sini Öğrenme

```bash
firebase functions:list
```

Veya Firebase Console > Functions > sendAIPingEmails

### 4. Email Gönderme

#### Yöntem 1: PowerShell Script (Önerilen)

```powershell
.\scripts\call-send-ai-ping.ps1 -FunctionUrl "https://us-central1-tamgaci.cloudfunctions.net/sendAIPingEmails" -Action "all"
```

Actions:
- `all`: Tüm email'leri gönder (Perplexity, Kagi, Andi)
- `perplexity`: Sadece Perplexity'a gönder
- `kagi`: Sadece Kagi'ye gönder
- `andi`: Sadece Andi'ye gönder

#### Yöntem 2: Direct HTTP Call

```bash
curl -X POST https://us-central1-tamgaci.cloudfunctions.net/sendAIPingEmails \
  -H "Content-Type: application/json" \
  -d '{"action": "all"}'
```

#### Yöntem 3: Postman/Insomnia

- Method: POST
- URL: `https://us-central1-tamgaci.cloudfunctions.net/sendAIPingEmails`
- Body (JSON):
```json
{
  "action": "all"
}
```

## SMTP Ayarları

Function'da şu anda Gmail kullanılıyor. Farklı bir SMTP servisi kullanmak için `functions/src/send-ai-ping-emails.ts` dosyasındaki `createTransporter` fonksiyonunu düzenleyin:

```typescript
// Gmail için
return nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD,
    },
});

// Genel SMTP için
return nodemailer.createTransport({
    host: 'smtp.example.com',
    port: 587,
    secure: false, // true for 465, false for other ports
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD,
    },
});
```

## Test Etme

Deploy sonrası test:

```bash
# Tüm email'leri test et
.\scripts\call-send-ai-ping.ps1 -FunctionUrl "YOUR_FUNCTION_URL" -Action "all"

# Sadece birini test et
.\scripts\call-send-ai-ping.ps1 -FunctionUrl "YOUR_FUNCTION_URL" -Action "perplexity"
```

## Troubleshooting

1. **"SMTP_USER is not defined" hatası:**
   - Firebase Config'de SMTP ayarlarını kontrol edin
   - `firebase functions:config:get` ile kontrol edebilirsiniz

2. **Email gönderilemiyor:**
   - SMTP bilgilerinin doğru olduğundan emin olun
   - Gmail kullanıyorsanız App Password kullandığınızdan emin olun
   - Function logs: `firebase functions:log`

3. **Function bulunamıyor:**
   - Deploy'un başarılı olduğundan emin olun
   - Function URL'sinin doğru olduğundan emin olun

## Güvenlik Notları

- SMTP şifrelerini asla kod içine yazmayın
- Firebase Config kullanın veya Secret Manager
- Function'ı authenticated yapmak için `invoker: 'authenticated'` kullanabilirsiniz

