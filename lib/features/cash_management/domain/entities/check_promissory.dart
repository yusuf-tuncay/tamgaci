// ========== CHECK PROMISSORY ENTITY ==========
// lib/features/cash_management/domain/entities/check_promissory.dart

/// Çek/Senet türü
enum CheckPromissoryType {
  check('Çek'),
  promissoryNote('Senet'),
  billOfExchange('Poliçe');

  const CheckPromissoryType(this.displayName);
  final String displayName;
}

/// Çek/Senet durumu
enum CheckPromissoryStatus {
  pending('Beklemede'),
  deposited('Banka Yatırıldı'),
  collected('Tahsil Edildi'),
  returned('İade Edildi'),
  protested('Protesto Edildi'),
  cancelled('İptal Edildi'),
  expired('Vadesi Geçti');

  const CheckPromissoryStatus(this.displayName);
  final String displayName;
}

/// Çek/Senet entity'si
class CheckPromissory {
  final String id;
  final String documentNumber;
  final CheckPromissoryType type;
  final CheckPromissoryStatus status;
  final String? customerId; // Müşteri ID'si
  final String? customerName; // Müşteri adı
  final String? supplierId; // Tedarikçi ID'si
  final String? supplierName; // Tedarikçi adı
  final double amount;
  final String currency;
  final String? bankName; // Banka adı
  final String? bankBranch; // Şube
  final String? accountNumber; // Hesap numarası
  final String? checkNumber; // Çek numarası
  final DateTime issueDate; // Keşide tarihi
  final DateTime dueDate; // Vade tarihi
  final DateTime? depositDate; // Yatırma tarihi
  final DateTime? collectionDate; // Tahsil tarihi
  final DateTime? returnDate; // İade tarihi
  final String? returnReason; // İade nedeni
  final String? protestReason; // Protesto nedeni
  final String? description;
  final String? notes;
  final String? relatedSaleId; // İlgili satış ID'si
  final String? relatedSaleNumber; // İlgili satış numarası
  final String? relatedPurchaseId; // İlgili satınalma ID'si
  final String? relatedPurchaseNumber; // İlgili satınalma numarası
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const CheckPromissory({
    required this.id,
    required this.documentNumber,
    required this.type,
    required this.status,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    required this.amount,
    required this.currency,
    this.bankName,
    this.bankBranch,
    this.accountNumber,
    this.checkNumber,
    required this.issueDate,
    required this.dueDate,
    this.depositDate,
    this.collectionDate,
    this.returnDate,
    this.returnReason,
    this.protestReason,
    this.description,
    this.notes,
    this.relatedSaleId,
    this.relatedSaleNumber,
    this.relatedPurchaseId,
    this.relatedPurchaseNumber,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  CheckPromissory copyWith({
    String? id,
    String? documentNumber,
    CheckPromissoryType? type,
    CheckPromissoryStatus? status,
    String? customerId,
    String? customerName,
    String? supplierId,
    String? supplierName,
    double? amount,
    String? currency,
    String? bankName,
    String? bankBranch,
    String? accountNumber,
    String? checkNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? depositDate,
    DateTime? collectionDate,
    DateTime? returnDate,
    String? returnReason,
    String? protestReason,
    String? description,
    String? notes,
    String? relatedSaleId,
    String? relatedSaleNumber,
    String? relatedPurchaseId,
    String? relatedPurchaseNumber,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CheckPromissory(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      accountNumber: accountNumber ?? this.accountNumber,
      checkNumber: checkNumber ?? this.checkNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      depositDate: depositDate ?? this.depositDate,
      collectionDate: collectionDate ?? this.collectionDate,
      returnDate: returnDate ?? this.returnDate,
      returnReason: returnReason ?? this.returnReason,
      protestReason: protestReason ?? this.protestReason,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      relatedSaleId: relatedSaleId ?? this.relatedSaleId,
      relatedSaleNumber: relatedSaleNumber ?? this.relatedSaleNumber,
      relatedPurchaseId: relatedPurchaseId ?? this.relatedPurchaseId,
      relatedPurchaseNumber:
          relatedPurchaseNumber ?? this.relatedPurchaseNumber,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan CheckPromissory oluştur
  factory CheckPromissory.fromJson(Map<String, dynamic> json) {
    return CheckPromissory(
      id: json['id'] as String,
      documentNumber: json['documentNumber'] as String,
      type: CheckPromissoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CheckPromissoryType.check,
      ),
      status: CheckPromissoryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CheckPromissoryStatus.pending,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      bankName: json['bankName'] as String?,
      bankBranch: json['bankBranch'] as String?,
      accountNumber: json['accountNumber'] as String?,
      checkNumber: json['checkNumber'] as String?,
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      depositDate: json['depositDate'] != null
          ? DateTime.parse(json['depositDate'] as String)
          : null,
      collectionDate: json['collectionDate'] != null
          ? DateTime.parse(json['collectionDate'] as String)
          : null,
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'] as String)
          : null,
      returnReason: json['returnReason'] as String?,
      protestReason: json['protestReason'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      relatedSaleId: json['relatedSaleId'] as String?,
      relatedSaleNumber: json['relatedSaleNumber'] as String?,
      relatedPurchaseId: json['relatedPurchaseId'] as String?,
      relatedPurchaseNumber: json['relatedPurchaseNumber'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// CheckPromissory'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentNumber': documentNumber,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'amount': amount,
      'currency': currency,
      'bankName': bankName,
      'bankBranch': bankBranch,
      'accountNumber': accountNumber,
      'checkNumber': checkNumber,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'depositDate': depositDate?.toIso8601String(),
      'collectionDate': collectionDate?.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'returnReason': returnReason,
      'protestReason': protestReason,
      'description': description,
      'notes': notes,
      'relatedSaleId': relatedSaleId,
      'relatedSaleNumber': relatedSaleNumber,
      'relatedPurchaseId': relatedPurchaseId,
      'relatedPurchaseNumber': relatedPurchaseNumber,
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
        status != CheckPromissoryStatus.collected &&
        status != CheckPromissoryStatus.cancelled;
  }

  /// Vadesi yaklaşıyor mu? (7 gün)
  bool get isDueSoon {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 &&
        daysUntilDue > 0 &&
        status == CheckPromissoryStatus.pending;
  }

  /// Tahsil edildi mi?
  bool get isCollected => status == CheckPromissoryStatus.collected;

  /// İade edildi mi?
  bool get isReturned => status == CheckPromissoryStatus.returned;

  /// Protesto edildi mi?
  bool get isProtested => status == CheckPromissoryStatus.protested;

  /// İptal edildi mi?
  bool get isCancelled => status == CheckPromissoryStatus.cancelled;

  /// Beklemede mi?
  bool get isPending => status == CheckPromissoryStatus.pending;

  /// Bankaya yatırıldı mı?
  bool get isDeposited => status == CheckPromissoryStatus.deposited;

  /// Müşteri çeki/senedi mi?
  bool get isCustomerDocument => customerId != null;

  /// Tedarikçi çeki/senedi mi?
  bool get isSupplierDocument => supplierId != null;

  /// Banka bilgisi var mı?
  bool get hasBankInfo => bankName != null && bankName!.isNotEmpty;

  /// Çek numarası var mı?
  bool get hasCheckNumber => checkNumber != null && checkNumber!.isNotEmpty;

  /// İlgili satış var mı?
  bool get hasRelatedSale => relatedSaleId != null && relatedSaleId!.isNotEmpty;

  /// İlgili satınalma var mı?
  bool get hasRelatedPurchase =>
      relatedPurchaseId != null && relatedPurchaseId!.isNotEmpty;

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// İade edilebilir mi?
  bool get canBeReturned {
    return status == CheckPromissoryStatus.pending ||
        status == CheckPromissoryStatus.deposited;
  }

  /// Protesto edilebilir mi?
  bool get canBeProtested {
    return status == CheckPromissoryStatus.returned;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status == CheckPromissoryStatus.pending;
  }

  /// Bankaya yatırılabilir mi?
  bool get canBeDeposited {
    return status == CheckPromissoryStatus.pending;
  }

  /// Tahsil edilebilir mi?
  bool get canBeCollected {
    return status == CheckPromissoryStatus.deposited;
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

  @override
  String toString() {
    return 'CheckPromissory(id: $id, documentNumber: $documentNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckPromissory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
