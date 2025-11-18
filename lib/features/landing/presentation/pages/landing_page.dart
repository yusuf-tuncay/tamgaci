// ========== KURUMSAL LANDING PAGE ==========
// lib/features/landing/presentation/pages/landing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:web/web.dart' as web;
import '../../../../../shared/platform/web_asset_loader.dart';

/// Kurumsal ve KOBİ odaklı landing page
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  // State
  bool _isDesktop = false;
  bool _isDesktopCheckScheduled = false;
  final bool _showBanner = true;
  final ScrollController _scrollController = ScrollController();

  // Scroll keys for sections
  final GlobalKey _aboutSectionKey = GlobalKey();
  final GlobalKey _contactSectionKey = GlobalKey();

  // Responsive helper methods
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;
  bool _isDesktopSize(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Device type check build sonrası yapılacak
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Context hazır olduğunda device type kontrolü yap (sadece bir kez)
    if (!_isDesktopCheckScheduled && _isDesktop == false && MediaQuery.of(context).size.width >= 768) {
      _isDesktopCheckScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isDesktop = true;
          });
        }
      });
    }
  }

  void _initializeAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Float animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Float animation
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    if (mounted) {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_slideController.isAnimating) {
      _slideController.forward();
        }
    });
      if (mounted) {
    _floatController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    // Stop animations before disposing
    _fadeController.stop();
    _slideController.stop();
    _floatController.stop();
    _pulseController.stop();
    
    // Dispose controllers
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          _buildMainContent(),

          // Promo banner (tüm cihazlarda)
          if (_showBanner) _buildProfessionalBanner(),
        ],
      ),
    );
  }

  /// Main content with professional design
  Widget _buildMainContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Professional Hero Section
          _buildProfessionalHero(),

          // Business Features
          _buildBusinessFeatures(),

          // Platform Section
          _buildPlatformSection(),

          // About Section
          _buildAboutSection(),

          // Contact Section
          _buildContactSection(),

          // Professional Footer
          _buildProfessionalFooter(),
        ],
      ),
    );
  }

  /// Professional Hero Section
  Widget _buildProfessionalHero() {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Koyu mavi
            Color(0xFF3B82F6), // Ana mavi
            Color(0xFF60A5FA), // Açık mavi
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Subtle background pattern
          _buildBackgroundPattern(),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewportHeight = MediaQuery.of(context).size.height;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: _isMobile(context)
                          ? ((_showBanner)
                              ? 130.0
                              : 16.0) // Mobil: Banner yüksekliği (80) + padding (50)
                          : (_isTablet(context)
                              ? ((_showBanner)
                                  ? 132.0
                                  : 32.0) // Tablet: Banner yüksekliği (100) + padding (32)
                              : ((_isDesktop && _showBanner)
                                  ? 124.0
                                  : 24.0)), // Desktop: Banner yüksekliği (100) + padding (24)
                      left: _isMobile(context)
                          ? 16.0
                          : (_isTablet(context) ? 40.0 : 24.0),
                      right: _isMobile(context)
                          ? 16.0
                          : (_isTablet(context) ? 40.0 : 24.0),
                      bottom: _isMobile(context)
                          ? 16.0
                          : (_isTablet(context) ? 32.0 : 24.0),
                    ),
                    child: _isMobile(context)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Professional logo
                              _buildProfessionalLogo(),

                              const SizedBox(height: 24),

                              // Professional text
                              _buildProfessionalText(),

                              const SizedBox(height: 24),

                              // Professional buttons
                              _buildProfessionalButtons(),

                              const SizedBox(height: 32),

                              // Reklam görseli (Mobile - butonların altında)
                              _buildAdvertisementImageMobile(),

                              const SizedBox(height: 20),
                            ],
                          )
                        : _isTablet(context)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo, metin ve butonlar üstte
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Professional logo
                                      _buildProfessionalLogo(),

                                      const SizedBox(height: 30),

                                      // Professional text
                                      _buildProfessionalText(),

                                      const SizedBox(height: 30),

                                      // Professional buttons
                                      _buildProfessionalButtons(),
                                    ],
                                  ),

                                  const SizedBox(height: 40),

                                  // Görsel altta
                                  Center(
                                    child: _buildAdvertisementImage(),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  // Sol taraf - Reklam görseli (Desktop)
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: _buildAdvertisementImage(),
                                    ),
                                  ),

                                  const SizedBox(width: 40),

                                  // Sağ taraf - Logo, metin ve butonlar (Desktop)
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Professional logo
                                        _buildProfessionalLogo(),

                                        const SizedBox(height: 40),

                                        // Professional text
                                        _buildProfessionalText(),

                                        const SizedBox(height: 60),

                                        // Professional buttons
                                        _buildProfessionalButtons(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Advertisement image (Desktop)
  Widget _buildAdvertisementImage() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(top: 100),
            width: 550,
            height: 650, // 500 / 1.18 = 424 (orijinal oran korunuyor)
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: const DecorationImage(
                image: AssetImage('assets/images/ads/landingMainImage.png'),
                fit: BoxFit
                    .contain, // En-boy oranını korur, küçülür ama kesilmez
              ),
            ),
          ),
        );
      },
    );
  }

  /// Advertisement image (Mobile)
  Widget _buildAdvertisementImageMobile() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        const padding = 32.0; // Sol ve sağ padding toplamı
        final availableWidth = screenWidth - padding;
        final imageWidth = (availableWidth * 0.9).clamp(250.0, 320.0);
        final imageHeight = (imageWidth * 1.18);

        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: imageWidth,
            height: imageHeight,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/ads/landingMainImage.png',
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Background pattern
  Widget _buildBackgroundPattern() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Eğer constraints infinite ise, pattern'ı gösterme
        if (!constraints.hasBoundedHeight || !constraints.hasBoundedWidth) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: List.generate(8, (index) {
                  final angle = (index * 45.0) * (math.pi / 180);
                  final radius = 150 + (index * 30);
                  final x = constraints.maxWidth / 2 +
                      radius *
                          math.cos(angle + _floatAnimation.value * 2 * math.pi);
                  final y = constraints.maxHeight / 2 +
                      radius *
                          math.sin(angle + _floatAnimation.value * 2 * math.pi);

                  return Positioned(
                    left: x,
                    top: y,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  /// Professional logo
  Widget _buildProfessionalLogo() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
            scale: _fadeAnimation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF0EA5E9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Web platformu için optimize edilmiş logo yükleme
                  WebAssetLoader.buildAssetImage(
                    assetPath: 'assets/images/logos/140x140logo.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                    fallback: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Subtle shine effect
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  /// Professional text
  Widget _buildProfessionalText() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Main title
              Text(
                'TAMGACI',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width < 1000 ? 64 : 72,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 24),

              // Subtitle
              Text(
                'Kurumsal Ön Muhasebe Çözümü',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'İşletmenizin muhasebe işlemlerini dijitalleştirin, verimliliğinizi artırın',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Professional buttons
  Widget _buildProfessionalButtons() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Dar ekranlarda dikey düzen
            if (constraints.maxWidth < 500) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Primary button
                  _buildProfessionalButton(
                    text: 'Hemen Başla',
                    onPressed: () => _launchWebApp(),
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  // Secondary button
                  _buildProfessionalButton(
                    text: 'Mobil Uygulamalar',
                    onPressed: () => _scrollToPlatforms(),
                    isPrimary: false,
                  ),
                ],
              );
            }

            // Geniş ekranlarda yatay düzen - esnek butonlar
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Primary button
                Flexible(
                  child: _buildProfessionalButton(
                    text: 'Hemen Başla',
                    onPressed: () => _launchWebApp(),
                    isPrimary: true,
                  ),
                ),
                const SizedBox(width: 12),
                // Secondary button
                Flexible(
                  child: _buildProfessionalButton(
                    text: 'Mobil Uygulamalar',
                    onPressed: () => _scrollToPlatforms(),
                    isPrimary: false,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Professional button
  Widget _buildProfessionalButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isPrimary ? _pulseAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: isPrimary
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF2563EB),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPrimary
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isPrimary ? Icons.arrow_forward : Icons.download,
                    color: isPrimary ? Colors.white : Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Business features section
  Widget _buildBusinessFeatures() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding:
          EdgeInsets.all(MediaQuery.of(context).size.width > 768 ? 80 : 40),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                ],
              )
            : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFE2E8F0),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Neden Tamgacı?',
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.of(context).size.width > 768 ? 56 : 40,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.width > 768 ? 80 : 40),
          // Mobil için dikey düzen, desktop için yatay
          MediaQuery.of(context).size.width > 768
              ? Row(
                  children: [
                    Expanded(
                      child: _buildBusinessFeatureCard(
                        icon: Icons.speed,
                        title: 'Hızlı ve Güvenilir',
                        description:
                            'İşlemlerinizi hızla tamamlayın, verileriniz güvende',
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildBusinessFeatureCard(
                        icon: Icons.security,
                        title: 'Güvenli Altyapı',
                        description:
                            'Bank level güvenlik ile verilerinizi koruyun',
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildBusinessFeatureCard(
                        icon: Icons.cloud_sync,
                        title: 'Bulut Tabanlı',
                        description: 'Her yerden erişim, otomatik yedekleme',
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildBusinessFeatureCard(
                      icon: Icons.speed,
                      title: 'Hızlı ve Güvenilir',
                      description:
                          'İşlemlerinizi hızla tamamlayın, verileriniz güvende',
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 20),
                    _buildBusinessFeatureCard(
                      icon: Icons.security,
                      title: 'Güvenli Altyapı',
                      description:
                          'Bank level güvenlik ile verilerinizi koruyun',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 20),
                    _buildBusinessFeatureCard(
                      icon: Icons.cloud_sync,
                      title: 'Bulut Tabanlı',
                      description: 'Her yerden erişim, otomatik yedekleme',
                      color: const Color(0xFF0EA5E9),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  /// Business feature card
  Widget _buildBusinessFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(isMobile ? 24 : (isTablet ? 32 : 40)),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: Colors.white12, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isMobile ? 80 : (isTablet ? 90 : 100),
            height: isMobile ? 80 : (isTablet ? 90 : 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Icon(
              icon,
              size: isMobile ? 40 : (isTablet ? 45 : 50),
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 24 : (isTablet ? 28 : 32)),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 20 : (isTablet ? 22 : 24),
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : (isTablet ? 15 : 16),
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Platform section
  Widget _buildPlatformSection() {
    return Container(
      padding:
          EdgeInsets.all(MediaQuery.of(context).size.width > 768 ? 80 : 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Tüm Platformlarda',
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.of(context).size.width > 768 ? 56 : 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: _isMobile(context) ? 30 : (_isTablet(context) ? 40 : 50)),
          // Mobil için dikey düzen, tablet ve desktop için yatay
          _isMobile(context)
              ? Column(
                  children: [
                    _buildPlatformCard(
                      icon: Icons.web,
                      title: 'Web',
                      description: 'Tüm Tarayıcılar',
                      color: Colors.white,
                      onTap: () => _launchWebApp(),
                    ),
                    const SizedBox(height: 20),
                    _buildPlatformCard(
                      icon: Icons.phone_android,
                      title: 'Android',
                      description: 'Google Play',
                      color: const Color.fromARGB(255, 62, 255, 184),
                      onTap: () => _launchGooglePlay(),
                    ),
                    const SizedBox(height: 20),
                    _buildPlatformCard(
                      icon: Icons.phone_iphone,
                      title: 'iOS',
                      description: 'App Store',
                      color: const Color.fromARGB(255, 101, 219, 255),
                      onTap: () => _launchAppStore(),
                    ),
                    const SizedBox(height: 20),
                    _buildPlatformCard(
                      icon: Icons.desktop_windows,
                      title: 'Windows',
                      description: 'Masaüstü',
                      color: const Color.fromARGB(255, 248, 179, 122),
                      onTap: () => _launchWindowsApp(),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _buildPlatformCard(
                        icon: Icons.web,
                        title: 'Web',
                        description: 'Tüm Tarayıcılar',
                        color: Colors.white,
                        onTap: () => _launchWebApp(),
                      ),
                    ),
                    SizedBox(width: _isTablet(context) ? 12 : 20),
                    Flexible(
                      child: _buildPlatformCard(
                        icon: Icons.phone_android,
                        title: 'Android',
                        description: 'Google Play',
                        color: const Color.fromARGB(255, 62, 255, 184),
                        onTap: () => _launchGooglePlay(),
                      ),
                    ),
                    SizedBox(width: _isTablet(context) ? 12 : 20),
                    Flexible(
                      child: _buildPlatformCard(
                        icon: Icons.phone_iphone,
                        title: 'iOS',
                        description: 'App Store',
                        color: const Color.fromARGB(255, 101, 219, 255),
                        onTap: () => _launchAppStore(),
                      ),
                    ),
                    SizedBox(width: _isTablet(context) ? 12 : 20),
                    Flexible(
                      child: _buildPlatformCard(
                        icon: Icons.desktop_windows,
                        title: 'Windows',
                        description: 'Masaüstü',
                        color: const Color.fromARGB(255, 248, 179, 122),
                        onTap: () => _launchWindowsApp(),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  /// Platform card
  Widget _buildPlatformCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * math.sin(_floatAnimation.value * 2 * math.pi)),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: isMobile ? double.infinity : 200,
              padding: EdgeInsets.all(isMobile ? 24 : 40),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: isMobile ? 60 : 80,
                    height: isMobile ? 60 : 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: color.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      icon,
                      size: isMobile ? 30 : 40,
                      color: color,
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// About section
  Widget _buildAboutSection() {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);
    final isDesktop = _isDesktopSize(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: _aboutSectionKey,
      padding: EdgeInsets.all(isMobile ? 40 : (isTablet ? 50 : 80)),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : const Color(0xFFF8FAFC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana Başlık
          Center(
            child: Column(
              children: [
                Text(
                  'Hakkımızda',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 54 : 40,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),

          // Şirket Hikayesi - Görsel ve Metin
          (isTablet || isDesktop)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Görsel
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: isTablet ? 400 : 500,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: isDark ? Colors.grey[800] : const Color(0xFFE2E8F0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: isDark ? Colors.grey[800] : const Color(0xFFE2E8F0),
                                child: Center(
                                  child: Icon(
                                    Icons.business_center,
                                    size: 100,
                                    color: isDark ? Colors.grey[400] : const Color(0xFF3B82F6),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 40 : 60),
                    // İçerik
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seek IT Apps',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 36 : 42,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Kurumsal ve KOBİ işletmelerin dijital dönüşüm sürecinde yanlarında olmaktan gurur duyuyoruz. '
                            'Modern teknoloji ve kullanıcı dostu tasarım anlayışımızla, işletmenizin verimliliğini artıracak '
                            'çözümler sunuyoruz.',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 16 : 18,
                              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '2015 yılından beri teknoloji sektöründe faaliyet gösteren ekibimiz, işletmelerin dijitalleşme '
                            'ihtiyaçlarına çözüm üretmek için sürekli kendini geliştirmektedir. TAMGACI, bu deneyimin '
                            've tutkunun bir ürünü olarak ortaya çıkmıştır.',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 16 : 18,
                              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: isDark ? Colors.grey[800] : const Color(0xFFE2E8F0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDark ? Colors.grey[800] : const Color(0xFFE2E8F0),
                              child: Center(
                                child: Icon(
                                  Icons.business_center,
                                  size: 80,
                                  color: isDark ? Colors.grey[400] : const Color(0xFF3B82F6),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Seek IT Apps',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Kurumsal ve KOBİ işletmelerin dijital dönüşüm sürecinde yanlarında olmaktan gurur duyuyoruz. '
                      'Modern teknoloji ve kullanıcı dostu tasarım anlayışımızla, işletmenizin verimliliğini artıracak '
                      'çözümler sunuyoruz.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '2015 yılından beri teknoloji sektöründe faaliyet gösteren ekibimiz, işletmelerin dijitalleşme '
                      'ihtiyaçlarına çözüm üretmek için sürekli kendini geliştirmektedir.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

          const SizedBox(height: 80),

          // Misyon, Vizyon, Değerler Kartları
          (isTablet || isDesktop)
              ? Row(
                  children: [
                    Expanded(
                      child: _buildAboutCard(
                        icon: Icons.flag,
                        title: 'Misyonumuz',
                        description:
                            'İşletmelerin finansal yönetim süreçlerini dijitalleştirerek, onların büyümesine ve '
                            'başarısına katkıda bulunmak. Her işletmenin erişebileceği, kullanımı kolay ve '
                            'güvenilir ön muhasebe çözümleri sunmak.',
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(width: isTablet ? 20 : 30),
                    Expanded(
                      child: _buildAboutCard(
                        icon: Icons.visibility,
                        title: 'Vizyonumuz',
                        description:
                            'Türkiye\'nin önde gelen bulut tabanlı ön muhasebe platformu olmak ve işletmelerin '
                            'dijital dönüşüm yolculuğunda güvenilir bir partner olarak yanlarında yer almak.',
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: isTablet ? 20 : 30),
                    Expanded(
                      child: _buildAboutCard(
                        icon: Icons.favorite,
                        title: 'Değerlerimiz',
                        description:
                            'Müşteri odaklılık, inovasyon, güvenilirlik ve sürekli gelişim değerlerimizle, '
                            'her işletmenin ihtiyacına özel çözümler üretmek için çalışıyoruz.',
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildAboutCard(
                      icon: Icons.flag,
                      title: 'Misyonumuz',
                      description:
                          'İşletmelerin finansal yönetim süreçlerini dijitalleştirerek, onların büyümesine ve '
                          'başarısına katkıda bulunmak. Her işletmenin erişebileceği, kullanımı kolay ve '
                          'güvenilir ön muhasebe çözümleri sunmak.',
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 24),
                    _buildAboutCard(
                      icon: Icons.visibility,
                      title: 'Vizyonumuz',
                      description:
                          'Türkiye\'nin önde gelen bulut tabanlı ön muhasebe platformu olmak ve işletmelerin '
                          'dijital dönüşüm yolculuğunda güvenilir bir partner olarak yanlarında yer almak.',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 24),
                    _buildAboutCard(
                      icon: Icons.favorite,
                      title: 'Değerlerimiz',
                      description:
                          'Müşteri odaklılık, inovasyon, güvenilirlik ve sürekli gelişim değerlerimizle, '
                          'her işletmenin ihtiyacına özel çözümler üretmek için çalışıyoruz.',
                      color: const Color(0xFF0EA5E9),
                    ),
                  ],
                ),

          const SizedBox(height: 80),

          // İstatistikler Bölümü
          Container(
            padding: EdgeInsets.all(isMobile ? 40 : (isTablet ? 50 : 60)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF3B82F6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Rakamlarla Biz',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 32 : (isTablet ? 36 : 40),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                isMobile
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: _buildStatisticItem(
                                  '1000+', 'Mutlu Müşteri', Icons.people),
                              ),
                              Flexible(
                                child: _buildStatisticItem(
                                  '50+', 'Ülkede Hizmet', Icons.language),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: _buildStatisticItem(
                                  '99.9%', 'Uptime', Icons.cloud_done),
                              ),
                              Flexible(
                                child: _buildStatisticItem(
                                  '7/24', 'Destek', Icons.support_agent),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: _buildStatisticItem(
                              '1000+', 'Mutlu Müşteri', Icons.people),
                          ),
                          Flexible(
                            child: _buildStatisticItem(
                              '50+', 'Ülkede Hizmet', Icons.language),
                          ),
                          Flexible(
                            child: _buildStatisticItem(
                              '99.9%', 'Uptime', Icons.cloud_done),
                          ),
                          Flexible(
                            child: _buildStatisticItem(
                              '7/24', 'Destek', Icons.support_agent),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// About card widget
  Widget _buildAboutCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isMobile ? 30 : (isTablet ? 35 : 40)),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: Colors.white12, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 50 : (isTablet ? 55 : 60),
            height: isMobile ? 50 : (isTablet ? 55 : 60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              icon,
              size: isMobile ? 25 : (isTablet ? 28 : 30),
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 20 : (isTablet ? 22 : 24),
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : (isTablet ? 15 : 16),
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  /// Statistic item widget
  Widget _buildStatisticItem(String number, String label, IconData icon) {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);

    return Column(
      children: [
        Icon(
          icon,
          size: isMobile ? 32 : (isTablet ? 36 : 40),
          color: Colors.white.withValues(alpha: 0.9),
        ),
        const SizedBox(height: 16),
        Text(
          number,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 36 : (isTablet ? 42 : 48),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 14 : (isTablet ? 15 : 16),
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Contact section
  Widget _buildContactSection() {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);

    return Container(
      key: _contactSectionKey,
      padding: EdgeInsets.all(isMobile ? 40 : (isTablet ? 50 : 80)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'İletişim',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 40 : (isTablet ? 48 : 56),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 40 : (isTablet ? 60 : 100)),
          // Mobil için dikey düzen, tablet ve desktop için yatay
          isMobile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContactCard(
                      icon: Icons.email,
                      title: 'E-posta',
                      value: 'info@seekitapps.com',
                      onTap: () => _launchEmail(),
                    ),
                    const SizedBox(height: 20),
                    _buildContactCard(
                      icon: Icons.phone,
                      title: 'Telefon',
                      value: '+90 212 976 4939',
                      onTap: () => _launchPhone(),
                    ),
                    const SizedBox(height: 20),
                    _buildContactCard(
                      icon: Icons.location_on,
                      title: 'Adres',
                      value:
                          'Kocamustafapaşa Mah.\nPulcu Sokak, No:28\nFatih, İstanbul',
                      onTap: null,
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: _buildContactCard(
                        icon: Icons.email,
                        title: 'E-posta',
                        value: 'info@seekitapps.com',
                        onTap: () => _launchEmail(),
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 20),
                    Flexible(
                      child: _buildContactCard(
                        icon: Icons.phone,
                        title: 'Telefon',
                        value: '+90 212 976 4939',
                        onTap: () => _launchPhone(),
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 20),
                    Flexible(
                      child: _buildContactCard(
                        icon: Icons.location_on,
                        title: 'Adres',
                        value:
                            'Kocamustafapaşa Mah.\nPulcu Sokak, No:28\nFatih, İstanbul',
                        onTap: null,
                      ),
                    ),
                  ],
                ),
          SizedBox(height: isMobile ? 40 : (isTablet ? 60 : 80)),

          // Öneri, İstek, Şikayet Butonu
          SizedBox(
            width: isMobile ? double.infinity : (isTablet ? 400 : 500),
            child: ElevatedButton.icon(
              onPressed: () => _showFeedbackDialog(context),
              icon: const Icon(Icons.feedback_outlined, size: 24),
              label: Text(
                'Öneri, İstek veya Şikayet',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E3A8A),
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 16 : 20,
                  horizontal: isMobile ? 24 : 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Contact card
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback? onTap,
  }) {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMobile ? double.infinity : (isTablet ? 220 : 300),
        padding: EdgeInsets.all(isMobile ? 24 : (isTablet ? 30 : 40)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: isMobile ? 60 : 80,
              height: isMobile ? 60 : 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: isMobile ? 30 : 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14 : 16,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Professional footer
  Widget _buildProfessionalFooter() {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      padding:
          EdgeInsets.all(MediaQuery.of(context).size.width > 768 ? 60 : 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: isMobile
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol taraf - Şirket adı
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Links
                      _buildFooterLinks(),
                      const SizedBox(height: 20),
                      // Company info
                      Text(
                        '© 2025 Seek IT Apps',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sağ taraf - Vergi bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Vergi Dairesi:',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        'Fatih VD',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vergi No:',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        '4130689211',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol taraf - Links ve şirket adı
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFooterLinks(),
                      const SizedBox(height: 30),
                      Text(
                        '© 2025 Seek IT Apps',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sağ taraf - Vergi bilgileri
                Expanded(
                  child: Text(
                    'Vergi Dairesi: Fatih VD | Vergi No: 4130689211',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
    );
  }

  /// Footer links
  Widget _buildFooterLinks() {
    final isMobile = _isMobile(context);

    if (isMobile) {
      // Mobilde Wrap kullan (overflow'u önlemek için)
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          _buildFooterLink(
            'Hakkımızda',
            () => _scrollToAbout(),
            isMobile,
          ),
          _buildFooterLink(
            'Blog',
            () => context.go('/blog'),
            isMobile,
          ),
          _buildFooterLink(
            'SSS',
            () => context.go('/faq'),
            isMobile,
          ),
          _buildFooterLink(
            'İletişim',
            () => _scrollToContact(),
            isMobile,
          ),
        ],
      );
    }

    // Desktop'ta Wrap kullan (daha fazla alan var)
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildFooterLink(
          'Hakkımızda',
          () => _scrollToAbout(),
          isMobile,
        ),
        _buildFooterLink(
          'Blog',
          () => context.go('/blog'),
          isMobile,
        ),
        _buildFooterLink(
          'SSS',
          () => context.go('/faq'),
          isMobile,
        ),
        _buildFooterLink(
          'İletişim',
          () => _scrollToContact(),
          isMobile,
        ),
      ],
    );
  }

  /// Footer link widget
  Widget _buildFooterLink(String text, VoidCallback onTap, bool isMobile) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 4 : 12,
          vertical: isMobile ? 4 : 6,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 10 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.2,
          ),
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  /// Professional banner
  Widget _buildProfessionalBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: _showBanner
            ? (MediaQuery.of(context).size.width > 768 ? 100 : 80)
            : 0,
        curve: Curves.easeInOut,
        child: _showBanner
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 768 ? 24 : 12,
                  vertical: MediaQuery.of(context).size.width > 768 ? 16 : 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF2563EB),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Banner content - Sol taraf (İkon + Metin)
                    Expanded(
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: MediaQuery.of(context).size.width > 768
                                ? 48
                                : 36,
                            height: MediaQuery.of(context).size.width > 768
                                ? 48
                                : 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width > 768
                                    ? 24
                                    : 18,
                              ),
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width > 768
                                  ? 24
                                  : 18,
                            ),
                          ),

                          SizedBox(
                              width: MediaQuery.of(context).size.width > 768
                                  ? 16
                                  : 12),

                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '30 Gün Ücretsiz Deneyin',
                                  style: GoogleFonts.poppins(
                                    fontSize:
                                        MediaQuery.of(context).size.width > 768
                                            ? 18
                                            : 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  MediaQuery.of(context).size.width > 768
                                      ? 'Hiçbir kredi kartı gerektirmez!'
                                      : 'Kredi kartı gerektirmez!',
                                  style: GoogleFonts.poppins(
                                    fontSize:
                                        MediaQuery.of(context).size.width > 768
                                            ? 14
                                            : 10,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sağ taraf - Banner butonları (tablet ve desktop) + CTA Button
                    if (!_isMobile(context))
                      Flexible(
                        child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Blog ve FAQ Butonları
                            Flexible(
                              child: _buildBannerLinks(),
                            ),
                          SizedBox(width: _isTablet(context) ? 8 : 12),
                          // CTA Button - Sağda sabit
                          _buildBannerCTA(),
                        ],
                        ),
                      )
                    else
                      // Mobilde sadece CTA
                      _buildBannerCTA(),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Banner links (Hakkımızda, Blog, SSS, İletişim)
  Widget _buildBannerLinks() {
    final isDesktop = _isDesktopSize(context);

    return Wrap(
      spacing: _isTablet(context) ? 6 : 8,
      runSpacing: _isTablet(context) ? 6 : 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildBannerLink(
          'Hakkımızda',
          () => _scrollToAbout(),
          isDesktop,
        ),
        _buildBannerLink(
          'Blog',
          () => context.go('/blog'),
          isDesktop,
        ),
        _buildBannerLink(
          'Ücretler',
          () => context.go('/pricing'),
          isDesktop,
        ),
        _buildBannerLink(
          'SSS',
          () => context.go('/faq'),
          isDesktop,
        ),
        _buildBannerLink(
          'İletişim',
          () => _scrollToContact(),
          isDesktop,
        ),
      ],
    );
  }

  /// Banner link button
  Widget _buildBannerLink(String text, VoidCallback onTap, bool isDesktop) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 12 : 10,
          vertical: isDesktop ? 6 : 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 12 : 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Banner CTA button
  Widget _buildBannerCTA() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: () => _launchWebApp(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 768 ? 24 : 16,
                vertical: MediaQuery.of(context).size.width > 768 ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                'Hemen Dene',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width > 768 ? 14 : 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ========== URL LAUNCHER METHODS ==========

  Future<void> _launchWebApp() async {
    if (!mounted) return;
    
    // Firebase Auth durumunu kontrol et
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // Kullanıcı giriş yapmış - dashboard'a yönlendir
      debugPrint('LandingPage: User is signed in, navigating to dashboard');
      if (mounted) {
      context.go('/dashboard');
      }
    } else {
      // Kullanıcı giriş yapmamış - login sayfasına yönlendir
      debugPrint('LandingPage: User is not signed in, navigating to login');
      if (mounted) {
      context.go('/login');
      }
    }
  }

  Future<void> _launchGooglePlay() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.seekitapps.tamgaci';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchAppStore() async {
    const url = 'https://apps.apple.com/app/tamgaci/id123456789';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchWindowsApp() async {
    const url = 'https://www.tamgaci.online/download/tamgaci-setup-latest.exe';

    if (kIsWeb) {
      // Web'de otomatik indirme için HTML5 download attribute kullan
      try {
        final anchor = web.HTMLAnchorElement()
          ..href = url
          ..setAttribute('download', 'tamgaci-setup-latest.exe');
        web.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
      } catch (e) {
        // Fallback: normal URL açma
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        }
      }
    } else {
      // Mobil/Desktop'ta normal URL açma
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  Future<void> _launchEmail() async {
    const url = 'mailto:info@seekitapps.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchPhone() async {
    const url = 'tel:+902129764939';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _scrollToPlatforms() {
    if (!mounted || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      1200,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToAbout() {
    if (!mounted) return;

    final context = _aboutSectionKey.currentContext;
    if (context == null) {
      // Context henüz hazır değilse, bir sonraki frame'de tekrar dene
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToAbout();
        }
      });
      return;
    }

    if (!mounted) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      alignment: 0.1, // Bölümün üst kısmına hizala (banner için offset)
    );
  }

  void _scrollToContact() {
    if (!mounted) return;

    final context = _contactSectionKey.currentContext;
    if (context == null) {
      // Context henüz hazır değilse, bir sonraki frame'de tekrar dene
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToContact();
        }
      });
      return;
    }

    if (!mounted) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      alignment: 0.1, // Bölümün üst kısmına hizala (banner için offset)
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return const FeedbackDialog();
      },
    );
  }
}

/// Feedback Dialog Widget - Öneri, İstek, Şikayet Formu
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Geçerli bir e-posta adresi giriniz';
      }
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9\s\-\+\(\)]+$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Geçerli bir telefon numarası giriniz';
      }
    }
    return null;
  }

  String? _validateEmailOrPhone() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (email.isEmpty && phone.isEmpty) {
      return 'E-posta veya telefon numarasından en az birisi gereklidir';
    }
    return null;
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mesaj zorunludur';
    }
    if (value.trim().length < 10) {
      return 'Mesaj en az 10 karakter olmalıdır';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir kategori seçiniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final emailOrPhoneError = _validateEmailOrPhone();
    if (emailOrPhoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailOrPhoneError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate form submission
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Mesajınız başarıyla gönderildi. En kısa sürede size dönüş yapacağız.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: isDark ? Colors.grey[850] : null,
      child: Container(
        width: isMobile ? double.infinity : 600,
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Öneri, İstek veya Şikayet',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Category Selection
                Text(
                  'Kategori *',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 12),
                // Mobilde yan yana, küçük ekranlarda wrap
                isMobile
                    ? Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip('Öneri', Icons.lightbulb_outline),
                          _buildCategoryChip(
                              'İstek', Icons.request_quote_outlined),
                          _buildCategoryChip('Şikayet', Icons.error_outline),
                        ],
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildCategoryChip('Öneri', Icons.lightbulb_outline),
                          _buildCategoryChip(
                              'İstek', Icons.request_quote_outlined),
                          _buildCategoryChip('Şikayet', Icons.error_outline),
                        ],
                      ),
                const SizedBox(height: 24),

                // Name and Surname Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Ad',
                          hintText: 'Adınız',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _surnameController,
                        decoration: InputDecoration(
                          labelText: 'Soyad',
                          hintText: 'Soyadınız',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'ornek@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 20),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefon',
                    hintText: '0555 123 45 67',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: _validatePhone,
                  style: GoogleFonts.poppins(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    '* E-posta veya telefon numarasından en az birisi gereklidir',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Message
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Mesaj *',
                    hintText:
                        'Öneri, istek veya şikayetinizi detaylı bir şekilde yazınız...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: _validateMessage,
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '* Zorunlu alan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Gönder',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    final isMobile = MediaQuery.of(context).size.width <= 768;
    final colors = {
      'Öneri': const Color(0xFF10B981),
      'İstek': const Color(0xFF3B82F6),
      'Şikayet': const Color(0xFFEF4444),
    };

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isMobile ? 14 : 18,
            color: isSelected ? Colors.white : colors[category],
          ),
          SizedBox(width: isMobile ? 3 : 8),
          Flexible(
            child: Text(
              category,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      selectedColor: colors[category],
      checkmarkColor: Colors.white,
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : colors[category],
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected
            ? colors[category]!
            : colors[category]!.withValues(alpha: 0.3),
        width: 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 16,
        vertical: isMobile ? 6 : 12,
      ),
    );
  }
}
