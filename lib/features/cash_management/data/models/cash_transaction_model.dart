import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_transaction.dart';

/// CashTransaction model for Firebase integration
class CashTransactionModel extends CashTransaction {
  const CashTransactionModel({
    required super.id,
    required super.transactionNumber,
    required super.type,
    required super.category,
    required super.status,
    required super.fromAccountId,
    super.toAccountId,
    required super.amount,
    required super.currency,
    super.description,
    super.reference,
    super.relatedDocumentId,
    super.relatedDocumentType,
    required super.transactionDate,
    super.dueDate,
    super.notes,
    super.attachments,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  /// Firestore DocumentSnapshot'tan CashTransactionModel oluşturur
  factory CashTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CashTransactionModel(
      id: doc.id,
      transactionNumber: data['transactionNumber'] as String,
      type: CashTransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CashTransactionType.income,
      ),
      category: CashTransactionCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => CashTransactionCategory.otherIncome,
      ),
      status: CashTransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CashTransactionStatus.pending,
      ),
      fromAccountId: data['fromAccountId'] as String,
      toAccountId: data['toAccountId'] as String?,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      description: data['description'] as String?,
      reference: data['reference'] as String?,
      relatedDocumentId: data['relatedDocumentId'] as String?,
      relatedDocumentType: data['relatedDocumentType'] as String?,
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
      attachments: List<String>.from(data['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  @override
  CashTransactionModel copyWith({
    String? id,
    String? transactionNumber,
    CashTransactionType? type,
    CashTransactionCategory? category,
    CashTransactionStatus? status,
    String? fromAccountId,
    String? toAccountId,
    double? amount,
    String? currency,
    String? description,
    String? reference,
    String? relatedDocumentId,
    String? relatedDocumentType,
    DateTime? transactionDate,
    DateTime? dueDate,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CashTransactionModel(
      id: id ?? this.id,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// CashTransactionModel'i Firestore'a uygun Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
      'transactionNumber': transactionNumber,
      'type': type.name,
      'category': category.name,
      'status': status.name,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'reference': reference,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// CashTransactionModel'i CashTransaction entity'sine dönüştürür
  CashTransaction toEntity() {
    return CashTransaction(
      id: id,
      transactionNumber: transactionNumber,
      type: type,
      category: category,
      status: status,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      currency: currency,
      description: description,
      reference: reference,
      relatedDocumentId: relatedDocumentId,
      relatedDocumentType: relatedDocumentType,
      transactionDate: transactionDate,
      dueDate: dueDate,
      notes: notes,
      attachments: attachments,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// CashTransaction entity'sinden CashTransactionModel oluşturur
  factory CashTransactionModel.fromEntity(CashTransaction cashTransaction) {
    return CashTransactionModel(
      id: cashTransaction.id,
      transactionNumber: cashTransaction.transactionNumber,
      type: cashTransaction.type,
      category: cashTransaction.category,
      status: cashTransaction.status,
      fromAccountId: cashTransaction.fromAccountId,
      toAccountId: cashTransaction.toAccountId,
      amount: cashTransaction.amount,
      currency: cashTransaction.currency,
      description: cashTransaction.description,
      reference: cashTransaction.reference,
      relatedDocumentId: cashTransaction.relatedDocumentId,
      relatedDocumentType: cashTransaction.relatedDocumentType,
      transactionDate: cashTransaction.transactionDate,
      dueDate: cashTransaction.dueDate,
      notes: cashTransaction.notes,
      attachments: cashTransaction.attachments,
      metadata: cashTransaction.metadata,
      createdAt: cashTransaction.createdAt,
      updatedAt: cashTransaction.updatedAt,
      createdBy: cashTransaction.createdBy,
      updatedBy: cashTransaction.updatedBy,
    );
  }
}
