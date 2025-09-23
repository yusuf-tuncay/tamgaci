// ========== CASH FLOW ENTITY ==========
// lib/features/cash_management/domain/entities/cash_flow.dart

/// Nakit akış türü
enum CashFlowType {
  operating('İşletme'),
  investing('Yatırım'),
  financing('Finansman');

  const CashFlowType(this.displayName);
  final String displayName;
}

/// Nakit akış kategorisi
enum CashFlowCategory {
  // İşletme nakit akışları
  salesRevenue('Satış Geliri'),
  serviceRevenue('Hizmet Geliri'),
  purchasePayments('Satın Alma Ödemeleri'),
  operatingExpenses('İşletme Giderleri'),
  salaryPayments('Maaş Ödemeleri'),
  taxPayments('Vergi Ödemeleri'),

  // Yatırım nakit akışları
  assetPurchases('Varlık Alımları'),
  assetSales('Varlık Satışları'),
  investmentIncome('Yatırım Geliri'),
  investmentExpenses('Yatırım Giderleri'),

  // Finansman nakit akışları
  loanReceipts('Kredi Alımları'),
  loanPayments('Kredi Ödemeleri'),
  equityInvestments('Sermaye Yatırımları'),
  dividendPayments('Temettü Ödemeleri');

  const CashFlowCategory(this.displayName);
  final String displayName;
}

