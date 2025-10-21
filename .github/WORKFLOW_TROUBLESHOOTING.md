# GitHub Actions Workflow Sorun Giderme Rehberi

## Workflow'ların Genel Yapısı

### 1. Test Coverage Workflow
- **Dosya**: `.github/workflows/test_coverage.yml`
- **Amaç**: Test coverage raporu oluşturma ve Codecov'a upload
- **Tetikleyiciler**: Push, PR, Manuel tetikleme

### 2. Patrol E2E Tests Workflow
- **Dosya**: `.github/workflows/patrol_tests.yml`
- **Amaç**: End-to-end testleri çalıştırma
- **Tetikleyiciler**: Push, PR, Günlük schedule, Manuel tetikleme

### 3. Golden Tests Workflow
- **Dosya**: `.github/workflows/golden_tests.yml`
- **Amaç**: Golden testleri çalıştırma
- **Tetikleyiciler**: Push, PR, Manuel tetikleme

## Yaygın Sorunlar ve Çözümleri

### Test Coverage Workflow Sorunları

#### 1. Coverage Dosyası Oluşturulamadı
**Hata**: `❌ Coverage dosyası oluşturulamadı!`
**Çözüm**:
- Test dosyalarının varlığını kontrol edin
- `flutter test --coverage` komutunu manuel çalıştırın
- Test hatalarını kontrol edin

#### 2. CODECOV_TOKEN Eksik
**Hata**: `Codecov upload failed: token not found`
**Çözüm**:
- GitHub Secrets'a `CODECOV_TOKEN` ekleyin
- Token'ı Codecov'dan alın
- Repository Settings > Secrets > Actions

#### 3. Test Başarısız
**Hata**: Test step failed
**Çözüm**:
- Test hatalarını loglardan kontrol edin
- `flutter test` komutunu manuel çalıştırın
- Test dosyalarını kontrol edin

### Patrol E2E Tests Workflow Sorunları

#### 1. Android SDK Kurulum Hatası
**Hata**: `Android SDK setup failed`
**Çözüm**:
- API level 33 kullanıldığını kontrol edin
- Build tools 33.0.0 kullanıldığını kontrol edin
- Android licenses'ları kabul edildiğini kontrol edin

#### 2. Patrol Test Dosyaları Bulunamadı
**Hata**: `⚠️ Patrol test dosyası bulunamadı`
**Çözüm**:
- `test/patrol/` dizininin varlığını kontrol edin
- Patrol test dosyalarının `.dart` uzantılı olduğunu kontrol edin
- Test dosyalarının içeriğini kontrol edin

#### 3. Android Emulator Başlatılamadı
**Hata**: `Android emulator launch failed`
**Çözüm**:
- Android SDK kurulumunu kontrol edin
- Emulator'ın mevcut olduğunu kontrol edin
- Android licenses'ları kabul edin

### Golden Tests Workflow Sorunları

#### 1. Golden Test Dizini Bulunamadı
**Hata**: `⚠️ Golden test dizini bulunamadı`
**Çözüm**:
- `test/golden/` dizininin varlığını kontrol edin
- Golden test dosyalarının `.dart` uzantılı olduğunu kontrol edin

#### 2. Alchemist Bağımlılığı Eksik
**Hata**: `⚠️ Alchemist bağımlılığı bulunamadı`
**Çözüm**:
- `pubspec.yaml`'da `alchemist` bağımlılığını kontrol edin
- `flutter pub get` komutunu çalıştırın
- Bağımlılık versiyonunu kontrol edin

#### 3. Golden Test Başarısız
**Hata**: `Golden testleri başarısız oldu`
**Çözüm**:
- Test dosyalarının içeriğini kontrol edin
- Alchemist API kullanımını kontrol edin
- Test widget'larının doğru import edildiğini kontrol edin

## Debug Logging

### Debug Logging Etkinleştirme
Tüm workflow'larda debug logging etkinleştirilmiştir:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

### Log Analizi
1. **Workflow Logs**: Actions sekmesinde workflow loglarını görüntüleyin
2. **Step Logs**: Her step için detaylı logları kontrol edin
3. **Error Messages**: Hata mesajlarını dikkatli okuyun
4. **Artifact Downloads**: Upload edilen artifact'ları indirin

## Manuel Test Etme

### Lokal Test
```bash
# Test coverage
flutter test --coverage

# Patrol tests
flutter test test/patrol/

# Golden tests
flutter test test/golden/ --update-goldens
```

### Workflow Manuel Tetikleme
1. GitHub'da Actions sekmesine gidin
2. İlgili workflow'u seçin
3. "Run workflow" düğmesine tıklayın
4. Branch seçin ve tetikleyin

## Monitoring ve İzleme

### Workflow Durumu
- **Yeşil**: Başarılı
- **Kırmızı**: Başarısız
- **Sarı**: Uyarı
- **Gri**: Beklemede

### Artifact'lar
- **Coverage**: `coverage/lcov.info`
- **Patrol Results**: `test/patrol/`
- **Golden Files**: `test/golden/`

### Notification'lar
- Email bildirimleri
- PR yorumları
- Slack/Discord entegrasyonu

## Sorun Giderme Adımları

### 1. Hata Analizi
1. Workflow loglarını inceleyin
2. Hata mesajlarını not edin
3. Hangi step'te hata olduğunu belirleyin

### 2. Lokal Test
1. Hatalı komutları lokal çalıştırın
2. Dependencies'i kontrol edin
3. Dosya yollarını kontrol edin

### 3. Çözüm Uygulama
1. Workflow dosyasını düzenleyin
2. Değişiklikleri commit edin
3. Workflow'u tekrar tetikleyin

### 4. Doğrulama
1. Workflow'un başarılı olduğunu kontrol edin
2. Artifact'ları indirin
3. Sonuçları analiz edin

## İletişim ve Destek

### GitHub Issues
- Workflow hatalarını GitHub Issues'da bildirin
- Detaylı hata mesajlarını ekleyin
- Log dosyalarını attach edin

### Dokümantasyon
- Bu rehberi güncelleyin
- Yeni sorunları ekleyin
- Çözümleri paylaşın

## Sonuç

Bu rehber, GitHub Actions workflow'larında karşılaşılan yaygın sorunları çözmek için hazırlanmıştır. Sorun yaşadığınızda bu rehberi takip edin ve gerekirse ek destek alın.
