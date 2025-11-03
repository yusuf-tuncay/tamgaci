// ========== PRICING PAGE ==========
// lib/features/landing/presentation/pages/pricing_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/services/subscription/pricing_config.dart';
import '../../../subscription/domain/entities/subscription_plan.dart' as sub;

/// Landing page'den erişilebilen ücretler ve kampanyalar sayfası
class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    // 2026 yılbaşına kadar olan süreyi hesapla
    final now = DateTime.now();
    final targetDate = DateTime(2026, 1, 1);
    _timeRemaining = targetDate.difference(now);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          final targetDate = DateTime(2026, 1, 1);
          _timeRemaining = targetDate.difference(now);

          if (_timeRemaining.isNegative) {
            _timeRemaining = Duration.zero;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final plans = PricingConfig.getAllPlans();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    const Color(0xFFF8FAFF),
                    const Color(0xFFE8F4FD),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with back button
              _buildHeader(isDark),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Section
                      _buildHeroSection(isDark),
                      const SizedBox(height: 40),

                      // Lansman bilgisi (sadece lansman döneminde göster)
                      if (PricingConfig.isLaunchPeriod) ...[
                        _buildLaunchInfo(isDark),
                        const SizedBox(height: 32),
                      ],

                      // Plan Cards (3 yan yana)
                      _buildPlanCardsRow(plans, isDark),
                      const SizedBox(height: 32),

                      // CTA Button
                      _buildCTAButton(isDark),
                      const SizedBox(height: 40),

                      // Features Section
                      _buildFeaturesSection(isDark),
                      const SizedBox(height: 40),

                      // FAQ Section
                      _buildFAQSection(isDark),
                    ],
                  ),
                ),
              ),

              // Footer
              _buildProfessionalFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with back button
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Ücretler ve Kampanyalar',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  /// Hero Section
  Widget _buildHeroSection(bool isDark) {
    final features = [
      'Sınırsız satış ve fatura oluşturma',
      'Tüm raporlara erişim',
      'Müşteri ve tedarikçi yönetimi',
      'Stok takibi ve ürün yönetimi',
      'Çoklu para birimi desteği',
      'Mobil uygulama erişimi',
      '7/24 teknik destek',
      'Otomatik yedekleme',
    ];

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TamgaciConstants.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 768;

          if (isSmallScreen) {
            // Mobil: Logo ve başlık yukarıda, özellikler altında
            return Column(
              children: [
                // Logo ve başlık
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        'assets/images/logos/140x140logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        color: Colors.white,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TAMGACI',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '30 Gün Ücretsiz Deneme',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Süre seçin, tüm özellikler dahil',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Özellikler - tek sütun
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features
                      .map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            );
          } else {
            // Desktop: 3 sütunlu düzen
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol sütun özellikler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features
                        .take(4)
                        .map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 16),
                // Orta sütun - Logo ve başlık
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        'assets/images/logos/140x140logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        color: Colors.white,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TAMGACI',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '30 Gün Ücretsiz Deneme',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Süre seçin, tüm özellikler dahil',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Sağ sütun özellikler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: features
                        .skip(4)
                        .map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  /// Lansman bilgisi
  Widget _buildLaunchInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange[400]!,
            Colors.orange[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 768;

          if (isLargeScreen) {
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lansmana Özel Fiyatlar!',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PricingConfig.getPriceLabel(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (PricingConfig.isLaunchPeriod) ...[
                  const SizedBox(width: 16),
                  _buildCountdownDisplay(),
                ],
              ],
            );
          } else {
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lansmana Özel Fiyatlar!',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            PricingConfig.getPriceLabel(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (PricingConfig.isLaunchPeriod) ...[
                  const SizedBox(height: 16),
                  _buildCountdownDisplay(),
                ],
              ],
            );
          }
        },
      ),
    );
  }

  /// Geri sayım display
  Widget _buildCountdownDisplay() {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTimeUnit(days.toString(), 'Gün'),
        _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Saat'),
        _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Dakika'),
        _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Saniye'),
      ],
    );
  }

  /// Zaman birimi widget'ı
  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  /// 3 yan yana plan kartları
  Widget _buildPlanCardsRow(List<sub.SubscriptionPlan> plans, bool isDark) {
    // Planları sırala: Aylık -> 6 Aylık -> Yıllık
    final sortedPlans = List<sub.SubscriptionPlan>.from(plans);
    sortedPlans.sort((a, b) {
      if (a.type == sub.SubscriptionPlanType.monthly) return -1;
      if (b.type == sub.SubscriptionPlanType.monthly) return 1;
      if (a.type == sub.SubscriptionPlanType.semiAnnual) return -1;
      if (b.type == sub.SubscriptionPlanType.semiAnnual) return 1;
      return 0;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          // Mobilde dikey düzen
          return Column(
            children: sortedPlans.map((plan) {
              final isYearly = plan.type == sub.SubscriptionPlanType.annual;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPlanCard(plan, isYearly, isDark),
              );
            }).toList(),
          );
        } else {
          // Desktop'ta yatay düzen
          return Row(
            children: sortedPlans.map((plan) {
              final isYearly = plan.type == sub.SubscriptionPlanType.annual;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildPlanCard(plan, isYearly, isDark),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  /// Plan kartı
  Widget _buildPlanCard(sub.SubscriptionPlan plan, bool isYearly, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isYearly
            ? const Color(0xFF10B981)
            : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isYearly
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
          width: isYearly ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isYearly
                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                : (isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1)),
            blurRadius: isYearly ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge
          if (isYearly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.purple, // Mor renk
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Text(
                'EN POPÜLER',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge (altında)
                if (!isYearly)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getBadgeColor(plan.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getBadgeText(plan.type),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (!isYearly) const SizedBox(height: 12),

                // Plan adı
                Text(
                  plan.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isYearly
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Fiyat
                Text(
                  '₺${plan.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color:
                        isYearly ? Colors.white : TamgaciConstants.primaryColor,
                  ),
                ),
                Text(
                  '/${plan.durationMonths == 1 ? 'ay' : plan.durationMonths == 6 ? '6 ay' : 'yıl'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isYearly
                        ? Colors.white.withValues(alpha: 0.8)
                        : (isDark ? Colors.white70 : const Color(0xFF666666)),
                  ),
                ),

                // Aylık fiyat breakdown
                if (plan.durationMonths > 1) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isYearly
                          ? Colors.white.withValues(alpha: 0.2)
                          : (isDark
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFFF0F0F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₺${(plan.price / plan.durationMonths).toStringAsFixed(0)}/ay',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isYearly
                            ? Colors.white
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF666666)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Ana avantaj
                Text(
                  _getMainAdvantage(plan.type),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isYearly
                        ? Colors.white.withValues(alpha: 0.9)
                        : (isDark ? Colors.white70 : const Color(0xFF666666)),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Tüm özellikler dahil
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isYearly
                        ? Colors.white.withValues(alpha: 0.1)
                        : (isDark
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFF0F0F0)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isYearly
                          ? Colors.white.withValues(alpha: 0.2)
                          : (isDark
                              ? const Color(0xFF333333)
                              : const Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: isYearly
                            ? Colors.white
                            : TamgaciConstants.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Tüm özellikler dahil',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isYearly
                                ? Colors.white
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A)),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Plan tipine göre badge rengi
  Color _getBadgeColor(sub.SubscriptionPlanType type) {
    switch (type) {
      case sub.SubscriptionPlanType.monthly:
        return Colors.blue;
      case sub.SubscriptionPlanType.semiAnnual:
        return Colors.orange; // Turuncu renk
      case sub.SubscriptionPlanType.annual:
        return Colors.orange;
      case sub.SubscriptionPlanType.none:
        return Colors.grey;
    }
  }

  /// Plan tipine göre badge metni
  String _getBadgeText(sub.SubscriptionPlanType type) {
    switch (type) {
      case sub.SubscriptionPlanType.monthly:
        return 'ESNEK';
      case sub.SubscriptionPlanType.semiAnnual:
        return 'AVANTAJLI';
      case sub.SubscriptionPlanType.annual:
        return 'EN İYİ';
      case sub.SubscriptionPlanType.none:
        return '';
    }
  }

  /// Plan tipine göre ana avantaj
  String _getMainAdvantage(sub.SubscriptionPlanType type) {
    switch (type) {
      case sub.SubscriptionPlanType.monthly:
        return 'Esnek ödeme seçeneği';
      case sub.SubscriptionPlanType.semiAnnual:
        return '%16 tasarruf';
      case sub.SubscriptionPlanType.annual:
        return '%33 tasarruf - En iyi değer!';
      case sub.SubscriptionPlanType.none:
        return '';
    }
  }

  /// CTA Button
  Widget _buildCTAButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            TamgaciConstants.primaryColor,
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/register'),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '30 Gün Ücretsiz Denemeye Başla',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Features Section
  Widget _buildFeaturesSection(bool isDark) {
    final allFeatures = [
      {
        'icon': Icons.receipt_long,
        'title': 'Sınırsız Fatura',
        'desc': 'Sınırsız fatura oluşturma ve yönetimi'
      },
      {
        'icon': Icons.people,
        'title': 'Müşteri Yönetimi',
        'desc': 'Müşteri ve tedarikçi bilgilerini kolayca yönetin'
      },
      {
        'icon': Icons.inventory_2,
        'title': 'Stok Takibi',
        'desc': 'Gerçek zamanlı stok takibi ve ürün yönetimi'
      },
      {
        'icon': Icons.currency_exchange,
        'title': 'Çoklu Para Birimi',
        'desc': 'Birden fazla para birimi desteği'
      },
      {
        'icon': Icons.phone_android,
        'title': 'Mobil Erişim',
        'desc': 'iOS ve Android uygulamaları ile her yerden erişim'
      },
      {
        'icon': Icons.support_agent,
        'title': '7/24 Destek',
        'desc': 'Kesintisiz teknik destek hizmeti'
      },
      {
        'icon': Icons.backup,
        'title': 'Otomatik Yedekleme',
        'desc': 'Verileriniz otomatik olarak yedeklenir'
      },
      {
        'icon': Icons.analytics,
        'title': 'Detaylı Raporlar',
        'desc': 'Kapsamlı finansal raporlar ve analizler'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tüm Özellikler Dahil',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tüm planlarımızda aynı özellikler sunulmaktadır',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDark ? Colors.white70 : const Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            final crossAxisCount = isMobile ? 1 : 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 4 : 3.5,
              ),
              itemCount: allFeatures.length,
              itemBuilder: (context, index) {
                final feature = allFeatures[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TamgaciConstants.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: TamgaciConstants.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              feature['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feature['desc'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// FAQ Section
  Widget _buildFAQSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sıkça Sorulan Sorular',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildFAQItem(
          '30 günlük ücretsiz deneme nedir?',
          'Kayıt olduğunuzda 30 gün boyunca tüm özellikleri ücretsiz kullanabilirsiniz. Kredi kartı bilgisi istemiyoruz.',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'İptal edebilir miyim?',
          'Evet, istediğiniz zaman iptal edebilirsiniz. İptal ettiğinizde aboneliğiniz dönem sonuna kadar devam eder.',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'Hangi ödeme yöntemlerini kabul ediyorsunuz?',
          'Kredi kartı ve banka kartı ile ödeme yapabilirsiniz. Tüm ödemeler güvenli PayTR altyapısı ile işlenir.',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'Fiyat değişikliği olur mu?',
          'Mevcut aboneliğiniz süresince fiyatınız sabit kalır. Yeni dönemde güncel fiyatlar geçerli olur.',
          isDark,
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () => context.go('/faq'),
            child: Text(
              'Tüm SSS\'leri Görüntüle',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// FAQ Item
  Widget _buildFAQItem(String question, String answer, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  /// Professional footer
  Widget _buildProfessionalFooter() {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 30 : 40,
      ),
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
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Links
                _buildFooterLinks(),
                const SizedBox(height: 20),
                // Company info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2025 Seek IT Apps',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Column(
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
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol taraf - Links ve şirket adı
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                Flexible(
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
    final isMobile = MediaQuery.of(context).size.width <= 768;

    if (isMobile) {
      // Mobilde yan yana
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFooterLink(
            'Ana Sayfa',
            () => context.go('/'),
            isMobile,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFooterLink(
            'Blog',
            () => context.go('/blog'),
            isMobile,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFooterLink(
            'Ücretler',
            () => context.go('/pricing'),
            isMobile,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFooterLink(
            'SSS',
            () => context.go('/faq'),
            isMobile,
          ),
        ],
      );
    }

    // Desktop'ta Wrap kullan
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildFooterLink(
          'Ana Sayfa',
          () => context.go('/'),
          isMobile,
        ),
        _buildFooterLink(
          'Blog',
          () => context.go('/blog'),
          isMobile,
        ),
        _buildFooterLink(
          'Ücretler',
          () => context.go('/pricing'),
          isMobile,
        ),
        _buildFooterLink(
          'SSS',
          () => context.go('/faq'),
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
}
