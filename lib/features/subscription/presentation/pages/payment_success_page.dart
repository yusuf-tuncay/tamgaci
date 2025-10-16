// ========== PAYMENT SUCCESS PAGE ==========
// lib/features/subscription/presentation/pages/payment_success_page.dart

import 'dart:html' as html;
import 'package:flutter/material.dart';

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
    _closeTabImmediately();
  }

  /// Sekmeyi hemen kapat
  void _closeTabImmediately() {
    debugPrint('🎉 PaymentSuccessPage: Attempting to close window immediately');
    
    // Hemen kapatmayı dene
    html.window.close();
    
    // Eğer kapanmazsa 1 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 1), () {
      debugPrint('🎉 PaymentSuccessPage: Second attempt to close window');
      html.window.close();
    });
    
    // Son çare olarak 3 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('🎉 PaymentSuccessPage: Final attempt to close window');
      html.window.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎉 PaymentSuccessPage: build called');
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Ödeme Başarılı!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Sekme kapanıyor...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
