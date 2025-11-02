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

# 2.1. Sosyal medya görsellerini tek "assets" yapısına kopyala
# Flutter build/web/assets/assets/images/logos/ yapısını oluşturuyor
# Biz build/web/assets/images/logos/ yapısını istiyoruz (tek assets)
Write-Host "[2.1/3] Sosyal medya görselleri kopyalaniyor..." -ForegroundColor Yellow
$sourceDir = "build/web/assets/assets/images/logos"
$targetDir = "build/web/assets/images/logos"

if (Test-Path $sourceDir) {
    # Hedef klasörü oluştur
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    
    # Görselleri kopyala (Flutter'ın kopyaladığı yerden istediğimiz yere)
    $images = @(
        "og-image-1200x630.png",
        "twitter-card-1200x675.png",
        "twitter-card-120x120.png",
        "google-favicon-512x512.png",
        "favicon_48x48.png",
        "192x192logo.png",
        "512x512logo.png"
    )
    
    foreach ($image in $images) {
        $source = Join-Path $sourceDir $image
        $target = Join-Path $targetDir $image
        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $target -Force
        }
    }
    Write-Host "Sosyal medya görselleri kopyalandi (tek assets yapisi)" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "UYARI: Flutter build/assets/assets/images/logos klasörü bulunamadi" -ForegroundColor Yellow
    Write-Host ""
}

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
