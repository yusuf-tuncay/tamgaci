import 'package:equatable/equatable.dart';

/// Banka hesabı entity'si
class Account extends Equatable {
  final String id;
  final String tenantId; // Multi-tenant güvenlik için zorunlu
  final String name;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String iban;
  final String swiftCode;
  final String currency;
  final double balance;
  final double availableBalance;
  final double blockedAmount;
  final AccountType type;
  final AccountStatus status;
  final bool isActive;
  final bool isDefault; // Varsayılan hesap kontrolü için
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  const Account({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.iban,
    required this.swiftCode,
    required this.currency,
    required this.balance,
    required this.availableBalance,
    required this.blockedAmount,
    required this.type,
    required this.status,
    required this.isActive,
    this.isDefault = false, // Varsayılan olarak false
    this.description,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  Account copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? accountNumber,
    String? bankName,
    String? branchName,
    String? iban,
    String? swiftCode,
    String? currency,
    double? balance,
    double? availableBalance,
    double? blockedAmount,
    AccountType? type,
    AccountStatus? status,
    bool? isActive,
    bool? isDefault,
    String? description,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Account(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      iban: iban ?? this.iban,
      swiftCode: swiftCode ?? this.swiftCode,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      blockedAmount: blockedAmount ?? this.blockedAmount,
      type: type ?? this.type,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String,
      accountNumber: json['accountNumber'] as String,
      bankName: json['bankName'] as String,
      branchName: json['branchName'] as String,
      iban: json['iban'] as String,
      swiftCode: json['swiftCode'] as String,
      currency: json['currency'] as String,
      balance: (json['balance'] as num).toDouble(),
      availableBalance: (json['availableBalance'] as num).toDouble(),
      blockedAmount: (json['blockedAmount'] as num).toDouble(),
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.checking,
      ),
      status: AccountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AccountStatus.active,
      ),
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'branchName': branchName,
      'iban': iban,
      'swiftCode': swiftCode,
      'currency': currency,
      'balance': balance,
      'availableBalance': availableBalance,
      'blockedAmount': blockedAmount,
      'type': type.name,
      'status': status.name,
      'isActive': isActive,
      'isDefault': isDefault,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        accountNumber,
        bankName,
        branchName,
        iban,
        swiftCode,
        currency,
        balance,
        availableBalance,
        blockedAmount,
        type,
        status,
        isActive,
        isDefault,
        description,
        notes,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  /// Çek hesabı mı?
  bool get isCheckAccount {
    final normalized = name.toLowerCase();
    return type.name.toLowerCase() == 'check' ||
        normalized.contains('çek') ||
        normalized.contains('check');
  }

  /// Senet hesabı mı?
  bool get isPromissoryAccount {
    final normalized = name.toLowerCase();
    return type.name.toLowerCase() == 'promissorynote' ||
        normalized.contains('senet') ||
        normalized.contains('promissory');
  }

  /// Portföy hesabı mı? (Çek veya Senet)
  bool get isPortfolioAccount => isCheckAccount || isPromissoryAccount;

  /// Sistem tarafından oluşturulan varsayılan hesap mı?
  bool get isSystemDefaultAccount {
    final normalizedName = name.trim().toLowerCase();
    final normalizedAccountNumber = accountNumber.trim().toUpperCase();
    return isDefault ||
        _defaultAccountNames.contains(normalizedName) ||
        _defaultAccountNumbers.contains(normalizedAccountNumber);
  }

  static const Set<String> _defaultAccountNames = {
    'nakit kasa',
    'kredi kartı',
    'çek hesabı',
    'senet hesabı',
    'pos hesabı',
    'usd kasa',
    'eur kasa',
  };

  static const Set<String> _defaultAccountNumbers = {
    'CASH-001',
    'CC-001',
    'CHECK-001',
    'PROM-001',
    'POS-001',
    'USD-001',
    'EUR-001',
  };

  static const double _balanceTolerance = 0.01;

  /// Hesapta bakiye var mı? (Pozitif veya negatif)
  bool get hasBalance {
    return balance.abs() > _balanceTolerance ||
        availableBalance.abs() > _balanceTolerance ||
        blockedAmount.abs() > _balanceTolerance;
  }

  /// Hesap silinebilir mi?
  bool get canBeDeleted => !isSystemDefaultAccount && !hasBalance;
}

/// Hesap türleri
enum AccountType {
  checking('Vadesiz'),
  savings('Vadeli'),
  credit('Kredi'),
  creditCard('Kredi Kartı'),
  investment('Yatırım'),
  foreign('Döviz'),
  cash('Nakit'),
  other('Diğer');

  const AccountType(this.displayName);
  final String displayName;

  String get icon {
    switch (this) {
      case AccountType.checking:
        return '🏦';
      case AccountType.savings:
        return '💰';
      case AccountType.credit:
        return '💳';
      case AccountType.creditCard:
        return '💳';
      case AccountType.investment:
        return '📈';
      case AccountType.foreign:
        return '🌍';
      case AccountType.cash:
        return '💵';
      case AccountType.other:
        return '📋';
    }
  }
}

/// Hesap durumları
enum AccountStatus {
  active('Aktif'),
  inactive('Pasif'),
  blocked('Bloke'),
  closed('Kapalı'),
  suspended('Askıya Alınmış');

  const AccountStatus(this.displayName);
  final String displayName;

  String get color {
    switch (this) {
      case AccountStatus.active:
        return 'green';
      case AccountStatus.inactive:
        return 'orange';
      case AccountStatus.blocked:
        return 'red';
      case AccountStatus.closed:
        return 'grey';
      case AccountStatus.suspended:
        return 'yellow';
    }
  }
}
