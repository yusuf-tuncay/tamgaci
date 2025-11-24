# ScreenUtil Tabanlı Responsive Tasarım Kılavuzu

Bu doküman, Tamgacı Flutter projesinde `flutter_screenutil` kullanarak mobil, tablet ve masaüstü ekranlarda tutarlı ve ölçeklenebilir arayüzler oluşturmak için izlenmesi gereken tüm adımları ve en iyi uygulamaları açıklar. Aşağıdaki yönergeler, yeni geliştirmeler veya mevcut bileşenlerde yapılacak refaktör çalışmalarında referans olarak kullanılmalıdır.

---

## 1. Başlangıç Hazırlıkları

1. **Bağımlılık**
   ```yaml
   # pubspec.yaml
   dependencies:
     flutter_screenutil: ^5.9.3
   ```

2. **Uygulama Girişi**
   ```dart
   // lib/main.dart
   class TamgaciRoot extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return ScreenUtilInit(
         designSize: const Size(390, 844),
         minTextAdapt: true,
         splitScreenMode: true,
         builder: (_, __) => const TamgaciApp(),
       );
     }
   }
   ```
   > `designSize` mobil tasarım referansıdır. Tablet/masaüstü için otomatik ölçeklemeler bu değere göre yapılır.

3. **Kod Tarama**
   - `grep -R "EdgeInsets"`, `SizedBox`, `fontSize:` gibi kalıplarla sabit piksel ve sabit font kullanımını tespit edin.
   - Öncelik sırası: sayfa düzeyi layout → kritik bileşenler → ortak bileşenler (Card, AppBar, ListView vb.)

---

## 2. Yardımcı Fonksiyonlar ve Desenler

### 2.1 `_clampResponsive`
Projede yaygın şekilde kullanılan fonksiyon, ScreenUtil çıktısını belirli bir aralıkta sınırlar:
```dart
double _clampResponsive(double value, double min, double max) =>
    value.clamp(min, max);
```
**Kullanım Amaçları**
- Masaüstünde aşırı büyüyen font/padding durumlarını engellemek.
- Mobilde okunabilirliği bozmayacak minimum değerler belirlemek.

### 2.2 Breakpoint Tanımları
```dart
final width = MediaQuery.of(context).size.width;
final isMobile = width < 600;
final isTablet = width >= 600 && width < 1024;
final isDesktop = width >= 1024;
```
Her bileşende bu üçlü kullanılarak:
- Padding/spacing/fonksiyonel görünüm farklılaştırılabilir.
- `Row` ↔ `Column` geçişleri (örn. header istatistikleri, quick actions) kontrol edilir.

### 2.3 Ortak Ölçekleme Önerileri
| Özellik        | Öneri                                                                       |
| -------------- | --------------------------------------------------------------------------- |
| Padding        | `EdgeInsets.symmetric(horizontal: _clampResponsive(12.w, 10, 24))`          |
| Font Size      | `_clampResponsive(isMobile ? 12.sp : 16.sp, 11, 20)`                        |
| Icon Size      | `_clampResponsive(isMobile ? 18.sp : 22.sp, 16, 28)`                        |
| Border Radius  | `_clampResponsive(12.r, 8, 20)`                                             |
| Spacing        | `_clampResponsive(8.h, 6, 16)`                                              |
| Container min/max genişliği | `constraints: BoxConstraints(maxWidth: ... )` yerine **`width: double.infinity`** + `LayoutBuilder` ile hizalama |

---

## 3. Bileşen Bazlı Stratejiler

### 3.1 Header / Hero Kartları
1. **Genişlik:** `width: double.infinity` kullanın, üst düzey `Padding`/`Column` ile hizalama sağlayın.
2. **Logo & ikonlar:** Mobilde 32–40px, desktop’ta 44–56px aralığında tutun.
3. **Metinler:** Başlıklar için 17–22sp, alt metinler için 11–14sp arası; `_clampResponsive` ile sınırlandırın.
4. **Gölge/Padding:** Masaüstünde 24px üzeri değerlerden kaçının; `boxShadow` ve `padding` değerlerini de ölçekleyin.

### 3.2 Hava Durumu ve Bilgi Kartları
1. `Loading` ve `Data` durumlarında aynı padding/fonksiyon şablonunu kullanın.
2. Sıcaklık/açıklama metinlerini 15–18sp bandında tutarak masaüstü taşmasını engelleyin.
3. Ek bilgiler (rüzgâr, nem) için 10–12sp aralığı idealdir.
4. Kart yüksekliğini sabitlemek yerine `spacing` ve `Expanded` kullanarak içerik bazlı akışı koruyun.

### 3.3 Hızlı İşlemler (Quick Actions)
- **Konteyner:** `padding` ve `borderRadius` ScreenUtil ile ayarlanmalı.
- **Kartlar:** `InkWell` + `Container` içinde min genişlik (örn. `minWidth: 110`) vererek kısa başlıklarda bile hizalamayı koruyun.
- **Yatay Liste:** Mobilde 48–50px, desktop’ta 56–60px yüksekliği yeterlidir.

