// ========== KURUMSAL LANDING PAGE ==========
// lib/features/landing/presentation/pages/landing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'dart:html' as html show AnchorElement, document;

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
  bool _showBanner = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkDeviceType();
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
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    _floatController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  Future<void> _checkDeviceType() async {
    if (kIsWeb) {
      final deviceInfo = DeviceInfoPlugin();
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      setState(() {
        _isDesktop = webBrowserInfo.platform != 'Android' &&
            webBrowserInfo.platform != 'iOS';
      });
    } else {
      // Windows, macOS, Linux için desktop olarak kabul et
      setState(() {
        _isDesktop = true;
      });
    }
  }

  @override
  void dispose() {
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

          // Desktop promo banner
          if (_isDesktop && _showBanner) _buildProfessionalBanner(),
        ],
      ),
    );
  }

  /// Main content with professional design
  Widget _buildMainContent() {
    return SingleChildScrollView(
      controller: _scrollController,
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
      height: MediaQuery.of(context).size.height,
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width > 768 ? 24.0 : 16.0,
                  left: MediaQuery.of(context).size.width > 768 ? 24.0 : 16.0,
                  right: MediaQuery.of(context).size.width > 768 ? 24.0 : 16.0,
                  bottom: MediaQuery.of(context).size.width > 768 ? 24.0 : 16.0,
                ),
                child: MediaQuery.of(context).size.width > 768
                    ? Row(
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Professional logo - üst ve alt margin ile
                          Container(
                            margin: const EdgeInsets.only(top: 120),
                            child: _buildProfessionalLogo(),
                          ),

                          const SizedBox(height: 20),

                          // Professional text
                          _buildProfessionalText(),

                          const SizedBox(height: 20),

                          // Professional buttons
                          _buildProfessionalButtons(),

                          const SizedBox(height: 20),

                          // Reklam görseli (Mobile - butonların altında)
                          _buildAdvertisementImageMobile(),
                        ],
                      ),
              ),
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
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Container(
            width: 250,
            height: 300, // Mobile için daha küçük boyut
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/ads/landingMainImage.png', // Ana görseli kullan
                width: 250,
                height: 300,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Background pattern
  Widget _buildBackgroundPattern() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final angle = (index * 45.0) * (math.pi / 180);
            final radius = 150 + (index * 30);
            final x = MediaQuery.of(context).size.width / 2 +
                radius * math.cos(angle + _floatAnimation.value * 2 * math.pi);
            final y = MediaQuery.of(context).size.height / 2 +
                radius * math.sin(angle + _floatAnimation.value * 2 * math.pi);

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
                  Image.asset(
                    'assets/images/logos/140x140logo.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
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
    return Container(
      padding:
          EdgeInsets.all(MediaQuery.of(context).size.width > 768 ? 80 : 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
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
              color: const Color(0xFF1E3A8A),
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
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isMobile ? 80 : 100,
            height: isMobile ? 80 : 100,
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
              size: isMobile ? 40 : 50,
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 16,
              color: const Color(0xFF64748B),
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
          SizedBox(height: MediaQuery.of(context).size.width > 768 ? 50 : 30),
          // Mobil için dikey düzen, desktop için yatay
          MediaQuery.of(context).size.width > 768
              ? Row(
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
                    const SizedBox(width: 20),
                    Flexible(
                      child: _buildPlatformCard(
                        icon: Icons.phone_android,
                        title: 'Android',
                        description: 'Google Play',
                        color: const Color.fromARGB(255, 62, 255, 184),
                        onTap: () => _launchGooglePlay(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: _buildPlatformCard(
                        icon: Icons.phone_iphone,
                        title: 'iOS',
                        description: 'App Store',
                        color: const Color.fromARGB(255, 101, 219, 255),
                        onTap: () => _launchAppStore(),
                      ),
                    ),
                    const SizedBox(width: 20),
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
                )
              : Column(
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
    return Container(
      padding: const EdgeInsets.all(80),
      child: Column(
        children: [
          Text(
            'Hakkımızda',
            style: GoogleFonts.poppins(
              fontSize: 54,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Seek IT Apps',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Kurumsal ve KOBİ işletmelerin dijital dönüşüm sürecinde yanlarında olmaktan gurur duyuyoruz. '
                  'Modern teknoloji ve kullanıcı dostu tasarım anlayışımızla, işletmenizin verimliliğini artıracak '
                  'çözümler sunuyoruz.',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: const Color(0xFF64748B),
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Contact section
  Widget _buildContactSection() {
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
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'İletişim',
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.of(context).size.width > 768 ? 56 : 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.width > 768 ? 100 : 40),
          // Mobil için dikey düzen, desktop için yatay
          MediaQuery.of(context).size.width > 768
              ? Row(
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
                    Flexible(
                      child: _buildContactCard(
                        icon: Icons.phone,
                        title: 'Telefon',
                        value: '+90 212 976 4939',
                        onTap: () => _launchPhone(),
                      ),
                    ),
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
                )
              : Column(
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
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMobile ? double.infinity : 300,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol taraf - Şirket adı
          Expanded(
            child: Text(
              '© 2025 Seek IT Apps',
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width > 768 ? 20 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),

          // Sağ taraf - Vergi bilgileri
          Expanded(
            child: Text(
              MediaQuery.of(context).size.width > 768
                  ? 'Vergi Dairesi: Fatih VD | Vergi No: 4130689211'
                  : 'Vergi Dairesi: Fatih VD\nVergi No: 4130689211',
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width > 768 ? 16 : 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
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
            ? (MediaQuery.of(context).size.width > 768 ? 100 : 70)
            : 0,
        curve: Curves.easeInOut,
        child: _showBanner
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 768 ? 24 : 12,
                  vertical: MediaQuery.of(context).size.width > 768 ? 16 : 8,
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
                  children: [
                    // Close button
                    GestureDetector(
                      onTap: () => setState(() => _showBanner = false),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Banner content
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
                                ),
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
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // CTA Button
                          _buildBannerCTA(),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
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
    // Firebase Auth durumunu kontrol et
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı giriş yapmış - dashboard'a yönlendir
      debugPrint('LandingPage: User is signed in, navigating to dashboard');
      context.go('/dashboard');
    } else {
      // Kullanıcı giriş yapmamış - login sayfasına yönlendir
      debugPrint('LandingPage: User is not signed in, navigating to login');
      context.go('/login');
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
    const url = 'https://tamgaci.web.app/download/tamgaci-setup-latest.exe';
    
    if (kIsWeb) {
      // Web'de otomatik indirme için HTML5 download attribute kullan
      try {
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'tamgaci-setup-latest.exe')
          ..click();
        // Anchor element'i DOM'a ekle ve sonra kaldır
        html.document.body?.append(anchor);
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
    _scrollController.animateTo(
      1200,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }
}
