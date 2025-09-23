// ========== BANK RECONCILIATION ENTITY ==========
// lib/features/cash_management/domain/entities/bank_reconciliation.dart

/// Banka mutabakat durumu
enum BankReconciliationStatus {
  draft('Taslak'),
  inProgress('Devam Ediyor'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi');

  const BankReconciliationStatus(this.displayName);
  final String displayName;
}

/// Banka mutabakat entity'si
class BankReconciliation {
  final String id;
  final String reconciliationNumber;
  final String bankAccountId;
  final String? bankAccountName;
  final BankReconciliationStatus status;
  final DateTime statementDate; // Ekstre tarihi
  final DateTime reconciliationDate; // Mutabakat tarihi
  final double bankBalance; // Banka bakiyesi
  final double bookBalance; // Defter bakiyesi
  final double reconciledBalance; // Mutabakat bakiyesi
  final List<BankReconciliationItem> items;
  final String? notes;
  final String? preparedBy; // Hazırlayan
  final String? reviewedBy; // İnceleyen
  final DateTime? reviewedDate; // İnceleme tarihi
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const BankReconciliation({
    required this.id,
    required this.reconciliationNumber,
    required this.bankAccountId,
    this.bankAccountName,
    required this.status,
    required this.statementDate,
    required this.reconciliationDate,
    required this.bankBalance,
    required this.bookBalance,
    required this.reconciledBalance,
    this.items = const [],
    this.notes,
    this.preparedBy,
    this.reviewedBy,
    this.reviewedDate,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  BankReconciliation copyWith({
    String? id,
    String? reconciliationNumber,
    String? bankAccountId,
    String? bankAccountName,
    BankReconciliationStatus? status,
    DateTime? statementDate,
    DateTime? reconciliationDate,
    double? bankBalance,
    double? bookBalance,
    double? reconciledBalance,
    List<BankReconciliationItem>? items,
    String? notes,
    String? preparedBy,
    String? reviewedBy,
    DateTime? reviewedDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return BankReconciliation(
      id: id ?? this.id,
      reconciliationNumber: reconciliationNumber ?? this.reconciliationNumber,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      status: status ?? this.status,
      statementDate: statementDate ?? this.statementDate,
      reconciliationDate: reconciliationDate ?? this.reconciliationDate,
      bankBalance: bankBalance ?? this.bankBalance,
      bookBalance: bookBalance ?? this.bookBalance,
      reconciledBalance: reconciledBalance ?? this.reconciledBalance,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      preparedBy: preparedBy ?? this.preparedBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedDate: reviewedDate ?? this.reviewedDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan BankReconciliation oluştur
  factory BankReconciliation.fromJson(Map<String, dynamic> json) {
    return BankReconciliation(
      id: json['id'] as String,
      reconciliationNumber: json['reconciliationNumber'] as String,
      bankAccountId: json['bankAccountId'] as String,
      bankAccountName: json['bankAccountName'] as String?,
      status: BankReconciliationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BankReconciliationStatus.draft,
      ),
      statementDate: DateTime.parse(json['statementDate'] as String),
      reconciliationDate: DateTime.parse(json['reconciliationDate'] as String),
      bankBalance: (json['bankBalance'] as num).toDouble(),
      bookBalance: (json['bookBalance'] as num).toDouble(),
      reconciledBalance: (json['reconciledBalance'] as num).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  BankReconciliationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      preparedBy: json['preparedBy'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      reviewedDate: json['reviewedDate'] != null
          ? DateTime.parse(json['reviewedDate'] as String)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// BankReconciliation'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reconciliationNumber': reconciliationNumber,
      'bankAccountId': bankAccountId,
      'bankAccountName': bankAccountName,
      'status': status.name,
      'statementDate': statementDate.toIso8601String(),
      'reconciliationDate': reconciliationDate.toIso8601String(),
      'bankBalance': bankBalance,
      'bookBalance': bookBalance,
      'reconciledBalance': reconciledBalance,
      'items': items.map((e) => e.toJson()).toList(),
      'notes': notes,
      'preparedBy': preparedBy,
      'reviewedBy': reviewedBy,
      'reviewedDate': reviewedDate?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Fark tutarı
  double get difference => bankBalance - bookBalance;

  /// Mutabakat tamamlandı mı?
  bool get isCompleted => status == BankReconciliationStatus.completed;

  /// Mutabakat devam ediyor mu?
  bool get isInProgress => status == BankReconciliationStatus.inProgress;

  /// Mutabakat edilen kalem sayısı
  int get reconciledItemsCount =>
      items.where((item) => item.isReconciled).length;

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Mutabakat yüzdesi
  double get reconciliationPercentage {
    if (totalItemsCount == 0) return 0;
    return (reconciledItemsCount / totalItemsCount) * 100;
  }

  /// Mutabakat edilebilir mi?
  bool get canBeReconciled {
    return status == BankReconciliationStatus.draft ||
        status == BankReconciliationStatus.inProgress;
  }

  /// İnceleme yapılabilir mi?
  bool get canBeReviewed {
    return status == BankReconciliationStatus.completed && reviewedBy == null;
  }

  @override
  String toString() {
    return 'BankReconciliation(id: $id, reconciliationNumber: $reconciliationNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankReconciliation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Banka mutabakat kalemi
class BankReconciliationItem {
  final String id;
  final String reconciliationId;
  final String? transactionId; // İlgili işlem ID'si
  final String? transactionNumber; // İşlem numarası
  final DateTime transactionDate; // İşlem tarihi
  final String description; // Açıklama
  final double amount; // Tutar
  final String currency; // Para birimi
  final bool isReconciled; // Mutabakat edildi mi?
  final DateTime? reconciledDate; // Mutabakat tarihi
  final String? reconciledBy; // Mutabakat eden
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek bilgiler

  const BankReconciliationItem({
    required this.id,
    required this.reconciliationId,
    this.transactionId,
    this.transactionNumber,
    required this.transactionDate,
    required this.description,
    required this.amount,
    required this.currency,
    this.isReconciled = false,
    this.reconciledDate,
    this.reconciledBy,
    this.notes,
    this.metadata = const {},
  });

  /// CopyWith metodu
  BankReconciliationItem copyWith({
    String? id,
    String? reconciliationId,
    String? transactionId,
    String? transactionNumber,
    DateTime? transactionDate,
    String? description,
    double? amount,
    String? currency,
    bool? isReconciled,
    DateTime? reconciledDate,
    String? reconciledBy,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return BankReconciliationItem(
      id: id ?? this.id,
      reconciliationId: reconciliationId ?? this.reconciliationId,
      transactionId: transactionId ?? this.transactionId,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      isReconciled: isReconciled ?? this.isReconciled,
      reconciledDate: reconciledDate ?? this.reconciledDate,
      reconciledBy: reconciledBy ?? this.reconciledBy,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON'dan BankReconciliationItem oluştur
  factory BankReconciliationItem.fromJson(Map<String, dynamic> json) {
    return BankReconciliationItem(
      id: json['id'] as String,
      reconciliationId: json['reconciliationId'] as String,
      transactionId: json['transactionId'] as String?,
      transactionNumber: json['transactionNumber'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      isReconciled: json['isReconciled'] ?? false,
      reconciledDate: json['reconciledDate'] != null
          ? DateTime.parse(json['reconciledDate'] as String)
          : null,
      reconciledBy: json['reconciledBy'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// BankReconciliationItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reconciliationId': reconciliationId,
      'transactionId': transactionId,
      'transactionNumber': transactionNumber,
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      'amount': amount,
      'currency': currency,
      'isReconciled': isReconciled,
      'reconciledDate': reconciledDate?.toIso8601String(),
      'reconciledBy': reconciledBy,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Giriş mi?
  bool get isCredit => amount > 0;

  /// Çıkış mı?
  bool get isDebit => amount < 0;

  /// Mutabakat edilebilir mi?
  bool get canBeReconciled => !isReconciled;

  /// İşlem ID'si var mı?
  bool get hasTransactionId =>
      transactionId != null && transactionId!.isNotEmpty;

  /// İşlem numarası var mı?
  bool get hasTransactionNumber =>
      transactionNumber != null && transactionNumber!.isNotEmpty;

  @override
  String toString() {
    return 'BankReconciliationItem(id: $id, description: $description, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankReconciliationItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
