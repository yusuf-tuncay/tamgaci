import 'package:equatable/equatable.dart';

/// Nakit hesap türü
enum CashAccountType {
  cash('Nakit'),
  bank('Banka'),
  creditCard('Kredi Kartı'),
  check('Çek'),
  other('Diğer');

  const CashAccountType(this.displayName);
  final String displayName;
}

/// Nakit hesap durumu
enum CashAccountStatus {
  active('Aktif'),
  inactive('Pasif'),
  closed('Kapalı');

  const CashAccountStatus(this.displayName);
  final String displayName;
}

/// Nakit hesap entity'si
class CashAccount extends Equatable {
  final String id;
  final String name;
  final String? description;
  final CashAccountType type;
  final CashAccountStatus status;
  final double balance;
  final String currency;
  final String? bankName;
  final String? accountNumber;
  final String? iban;
  final String? swiftCode;
  final double? creditLimit;
  final double? minimumBalance;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const CashAccount({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.status,
    required this.balance,
    required this.currency,
    this.bankName,
    this.accountNumber,
    this.iban,
    this.swiftCode,
    this.creditLimit,
    this.minimumBalance,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  CashAccount copyWith({
    String? id,
    String? name,
    String? description,
    CashAccountType? type,
    CashAccountStatus? status,
    double? balance,
    String? currency,
    String? bankName,
    String? accountNumber,
    String? iban,
    String? swiftCode,
    double? creditLimit,
    double? minimumBalance,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CashAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      swiftCode: swiftCode ?? this.swiftCode,
      creditLimit: creditLimit ?? this.creditLimit,
      minimumBalance: minimumBalance ?? this.minimumBalance,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'balance': balance,
      'currency': currency,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'iban': iban,
      'swiftCode': swiftCode,
      'creditLimit': creditLimit,
      'minimumBalance': minimumBalance,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory CashAccount.fromJson(Map<String, dynamic> json) {
    return CashAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: CashAccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CashAccountType.cash,
      ),
      status: CashAccountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CashAccountStatus.active,
      ),
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      iban: json['iban'] as String?,
      swiftCode: json['swiftCode'] as String?,
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      minimumBalance: (json['minimumBalance'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        status,
        balance,
        currency,
        bankName,
        accountNumber,
        iban,
        swiftCode,
        creditLimit,
        minimumBalance,
        isDefault,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
