// ========== POS TRANSACTION ENTITY ==========
// lib/features/cash_management/domain/entities/pos_transaction.dart

/// POS işlem türü
enum PosTransactionType {
  sale('Satış'),
  refund('İade'),
  voidTransaction('İptal'),
  preAuth('Ön Yetkilendirme'),
  capture('Tahsilat'),
  reversal('Geri Alma');

  const PosTransactionType(this.displayName);
  final String displayName;
}

/// POS işlem durumu
enum PosTransactionStatus {
  pending('Beklemede'),
  approved('Onaylandı'),
  declined('Reddedildi'),
  cancelled('İptal Edildi'),
  timeout('Zaman Aşımı'),
  error('Hata');

  const PosTransactionStatus(this.displayName);
  final String displayName;
}

/// POS işlem entity'si
class PosTransaction {
  final String id;
  final String transactionNumber;
  final PosTransactionType type;
  final PosTransactionStatus status;
  final String posTerminalId; // POS terminal ID'si
  final String? posTerminalName; // POS terminal adı
  final String? merchantId; // Tüccar ID'si
  final String? merchantName; // Tüccar adı
  final double amount;
  final String currency;
  final String? cardNumber; // Kart numarası (maskelenmiş)
  final String? cardType; // Kart türü (Visa, MasterCard, etc.)
  final String? cardHolderName; // Kart sahibi adı
  final String? authorizationCode; // Yetkilendirme kodu
  final String? referenceNumber; // Referans numarası
  final String? batchNumber; // Batch numarası
  final DateTime transactionDate;
  final DateTime? settlementDate; // Takas tarihi
  final double? commission; // Komisyon
  final double? netAmount; // Net tutar
  final String? description;
  final String? notes;
  final String? relatedSaleId; // İlgili satış ID'si
  final String? relatedSaleNumber; // İlgili satış numarası
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const PosTransaction({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.status,
    required this.posTerminalId,
    this.posTerminalName,
    this.merchantId,
    this.merchantName,
    required this.amount,
    required this.currency,
    this.cardNumber,
    this.cardType,
    this.cardHolderName,
    this.authorizationCode,
    this.referenceNumber,
    this.batchNumber,
    required this.transactionDate,
    this.settlementDate,
    this.commission,
    this.netAmount,
    this.description,
    this.notes,
    this.relatedSaleId,
    this.relatedSaleNumber,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  PosTransaction copyWith({
    String? id,
    String? transactionNumber,
    PosTransactionType? type,
    PosTransactionStatus? status,
    String? posTerminalId,
    String? posTerminalName,
    String? merchantId,
    String? merchantName,
    double? amount,
    String? currency,
    String? cardNumber,
    String? cardType,
    String? cardHolderName,
    String? authorizationCode,
    String? referenceNumber,
    String? batchNumber,
    DateTime? transactionDate,
    DateTime? settlementDate,
    double? commission,
    double? netAmount,
    String? description,
    String? notes,
    String? relatedSaleId,
    String? relatedSaleNumber,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PosTransaction(
      id: id ?? this.id,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      posTerminalId: posTerminalId ?? this.posTerminalId,
      posTerminalName: posTerminalName ?? this.posTerminalName,
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      cardNumber: cardNumber ?? this.cardNumber,
      cardType: cardType ?? this.cardType,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      batchNumber: batchNumber ?? this.batchNumber,
      transactionDate: transactionDate ?? this.transactionDate,
      settlementDate: settlementDate ?? this.settlementDate,
      commission: commission ?? this.commission,
      netAmount: netAmount ?? this.netAmount,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      relatedSaleId: relatedSaleId ?? this.relatedSaleId,
      relatedSaleNumber: relatedSaleNumber ?? this.relatedSaleNumber,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan PosTransaction oluştur
  factory PosTransaction.fromJson(Map<String, dynamic> json) {
    return PosTransaction(
      id: json['id'] as String,
      transactionNumber: json['transactionNumber'] as String,
      type: PosTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PosTransactionType.sale,
      ),
      status: PosTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PosTransactionStatus.pending,
      ),
      posTerminalId: json['posTerminalId'] as String,
      posTerminalName: json['posTerminalName'] as String?,
      merchantId: json['merchantId'] as String?,
      merchantName: json['merchantName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      cardNumber: json['cardNumber'] as String?,
      cardType: json['cardType'] as String?,
      cardHolderName: json['cardHolderName'] as String?,
      authorizationCode: json['authorizationCode'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      batchNumber: json['batchNumber'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      settlementDate: json['settlementDate'] != null
          ? DateTime.parse(json['settlementDate'] as String)
          : null,
      commission: (json['commission'] as num?)?.toDouble(),
      netAmount: (json['netAmount'] as num?)?.toDouble(),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      relatedSaleId: json['relatedSaleId'] as String?,
      relatedSaleNumber: json['relatedSaleNumber'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// PosTransaction'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionNumber': transactionNumber,
      'type': type.name,
      'status': status.name,
      'posTerminalId': posTerminalId,
      'posTerminalName': posTerminalName,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'amount': amount,
      'currency': currency,
      'cardNumber': cardNumber,
      'cardType': cardType,
      'cardHolderName': cardHolderName,
      'authorizationCode': authorizationCode,
      'referenceNumber': referenceNumber,
      'batchNumber': batchNumber,
      'transactionDate': transactionDate.toIso8601String(),
      'settlementDate': settlementDate?.toIso8601String(),
      'commission': commission,
      'netAmount': netAmount,
      'description': description,
      'notes': notes,
      'relatedSaleId': relatedSaleId,
      'relatedSaleNumber': relatedSaleNumber,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Onaylandı mı?
  bool get isApproved => status == PosTransactionStatus.approved;

  /// Reddedildi mi?
  bool get isDeclined => status == PosTransactionStatus.declined;

  /// İptal edildi mi?
  bool get isCancelled => status == PosTransactionStatus.cancelled;

  /// Beklemede mi?
  bool get isPending => status == PosTransactionStatus.pending;

  /// Hata var mı?
  bool get hasError => status == PosTransactionStatus.error;

  /// Takas edildi mi?
  bool get isSettled => settlementDate != null;

  /// Komisyon hesaplandı mı?
  bool get hasCommission => commission != null && commission! > 0;

  /// Net tutar hesaplandı mı?
  bool get hasNetAmount => netAmount != null;

  /// Kart numarası maskelenmiş mi?
  bool get isCardNumberMasked {
    if (cardNumber == null) return false;
    return cardNumber!.contains('*');
  }

  /// Yetkilendirme kodu var mı?
  bool get hasAuthorizationCode =>
      authorizationCode != null && authorizationCode!.isNotEmpty;

  /// Referans numarası var mı?
  bool get hasReferenceNumber =>
      referenceNumber != null && referenceNumber!.isNotEmpty;

  /// Batch numarası var mı?
  bool get hasBatchNumber => batchNumber != null && batchNumber!.isNotEmpty;

  /// İlgili satış var mı?
  bool get hasRelatedSale => relatedSaleId != null && relatedSaleId!.isNotEmpty;

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status == PosTransactionStatus.pending ||
        status == PosTransactionStatus.approved;
  }

  /// İade edilebilir mi?
  bool get canBeRefunded {
    return status == PosTransactionStatus.approved &&
        type == PosTransactionType.sale;
  }

  @override
  String toString() {
    return 'PosTransaction(id: $id, transactionNumber: $transactionNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PosTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
