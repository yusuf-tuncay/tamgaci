// ========== PAYMENT METHOD ENTITY ==========
// lib/features/payment_collection/domain/entities/payment_method.dart

import 'package:equatable/equatable.dart';
import 'payment_enums.dart';

/// Ödeme yöntemi entity'si
class PaymentMethod extends Equatable {
  /// Benzersiz ID
  final String id;

  /// Yöntem türü
  final PaymentMethodType type;

  /// Yöntem adı
  final String name;

  /// Açıklama
  final String? description;

  /// Aktif durumu
  final bool isActive;

  /// Varsayılan yöntem mi?
  final bool isDefault;

  /// Yöntem ayarları
  final Map<String, dynamic> settings;

  /// Komisyon oranı (%)
  final double? commissionRate;

  /// Minimum tutar
  final double? minimumAmount;

  /// Maksimum tutar
  final double? maximumAmount;

  /// Günlük limit
  final double? dailyLimit;

  /// Aylık limit
  final double? monthlyLimit;

  /// Onay gerekli mi?
  final bool requiresApproval;

  /// Onay seviyesi
  final PaymentApprovalLevel approvalLevel;

  /// Öncelik seviyesi
  final PaymentPriority priority;

  /// Şirket ID'si
  final String companyId;

  /// Tenant ID'si
  final String tenantId;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  /// Oluşturan kullanıcı
  final String createdBy;

  /// Güncelleyen kullanıcı
  final String? updatedBy;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.isActive = true,
    this.isDefault = false,
    this.settings = const {},
    this.commissionRate,
    this.minimumAmount,
    this.maximumAmount,
    this.dailyLimit,
    this.monthlyLimit,
    this.requiresApproval = false,
    this.approvalLevel = PaymentApprovalLevel.none,
    this.priority = PaymentPriority.normal,
    required this.companyId,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? name,
    String? description,
    bool? isActive,
    bool? isDefault,
    Map<String, dynamic>? settings,
    double? commissionRate,
    double? minimumAmount,
    double? maximumAmount,
    double? dailyLimit,
    double? monthlyLimit,
    bool? requiresApproval,
    PaymentApprovalLevel? approvalLevel,
    PaymentPriority? priority,
    String? companyId,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      settings: settings ?? this.settings,
      commissionRate: commissionRate ?? this.commissionRate,
      minimumAmount: minimumAmount ?? this.minimumAmount,
      maximumAmount: maximumAmount ?? this.maximumAmount,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      approvalLevel: approvalLevel ?? this.approvalLevel,
      priority: priority ?? this.priority,
      companyId: companyId ?? this.companyId,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan PaymentMethod oluştur
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentMethodType.cash,
      ),
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      commissionRate: (json['commissionRate'] as num?)?.toDouble(),
      minimumAmount: (json['minimumAmount'] as num?)?.toDouble(),
      maximumAmount: (json['maximumAmount'] as num?)?.toDouble(),
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble(),
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble(),
      requiresApproval: json['requiresApproval'] as bool? ?? false,
      approvalLevel: PaymentApprovalLevel.values.firstWhere(
        (e) => e.name == json['approvalLevel'],
        orElse: () => PaymentApprovalLevel.none,
      ),
      priority: PaymentPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => PaymentPriority.normal,
      ),
      companyId: json['companyId'] as String,
      tenantId: json['tenantId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// PaymentMethod'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'isActive': isActive,
      'isDefault': isDefault,
      'settings': settings,
      'commissionRate': commissionRate,
      'minimumAmount': minimumAmount,
      'maximumAmount': maximumAmount,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
      'requiresApproval': requiresApproval,
      'approvalLevel': approvalLevel.name,
      'priority': priority.name,
      'companyId': companyId,
      'tenantId': tenantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Yöntem türü görünen adı
  String get typeDisplayName {
    return type.displayName;
  }

  /// Yöntem ikonu
  String get icon {
    return type.icon;
  }

  /// Komisyon hesapla
  double calculateCommission(double amount) {
    if (commissionRate == null) return 0.0;
    return amount * (commissionRate! / 100);
  }

  /// Tutar limitler içinde mi?
  bool isAmountWithinLimits(double amount) {
    if (minimumAmount != null && amount < minimumAmount!) return false;
    if (maximumAmount != null && amount > maximumAmount!) return false;
    return true;
  }

  /// Günlük limit aşıldı mı?
  bool isDailyLimitExceeded(double dailyAmount) {
    if (dailyLimit == null) return false;
    return dailyAmount > dailyLimit!;
  }

  /// Aylık limit aşıldı mı?
  bool isMonthlyLimitExceeded(double monthlyAmount) {
    if (monthlyLimit == null) return false;
    return monthlyAmount > monthlyLimit!;
  }

  /// Onay gerekli mi?
  bool get needsApproval {
    return requiresApproval;
  }

  /// Öncelik seviyesi görünen adı
  String get priorityDisplayName {
    return priority.displayName;
  }

  /// Öncelik rengi
  String get priorityColor {
    return priority.color;
  }

  /// Öncelik ikonu
  String get priorityIcon {
    return priority.icon;
  }


  @override
  List<Object?> get props => [
        id,
        type,
        name,
        description,
        isActive,
        isDefault,
        settings,
        commissionRate,
        minimumAmount,
        maximumAmount,
        dailyLimit,
        monthlyLimit,
        requiresApproval,
        approvalLevel,
        priority,
        companyId,
        tenantId,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];


  @override
  String toString() {
    return 'PaymentMethod(id: $id, name: $name, type: $typeDisplayName, active: $isActive)';
  }
}
