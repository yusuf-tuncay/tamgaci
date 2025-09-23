// ========== EXCHANGE RATE LOCK ENTITY ==========
// lib/features/sales/domain/entities/exchange_rate_lock.dart

/// Kur kilitleme türü
enum ExchangeRateLockType {
  document('Belge Bazlı'),
  line('Satır Bazlı'),
  customer('Müşteri Bazlı'),
  product('Ürün Bazlı'),
  global('Global');

  const ExchangeRateLockType(this.displayName);
  final String displayName;
}

/// Kur kilitleme durumu
enum ExchangeRateLockStatus {
  active('Aktif'),
  expired('Süresi Dolmuş'),
  cancelled('İptal Edilmiş'),
  used('Kullanılmış');

  const ExchangeRateLockStatus(this.displayName);
  final String displayName;
}

/// Döviz kuru kilitleme entity'si
class ExchangeRateLock {
  final String id;
  final String lockNumber;
  final ExchangeRateLockType type;
  final ExchangeRateLockStatus status;
  final String fromCurrency;
  final String toCurrency;
  final double exchangeRate;
  final String exchangeRateSource; // Kur kaynağı (TCMB, MANUAL, etc.)
  final DateTime lockDate;
  final DateTime? validUntil; // Geçerlilik bitiş tarihi
  final String? documentId; // İlgili belge ID'si
  final String? documentType; // İlgili belge türü
  final String? documentNumber; // İlgili belge numarası
  final String? customerId; // İlgili müşteri ID'si
  final String? productId; // İlgili ürün ID'si
  final String? reason; // Kilitleme nedeni
  final String? description; // Açıklama
  final double? lockedAmount; // Kilitlenen tutar
  final String? lockedAmountCurrency; // Kilitlenen tutar para birimi
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const ExchangeRateLock({
    required this.id,
    required this.lockNumber,
    required this.type,
    required this.status,
    required this.fromCurrency,
    required this.toCurrency,
    required this.exchangeRate,
    required this.exchangeRateSource,
    required this.lockDate,
    this.validUntil,
    this.documentId,
    this.documentType,
    this.documentNumber,
    this.customerId,
    this.productId,
    this.reason,
    this.description,
    this.lockedAmount,
    this.lockedAmountCurrency,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  ExchangeRateLock copyWith({
    String? id,
    String? lockNumber,
    ExchangeRateLockType? type,
    ExchangeRateLockStatus? status,
    String? fromCurrency,
    String? toCurrency,
    double? exchangeRate,
    String? exchangeRateSource,
    DateTime? lockDate,
    DateTime? validUntil,
    String? documentId,
    String? documentType,
    String? documentNumber,
    String? customerId,
    String? productId,
    String? reason,
    String? description,
    double? lockedAmount,
    String? lockedAmountCurrency,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ExchangeRateLock(
      id: id ?? this.id,
      lockNumber: lockNumber ?? this.lockNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      exchangeRateSource: exchangeRateSource ?? this.exchangeRateSource,
      lockDate: lockDate ?? this.lockDate,
      validUntil: validUntil ?? this.validUntil,
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      customerId: customerId ?? this.customerId,
      productId: productId ?? this.productId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      lockedAmount: lockedAmount ?? this.lockedAmount,
      lockedAmountCurrency: lockedAmountCurrency ?? this.lockedAmountCurrency,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan ExchangeRateLock oluştur
  factory ExchangeRateLock.fromJson(Map<String, dynamic> json) {
    return ExchangeRateLock(
      id: json['id'] as String,
      lockNumber: json['lockNumber'] as String,
      type: ExchangeRateLockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExchangeRateLockType.document,
      ),
      status: ExchangeRateLockStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExchangeRateLockStatus.active,
      ),
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      exchangeRateSource: json['exchangeRateSource'] as String,
      lockDate: DateTime.parse(json['lockDate'] as String),
      validUntil: json['validUntil'] != null
          ? DateTime.parse(json['validUntil'] as String)
          : null,
      documentId: json['documentId'] as String?,
      documentType: json['documentType'] as String?,
      documentNumber: json['documentNumber'] as String?,
      customerId: json['customerId'] as String?,
      productId: json['productId'] as String?,
      reason: json['reason'] as String?,
      description: json['description'] as String?,
      lockedAmount: (json['lockedAmount'] as num?)?.toDouble(),
      lockedAmountCurrency: json['lockedAmountCurrency'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// ExchangeRateLock'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lockNumber': lockNumber,
      'type': type.name,
      'status': status.name,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'exchangeRate': exchangeRate,
      'exchangeRateSource': exchangeRateSource,
      'lockDate': lockDate.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'documentId': documentId,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'customerId': customerId,
      'productId': productId,
      'reason': reason,
      'description': description,
      'lockedAmount': lockedAmount,
      'lockedAmountCurrency': lockedAmountCurrency,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Kur kilitleme geçerli mi?
  bool get isValid {
    if (status != ExchangeRateLockStatus.active) return false;
    if (validUntil != null && DateTime.now().isAfter(validUntil!)) return false;
    return true;
  }

  /// Kur kilitleme süresi dolmuş mu?
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Belge bazlı kilitleme mi?
  bool get isDocumentLock => type == ExchangeRateLockType.document;

  /// Satır bazlı kilitleme mi?
  bool get isLineLock => type == ExchangeRateLockType.line;

  /// Müşteri bazlı kilitleme mi?
  bool get isCustomerLock => type == ExchangeRateLockType.customer;

  /// Ürün bazlı kilitleme mi?
  bool get isProductLock => type == ExchangeRateLockType.product;

  /// Global kilitleme mi?
  bool get isGlobalLock => type == ExchangeRateLockType.global;

  /// Belirli bir belge için geçerli mi?
  bool isApplicableToDocument(String? docId, String? docType) {
    if (!isValid) return false;
    if (isDocumentLock) {
      return documentId == docId && documentType == docType;
    }
    return true;
  }

  /// Belirli bir müşteri için geçerli mi?
  bool isApplicableToCustomer(String? customerId) {
    if (!isValid) return false;
    if (isCustomerLock) {
      return this.customerId == customerId;
    }
    return true;
  }

  /// Belirli bir ürün için geçerli mi?
  bool isApplicableToProduct(String? productId) {
    if (!isValid) return false;
    if (isProductLock) {
      return this.productId == productId;
    }
    return true;
  }

  /// Tutarı dönüştür
  double convertAmount(double amount) {
    if (!isValid) return amount;
    return amount * exchangeRate;
  }

  /// Ters dönüşüm (hedef para biriminden kaynak para birimine)
  double reverseConvertAmount(double amount) {
    if (!isValid) return amount;
    return amount / exchangeRate;
  }

  /// Kur farkı hesapla
  double calculateExchangeDifference(double amount, double currentRate) {
    if (!isValid) return 0;
    final lockedAmount = convertAmount(amount);
    final currentAmount = amount * currentRate;
    return currentAmount - lockedAmount;
  }

  @override
  String toString() {
    return 'ExchangeRateLock(id: $id, lockNumber: $lockNumber, fromCurrency: $fromCurrency, toCurrency: $toCurrency, exchangeRate: $exchangeRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExchangeRateLock && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