/// Nakit akış entity'si
class CashFlow {
  final String id;
  final String flowNumber;
  final CashFlowType type;
  final CashFlowCategory category;
  final String? accountId; // Hesap ID'si
  final String? accountName; // Hesap adı
  final double amount;
  final String currency;
  final DateTime flowDate;
  final String? description;
  final String? reference;
  final String? relatedDocumentId; // İlgili belge ID'si
  final String? relatedDocumentType; // İlgili belge türü
  final String? relatedDocumentNumber; // İlgili belge numarası
  final String? notes;
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const CashFlow({
    required this.id,
    required this.flowNumber,
    required this.type,
    required this.category,
    this.accountId,
    this.accountName,
    required this.amount,
    required this.currency,
    required this.flowDate,
    this.description,
    this.reference,
    this.relatedDocumentId,
    this.relatedDocumentType,
    this.relatedDocumentNumber,
    this.notes,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  CashFlow copyWith({
    String? id,
    String? flowNumber,
    CashFlowType? type,
    CashFlowCategory? category,
    String? accountId,
    String? accountName,
    double? amount,
    String? currency,
    DateTime? flowDate,
    String? description,
    String? reference,
    String? relatedDocumentId,
    String? relatedDocumentType,
    String? relatedDocumentNumber,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CashFlow(
      id: id ?? this.id,
      flowNumber: flowNumber ?? this.flowNumber,
      type: type ?? this.type,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      flowDate: flowDate ?? this.flowDate,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      relatedDocumentNumber:
          relatedDocumentNumber ?? this.relatedDocumentNumber,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan CashFlow oluştur
  factory CashFlow.fromJson(Map<String, dynamic> json) {
    return CashFlow(
      id: json['id'] as String,
      flowNumber: json['flowNumber'] as String,
      type: CashFlowType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CashFlowType.operating,
      ),
      category: CashFlowCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => CashFlowCategory.salesRevenue,
      ),
      accountId: json['accountId'] as String?,
      accountName: json['accountName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      flowDate: DateTime.parse(json['flowDate'] as String),
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      relatedDocumentId: json['relatedDocumentId'] as String?,
      relatedDocumentType: json['relatedDocumentType'] as String?,
      relatedDocumentNumber: json['relatedDocumentNumber'] as String?,
      notes: json['notes'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// CashFlow'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flowNumber': flowNumber,
      'type': type.name,
      'category': category.name,
      'accountId': accountId,
      'accountName': accountName,
      'amount': amount,
      'currency': currency,
      'flowDate': flowDate.toIso8601String(),
      'description': description,
      'reference': reference,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'relatedDocumentNumber': relatedDocumentNumber,
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Giriş mi?
  bool get isInflow => amount > 0;

  /// Çıkış mı?
  bool get isOutflow => amount < 0;

  /// İşletme nakit akışı mı?
  bool get isOperating => type == CashFlowType.operating;

  /// Yatırım nakit akışı mı?
  bool get isInvesting => type == CashFlowType.investing;

  /// Finansman nakit akışı mı?
  bool get isFinancing => type == CashFlowType.financing;

  /// Hesap bilgisi var mı?
  bool get hasAccount => accountId != null && accountId!.isNotEmpty;

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

  /// Mutlak tutar
  double get absoluteAmount => amount.abs();

  /// Nakit akış yönü
  String get flowDirection => isInflow ? 'Giriş' : 'Çıkış';

  /// Nakit akış türü rengi
  String get typeColor {
    switch (type) {
      case CashFlowType.operating:
        return '#2196F3'; // Mavi
      case CashFlowType.investing:
        return '#4CAF50'; // Yeşil
      case CashFlowType.financing:
        return '#FF9800'; // Turuncu
    }
  }

  @override
  String toString() {
    return 'CashFlow(id: $id, flowNumber: $flowNumber, type: $type, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CashFlow && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Nakit akış özeti
class CashFlowSummary {
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final double operatingInflow;
  final double operatingOutflow;
  final double investingInflow;
  final double investingOutflow;
  final double financingInflow;
  final double financingOutflow;
  final double netOperatingFlow;
  final double netInvestingFlow;
  final double netFinancingFlow;
  final double netCashFlow;
  final double openingBalance;
  final double closingBalance;

  const CashFlowSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.currency,
    required this.operatingInflow,
    required this.operatingOutflow,
    required this.investingInflow,
    required this.investingOutflow,
    required this.financingInflow,
    required this.financingOutflow,
    required this.netOperatingFlow,
    required this.netInvestingFlow,
    required this.netFinancingFlow,
    required this.netCashFlow,
    required this.openingBalance,
    required this.closingBalance,
  });

  /// CopyWith metodu
  CashFlowSummary copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    String? currency,
    double? operatingInflow,
    double? operatingOutflow,
    double? investingInflow,
    double? investingOutflow,
    double? financingInflow,
    double? financingOutflow,
    double? netOperatingFlow,
    double? netInvestingFlow,
    double? netFinancingFlow,
    double? netCashFlow,
    double? openingBalance,
    double? closingBalance,
  }) {
    return CashFlowSummary(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      currency: currency ?? this.currency,
      operatingInflow: operatingInflow ?? this.operatingInflow,
      operatingOutflow: operatingOutflow ?? this.operatingOutflow,
      investingInflow: investingInflow ?? this.investingInflow,
      investingOutflow: investingOutflow ?? this.investingOutflow,
      financingInflow: financingInflow ?? this.financingInflow,
      financingOutflow: financingOutflow ?? this.financingOutflow,
      netOperatingFlow: netOperatingFlow ?? this.netOperatingFlow,
      netInvestingFlow: netInvestingFlow ?? this.netInvestingFlow,
      netFinancingFlow: netFinancingFlow ?? this.netFinancingFlow,
      netCashFlow: netCashFlow ?? this.netCashFlow,
      openingBalance: openingBalance ?? this.openingBalance,
      closingBalance: closingBalance ?? this.closingBalance,
    );
  }

  /// JSON'dan CashFlowSummary oluştur
  factory CashFlowSummary.fromJson(Map<String, dynamic> json) {
    return CashFlowSummary(
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      currency: json['currency'] as String,
      operatingInflow: (json['operatingInflow'] as num).toDouble(),
      operatingOutflow: (json['operatingOutflow'] as num).toDouble(),
      investingInflow: (json['investingInflow'] as num).toDouble(),
      investingOutflow: (json['investingOutflow'] as num).toDouble(),
      financingInflow: (json['financingInflow'] as num).toDouble(),
      financingOutflow: (json['financingOutflow'] as num).toDouble(),
      netOperatingFlow: (json['netOperatingFlow'] as num).toDouble(),
      netInvestingFlow: (json['netInvestingFlow'] as num).toDouble(),
      netFinancingFlow: (json['netFinancingFlow'] as num).toDouble(),
      netCashFlow: (json['netCashFlow'] as num).toDouble(),
      openingBalance: (json['openingBalance'] as num).toDouble(),
      closingBalance: (json['closingBalance'] as num).toDouble(),
    );
  }

  /// CashFlowSummary'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'currency': currency,
      'operatingInflow': operatingInflow,
      'operatingOutflow': operatingOutflow,
      'investingInflow': investingInflow,
      'investingOutflow': investingOutflow,
      'financingInflow': financingInflow,
      'financingOutflow': financingOutflow,
      'netOperatingFlow': netOperatingFlow,
      'netInvestingFlow': netInvestingFlow,
      'netFinancingFlow': netFinancingFlow,
      'netCashFlow': netCashFlow,
      'openingBalance': openingBalance,
      'closingBalance': closingBalance,
    };
  }

  /// Pozitif nakit akışı var mı?
  bool get hasPositiveCashFlow => netCashFlow > 0;

  /// Negatif nakit akışı var mı?
  bool get hasNegativeCashFlow => netCashFlow < 0;

  /// Dönem süresi (gün)
  int get periodDays => periodEnd.difference(periodStart).inDays + 1;

  /// Günlük ortalama nakit akışı
  double get dailyAverageCashFlow => netCashFlow / periodDays;

  @override
  String toString() {
    return 'CashFlowSummary(periodStart: $periodStart, periodEnd: $periodEnd, netCashFlow: $netCashFlow)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CashFlowSummary &&
        other.periodStart == periodStart &&
        other.periodEnd == periodEnd;
  }

  @override
  int get hashCode => periodStart.hashCode ^ periodEnd.hashCode;
}
