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
    
    // Hemen kapatmayı dene
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎉 PaymentSuccessPage: PostFrameCallback - attempting immediate close');
      html.window.close();
    });
    
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: const Center(
        child: Text(
          'Ödeme Başarılı!\nSekme kapanıyor...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
