# Tamgaci Web Build and Deploy Script
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  TAMGACI WEB BUILD & DEPLOY" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 1. Flutter Build Web
Write-Host "[1/3] Web build yapiliyor..." -ForegroundColor Yellow
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Build basarisiz!" -ForegroundColor Red
    exit 1
}
Write-Host "Build tamamlandi" -ForegroundColor Green
Write-Host ""

# 2. Renderer'i HTML olarak degistir
Write-Host "[2/3] Renderer HTML olarak ayarlaniyor..." -ForegroundColor Yellow
$configPath = "build/web/flutter_build_config.js"
$content = Get-Content $configPath -Raw
$content = $content -replace "renderer: 'canvaskit'", "renderer: 'html'"
$content | Set-Content $configPath -NoNewline
Write-Host "Renderer HTML olarak ayarlandi" -ForegroundColor Green
Write-Host ""

# 3. Firebase Deploy
Write-Host "[3/3] Firebase'e deploy ediliyor..." -ForegroundColor Yellow
firebase deploy --only hosting
if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Deploy basarisiz!" -ForegroundColor Red
    exit 1
}
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  TAMAMLANDI!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Web: https://www.tamgaci.online" -ForegroundColor Cyan
