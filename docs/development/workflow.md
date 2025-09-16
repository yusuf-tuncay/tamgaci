## Tamgaci Geliştirme Workflow’u (CI yeşil, hatasız)

Bu doküman, Tamgaci’de geliştirme yaparken hataları baştan engellemek ve CI’nin her zaman yeşil kalmasını sağlamak için izlenecek net adımları içerir.

### 1) Branch/Commit Stratejisi
- Branch: feature/<kısa-öz>, fix/<kısa-öz>, chore/<kısa-öz>
- Commit: Conventional Commits kullanın
  - feat(auth): add remember me persistence
  - fix(lint): wrap single-line if statements
  - ci(web): force JS build to avoid wasm ffi checks

### 2) Yerel Kurulum ve Komutlar
- Flutter: 3.35.1 (CI ile aynı sürüm)
- Komutlar (çekmeden/itmeden önce çalıştırın):
  - flutter pub get
  - dart format .
  - flutter analyze
  - flutter build web --release (gerekirse)

### 3) Kod Tarzı ve Lint Kuralları
- Tüm if/else/for/while gövdeleri süslü parantez ile yazılmalı (curly_braces_in_flow_control_structures)
- Açık, anlamlı isimlendirme; erken dönüş ve guard clause kullanımı
- Uzun satırlardan kaçının, okunabilirliği koruyun
- dart format CI’de zorunlu; yerelde çalıştırmadan commit etmeyin

### 4) Platforma Özgü Kod (Web/Windows/Mobil)
- Web derlemesinde dart:ffi ve win32 kullanılamaz.
- Koşullu export/import zorunlu:
  - IO sürümü (mobil/desktop): `*_io.dart`
  - Web sürümü: `*_web.dart`
  - Ortak facade: `export 'x_io.dart' if (dart.library.html) 'x_web.dart';`
- Örnekler projede hazır:
  - Bildirim servisi: `lib/core/services/utils/notification_service.dart`
  - İzin servisi: `lib/core/services/utils/permission_service.dart`
  - Profil resmi sağlayıcı: `lib/shared/utils/profile_image_provider.dart`
  - UserProfile repo: `lib/features/user_profile/data/repositories/user_profile_repository_*.dart`
- Web’de kesinlikle `dart:io` ve `FileImage` kullanmayın; facade üzerinden gidin.

### 5) Web Derleme (Wasm ve JS)
- Wasm hedefinde `dart:ffi` kullanan bağımlılıklar hata verir.
- Projede web için gerekli yerler ayrılmıştır; yine de JS fallback güvenlidir.
- Yerel doğrulama: `flutter build web --release` (makinenizde hatasız derlenmeli)

### 6) Varlıklar (Assets) ve Satır Sonları
- `pubspec.yaml`’da tanımlı tüm klasörler repo’da fiziksel olarak mevcut olmalı.
- Boş klasörler için `.gitkeep` ekleyin (örn. `assets/translations/.gitkeep`).
- Satır sonları: `.gitattributes` ile `.dart/.yaml/.yml/.md/.json` için LF zorunlu. Windows’ta CRLF üretmeyin.

### 7) Firebase Yapılandırması
- `lib/firebase_options.dart` projeye özel ve commitlidir.
- Güvenlik kuralları: kullanıcı kendi profilini okuyup yazabilmeli; kuralları bozmadan değişiklik yapın.
- Auth/Firestore işlemlerinde kullanıcıya ham Firebase hatası göstermeyin; kullanıcı dostu mesaj üretin.

### 8) Kimlik Doğrulama UX Kuralları
- Login’de “Beni hatırla” (LOCAL/SESSION persistence) uygulanır.
- Hata mesajları localized ve anlaşılır olmalı; ham hata kodları gösterilmez.
- Register’da güçlü parola kuralı: en az 8 karakter, büyük/küçük harf, rakam ve noktalama.

### 9) Telefon / Ülke Kodu
- Kayıtta ülke kodu otomatik tespit ve kullanıcı değiştirebilir olmalı.
- Sadece numara gövdesi girilir; kod picker ile seçilir; bayrak görünür.

### 10) Vergi Bilgileri
- Register’da “Vergi Kimlik No”, “Vergi Dairesi”, “Adres” zorunlu alanlar olarak toplanır ve Firestore’da saklanır.

### 11) Para Birimi ve Kur Bilgisi
- Drawer’ın alt kısmında seçili para birimine göre “1 USD = XX {CODE}” canlı gösterim.
- `currencyConverterProvider.convert(...)` üzerinden reactive yapı.

### 12) Tema ve Responsive
- Material 3, koyu/açık tema tutarlı; koyu temada beyaz zemin kalmamalı.
- `ResponsiveScaffold` ile geniş ekranda kalıcı drawer, içerik genişliği 1200–1400 px arası sınırlı.

### 13) Performans ve Önbellek
- Kur verileri: gerçek API + `CacheManager` ile önbellek ve hata durumunda eski veriye düşme.
- Görsel/asset işleme: gereksiz işlerden kaçının; ağ isteklerini mantıklı önbelleğe alın.

### 14) Test Zorunlulukları
- Hedef: %80+ coverage (unit/widget/integration).
- CI’da en az analyze/format/build geçmeli.

### 15) CI/CD Pipeline (GitHub Actions)
- Adımlar:
  1. Analyze & Format Check: `dart format --set-exit-if-changed .`, `flutter analyze`
  2. Build Web: `flutter build web --release`
  3. Build Windows (opsiyonel)
  4. Firebase Hosting (main’de ve secret mevcutsa)
- Flutter sürümü CI’da sabit (3.35.1). Yerelde aynı sürümü kullanın.

### 16) PR Checklist
- [ ] dart format .
- [ ] flutter analyze (hatayla bitmemeli)
- [ ] Web build lokal geçiyor
- [ ] Platforma özel kodlar conditional export ile ayrılmış
- [ ] Asset dizinleri mevcut
- [ ] Kullanıcıya gösterilen hata mesajları uygun ve localized
- [ ] Testler güncel ve geçiyor

### 17) Sık Karşılaşılan Hatalar ve Çözümler
- dart format exit code 1: Yerelde `dart format .` çalıştırın, değişiklikleri commit edin.
- asset_directory_does_not_exist: `pubspec.yaml`’da tanımlanan klasörleri oluşturun ve `.gitkeep` ekleyin.
- curly_braces_in_flow_control_structures: Tüm tek satırlık gövdeleri `{}` ile sarın.
- Wasm ‘dart:ffi’ hataları (web): Koşullu export kullanın ve web yolunda `dart:io`/`win32`/`ffi` kullanmayın.
- Firestore permission-denied (auth): Kuralları gözden geçirin; auth akışında Firestore hataları kullanıcı oturumunu engellememeli.

### 18) Sürümleme ve Bağımlılıklar
- Büyük sürüm güncellemeleri için ayrı PR; CI yeşil olmadan merge etmeyin.
- Flutter sürüm pinli; yerelde aynı sürümü kullanın.

---
Bu workflow’u uyguladığınızda yerel geliştirme ve CI süreçleri tutarlı, hatasız ve üretim şartlarına uygun ilerler.


