import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/account_transaction.dart';

/// Firebase Account Transaction Entity
class FirebaseAccountTransactionEntity {
  final String id;
  final String accountId;
  final String? fromAccountId;
  final String? toAccountId;
  final TransactionType type;
  final TransactionCategory category;
  final double amount;
  final double? debitAmount;
  final double? creditAmount;
  final double balanceAfter;
  final String description;
  final String? reference;
  final DateTime transactionDate;
  final String userId;
  final String? notes;
  final bool isReconciled;
  final DateTime? reconciledAt;
  final String? reconciledBy;

  // Audit fields
  final String tenantId;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FirebaseAccountTransactionEntity({
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

  /// Firestore'dan oluştur
  factory FirebaseAccountTransactionEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseAccountTransactionEntity(
      id: doc.id,
      accountId: data['accountId'] as String,
      fromAccountId: data['fromAccountId'] as String?,
      toAccountId: data['toAccountId'] as String?,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.deposit,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TransactionCategory.other,
      ),
      amount: (data['amount'] as num).toDouble(),
      debitAmount: data['debitAmount'] != null
          ? (data['debitAmount'] as num).toDouble()
          : null,
      creditAmount: data['creditAmount'] != null
          ? (data['creditAmount'] as num).toDouble()
          : null,
      balanceAfter: (data['balanceAfter'] as num).toDouble(),
      description: data['description'] as String,
      reference: data['reference'] as String?,
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      userId: data['userId'] as String,
      notes: data['notes'] as String?,
      isReconciled: data['isReconciled'] as bool? ?? false,
      reconciledAt: data['reconciledAt'] != null
          ? (data['reconciledAt'] as Timestamp).toDate()
          : null,
      reconciledBy: data['reconciledBy'] as String?,
      tenantId: data['tenantId'] as String,
      createdBy: data['createdBy'] as String,
      updatedBy: data['updatedBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Domain entity'ye dönüştür
  AccountTransaction toDomain() {
    return AccountTransaction(
      id: id,
      accountId: accountId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      type: type,
      category: category,
      amount: amount,
      debitAmount: debitAmount,
      creditAmount: creditAmount,
      balanceAfter: balanceAfter,
      description: description,
      reference: reference,
      transactionDate: transactionDate,
      userId: userId,
      notes: notes,
      isReconciled: isReconciled,
      reconciledAt: reconciledAt,
      reconciledBy: reconciledBy,
      tenantId: tenantId,
      createdBy: createdBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Domain entity'den oluştur
  factory FirebaseAccountTransactionEntity.fromDomain(
      AccountTransaction transaction) {
    return FirebaseAccountTransactionEntity(
      id: transaction.id,
      accountId: transaction.accountId,
      fromAccountId: transaction.fromAccountId,
      toAccountId: transaction.toAccountId,
      type: transaction.type,
      category: transaction.category,
      amount: transaction.amount,
      debitAmount: transaction.debitAmount,
      creditAmount: transaction.creditAmount,
      balanceAfter: transaction.balanceAfter,
      description: transaction.description,
      reference: transaction.reference,
      transactionDate: transaction.transactionDate,
      userId: transaction.userId,
      notes: transaction.notes,
      isReconciled: transaction.isReconciled,
      reconciledAt: transaction.reconciledAt,
      reconciledBy: transaction.reconciledBy,
      tenantId: transaction.tenantId,
      createdBy: transaction.createdBy,
      updatedBy: transaction.updatedBy,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  /// Firestore'a dönüştür
  Map<String, dynamic> toFirestore() {
    return {
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

  /// Copy with method
  FirebaseAccountTransactionEntity copyWith({
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
    return FirebaseAccountTransactionEntity(
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
}
