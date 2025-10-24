// ========== CHECK TRANSACTION ENTITY ==========
// lib/features/payment_collection/domain/entities/check_transaction.dart

import 'package:equatable/equatable.dart';
import 'payment_enums.dart';

/// Çek işlemi entity'si
class CheckTransaction extends Equatable {
  /// Benzersiz ID
  final String id;

  /// Çek numarası
  final String checkNumber;

  /// Çek tutarı
  final double amount;

  /// Para birimi
  final String currency;

  /// Çek tarihi
  final DateTime checkDate;

  /// Vade tarihi
  final DateTime dueDate;

  /// Banka adı
  final String bankName;

  /// Şube adı
  final String branchName;

  /// Hesap numarası
  final String accountNumber;

  /// IBAN
  final String? iban;

  /// Çek durumu
  final CheckStatus status;

  /// Ödeme tarihi
  final DateTime? paymentDate;

  /// Karşılıksız tarihi
  final DateTime? bouncedDate;

  /// Karşılıksız sebebi
  final String? bounceReason;

  /// İlişkili müşteri ID'si
  final String? customerId;

  /// İlişkili tedarikçi ID'si
  final String? supplierId;

  /// Kaynak hesap ID'si
  final String? sourceAccountId;

  /// Hedef hesap ID'si
  final String? targetAccountId;

  /// Açıklama
  final String? description;

  /// Notlar
  final String? notes;

  /// Ek dosyalar
  final List<String> attachments;

  /// Metadata
  final Map<String, dynamic> metadata;

  /// Şirket ID'si
  final String companyId;

  /// Tenant ID'si
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

  const CheckTransaction({
    required this.id,
    required this.checkNumber,
    required this.amount,
    required this.currency,
    required this.checkDate,
    required this.dueDate,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    this.iban,
    required this.status,
    this.paymentDate,
    this.bouncedDate,
    this.bounceReason,
    this.customerId,
    this.supplierId,
    this.sourceAccountId,
    this.targetAccountId,
    this.description,
    this.notes,
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
  CheckTransaction copyWith({
    String? id,
    String? checkNumber,
    double? amount,
    String? currency,
    DateTime? checkDate,
    DateTime? dueDate,
    String? bankName,
    String? branchName,
    String? accountNumber,
    String? iban,
    CheckStatus? status,
    DateTime? paymentDate,
    DateTime? bouncedDate,
    String? bounceReason,
    String? customerId,
    String? supplierId,
    String? sourceAccountId,
    String? targetAccountId,
    String? description,
    String? notes,
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
    return CheckTransaction(
      id: id ?? this.id,
      checkNumber: checkNumber ?? this.checkNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      checkDate: checkDate ?? this.checkDate,
      dueDate: dueDate ?? this.dueDate,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      bouncedDate: bouncedDate ?? this.bouncedDate,
      bounceReason: bounceReason ?? this.bounceReason,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
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

  /// JSON'dan CheckTransaction oluştur
  factory CheckTransaction.fromJson(Map<String, dynamic> json) {
    return CheckTransaction(
      id: json['id'] as String,
      checkNumber: json['checkNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      checkDate: DateTime.parse(json['checkDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      bankName: json['bankName'] as String,
      branchName: json['branchName'] as String,
      accountNumber: json['accountNumber'] as String,
      iban: json['iban'] as String?,
      status: CheckStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CheckStatus.pending,
      ),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
      bouncedDate: json['bouncedDate'] != null
          ? DateTime.parse(json['bouncedDate'] as String)
          : null,
      bounceReason: json['bounceReason'] as String?,
      customerId: json['customerId'] as String?,
      supplierId: json['supplierId'] as String?,
      sourceAccountId: json['sourceAccountId'] as String?,
      targetAccountId: json['targetAccountId'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
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

  /// CheckTransaction'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkNumber': checkNumber,
      'amount': amount,
      'currency': currency,
      'checkDate': checkDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'bankName': bankName,
      'branchName': branchName,
      'accountNumber': accountNumber,
      'iban': iban,
      'status': status.name,
      'paymentDate': paymentDate?.toIso8601String(),
      'bouncedDate': bouncedDate?.toIso8601String(),
      'bounceReason': bounceReason,
      'customerId': customerId,
      'supplierId': supplierId,
      'sourceAccountId': sourceAccountId,
      'targetAccountId': targetAccountId,
      'description': description,
      'notes': notes,
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

  /// Durum görünen adı
  String get statusDisplayName {
    return status.displayName;
  }

  /// Durum rengi
  String get statusColor {
    return status.color;
  }

  /// Vade geçmiş mi?
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate);
  }

  /// Vadeye kaç gün kaldı?
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Vadeye kaç gün kaldı? (pozitif/negatif)
  int get daysUntilDueSigned {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Çek ödendi mi?
  bool get isPaid {
    return status == CheckStatus.cleared;
  }

  /// Çek karşılıksız mı?
  bool get isBounced {
    return status == CheckStatus.bounced;
  }

  /// Çek iptal edildi mi?
  bool get isCancelled {
    return status == CheckStatus.cancelled;
  }

  /// Çek süresi doldu mu?
  bool get isExpired {
    return status == CheckStatus.expired;
  }

  /// Çek beklemede mi?
  bool get isPending {
    return status == CheckStatus.pending;
  }

  /// Çek yatırıldı mı?
  bool get isDeposited {
    return status == CheckStatus.deposited;
  }

  /// Müşteri çeki mi?
  bool get isCustomerCheck {
    return customerId != null;
  }

  /// Tedarikçi çeki mi?
  bool get isSupplierCheck {
    return supplierId != null;
  }

  /// Tam banka bilgisi
  String get fullBankInfo {
    return '$bankName - $branchName';
  }

  /// Kısa banka bilgisi
  String get shortBankInfo {
    return '$bankName - $accountNumber';
  }

  /// Formatlanmış vade tarihi
  String get formattedDueDate {
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }

  /// Formatlanmış çek tarihi
  String get formattedCheckDate {
    return '${checkDate.day}/${checkDate.month}/${checkDate.year}';
  }

  /// Vade durumu
  String get dueStatus {
    if (isOverdue) {
      return 'Vadesi Geçti';
    } else if (daysUntilDue <= 3) {
      return 'Vadesi Yaklaşıyor';
    } else {
      return 'Vadesi Normal';
    }
  }

  /// Vade durumu rengi
  String get dueStatusColor {
    if (isOverdue) {
      return 'red';
    } else if (daysUntilDue <= 3) {
      return 'orange';
    } else {
      return 'green';
    }
  }


  @override
  List<Object?> get props => [
        id,
        checkNumber,
        amount,
        currency,
        checkDate,
        dueDate,
        bankName,
        branchName,
        accountNumber,
        iban,
        status,
        paymentDate,
        bouncedDate,
        bounceReason,
        customerId,
        supplierId,
        sourceAccountId,
        targetAccountId,
        description,
        notes,
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
    return 'CheckTransaction(id: $id, number: $checkNumber, amount: $formattedAmount, status: $statusDisplayName)';
  }
}
