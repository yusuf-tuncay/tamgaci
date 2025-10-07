// ========== SUBSCRIPTION ENTITY ==========
// lib/features/subscription/domain/entities/subscription_entity.dart

import 'subscription_plan.dart';

/// Abonelik durumu enum'u
enum SubscriptionStatus {
  none,        // Abonelik yok
  trial,       // Deneme süresi
  active,      // Aktif abonelik
  expired,     // Süresi dolmuş
  canceled,    // İptal edilmiş
  suspended,   // Askıya alınmış
}

/// Ödeme sağlayıcısı enum'u
enum PaymentProvider {
  paytr,       // PayTR (Web/Windows)
  appStore,    // iOS App Store
  playStore,   // Android Play Store
  manual,      // Manuel ödeme
}

/// Abonelik entity'si
class SubscriptionEntity {
  /// Abonelik ID'si
  final String id;

  /// Kullanıcı ID'si
  final String userId;

  /// Plan tipi
  final SubscriptionPlanType planType;

  /// Abonelik durumu
  final SubscriptionStatus status;

  /// Ödeme sağlayıcısı
  final PaymentProvider provider;

  /// Başlangıç tarihi
  final DateTime startDate;

  /// Bitiş tarihi
  final DateTime endDate;

  /// Ödeme tutarı
  final double amount;

  /// Para birimi
  final String currency;

  /// Otomatik yenileme aktif mi?
  final bool autoRenew;

  /// PayTR transaction token (varsa)
  final String? paytrToken;

  /// App Store receipt (varsa)
  final String? appStoreReceipt;

  /// Play Store purchase token (varsa)
  final String? playStorePurchaseToken;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.planType,
    required this.status,
    required this.provider,
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.currency = 'TRY',
    this.autoRenew = false,
    this.paytrToken,
    this.appStoreReceipt,
    this.playStorePurchaseToken,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Abonelik aktif mi?
  bool get isActive => status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);

  /// Deneme süresi mi?
  bool get isTrial => status == SubscriptionStatus.trial;

  /// Süresi dolmuş mu?
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Kalan gün sayısı
  int get remainingDays {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// JSON'dan oluştur
  factory SubscriptionEntity.fromJson(Map<String, dynamic> json) {
    return SubscriptionEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planType: SubscriptionPlanType.values.firstWhere(
        (e) => e.name == json['planType'],
        orElse: () => SubscriptionPlanType.none,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.none,
      ),
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => PaymentProvider.manual,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      autoRenew: json['autoRenew'] as bool? ?? false,
      paytrToken: json['paytrToken'] as String?,
      appStoreReceipt: json['appStoreReceipt'] as String?,
      playStorePurchaseToken: json['playStorePurchaseToken'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planType': planType.name,
      'status': status.name,
      'provider': provider.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'autoRenew': autoRenew,
      'paytrToken': paytrToken,
      'appStoreReceipt': appStoreReceipt,
      'playStorePurchaseToken': playStorePurchaseToken,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Kopyala
  SubscriptionEntity copyWith({
    String? id,
    String? userId,
    SubscriptionPlanType? planType,
    SubscriptionStatus? status,
    PaymentProvider? provider,
    DateTime? startDate,
    DateTime? endDate,
    double? amount,
    String? currency,
    bool? autoRenew,
    String? paytrToken,
    String? appStoreReceipt,
    String? playStorePurchaseToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      status: status ?? this.status,
      provider: provider ?? this.provider,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      autoRenew: autoRenew ?? this.autoRenew,
      paytrToken: paytrToken ?? this.paytrToken,
      appStoreReceipt: appStoreReceipt ?? this.appStoreReceipt,
      playStorePurchaseToken: playStorePurchaseToken ?? this.playStorePurchaseToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
