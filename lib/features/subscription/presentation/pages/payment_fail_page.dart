// ========== PAYMENT FAIL PAGE ==========
// lib/features/subscription/presentation/pages/payment_fail_page.dart

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';

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
    _closeTabAfterDelay();
  }

  /// Sekmeyi gecikmeli olarak kapat
  void _closeTabAfterDelay() {
    debugPrint('🔄 PaymentFailPage: Starting delayed tab close sequence');

    // 2 saniye sonra sekmeyi kapatmayı dene
    Future.delayed(const Duration(seconds: 2), () {
      debugPrint('🔄 PaymentFailPage: First attempt to close window');
      html.window.close();
    });

    // 5 saniye sonra tekrar dene
    Future.delayed(const Duration(seconds: 5), () {
      debugPrint('🔄 PaymentFailPage: Second attempt to close window');
      html.window.close();
    });

    // 10 saniye sonra son deneme
    Future.delayed(const Duration(seconds: 10), () {
      debugPrint('🔄 PaymentFailPage: Final attempt to close window');
      html.window.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 PaymentFailPage: build called');
    
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: TamgaciConstants.pagePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hata ikonu
                Icon(
                  Icons.cancel_outlined,
                  size: TamgaciConstants.getResponsiveValue(
                    context,
                    mobile: 120.0,
                    tablet: 140.0,
                    desktop: 160.0,
                    wideDesktop: 180.0,
                  ),
                  color: Colors.red,
                ),

                const SizedBox(height: TamgaciConstants.spaceXL),

                // Hata mesajı
                Text(
                  'Ödeme Başarısız',
                  style: GoogleFonts.poppins(
                    fontSize: TamgaciConstants.getResponsiveValue(
                      context,
                      mobile: 28.0,
                      tablet: 32.0,
                      desktop: 36.0,
                      wideDesktop: 40.0,
                    ),
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: TamgaciConstants.spaceMD),

                // Açıklama metni
                Text(
                  'Ödeme işlemi tamamlanamadı.\nLütfen tekrar deneyin.\nSekme otomatik olarak kapanacaktır.',
                  style: GoogleFonts.poppins(
                    fontSize: TamgaciConstants.getResponsiveValue(
                      context,
                      mobile: 16.0,
                      tablet: 17.0,
                      desktop: 18.0,
                      wideDesktop: 19.0,
                    ),
                    fontWeight: FontWeight.w400,
                    color: TamgaciConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: TamgaciConstants.spaceXL),

                // Ana sayfaya git butonu
                SizedBox(
                  width: TamgaciConstants.getResponsiveValue(
                    context,
                    mobile: double.infinity,
                    tablet: 300.0,
                    desktop: 350.0,
                    wideDesktop: 400.0,
                  ),
                  height: TamgaciConstants.buttonHeight(context),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Ana sayfaya yönlendir
                      TamgaciRoutes.pushNamedAndClearAll(
                        context,
                        TamgaciRoutes.dashboard,
                      );
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: Text(
                      'Ana Sayfaya Git',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TamgaciConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: TamgaciConstants.spaceMD),

                // Abonelik sayfasına git butonu
                SizedBox(
                  width: TamgaciConstants.getResponsiveValue(
                    context,
                    mobile: double.infinity,
                    tablet: 300.0,
                    desktop: 350.0,
                    wideDesktop: 400.0,
                  ),
                  height: TamgaciConstants.buttonHeight(context),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Abonelik sayfasına yönlendir
                      TamgaciRoutes.pushNamedAndClearAll(
                        context,
                        TamgaciRoutes.subscription,
                      );
                    },
                    icon: const Icon(Icons.subscriptions_outlined),
                    label: Text(
                      'Abonelik Sayfası',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TamgaciConstants.primaryColor,
                      side: BorderSide(color: TamgaciConstants.primaryColor),
                    ),
                  ),
                ),

                const SizedBox(height: TamgaciConstants.spaceMD),

                // Tekrar dene butonu
                SizedBox(
                  width: TamgaciConstants.getResponsiveValue(
                    context,
                    mobile: double.infinity,
                    tablet: 300.0,
                    desktop: 350.0,
                    wideDesktop: 400.0,
                  ),
                  height: TamgaciConstants.buttonHeight(context),
                  child: TextButton.icon(
                    onPressed: () {
                      // Geri git
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        TamgaciRoutes.pushNamedAndClearAll(
                          context,
                          TamgaciRoutes.subscription,
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh_outlined),
                    label: Text(
                      'Tekrar Dene',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: TamgaciConstants.textSecondary,
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
