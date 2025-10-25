// ========== PAYMENT TRANSACTION FORM MODEL ==========
// lib/features/payment_collection/presentation/models/payment_transaction_form_model.dart

import '../../domain/entities/payment_enums.dart';

/// Ödeme işlemi form modeli
class PaymentTransactionFormModel {
  /// İşlem türü
  PaymentTransactionType? type;

  /// İşlem kategorisi
  PaymentTransactionCategory? category;

  /// İşlem yönü
  PaymentDirection? direction;

  /// Tutar
  double? amount;

  /// Para birimi
  String currency = 'TRY';

  /// İşlem tarihi
  DateTime? transactionDate;

  /// Vade tarihi
  DateTime? dueDate;

  /// Açıklama
  String? description;

  /// Referans numarası
  String? referenceNumber;

  /// Notlar
  String? notes;

  /// Müşteri ID'si
  String? customerId;

  /// Tedarikçi ID'si
  String? supplierId;

  /// Gelir fişi ID'si
  String? revenueId;

  /// Gider fişi ID'si
  String? expenseId;

  /// Hesap ID'si (zorunlu)
  String? accountId;

  /// Kaynak hesap ID'si (cari virman için)
  String? sourceAccountId;

  /// Hedef hesap ID'si
  String? targetAccountId;

  /// Ödeme yöntemi ID'si (zorunlu)
  String? paymentMethodId;

  /// Ödeme kaynağı ID'si
  String? paymentSourceId;

  /// İlişkili belge ID'si
  String? relatedDocumentId;

  /// İlişkili belge türü
  String? relatedDocumentType;

  /// Ek dosyalar
  List<String> attachments = [];

  /// Metadata
  Map<String, dynamic> metadata = {};

  /// Hata mesajları
  Map<String, String> errors = {};

  /// Form geçerli mi?
  bool get isValid {
    return errors.isEmpty &&
        type != null &&
        category != null &&
        direction != null &&
        amount != null &&
        amount! > 0 &&
        transactionDate != null &&
        accountId != null &&
        paymentMethodId != null;
  }

  /// Form boş mu?
  bool get isEmpty {
    return type == null &&
        category == null &&
        direction == null &&
        amount == null &&
        transactionDate == null &&
        accountId == null &&
        paymentMethodId == null;
  }

  /// Form dolu mu?
  bool get isFilled {
    return !isEmpty;
  }

  /// Müşteri işlemi mi?
  bool get isCustomerTransaction {
    return customerId != null && supplierId == null;
  }

