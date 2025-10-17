// ========== PAYMENT SUCCESS PAGE ==========
// lib/features/subscription/presentation/pages/payment_success_page.dart

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ödeme başarı sayfası - Public route (authentication gerektirmez)
class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 PaymentSuccessPage: initState called');
    debugPrint('🔍 PaymentSuccessPage: Current URL: ${Uri.base}');
    debugPrint(
        '🔍 PaymentSuccessPage: Route: ${ModalRoute.of(context)?.settings.name}');

    // Hemen kapanmayı dene
    _closeTabImmediately();
  }

  /// Sekmeyi hemen kapat
  void _closeTabImmediately() {
    debugPrint('🔄 PaymentSuccessPage: Attempting immediate tab close');

    // Hemen kapatmayı dene
    html.window.close();

    // 1 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 1), () {
      debugPrint('🔄 PaymentSuccessPage: Second attempt to close window');
      html.window.close();
    });

    // 3 saniye sonra son deneme
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('🔄 PaymentSuccessPage: Final attempt to close window');
      html.window.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 PaymentSuccessPage: build called');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Başarı ikonu
                const Icon(
                  Icons.check_circle_outline,
                  size: 120.0,
                  color: Colors.green,
                ),

                const SizedBox(height: 32),

                // Başarı mesajı
                Text(
                  'Ödeme Başarılı!',
                  style: GoogleFonts.poppins(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Açıklama metni
                Text(
                  'Aboneliğiniz başarıyla aktif edildi.\nBu ekranı kapatabilirsiniz.',
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
                      backgroundColor: Colors.green,
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
