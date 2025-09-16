import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';

/// CashAccount model for Firebase integration
class CashAccountModel extends CashAccount {
  const CashAccountModel({
    required super.id,
    required super.name,
    super.description,
    required super.type,
    required super.status,
    required super.balance,
    required super.currency,
    super.bankName,
    super.accountNumber,
    super.iban,
    super.swiftCode,
    super.creditLimit,
    super.minimumBalance,
    super.isDefault,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  /// Firestore DocumentSnapshot'tan CashAccountModel oluşturur
  factory CashAccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CashAccountModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      type: CashAccountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CashAccountType.cash,
      ),
      status: CashAccountStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CashAccountStatus.active,
      ),
      balance: (data['balance'] as num).toDouble(),
      currency: data['currency'] as String,
      bankName: data['bankName'] as String?,
      accountNumber: data['accountNumber'] as String?,
      iban: data['iban'] as String?,
      swiftCode: data['swiftCode'] as String?,
      creditLimit: (data['creditLimit'] as num?)?.toDouble(),
      minimumBalance: (data['minimumBalance'] as num?)?.toDouble(),
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  @override
  CashAccountModel copyWith({
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
    return CashAccountModel(
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

  /// CashAccountModel'i Firestore'a uygun Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// CashAccountModel'i CashAccount entity'sine dönüştürür
  CashAccount toEntity() {
    return CashAccount(
      id: id,
      name: name,
      description: description,
      type: type,
      status: status,
      balance: balance,
      currency: currency,
      bankName: bankName,
      accountNumber: accountNumber,
      iban: iban,
      swiftCode: swiftCode,
      creditLimit: creditLimit,
      minimumBalance: minimumBalance,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// CashAccount entity'sinden CashAccountModel oluşturur
  factory CashAccountModel.fromEntity(CashAccount cashAccount) {
    return CashAccountModel(
      id: cashAccount.id,
      name: cashAccount.name,
      description: cashAccount.description,
      type: cashAccount.type,
      status: cashAccount.status,
      balance: cashAccount.balance,
      currency: cashAccount.currency,
      bankName: cashAccount.bankName,
      accountNumber: cashAccount.accountNumber,
      iban: cashAccount.iban,
      swiftCode: cashAccount.swiftCode,
      creditLimit: cashAccount.creditLimit,
      minimumBalance: cashAccount.minimumBalance,
      isDefault: cashAccount.isDefault,
      createdAt: cashAccount.createdAt,
      updatedAt: cashAccount.updatedAt,
      createdBy: cashAccount.createdBy,
      updatedBy: cashAccount.updatedBy,
    );
  }
}
