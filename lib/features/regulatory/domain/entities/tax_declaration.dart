// ========== TAX DECLARATION ENTITY ==========
// lib/features/regulatory/domain/entities/tax_declaration.dart

/// Vergi beyannamesi türü
enum TaxDeclarationType {
  vat('KDV Beyannamesi'),
  income('Gelir Vergisi Beyannamesi'),
  corporate('Kurumlar Vergisi Beyannamesi'),
  withholding('Stopaj Beyannamesi'),
  stamp('Damga Vergisi Beyannamesi'),
  other('Diğer Vergi Beyannamesi');

  const TaxDeclarationType(this.displayName);
  final String displayName;
}

/// Vergi beyannamesi durumu
enum TaxDeclarationStatus {
  draft('Taslak'),
  prepared('Hazırlandı'),
  submitted('Beyan Edildi'),
  accepted('Kabul Edildi'),
  rejected('Reddedildi'),
  amended('Düzeltme Yapıldı'),
  cancelled('İptal Edildi');

  const TaxDeclarationStatus(this.displayName);
  final String displayName;
}

/// Vergi beyannamesi entity'si
class TaxDeclaration {
  final String id;
  final String declarationNumber;
  final TaxDeclarationType type;
  final TaxDeclarationStatus status;
  final String period; // Dönem (2024-01, 2024-Q1, 2024)
  final double totalTaxAmount;
  final double totalTaxBase;
  final double totalTaxRate;
  final String currency;
  final DateTime declarationDate;
  final DateTime? submittedDate;
  final DateTime? acceptedDate;
  final DateTime? rejectedDate;
  final String? rejectionReason;
  final String? gibDeclarationId; // GİB beyanname ID'si
  final String? gibDeclarationUuid; // GİB beyanname UUID
  final String? description;
  final String? notes;
  final List<TaxDeclarationItem> items;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const TaxDeclaration({
    required this.id,
    required this.declarationNumber,
    required this.type,
    required this.status,
    required this.period,
    required this.totalTaxAmount,
    required this.totalTaxBase,
    required this.totalTaxRate,
    required this.currency,
    required this.declarationDate,
    this.submittedDate,
    this.acceptedDate,
    this.rejectedDate,
    this.rejectionReason,
    this.gibDeclarationId,
    this.gibDeclarationUuid,
    this.description,
    this.notes,
    this.items = const [],
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  TaxDeclaration copyWith({
    String? id,
    String? declarationNumber,
    TaxDeclarationType? type,
    TaxDeclarationStatus? status,
    String? period,
    double? totalTaxAmount,
    double? totalTaxBase,
    double? totalTaxRate,
    String? currency,
    DateTime? declarationDate,
    DateTime? submittedDate,
    DateTime? acceptedDate,
    DateTime? rejectedDate,
    String? rejectionReason,
    String? gibDeclarationId,
    String? gibDeclarationUuid,
    String? description,
    String? notes,
    List<TaxDeclarationItem>? items,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return TaxDeclaration(
      id: id ?? this.id,
      declarationNumber: declarationNumber ?? this.declarationNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      period: period ?? this.period,
      totalTaxAmount: totalTaxAmount ?? this.totalTaxAmount,
      totalTaxBase: totalTaxBase ?? this.totalTaxBase,
      totalTaxRate: totalTaxRate ?? this.totalTaxRate,
      currency: currency ?? this.currency,
      declarationDate: declarationDate ?? this.declarationDate,
      submittedDate: submittedDate ?? this.submittedDate,
      acceptedDate: acceptedDate ?? this.acceptedDate,
      rejectedDate: rejectedDate ?? this.rejectedDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      gibDeclarationId: gibDeclarationId ?? this.gibDeclarationId,
      gibDeclarationUuid: gibDeclarationUuid ?? this.gibDeclarationUuid,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan TaxDeclaration oluştur
  factory TaxDeclaration.fromJson(Map<String, dynamic> json) {
    return TaxDeclaration(
      id: json['id'] as String,
      declarationNumber: json['declarationNumber'] as String,
      type: TaxDeclarationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaxDeclarationType.vat,
      ),
      status: TaxDeclarationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaxDeclarationStatus.draft,
      ),
      period: json['period'] as String,
      totalTaxAmount: (json['totalTaxAmount'] as num).toDouble(),
      totalTaxBase: (json['totalTaxBase'] as num).toDouble(),
      totalTaxRate: (json['totalTaxRate'] as num).toDouble(),
      currency: json['currency'] as String,
      declarationDate: DateTime.parse(json['declarationDate'] as String),
      submittedDate: json['submittedDate'] != null
          ? DateTime.parse(json['submittedDate'] as String)
          : null,
      acceptedDate: json['acceptedDate'] != null
          ? DateTime.parse(json['acceptedDate'] as String)
          : null,
      rejectedDate: json['rejectedDate'] != null
          ? DateTime.parse(json['rejectedDate'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      gibDeclarationId: json['gibDeclarationId'] as String?,
      gibDeclarationUuid: json['gibDeclarationUuid'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => TaxDeclarationItem.fromJson(e as Map<String, dynamic>))
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

  /// TaxDeclaration'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'declarationNumber': declarationNumber,
      'type': type.name,
      'status': status.name,
      'period': period,
      'totalTaxAmount': totalTaxAmount,
      'totalTaxBase': totalTaxBase,
      'totalTaxRate': totalTaxRate,
      'currency': currency,
      'declarationDate': declarationDate.toIso8601String(),
      'submittedDate': submittedDate?.toIso8601String(),
      'acceptedDate': acceptedDate?.toIso8601String(),
      'rejectedDate': rejectedDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'gibDeclarationId': gibDeclarationId,
      'gibDeclarationUuid': gibDeclarationUuid,
      'description': description,
      'notes': notes,
      'items': items.map((e) => e.toJson()).toList(),
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Taslak mı?
  bool get isDraft => status == TaxDeclarationStatus.draft;

  /// Hazırlandı mı?
  bool get isPrepared => status == TaxDeclarationStatus.prepared;

  /// Beyan edildi mi?
  bool get isSubmitted => status == TaxDeclarationStatus.submitted;

  /// Kabul edildi mi?
  bool get isAccepted => status == TaxDeclarationStatus.accepted;

  /// Reddedildi mi?
  bool get isRejected => status == TaxDeclarationStatus.rejected;

  /// Düzeltme yapıldı mı?
  bool get isAmended => status == TaxDeclarationStatus.amended;

  /// İptal edildi mi?
  bool get isCancelled => status == TaxDeclarationStatus.cancelled;

  /// KDV beyannamesi mi?
  bool get isVatDeclaration => type == TaxDeclarationType.vat;

  /// Gelir vergisi beyannamesi mi?
  bool get isIncomeDeclaration => type == TaxDeclarationType.income;

  /// Kurumlar vergisi beyannamesi mi?
  bool get isCorporateDeclaration => type == TaxDeclarationType.corporate;

  /// Stopaj beyannamesi mi?
  bool get isWithholdingDeclaration => type == TaxDeclarationType.withholding;

  /// Damga vergisi beyannamesi mi?
  bool get isStampDeclaration => type == TaxDeclarationType.stamp;

  /// Diğer vergi beyannamesi mi?
  bool get isOtherDeclaration => type == TaxDeclarationType.other;

  /// GİB beyanname ID'si var mı?
  bool get hasGibDeclarationId =>
      gibDeclarationId != null && gibDeclarationId!.isNotEmpty;

  /// GİB beyanname UUID var mı?
  bool get hasGibDeclarationUuid =>
      gibDeclarationUuid != null && gibDeclarationUuid!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// Red nedeni var mı?
  bool get hasRejectionReason =>
      rejectionReason != null && rejectionReason!.isNotEmpty;

  /// Hazırlanabilir mi?
  bool get canBePrepared {
    return status == TaxDeclarationStatus.draft && items.isNotEmpty;
  }

  /// Beyan edilebilir mi?
  bool get canBeSubmitted {
    return status == TaxDeclarationStatus.prepared;
  }

  /// Düzeltme yapılabilir mi?
  bool get canBeAmended {
    return status == TaxDeclarationStatus.submitted ||
        status == TaxDeclarationStatus.accepted;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status != TaxDeclarationStatus.submitted &&
        status != TaxDeclarationStatus.accepted &&
        status != TaxDeclarationStatus.cancelled;
  }

  /// Beyan süresi (gün)
  int? get submissionTimeInDays {
    if (submittedDate == null) return null;
    return submittedDate!.difference(declarationDate).inDays;
  }

  /// Kabul süresi (gün)
  int? get acceptanceTimeInDays {
    if (acceptedDate == null || submittedDate == null) return null;
    return acceptedDate!.difference(submittedDate!).inDays;
  }

  /// Red süresi (gün)
  int? get rejectionTimeInDays {
    if (rejectedDate == null || submittedDate == null) return null;
    return rejectedDate!.difference(submittedDate!).inDays;
  }

  /// Toplam vergi oranı yüzdesi
  double get totalTaxRatePercentage => totalTaxRate * 100;

  /// Toplam vergi oranı etiketi
  String get totalTaxRateLabel =>
      '${totalTaxRatePercentage.toStringAsFixed(2)}%';

  /// Pozitif toplam vergi tutarı mı?
  bool get isPositiveTotalTaxAmount => totalTaxAmount > 0;

  /// Pozitif toplam vergi matrahı mı?
  bool get isPositiveTotalTaxBase => totalTaxBase > 0;

  /// Pozitif toplam vergi oranı mı?
  bool get isPositiveTotalTaxRate => totalTaxRate > 0;

  /// Sıfır toplam vergi tutarı mı?
  bool get isZeroTotalTaxAmount => totalTaxAmount == 0;

  /// Sıfır toplam vergi matrahı mı?
  bool get isZeroTotalTaxBase => totalTaxBase == 0;

  /// Sıfır toplam vergi oranı mı?
  bool get isZeroTotalTaxRate => totalTaxRate == 0;

  /// Yüksek toplam vergi tutarı mı? (100,000'den fazla)
  bool get isHighTotalTaxAmount => totalTaxAmount > 100000;

  /// Düşük toplam vergi tutarı mı? (1,000'den az)
  bool get isLowTotalTaxAmount => totalTaxAmount < 1000;

  /// Orta toplam vergi tutarı mı? (1,000-100,000 arası)
  bool get isMediumTotalTaxAmount =>
      totalTaxAmount >= 1000 && totalTaxAmount <= 100000;

  /// Toplam vergi tutarı kategorisi
  String get totalTaxAmountCategory {
    if (isHighTotalTaxAmount) return 'Yüksek';
    if (isLowTotalTaxAmount) return 'Düşük';
    return 'Orta';
  }

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Toplam kalem vergi tutarı
  double get totalItemsTaxAmount =>
      items.fold(0.0, (sum, item) => sum + item.taxAmount);

  /// Toplam kalem vergi matrahı
  double get totalItemsTaxBase =>
      items.fold(0.0, (sum, item) => sum + item.taxBase);

  @override
  String toString() {
    return 'TaxDeclaration(id: $id, declarationNumber: $declarationNumber, type: $type, totalTaxAmount: $totalTaxAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxDeclaration && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Vergi beyannamesi kalemi
class TaxDeclarationItem {
  final String id;
  final String accountCode; // Hesap kodu
  final String accountName; // Hesap adı
  final double taxBase; // Vergi matrahı
  final double taxRate; // Vergi oranı
  final double taxAmount; // Vergi tutarı
  final String currency;
  final String? description;
  final String? notes;

  const TaxDeclarationItem({
    required this.id,
    required this.accountCode,
    required this.accountName,
    required this.taxBase,
    required this.taxRate,
    required this.taxAmount,
    required this.currency,
    this.description,
    this.notes,
  });

  /// CopyWith metodu
  TaxDeclarationItem copyWith({
    String? id,
    String? accountCode,
    String? accountName,
    double? taxBase,
    double? taxRate,
    double? taxAmount,
    String? currency,
    String? description,
    String? notes,
  }) {
    return TaxDeclarationItem(
      id: id ?? this.id,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      taxBase: taxBase ?? this.taxBase,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan TaxDeclarationItem oluştur
  factory TaxDeclarationItem.fromJson(Map<String, dynamic> json) {
    return TaxDeclarationItem(
      id: json['id'] as String,
      accountCode: json['accountCode'] as String,
      accountName: json['accountName'] as String,
      taxBase: (json['taxBase'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// TaxDeclarationItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountCode': accountCode,
      'accountName': accountName,
      'taxBase': taxBase,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'currency': currency,
      'description': description,
      'notes': notes,
    };
  }

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Pozitif vergi matrahı mı?
  bool get isPositiveTaxBase => taxBase > 0;

  /// Pozitif vergi oranı mı?
  bool get isPositiveTaxRate => taxRate > 0;

  /// Pozitif vergi tutarı mı?
  bool get isPositiveTaxAmount => taxAmount > 0;

  /// Sıfır vergi matrahı mı?
  bool get isZeroTaxBase => taxBase == 0;

  /// Sıfır vergi oranı mı?
  bool get isZeroTaxRate => taxRate == 0;

  /// Sıfır vergi tutarı mı?
  bool get isZeroTaxAmount => taxAmount == 0;

  /// Vergi oranı yüzdesi
  double get taxRatePercentage => taxRate * 100;

  /// Vergi oranı etiketi
  String get taxRateLabel => '${taxRatePercentage.toStringAsFixed(2)}%';

  /// Yüksek vergi oranı mı? (%20'den fazla)
  bool get isHighTaxRate => taxRate > 0.20;

  /// Düşük vergi oranı mı? (%5'ten az)
  bool get isLowTaxRate => taxRate < 0.05;

  /// Orta vergi oranı mı? (%5-20 arası)
  bool get isMediumTaxRate => taxRate >= 0.05 && taxRate <= 0.20;

  /// Vergi oranı kategorisi
  String get taxRateCategory {
    if (isHighTaxRate) return 'Yüksek';
    if (isLowTaxRate) return 'Düşük';
    return 'Orta';
  }

  /// Yüksek vergi tutarı mı? (10,000'den fazla)
  bool get isHighTaxAmount => taxAmount > 10000;

  /// Düşük vergi tutarı mı? (100'den az)
  bool get isLowTaxAmount => taxAmount < 100;

  /// Orta vergi tutarı mı? (100-10,000 arası)
  bool get isMediumTaxAmount => taxAmount >= 100 && taxAmount <= 10000;

  /// Vergi tutarı kategorisi
  String get taxAmountCategory {
    if (isHighTaxAmount) return 'Yüksek';
    if (isLowTaxAmount) return 'Düşük';
    return 'Orta';
  }

  @override
  String toString() {
    return 'TaxDeclarationItem(id: $id, accountCode: $accountCode, accountName: $accountName, taxAmount: $taxAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxDeclarationItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
