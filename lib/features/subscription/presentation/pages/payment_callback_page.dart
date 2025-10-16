// ========== PAYMENT CALLBACK PAGE ==========
// lib/features/subscription/presentation/pages/payment_callback_page.dart

import 'dart:html' as html;
import 'package:flutter/material.dart';

/// PayTR callback sayfası - sekme kapatma
class PaymentCallbackPage extends StatefulWidget {
  const PaymentCallbackPage({super.key});

  @override
  State<PaymentCallbackPage> createState() => _PaymentCallbackPageState();
}

class _PaymentCallbackPageState extends State<PaymentCallbackPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 PaymentCallbackPage: initState called');
    _closeTabImmediately();
  }

  /// Sekmeyi hemen kapat
  void _closeTabImmediately() {
    debugPrint(
        '🔄 PaymentCallbackPage: Attempting to close window immediately');

    // Hemen kapatmayı dene
    html.window.close();

    // Eğer kapanmazsa 1 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 1), () {
      debugPrint('🔄 PaymentCallbackPage: Second attempt to close window');
      html.window.close();
    });

    // Son çare olarak 3 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('🔄 PaymentCallbackPage: Final attempt to close window');
      html.window.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 PaymentCallbackPage: build called');
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sync,
              color: Colors.blue,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Ödeme İşleniyor...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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
