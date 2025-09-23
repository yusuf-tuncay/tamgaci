// ========== PURCHASE EXPENSE ENTITY ==========
// lib/features/purchases/domain/entities/purchase_expense.dart

/// Satınalma masrafı türü
enum PurchaseExpenseType {
  shipping('Nakliye'),
  insurance('Sigorta'),
  customs('Gümrük'),
  handling('Elleçleme'),
  storage('Depolama'),
  inspection('Muayene'),
  certification('Sertifikasyon'),
  bank('Banka'),
  other('Diğer');

  const PurchaseExpenseType(this.displayName);
  final String displayName;
}

/// Satınalma masrafı durumu
enum PurchaseExpenseStatus {
  draft('Taslak'),
  pending('Beklemede'),
  approved('Onaylandı'),
  paid('Ödendi'),
  cancelled('İptal Edildi');

  const PurchaseExpenseStatus(this.displayName);
  final String displayName;
}

/// Satınalma masrafı entity'si
class PurchaseExpense {
  final String id;
  final String expenseNumber;
  final PurchaseExpenseType type;
  final PurchaseExpenseStatus status;
  final String? purchaseOrderId; // Satınalma siparişi ID'si
  final String? purchaseOrderNumber; // Satınalma siparişi numarası
  final String? goodsReceiptId; // Mal kabul ID'si
  final String? goodsReceiptNumber; // Mal kabul numarası
  final String supplierId;
  final String? supplierName;
  final String? expenseSupplierId; // Masraf tedarikçisi ID'si (farklı olabilir)
  final String? expenseSupplierName; // Masraf tedarikçisi adı
  final DateTime expenseDate;
  final DateTime? dueDate; // Vade tarihi
  final double amount;
  final String currency;
  final double? exchangeRate; // Döviz kuru
  final String? exchangeRateSource; // Kur kaynağı
  final DateTime? exchangeRateDate; // Kur tarihi
  final String? description;
  final String? notes;
  final String? reference; // Referans numarası
  final String? invoiceNumber; // Fatura numarası
  final String? paymentMethod; // Ödeme yöntemi
  final String? paymentTerms; // Ödeme koşulları
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const PurchaseExpense({
    required this.id,
    required this.expenseNumber,
    required this.type,
    required this.status,
    this.purchaseOrderId,
    this.purchaseOrderNumber,
    this.goodsReceiptId,
    this.goodsReceiptNumber,
    required this.supplierId,
    this.supplierName,
    this.expenseSupplierId,
    this.expenseSupplierName,
    required this.expenseDate,
    this.dueDate,
    required this.amount,
    required this.currency,
    this.exchangeRate,
    this.exchangeRateSource,
    this.exchangeRateDate,
    this.description,
    this.notes,
    this.reference,
    this.invoiceNumber,
    this.paymentMethod,
    this.paymentTerms,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  PurchaseExpense copyWith({
    String? id,
    String? expenseNumber,
    PurchaseExpenseType? type,
    PurchaseExpenseStatus? status,
    String? purchaseOrderId,
    String? purchaseOrderNumber,
    String? goodsReceiptId,
    String? goodsReceiptNumber,
    String? supplierId,
    String? supplierName,
    String? expenseSupplierId,
    String? expenseSupplierName,
    DateTime? expenseDate,
    DateTime? dueDate,
    double? amount,
    String? currency,
    double? exchangeRate,
    String? exchangeRateSource,
    DateTime? exchangeRateDate,
    String? description,
    String? notes,
    String? reference,
    String? invoiceNumber,
    String? paymentMethod,
    String? paymentTerms,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PurchaseExpense(
      id: id ?? this.id,
      expenseNumber: expenseNumber ?? this.expenseNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      purchaseOrderNumber: purchaseOrderNumber ?? this.purchaseOrderNumber,
      goodsReceiptId: goodsReceiptId ?? this.goodsReceiptId,
      goodsReceiptNumber: goodsReceiptNumber ?? this.goodsReceiptNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      expenseSupplierId: expenseSupplierId ?? this.expenseSupplierId,
      expenseSupplierName: expenseSupplierName ?? this.expenseSupplierName,
      expenseDate: expenseDate ?? this.expenseDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      exchangeRateSource: exchangeRateSource ?? this.exchangeRateSource,
      exchangeRateDate: exchangeRateDate ?? this.exchangeRateDate,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      reference: reference ?? this.reference,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan PurchaseExpense oluştur
  factory PurchaseExpense.fromJson(Map<String, dynamic> json) {
    return PurchaseExpense(
      id: json['id'] as String,
      expenseNumber: json['expenseNumber'] as String,
      type: PurchaseExpenseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PurchaseExpenseType.other,
      ),
      status: PurchaseExpenseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PurchaseExpenseStatus.draft,
      ),
      purchaseOrderId: json['purchaseOrderId'] as String?,
      purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
      goodsReceiptId: json['goodsReceiptId'] as String?,
      goodsReceiptNumber: json['goodsReceiptNumber'] as String?,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      expenseSupplierId: json['expenseSupplierId'] as String?,
      expenseSupplierName: json['expenseSupplierName'] as String?,
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      exchangeRateSource: json['exchangeRateSource'] as String?,
      exchangeRateDate: json['exchangeRateDate'] != null
          ? DateTime.parse(json['exchangeRateDate'] as String)
          : null,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      reference: json['reference'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// PurchaseExpense'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseNumber': expenseNumber,
      'type': type.name,
      'status': status.name,
      'purchaseOrderId': purchaseOrderId,
      'purchaseOrderNumber': purchaseOrderNumber,
      'goodsReceiptId': goodsReceiptId,
      'goodsReceiptNumber': goodsReceiptNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'expenseSupplierId': expenseSupplierId,
      'expenseSupplierName': expenseSupplierName,
      'expenseDate': expenseDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'exchangeRateSource': exchangeRateSource,
      'exchangeRateDate': exchangeRateDate?.toIso8601String(),
      'description': description,
      'notes': notes,
      'reference': reference,
      'invoiceNumber': invoiceNumber,
      'paymentMethod': paymentMethod,
      'paymentTerms': paymentTerms,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Kur kilitleme yapılmış mı?
  bool get isExchangeRateLocked => exchangeRate != null;

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) &&
        status != PurchaseExpenseStatus.paid;
  }

  /// Onaylanabilir mi?
  bool get canBeApproved {
    return status == PurchaseExpenseStatus.draft ||
        status == PurchaseExpenseStatus.pending;
  }

  /// Ödenebilir mi?
  bool get canBePaid {
    return status == PurchaseExpenseStatus.approved;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status != PurchaseExpenseStatus.cancelled &&
        status != PurchaseExpenseStatus.paid;
  }

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// Fatura numarası var mı?
  bool get hasInvoiceNumber =>
      invoiceNumber != null && invoiceNumber!.isNotEmpty;

  /// Referans numarası var mı?
  bool get hasReference => reference != null && reference!.isNotEmpty;

  /// Masraf tedarikçisi farklı mı?
  bool get hasDifferentExpenseSupplier {
    return expenseSupplierId != null && expenseSupplierId != supplierId;
  }

  @override
  String toString() {
    return 'PurchaseExpense(id: $id, expenseNumber: $expenseNumber, type: $type, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseExpense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
