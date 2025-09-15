// ========== CASH MANAGEMENT DOMAIN ENTITY ==========
// lib/features/cash_management/domain/entities/account.dart

/// Hesap türü enum'u
enum AccountType {
  cash('Nakit'),
  bank('Banka'),
  credit('Kredi'),
  investment('Yatırım'),
  other('Diğer');

  const AccountType(this.displayName);
  final String displayName;
}

/// Hesap durumu enum'u
enum AccountStatus {
  active('Aktif'),
  inactive('Pasif'),
  closed('Kapalı'),
  suspended('Askıya Alınmış');

  const AccountStatus(this.displayName);
  final String displayName;
}

/// Hesap domain entity'si
class Account {
  final String id;
  final String name;
  final String? description;
  final AccountType type;
  final AccountStatus status;
  final String? bankName;
  final String? accountNumber;
  final String? iban;
  final String? swiftCode;
  final double currentBalance;
  final String currency;
  final double? creditLimit;
  final double? interestRate;
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const Account({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.status,
    this.bankName,
    this.accountNumber,
    this.iban,
    this.swiftCode,
    required this.currentBalance,
    required this.currency,
    this.creditLimit,
    this.interestRate,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Kredi limiti var mı?
  bool get hasCreditLimit => creditLimit != null && creditLimit! > 0;

  /// Kredi kullanım oranı
  double get creditUtilization {
    if (!hasCreditLimit) return 0.0;
    final used = currentBalance < 0 ? currentBalance.abs() : 0.0;
    return used / creditLimit!;
  }

  /// Kredi limiti aşıldı mı?
  bool get isOverCreditLimit {
    if (!hasCreditLimit) return false;
    return currentBalance < -creditLimit!;
  }

  /// Kopyalama metodu
  Account copyWith({
    String? id,
    String? name,
    String? description,
    AccountType? type,
    AccountStatus? status,
    String? bankName,
    String? accountNumber,
    String? iban,
    String? swiftCode,
    double? currentBalance,
    String? currency,
    double? creditLimit,
    double? interestRate,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      swiftCode: swiftCode ?? this.swiftCode,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      creditLimit: creditLimit ?? this.creditLimit,
      interestRate: interestRate ?? this.interestRate,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan Account oluşturma
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.cash,
      ),
      status: AccountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AccountStatus.active,
      ),
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      iban: json['iban'] as String?,
      swiftCode: json['swiftCode'] as String?,
      currentBalance: (json['currentBalance'] as num).toDouble(),
      currency: json['currency'] as String,
      creditLimit: json['creditLimit']?.toDouble(),
      interestRate: json['interestRate']?.toDouble(),
      contactPerson: json['contactPerson'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'iban': iban,
      'swiftCode': swiftCode,
      'currentBalance': currentBalance,
      'currency': currency,
      'creditLimit': creditLimit,
      'interestRate': interestRate,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type, balance: $currentBalance)';
  }
}

/// Nakit işlemi türü enum'u
enum CashTransactionType {
  income('Gelir'),
  expense('Gider'),
  transfer('Transfer'),
  adjustment('Düzeltme'),
  loan('Kredi'),
  investment('Yatırım');

  const CashTransactionType(this.displayName);
  final String displayName;
}

/// Nakit işlemi durumu enum'u
enum CashTransactionStatus {
  pending('Beklemede'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi'),
  failed('Başarısız');

  const CashTransactionStatus(this.displayName);
  final String displayName;
}

/// Nakit işlemi domain entity'si
class CashTransaction {
  final String id;
  final String accountId;
  final String? toAccountId; // Transfer için hedef hesap
  final CashTransactionType type;
  final CashTransactionStatus status;
  final double amount;
  final String currency;
  final String? description;
  final String? reference; // Referans numarası
  final String? category;
  final String? subCategory;
  final DateTime transactionDate;
  final DateTime? dueDate;
  final String? notes;
  final String? attachmentUrl;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CashTransaction({
    required this.id,
    required this.accountId,
    this.toAccountId,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.description,
    this.reference,
    this.category,
    this.subCategory,
    required this.transactionDate,
    this.dueDate,
    this.notes,
    this.attachmentUrl,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Gelir mi?
  bool get isIncome => type == CashTransactionType.income;

  /// Gider mi?
  bool get isExpense => type == CashTransactionType.expense;

  /// Transfer mi?
  bool get isTransfer => type == CashTransactionType.transfer;

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    if (dueDate == null || status == CashTransactionStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Kopyalama metodu
  CashTransaction copyWith({
    String? id,
    String? accountId,
    String? toAccountId,
    CashTransactionType? type,
    CashTransactionStatus? status,
    double? amount,
    String? currency,
    String? description,
    String? reference,
    String? category,
    String? subCategory,
    DateTime? transactionDate,
    DateTime? dueDate,
    String? notes,
    String? attachmentUrl,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CashTransaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan CashTransaction oluşturma
  factory CashTransaction.fromJson(Map<String, dynamic> json) {
    return CashTransaction(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      type: CashTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CashTransactionType.income,
      ),
      status: CashTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CashTransactionStatus.pending,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      category: json['category'] as String?,
      subCategory: json['subCategory'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      notes: json['notes'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'description': description,
      'reference': reference,
      'category': category,
      'subCategory': subCategory,
      'transactionDate': transactionDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
      'attachmentUrl': attachmentUrl,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CashTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CashTransaction(id: $id, type: $type, amount: $amount, status: $status)';
  }
}
