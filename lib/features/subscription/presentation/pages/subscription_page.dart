// ========== SUBSCRIPTION PAGE ==========
// lib/features/subscription/presentation/pages/subscription_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/services/subscription/pricing_config.dart';
import '../../../../core/services/subscription/firestore_subscription_service.dart';
import '../../../../core/providers/subscription_state_provider.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/subscription_plan.dart' as sub;
import '../../../../core/services/payment/paytr_service.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Kupon kodu için
  final TextEditingController _couponController = TextEditingController();
  String? _couponMessage;
  bool _isSpecialCouponApplied = false; // 139570 kuponu uygulandı mı?

  // Cache'lenmiş subscription future
  Future<SubscriptionCheckResult>? _cachedSubscriptionFuture;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _cachedSubscriptionFuture = null; // Cache'i temizle
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sayfa her açıldığında otomatik güncelleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoRefreshSubscription();
    });
  }

  /// Otomatik abonelik durumu güncelleme
  void _autoRefreshSubscription() {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      ref
          .read(subscriptionStateProvider.notifier)
          .autoRefreshSubscription(user.id);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _couponController.dispose();
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
        showBackButton: true,
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

              // Abonelik durumu ve kupon kartları (yan yana)
              _buildStatusAndCouponRow(isDark),
              const SizedBox(height: 32),

              // Plan Cards (3 yan yana)
              _buildPlanCardsRow(plans, isDark),
              const SizedBox(height: 32),

              // Geçmiş Satın Alımlar
              if (user != null) ...[
                _buildPurchaseHistorySection(user, isDark),
                const SizedBox(height: 32),
              ],

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 768;

          if (isLargeScreen) {
            // Büyük ekranlar: Timer sağda, yazıyla aynı hizada
            return Row(
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
                // Timer sağda
                if (PricingConfig.isLaunchPeriod) ...[
                  const SizedBox(width: 16),
                  _buildCountdownDisplay(),
                ],
              ],
            );
          } else {
            // Küçük ekranlar: Dikey düzen
            return Column(
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
                // Countdown (sadece lansman döneminde göster, altta ortalanmış)
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
                // Logo ve başlık - yukarıda
                Column(
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
                    const SizedBox(height: 16),
                    // Başlık ve açıklama
                    Text(
                      'TAMGACI',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
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
                const SizedBox(height: 24),
                // Özellikler - 2 sütun halinde
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol sütun özellikler
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: features
                            .take(8)
                            .map((feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
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
                    // Sağ sütun özellikler
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: features
                            .skip(8)
                            .map((feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
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
                        .take(8)
                        .map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
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
                    const SizedBox(height: 16),
                    // Başlık ve açıklama
                    Text(
                      'TAMGACI',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
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
                const SizedBox(width: 16),
                // Sağ sütun özellikler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: features
                        .skip(8)
                        .map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
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
                  _isSpecialCouponApplied
                      ? '₺1'
                      : '₺${plan.price.toStringAsFixed(0)}',
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
                    _isSpecialCouponApplied
                        ? '₺1/ay'
                        : '₺${(plan.price / plan.durationMonths).toStringAsFixed(0)}/ay',
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

      // Özel kupon uygulandıysa fiyatı 1 TL yap (PayTR minimum 1 TL kabul eder)
      final amount = _isSpecialCouponApplied
          ? 1.0
          : PricingConfig.getPriceForPlan(_selectedPlan!);

      final tokenResponse = await paytrService.createPaymentToken(
        user: currentUser,
        planType: _selectedPlan!,
        amount: amount,
        userAddress: currentUser.address, // Kullanıcı adresini geç
      );

      // Loading'i kapat
      Navigator.of(context).pop();

      if (tokenResponse.success) {
        // PayTR ödeme sayfasına yönlendir
        final iframeUrl =
            'https://www.paytr.com/odeme/guvenli/${tokenResponse.token}';

        // Satın alım işlemi başladığında cache'i temizle
        _clearPurchaseHistoryCache();

        if (kIsWeb) {
          // Web için URL'yi yeni sekmede aç
          final uri = Uri.parse(iframeUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('PayTR ödeme sayfası açılamadı');
          }
        } else {
          // Mobile için WebView ile ödeme sayfasını göster
          _showPaymentWebView(context, iframeUrl);
        }
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

  /// PayTR ödeme sayfasını WebView ile göster
  void _showPaymentWebView(BuildContext context, String paymentUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Ödeme'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(paymentUrl))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (NavigationRequest request) {
                    // PayTR callback URL'lerini kontrol et
                    if (request.url.contains('paytr.com/callback')) {
                      // Ödeme tamamlandı, ana sayfaya dön
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              ),
          ),
        ),
      ),
    );
  }

  /// Abonelik durumu ve kupon kartları (yan yana)
  Widget _buildStatusAndCouponRow(bool isDark) {
    return Row(
      children: [
        // Abonelik durumu kartı
        Expanded(
          child: _buildSubscriptionStatusCard(isDark),
        ),
        const SizedBox(width: 16),
        // Kupon kodu kartı
        Expanded(
          child: _buildCouponCard(isDark),
        ),
      ],
    );
  }

  /// Kullanıcının abonelik durumunu gösteren kart
  Widget _buildSubscriptionStatusCard(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        // Cache'lenmiş abonelik durumunu kullan
        final subscriptionState = ref.watch(subscriptionStateProvider);

        if (subscriptionState.isLoading) {
          return _buildLoadingCard(isDark);
        }

        if (subscriptionState.error != null) {
          return _buildErrorCard('Hata: ${subscriptionState.error}', isDark);
        }

        if (subscriptionState.subscriptionResult != null) {
          return _buildSubscriptionStatusWidget(
              subscriptionState.subscriptionResult!, isDark);
        }

        // Fallback: Kullanıcı verilerinden kontrol et
        final user = ref.watch(currentUserProvider);
        return user.when(
          data: (userData) =>
              _buildRealSubscriptionStatusCard(userData, isDark),
          loading: () => _buildLoadingCard(isDark),
          error: (error, stack) => _buildErrorCard('Hata: $error', isDark),
        );
      },
    );
  }

  /// Gerçek abonelik durumu kartı
  Widget _buildRealSubscriptionStatusCard(User? userData, bool isDark) {
    if (userData == null) {
      return _buildErrorCard('Kullanıcı verisi bulunamadı', isDark);
    }

    // Cache'lenmiş future kullan
    return FutureBuilder<SubscriptionCheckResult>(
      future: _cachedSubscriptionFuture ??=
          _getSubscriptionInfoWithFallback(userData, isDark),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(isDark);
        }

        if (snapshot.hasError) {
          return _buildErrorCard('Hata: ${snapshot.error}', isDark);
        }

        final result = snapshot.data!;
        return _buildSubscriptionStatusWidget(result, isDark);
      },
    );
  }

  /// Abonelik bilgilerini al (FirestoreSubscriptionService önce, hata olursa kullanıcı verileri)
  Future<SubscriptionCheckResult> _getSubscriptionInfoWithFallback(
      User userData, bool isDark) async {
    try {
      debugPrint(
          '🔍 SubscriptionPage: Trying FirestoreSubscriptionService first');
      // Önce FirestoreSubscriptionService'i dene
      final result = await FirestoreSubscriptionService()
          .checkUserSubscriptionStatus(userData.id);
      debugPrint(
          '✅ SubscriptionPage: FirestoreSubscriptionService succeeded: ${result.hasAccess}');
      return result;
    } catch (e) {
      debugPrint('❌ SubscriptionPage: FirestoreSubscriptionService failed: $e');
      debugPrint('🔍 SubscriptionPage: Falling back to user data');
      // Hata olursa kullanıcı verilerini kullan
      return _getSubscriptionInfoFromUserData(userData);
    }
  }

  /// Kullanıcı verilerinden abonelik bilgilerini al
  Future<SubscriptionCheckResult> _getSubscriptionInfoFromUserData(
      User userData) async {
    try {
      debugPrint(
          '🔍 SubscriptionPage: Getting subscription info from user data');

      final now = DateTime.now();
      final subscriptionStatus = userData.subscriptionStatus;
      final trialEndAt = userData.trialEndAt;
      final subscriptionEndAt = userData.subscriptionEndAt;

      debugPrint(
          '🔍 SubscriptionPage: subscriptionStatus: $subscriptionStatus');
      debugPrint('🔍 SubscriptionPage: trialEndAt: $trialEndAt');
      debugPrint('🔍 SubscriptionPage: subscriptionEndAt: $subscriptionEndAt');

      // Aktif abonelik kontrolü
      if (subscriptionStatus == SubscriptionStatus.active &&
          subscriptionEndAt != null) {
        if (now.isBefore(subscriptionEndAt)) {
          final remainingDays = subscriptionEndAt.difference(now).inDays;
          debugPrint(
              '✅ SubscriptionPage: Active subscription found, remaining: $remainingDays days');
          return SubscriptionCheckResult(
            hasAccess: true,
            reason: 'Aktif abonelik - Kullanıcı verilerinden',
            remainingDays: remainingDays,
          );
        }
      }

      // Trial kontrolü
      if (subscriptionStatus == SubscriptionStatus.trial &&
          trialEndAt != null) {
        if (now.isBefore(trialEndAt)) {
          final remainingDays = trialEndAt.difference(now).inDays;
          debugPrint(
              '✅ SubscriptionPage: Active trial found, remaining: $remainingDays days');
          return SubscriptionCheckResult(
            hasAccess: true,
            reason: 'Aktif deneme süresi - Kullanıcı verilerinden',
            remainingDays: remainingDays,
          );
        }
      }

      debugPrint('❌ SubscriptionPage: No active subscription or trial found');
      return const SubscriptionCheckResult(
        hasAccess: false,
        reason: 'Abonelik bulunamadı - Kullanıcı verilerinden',
        needsSubscription: true,
      );
    } catch (e) {
      debugPrint('❌ SubscriptionPage: Error getting subscription info: $e');
      return SubscriptionCheckResult(
        hasAccess: false,
        reason: 'Abonelik kontrolü başarısız: $e',
        needsSubscription: true,
      );
    }
  }

  /// Yükleme kartı
  Widget _buildLoadingCard(bool isDark) {
    return Container(
      height: 195,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Hata kartı
  Widget _buildErrorCard(String message, bool isDark) {
    return Container(
      height: 195,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  /// Abonelik durumunu yenile
  void _refreshSubscriptionStatus(WidgetRef ref) async {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      await ref
          .read(subscriptionStateProvider.notifier)
          .refreshSubscription(user.id);
    }
  }

  /// Abonelik durumu widget'ı
  Widget _buildSubscriptionStatusWidget(
      SubscriptionCheckResult result, bool isDark) {
    String text = 'Abonelik: Yok';
    Color backgroundColor;
    Color iconColor;
    Color iconBackgroundColor;

    if (result.hasAccess) {
      if (result.reason.contains('Aktif abonelik')) {
        text = 'Aktif Abonelik';
        backgroundColor =
            isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E8);
        iconColor = Colors.green;
        iconBackgroundColor = Colors.green.withValues(alpha: 0.1);
      } else if (result.reason.contains('Aktif deneme')) {
        text = 'Deneme Süresi';
        backgroundColor =
            isDark ? const Color(0xFF8B4513) : const Color(0xFFFFF3E0);
        iconColor = Colors.orange;
        iconBackgroundColor = Colors.orange.withValues(alpha: 0.1);
      } else {
        text = 'Aktif';
        backgroundColor =
            isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E8);
        iconColor = Colors.green;
        iconBackgroundColor = Colors.green.withValues(alpha: 0.1);
      }
    } else {
      text = 'Abonelik: Yok';
      backgroundColor =
          isDark ? const Color(0xFF8B0000) : const Color(0xFFFFEBEE);
      iconColor = Colors.red;
      iconBackgroundColor = Colors.red.withValues(alpha: 0.1);
    }

    return Container(
      height: 195,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  result.hasAccess ? Icons.check_circle : Icons.cancel,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Abonelik Durumu',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              // Yenile butonu
              Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    onPressed: () => _refreshSubscriptionStatus(ref),
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Yenile',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      result.hasAccess ? Icons.check_circle : Icons.cancel,
                      color: iconColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (result.remainingDays != null) ...[
                  Text(
                    'Kalan: ${result.remainingDays} gün',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : const Color(0xFF666666),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kupon kodu kartı
  Widget _buildCouponCard(bool isDark) {
    return Container(
      height: 195, // Sabit yükseklik - abonelik durumu kartıyla aynı
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kupon Kodu',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _couponController,
            style: GoogleFonts.poppins(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Kupon kodu girin',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.white60 : const Color(0xFF999999),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF444444)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF444444)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.orange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Uygula',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_couponMessage != null) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _couponMessage!.contains('başarılı')
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _couponMessage!.contains('başarılı')
                      ? Colors.green
                      : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _couponMessage!.contains('başarılı')
                        ? Icons.check_circle
                        : Icons.error,
                    color: _couponMessage!.contains('başarılı')
                        ? Colors.green
                        : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _couponMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _couponMessage!.contains('başarılı')
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
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

  /// Kupon kodunu uygula
  void _applyCoupon() {
    final couponCode = _couponController.text.trim();

    if (couponCode.isEmpty) {
      setState(() {
        _couponMessage = 'Lütfen kupon kodunu girin';
      });
      return;
    }

    // TODO: Gerçek kupon doğrulama API'si entegre edilecek
    // Şimdilik basit bir simülasyon
    if (couponCode == '139570') {
      setState(() {
        _couponMessage = 'Özel kupon kodu uygulandı! Tüm fiyatlar sıfırlandı.';
        // TODO: Fiyatları sıfırla - PayTR'a 0 TL gönder
        _applySpecialCoupon();
      });
    } else if (couponCode.toLowerCase() == 'welcome10') {
      setState(() {
        _couponMessage =
            'Kupon kodu başarıyla uygulandı! %10 indirim kazandınız.';
      });
    } else if (couponCode.toLowerCase() == 'launch20') {
      setState(() {
        _couponMessage =
            'Kupon kodu başarıyla uygulandı! %20 indirim kazandınız.';
      });
    } else {
      setState(() {
        _couponMessage = 'Geçersiz kupon kodu. Lütfen tekrar deneyin.';
      });
    }
  }

  /// Özel kupon kodu uygula (139570 - tüm fiyatları sıfırla)
  void _applySpecialCoupon() {
    setState(() {
      _isSpecialCouponApplied = true;
    });

    // TODO: Bu kupon uygulandığında:
    // 1. Tüm plan fiyatlarını 0 TL yap
    // 2. PayTR'a 0 TL gönder
    // 3. Özel kupon durumunu state'te sakla

    debugPrint('Özel kupon 139570 uygulandı - Tüm fiyatlar sıfırlandı');
  }

  /// Geçmiş satın alımlar cache'ini temizle
  void _clearPurchaseHistoryCache() {
    // Bu metod _PurchaseHistoryList widget'ının cache'ini temizlemek için kullanılır
    // Widget'ın onRefresh callback'i ile cache temizlenir
    setState(() {
      // setState çağrısı _PurchaseHistoryList'in onRefresh callback'ini tetikler
    });
  }

  /// Geçmiş satın alımlar bölümü
  Widget _buildPurchaseHistorySection(User user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Geçmiş Satın Alımlar',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPurchaseHistoryList(user, isDark),
        ],
      ),
    );
  }

  /// Geçmiş satın alımlar listesi
  Widget _buildPurchaseHistoryList(User user, bool isDark) {
    return _PurchaseHistoryList(
      userId: user.id,
      isDark: isDark,
      onRefresh: () {
        // Satın alımdan sonra yenileme için callback
        setState(() {});
      },
    );
  }
}

/// Geçmiş satın alımlar listesi widget'ı - cache'li
class _PurchaseHistoryList extends StatefulWidget {
  final String userId;
  final bool isDark;
  final VoidCallback onRefresh;

  const _PurchaseHistoryList({
    required this.userId,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  State<_PurchaseHistoryList> createState() => _PurchaseHistoryListState();
}

class _PurchaseHistoryListState extends State<_PurchaseHistoryList> {
  List<Map<String, dynamic>>? _cachedData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(_PurchaseHistoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sadece userId değişirse yenile
    if (oldWidget.userId != widget.userId) {
      _loadData();
    }
    // onRefresh callback'i çağrıldığında cache'i temizle
    if (oldWidget.onRefresh != widget.onRefresh) {
      _clearCache();
    }
  }

  /// Cache'i temizle ve yeniden yükle
  void _clearCache() {
    setState(() {
      _cachedData = null;
      _error = null;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    if (_cachedData != null) return; // Cache varsa yenileme

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _getPurchaseHistory(widget.userId);
      if (mounted) {
        setState(() {
          _cachedData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getPurchaseHistory(String userId) async {
    try {
      final query = FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'status': data['status'] ?? 'unknown',
          'planType': data['planType'] ?? 'unknown',
          'amount': data['amount'] ?? 0,
          'createdAt': data['createdAt'],
          'endDate': data['endDate'],
          'orderId': data['orderId'] ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching purchase history: $e');
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Geçmiş satın alımlar yüklenirken hata oluştu',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _cachedData = null;
                    _error = null;
                  });
                  _loadData();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cachedData == null || _cachedData!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.grey,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz satın alım geçmişi bulunmuyor',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _cachedData!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final purchase = _cachedData![index];
        return _buildPurchaseHistoryItem(purchase, widget.isDark);
      },
    );
  }

  Widget _buildPurchaseHistoryItem(Map<String, dynamic> purchase, bool isDark) {
    final status = purchase['status'] as String;
    final planType = purchase['planType'] as String;
    final amount = (purchase['amount'] as num).toDouble();
    final createdAt = purchase['createdAt'] as Timestamp?;
    final endDate = purchase['endDate'] as Timestamp?;
    final orderId = purchase['orderId'] as String;

    // Status renkleri
    Color statusColor;
    String statusText;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Aktif';
        break;
      case 'expired':
        statusColor = Colors.red;
        statusText = 'Süresi Dolmuş';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Beklemede';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Bilinmiyor';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: Status ve plan tipi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                planType == 'monthly' ? 'Aylık' : 'Yıllık',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Orta satır: Tutar ve tarih
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₺${amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
              if (createdAt != null)
                Text(
                  _formatDate(createdAt.toDate()),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),

          // Alt satır: Sipariş ID ve bitiş tarihi
          if (orderId.isNotEmpty || endDate != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (orderId.isNotEmpty)
                  Expanded(
                    child: Text(
                      'Sipariş: ${orderId.length > 20 ? '${orderId.substring(0, 20)}...' : orderId}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (endDate != null)
                  Text(
                    'Bitiş: ${_formatDate(endDate.toDate())}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
