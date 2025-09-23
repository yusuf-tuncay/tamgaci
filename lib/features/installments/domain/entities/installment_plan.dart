// ========== INSTALLMENT PLAN ENTITY ==========
// lib/features/installments/domain/entities/installment_plan.dart

/// Taksit planı türü
enum InstallmentPlanType {
  sales('Satış Taksitleri'),
  purchase('Satın Alma Taksitleri'),
  loan('Kredi Taksitleri'),
  other('Diğer Taksitler');

  const InstallmentPlanType(this.displayName);
  final String displayName;
}

/// Taksit planı durumu
enum InstallmentPlanStatus {
  active('Aktif'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi'),
  suspended('Askıya Alındı');

  const InstallmentPlanStatus(this.displayName);
  final String displayName;
}

/// Taksit planı entity'si
class InstallmentPlan {
  final String id;
  final String planNumber;
  final InstallmentPlanType type;
  final InstallmentPlanStatus status;
  final String? customerId; // Müşteri ID'si
  final String? customerName; // Müşteri adı
  final String? supplierId; // Tedarikçi ID'si
  final String? supplierName; // Tedarikçi adı
  final double totalAmount;
  final String currency;
  final int installmentCount;
  final double installmentAmount;
  final double? interestRate; // Faiz oranı
  final double? totalInterest; // Toplam faiz
  final double? totalAmountWithInterest; // Faiz dahil toplam
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final String? reference;
  final String? relatedDocumentId; // İlgili belge ID'si
  final String? relatedDocumentType; // İlgili belge türü
  final String? relatedDocumentNumber; // İlgili belge numarası
  final String? notes;
  final List<InstallmentItem> installments; // Taksit kalemleri
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const InstallmentPlan({
    required this.id,
    required this.planNumber,
    required this.type,
    required this.status,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    required this.totalAmount,
    required this.currency,
    required this.installmentCount,
    required this.installmentAmount,
    this.interestRate,
    this.totalInterest,
    this.totalAmountWithInterest,
    required this.startDate,
    this.endDate,
    this.description,
    this.reference,
    this.relatedDocumentId,
    this.relatedDocumentType,
    this.relatedDocumentNumber,
    this.notes,
    this.installments = const [],
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  InstallmentPlan copyWith({
    String? id,
    String? planNumber,
    InstallmentPlanType? type,
    InstallmentPlanStatus? status,
    String? customerId,
    String? customerName,
    String? supplierId,
    String? supplierName,
    double? totalAmount,
    String? currency,
    int? installmentCount,
    double? installmentAmount,
    double? interestRate,
    double? totalInterest,
    double? totalAmountWithInterest,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? reference,
    String? relatedDocumentId,
    String? relatedDocumentType,
    String? relatedDocumentNumber,
    String? notes,
    List<InstallmentItem>? installments,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return InstallmentPlan(
      id: id ?? this.id,
      planNumber: planNumber ?? this.planNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      installmentCount: installmentCount ?? this.installmentCount,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      interestRate: interestRate ?? this.interestRate,
      totalInterest: totalInterest ?? this.totalInterest,
      totalAmountWithInterest:
          totalAmountWithInterest ?? this.totalAmountWithInterest,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      relatedDocumentNumber:
          relatedDocumentNumber ?? this.relatedDocumentNumber,
      notes: notes ?? this.notes,
      installments: installments ?? this.installments,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan InstallmentPlan oluştur
  factory InstallmentPlan.fromJson(Map<String, dynamic> json) {
    return InstallmentPlan(
      id: json['id'] as String,
      planNumber: json['planNumber'] as String,
      type: InstallmentPlanType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InstallmentPlanType.sales,
      ),
      status: InstallmentPlanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InstallmentPlanStatus.active,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      installmentCount: json['installmentCount'] as int,
      installmentAmount: (json['installmentAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      totalInterest: (json['totalInterest'] as num?)?.toDouble(),
      totalAmountWithInterest:
          (json['totalAmountWithInterest'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      relatedDocumentId: json['relatedDocumentId'] as String?,
      relatedDocumentType: json['relatedDocumentType'] as String?,
      relatedDocumentNumber: json['relatedDocumentNumber'] as String?,
      notes: json['notes'] as String?,
      installments: (json['installments'] as List<dynamic>?)
              ?.map((e) => InstallmentItem.fromJson(e as Map<String, dynamic>))
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

  /// InstallmentPlan'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planNumber': planNumber,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'totalAmount': totalAmount,
      'currency': currency,
      'installmentCount': installmentCount,
      'installmentAmount': installmentAmount,
      'interestRate': interestRate,
      'totalInterest': totalInterest,
      'totalAmountWithInterest': totalAmountWithInterest,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'reference': reference,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'relatedDocumentNumber': relatedDocumentNumber,
      'notes': notes,
      'installments': installments.map((e) => e.toJson()).toList(),
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Aktif mi?
  bool get isActive => status == InstallmentPlanStatus.active;

  /// Tamamlandı mı?
  bool get isCompleted => status == InstallmentPlanStatus.completed;

  /// İptal edildi mi?
  bool get isCancelled => status == InstallmentPlanStatus.cancelled;

  /// Askıya alındı mı?
  bool get isSuspended => status == InstallmentPlanStatus.suspended;

  /// Müşteri taksit planı mı?
  bool get isCustomerPlan => customerId != null;

  /// Tedarikçi taksit planı mı?
  bool get isSupplierPlan => supplierId != null;

  /// Faiz oranı var mı?
  bool get hasInterestRate => interestRate != null && interestRate! > 0;

  /// Toplam faiz var mı?
  bool get hasTotalInterest => totalInterest != null && totalInterest! > 0;

  /// Faiz dahil toplam var mı?
  bool get hasTotalAmountWithInterest => totalAmountWithInterest != null;

  /// Referans var mı?
  bool get hasReference => reference != null && reference!.isNotEmpty;

  /// İlgili belge var mı?
  bool get hasRelatedDocument {
    return relatedDocumentId != null &&
        relatedDocumentId!.isNotEmpty &&
        relatedDocumentType != null &&
        relatedDocumentType!.isNotEmpty;
  }

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// Ödenen taksit sayısı
  int get paidInstallmentsCount => installments.where((i) => i.isPaid).length;

  /// Kalan taksit sayısı
  int get remainingInstallmentsCount =>
      installments.where((i) => !i.isPaid).length;

  /// Toplam ödenen tutar
  double get totalPaidAmount =>
      installments.where((i) => i.isPaid).fold(0.0, (sum, i) => sum + i.amount);

  /// Toplam kalan tutar
  double get totalRemainingAmount => totalAmount - totalPaidAmount;

  /// Ödeme yüzdesi
  double get paymentPercentage {
    if (totalAmount == 0) return 0;
    return (totalPaidAmount / totalAmount) * 100;
  }

  /// Vadesi geçmiş taksit sayısı
  int get overdueInstallmentsCount =>
      installments.where((i) => i.isOverdue).length;

  /// Vadesi yaklaşan taksit sayısı (7 gün)
  int get dueSoonInstallmentsCount =>
      installments.where((i) => i.isDueSoon).length;

  /// Son ödeme tarihi
  DateTime? get lastPaymentDate {
    final paidInstallments = installments.where((i) => i.isPaid).toList();
    if (paidInstallments.isEmpty) return null;
    paidInstallments.sort((a, b) => b.paymentDate!.compareTo(a.paymentDate!));
    return paidInstallments.first.paymentDate;
  }

  /// Son taksit tarihi
  DateTime? get lastInstallmentDate {
    if (installments.isEmpty) return null;
    installments.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return installments.first.dueDate;
  }

  /// Taksit planı tamamlanabilir mi?
  bool get canBeCompleted {
    return status == InstallmentPlanStatus.active &&
        paidInstallmentsCount == installmentCount;
  }

  /// Taksit planı iptal edilebilir mi?
  bool get canBeCancelled {
    return status == InstallmentPlanStatus.active ||
        status == InstallmentPlanStatus.suspended;
  }

  /// Taksit planı askıya alınabilir mi?
  bool get canBeSuspended {
    return status == InstallmentPlanStatus.active;
  }

  /// Taksit planı aktif edilebilir mi?
  bool get canBeActivated {
    return status == InstallmentPlanStatus.suspended;
  }

  @override
  String toString() {
    return 'InstallmentPlan(id: $id, planNumber: $planNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstallmentPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Taksit kalemi
class InstallmentItem {
  final String id;
  final String planId;
  final int installmentNumber;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final double? paidAmount;
  final String? paymentReference;
  final String? notes;
  final Map<String, dynamic> metadata;

  const InstallmentItem({
    required this.id,
    required this.planId,
    required this.installmentNumber,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.paymentDate,
    this.paidAmount,
    this.paymentReference,
    this.notes,
    this.metadata = const {},
  });

  /// CopyWith metodu
  InstallmentItem copyWith({
    String? id,
    String? planId,
    int? installmentNumber,
    double? amount,
    String? currency,
    DateTime? dueDate,
    DateTime? paymentDate,
    double? paidAmount,
    String? paymentReference,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return InstallmentItem(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON'dan InstallmentItem oluştur
  factory InstallmentItem.fromJson(Map<String, dynamic> json) {
    return InstallmentItem(
      id: json['id'] as String,
      planId: json['planId'] as String,
      installmentNumber: json['installmentNumber'] as int,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
      paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      paymentReference: json['paymentReference'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// InstallmentItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'installmentNumber': installmentNumber,
      'amount': amount,
      'currency': currency,
      'dueDate': dueDate.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'paidAmount': paidAmount,
      'paymentReference': paymentReference,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Ödendi mi?
  bool get isPaid =>
      paymentDate != null && paidAmount != null && paidAmount! >= amount;

  /// Kısmen ödendi mi?
  bool get isPartiallyPaid =>
      paidAmount != null && paidAmount! > 0 && paidAmount! < amount;

  /// Ödenmedi mi?
  bool get isUnpaid => paidAmount == null || paidAmount! == 0;

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && !isPaid;
  }

  /// Vadesi yaklaşıyor mu? (7 gün)
  bool get isDueSoon {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 && daysUntilDue > 0 && !isPaid;
  }

  /// Ödeme referansı var mı?
  bool get hasPaymentReference =>
      paymentReference != null && paymentReference!.isNotEmpty;

  /// Kalan tutar
  double get remainingAmount => amount - (paidAmount ?? 0);

  /// Ödeme yüzdesi
  double get paymentPercentage {
    if (amount == 0) return 0;
    return ((paidAmount ?? 0) / amount) * 100;
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

  /// Ödeme yapılabilir mi?
  bool get canBePaid => !isPaid;

  @override
  String toString() {
    return 'InstallmentItem(id: $id, installmentNumber: $installmentNumber, amount: $amount, isPaid: $isPaid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstallmentItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
