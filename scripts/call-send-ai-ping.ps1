# ============================================
# AI PING EMAIL GÖNDERME SCRIPT
# ============================================
# Bu script Firebase Cloud Function'ı çağırarak email gönderir

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('all', 'perplexity', 'kagi', 'andi')]
    [string]$Action = 'all',
    
    [Parameter(Mandatory=$false)]
    [string]$FunctionUrl = ""  # Firebase Function URL'si buraya gelecek
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI PING EMAIL GÖNDERİCİ" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrEmpty($FunctionUrl)) {
    Write-Host "HATA: FunctionUrl parametresi gerekli!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Kullanım:" -ForegroundColor Yellow
    Write-Host "  .\scripts\call-send-ai-ping.ps1 -FunctionUrl 'https://us-central1-tamgaci.cloudfunctions.net/sendAIPingEmails' -Action 'all'" -ForegroundColor White
    Write-Host ""
    Write-Host "Actions:" -ForegroundColor Yellow
    Write-Host "  - all: Tüm email'leri gönder (default)" -ForegroundColor White
    Write-Host "  - perplexity: Sadece Perplexity'a gönder" -ForegroundColor White
    Write-Host "  - kagi: Sadece Kagi'ye gönder" -ForegroundColor White
    Write-Host "  - andi: Sadece Andi'ye gönder" -ForegroundColor White
    Write-Host ""
    Write-Host "Function URL'yi öğrenmek için:" -ForegroundColor Yellow
    Write-Host "  firebase functions:list" -ForegroundColor White
    Write-Host "  veya Firebase Console'dan kontrol edin" -ForegroundColor White
    exit 1
}

Write-Host "Action: $Action" -ForegroundColor Yellow
Write-Host "Function URL: $FunctionUrl" -ForegroundColor Yellow
Write-Host ""

try {
    Write-Host "Email gönderiliyor..." -ForegroundColor Yellow
    
    $body = @{
        action = $Action
    } | ConvertTo-Json

    $headers = @{
        "Content-Type" = "application/json"
    }

    $response = Invoke-RestMethod -Uri $FunctionUrl -Method Post -Body $body -Headers $headers

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  BAŞARILI!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Sonuç: $($response.message)" -ForegroundColor White
    Write-Host ""
    
    if ($response.results) {
        Write-Host "Detaylar:" -ForegroundColor Yellow
        foreach ($result in $response.results) {
            if ($result.success) {
                Write-Host "  ✓ $($result.to) - Başarılı" -ForegroundColor Green
            } else {
                Write-Host "  ✗ $($result.to) - Başarısız: $($result.error)" -ForegroundColor Red
            }
        }
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  HATA!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Hata Mesajı: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Not: Function'ın deploy edilmiş olması gerekiyor." -ForegroundColor Yellow
    Write-Host "Deploy etmek için: firebase deploy --only functions:sendAIPingEmails" -ForegroundColor Yellow
}

