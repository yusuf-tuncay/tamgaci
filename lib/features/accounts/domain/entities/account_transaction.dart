import 'package:cloud_firestore/cloud_firestore.dart';

/// Hesap hareketi türleri
enum TransactionType {
  deposit, // Para girişi
  withdrawal, // Para çıkışı
  transfer, // Transfer
  adjustment, // Düzeltme
  opening, // Açılış bakiyesi
  income, // Gelir (pozitif değerler)
  expense, // Gider (negatif değerler)
}

/// Hesap hareketi kategorileri
enum TransactionCategory {
  cash, // Nakit
  bank, // Banka
  credit, // Kredi
  investment, // Yatırım
  expense, // Masraf
  other, // Diğer
}

/// Hesap hareketi entity'si
class AccountTransaction {
  final String id;
  final String accountId;
  final String? fromAccountId; // Transfer için kaynak hesap
  final String? toAccountId; // Transfer için hedef hesap
  final TransactionType type;
  final TransactionCategory category;
  final double amount;
  final double? debitAmount; // Borç tutarı
  final double? creditAmount; // Alacak tutarı
  final double balanceAfter; // İşlem sonrası bakiye
  final String description;
  final String? reference; // Referans numarası
  final DateTime transactionDate;
  final String userId; // İşlemi yapan kullanıcı
  final String? notes;
  final bool isReconciled; // Mutabakat durumu
  final DateTime? reconciledAt;
  final String? reconciledBy;

  // Audit fields
  final String tenantId;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountTransaction({
    required this.id,
    required this.accountId,
    this.fromAccountId,
    this.toAccountId,
    required this.type,
    required this.category,
    required this.amount,
    this.debitAmount,
    this.creditAmount,
    required this.balanceAfter,
    required this.description,
    this.reference,
    required this.transactionDate,
    required this.userId,
    this.notes,
    this.isReconciled = false,
    this.reconciledAt,
    this.reconciledBy,
    required this.tenantId,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Copy with method
  AccountTransaction copyWith({
    String? id,
    String? accountId,
    String? fromAccountId,
    String? toAccountId,
    TransactionType? type,
    TransactionCategory? category,
    double? amount,
    double? debitAmount,
    double? creditAmount,
    double? balanceAfter,
    String? description,
    String? reference,
    DateTime? transactionDate,
    String? userId,
    String? notes,
    bool? isReconciled,
    DateTime? reconciledAt,
    String? reconciledBy,
    String? tenantId,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountTransaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      debitAmount: debitAmount ?? this.debitAmount,
      creditAmount: creditAmount ?? this.creditAmount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      transactionDate: transactionDate ?? this.transactionDate,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      isReconciled: isReconciled ?? this.isReconciled,
      reconciledAt: reconciledAt ?? this.reconciledAt,
      reconciledBy: reconciledBy ?? this.reconciledBy,
      tenantId: tenantId ?? this.tenantId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan oluştur
  factory AccountTransaction.fromJson(Map<String, dynamic> json) {
    return AccountTransaction(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      fromAccountId: json['fromAccountId'] as String?,
      toAccountId: json['toAccountId'] as String?,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.deposit,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TransactionCategory.other,
      ),
      amount: (json['amount'] as num).toDouble(),
      debitAmount: json['debitAmount'] != null
          ? (json['debitAmount'] as num).toDouble()
          : null,
      creditAmount: json['creditAmount'] != null
          ? (json['creditAmount'] as num).toDouble()
          : null,
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      description: json['description'] as String,
      reference: json['reference'] as String?,
      transactionDate: (json['transactionDate'] as Timestamp).toDate(),
      userId: json['userId'] as String,
      notes: json['notes'] as String?,
      isReconciled: json['isReconciled'] as bool? ?? false,
      reconciledAt: json['reconciledAt'] != null
          ? (json['reconciledAt'] as Timestamp).toDate()
          : null,
      reconciledBy: json['reconciledBy'] as String?,
      tenantId: json['tenantId'] as String,
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'type': type.name,
      'category': category.name,
      'amount': amount,
      'debitAmount': debitAmount,
      'creditAmount': creditAmount,
      'balanceAfter': balanceAfter,
      'description': description,
      'reference': reference,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'userId': userId,
      'notes': notes,
      'isReconciled': isReconciled,
      'reconciledAt':
          reconciledAt != null ? Timestamp.fromDate(reconciledAt!) : null,
      'reconciledBy': reconciledBy,
      'tenantId': tenantId,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
