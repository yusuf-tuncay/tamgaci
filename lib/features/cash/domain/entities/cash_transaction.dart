// ========== CASH TRANSACTION ENTITY ==========
// lib/features/cash/domain/entities/cash_transaction.dart

/// Nakit işlem tipi enum'u
enum CashTransactionType {
  income('Gelir'),
  expense('Gider'),
  transfer('Transfer');

  const CashTransactionType(this.displayName);
  final String displayName;
}

/// Nakit işlem entity sınıfı
class CashTransaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final CashTransactionType type;
  final String category;
  final DateTime transactionDate;
  final String? referenceNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CashTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.currency,
    required this.type,
    required this.category,
    required this.transactionDate,
    this.referenceNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Kopyalama metodu
  CashTransaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? currency,
    CashTransactionType? type,
    String? category,
    DateTime? transactionDate,
    String? referenceNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CashTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      category: category ?? this.category,
      transactionDate: transactionDate ?? this.transactionDate,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan CashTransaction oluşturma
  factory CashTransaction.fromJson(Map<String, dynamic> json) {
    return CashTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      type: CashTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CashTransactionType.income,
      ),
      category: json['category'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// CashTransaction'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'type': type.name,
      'category': category,
      'transactionDate': transactionDate.toIso8601String(),
      'referenceNumber': referenceNumber,
      'notes': notes,
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
    return 'CashTransaction(id: $id, title: $title, amount: $amount, type: $type)';
  }
}
