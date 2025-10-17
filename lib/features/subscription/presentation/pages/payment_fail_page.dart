// ========== PAYMENT FAIL PAGE ==========
// lib/features/subscription/presentation/pages/payment_fail_page.dart

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ödeme başarısız sayfası - Public route (authentication gerektirmez)
class PaymentFailPage extends StatefulWidget {
  const PaymentFailPage({super.key});

  @override
  State<PaymentFailPage> createState() => _PaymentFailPageState();
}

class _PaymentFailPageState extends State<PaymentFailPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 PaymentFailPage: initState called');
    debugPrint('🔍 PaymentFailPage: Current URL: ${Uri.base}');
    debugPrint(
        '🔍 PaymentFailPage: Route: ${ModalRoute.of(context)?.settings.name}');

    // Hemen kapanmayı dene
    _closeTabImmediately();
  }

  /// Sekmeyi hemen kapat
  void _closeTabImmediately() {
    debugPrint('🔄 PaymentFailPage: Attempting immediate tab close');

    // Hemen kapatmayı dene
    html.window.close();

    // 1 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 1), () {
      debugPrint('🔄 PaymentFailPage: Second attempt to close window');
      html.window.close();
    });

    // 3 saniye sonra son deneme
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('🔄 PaymentFailPage: Final attempt to close window');
      html.window.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 PaymentFailPage: build called');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hata ikonu
                const Icon(
                  Icons.cancel_outlined,
                  size: 120.0,
                  color: Colors.red,
                ),

                const SizedBox(height: 32),

                // Hata mesajı
                Text(
                  'Ödeme Başarısız',
                  style: GoogleFonts.poppins(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Açıklama metni
                Text(
                  'Ödeme işlemi tamamlanamadı.\nLütfen tekrar deneyin.\nBu ekranı kapatabilirsiniz.',
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Kapat butonu
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Sadece sekmeyi kapat
                      html.window.close();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Bu Ekranı Kapat',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
