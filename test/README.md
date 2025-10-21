# Tamgacı Test Dokümantasyonu

## 📁 Test Yapısı

```
test/
├── golden/                 # Golden testler (Alchemist)
│   ├── simple_golden_test.dart
│   ├── landing_page_golden_test.dart
│   └── calculator_golden_test.dart
├── patrol/                 # E2E testler (Patrol)
│   ├── app_flow_test.dart
│   ├── calculator_test.dart
│   └── patrol_test.dart
├── unit/                   # Unit testler
├── widget/                 # Widget testler
├── integration/            # Integration testler
├── e2e/                    # End-to-end testler
├── mocks/                  # Mock dosyaları
├── utils/                  # Test yardımcıları
├── performance/            # Performance testleri
└── security/               # Security testleri
```

## 🧪 Test Türleri

### 1. **Unit Tests**
```bash
flutter test test/unit/
```

### 2. **Widget Tests**
```bash
flutter test test/widget/
```

### 3. **Integration Tests**
```bash
flutter test test/integration/
```

### 4. **Golden Tests (Alchemist)**
```bash
flutter test test/golden/ --update-goldens
```

### 5. **E2E Tests (Patrol)**
```bash
patrol test
```

## 📊 Coverage Raporu

### Coverage Oluşturma
```bash
flutter test --coverage
```

### Coverage Görüntüleme
```bash
# HTML raporu oluştur
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🚀 CI/CD Entegrasyonu

### GitHub Actions
- **Test Coverage**: `.github/workflows/test_coverage.yml`
- **Patrol Tests**: `.github/workflows/patrol_tests.yml`
- **Golden Tests**: `.github/workflows/golden_tests.yml`

### Codemagic
- **Codemagic Config**: `codemagic.yaml`

## 📋 Test Komutları

```bash
# Tüm testleri çalıştır
flutter test

# Coverage ile test
flutter test --coverage

# Golden testleri güncelle
flutter test test/golden/ --update-goldens

# Patrol E2E testleri
patrol test

# Belirli test dosyası
flutter test test/unit/calculator_test.dart

# Belirli test grubu
flutter test --name "Calculator Tests"
```

## 🔧 Test Araçları

- **Alchemist**: Golden testler için
- **Patrol**: E2E testler için
- **Mockito**: Mock objeler için
- **Flutter Test**: Unit ve widget testler için

## 📈 Coverage Hedefleri

- **Line Coverage**: %80+
- **Branch Coverage**: %70+
- **Function Coverage**: %85+

## 🐛 Test Debugging

```bash
# Verbose output
flutter test --verbose

# Debug mode
flutter test --debug

# Test sonuçlarını dosyaya yaz
flutter test > test_results.txt
```