### 3.4 Dashboard İstatistik Kartları
- Tüm stat kartları `flutter_screenutil` tabanlı özel bileşen (`DashboardStatsCard`) üzerinden kontrol edilir.
- Kart içi padding, ikon boyutu, başlık/değer fontları ve yüzdelik etiketler (chip) için `isMobile`/`isTablet` farkı gözetilir.
- Grid yerleşiminde `SliverGridDelegateWithFixedCrossAxisCount` kullanırken `mainAxisSpacing`/`crossAxisSpacing` değerleri de `_clampResponsive` ile belirlenmelidir.

### 3.5 Listeler ve Gridler
- `LayoutBuilder` kullanarak `constraints.maxWidth` üzerinden `isMobile` durumunu hesaplayın.
- Mobilde 1 veya 2 kolon, tablet/desktop’ta 2–4 kolon arasında geçiş yapın.
- Boşluklar için sabit 8/12 px yerine `spacing = _clampResponsive(...)` kullanın.

---

## 4. Uygulama Adımları

1. **Tanınan bileşeni izole et:** Örneğin `_buildWelcomeCard`, `_buildWeatherRow`, `DashboardStatsCard`.
2. **Mevcut sabit değerleri listele:** `EdgeInsets`, `SizedBox`, `fontSize`, `Icon(size:)`, `Container(height/width)`.
3. **ScreenUtil’e geçir:**
   - Pixel yerine `.w`, `.h`, `.sp`, `.r`.
   - Ardından `_clampResponsive` ile min/max sınırı koy.
4. **Breakpoints ile davranışı ayarla:** `if (isDesktop) ... else if (isTablet) ... else ...`
5. **Test ve düzeltme:**
   - Flutter web (Chrome) ile `--web-renderer html` modunda 375px, 768px, 1024px, 1440px kırılımlarını test et.
   - Gözle görülür kaymalar için `debugPaintSizeEnabled` veya `LayoutBuilder` logları kullan.
6. **Kod gözden geçirme notları:**
   - Sabit piksel değeri kalmamalı (örn. `padding: EdgeInsets.all(20)` → ScreenUtil + clamp).
   - `width: double.infinity` + `constraints` kombinasyonuyla hizalama korunmalı.
   - `ListView`/`GridView` gibi bileşenlerde de `shrinkWrap`/`physics` kullanımına dikkat et.

---

## 5. Özelleştirilmiş Rehberlik

| Bileşen              | Uyum Noktaları                                                                                              |
| -------------------- | ----------------------------------------------------------------------------------------------------------- |
| **AppBar / Drawer**  | `CustomAppBar` içinde yükseklik `Size.fromHeight(_clampResponsive(...))` ile ele alınmalı.                 |
| **Formlar / Input**  | `TextField` padding ve `fontSize` değerleri `.w`, `.h`, `.sp` dönüşümü + clamp ile sınırlandırılmalı.        |
| **Grafik/Chart**     | Dış konteynerler responsive, Chart paketleri için min boyut kontrolü `min( max(width, minValue), maxValue )`.|
| **Dialog / Popup**   | `Dialog` veya `BottomSheet` genişlik/kenar boşluğu için `MediaQuery.of(context).size.width` bazlı clamp.    |
| **Animasyonlar**     | Animasyon süreleri sabit kalsın; ancak animasyonla büyüyen widget’ların max değerleri clamp’lenmeli.        |

---

## 6. Test ve Doğrulama

1. **CI/CD Kontrolü:** PR içinde `flutter analyze` ve (mümkünse) `flutter test --platform chrome`.
2. **Manuel Test Check-list:**
   - [ ] 360–400px mobil ekranlarda yatay kayma veya taşma yok.
   - [ ] 768–1024 px arası (tablet) row→wrap geçişleri sorunsuz.
   - [ ] 1280+ px’te header, kart ve gridler tam genişlik kullanıyor; aşırı boşluk yok.
   - [ ] Yüzdelik/istatistik değerleri taşmıyor, `TextOverflow.ellipsis` aktif.
   - [ ] Tüm kliklenebilir bileşenler (InkWell, IconButton) yeterli dokunmatik alan (min 40px) sunuyor.

---

## 7. Örnek Kod Parçası (Özet)

```dart
Widget _buildHeader() {
  final width = MediaQuery.of(context).size.width;
  final isMobile = width < 600;
  final padding = _clampResponsive(isMobile ? 16.w : 24.w, 12, 36);
  final borderRadius = _clampResponsive(16.r, 12, 20);

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: Theme.of(context).colorScheme.surface,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Başlık',
          style: TextStyle(
            fontSize: _clampResponsive(isMobile ? 18.sp : 22.sp, 16, 26),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _clampResponsive(8.h, 6, 14)),
        Text(
          'Açıklama',
          style: TextStyle(
            fontSize: _clampResponsive(isMobile ? 12.sp : 14.sp, 11, 16),
          ),
        ),
      ],
    ),
  );
}
```

---

## 8. Sonuç

Bu kılavuzdaki adımlar izlenerek:
- Etraflı hizalama ve görsel tutarlılık korunur.
- Desktop ekran dışında mobil/tablet deneyimi bozulmaz.
- Review süreçlerinde “sabit piksel” kaynaklı geri bildirimler minimize edilir.

Her yeni bileşende **önce** bu dokümanı referans alarak tasarım kararı verin, ardından uygulama/test aşamasını sürdürün. Gerekli ek senaryolar veya yeni bulgular ortaya çıktıkça bu dokümanı güncellemekten çekinmeyin.

