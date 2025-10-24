// ========== PAYMENT TRANSACTION ENTITY ==========
// lib/features/payment_collection/domain/entities/payment_transaction.dart

import 'package:equatable/equatable.dart';
import 'payment_enums.dart';

/// Ana tahsilat ve ödeme işlemi entity'si
/// Tüm finansal hareketlerin merkezi kaydı
class PaymentTransaction extends Equatable {
  /// Benzersiz işlem ID'si
  final String id;

  /// İşlem numarası (otomatik oluşturulan)
  final String transactionNumber;

  /// İşlem türü
  final PaymentTransactionType type;

  /// İşlem kategorisi
  final PaymentTransactionCategory category;

  /// İşlem durumu
  final PaymentTransactionStatus status;

  /// İşlem yönü (Giriş/Çıkış)
  final PaymentDirection direction;

  /// Tutar
  final double amount;

  /// Para birimi
  final String currency;

  /// İşlem tarihi
  final DateTime transactionDate;

  /// Vade tarihi (çek, senet için)
  final DateTime? dueDate;

  /// Açıklama
  final String? description;

  /// Referans numarası
  final String? referenceNumber;

  /// Notlar
  final String? notes;

  /// İlişkili müşteri ID'si (tahsilat için)
  final String? customerId;

  /// İlişkili tedarikçi ID'si (ödeme için)
  final String? supplierId;

  /// İlişkili gelir ID'si (gelir fişi için)
  final String? revenueId;

  /// İlişkili gider ID'si (gider fişi için)
  final String? expenseId;

  /// Kaynak hesap ID'si (zorunlu)
  final String accountId;

  /// Hedef hesap ID'si
  final String? targetAccountId;

  /// Ödeme yöntemi ID'si (zorunlu)
  final String paymentMethodId;

  /// Ödeme kaynağı ID'si
  final String? paymentSourceId;

  /// İlişkili belge ID'si (fatura, makbuz vb.)
  final String? relatedDocumentId;

  /// İlişkili belge türü
  final String? relatedDocumentType;

  /// Ek dosyalar
  final List<String> attachments;

  /// Ekstra metadata
  final Map<String, dynamic> metadata;

  /// Şirket ID'si
  final String companyId;

  /// Tenant ID'si (multi-tenant güvenlik)
  final String tenantId;

  /// Aktif durumu
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  /// Oluşturan kullanıcı
  final String createdBy;

  /// Güncelleyen kullanıcı
  final String? updatedBy;

