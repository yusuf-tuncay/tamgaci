# Sosyal Medya ve Favicon Görsel Gereksinimleri

## 📱 Link Paylaşılırken Görünen Görseller

### 1. Open Graph Görseli (Facebook, LinkedIn, WhatsApp, vb.)
**Mevcut Durum:** ❌ `256x256logorenkli.png` kullanılıyor - ÇOK KÜÇÜK!

**Gereken:**
- **Boyut:** 1200x630px (ideal)
- **Minimum:** 600x315px
- **Format:** PNG veya JPG
- **Maksimum Dosya Boyutu:** 8MB
- **Aspect Ratio:** 1.91:1 (yatay dikdörtgen)
- **Özellikler:** 
  - Yüksek kaliteli, net logo
  - Arka plan renkli veya şeffaf
  - Logo ortada veya sol tarafta, sağda metin olabilir
  - Marka kimliğini yansıtmalı

**Dosya Adı Önerisi:** `og-image-1200x630.png`
**Mevcut URL:** `https://www.tamgaci.online/assets/images/logos/256x256logorenkli.png`
**Olması Gereken:** `https://www.tamgaci.online/assets/images/logos/og-image-1200x630.png`

---

### 2. Twitter Card Görseli
**Mevcut Durum:** ⚠️ `summary` card tipi kullanılıyor, küçük görsel

**İki Seçenek:**

#### a) Summary Card (Küçük - Mevcut)
- **Boyut:** 120x120px
- **Card Type:** `summary`
- Mevcut durumda bu kullanılıyor ama görsel küçük

#### b) Summary Large Image Card (ÖNERİLEN) ⭐
- **Boyut:** 1200x675px (ideal) veya 1200x1200px (kare)
- **Minimum:** 300x157px
- **Format:** PNG veya JPG
- **Maksimum Dosya Boyutu:** 5MB
- **Aspect Ratio:** 16:9 veya 1:1
- **Daha etkili ve profesyonel görünür**

**Dosya Adı Önerisi:** `twitter-card-1200x675.png` veya `twitter-card-1200x1200.png`

---

## 🎨 Favicon ve İkonlar

### 3. Favicon (Tarayıcı Sekmesi)
**Mevcut Durum:** ✅ `favicon_48x48.png` kullanılıyor

**Gereken Boyutlar:**
- ✅ 16x16px (küçük ekranlar)
- ✅ 32x32px (standart)
- ✅ 48x48px (yüksek çözünürlük) - Mevcut
- **Format:** PNG veya ICO
- **Özellikler:** Basit, tanınabilir, küçük boyutta okunabilir

**Dosyalar:**
- `favicon-16x16.png`
- `favicon-32x32.png`
- `favicon-48x48.png` (mevcut)

---

### 4. Apple Touch Icon (iOS Safari)
**Mevcut Durum:** ✅ 192x192 ve 512x512 mevcut

**Gereken:**
- ✅ 180x180px (iPhone, iPad) - Mevcut 192x192 kullanılabilir
- ✅ 512x512px (iPad Pro) - Mevcut
- **Format:** PNG
- **Özellikler:** Yuvarlak köşeler otomatik eklenir, padding eklemeyin

---

### 5. PWA Manifest Icons (Progressive Web App)
**Mevcut Durum:** ✅ Manifest.json'da tanımlı

**Gereken Boyutlar:**
- ✅ 192x192px - Mevcut
- ✅ 512x512px - Mevcut
- **Maskable Icons:** Android için (mevcut)
- **Format:** PNG

---

### 6. Google Favicon (Arama Sonuçları)
**Mevcut Durum:** ✅ `favicon_48x48.png` kullanılıyor

**Gereken:**
- **Minimum:** 112x112px
- **Önerilen:** 1200x1200px veya 512x512px
- **Format:** PNG
- **Aspect Ratio:** 1:1 (kare)
- **Özellikler:** Şeffaf arka plan, net logo

