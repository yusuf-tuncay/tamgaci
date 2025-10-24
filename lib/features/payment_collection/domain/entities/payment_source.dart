// ========== PAYMENT SOURCE ENTITY ==========
// lib/features/payment_collection/domain/entities/payment_source.dart

import 'package:equatable/equatable.dart';
import 'payment_enums.dart';

/// Ödeme kaynağı entity'si
class PaymentSource extends Equatable {
  /// Benzersiz ID
  final String id;

  /// Kaynak türü
  final PaymentSourceType type;

  /// Kaynak adı
  final String name;

  /// Açıklama
  final String? description;

  /// Hesap ID'si (banka hesabı için)
  final String? accountId;

  /// Hesap numarası
  final String? accountNumber;

  /// IBAN
  final String? iban;

  /// Banka adı
  final String? bankName;

  /// Şube adı
  final String? branchName;

  /// Para birimi
  final String currency;

  /// Mevcut bakiye
  final double currentBalance;

  /// Kullanılabilir bakiye
  final double availableBalance;

  /// Bloke edilmiş tutar
  final double blockedAmount;

  /// Günlük limit
  final double? dailyLimit;

  /// Aylık limit
  final double? monthlyLimit;

  /// İşlem limiti
  final double? transactionLimit;

  /// Aktif durumu
  final bool isActive;

  /// Varsayılan kaynak mı?
  final bool isDefault;

  /// Kaynak ayarları
  final Map<String, dynamic> settings;

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

  const PaymentSource({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.accountId,
    this.accountNumber,
    this.iban,
    this.bankName,
    this.branchName,
    this.currency = 'TRY',
    this.currentBalance = 0.0,
    this.availableBalance = 0.0,
    this.blockedAmount = 0.0,
    this.dailyLimit,
    this.monthlyLimit,
    this.transactionLimit,
    this.isActive = true,
    this.isDefault = false,
    this.settings = const {},
    required this.companyId,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  PaymentSource copyWith({
    String? id,
    PaymentSourceType? type,
    String? name,
    String? description,
    String? accountId,
    String? accountNumber,
    String? iban,
    String? bankName,
    String? branchName,
    String? currency,
    double? currentBalance,
    double? availableBalance,
    double? blockedAmount,
    double? dailyLimit,
    double? monthlyLimit,
    double? transactionLimit,
    bool? isActive,
    bool? isDefault,
    Map<String, dynamic>? settings,
    String? companyId,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PaymentSource(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      accountId: accountId ?? this.accountId,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      currency: currency ?? this.currency,
      currentBalance: currentBalance ?? this.currentBalance,
      availableBalance: availableBalance ?? this.availableBalance,
      blockedAmount: blockedAmount ?? this.blockedAmount,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      transactionLimit: transactionLimit ?? this.transactionLimit,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      settings: settings ?? this.settings,
      companyId: companyId ?? this.companyId,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan PaymentSource oluştur
  factory PaymentSource.fromJson(Map<String, dynamic> json) {
    return PaymentSource(
      id: json['id'] as String,
      type: PaymentSourceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentSourceType.cash,
      ),
      name: json['name'] as String,
      description: json['description'] as String?,
      accountId: json['accountId'] as String?,
      accountNumber: json['accountNumber'] as String?,
      iban: json['iban'] as String?,
      bankName: json['bankName'] as String?,
      branchName: json['branchName'] as String?,
      currency: json['currency'] as String? ?? 'TRY',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      blockedAmount: (json['blockedAmount'] as num?)?.toDouble() ?? 0.0,
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble(),
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble(),
      transactionLimit: (json['transactionLimit'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      companyId: json['companyId'] as String,
      tenantId: json['tenantId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// PaymentSource'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'accountId': accountId,
      'accountNumber': accountNumber,
      'iban': iban,
      'bankName': bankName,
      'branchName': branchName,
      'currency': currency,
      'currentBalance': currentBalance,
      'availableBalance': availableBalance,
      'blockedAmount': blockedAmount,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
      'transactionLimit': transactionLimit,
      'isActive': isActive,
      'isDefault': isDefault,
      'settings': settings,
      'companyId': companyId,
      'tenantId': tenantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Kaynak türü görünen adı
  String get typeDisplayName {
    return type.displayName;
  }

  /// Kaynak ikonu
  String get icon {
    return type.icon;
  }

  /// Formatlanmış bakiye
  String get formattedBalance {
    return '${currentBalance.toStringAsFixed(2)} $currency';
  }

  /// Formatlanmış kullanılabilir bakiye
  String get formattedAvailableBalance {
    return '${availableBalance.toStringAsFixed(2)} $currency';
  }

  /// Formatlanmış bloke tutar
  String get formattedBlockedAmount {
    return '${blockedAmount.toStringAsFixed(2)} $currency';
  }

  /// Bakiye yeterli mi?
  bool hasSufficientBalance(double amount) {
    return availableBalance >= amount;
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

  /// İşlem limiti aşıldı mı?
  bool isTransactionLimitExceeded(double amount) {
    if (transactionLimit == null) return false;
    return amount > transactionLimit!;
  }

  /// Limitler içinde mi?
  bool isWithinLimits(double amount, double dailyAmount, double monthlyAmount) {
    if (!hasSufficientBalance(amount)) return false;
    if (isTransactionLimitExceeded(amount)) return false;
    if (isDailyLimitExceeded(dailyAmount)) return false;
    if (isMonthlyLimitExceeded(monthlyAmount)) return false;
    return true;
  }

  /// Banka hesabı mı?
  bool get isBankAccount {
    return type == PaymentSourceType.bankAccount;
  }

  /// Nakit kasa mı?
  bool get isCash {
    return type == PaymentSourceType.cash;
  }

  /// POS terminali mi?
  bool get isPos {
    return type == PaymentSourceType.pos;
  }

  /// Online ödeme mi?
  bool get isOnline {
    return type == PaymentSourceType.online;
  }

  /// Mobil ödeme mi?
  bool get isMobile {
    return type == PaymentSourceType.mobile;
  }

  /// Tam hesap bilgisi
  String get fullAccountInfo {
    if (isBankAccount) {
      final parts = <String>[];
      if (bankName != null) parts.add(bankName!);
      if (branchName != null) parts.add(branchName!);
      if (accountNumber != null) parts.add('Hesap: $accountNumber');
      if (iban != null) parts.add('IBAN: $iban');
      return parts.join(' - ');
    }
    return name;
  }

  /// Kısa hesap bilgisi
  String get shortAccountInfo {
    if (isBankAccount) {
      if (accountNumber != null) {
        return '${bankName ?? 'Banka'} - $accountNumber';
      }
      if (iban != null) {
        return '${bankName ?? 'Banka'} - ${iban!.substring(0, 8)}...';
      }
    }
    return name;
  }


  @override
  List<Object?> get props => [
        id,
        type,
        name,
        description,
        accountId,
        accountNumber,
        iban,
        bankName,
        branchName,
        currency,
        currentBalance,
        availableBalance,
        blockedAmount,
        dailyLimit,
        monthlyLimit,
        transactionLimit,
        isActive,
        isDefault,
        settings,
        companyId,
        tenantId,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];


  @override
  String toString() {
    return 'PaymentSource(id: $id, name: $name, type: $typeDisplayName, balance: $formattedBalance)';
  }
}
