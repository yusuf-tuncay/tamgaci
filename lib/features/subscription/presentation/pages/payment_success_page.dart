// ========== PAYMENT SUCCESS PAGE ==========
// lib/features/subscription/presentation/pages/payment_success_page.dart

import 'package:flutter/foundation.dart';
import 'package:tamgaci/shared/platform/html_compat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ödeme başarı sayfası - Public route (authentication gerektirmez)
class PaymentSuccessPage extends StatefulWidget {
  final bool fromPayment;

  const PaymentSuccessPage({
    super.key,
    this.fromPayment = false,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 PaymentSuccessPage: initState called');
    debugPrint('🔍 PaymentSuccessPage: Current URL: ${Uri.base}');
    debugPrint('🔍 PaymentSuccessPage: Current path: ${Uri.base.path}');
    debugPrint('🔍 PaymentSuccessPage: Current fragment: ${Uri.base.fragment}');
    debugPrint('🔍 PaymentSuccessPage: Current query: ${Uri.base.query}');
    debugPrint('🔍 PaymentSuccessPage: From payment: ${widget.fromPayment}');
    debugPrint(
        '🔍 PaymentSuccessPage: Route: ${ModalRoute.of(context)?.settings.name}');

    // Payment'tan geliyorsa parent window'a mesaj gönder ve sekmeyi kapat
    if (kIsWeb && widget.fromPayment) {
      _notifyParentAndClose();
    } else {
      // Normal kullanıcı için sadece bilgi göster
      _showSuccessMessage();
    }
  }

  /// Parent window'a mesaj gönder ve sekmeyi kapat
  void _notifyParentAndClose() {
    debugPrint('🔄 PaymentSuccessPage: Notifying parent window');

    try {
      htmlWindow.postMessage('payment_success');
      debugPrint('✅ PaymentSuccessPage: Success message sent to parent');

      // Parent window'u subscription sayfasına yönlendir
      htmlWindow.redirect('https://www.tamgaci.online/settings/subscription?payment=success');
      debugPrint(
          '✅ PaymentSuccessPage: Redirected parent to subscription page');
    } catch (e) {
      debugPrint('❌ PaymentSuccessPage: Failed to send message to parent: $e');
    }

    // 2 saniye sonra sekmeyi kapat
    Future.delayed(const Duration(seconds: 2), () {
      debugPrint('🔄 PaymentSuccessPage: Attempting to close window');
      try {
        htmlWindow.close();
      } catch (e) {
        debugPrint('❌ PaymentSuccessPage: Failed to close window: $e');
        // Kapatılamazsa kullanıcıya bilgi ver
        _showCloseMessage();
      }
    });
  }

  /// Kullanıcıya sekmeyi kapatması gerektiğini söyle
  void _showCloseMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödeme başarılı! Bu sekmeyi kapatabilirsiniz.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  /// Normal kullanıcı için başarı mesajı göster
  void _showSuccessMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödeme başarıyla tamamlandı!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
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
                      // Parent window'a mesaj gönder, yönlendir ve sekmeyi kapat
                      try {
                        htmlWindow.postMessage('payment_success');
                        htmlWindow.redirect('https://www.tamgaci.online/settings/subscription?payment=success');
                        htmlWindow.close();
                      } catch (e) {
                        debugPrint('❌ PaymentSuccessPage: Failed to close: $e');
                        _showCloseMessage();
                      }
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