**Mevcut:** `favicon_48x48.png` - Yeterli ama daha büyük olabilir

---

## 📋 Öncelikli Gereksinimler (Eksikler)

### ❌ ACİL - Yapılması Gerekenler:

1. **Open Graph Görseli - 1200x630px** 
   - En önemli eksik!
   - Facebook, LinkedIn, WhatsApp'ta link paylaşılınca görünür
   - Mevcut 256x256 çok küçük ve kare

2. **Twitter Large Image Card - 1200x1200px veya 1200x675px**
   - Twitter'da daha etkili görünüm
   - Mevcut summary card yerine kullanılabilir

### ⚠️ İYİLEŞTİRİLEBİLİR:

3. **Google Favicon - 512x512px veya daha büyük**
   - Mevcut 48x48 yeterli ama daha büyük olabilir
   - 256x256logorenkli.png kullanılabilir ama favicon için optimize edilmeli

---

## 📁 Önerilen Dosya Yapısı

```
assets/images/logos/
├── favicon-16x16.png           ✅ (gerekli)
├── favicon-32x32.png           ✅ (gerekli)
├── favicon-48x48.png           ✅ (mevcut)
├── favicon-512x512.png         ⚠️ (iyileştirilebilir)
├── 192x192logo.png            ✅ (mevcut - PWA)
├── 512x512logo.png            ✅ (mevcut - PWA)
├── 256x256logorenkli.png      ✅ (mevcut - Google SEO)
├── og-image-1200x630.png      ❌ (ACİL - Open Graph için)
└── twitter-card-1200x1200.png ❌ (Twitter için - isteğe bağlı)
```

---

## 🎨 Görsel Tasarım Önerileri

### Open Graph Görseli (1200x630px):
- **Arka plan:** Marka rengi (#0175C2) veya gradyan
- **Logo:** Sol tarafta veya ortada, büyük ve net
- **Metin (opsiyonel):** Sağ tarafta "Tamgacı - AI Destekli Muhasebe Yazılımı"
- **Catchy tagline:** "İşletmenizi Dijitalleştirin" gibi
- **Görsel kalitesi:** Yüksek çözünürlük, profesyonel görünüm

### Twitter Card (1200x1200px):
- **Kare format:** Logo ortada
- **Arka plan:** Marka rengi veya şeffaf
- **Basit ve etkili tasarım**

---

## ✅ Mevcut Durum Özeti

| Görsel Tipi | Boyut | Durum | Öncelik |
|------------|-------|-------|---------|
| Open Graph | 256x256 ❌ | Çok küçük | 🔴 ACİL |
| Twitter Card | 256x256 ⚠️ | Küçük | 🟡 İYİLEŞTİR |
| Favicon (Google) | 48x48 ✅ | Yeterli | 🟢 OK |
| Apple Touch Icon | 192x192, 512x512 ✅ | Mevcut | 🟢 OK |
| PWA Icons | 192x192, 512x512 ✅ | Mevcut | 🟢 OK |

---

## 🔧 Kod Güncellemeleri Gerekli

Open Graph görselini ekledikten sonra `web/index.html` dosyasında güncelleme yapılacak:

```html
<!-- Open Graph / Facebook -->
<meta property="og:image" content="https://www.tamgaci.online/assets/images/logos/og-image-1200x630.png" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />

<!-- Twitter Card (Large Image) -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:image" content="https://www.tamgaci.online/assets/images/logos/twitter-card-1200x1200.png" />
```

---

## 📌 Sonuç

**EN ÖNEMLİ EKSİK:** 
Open Graph görseli (1200x630px) - Sosyal medyada link paylaşılınca görünen büyük görsel. Mevcut 256x256 görsel çok küçük ve profesyonel görünmüyor.

Bu görseli hazırladıktan sonra ben gerekli kod güncellemelerini yapabilirim! 🚀

