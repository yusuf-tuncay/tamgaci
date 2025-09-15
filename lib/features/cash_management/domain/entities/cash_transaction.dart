import 'package:equatable/equatable.dart';

/// Nakit işlem türü
enum CashTransactionType {
  income('Gelir'),
  expense('Gider'),
  transfer('Transfer'),
  adjustment('Düzeltme');

  const CashTransactionType(this.displayName);
  final String displayName;
}

/// Nakit işlem kategorisi
enum CashTransactionCategory {
  // Gelir kategorileri
  sales('Satış Geliri'),
  service('Hizmet Geliri'),
  investment('Yatırım Geliri'),
  loan('Kredi Geliri'),
  otherIncome('Diğer Gelir'),

  // Gider kategorileri
  purchase('Satın Alma'),
  salary('Maaş'),
  rent('Kira'),
  utilities('Faturalar'),
  marketing('Pazarlama'),
  maintenance('Bakım'),
  insurance('Sigorta'),
  tax('Vergi'),
  otherExpense('Diğer Gider'),

  // Transfer kategorileri
  transferIn('Transfer Giriş'),
  transferOut('Transfer Çıkış'),

  // Düzeltme kategorileri
  adjustment('Düzeltme');

  const CashTransactionCategory(this.displayName);
  final String displayName;
}

/// Nakit işlem durumu
enum CashTransactionStatus {
  pending('Beklemede'),
  completed('Tamamlandı'),
  cancelled('İptal'),
  failed('Başarısız');

  const CashTransactionStatus(this.displayName);
  final String displayName;
}

/// Nakit işlem entity'si
class CashTransaction extends Equatable {
  final String id;
  final String transactionNumber;
  final CashTransactionType type;
  final CashTransactionCategory category;
  final CashTransactionStatus status;
  final String fromAccountId;
  final String? toAccountId;
  final double amount;
  final String currency;
  final String? description;
  final String? reference;
  final String? relatedDocumentId;
  final String? relatedDocumentType;
  final DateTime transactionDate;
  final DateTime? dueDate;
  final String? notes;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const CashTransaction({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.category,
    required this.status,
    required this.fromAccountId,
    this.toAccountId,
    required this.amount,
    required this.currency,
    this.description,
    this.reference,
    this.relatedDocumentId,
    this.relatedDocumentType,
    required this.transactionDate,
    this.dueDate,
    this.notes,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  CashTransaction copyWith({
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
    return CashTransaction(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'transactionDate': transactionDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory CashTransaction.fromJson(Map<String, dynamic> json) {
    return CashTransaction(
      id: json['id'] as String,
      transactionNumber: json['transactionNumber'] as String,
      type: CashTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CashTransactionType.income,
      ),
      category: CashTransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => CashTransactionCategory.otherIncome,
      ),
      status: CashTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CashTransactionStatus.pending,
      ),
      fromAccountId: json['fromAccountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      relatedDocumentId: json['relatedDocumentId'] as String?,
      relatedDocumentType: json['relatedDocumentType'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      notes: json['notes'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionNumber,
        type,
        category,
        status,
        fromAccountId,
        toAccountId,
        amount,
        currency,
        description,
        reference,
        relatedDocumentId,
        relatedDocumentType,
        transactionDate,
        dueDate,
        notes,
        attachments,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
