// ========== PAYMENT FAIL PAGE ==========
// lib/features/subscription/presentation/pages/payment_fail_page.dart

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ödeme başarısız sayfası - sekme kapatma
class PaymentFailPage extends StatefulWidget {
  const PaymentFailPage({super.key});

  @override
  State<PaymentFailPage> createState() => _PaymentFailPageState();
}

class _PaymentFailPageState extends State<PaymentFailPage> {
  @override
  void initState() {
    super.initState();
    _closeTabAfterDelay();
  }

  /// Sekmeyi 3 saniye sonra kapat
  void _closeTabAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Sekmeyi kapat
        html.window.close();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hata ikonu
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel,
                  color: Colors.red[600],
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              
              // Başlık
              Text(
                'Ödeme Başarısız',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Açıklama
              Text(
                'Ödeme işlemi tamamlanamadı.\nBu sayfa otomatik olarak kapanacak.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Yükleme animasyonu
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
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