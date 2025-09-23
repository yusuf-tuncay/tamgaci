// ========== ACCOUNTS RECEIVABLE ENTITY ==========
// lib/features/accounts_receivable/domain/entities/accounts_receivable.dart

/// Alacak türü
enum ReceivableType {
  salesInvoice('Satış Faturası'),
  serviceInvoice('Hizmet Faturası'),
  advancePayment('Avans Ödemesi'),
  otherReceivable('Diğer Alacak');

  const ReceivableType(this.displayName);
  final String displayName;
}

/// Alacak durumu
enum ReceivableStatus {
  open('Açık'),
  partiallyPaid('Kısmen Ödendi'),
  paid('Ödendi'),
  overdue('Vadesi Geçti'),
  writtenOff('Terk Edildi'),
  disputed('İtiraz Edildi');

  const ReceivableStatus(this.displayName);
  final String displayName;
}

/// Alacak entity'si
class AccountsReceivable {
  final String id;
  final String receivableNumber;
  final ReceivableType type;
  final ReceivableStatus status;
  final String customerId;
  final String? customerName;
  final String? customerCode;
  final double originalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String currency;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final String? description;
  final String? reference;
  final String? relatedDocumentId; // İlgili belge ID'si
  final String? relatedDocumentType; // İlgili belge türü
  final String? relatedDocumentNumber; // İlgili belge numarası
  final double? interestRate; // Faiz oranı
  final double? interestAmount; // Faiz tutarı
  final double? penaltyAmount; // Ceza tutarı
  final String? notes;
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const AccountsReceivable({
    required this.id,
    required this.receivableNumber,
    required this.type,
    required this.status,
    required this.customerId,
    this.customerName,
    this.customerCode,
    required this.originalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.currency,
    required this.invoiceDate,
    required this.dueDate,
    this.paymentDate,
    this.description,
    this.reference,
    this.relatedDocumentId,
    this.relatedDocumentType,
    this.relatedDocumentNumber,
    this.interestRate,
    this.interestAmount,
    this.penaltyAmount,
    this.notes,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  AccountsReceivable copyWith({
    String? id,
    String? receivableNumber,
    ReceivableType? type,
    ReceivableStatus? status,
    String? customerId,
    String? customerName,
    String? customerCode,
    double? originalAmount,
    double? paidAmount,
    double? remainingAmount,
    String? currency,
    DateTime? invoiceDate,
    DateTime? dueDate,
    DateTime? paymentDate,
    String? description,
    String? reference,
    String? relatedDocumentId,
    String? relatedDocumentType,
    String? relatedDocumentNumber,
    double? interestRate,
    double? interestAmount,
    double? penaltyAmount,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return AccountsReceivable(
      id: id ?? this.id,
      receivableNumber: receivableNumber ?? this.receivableNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerCode: customerCode ?? this.customerCode,
      originalAmount: originalAmount ?? this.originalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      currency: currency ?? this.currency,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      relatedDocumentNumber:
          relatedDocumentNumber ?? this.relatedDocumentNumber,
      interestRate: interestRate ?? this.interestRate,
      interestAmount: interestAmount ?? this.interestAmount,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan AccountsReceivable oluştur
  factory AccountsReceivable.fromJson(Map<String, dynamic> json) {
    return AccountsReceivable(
      id: json['id'] as String,
      receivableNumber: json['receivableNumber'] as String,
      type: ReceivableType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReceivableType.salesInvoice,
      ),
      status: ReceivableStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReceivableStatus.open,
      ),
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      customerCode: json['customerCode'] as String?,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      relatedDocumentId: json['relatedDocumentId'] as String?,
      relatedDocumentType: json['relatedDocumentType'] as String?,
      relatedDocumentNumber: json['relatedDocumentNumber'] as String?,
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      interestAmount: (json['interestAmount'] as num?)?.toDouble(),
      penaltyAmount: (json['penaltyAmount'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// AccountsReceivable'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receivableNumber': receivableNumber,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'customerCode': customerCode,
      'originalAmount': originalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'currency': currency,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'description': description,
      'reference': reference,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'relatedDocumentNumber': relatedDocumentNumber,
      'interestRate': interestRate,
      'interestAmount': interestAmount,
      'penaltyAmount': penaltyAmount,
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) &&
        status != ReceivableStatus.paid &&
        status != ReceivableStatus.writtenOff;
  }

  /// Vadesi yaklaşıyor mu? (7 gün)
  bool get isDueSoon {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 &&
        daysUntilDue > 0 &&
        status == ReceivableStatus.open;
  }

  /// Ödendi mi?
  bool get isPaid => status == ReceivableStatus.paid;

  /// Kısmen ödendi mi?
  bool get isPartiallyPaid => status == ReceivableStatus.partiallyPaid;

  /// Açık mı?
  bool get isOpen => status == ReceivableStatus.open;

  /// Terk edildi mi?
  bool get isWrittenOff => status == ReceivableStatus.writtenOff;

  /// İtiraz edildi mi?
  bool get isDisputed => status == ReceivableStatus.disputed;

  /// Müşteri adı var mı?
  bool get hasCustomerName => customerName != null && customerName!.isNotEmpty;

  /// Müşteri kodu var mı?
  bool get hasCustomerCode => customerCode != null && customerCode!.isNotEmpty;

  /// Referans var mı?
  bool get hasReference => reference != null && reference!.isNotEmpty;

  /// İlgili belge var mı?
  bool get hasRelatedDocument {
    return relatedDocumentId != null &&
        relatedDocumentId!.isNotEmpty &&
        relatedDocumentType != null &&
        relatedDocumentType!.isNotEmpty;
  }

  /// Faiz oranı var mı?
  bool get hasInterestRate => interestRate != null && interestRate! > 0;

  /// Faiz tutarı var mı?
  bool get hasInterestAmount => interestAmount != null && interestAmount! > 0;

  /// Ceza tutarı var mı?
  bool get hasPenaltyAmount => penaltyAmount != null && penaltyAmount! > 0;

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// Ödeme yüzdesi
  double get paymentPercentage {
    if (originalAmount == 0) return 0;
    return (paidAmount / originalAmount) * 100;
  }

  /// Vade günü
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Vade geçmiş gün sayısı
  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  /// Toplam tutar (ana + faiz + ceza)
  double get totalAmount {
    return originalAmount + (interestAmount ?? 0) + (penaltyAmount ?? 0);
  }

  /// Toplam kalan tutar
  double get totalRemainingAmount {
    return totalAmount - paidAmount;
  }

  /// Ödeme yapılabilir mi?
  bool get canBePaid {
    return status == ReceivableStatus.open ||
        status == ReceivableStatus.partiallyPaid;
  }

  /// Terk edilebilir mi?
  bool get canBeWrittenOff {
    return status == ReceivableStatus.open ||
        status == ReceivableStatus.partiallyPaid ||
        status == ReceivableStatus.overdue;
  }

  /// İtiraz edilebilir mi?
  bool get canBeDisputed {
    return status == ReceivableStatus.open ||
        status == ReceivableStatus.partiallyPaid ||
        status == ReceivableStatus.overdue;
  }

  @override
  String toString() {
    return 'AccountsReceivable(id: $id, receivableNumber: $receivableNumber, customerId: $customerId, remainingAmount: $remainingAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountsReceivable && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
