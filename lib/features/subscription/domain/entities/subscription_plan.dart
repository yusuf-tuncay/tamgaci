// ========== SUBSCRIPTION PLAN ENTITY ==========
// lib/features/subscription/domain/entities/subscription_plan.dart

/// Abonelik planları enum'u
enum SubscriptionPlanType {
  none,
  monthly,
  semiAnnual,
  annual,
}

/// Abonelik planı entity'si
class SubscriptionPlan {
  /// Plan tipi
  final SubscriptionPlanType type;

  /// Plan adı
  final String name;

  /// Plan açıklaması
  final String description;

  /// Fiyat (TL)
  final double price;

  /// Süre (ay)
  final int durationMonths;

  /// Lansman fiyatı mı?
  final bool isLaunchPrice;

  /// Öne çıkarılacak plan mı?
  final bool isRecommended;

  /// Plan avantajları
  final List<String> features;

  const SubscriptionPlan({
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMonths,
    this.isLaunchPrice = false,
    this.isRecommended = false,
    this.features = const [],
  });

  /// Aylık fiyat hesapla
  double get monthlyPrice => price / durationMonths;

  /// İndirim yüzdesi hesapla (yıllık plana göre)
  double get discountPercentage {
    if (type == SubscriptionPlanType.monthly) return 0.0;
    final monthlyTotal = monthlyPrice * 12;
    final annualPrice = price * (12 / durationMonths);
    return ((monthlyTotal - annualPrice) / monthlyTotal) * 100;
  }

  /// Plan ID'si (PayTR için)
  String get planId {
    switch (type) {
      case SubscriptionPlanType.monthly:
        return 'monthly';
      case SubscriptionPlanType.semiAnnual:
        return 'semi_annual';
      case SubscriptionPlanType.annual:
        return 'annual';
      case SubscriptionPlanType.none:
        return 'none';
    }
  }

  @override
  String toString() => 'SubscriptionPlan(type: $type, name: $name, price: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionPlan && runtimeType == other.runtimeType && type == other.type;

  @override
  int get hashCode => type.hashCode;
}
