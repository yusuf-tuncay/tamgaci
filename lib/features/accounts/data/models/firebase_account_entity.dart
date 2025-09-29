import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/account.dart';

/// Firebase Account Entity
class FirebaseAccountEntity {
  final String id;
  final String tenantId;
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
  final bool isDefault;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  const FirebaseAccountEntity({
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
    this.isDefault = false,
    this.description,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  /// Firestore DocumentSnapshot'tan FirebaseAccountEntity oluşturur
  factory FirebaseAccountEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseAccountEntity(
      id: doc.id,
      tenantId: data['tenantId'] as String? ?? '',
      name: data['name'] as String,
      accountNumber: data['accountNumber'] as String,
      bankName: data['bankName'] as String,
      branchName: data['branchName'] as String,
      iban: data['iban'] as String,
      swiftCode: data['swiftCode'] as String,
      currency: data['currency'] as String,
      balance: (data['balance'] as num).toDouble(),
      availableBalance: (data['availableBalance'] as num).toDouble(),
      blockedAmount: (data['blockedAmount'] as num).toDouble(),
      type: AccountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AccountType.checking,
      ),
      status: AccountStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AccountStatus.active,
      ),
      isActive: data['isActive'] as bool? ?? true,
      isDefault: data['isDefault'] as bool? ?? false,
      description: data['description'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
      updatedBy: data['updatedBy'] as String,
    );
  }

  /// Domain entity'den FirebaseAccountEntity oluşturur
  factory FirebaseAccountEntity.fromDomain(Account account) {
    return FirebaseAccountEntity(
      id: account.id,
      tenantId: account.tenantId,
      name: account.name,
      accountNumber: account.accountNumber,
      bankName: account.bankName,
      branchName: account.branchName,
      iban: account.iban,
      swiftCode: account.swiftCode,
      currency: account.currency,
      balance: account.balance,
      availableBalance: account.availableBalance,
      blockedAmount: account.blockedAmount,
      type: account.type,
      status: account.status,
      isActive: account.isActive,
      isDefault: account.isDefault,
      description: account.description,
      notes: account.notes,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
      createdBy: account.createdBy,
      updatedBy: account.updatedBy,
    );
  }

  /// Domain entity'ye dönüştürür
  Account toDomain() {
    return Account(
      id: id,
      tenantId: tenantId,
      name: name,
      accountNumber: accountNumber,
      bankName: bankName,
      branchName: branchName,
      iban: iban,
      swiftCode: swiftCode,
      currency: currency,
      balance: balance,
      availableBalance: availableBalance,
      blockedAmount: blockedAmount,
      type: type,
      status: status,
      isActive: isActive,
      isDefault: isDefault,
      description: description,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Firestore'a kaydetmek için Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Copy with metodu
  FirebaseAccountEntity copyWith({
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
    return FirebaseAccountEntity(
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
}
