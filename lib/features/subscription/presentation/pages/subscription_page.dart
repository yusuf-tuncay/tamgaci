// ========== SUBSCRIPTION PAGE ==========
// lib/features/subscription/presentation/pages/subscription_page.dart

import 'dart:async';
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
import '../../../../core/services/payment/paytr_service.dart';
import 'package:web/web.dart' as web;

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
      setState(() {
        final now = DateTime.now();
        final targetDate = DateTime(2026, 1, 1);
        _timeRemaining = targetDate.difference(now);

        if (_timeRemaining.isNegative) {
          _timeRemaining = Duration.zero;
          timer.cancel();
        }
      });
    });
  }

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

              // Lansman bilgisi (sadece lansman döneminde göster)
              if (PricingConfig.isLaunchPeriod) ...[
                _buildLaunchInfo(isDark),
                const SizedBox(height: 32),
              ],

              // Durum mesajı
              if (widget.isTrialExpired || widget.isExpired) ...[
                _buildStatusMessage(),
                const SizedBox(height: 32),
              ],

              // Kullanım süresi bilgisi (trial veya aktif abonelik)
              if (user != null && _shouldShowUsageInfo(user)) ...[
                _buildUsageInfo(user),
                const SizedBox(height: 32),
              ],

              // Features Card
              _buildFeaturesCard(isDark),
              const SizedBox(height: 32),

              // Plan Cards (3 yan yana)
              _buildPlanCardsRow(plans, isDark),
              const SizedBox(height: 32),

              // Dynamic Continue Button
              _buildDynamicContinueButton(isDark),
            ],
          ),
        ),
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
      child: Column(
        children: [
          Row(
            children: [
              // Icon
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
              // Text
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
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Countdown (sadece lansman döneminde göster, altta iki yana yaslı)
          if (PricingConfig.isLaunchPeriod) ...[
            const SizedBox(height: 16),
            _buildCountdownDisplay(),
          ],
        ],
      ),
    );
  }

  /// Geri sayım display
  Widget _buildCountdownDisplay() {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeUnit(days.toString(), 'Gün'),
        const SizedBox(width: 8),
        _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Saat'),
        const SizedBox(width: 8),
        _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Dakika'),
        const SizedBox(width: 8),
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
              fontSize: 22,
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

  /// Hero Section
  Widget _buildHeroSection(User? user, bool isDark) {
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
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(
              'assets/images/logos/140x140logo.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'TAMGACI',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Süre seçin, tüm özellikler dahil',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Özellikler kartı
  Widget _buildFeaturesCard(bool isDark) {
    final features = [
      'Sınırsız satış ve fatura oluşturma',
      'Tüm raporlara erişim',
      'Müşteri ve tedarikçi yönetimi',
      'Stok takibi ve ürün yönetimi',
      'Çoklu para birimi desteği',
      'Mobil uygulama erişimi',
      '7/24 teknik destek',
      'Otomatik yedekleme',
      'E-fatura entegrasyonu',
      'Banka hesap yönetimi',
      'Kasa işlemleri',
      'Alış/satış faturaları',
      'KDV hesaplamaları',
      'İndirim ve kampanya yönetimi',
      'Ürün varyantları',
      'Toplu işlemler',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TAMGACI Özellikleri',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Tüm özellikler her planda dahil',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Özellikler grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: TamgaciConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      features[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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

    return Row(
      children: sortedPlans.map((plan) {
        final isSelected = _selectedPlan == plan.type;
        final isYearly = plan.type == sub.SubscriptionPlanType.annual;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCompactPlanCard(plan, isSelected, isYearly, isDark),
          ),
        );
      }).toList(),
    );
  }

  /// Kompakt plan kartı
  Widget _buildCompactPlanCard(
      sub.SubscriptionPlan plan, bool isSelected, bool isYearly, bool isDark) {
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
                ? TamgaciConstants.primaryColor.withValues(alpha: 0.2)
                : isYearly
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.2)
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge
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
                const SizedBox(height: 8),

                // Plan adı
                Text(
                  plan.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : isYearly
                            ? Colors.white
                            : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Fiyat
                Text(
                  '₺${plan.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : isYearly
                            ? Colors.white
                            : TamgaciConstants.primaryColor,
                  ),
                ),
                Text(
                  '/${plan.durationMonths == 1 ? 'ay' : plan.durationMonths == 6 ? '6 ay' : 'yıl'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : isYearly
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF666666)),
                  ),
                ),

                // Aylık fiyat breakdown
                if (plan.durationMonths > 1) ...[
                  const SizedBox(height: 4),
                  Text(
                    '₺${(plan.price / plan.durationMonths).toStringAsFixed(0)}/ay',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : isYearly
                              ? Colors.white.withValues(alpha: 0.9)
                              : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF666666)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Ana avantaj
                Text(
                  _getMainAdvantage(plan.type),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : isYearly
                            ? Colors.white.withValues(alpha: 0.9)
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF666666)),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Plan tipine göre badge rengi
  Color _getBadgeColor(sub.SubscriptionPlanType type) {
    switch (type) {
      case sub.SubscriptionPlanType.monthly:
        return Colors.blue;
      case sub.SubscriptionPlanType.semiAnnual:
        return Colors.purple;
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
        return 'Esnek ödeme';
      case sub.SubscriptionPlanType.semiAnnual:
        return '%16 tasarruf';
      case sub.SubscriptionPlanType.annual:
        return '%33 tasarruf';
      case sub.SubscriptionPlanType.none:
        return '';
    }
  }

  /// Dinamik devam et butonu
  Widget _buildDynamicContinueButton(bool isDark) {
    if (_selectedPlan == null) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Plan Seçin',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final isYearly = _selectedPlan == sub.SubscriptionPlanType.annual;
    final isSixMonth = _selectedPlan == sub.SubscriptionPlanType.semiAnnual;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isYearly
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : isSixMonth
                  ? [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
                  : [TamgaciConstants.primaryColor, const Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isYearly
                    ? const Color(0xFF10B981)
                    : isSixMonth
                        ? const Color(0xFF8B5CF6)
                        : TamgaciConstants.primaryColor)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onContinuePressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                isYearly
                    ? Icons.local_fire_department
                    : isSixMonth
                        ? Icons.rocket_launch
                        : Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              // Text
              Text(
                _getButtonText(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
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

  /// Buton metni
  String _getButtonText() {
    switch (_selectedPlan) {
      case sub.SubscriptionPlanType.monthly:
        return 'Aylık Planı Başlat';
      case sub.SubscriptionPlanType.semiAnnual:
        return '6 Aylık Planı Başlat';
      case sub.SubscriptionPlanType.annual:
        return 'Yıllık Planı Başlat - En İyi Değer!';
      default:
        return 'Plan Seçin';
    }
  }

  /// Durum mesajı
  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red[700],
            size: 24,
          ),
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

  /// Kullanım süresi bilgisini göstermeli mi?
  bool _shouldShowUsageInfo(User user) {
    // Trial kullanıcılar için
    if (user.trialEndAt != null && !widget.isTrialExpired) {
      return true;
    }

    // Aktif abonelik kullanıcıları için
    if (user.subscriptionStatus == SubscriptionStatus.active &&
        user.subscriptionEndAt != null) {
      return true;
    }

    return false;
  }

  /// Kullanım süresi bilgisi (trial veya aktif abonelik)
  Widget _buildUsageInfo(User user) {
    final now = DateTime.now();

    // Trial kullanıcı
    if (user.trialEndAt != null && !widget.isTrialExpired) {
      return _buildTrialUsageInfo(user, now);
    }

    // Aktif abonelik kullanıcı
    if (user.subscriptionStatus == SubscriptionStatus.active &&
        user.subscriptionEndAt != null) {
      return _buildSubscriptionUsageInfo(user, now);
    }

    return const SizedBox.shrink();
  }

  /// Trial kullanım süresi bilgisi
  Widget _buildTrialUsageInfo(User user, DateTime now) {
    final trialEnd = user.trialEndAt!;
    final remainingDays = trialEnd.difference(now).inDays;
    final remainingHours = trialEnd.difference(now).inHours % 24;

    // Trial başlangıç tarihi varsa kullanım bilgisi
    String? usageInfo;
    if (user.trialStartAt != null) {
      final trialStart = user.trialStartAt!;
      final totalTrialDays = trialEnd.difference(trialStart).inDays;
      final usedDays = now.difference(trialStart).inDays;
      usageInfo = 'Kullanım: $usedDays/$totalTrialDays gün';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deneme Süreniz',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                    Text(
                      remainingDays > 0
                          ? '$remainingDays gün, $remainingHours saat kaldı'
                          : 'Deneme süreniz doldu',
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
          if (usageInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    usageInfo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Abonelik kullanım süresi bilgisi
  Widget _buildSubscriptionUsageInfo(User user, DateTime now) {
    final subEnd = user.subscriptionEndAt!;
    final remainingDays = subEnd.difference(now).inDays;
    final remainingHours = subEnd.difference(now).inHours % 24;

    // Abonelik başlangıç tarihi varsa kullanım bilgisi
    String? usageInfo;
    if (user.subscriptionStartAt != null) {
      final subStart = user.subscriptionStartAt!;
      final usedDays = now.difference(subStart).inDays;
      usageInfo = 'Kullanım: $usedDays gün';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[50]!,
            Colors.green[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktif Aboneliğiniz',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      remainingDays > 0
                          ? '$remainingDays gün, $remainingHours saat kaldı'
                          : 'Abonelik süreniz doldu',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (usageInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    usageInfo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Devam et butonuna basıldığında
  void _onContinuePressed() async {
    if (_selectedPlan == null) return;

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // PayTR token oluştur
      final paytrService = PaytrService();
      final currentUser = ref.read(currentUserProvider).value!;
      final tokenResponse = await paytrService.createPaymentToken(
        user: currentUser,
        planType: _selectedPlan!,
        amount: PricingConfig.getPriceForPlan(_selectedPlan!),
        userAddress: currentUser.address, // Kullanıcı adresini geç
      );

      // Loading'i kapat
      Navigator.of(context).pop();

      if (tokenResponse.success) {
        // PayTR ödeme sayfasına yönlendir
        final iframeUrl =
            'https://www.paytr.com/odeme/guvenli/${tokenResponse.token}';
        web.window.location.href = iframeUrl;
      } else {
        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Ödeme sayfası oluşturulamadı: ${tokenResponse.error ?? 'Bilinmeyen hata'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      Navigator.of(context).pop();

      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ödeme sayfası oluşturulamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
