// ========== PROMISSORY NOTE ENTITY ==========
// lib/features/payment_collection/domain/entities/promissory_note.dart

import 'package:equatable/equatable.dart';
import 'payment_enums.dart';

/// Senet entity'si
class PromissoryNote extends Equatable {
  /// Benzersiz ID
  final String id;

  /// Senet numarası
  final String noteNumber;

  /// Senet tutarı
  final double amount;

  /// Para birimi
  final String currency;

  /// Senet tarihi
  final DateTime noteDate;

  /// Vade tarihi
  final DateTime dueDate;

  /// Faiz oranı (%)
  final double? interestRate;

  /// Faiz tutarı
  final double? interestAmount;

  /// Toplam tutar (ana para + faiz)
  final double totalAmount;

  /// Senet durumu
  final PromissoryNoteStatus status;

  /// Ödeme tarihi
  final DateTime? paymentDate;

  /// Red tarihi
  final DateTime? rejectionDate;

  /// Red sebebi
  final String? rejectionReason;

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

  const PromissoryNote({
    required this.id,
    required this.noteNumber,
    required this.amount,
    required this.currency,
    required this.noteDate,
    required this.dueDate,
    this.interestRate,
    this.interestAmount,
    required this.totalAmount,
    required this.status,
    this.paymentDate,
    this.rejectionDate,
    this.rejectionReason,
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
  PromissoryNote copyWith({
    String? id,
    String? noteNumber,
    double? amount,
    String? currency,
    DateTime? noteDate,
    DateTime? dueDate,
    double? interestRate,
    double? interestAmount,
    double? totalAmount,
    PromissoryNoteStatus? status,
    DateTime? paymentDate,
    DateTime? rejectionDate,
    String? rejectionReason,
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
    return PromissoryNote(
      id: id ?? this.id,
      noteNumber: noteNumber ?? this.noteNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      noteDate: noteDate ?? this.noteDate,
      dueDate: dueDate ?? this.dueDate,
      interestRate: interestRate ?? this.interestRate,
      interestAmount: interestAmount ?? this.interestAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      rejectionDate: rejectionDate ?? this.rejectionDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
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

  /// JSON'dan PromissoryNote oluştur
  factory PromissoryNote.fromJson(Map<String, dynamic> json) {
    return PromissoryNote(
      id: json['id'] as String,
      noteNumber: json['noteNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      noteDate: DateTime.parse(json['noteDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      interestAmount: (json['interestAmount'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: PromissoryNoteStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PromissoryNoteStatus.pending,
      ),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
      rejectionDate: json['rejectionDate'] != null
          ? DateTime.parse(json['rejectionDate'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
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

  /// PromissoryNote'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteNumber': noteNumber,
      'amount': amount,
      'currency': currency,
      'noteDate': noteDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'interestRate': interestRate,
      'interestAmount': interestAmount,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentDate': paymentDate?.toIso8601String(),
      'rejectionDate': rejectionDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
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

  /// Formatlanmış toplam tutar
  String get formattedTotalAmount {
    return '${totalAmount.toStringAsFixed(2)} $currency';
  }

  /// Formatlanmış faiz tutarı
  String get formattedInterestAmount {
    if (interestAmount == null) return '0.00 $currency';
    return '${interestAmount!.toStringAsFixed(2)} $currency';
  }

  /// Formatlanmış faiz oranı
  String get formattedInterestRate {
    if (interestRate == null) return '0.00%';
    return '${interestRate!.toStringAsFixed(2)}%';
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

  /// Senet ödendi mi?
  bool get isPaid {
    return status == PromissoryNoteStatus.paid;
  }

  /// Senet reddedildi mi?
  bool get isRejected {
    return status == PromissoryNoteStatus.rejected;
  }

  /// Senet iptal edildi mi?
  bool get isCancelled {
    return status == PromissoryNoteStatus.cancelled;
  }

  /// Senet vadesi geçti mi?
  bool get isOverdueStatus {
    return status == PromissoryNoteStatus.overdue;
  }

  /// Senet beklemede mi?
  bool get isPending {
    return status == PromissoryNoteStatus.pending;
  }

  /// Senet kabul edildi mi?
  bool get isAccepted {
    return status == PromissoryNoteStatus.accepted;
  }

  /// Müşteri senedi mi?
  bool get isCustomerNote {
    return customerId != null;
  }

  /// Tedarikçi senedi mi?
  bool get isSupplierNote {
    return supplierId != null;
  }

  /// Formatlanmış vade tarihi
  String get formattedDueDate {
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }

  /// Formatlanmış senet tarihi
  String get formattedNoteDate {
    return '${noteDate.day}/${noteDate.month}/${noteDate.year}';
  }

  /// Vade durumu
  String get dueStatus {
    if (isOverdue) {
      return 'Vadesi Geçti';
    } else if (daysUntilDue <= 7) {
      return 'Vadesi Yaklaşıyor';
    } else {
      return 'Vadesi Normal';
    }
  }

  /// Vade durumu rengi
  String get dueStatusColor {
    if (isOverdue) {
      return 'red';
    } else if (daysUntilDue <= 7) {
      return 'orange';
    } else {
      return 'green';
    }
  }

  /// Faiz hesapla
  double calculateInterest() {
    if (interestRate == null) return 0.0;
    return amount * (interestRate! / 100);
  }

  /// Toplam tutar hesapla
  double calculateTotalAmount() {
    return amount + (interestAmount ?? 0.0);
  }

  /// Faiz var mı?
  bool get hasInterest {
    return interestRate != null && interestRate! > 0;
  }

  /// Faiz oranı yüzdesi
  double get interestRatePercentage {
    return interestRate ?? 0.0;
  }


  @override
  List<Object?> get props => [
        id,
        noteNumber,
        amount,
        currency,
        noteDate,
        dueDate,
        interestRate,
        interestAmount,
        totalAmount,
        status,
        paymentDate,
        rejectionDate,
        rejectionReason,
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
    return 'PromissoryNote(id: $id, number: $noteNumber, amount: $formattedAmount, status: $statusDisplayName)';
  }
}
