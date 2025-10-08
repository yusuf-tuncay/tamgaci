// ========== SUBSCRIPTION PAGE ==========
// lib/features/subscription/presentation/pages/subscription_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/services/subscription/pricing_config.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/subscription_plan.dart' as sub;
import '../widgets/platform_payment_widget.dart';

/// Abonelik sayfası
class SubscriptionPage extends ConsumerStatefulWidget {
  /// Deneme süresi dolmuş mu?
  final bool isTrialExpired;

  /// Abonelik süresi dolmuş mu?
  final bool isExpired;

  /// Yönlendirme sebebi
  final String? reason;

  const SubscriptionPage({
    super.key,
    this.isTrialExpired = false,
    this.isExpired = false,
    this.reason,
  });

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  sub.SubscriptionPlanType? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final plans = PricingConfig.getAllPlans();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveScaffold(
      drawerContent: const SizedBox.shrink(),
      appBar: const CustomAppBar(
        title: 'Abonelik Planları',
        showBackButton: false, // Geri dönüşü engelle
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              _buildHeroSection(user, isDark),
              const SizedBox(height: 40),

              // Durum mesajı
              if (widget.isTrialExpired || widget.isExpired) ...[
                _buildStatusMessage(),
                const SizedBox(height: 32),
              ],

              // Deneme süresi bilgisi (aktifse)
              if (user?.trialEndAt != null && !widget.isTrialExpired) ...[
                _buildTrialInfo(user!),
                const SizedBox(height: 32),
              ],

              // Premium Plan Cards
              _buildPremiumPlanCards(plans.map((p) => p.type).toList(), isDark),
              const SizedBox(height: 40),

              // Devam et butonu
              _buildPremiumContinueButton(),
              const SizedBox(height: 32),

              // Özellikler karşılaştırması
              _buildPremiumFeaturesComparison(isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Hero Section - Ultra Premium başlık ve açıklama
  Widget _buildHeroSection(User? user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Deep blue
            Color(0xFF3B82F6), // Blue
            Color(0xFF60A5FA), // Light blue
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          Column(
            children: [
              // Premium Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'PREMIUM',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Main Icon with glow effect
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Başlık
              Text(
                'TAMGACI Premium',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Alt başlık
              Text(
                'Profesyonel ön muhasebe çözümünüz',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Açıklama
              Text(
                'Sınırsız fatura, gelişmiş raporlama ve 7/24 destek',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Premium Plan Cards
  Widget _buildPremiumPlanCards(
      List<sub.SubscriptionPlanType> plans, bool isDark) {
    return Column(
      children: [
        // Başlık
        Text(
          'Planınızı Seçin',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'İhtiyacınıza en uygun planı seçin',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: isDark ? Colors.white70 : const Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Plan kartları - Yıllık planı öne çıkar
        ...plans.map((plan) {
          final isPopular = plan == sub.SubscriptionPlanType.annual; // Yıllık planı popüler yap
          final isYearly = plan == sub.SubscriptionPlanType.annual;

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: _buildUltraPremiumPlanCard(plan, isPopular, isYearly, isDark),
          );
        }),
      ],
    );
  }

  /// Ultra Premium Plan Card - Yıllık plana özel dikkat
  Widget _buildUltraPremiumPlanCard(
      sub.SubscriptionPlanType plan, bool isPopular, bool isYearly, bool isDark) {
    final planData =
        PricingConfig.getAllPlans().firstWhere((p) => p.type == plan);
    final isSelected = _selectedPlan == plan;

    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A), // Deep blue
                  Color(0xFF3B82F6), // Blue
                  Color(0xFF60A5FA), // Light blue
                ],
                stops: [0.0, 0.5, 1.0],
              )
            : isYearly
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF059669), // Emerald
                      Color(0xFF10B981), // Green
                      Color(0xFF34D399), // Light green
                    ],
                    stops: [0.0, 0.5, 1.0],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF2A2A2A),
                            const Color(0xFF1A1A1A),
                          ]
                        : [
                            Colors.white,
                            const Color(0xFFF8F9FA),
                          ],
                  ),
        borderRadius: BorderRadius.circular(28),
        border: isSelected
            ? Border.all(color: const Color(0xFF3B82F6), width: 3)
            : isYearly
                ? Border.all(color: const Color(0xFF10B981), width: 2)
                : Border.all(
                    color:
                        isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                : isYearly
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.1)),
            blurRadius: isSelected ? 25 : isYearly ? 20 : 10,
            offset: const Offset(0, 8),
            spreadRadius: isSelected ? 2 : isYearly ? 1 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedPlan = plan),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium badges
                Row(
                  children: [
                    if (isYearly)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'EN İYİ DEĞER',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isYearly) const SizedBox(width: 12),
                    if (isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'ÖNERİLEN',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (isYearly || isPopular) const SizedBox(height: 24),

                // Plan adı
                Text(
                  planData.name,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? Colors.white
                        : isYearly
                            ? const Color(0xFF059669)
                            : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                ),
                const SizedBox(height: 12),

                // Plan açıklaması
                Text(
                  planData.description,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : isYearly
                            ? const Color(0xFF047857)
                            : (isDark ? Colors.white70 : const Color(0xFF666666)),
                  ),
                ),
                const SizedBox(height: 28),

                // Fiyat bölümü
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.15)
                        : isYearly
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : isYearly
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₺${planData.price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.white
                                  : isYearly
                                      ? const Color(0xFF059669)
                                      : TamgaciConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '/${planData.durationMonths == 1 ? 'ay' : planData.durationMonths == 6 ? '6 ay' : 'yıl'}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : isYearly
                                      ? const Color(0xFF047857)
                                      : (isDark ? Colors.white70 : const Color(0xFF666666)),
                            ),
                          ),
                        ],
                      ),
                      if (isYearly) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Aylık ₺${(planData.price / 12).toStringAsFixed(0)} - %50 Tasarruf!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Özellikler
                ...planData.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : isYearly
                                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                      : TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : isYearly
                                      ? const Color(0xFF10B981)
                                      : TamgaciConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : isYearly
                                        ? const Color(0xFF047857)
                                        : (isDark ? Colors.white70 : const Color(0xFF666666)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 28),

                // Seçim göstergesi
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : isYearly
                            ? const Color(0xFF10B981)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ultra Premium Continue Button
  Widget _buildPremiumContinueButton() {
    final isYearlySelected = _selectedPlan == sub.SubscriptionPlanType.annual;
    
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: _selectedPlan != null
            ? (isYearlySelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF059669), // Emerald
                      Color(0xFF10B981), // Green
                      Color(0xFF34D399), // Light green
                    ],
                    stops: [0.0, 0.5, 1.0],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E3A8A), // Deep blue
                      Color(0xFF3B82F6), // Blue
                      Color(0xFF60A5FA), // Light blue
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ))
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _selectedPlan != null
            ? [
                BoxShadow(
                  color: isYearlySelected
                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                      : const Color(0xFF3B82F6).withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectedPlan != null ? _onContinuePressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedPlan != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isYearlySelected ? Icons.local_fire_department : Icons.diamond,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Text(
                    _selectedPlan != null
                        ? (isYearlySelected
                            ? 'Yıllık Planı Seç - En İyi Değer!'
                            : 'Planı Seç ve Devam Et')
                        : 'Plan Seçin',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_selectedPlan != null) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Premium Features Comparison
  Widget _buildPremiumFeaturesComparison(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tüm Premium Özellikler',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),

          // Özellik listesi
          ..._getAllFeatures().map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TamgaciConstants.primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: TamgaciConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Tüm özellikleri getir
  List<String> _getAllFeatures() {
    return [
      'Sınırsız fatura oluşturma',
      'Gelişmiş raporlama sistemi',
      'Multi-currency desteği',
      'Otomatik yedekleme',
      '7/24 teknik destek',
      'Mobil uygulama erişimi',
      'API entegrasyonu',
      'Özel fatura şablonları',
      'Gelişmiş stok yönetimi',
      'Müşteri portalı',
    ];
  }

  /// Durum mesajı
  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isTrialExpired
                      ? 'Deneme süreniz sona erdi'
                      : 'Abonelik süreniz sona erdi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tamgacı\'yı kullanmaya devam etmek için bir plan seçin.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Deneme süresi bilgisi
  Widget _buildTrialInfo(User user) {
    final remainingDays = user.trialEndAt!.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.blue[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '30 Günlük Ücretsiz Deneme',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kalan süre: $remainingDays gün',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Devam et butonuna tıklandığında
  void _onContinuePressed() {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (_selectedPlan == null || user == null) return;

    final plan =
        PricingConfig.getAllPlans().firstWhere((p) => p.type == _selectedPlan);

    // Platform-specific ödeme sayfasına yönlendir
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlatformPaymentWidget(
          user: user,
          planType: _selectedPlan!,
          amount: plan.price,
          onPaymentSuccess: () {
            Navigator.of(context).pop(); // Ödeme sayfasını kapat
            _showPaymentSuccessDialog();
          },
          onPaymentFailed: () {
            Navigator.of(context).pop(); // Ödeme sayfasını kapat
            _showPaymentFailedDialog();
          },
          onPaymentCancelled: () {
            Navigator.of(context).pop(); // Ödeme sayfasını kapat
            _showPaymentCancelledDialog();
          },
        ),
      ),
    );
  }

  /// Başarılı ödeme dialog'u
  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            Text(
              'Ödeme Başarılı!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        content: Text(
          'Aboneliğiniz başarıyla oluşturuldu. Artık tüm özellikleri kullanabilirsiniz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialog'u kapat
              Navigator.of(context).pop(); // Subscription sayfasını kapat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Tamam',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Başarısız ödeme dialog'u
  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            Text(
              'Ödeme Başarısız',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        content: Text(
          'Ödeme işlemi başarısız oldu. Lütfen tekrar deneyin.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Tamam',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// İptal edilen ödeme dialog'u
  void _showPaymentCancelledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.orange[600], size: 28),
            const SizedBox(width: 12),
            Text(
              'Ödeme İptal Edildi',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
        content: Text(
          'Ödeme işlemi iptal edildi. İstediğiniz zaman tekrar deneyebilirsiniz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Tamam',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