  const PaymentTransaction({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.category,
    required this.status,
    required this.direction,
    required this.amount,
    required this.currency,
    required this.transactionDate,
    this.dueDate,
    this.description,
    this.referenceNumber,
    this.notes,
    this.customerId,
    this.supplierId,
    this.revenueId,
    this.expenseId,
    required this.accountId,
    this.targetAccountId,
    required this.paymentMethodId,
    this.paymentSourceId,
    this.relatedDocumentId,
    this.relatedDocumentType,
    this.attachments = const [],
    this.metadata = const {},
    required this.companyId,
    required this.tenantId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  PaymentTransaction copyWith({
    String? id,
    String? transactionNumber,
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
    PaymentTransactionStatus? status,
    PaymentDirection? direction,
    double? amount,
    String? currency,
    DateTime? transactionDate,
    DateTime? dueDate,
    String? description,
    String? referenceNumber,
    String? notes,
    String? customerId,
    String? supplierId,
    String? revenueId,
    String? expenseId,
    String? accountId,
    String? targetAccountId,
    String? paymentMethodId,
    String? paymentSourceId,
    String? relatedDocumentId,
    String? relatedDocumentType,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? companyId,
    String? tenantId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      revenueId: revenueId ?? this.revenueId,
      expenseId: expenseId ?? this.expenseId,
      accountId: accountId ?? this.accountId,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentSourceId: paymentSourceId ?? this.paymentSourceId,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      companyId: companyId ?? this.companyId,
      tenantId: tenantId ?? this.tenantId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan PaymentTransaction oluştur
  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      transactionNumber: json['transactionNumber'] as String,
      type: PaymentTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentTransactionType.cash,
      ),
      category: PaymentTransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PaymentTransactionCategory.customerPayment,
      ),
      status: PaymentTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentTransactionStatus.pending,
      ),
      direction: PaymentDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => PaymentDirection.incoming,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      description: json['description'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
      customerId: json['customerId'] as String?,
      supplierId: json['supplierId'] as String?,
      revenueId: json['revenueId'] as String?,
      expenseId: json['expenseId'] as String?,
      accountId: json['accountId'] as String,
      targetAccountId: json['targetAccountId'] as String?,
      paymentMethodId: json['paymentMethodId'] as String,
      paymentSourceId: json['paymentSourceId'] as String?,
      relatedDocumentId: json['relatedDocumentId'] as String?,
      relatedDocumentType: json['relatedDocumentType'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      companyId: json['companyId'] as String,
      tenantId: json['tenantId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// PaymentTransaction'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionNumber': transactionNumber,
      'type': type.name,
      'category': category.name,
      'status': status.name,
      'direction': direction.name,
      'amount': amount,
      'currency': currency,
      'transactionDate': transactionDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'description': description,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'customerId': customerId,
      'supplierId': supplierId,
      'revenueId': revenueId,
      'expenseId': expenseId,
      'accountId': accountId,
      'targetAccountId': targetAccountId,
      'paymentMethodId': paymentMethodId,
      'paymentSourceId': paymentSourceId,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'attachments': attachments,
      'metadata': metadata,
      'companyId': companyId,
      'tenantId': tenantId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Formatlanmış tutar
  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  /// İşlem türü görünen adı
  String get typeDisplayName {
    return type.displayName;
  }

  /// Kategori görünen adı
  String get categoryDisplayName {
    return category.displayName;
  }

  /// Durum görünen adı
  String get statusDisplayName {
    return status.displayName;
  }

  /// Yön görünen adı
  String get directionDisplayName {
    return direction.displayName;
  }

  /// Vade geçmiş mi?
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Vadeye kaç gün kaldı?
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// İşlem tamamlandı mı?
  bool get isCompleted {
    return status == PaymentTransactionStatus.completed;
  }

  /// İşlem beklemede mi?
  bool get isPending {
    return status == PaymentTransactionStatus.pending;
  }

  /// İşlem iptal edildi mi?
  bool get isCancelled {
    return status == PaymentTransactionStatus.cancelled;
  }

  /// Giriş işlemi mi?
  bool get isIncoming {
    return direction == PaymentDirection.incoming;
  }

  /// Çıkış işlemi mi?
  bool get isOutgoing {
    return direction == PaymentDirection.outgoing;
  }

  /// Müşteri işlemi mi?
  bool get isCustomerTransaction {
    return customerId != null;
  }

  /// Tedarikçi işlemi mi?
  bool get isSupplierTransaction {
    return supplierId != null;
  }

  /// İç transfer mi?
  bool get isInternalTransfer {
    return category == PaymentTransactionCategory.internalTransfer;
  }

  /// Müşteri tahsilatı mı?
  bool get isCustomerPayment {
    return customerId != null && supplierId == null;
  }

  /// Tedarikçi ödemesi mi?
  bool get isSupplierPayment {
    return supplierId != null && customerId == null;
  }

  /// Gelir fişi bağlı mı?
  bool get isRevenueLinked {
    return revenueId != null;
  }

  /// Gider fişi bağlı mı?
  bool get isExpenseLinked {
    return expenseId != null;
  }

  /// Gelir/gider fişi bağlı mı?
  bool get isRevenueExpenseLinked {
    return revenueId != null || expenseId != null;
  }

  /// İlişki doğrulama
  bool get hasValidRelationships {
    // Sadece bir tarafla ilişkili olmalı
    final hasCustomer = customerId != null;
    final hasSupplier = supplierId != null;
    final hasRevenue = revenueId != null;
    final hasExpense = expenseId != null;

    // Müşteri veya tedarikçi ile ilişkili olmalı (ikisi birden olamaz)
    if (hasCustomer && hasSupplier) return false;

    // Gelir/gider fişi ile ilişkili ise, müşteri/tedarikçi ile de ilişkili olmalı
    if (hasRevenue && !hasCustomer) return false;
    if (hasExpense && !hasSupplier) return false;

    return true;
  }

  /// İlişki türü
  String get relationshipType {
    if (isCustomerPayment) return 'customer';
    if (isSupplierPayment) return 'supplier';
    if (isInternalTransfer) return 'internal';
    return 'unknown';
  }

  /// İlişkili entity ID'si
  String? get relatedEntityId {
    if (customerId != null) return customerId;
    if (supplierId != null) return supplierId;
    return null;
  }

  /// İlişkili gelir/gider ID'si
  String? get relatedRevenueExpenseId {
    if (revenueId != null) return revenueId;
    if (expenseId != null) return expenseId;
    return null;
  }

  /// Silinmiş mi?
  bool get isDeleted {
    return status == PaymentTransactionStatus.cancelled;
  }


  @override
  List<Object?> get props => [
        id,
        transactionNumber,
        type,
        category,
        status,
        direction,
        amount,
        currency,
        transactionDate,
        dueDate,
        description,
        referenceNumber,
        notes,
        customerId,
        supplierId,
        revenueId,
        expenseId,
        accountId,
        targetAccountId,
        paymentMethodId,
        paymentSourceId,
        relatedDocumentId,
        relatedDocumentType,
        attachments,
        metadata,
        companyId,
        tenantId,
        isActive,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];


  @override
  String toString() {
    return 'PaymentTransaction(id: $id, number: $transactionNumber, type: $typeDisplayName, amount: $formattedAmount, status: $statusDisplayName)';
  }
}