  /// Tedarikçi işlemi mi?
  bool get isSupplierTransaction {
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

  /// İç transfer mi?
  bool get isInternalTransfer {
    return category == PaymentTransactionCategory.internalTransfer;
  }

  /// Vade tarihi gerekli mi?
  bool get isDueDateRequired {
    return type == PaymentTransactionType.check ||
        type == PaymentTransactionType.promissoryNote;
  }

  /// Ödeme yöntemi gerekli mi?
  bool get isPaymentMethodRequired {
    return true; // Her zaman gerekli
  }

  /// Ödeme kaynağı gerekli mi?
  bool get isPaymentSourceRequired {
    return type != PaymentTransactionType.accountTransfer;
  }

  /// Hesap gerekli mi?
  bool get isAccountRequired {
    return true; // Her zaman gerekli
  }

  /// Hedef hesap gerekli mi?
  bool get isTargetAccountRequired {
    return direction == PaymentDirection.incoming ||
        category == PaymentTransactionCategory.internalTransfer;
  }

  /// Müşteri seçimi gerekli mi?
  bool get isCustomerSelectionRequired {
    return direction == PaymentDirection.incoming &&
        category == PaymentTransactionCategory.customerPayment;
  }

  /// Tedarikçi seçimi gerekli mi?
  bool get isSupplierSelectionRequired {
    return direction == PaymentDirection.outgoing &&
        category == PaymentTransactionCategory.supplierPayment;
  }

  /// Form temizle
  void clear() {
    type = null;
    category = null;
    direction = null;
    amount = null;
    currency = 'TRY';
    transactionDate = null;
    dueDate = null;
    description = null;
    referenceNumber = null;
    notes = null;
    customerId = null;
    supplierId = null;
    revenueId = null;
    expenseId = null;
    accountId = null;
    sourceAccountId = null;
    targetAccountId = null;
    paymentMethodId = null;
    paymentSourceId = null;
    relatedDocumentId = null;
    relatedDocumentType = null;
    attachments = [];
    metadata = {};
    errors = {};
  }

  /// Form sıfırla
  void reset() {
    clear();
  }

  /// Form kopyala
  PaymentTransactionFormModel copy() {
    return PaymentTransactionFormModel()
      ..type = type
      ..category = category
      ..direction = direction
      ..amount = amount
      ..currency = currency
      ..transactionDate = transactionDate
      ..dueDate = dueDate
      ..description = description
      ..referenceNumber = referenceNumber
      ..notes = notes
      ..customerId = customerId
      ..supplierId = supplierId
      ..revenueId = revenueId
      ..expenseId = expenseId
      ..accountId = accountId
      ..sourceAccountId = sourceAccountId
      ..targetAccountId = targetAccountId
      ..paymentMethodId = paymentMethodId
      ..paymentSourceId = paymentSourceId
      ..relatedDocumentId = relatedDocumentId
      ..relatedDocumentType = relatedDocumentType
      ..attachments = List.from(attachments)
      ..metadata = Map.from(metadata)
      ..errors = Map.from(errors);
  }

  /// Form kopyala (copyWith)
  PaymentTransactionFormModel copyWith({
    PaymentTransactionType? type,
    PaymentTransactionCategory? category,
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
    String? sourceAccountId,
    String? targetAccountId,
    String? paymentMethodId,
    String? paymentSourceId,
    String? relatedDocumentId,
    String? relatedDocumentType,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    Map<String, String>? errors,
  }) {
    return PaymentTransactionFormModel()
      ..type = type ?? this.type
      ..category = category ?? this.category
      ..direction = direction ?? this.direction
      ..amount = amount ?? this.amount
      ..currency = currency ?? this.currency
      ..transactionDate = transactionDate ?? this.transactionDate
      ..dueDate = dueDate ?? this.dueDate
      ..description = description ?? this.description
      ..referenceNumber = referenceNumber ?? this.referenceNumber
      ..notes = notes ?? this.notes
      ..customerId = customerId ?? this.customerId
      ..supplierId = supplierId ?? this.supplierId
      ..revenueId = revenueId ?? this.revenueId
      ..expenseId = expenseId ?? this.expenseId
      ..accountId = accountId ?? this.accountId
      ..sourceAccountId = sourceAccountId ?? this.sourceAccountId
      ..targetAccountId = targetAccountId ?? this.targetAccountId
      ..paymentMethodId = paymentMethodId ?? this.paymentMethodId
      ..paymentSourceId = paymentSourceId ?? this.paymentSourceId
      ..relatedDocumentId = relatedDocumentId ?? this.relatedDocumentId
      ..relatedDocumentType = relatedDocumentType ?? this.relatedDocumentType
      ..attachments = attachments ?? List.from(this.attachments)
      ..metadata = metadata ?? Map.from(this.metadata)
      ..errors = errors ?? Map.from(this.errors);
  }

  /// Form doğrula
  void validate() {
    errors.clear();

    if (type == null) {
      errors['type'] = 'İşlem türü seçilmelidir';
    }

    if (category == null) {
      errors['category'] = 'İşlem kategorisi seçilmelidir';
    }

    if (direction == null) {
      errors['direction'] = 'İşlem yönü seçilmelidir';
    }

    if (amount == null || amount! <= 0) {
      errors['amount'] = 'Geçerli bir tutar girilmelidir';
    }

    if (transactionDate == null) {
      errors['transactionDate'] = 'İşlem tarihi seçilmelidir';
    }

    if (isDueDateRequired && dueDate == null) {
      errors['dueDate'] = 'Vade tarihi seçilmelidir';
    }

    if (isPaymentMethodRequired && paymentMethodId == null) {
      errors['paymentMethodId'] = 'Ödeme yöntemi seçilmelidir';
    }

    if (isPaymentSourceRequired && paymentSourceId == null) {
      errors['paymentSourceId'] = 'Ödeme kaynağı seçilmelidir';
    }

    if (isAccountRequired && accountId == null) {
      errors['accountId'] = 'Hesap seçilmelidir';
    }

    if (isTargetAccountRequired && targetAccountId == null) {
      errors['targetAccountId'] = 'Hedef hesap seçilmelidir';
    }

    if (isCustomerSelectionRequired && customerId == null) {
      errors['customerId'] = 'Müşteri seçilmelidir';
    }

    if (isSupplierSelectionRequired && supplierId == null) {
      errors['supplierId'] = 'Tedarikçi seçilmelidir';
    }
  }

  /// Hata mesajı getir
  String? getError(String field) {
    return errors[field];
  }

  /// Hata var mı?
  bool hasError(String field) {
    return errors.containsKey(field);
  }

  /// Hata temizle
  void clearError(String field) {
    errors.remove(field);
  }

  /// Tüm hataları temizle
  void clearAllErrors() {
    errors.clear();
  }

  /// Form özeti
  Map<String, dynamic> toSummary() {
    return {
      'type': type?.displayName,
      'category': category?.displayName,
      'direction': direction?.displayName,
      'amount': amount,
      'currency': currency,
      'transactionDate': transactionDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'description': description,
      'referenceNumber': referenceNumber,
      'customerId': customerId,
      'supplierId': supplierId,
      'revenueId': revenueId,
      'expenseId': expenseId,
      'accountId': accountId,
      'sourceAccountId': sourceAccountId,
      'targetAccountId': targetAccountId,
      'paymentMethodId': paymentMethodId,
      'paymentSourceId': paymentSourceId,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'attachments': attachments,
      'metadata': metadata,
      'errors': errors,
      'isValid': isValid,
      'isEmpty': isEmpty,
      'isFilled': isFilled,
    };
  }

  @override
  String toString() {
    return 'PaymentTransactionFormModel(type: $type, category: $category, direction: $direction, amount: $amount, currency: $currency, isValid: $isValid)';
  }
}
