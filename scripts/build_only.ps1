# Tamgaci Web Build Script (Deploy olmadan)
# Bu script sadece Flutter web uygulamasını build eder
# HTML renderer kullanacak şekilde otomatik düzeltme yapar

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  TAMGACI WEB BUILD" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 1. Flutter Clean
Write-Host "[1/4] Flutter clean yapılıyor..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Flutter clean başarısız!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Clean tamamlandı" -ForegroundColor Green
Write-Host ""

# 2. Flutter Pub Get
Write-Host "[2/4] Dependencies indiriliyor..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Pub get başarısız!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Dependencies indirildi" -ForegroundColor Green
Write-Host ""

# 3. Flutter Build Web (Release Mode)
Write-Host "[3/4] Web build yapılıyor (release mode)..." -ForegroundColor Yellow
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Build başarısız!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Build tamamlandı" -ForegroundColor Green
Write-Host ""

# 4. Renderer'ı HTML olarak değiştir
Write-Host "[4/4] Renderer HTML olarak ayarlanıyor..." -ForegroundColor Yellow
$configPath = "build/web/flutter_build_config.js"

if (Test-Path $configPath) {
    $content = Get-Content $configPath -Raw
    $content = $content -replace "renderer: 'canvaskit'", "renderer: 'html'"
    $content | Set-Content $configPath -NoNewline
    Write-Host "✓ Renderer HTML olarak ayarlandı" -ForegroundColor Green
} else {
    Write-Host "UYARI: flutter_build_config.js bulunamadı!" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  ✓ BUILD TAMAMLANDI!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Build klasörü: build/web" -ForegroundColor White
Write-Host ""

