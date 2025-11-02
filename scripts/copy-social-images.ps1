# Sosyal Medya Görsellerini Web Klasörüne Kopyala
# Flutter build sonrası bu görseller build/web klasörüne kopyalanacak

Write-Host "Sosyal medya görselleri kopyalanıyor..." -ForegroundColor Yellow

$sourceDir = "assets/images/logos"
$targetDir = "build/web/assets/images/logos"

# Build klasörü yoksa oluştur
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# Görselleri kopyala
$images = @(
    "og-image-1200x630.png",
    "twitter-card-1200x675.png",
    "twitter-card-120x120.png",
    "google-favicon-512x512.png"
)

foreach ($image in $images) {
    $source = Join-Path $sourceDir $image
    $target = Join-Path $targetDir $image
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $target -Force
        Write-Host "  ✓ $image kopyalandı" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $image bulunamadı" -ForegroundColor Red
    }
}

Write-Host "Tamamlandı!" -ForegroundColor Green

