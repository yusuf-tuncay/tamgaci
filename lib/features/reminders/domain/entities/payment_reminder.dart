// ========== PAYMENT REMINDER ENTITY ==========
// lib/features/reminders/domain/entities/payment_reminder.dart

/// Ödeme hatırlatma türü
enum ReminderType {
  payment('Ödeme Hatırlatması'),
  overdue('Vadesi Geçmiş Hatırlatması'),
  followUp('Takip Hatırlatması'),
  collection('Tahsilat Hatırlatması');

  const ReminderType(this.displayName);
  final String displayName;
}

/// Hatırlatma durumu
enum ReminderStatus {
  pending('Beklemede'),
  sent('Gönderildi'),
  delivered('Teslim Edildi'),
  read('Okundu'),
  responded('Yanıtlandı'),
  cancelled('İptal Edildi');

  const ReminderStatus(this.displayName);
  final String displayName;
}

/// Hatırlatma kanalı
enum ReminderChannel {
  email('E-posta'),
  sms('SMS'),
  phone('Telefon'),
  letter('Mektup'),
  inApp('Uygulama İçi');

  const ReminderChannel(this.displayName);
  final String displayName;
}

/// Ödeme hatırlatma entity'si
class PaymentReminder {
  final String id;
  final String reminderNumber;
  final ReminderType type;
  final ReminderStatus status;
  final ReminderChannel channel;
  final String? customerId; // Müşteri ID'si
  final String? customerName; // Müşteri adı
  final String? customerEmail; // Müşteri e-posta
  final String? customerPhone; // Müşteri telefon
  final String? supplierId; // Tedarikçi ID'si
  final String? supplierName; // Tedarikçi adı
  final String? supplierEmail; // Tedarikçi e-posta
  final String? supplierPhone; // Tedarikçi telefon
  final String? relatedDocumentId; // İlgili belge ID'si
  final String? relatedDocumentType; // İlgili belge türü
  final String? relatedDocumentNumber; // İlgili belge numarası
  final double amount;
  final String currency;
  final DateTime dueDate;
  final DateTime? sentDate;
  final DateTime? deliveredDate;
  final DateTime? readDate;
  final DateTime? respondedDate;
  final String subject;
  final String message;
  final String? response;
  final String? notes;
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const PaymentReminder({
    required this.id,
    required this.reminderNumber,
    required this.type,
    required this.status,
    required this.channel,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.supplierId,
    this.supplierName,
    this.supplierEmail,
    this.supplierPhone,
    this.relatedDocumentId,
    this.relatedDocumentType,
    this.relatedDocumentNumber,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.sentDate,
    this.deliveredDate,
    this.readDate,
    this.respondedDate,
    required this.subject,
    required this.message,
    this.response,
    this.notes,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  PaymentReminder copyWith({
    String? id,
    String? reminderNumber,
    ReminderType? type,
    ReminderStatus? status,
    ReminderChannel? channel,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? supplierId,
    String? supplierName,
    String? supplierEmail,
    String? supplierPhone,
    String? relatedDocumentId,
    String? relatedDocumentType,
    String? relatedDocumentNumber,
    double? amount,
    String? currency,
    DateTime? dueDate,
    DateTime? sentDate,
    DateTime? deliveredDate,
    DateTime? readDate,
    DateTime? respondedDate,
    String? subject,
    String? message,
    String? response,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PaymentReminder(
      id: id ?? this.id,
      reminderNumber: reminderNumber ?? this.reminderNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      channel: channel ?? this.channel,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierEmail: supplierEmail ?? this.supplierEmail,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      relatedDocumentNumber:
          relatedDocumentNumber ?? this.relatedDocumentNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      sentDate: sentDate ?? this.sentDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      readDate: readDate ?? this.readDate,
      respondedDate: respondedDate ?? this.respondedDate,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      response: response ?? this.response,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan PaymentReminder oluştur
  factory PaymentReminder.fromJson(Map<String, dynamic> json) {
    return PaymentReminder(
      id: json['id'] as String,
      reminderNumber: json['reminderNumber'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.payment,
      ),
      status: ReminderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReminderStatus.pending,
      ),
      channel: ReminderChannel.values.firstWhere(
        (e) => e.name == json['channel'],
        orElse: () => ReminderChannel.email,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierEmail: json['supplierEmail'] as String?,
      supplierPhone: json['supplierPhone'] as String?,
      relatedDocumentId: json['relatedDocumentId'] as String?,
      relatedDocumentType: json['relatedDocumentType'] as String?,
      relatedDocumentNumber: json['relatedDocumentNumber'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      sentDate: json['sentDate'] != null
          ? DateTime.parse(json['sentDate'] as String)
          : null,
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'] as String)
          : null,
      readDate: json['readDate'] != null
          ? DateTime.parse(json['readDate'] as String)
          : null,
      respondedDate: json['respondedDate'] != null
          ? DateTime.parse(json['respondedDate'] as String)
          : null,
      subject: json['subject'] as String,
      message: json['message'] as String,
      response: json['response'] as String?,
      notes: json['notes'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// PaymentReminder'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderNumber': reminderNumber,
      'type': type.name,
      'status': status.name,
      'channel': channel.name,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierEmail': supplierEmail,
      'supplierPhone': supplierPhone,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'relatedDocumentNumber': relatedDocumentNumber,
      'amount': amount,
      'currency': currency,
      'dueDate': dueDate.toIso8601String(),
      'sentDate': sentDate?.toIso8601String(),
      'deliveredDate': deliveredDate?.toIso8601String(),
      'readDate': readDate?.toIso8601String(),
      'respondedDate': respondedDate?.toIso8601String(),
      'subject': subject,
      'message': message,
      'response': response,
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Beklemede mi?
  bool get isPending => status == ReminderStatus.pending;

  /// Gönderildi mi?
  bool get isSent => status == ReminderStatus.sent;

  /// Teslim edildi mi?
  bool get isDelivered => status == ReminderStatus.delivered;

  /// Okundu mu?
  bool get isRead => status == ReminderStatus.read;

  /// Yanıtlandı mı?
  bool get isResponded => status == ReminderStatus.responded;

  /// İptal edildi mi?
  bool get isCancelled => status == ReminderStatus.cancelled;

  /// Müşteri hatırlatması mı?
  bool get isCustomerReminder => customerId != null;

  /// Tedarikçi hatırlatması mı?
  bool get isSupplierReminder => supplierId != null;

  /// E-posta kanalı mı?
  bool get isEmailChannel => channel == ReminderChannel.email;

  /// SMS kanalı mı?
  bool get isSmsChannel => channel == ReminderChannel.sms;

  /// Telefon kanalı mı?
  bool get isPhoneChannel => channel == ReminderChannel.phone;

  /// Mektup kanalı mı?
  bool get isLetterChannel => channel == ReminderChannel.letter;

  /// Uygulama içi kanal mı?
  bool get isInAppChannel => channel == ReminderChannel.inApp;

  /// Müşteri adı var mı?
  bool get hasCustomerName => customerName != null && customerName!.isNotEmpty;

  /// Tedarikçi adı var mı?
  bool get hasSupplierName => supplierName != null && supplierName!.isNotEmpty;

  /// Müşteri e-posta var mı?
  bool get hasCustomerEmail =>
      customerEmail != null && customerEmail!.isNotEmpty;

  /// Tedarikçi e-posta var mı?
  bool get hasSupplierEmail =>
      supplierEmail != null && supplierEmail!.isNotEmpty;

  /// Müşteri telefon var mı?
  bool get hasCustomerPhone =>
      customerPhone != null && customerPhone!.isNotEmpty;

  /// Tedarikçi telefon var mı?
  bool get hasSupplierPhone =>
      supplierPhone != null && supplierPhone!.isNotEmpty;

  /// İlgili belge var mı?
  bool get hasRelatedDocument {
    return relatedDocumentId != null &&
        relatedDocumentId!.isNotEmpty &&
        relatedDocumentType != null &&
        relatedDocumentType!.isNotEmpty;
  }

  /// Yanıt var mı?
  bool get hasResponse => response != null && response!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) &&
        status != ReminderStatus.responded &&
        status != ReminderStatus.cancelled;
  }

  /// Vadesi yaklaşıyor mu? (3 gün)
  bool get isDueSoon {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 3 &&
        daysUntilDue > 0 &&
        status == ReminderStatus.pending;
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

  /// Gönderilebilir mi?
  bool get canBeSent {
    return status == ReminderStatus.pending;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return status == ReminderStatus.pending || status == ReminderStatus.sent;
  }

  /// Yanıtlanabilir mi?
  bool get canBeResponded {
    return status == ReminderStatus.delivered || status == ReminderStatus.read;
  }

  /// Gönderim süresi (gün)
  int? get deliveryTimeInDays {
    if (sentDate == null || deliveredDate == null) return null;
    return deliveredDate!.difference(sentDate!).inDays;
  }

  /// Okuma süresi (gün)
  int? get readTimeInDays {
    if (deliveredDate == null || readDate == null) return null;
    return readDate!.difference(deliveredDate!).inDays;
  }

  /// Yanıt süresi (gün)
  int? get responseTimeInDays {
    if (sentDate == null || respondedDate == null) return null;
    return respondedDate!.difference(sentDate!).inDays;
  }

  @override
  String toString() {
    return 'PaymentReminder(id: $id, reminderNumber: $reminderNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentReminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
