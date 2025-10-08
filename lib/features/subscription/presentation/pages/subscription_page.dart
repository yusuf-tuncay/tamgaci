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
        showBackButton: false,
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

              // Plan kartları
              _buildPlanCards(plans, isDark),
              const SizedBox(height: 40),

              // Devam et butonu
              _buildContinueButton(),
              const SizedBox(height: 32),

              // Özellikler karşılaştırması
              _buildFeaturesComparison(isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Hero Section - Temiz ve şık tasarım
  Widget _buildHeroSection(User? user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TamgaciConstants.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.diamond,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Başlık
          Text(
            'TAMGACI Premium',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Alt başlık
          Text(
            'Profesyonel ön muhasebe çözümünüz',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Açıklama
          Text(
            'Sınırsız fatura, gelişmiş raporlama ve 7/24 destek',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Plan kartları
  Widget _buildPlanCards(List<sub.SubscriptionPlan> plans, bool isDark) {
    // Planları sırala: Yıllık -> Aylık -> 6 Aylık
    final sortedPlans = List<sub.SubscriptionPlan>.from(plans);
    sortedPlans.sort((a, b) {
      if (a.type == sub.SubscriptionPlanType.annual) return -1;
      if (b.type == sub.SubscriptionPlanType.annual) return 1;
      if (a.type == sub.SubscriptionPlanType.monthly) return -1;
      if (b.type == sub.SubscriptionPlanType.monthly) return 1;
      return 0;
    });

    return Column(
      children: [
        // Başlık
        Text(
          'Planınızı Seçin',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'İhtiyacınıza en uygun planı seçin',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDark ? Colors.white70 : const Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Plan kartları - Sıralı şekilde
        ...sortedPlans.map((plan) {
          final isYearly = plan.type == sub.SubscriptionPlanType.annual;
          final isSelected = _selectedPlan == plan.type;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildPlanCard(plan, isYearly, isSelected, isDark),
          );
        }),
      ],
    );
  }

  /// Plan kartı
  Widget _buildPlanCard(
      sub.SubscriptionPlan plan, bool isYearly, bool isSelected, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? TamgaciConstants.primaryColor
            : isYearly
                ? const Color(0xFF10B981)
                : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? TamgaciConstants.primaryColor
              : isYearly
                  ? const Color(0xFF10B981)
                  : (isDark
                      ? const Color(0xFF333333)
                      : const Color(0xFFE0E0E0)),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? TamgaciConstants.primaryColor.withValues(alpha: 0.3)
                : isYearly
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.1)),
            blurRadius: isSelected
                ? 15
                : isYearly
                    ? 12
                    : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedPlan = plan.type),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge ve Plan adı
                Row(
                  children: [
                    if (isYearly)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'EN İYİ DEĞER',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isYearly) const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        plan.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isYearly
                                  ? Colors.white
                                  : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Plan açıklaması
                Text(
                  plan.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : isYearly
                            ? Colors.white.withValues(alpha: 0.9)
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF666666)),
                  ),
                ),
                const SizedBox(height: 16),

                // Fiyat bölümü
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.1)
                        : isYearly
                            ? Colors.white.withValues(alpha: 0.1)
                            : (isDark ? const Color(0xFF333333) : const Color(0xFFF8F9FA)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₺${plan.price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : isYearly
                                      ? Colors.white
                                      : TamgaciConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/${plan.durationMonths == 1 ? 'ay' : plan.durationMonths == 6 ? '6 ay' : 'yıl'}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : isYearly
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : (isDark
                                          ? Colors.white70
                                          : const Color(0xFF666666)),
                            ),
                          ),
                        ],
                      ),
                      // Yıllık plan için aylık fiyat
                      if (isYearly) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Aylık ₺${(plan.price / 12).toStringAsFixed(0)} - %50 Tasarruf!',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Özellikler (sadece ilk 3 tanesini göster)
                ...plan.features.take(3).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : isYearly
                                    ? Colors.white
                                    : TamgaciConstants.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : isYearly
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : (isDark
                                            ? Colors.white70
                                            : const Color(0xFF666666)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                
                // Daha fazla özellik varsa göster
                if (plan.features.length > 3) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${plan.features.length - 3} özellik daha',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.7)
                          : isYearly
                              ? Colors.white.withValues(alpha: 0.7)
                              : (isDark ? Colors.white60 : const Color(0xFF999999)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Devam et butonu
  Widget _buildContinueButton() {
    final isYearlySelected = _selectedPlan == sub.SubscriptionPlanType.annual;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _selectedPlan != null
            ? (isYearlySelected
                ? const Color(0xFF10B981)
                : TamgaciConstants.primaryColor)
            : const Color(0xFF9CA3AF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _selectedPlan != null
            ? [
                BoxShadow(
                  color: (isYearlySelected
                          ? const Color(0xFF10B981)
                          : TamgaciConstants.primaryColor)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectedPlan != null ? _onContinuePressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              _selectedPlan != null
                  ? (isYearlySelected
                      ? 'Yıllık Planı Seç - En İyi Değer!'
                      : 'Planı Seç ve Devam Et')
                  : 'Plan Seçin',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Özellikler karşılaştırması
  Widget _buildFeaturesComparison(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
          Icon(Icons.warning, color: Colors.red[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isTrialExpired
                  ? 'Deneme süreniz dolmuş. Devam etmek için abonelik alın.'
                  : 'Aboneliğiniz süresi dolmuş. Yenilemek için abonelik alın.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Deneme süresi bilgisi
  Widget _buildTrialInfo(User user) {
    final now = DateTime.now();
    final remaining = user.trialEndAt!.difference(now).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.orange[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Deneme süreniz: $remaining gün kaldı',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlatformPaymentWidget(
          planType: _selectedPlan!,
          user: user,
          amount: PricingConfig.getPriceForPlan(_selectedPlan!),
        ),
      ),
    );
  }
}
