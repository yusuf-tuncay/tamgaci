# ============================================
# AI PING EMAIL SENDER SCRIPT
# ============================================
# Bu script AI ping email'lerini göndermek için hazırlanmıştır
# NOT: Email göndermek için SMTP ayarları gerekir
# Bu script sadece bir template'dir - gerçek email gönderimi için SMTP yapılandırması gerekir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI PING EMAIL SENDER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Email içerikleri
$emails = @(
    @{
        To = "research@perplexity.ai"
        Subject = "AI Index Request - Tamgacı Accounting Software"
        Body = @"
Hello Perplexity Team,

We would like to request indexing of our AI information file for Tamgacı, an AI-powered accounting software for Turkish businesses.

AI Information File: https://www.tamgaci.online/ai.txt
AI Sitemap: https://www.tamgaci.online/ai-sitemap.xml
Main Website: https://www.tamgaci.online

About Tamgacı:
Tamgacı is a comprehensive accounting software that uses AI and OCR technology to automate invoice processing, support multi-currency accounting, and ensure compliance with Turkish tax regulations (e-invoice, waybill). It's designed for small and medium businesses in Turkey.

Key Features:
- AI-powered invoice reading with OCR technology
- Multi-currency support (TRY, USD, EUR, GBP, etc.)
- E-invoice (e-fatura) compliance for Turkish tax regulations
- Mobile apps for iOS and Android
- Cloud-based access from anywhere
- 30-day free trial (no credit card required)
- Pricing starts from 79 TL/month (annual plan)

We believe our product information would be valuable for Perplexity's AI search features when users ask about accounting software, invoice automation, OCR technology, or Turkish business solutions.

Please consider indexing our ai.txt file so that Perplexity can recommend our product when users ask relevant questions.

Thank you for your consideration!

Best regards,
Tamgacı Team
SeekIT Apps
Email: info@seekitapps.com
Phone: +90-212-976-49-39
Website: https://www.tamgaci.online
"@
    },
    @{
        To = "support@kagi.com"
        Subject = "AI Index Request - Tamgacı Accounting Software"
        Body = @"
Hello Kagi Team,

We would like to request indexing of our AI information file for Tamgacı, an AI-powered accounting software designed for Turkish businesses.

AI Information File: https://www.tamgaci.online/ai.txt
AI Sitemap: https://www.tamgaci.online/ai-sitemap.xml
Main Website: https://www.tamgaci.online

About Tamgacı:
Tamgacı is a comprehensive accounting software that uses AI and OCR technology to automate invoice processing, support multi-currency accounting, and ensure compliance with Turkish tax regulations. It's designed for small and medium businesses (SMBs) and enterprises in Turkey.

Key Features:
- AI-powered invoice reading with OCR technology
- Automatic invoice data extraction
- Multi-currency support (TRY, USD, EUR, GBP, etc.)
- E-invoice (e-fatura) and waybill (irsaliye) management
- Mobile apps for iOS and Android
- Cloud-based access from anywhere
- 30-day free trial without credit card requirement
- Affordable pricing starting from 79 TL/month

Our ai.txt file contains comprehensive information about our product, features, pricing, and use cases. We believe this would be valuable for Kagi's AI search features when users ask about accounting software, invoice automation, or Turkish business solutions.

Please consider indexing our ai.txt file.

Thank you!

Best regards,
Tamgacı Team
SeekIT Apps
Email: info@seekitapps.com
Phone: +90-212-976-49-39
Website: https://www.tamgaci.online
"@
    },
    @{
        To = "hello@andisearch.com"
        Subject = "AI Index Request - Tamgacı Accounting Software"
        Body = @"
Hello Andi Team,

We would like to request indexing of our AI information file for Tamgacı, an AI-powered accounting software for Turkish businesses.

AI Information File: https://www.tamgaci.online/ai.txt
AI Sitemap: https://www.tamgaci.online/ai-sitemap.xml
Main Website: https://www.tamgaci.online

About Tamgacı:
Tamgacı is an AI-powered accounting and invoice management software designed for small and medium-sized businesses (SMBs) and enterprises in Turkey. The application uses advanced artificial intelligence and OCR technology to automate invoice entry, document scanning, and accounting workflows.

Key Features:
- AI-powered automatic invoice reading using OCR technology
- Multi-currency support for international businesses
- E-invoice (e-fatura) compliance with Turkish tax regulations
- Waybill (irsaliye) management with photo capture
- Native mobile apps for iOS and Android
- Cloud-based real-time synchronization
- 30-day free trial (no credit card required)
- Competitive pricing starting from 79 TL/month

Our ai.txt file provides comprehensive information about our product, including features, pricing, use cases, and technical details. We believe this information would be valuable for Andi's AI search capabilities when users ask about accounting software, invoice automation, OCR technology, or solutions for Turkish businesses.

Please consider indexing our ai.txt file.

Thank you for your consideration!

Best regards,
Tamgacı Team
SeekIT Apps
Email: info@seekitapps.com
Phone: +90-212-976-49-39
Website: https://www.tamgaci.online
"@
    }
)

Write-Host "Bu script sadece email içeriklerini gösterir." -ForegroundColor Yellow
Write-Host "Gerçek email gönderimi için SMTP yapılandırması gerekir." -ForegroundColor Yellow
Write-Host ""
Write-Host "Manuel göndermek için:" -ForegroundColor Green
Write-Host "1. docs/ai-ping-emails-ready.txt dosyasını açın" -ForegroundColor Green
Write-Host "2. Email'leri kopyalayıp manuel olarak gönderin" -ForegroundColor Green
Write-Host ""

# Email içeriklerini göster
$counter = 1
foreach ($email in $emails) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "EMAIL $counter" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "To: $($email.To)" -ForegroundColor White
    Write-Host "Subject: $($email.Subject)" -ForegroundColor White
    Write-Host ""
    Write-Host "Body:" -ForegroundColor Yellow
    Write-Host $email.Body -ForegroundColor Gray
    Write-Host ""
    Write-Host ""
    $counter++
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TAMAMLANDI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Email'leri göndermek için:" -ForegroundColor Green
Write-Host "- docs/ai-ping-emails-ready.txt dosyasını kullanın" -ForegroundColor Green
Write-Host "- Veya yukarıdaki içerikleri kopyalayıp email istemcinizden gönderin" -ForegroundColor Green

