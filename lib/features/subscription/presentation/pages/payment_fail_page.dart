// ========== PAYMENT FAIL PAGE ==========
// lib/features/subscription/presentation/pages/payment_fail_page.dart

import 'dart:html' as html;
import 'package:flutter/material.dart';

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
    debugPrint('❌ PaymentFailPage: initState called');
    _closeTabImmediately();
  }

  /// Sekmeyi hemen kapat
  void _closeTabImmediately() {
    debugPrint('❌ PaymentFailPage: Attempting to close window immediately');

    // Hemen kapatmayı dene
    html.window.close();

    // Eğer kapanmazsa 1 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 1), () {
      debugPrint('❌ PaymentFailPage: Second attempt to close window');
      html.window.close();
    });

    // Son çare olarak 3 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('❌ PaymentFailPage: Final attempt to close window');
      html.window.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('❌ PaymentFailPage: build called');
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Ödeme Başarısız',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
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
