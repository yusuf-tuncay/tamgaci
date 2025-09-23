// ========== NOTIFICATION ENTITY ==========
// lib/features/workflow/domain/entities/notification.dart

/// Bildirim türü
enum NotificationType {
  task('Görev Bildirimi'),
  approval('Onay Bildirimi'),
  reminder('Hatırlatma Bildirimi'),
  alert('Uyarı Bildirimi'),
  info('Bilgi Bildirimi'),
  warning('Uyarı Bildirimi'),
  error('Hata Bildirimi'),
  success('Başarı Bildirimi'),
  system('Sistem Bildirimi'),
  custom('Özel Bildirim');

  const NotificationType(this.displayName);
  final String displayName;
}

/// Bildirim durumu
enum NotificationStatus {
  unread('Okunmadı'),
  read('Okundu'),
  archived('Arşivlendi'),
  deleted('Silindi');

  const NotificationStatus(this.displayName);
  final String displayName;
}

/// Bildirim önceliği
enum NotificationPriority {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  critical('Kritik');

  const NotificationPriority(this.displayName);
  final String displayName;
}

/// Bildirim entity'si
class Notification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationStatus status;
  final NotificationPriority priority;
  final String? recipientId; // Alıcı kullanıcı ID'si
  final String? recipientName; // Alıcı kullanıcı adı
  final String? senderId; // Gönderen kullanıcı ID'si
  final String? senderName; // Gönderen kullanıcı adı
  final String? relatedDocumentId; // İlgili belge ID'si
  final String? relatedDocumentType; // İlgili belge türü
  final String? relatedDocumentNumber; // İlgili belge numarası
  final String? actionUrl; // Aksiyon URL'si
  final String? actionText; // Aksiyon metni
  final String? category; // Kategori
  final String? tags; // Etiketler
  final DateTime? scheduledDate; // Zamanlanmış tarih
  final DateTime? sentDate; // Gönderim tarihi
  final DateTime? readDate; // Okunma tarihi
  final DateTime? archivedDate; // Arşivlenme tarihi
  final DateTime? deletedDate; // Silinme tarihi
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.priority,
    this.recipientId,
    this.recipientName,
    this.senderId,
    this.senderName,
    this.relatedDocumentId,
    this.relatedDocumentType,
    this.relatedDocumentNumber,
    this.actionUrl,
    this.actionText,
    this.category,
    this.tags,
    this.scheduledDate,
    this.sentDate,
    this.readDate,
    this.archivedDate,
    this.deletedDate,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  Notification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationStatus? status,
    NotificationPriority? priority,
    String? recipientId,
    String? recipientName,
    String? senderId,
    String? senderName,
    String? relatedDocumentId,
    String? relatedDocumentType,
    String? relatedDocumentNumber,
    String? actionUrl,
    String? actionText,
    String? category,
    String? tags,
    DateTime? scheduledDate,
    DateTime? sentDate,
    DateTime? readDate,
    DateTime? archivedDate,
    DateTime? deletedDate,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      relatedDocumentNumber:
          relatedDocumentNumber ?? this.relatedDocumentNumber,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      sentDate: sentDate ?? this.sentDate,
      readDate: readDate ?? this.readDate,
      archivedDate: archivedDate ?? this.archivedDate,
      deletedDate: deletedDate ?? this.deletedDate,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Notification oluştur
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.unread,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      recipientId: json['recipientId'] as String?,
      recipientName: json['recipientName'] as String?,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      relatedDocumentId: json['relatedDocumentId'] as String?,
      relatedDocumentType: json['relatedDocumentType'] as String?,
      relatedDocumentNumber: json['relatedDocumentNumber'] as String?,
      actionUrl: json['actionUrl'] as String?,
      actionText: json['actionText'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      sentDate: json['sentDate'] != null
          ? DateTime.parse(json['sentDate'] as String)
          : null,
      readDate: json['readDate'] != null
          ? DateTime.parse(json['readDate'] as String)
          : null,
      archivedDate: json['archivedDate'] != null
          ? DateTime.parse(json['archivedDate'] as String)
          : null,
      deletedDate: json['deletedDate'] != null
          ? DateTime.parse(json['deletedDate'] as String)
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Notification'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'senderId': senderId,
      'senderName': senderName,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'relatedDocumentNumber': relatedDocumentNumber,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'category': category,
      'tags': tags,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'sentDate': sentDate?.toIso8601String(),
      'readDate': readDate?.toIso8601String(),
      'archivedDate': archivedDate?.toIso8601String(),
      'deletedDate': deletedDate?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Okunmadı mı?
  bool get isUnread => status == NotificationStatus.unread;

  /// Okundu mu?
  bool get isRead => status == NotificationStatus.read;

  /// Arşivlendi mi?
  bool get isArchived => status == NotificationStatus.archived;

  /// Silindi mi?
  bool get isDeleted => status == NotificationStatus.deleted;

  /// Görev bildirimi mi?
  bool get isTaskNotification => type == NotificationType.task;

  /// Onay bildirimi mi?
  bool get isApprovalNotification => type == NotificationType.approval;

  /// Hatırlatma bildirimi mi?
  bool get isReminderNotification => type == NotificationType.reminder;

  /// Uyarı bildirimi mi?
  bool get isAlertNotification => type == NotificationType.alert;

  /// Bilgi bildirimi mi?
  bool get isInfoNotification => type == NotificationType.info;

  /// Uyarı bildirimi mi?
  bool get isWarningNotification => type == NotificationType.warning;

  /// Hata bildirimi mi?
  bool get isErrorNotification => type == NotificationType.error;

  /// Başarı bildirimi mi?
  bool get isSuccessNotification => type == NotificationType.success;

  /// Sistem bildirimi mi?
  bool get isSystemNotification => type == NotificationType.system;

  /// Özel bildirim mi?
  bool get isCustomNotification => type == NotificationType.custom;

  /// Düşük öncelik mi?
  bool get isLowPriority => priority == NotificationPriority.low;

  /// Orta öncelik mi?
  bool get isMediumPriority => priority == NotificationPriority.medium;

  /// Yüksek öncelik mi?
  bool get isHighPriority => priority == NotificationPriority.high;

  /// Kritik öncelik mi?
  bool get isCriticalPriority => priority == NotificationPriority.critical;

  /// Alıcı kullanıcı ID'si var mı?
  bool get hasRecipientId => recipientId != null && recipientId!.isNotEmpty;

  /// Alıcı kullanıcı adı var mı?
  bool get hasRecipientName =>
      recipientName != null && recipientName!.isNotEmpty;

  /// Gönderen kullanıcı ID'si var mı?
  bool get hasSenderId => senderId != null && senderId!.isNotEmpty;

  /// Gönderen kullanıcı adı var mı?
  bool get hasSenderName => senderName != null && senderName!.isNotEmpty;

  /// İlgili belge ID'si var mı?
  bool get hasRelatedDocumentId =>
      relatedDocumentId != null && relatedDocumentId!.isNotEmpty;

  /// İlgili belge türü var mı?
  bool get hasRelatedDocumentType =>
      relatedDocumentType != null && relatedDocumentType!.isNotEmpty;

  /// İlgili belge numarası var mı?
  bool get hasRelatedDocumentNumber =>
      relatedDocumentNumber != null && relatedDocumentNumber!.isNotEmpty;

  /// Aksiyon URL'si var mı?
  bool get hasActionUrl => actionUrl != null && actionUrl!.isNotEmpty;

  /// Aksiyon metni var mı?
  bool get hasActionText => actionText != null && actionText!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Zamanlanmış tarih var mı?
  bool get hasScheduledDate => scheduledDate != null;

  /// Gönderim tarihi var mı?
  bool get hasSentDate => sentDate != null;

  /// Okunma tarihi var mı?
  bool get hasReadDate => readDate != null;

  /// Arşivlenme tarihi var mı?
  bool get hasArchivedDate => archivedDate != null;

  /// Silinme tarihi var mı?
  bool get hasDeletedDate => deletedDate != null;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Zamanlanmış mı?
  bool get isScheduled =>
      hasScheduledDate && scheduledDate!.isAfter(DateTime.now());

  /// Gönderildi mi?
  bool get isSent => hasSentDate;

  /// Okunabilir mi?
  bool get canBeRead => isUnread;

  /// Arşivlenebilir mi?
  bool get canBeArchived => isRead && !isArchived;

  /// Silinebilir mi?
  bool get canBeDeleted => !isDeleted;

  /// Gönderilebilir mi?
  bool get canBeSent {
    return !isSent &&
        hasRecipientId &&
        (!hasScheduledDate || scheduledDate!.isBefore(DateTime.now()));
  }

  /// Zamanlanabilir mi?
  bool get canBeScheduled {
    return !isSent &&
        hasRecipientId &&
        hasScheduledDate &&
        scheduledDate!.isAfter(DateTime.now());
  }

  /// Gönderim süresi (gün)
  int? get sendingTimeInDays {
    if (sentDate == null) return null;
    return sentDate!.difference(createdAt).inDays;
  }

  /// Okunma süresi (gün)
  int? get readingTimeInDays {
    if (readDate == null || sentDate == null) return null;
    return readDate!.difference(sentDate!).inDays;
  }

  /// Arşivlenme süresi (gün)
  int? get archivingTimeInDays {
    if (archivedDate == null || readDate == null) return null;
    return archivedDate!.difference(readDate!).inDays;
  }

  /// Silinme süresi (gün)
  int? get deletionTimeInDays {
    if (deletedDate == null) return null;
    return deletedDate!.difference(createdAt).inDays;
  }

  /// Kalan süre (gün)
  int? get remainingDays {
    if (scheduledDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(scheduledDate!)) return 0;
    return scheduledDate!.difference(now).inDays;
  }

  /// Gecikme süresi (gün)
  int? get overdueDays {
    if (scheduledDate == null) return null;
    final now = DateTime.now();
    if (now.isBefore(scheduledDate!)) return 0;
    return now.difference(scheduledDate!).inDays;
  }

  /// Gecikmiş mi?
  bool get isOverdue {
    if (scheduledDate == null) return false;
    return DateTime.now().isAfter(scheduledDate!) && !isSent;
  }

  /// Acil mi?
  bool get isUrgent => isCriticalPriority || isOverdue;

  /// Önemli mi?
  bool get isImportant => isHighPriority || isCriticalPriority;

  /// Normal mi?
  bool get isNormal => isMediumPriority || isLowPriority;

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, type: $type, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
