# Fix FontManifest.json paths after Flutter build
$fontManifest = "build\web\assets\FontManifest.json"

if (Test-Path $fontManifest) {
    $content = Get-Content $fontManifest -Raw | ConvertFrom-Json
    
    # Fix Roboto font paths
    foreach ($font in $content) {
        if ($font.family -eq "Roboto") {
            foreach ($fontAsset in $font.fonts) {
                if ($fontAsset.asset -match "^assets/fonts/") {
                    $fontAsset.asset = $fontAsset.asset -replace "^assets/", "assets/assets/"
                }
            }
        }
    }
    
    # Save fixed manifest
    $content | ConvertTo-Json -Depth 10 -Compress | Set-Content $fontManifest -Encoding UTF8
    Write-Host "FontManifest.json fixed"
} else {
    Write-Host "FontManifest.json not found"
}

