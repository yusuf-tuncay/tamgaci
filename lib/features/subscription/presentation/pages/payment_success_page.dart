// ========== PAYMENT SUCCESS PAGE ==========
// lib/features/subscription/presentation/pages/payment_success_page.dart

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ödeme başarılı sayfası - sekme kapatma
class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🎉 PaymentSuccessPage: initState called');
    _closeTabAfterDelay();
  }

  /// Sekmeyi 3 saniye sonra kapat
  void _closeTabAfterDelay() {
    debugPrint('🎉 PaymentSuccessPage: Starting 3 second timer');
    
    // Hemen kapatmayı dene
    Future.delayed(const Duration(milliseconds: 500), () {
      debugPrint('🎉 PaymentSuccessPage: First attempt to close window');
      html.window.close();
    });
    
    // 3 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        debugPrint('🎉 PaymentSuccessPage: Second attempt to close window');
        html.window.close();
      } else {
        debugPrint('🎉 PaymentSuccessPage: Widget not mounted, cannot close');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎉 PaymentSuccessPage: build called');
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başarı ikonu
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),

              // Başlık
              Text(
                'Ödeme Başarılı!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Açıklama
              Text(
                'Aboneliğiniz başarıyla oluşturuldu.\nBu sayfa otomatik olarak kapanacak.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Yükleme animasyonu
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 16),

              Text(
                'Ana sayfaya yönlendiriliyor...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
