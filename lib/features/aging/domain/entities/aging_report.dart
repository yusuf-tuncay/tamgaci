// ========== AGING REPORT ENTITY ==========
// lib/features/aging/domain/entities/aging_report.dart

/// Yaşlandırma raporu türü
enum AgingReportType {
  receivables('Alacaklar'),
  payables('Borçlar'),
  combined('Kombine');

  const AgingReportType(this.displayName);
  final String displayName;
}

/// Yaşlandırma raporu entity'si
class AgingReport {
  final String id;
  final String reportNumber;
  final AgingReportType type;
  final DateTime reportDate;
  final DateTime asOfDate; // Rapor tarihi
  final String currency;
  final List<AgingReportItem> items;
  final AgingReportSummary summary;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const AgingReport({
    required this.id,
    required this.reportNumber,
    required this.type,
    required this.reportDate,
    required this.asOfDate,
    required this.currency,
    this.items = const [],
    required this.summary,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  AgingReport copyWith({
    String? id,
    String? reportNumber,
    AgingReportType? type,
    DateTime? reportDate,
    DateTime? asOfDate,
    String? currency,
    List<AgingReportItem>? items,
    AgingReportSummary? summary,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return AgingReport(
      id: id ?? this.id,
      reportNumber: reportNumber ?? this.reportNumber,
      type: type ?? this.type,
      reportDate: reportDate ?? this.reportDate,
      asOfDate: asOfDate ?? this.asOfDate,
      currency: currency ?? this.currency,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan AgingReport oluştur
  factory AgingReport.fromJson(Map<String, dynamic> json) {
    return AgingReport(
      id: json['id'] as String,
      reportNumber: json['reportNumber'] as String,
      type: AgingReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AgingReportType.receivables,
      ),
      reportDate: DateTime.parse(json['reportDate'] as String),
      asOfDate: DateTime.parse(json['asOfDate'] as String),
      currency: json['currency'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => AgingReportItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary:
          AgingReportSummary.fromJson(json['summary'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// AgingReport'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportNumber': reportNumber,
      'type': type.name,
      'reportDate': reportDate.toIso8601String(),
      'asOfDate': asOfDate.toIso8601String(),
      'currency': currency,
      'items': items.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Alacak raporu mu?
  bool get isReceivablesReport => type == AgingReportType.receivables;

  /// Borç raporu mu?
  bool get isPayablesReport => type == AgingReportType.payables;

  /// Kombine rapor mu?
  bool get isCombinedReport => type == AgingReportType.combined;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Toplam kalem sayısı
  int get totalItemsCount => items.length;

  /// Toplam tutar
  double get totalAmount => summary.totalAmount;

  /// Vadesi geçmiş tutar
  double get overdueAmount => summary.overdueAmount;

  /// Vadesi geçmiş yüzde
  double get overduePercentage {
    if (totalAmount == 0) return 0;
    return (overdueAmount / totalAmount) * 100;
  }

  /// Kritik durumda mı? (Vadesi geçmiş %30'dan fazla)
  bool get isCritical => overduePercentage > 30;

  @override
  String toString() {
    return 'AgingReport(id: $id, reportNumber: $reportNumber, type: $type, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgingReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Yaşlandırma raporu kalemi
class AgingReportItem {
  final String id;
  final String? customerId;
  final String? customerName;
  final String? customerCode;
  final String? supplierId;
  final String? supplierName;
  final String? supplierCode;
  final String documentNumber;
  final DateTime documentDate;
  final DateTime dueDate;
  final double originalAmount;
  final double currentAmount;
  final double current0to30; // 0-30 gün
  final double current31to60; // 31-60 gün
  final double current61to90; // 61-90 gün
  final double currentOver90; // 90+ gün
  final String currency;
  final String? notes;

  const AgingReportItem({
    required this.id,
    this.customerId,
    this.customerName,
    this.customerCode,
    this.supplierId,
    this.supplierName,
    this.supplierCode,
    required this.documentNumber,
    required this.documentDate,
    required this.dueDate,
    required this.originalAmount,
    required this.currentAmount,
    required this.current0to30,
    required this.current31to60,
    required this.current61to90,
    required this.currentOver90,
    required this.currency,
    this.notes,
  });

  /// CopyWith metodu
  AgingReportItem copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerCode,
    String? supplierId,
    String? supplierName,
    String? supplierCode,
    String? documentNumber,
    DateTime? documentDate,
    DateTime? dueDate,
    double? originalAmount,
    double? currentAmount,
    double? current0to30,
    double? current31to60,
    double? current61to90,
    double? currentOver90,
    String? currency,
    String? notes,
  }) {
    return AgingReportItem(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerCode: customerCode ?? this.customerCode,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierCode: supplierCode ?? this.supplierCode,
      documentNumber: documentNumber ?? this.documentNumber,
      documentDate: documentDate ?? this.documentDate,
      dueDate: dueDate ?? this.dueDate,
      originalAmount: originalAmount ?? this.originalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      current0to30: current0to30 ?? this.current0to30,
      current31to60: current31to60 ?? this.current31to60,
      current61to90: current61to90 ?? this.current61to90,
      currentOver90: currentOver90 ?? this.currentOver90,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'dan AgingReportItem oluştur
  factory AgingReportItem.fromJson(Map<String, dynamic> json) {
    return AgingReportItem(
      id: json['id'] as String,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerCode: json['customerCode'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierCode: json['supplierCode'] as String?,
      documentNumber: json['documentNumber'] as String,
      documentDate: DateTime.parse(json['documentDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      originalAmount: (json['originalAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      current0to30: (json['current0to30'] as num).toDouble(),
      current31to60: (json['current31to60'] as num).toDouble(),
      current61to90: (json['current61to90'] as num).toDouble(),
      currentOver90: (json['currentOver90'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
    );
  }

  /// AgingReportItem'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerCode': customerCode,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierCode': supplierCode,
      'documentNumber': documentNumber,
      'documentDate': documentDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'originalAmount': originalAmount,
      'currentAmount': currentAmount,
      'current0to30': current0to30,
      'current31to60': current31to60,
      'current61to90': current61to90,
      'currentOver90': currentOver90,
      'currency': currency,
      'notes': notes,
    };
  }

  /// Müşteri kalemi mi?
  bool get isCustomerItem => customerId != null;

  /// Tedarikçi kalemi mi?
  bool get isSupplierItem => supplierId != null;

  /// Müşteri adı var mı?
  bool get hasCustomerName => customerName != null && customerName!.isNotEmpty;

  /// Tedarikçi adı var mı?
  bool get hasSupplierName => supplierName != null && supplierName!.isNotEmpty;

  /// Müşteri kodu var mı?
  bool get hasCustomerCode => customerCode != null && customerCode!.isNotEmpty;

  /// Tedarikçi kodu var mı?
  bool get hasSupplierCode => supplierCode != null && supplierCode!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && currentAmount > 0;
  }

  /// Vadesi yaklaşıyor mu? (7 gün)
  bool get isDueSoon {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 && daysUntilDue > 0 && currentAmount > 0;
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

  /// Ödeme yüzdesi
  double get paymentPercentage {
    if (originalAmount == 0) return 0;
    return ((originalAmount - currentAmount) / originalAmount) * 100;
  }

  /// En büyük yaşlandırma kategorisi
  String get largestAgingCategory {
    final amounts = {
      '0-30': current0to30,
      '31-60': current31to60,
      '61-90': current61to90,
      '90+': currentOver90,
    };

    final maxEntry =
        amounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return maxEntry.key;
  }

  /// En büyük yaşlandırma tutarı
  double get largestAgingAmount {
    return [current0to30, current31to60, current61to90, currentOver90]
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  String toString() {
    return 'AgingReportItem(id: $id, documentNumber: $documentNumber, currentAmount: $currentAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgingReportItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Yaşlandırma raporu özeti
class AgingReportSummary {
  final double totalAmount;
  final double current0to30;
  final double current31to60;
  final double current61to90;
  final double currentOver90;
  final double overdueAmount;
  final int totalItemsCount;
  final int overdueItemsCount;
  final String currency;

  const AgingReportSummary({
    required this.totalAmount,
    required this.current0to30,
    required this.current31to60,
    required this.current61to90,
    required this.currentOver90,
    required this.overdueAmount,
    required this.totalItemsCount,
    required this.overdueItemsCount,
    required this.currency,
  });

  /// CopyWith metodu
  AgingReportSummary copyWith({
    double? totalAmount,
    double? current0to30,
    double? current31to60,
    double? current61to90,
    double? currentOver90,
    double? overdueAmount,
    int? totalItemsCount,
    int? overdueItemsCount,
    String? currency,
  }) {
    return AgingReportSummary(
      totalAmount: totalAmount ?? this.totalAmount,
      current0to30: current0to30 ?? this.current0to30,
      current31to60: current31to60 ?? this.current31to60,
      current61to90: current61to90 ?? this.current61to90,
      currentOver90: currentOver90 ?? this.currentOver90,
      overdueAmount: overdueAmount ?? this.overdueAmount,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      overdueItemsCount: overdueItemsCount ?? this.overdueItemsCount,
      currency: currency ?? this.currency,
    );
  }

  /// JSON'dan AgingReportSummary oluştur
  factory AgingReportSummary.fromJson(Map<String, dynamic> json) {
    return AgingReportSummary(
      totalAmount: (json['totalAmount'] as num).toDouble(),
      current0to30: (json['current0to30'] as num).toDouble(),
      current31to60: (json['current31to60'] as num).toDouble(),
      current61to90: (json['current61to90'] as num).toDouble(),
      currentOver90: (json['currentOver90'] as num).toDouble(),
      overdueAmount: (json['overdueAmount'] as num).toDouble(),
      totalItemsCount: json['totalItemsCount'] as int,
      overdueItemsCount: json['overdueItemsCount'] as int,
      currency: json['currency'] as String,
    );
  }

  /// AgingReportSummary'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'current0to30': current0to30,
      'current31to60': current31to60,
      'current61to90': current61to90,
      'currentOver90': currentOver90,
      'overdueAmount': overdueAmount,
      'totalItemsCount': totalItemsCount,
      'overdueItemsCount': overdueItemsCount,
      'currency': currency,
    };
  }

  /// Vadesi geçmiş yüzde
  double get overduePercentage {
    if (totalAmount == 0) return 0;
    return (overdueAmount / totalAmount) * 100;
  }

  /// Vadesi geçmiş kalem yüzdesi
  double get overdueItemsPercentage {
    if (totalItemsCount == 0) return 0;
    return (overdueItemsCount / totalItemsCount) * 100;
  }

  /// 0-30 gün yüzdesi
  double get current0to30Percentage {
    if (totalAmount == 0) return 0;
    return (current0to30 / totalAmount) * 100;
  }

  /// 31-60 gün yüzdesi
  double get current31to60Percentage {
    if (totalAmount == 0) return 0;
    return (current31to60 / totalAmount) * 100;
  }

  /// 61-90 gün yüzdesi
  double get current61to90Percentage {
    if (totalAmount == 0) return 0;
    return (current61to90 / totalAmount) * 100;
  }

  /// 90+ gün yüzdesi
  double get currentOver90Percentage {
    if (totalAmount == 0) return 0;
    return (currentOver90 / totalAmount) * 100;
  }

  /// Kritik durumda mı? (Vadesi geçmiş %30'dan fazla)
  bool get isCritical => overduePercentage > 30;

  /// Sağlıklı durumda mı? (Vadesi geçmiş %10'dan az)
  bool get isHealthy => overduePercentage < 10;

  @override
  String toString() {
    return 'AgingReportSummary(totalAmount: $totalAmount, overdueAmount: $overdueAmount, overduePercentage: $overduePercentage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgingReportSummary &&
        other.totalAmount == totalAmount &&
        other.overdueAmount == overdueAmount;
  }

  @override
  int get hashCode => totalAmount.hashCode ^ overdueAmount.hashCode;
}
