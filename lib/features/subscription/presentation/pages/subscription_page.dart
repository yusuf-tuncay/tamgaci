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

  /// Hero Section - Premium başlık ve açıklama
  Widget _buildHeroSection(User? user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TamgaciConstants.primaryColor,
            TamgaciConstants.primaryColorDark,
          ],
        ),
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
          // Premium Icon
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

  /// Premium Plan Cards
  Widget _buildPremiumPlanCards(
      List<sub.SubscriptionPlanType> plans, bool isDark) {
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

        // Plan kartları
        ...plans.map((plan) {
          final isPopular = plan == sub.SubscriptionPlanType.monthly;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: _buildPremiumPlanCard(plan, isPopular, isDark),
          );
        }),
      ],
    );
  }

  /// Premium Plan Card
  Widget _buildPremiumPlanCard(
      sub.SubscriptionPlanType plan, bool isPopular, bool isDark) {
    final planData =
        PricingConfig.getAllPlans().firstWhere((p) => p.type == plan);
    final isSelected = _selectedPlan == plan;

    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TamgaciConstants.primaryColor,
                  TamgaciConstants.primaryColorDark,
                ],
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
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: TamgaciConstants.primaryColor, width: 2)
            : Border.all(
                color:
                    isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? TamgaciConstants.primaryColor.withValues(alpha: 0.3)
                : (isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1)),
            blurRadius: isSelected ? 20 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedPlan = plan),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popular badge
                if (isPopular)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'En Popüler',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isPopular) const SizedBox(height: 16),

                // Plan adı
                Text(
                  planData.name,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                ),
                const SizedBox(height: 8),

                // Plan açıklaması
                Text(
                  planData.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : (isDark ? Colors.white70 : const Color(0xFF666666)),
                  ),
                ),
                const SizedBox(height: 20),

                // Fiyat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺${planData.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : TamgaciConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/${planData.durationMonths == 1 ? 'ay' : planData.durationMonths == 6 ? '6 ay' : 'yıl'}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF666666)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Özellikler
                ...planData.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : TamgaciConstants.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isSelected
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
                const SizedBox(height: 24),

                // Seçim göstergesi
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Premium Continue Button
  Widget _buildPremiumContinueButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TamgaciConstants.primaryColor,
            TamgaciConstants.primaryColorDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectedPlan != null ? _onContinuePressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedPlan != null
                        ? 'Planı Seç ve Devam Et'
                        : 'Plan Seçin',
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
                      child: Icon(
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
