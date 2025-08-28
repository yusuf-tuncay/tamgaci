// ========== lib/shared/pages/under_construction_page.dart ==========

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';
import '../../core/routes/routes.dart';

/// Yapım Aşamasında sayfası
class UnderConstructionPage extends StatefulWidget {
  /// Sayfa başlığı
  final String? title;

  /// Özel mesaj
  final String? customMessage;

  const UnderConstructionPage({super.key, this.title, this.customMessage});

  @override
  State<UnderConstructionPage> createState() => _UnderConstructionPageState();
}

class _UnderConstructionPageState extends State<UnderConstructionPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animasyonu
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animasyonu başlat ve döngüde çalıştır
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title ?? 'Yapım Aşamasında'),
        elevation: 0,
        backgroundColor: TamgaciConstants.appBarColor,
        foregroundColor: TamgaciConstants.textPrimary,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: TamgaciConstants.pagePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animasyonlu inşaat ikonu
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: TamgaciConstants.getResponsiveValue(
                          context,
                          mobile: 120.0,
                          tablet: 140.0,
                          desktop: 160.0,
                          wideDesktop: 180.0,
                        ),
                        height: TamgaciConstants.getResponsiveValue(
                          context,
                          mobile: 120.0,
                          tablet: 140.0,
                          desktop: 160.0,
                          wideDesktop: 180.0,
                        ),
                        decoration: BoxDecoration(
                          color: TamgaciConstants.warningColor.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.construction_outlined,
                          size: TamgaciConstants.getResponsiveValue(
                            context,
                            mobile: 60.0,
                            tablet: 70.0,
                            desktop: 80.0,
                            wideDesktop: 90.0,
                          ),
                          color: TamgaciConstants.warningColor,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: TamgaciConstants.spaceXL),

                // Yapım aşamasında başlık
                Text(
                  'Yapım Aşamasında',
                  style: GoogleFonts.poppins(
                    fontSize: TamgaciConstants.getResponsiveValue(
                      context,
                      mobile: 28.0,
                      tablet: 32.0,
                      desktop: 36.0,
                      wideDesktop: 40.0,
                    ),
                    fontWeight: FontWeight.w700,
                    color: TamgaciConstants.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: TamgaciConstants.spaceMD),

                // Açıklama metni
                Text(
                  widget.customMessage ??
                      'Bu özellik şu anda geliştirilme aşamasındadır.\nYakında sizlerle buluşacak!',
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

                SizedBox(height: TamgaciConstants.spaceXL),

                // Özellik listesi
                _buildFeaturesList(),

                SizedBox(height: TamgaciConstants.spaceXL),

                // Ana sayfaya dön butonu
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
                      TamgaciRoutes.pushReplacementNamed(
                        context,
                        TamgaciRoutes.dashboard,
                      );
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: Text(
                      'Ana Sayfaya Dön',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
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

  /// Gelecek özellikler listesi
  Widget _buildFeaturesList() {
    final features = [
      'Modern ve kullanıcı dostu arayüz',
      'Hızlı ve güvenilir performans',
      'Mobil ve masaüstü uyumluluğu',
      'Detaylı raporlama sistemi',
    ];

    return Container(
      padding: TamgaciConstants.cardPadding(context),
      decoration: BoxDecoration(
        color: TamgaciConstants.surfaceColor,
        borderRadius: BorderRadius.circular(
          TamgaciConstants.cardRadius(context),
        ),
        border: Border.all(color: TamgaciConstants.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            'Gelecek Özellikler:',
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: TamgaciConstants.textPrimary,
            ),
          ),

          SizedBox(height: TamgaciConstants.spaceSM),

          // Özellik listesi
          ...features.map(
            (feature) => Padding(
              padding: EdgeInsets.only(bottom: TamgaciConstants.spaceXS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bullet point
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: const BoxDecoration(
                      color: TamgaciConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Özellik metni
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
