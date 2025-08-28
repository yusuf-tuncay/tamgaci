// ========== lib/shared/pages/not_found_page.dart ==========

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';
import '../../core/routes/routes.dart';

/// 404 - Sayfa Bulunamadı sayfası
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: TamgaciConstants.pagePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 404 İkonu
                Icon(
                  Icons.search_off_outlined,
                  size: TamgaciConstants.getResponsiveValue(
                    context,
                    mobile: 120.0,
                    tablet: 140.0,
                    desktop: 160.0,
                    wideDesktop: 180.0,
                  ),
                  color: TamgaciConstants.textDisabled,
                ),
                
                const SizedBox(height: TamgaciConstants.spaceLG),
                
                // 404 Başlık
                Text(
                  '404',
                  style: GoogleFonts.poppins(
                    fontSize: TamgaciConstants.getResponsiveValue(
                      context,
                      mobile: 64.0,
                      tablet: 72.0,
                      desktop: 80.0,
                      wideDesktop: 88.0,
                    ),
                    fontWeight: FontWeight.w700,
                    color: TamgaciConstants.primaryColor,
                  ),
                ),
                
                const SizedBox(height: TamgaciConstants.spaceMD),
                
                // Sayfa bulunamadı mesajı
                Text(
                  'Sayfa Bulunamadı',
                  style: GoogleFonts.poppins(
                    fontSize: TamgaciConstants.getResponsiveValue(
                      context,
                      mobile: 24.0,
                      tablet: 28.0,
                      desktop: 32.0,
                      wideDesktop: 36.0,
                    ),
                    fontWeight: FontWeight.w600,
                    color: TamgaciConstants.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: TamgaciConstants.spaceSM),
                
                // Açıklama metni
                Text(
                  'Aradığınız sayfa bulunamadı veya taşınmış olabilir.\nAna sayfaya giderek devam edebilirsiniz.',
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
                  ),
                ),
                
                const SizedBox(height: TamgaciConstants.spaceMD),
                
                // Geri git butonu
                TextButton.icon(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      TamgaciRoutes.pop(context);
                    } else {
                      TamgaciRoutes.pushReplacementNamed(
                        context, 
                        TamgaciRoutes.dashboard,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_back_outlined),
                  label: Text(
                    'Geri Git',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
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