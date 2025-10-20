# GitHub Secrets Kurulumu

## FIREBASE_TOKEN Secret'ı Ekleme

1. GitHub repository'nize gidin
2. **Settings** > **Secrets and variables** > **Actions**
3. **New repository secret** butonuna tıklayın
4. **Name:** `FIREBASE_TOKEN`
5. **Secret:** Firebase CLI token'ınızı yapıştırın

## Firebase Token Alma

```bash
# Firebase CLI'yi yükleyin
npm install -g firebase-tools

# Firebase'e giriş yapın
firebase login

# Token alın
firebase login:ci
```

Bu komut size bir token verecek. Bu token'ı GitHub Secrets'a ekleyin.

## Test

Secret eklendikten sonra:
1. `main` branch'e push yapın
2. **Actions** sekmesinde workflow'un çalıştığını kontrol edin
3. Build başarılı olursa Firebase Hosting'e deploy edilecek
