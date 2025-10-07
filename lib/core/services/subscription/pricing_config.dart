// ========== PRICING CONFIG ==========
// lib/core/services/subscription/pricing_config.dart

import '../../../features/subscription/domain/entities/subscription_plan.dart';

/// Fiyatlandırma konfigürasyonu
class PricingConfig {
  /// Lansman bitiş tarihi
  static final DateTime launchEndDate = DateTime(2025, 12, 31);

  /// Şu anda lansman dönemi mi?
  static bool get isLaunchPeriod => DateTime.now().isBefore(launchEndDate);

  /// Lansman dönemi fiyatları (31 Aralık 2025'e kadar)
  static const Map<SubscriptionPlanType, double> _launchPrices = {
    SubscriptionPlanType.monthly: 119.0,
    SubscriptionPlanType.semiAnnual: 599.0,
    SubscriptionPlanType.annual: 949.0,
  };

  /// Lansman sonrası fiyatlar (1 Ocak 2026'dan itibaren)
  static const Map<SubscriptionPlanType, double> _regularPrices = {
    SubscriptionPlanType.monthly: 299.0,
    SubscriptionPlanType.semiAnnual: 1599.0,
    SubscriptionPlanType.annual: 2799.0,
  };

  /// Mevcut fiyatları al
  static Map<SubscriptionPlanType, double> get currentPrices =>
      isLaunchPeriod ? _launchPrices : _regularPrices;

  /// Belirli bir plan için fiyat al
  static double getPriceForPlan(SubscriptionPlanType planType) {
    return currentPrices[planType] ?? 0.0;
  }

  /// Tüm planları al
  static List<SubscriptionPlan> getAllPlans() {
    return [
      // Aylık Plan
      SubscriptionPlan(
        type: SubscriptionPlanType.monthly,
        name: 'Aylık Plan',
        description: 'Aylık ödeme seçeneği',
        price: getPriceForPlan(SubscriptionPlanType.monthly),
        durationMonths: 1,
        isLaunchPrice: isLaunchPeriod,
        features: [
          'Sınırsız fatura oluşturma',
          'Müşteri ve ürün yönetimi',
          'Satış takibi',
          'Raporlama',
          'Mobil erişim',
          '7/24 destek',
        ],
      ),

      // 6 Aylık Plan
      SubscriptionPlan(
        type: SubscriptionPlanType.semiAnnual,
        name: '6 Aylık Plan',
        description: '6 aylık ödeme seçeneği',
        price: getPriceForPlan(SubscriptionPlanType.semiAnnual),
        durationMonths: 6,
        isLaunchPrice: isLaunchPeriod,
        features: [
          'Sınırsız fatura oluşturma',
          'Müşteri ve ürün yönetimi',
          'Satış takibi',
          'Raporlama',
          'Mobil erişim',
          '7/24 destek',
          'Öncelikli destek',
          'Gelişmiş raporlar',
        ],
      ),

      // Yıllık Plan (Önerilen)
      SubscriptionPlan(
        type: SubscriptionPlanType.annual,
        name: 'Yıllık Plan',
        description: 'En avantajlı seçenek',
        price: getPriceForPlan(SubscriptionPlanType.annual),
        durationMonths: 12,
        isLaunchPrice: isLaunchPeriod,
        isRecommended: true,
        features: [
          'Sınırsız fatura oluşturma',
          'Müşteri ve ürün yönetimi',
          'Satış takibi',
          'Raporlama',
          'Mobil erişim',
          '7/24 destek',
          'Öncelikli destek',
          'Gelişmiş raporlar',
          'API erişimi',
          'Özel entegrasyonlar',
          'Veri yedekleme',
        ],
      ),
    ];
  }

  /// Önerilen planı al
  static SubscriptionPlan get recommendedPlan =>
      getAllPlans().firstWhere((plan) => plan.isRecommended);

  /// Fiyat etiketini al
  static String getPriceLabel() {
    return isLaunchPeriod 
        ? 'Lansmana özel fiyat – 31 Aralık\'a kadar geçerli!'
        : 'Güncel fiyatlar';
  }

  /// Deneme süresi (gün)
  static const int trialDays = 30;

  /// Para birimi
  static const String currency = 'TRY';

  /// Para birimi sembolü
  static const String currencySymbol = '₺';
}
