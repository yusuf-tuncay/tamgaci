// ========== CREDIT LIMIT ENTITY ==========
// lib/features/credit_limits/domain/entities/credit_limit.dart

/// Kredi limiti türü
enum CreditLimitType {
  customer('Müşteri Kredi Limiti'),
  supplier('Tedarikçi Kredi Limiti'),
  general('Genel Kredi Limiti');

  const CreditLimitType(this.displayName);
  final String displayName;
}

/// Kredi limiti durumu
enum CreditLimitStatus {
  active('Aktif'),
  suspended('Askıya Alındı'),
  expired('Süresi Doldu'),
  cancelled('İptal Edildi');

  const CreditLimitStatus(this.displayName);
  final String displayName;
}

/// Kredi limiti entity'si
class CreditLimit {
  final String id;
  final String limitNumber;
  final CreditLimitType type;
  final CreditLimitStatus status;
  final String? customerId; // Müşteri ID'si
  final String? customerName; // Müşteri adı
  final String? customerCode; // Müşteri kodu
  final String? supplierId; // Tedarikçi ID'si
  final String? supplierName; // Tedarikçi adı
  final String? supplierCode; // Tedarikçi kodu
  final double creditLimit; // Kredi limiti
  final double usedAmount; // Kullanılan tutar
  final double availableAmount; // Kullanılabilir tutar
  final String currency;
  final DateTime effectiveDate; // Geçerlilik tarihi
  final DateTime? expiryDate; // Son geçerlilik tarihi
  final String? description;
  final String? notes;
  final List<CreditLimitHistory> history; // Kredi limiti geçmişi
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const CreditLimit({
    required this.id,
    required this.limitNumber,
    required this.type,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerCode,
    this.supplierId,
    this.supplierName,
    this.supplierCode,
    required this.creditLimit,
    required this.usedAmount,
    required this.availableAmount,
    required this.currency,
    required this.effectiveDate,
    this.expiryDate,
    this.description,
    this.notes,
    this.history = const [],
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  CreditLimit copyWith({
    String? id,
    String? limitNumber,
    CreditLimitType? type,
    CreditLimitStatus? status,
    String? customerId,
    String? customerName,
    String? customerCode,
    String? supplierId,
    String? supplierName,
    String? supplierCode,
    double? creditLimit,
    double? usedAmount,
    double? availableAmount,
    String? currency,
    DateTime? effectiveDate,
    DateTime? expiryDate,
    String? description,
    String? notes,
    List<CreditLimitHistory>? history,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CreditLimit(
      id: id ?? this.id,
      limitNumber: limitNumber ?? this.limitNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerCode: customerCode ?? this.customerCode,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierCode: supplierCode ?? this.supplierCode,
      creditLimit: creditLimit ?? this.creditLimit,
      usedAmount: usedAmount ?? this.usedAmount,
      availableAmount: availableAmount ?? this.availableAmount,
      currency: currency ?? this.currency,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      history: history ?? this.history,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan CreditLimit oluştur
  factory CreditLimit.fromJson(Map<String, dynamic> json) {
    return CreditLimit(
      id: json['id'] as String,
      limitNumber: json['limitNumber'] as String,
      type: CreditLimitType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CreditLimitType.customer,
      ),
      status: CreditLimitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CreditLimitStatus.active,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerCode: json['customerCode'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierCode: json['supplierCode'] as String?,
      creditLimit: (json['creditLimit'] as num).toDouble(),
      usedAmount: (json['usedAmount'] as num).toDouble(),
      availableAmount: (json['availableAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      history: (json['history'] as List<dynamic>?)
              ?.map(
                  (e) => CreditLimitHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// CreditLimit'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'limitNumber': limitNumber,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'customerCode': customerCode,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierCode': supplierCode,
      'creditLimit': creditLimit,
      'usedAmount': usedAmount,
      'availableAmount': availableAmount,
      'currency': currency,
      'effectiveDate': effectiveDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'description': description,
      'notes': notes,
      'history': history.map((e) => e.toJson()).toList(),
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Aktif mi?
  bool get isActive => status == CreditLimitStatus.active;

  /// Askıya alındı mı?
  bool get isSuspended => status == CreditLimitStatus.suspended;

  /// Süresi doldu mu?
  bool get isExpired => status == CreditLimitStatus.expired;

  /// İptal edildi mi?
  bool get isCancelled => status == CreditLimitStatus.cancelled;

  /// Müşteri kredi limiti mi?
  bool get isCustomerLimit => customerId != null;

  /// Tedarikçi kredi limiti mi?
  bool get isSupplierLimit => supplierId != null;

  /// Genel kredi limiti mi?
  bool get isGeneralLimit => type == CreditLimitType.general;

  /// Müşteri adı var mı?
  bool get hasCustomerName => customerName != null && customerName!.isNotEmpty;

  /// Tedarikçi adı var mı?
  bool get hasSupplierName => supplierName != null && supplierName!.isNotEmpty;

  /// Müşteri kodu var mı?
  bool get hasCustomerCode => customerCode != null && customerCode!.isNotEmpty;

  /// Tedarikçi kodu var mı?
  bool get hasSupplierCode => supplierCode != null && supplierCode!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// Geçmiş var mı?
  bool get hasHistory => history.isNotEmpty;

  /// Süresi dolacak mı? (30 gün)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  /// Süresi dolmuş mu?
  bool get isExpiredByDate {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Kullanım yüzdesi
  double get usagePercentage {
    if (creditLimit == 0) return 0;
    return (usedAmount / creditLimit) * 100;
  }

  /// Kalan yüzde
  double get remainingPercentage {
    if (creditLimit == 0) return 0;
    return (availableAmount / creditLimit) * 100;
  }

  /// Limit aşıldı mı?
  bool get isLimitExceeded => usedAmount > creditLimit;

  /// Limit doldu mu? (%90'dan fazla kullanıldı)
  bool get isLimitAlmostFull => usagePercentage > 90;

  /// Limit düşük mü? (%10'dan az kullanıldı)
  bool get isLimitLow => usagePercentage < 10;

  /// Limit orta mı? (%10-90 arası kullanıldı)
  bool get isLimitMedium => usagePercentage >= 10 && usagePercentage <= 90;

  /// Süresi dolacak gün sayısı
  int get daysUntilExpiry {
    if (expiryDate == null) return -1;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Süresi dolmuş gün sayısı
  int get daysExpired {
    if (!isExpiredByDate) return 0;
    return DateTime.now().difference(expiryDate!).inDays;
  }

  /// Geçerlilik süresi (gün)
  int get validityPeriodInDays {
    if (expiryDate == null) return -1;
    return expiryDate!.difference(effectiveDate).inDays;
  }

  /// Kalan geçerlilik süresi (gün)
  int get remainingValidityInDays {
    if (expiryDate == null) return -1;
    final remaining = expiryDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Güncellenebilir mi?
  bool get canBeUpdated {
    return status == CreditLimitStatus.active;
  }

  /// Askıya alınabilir mi?
  bool get canBeSuspended {
    return status == CreditLimitStatus.active;
  }

  /// Aktif edilebilir mi?
  bool get canBeActivated {
    return status == CreditLimitStatus.suspended;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status == CreditLimitStatus.active ||
        status == CreditLimitStatus.suspended;
  }

  /// Yenilenebilir mi?
  bool get canBeRenewed {
    return status == CreditLimitStatus.expired || isExpiringSoon;
  }

  /// Son güncelleme tarihi
  DateTime? get lastUpdateDate {
    if (history.isEmpty) return null;
    history.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return history.first.updatedAt;
  }

  /// Son güncelleme yapan
  String? get lastUpdatedBy {
    if (history.isEmpty) return null;
    history.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return history.first.updatedBy;
  }

  @override
  String toString() {
    return 'CreditLimit(id: $id, limitNumber: $limitNumber, type: $type, creditLimit: $creditLimit, usedAmount: $usedAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditLimit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Kredi limiti geçmişi
class CreditLimitHistory {
  final String id;
  final String creditLimitId;
  final double previousLimit;
  final double newLimit;
  final double previousUsedAmount;
  final double newUsedAmount;
  final String changeReason;
  final String? notes;
  final DateTime updatedAt;
  final String? updatedBy;

  const CreditLimitHistory({
    required this.id,
    required this.creditLimitId,
    required this.previousLimit,
    required this.newLimit,
    required this.previousUsedAmount,
    required this.newUsedAmount,
    required this.changeReason,
    this.notes,
    required this.updatedAt,
    this.updatedBy,
  });

  /// CopyWith metodu
  CreditLimitHistory copyWith({
    String? id,
    String? creditLimitId,
    double? previousLimit,
    double? newLimit,
    double? previousUsedAmount,
    double? newUsedAmount,
    String? changeReason,
    String? notes,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return CreditLimitHistory(
      id: id ?? this.id,
      creditLimitId: creditLimitId ?? this.creditLimitId,
      previousLimit: previousLimit ?? this.previousLimit,
      newLimit: newLimit ?? this.newLimit,
      previousUsedAmount: previousUsedAmount ?? this.previousUsedAmount,
      newUsedAmount: newUsedAmount ?? this.newUsedAmount,
      changeReason: changeReason ?? this.changeReason,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan CreditLimitHistory oluştur
  factory CreditLimitHistory.fromJson(Map<String, dynamic> json) {
    return CreditLimitHistory(
      id: json['id'] as String,
      creditLimitId: json['creditLimitId'] as String,
      previousLimit: (json['previousLimit'] as num).toDouble(),
      newLimit: (json['newLimit'] as num).toDouble(),
      previousUsedAmount: (json['previousUsedAmount'] as num).toDouble(),
      newUsedAmount: (json['newUsedAmount'] as num).toDouble(),
      changeReason: json['changeReason'] as String,
      notes: json['notes'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// CreditLimitHistory'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creditLimitId': creditLimitId,
      'previousLimit': previousLimit,
      'newLimit': newLimit,
      'previousUsedAmount': previousUsedAmount,
      'newUsedAmount': newUsedAmount,
      'changeReason': changeReason,
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  /// Limit artırıldı mı?
  bool get isLimitIncreased => newLimit > previousLimit;

  /// Limit azaltıldı mı?
  bool get isLimitDecreased => newLimit < previousLimit;

  /// Limit değişmedi mi?
  bool get isLimitUnchanged => newLimit == previousLimit;

  /// Kullanılan tutar artırıldı mı?
  bool get isUsedAmountIncreased => newUsedAmount > previousUsedAmount;

  /// Kullanılan tutar azaltıldı mı?
  bool get isUsedAmountDecreased => newUsedAmount < previousUsedAmount;

  /// Kullanılan tutar değişmedi mi?
  bool get isUsedAmountUnchanged => newUsedAmount == previousUsedAmount;

  /// Limit değişim tutarı
  double get limitChangeAmount => newLimit - previousLimit;

  /// Kullanılan tutar değişim miktarı
  double get usedAmountChangeAmount => newUsedAmount - previousUsedAmount;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Güncelleyen var mı?
  bool get hasUpdatedBy => updatedBy != null && updatedBy!.isNotEmpty;

  @override
  String toString() {
    return 'CreditLimitHistory(id: $id, creditLimitId: $creditLimitId, changeReason: $changeReason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditLimitHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
