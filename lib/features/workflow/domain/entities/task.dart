// ========== TASK ENTITY ==========
// lib/features/workflow/domain/entities/task.dart

/// Görev türü
enum TaskType {
  approval('Onay Görevi'),
  review('İnceleme Görevi'),
  dataEntry('Veri Girişi'),
  followUp('Takip Görevi'),
  reminder('Hatırlatma Görevi'),
  report('Rapor Görevi'),
  maintenance('Bakım Görevi'),
  custom('Özel Görev');

  const TaskType(this.displayName);
  final String displayName;
}

/// Görev durumu
enum TaskStatus {
  draft('Taslak'),
  assigned('Atandı'),
  inProgress('Devam Ediyor'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi'),
  overdue('Süresi Doldu'),
  onHold('Beklemede');

  const TaskStatus(this.displayName);
  final String displayName;
}

/// Görev önceliği
enum TaskPriority {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  critical('Kritik');

  const TaskPriority(this.displayName);
  final String displayName;
}

/// Görev entity'si
class Task {
  final String id;
  final String taskNumber;
  final TaskType type;
  final TaskStatus status;
  final TaskPriority priority;
  final String title;
  final String? description;
  final String? category;
  final String? tags;
  final String? assignedTo; // Atanan kullanıcı ID'si
  final String? assignedToName; // Atanan kullanıcı adı
  final String? assignedToRole; // Atanan rol
  final String? assignedToDepartment; // Atanan departman
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? relatedDocumentId; // İlgili belge ID'si
  final String? relatedDocumentType; // İlgili belge türü
  final String? relatedDocumentNumber; // İlgili belge numarası
  final double? estimatedHours; // Tahmini saat
  final double? actualHours; // Gerçek saat
  final DateTime? startDate; // Başlangıç tarihi
  final DateTime? dueDate; // Son tarih
  final DateTime? completedDate; // Tamamlanma tarihi
  final String? notes; // Notlar
  final String? comments; // Yorumlar
  final List<String> attachments; // Ek dosyalar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.taskNumber,
    required this.type,
    required this.status,
    required this.priority,
    required this.title,
    this.description,
    this.category,
    this.tags,
    this.assignedTo,
    this.assignedToName,
    this.assignedToRole,
    this.assignedToDepartment,
    this.createdBy,
    this.createdByName,
    this.relatedDocumentId,
    this.relatedDocumentType,
    this.relatedDocumentNumber,
    this.estimatedHours,
    this.actualHours,
    this.startDate,
    this.dueDate,
    this.completedDate,
    this.notes,
    this.comments,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  Task copyWith({
    String? id,
    String? taskNumber,
    TaskType? type,
    TaskStatus? status,
    TaskPriority? priority,
    String? title,
    String? description,
    String? category,
    String? tags,
    String? assignedTo,
    String? assignedToName,
    String? assignedToRole,
    String? assignedToDepartment,
    String? createdBy,
    String? createdByName,
    String? relatedDocumentId,
    String? relatedDocumentType,
    String? relatedDocumentNumber,
    double? estimatedHours,
    double? actualHours,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedDate,
    String? notes,
    String? comments,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      taskNumber: taskNumber ?? this.taskNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedToRole: assignedToRole ?? this.assignedToRole,
      assignedToDepartment: assignedToDepartment ?? this.assignedToDepartment,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      relatedDocumentNumber:
          relatedDocumentNumber ?? this.relatedDocumentNumber,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Task oluştur
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      taskNumber: json['taskNumber'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.approval,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.draft,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      assignedToRole: json['assignedToRole'] as String?,
      assignedToDepartment: json['assignedToDepartment'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      relatedDocumentId: json['relatedDocumentId'] as String?,
      relatedDocumentType: json['relatedDocumentType'] as String?,
      relatedDocumentNumber: json['relatedDocumentNumber'] as String?,
      estimatedHours: json['estimatedHours'] != null
          ? (json['estimatedHours'] as num).toDouble()
          : null,
      actualHours: json['actualHours'] != null
          ? (json['actualHours'] as num).toDouble()
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      notes: json['notes'] as String?,
      comments: json['comments'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Task'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskNumber': taskNumber,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'assignedToRole': assignedToRole,
      'assignedToDepartment': assignedToDepartment,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'relatedDocumentNumber': relatedDocumentNumber,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'notes': notes,
      'comments': comments,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Taslak mı?
  bool get isDraft => status == TaskStatus.draft;

  /// Atandı mı?
  bool get isAssigned => status == TaskStatus.assigned;

  /// Devam ediyor mu?
  bool get isInProgress => status == TaskStatus.inProgress;

  /// Tamamlandı mı?
  bool get isCompleted => status == TaskStatus.completed;

  /// İptal edildi mi?
  bool get isCancelled => status == TaskStatus.cancelled;

  /// Süresi doldu mu?
  bool get isOverdue => status == TaskStatus.overdue;

  /// Beklemede mi?
  bool get isOnHold => status == TaskStatus.onHold;

  /// Onay görevi mi?
  bool get isApprovalTask => type == TaskType.approval;

  /// İnceleme görevi mi?
  bool get isReviewTask => type == TaskType.review;

  /// Veri girişi görevi mi?
  bool get isDataEntryTask => type == TaskType.dataEntry;

  /// Takip görevi mi?
  bool get isFollowUpTask => type == TaskType.followUp;

  /// Hatırlatma görevi mi?
  bool get isReminderTask => type == TaskType.reminder;

  /// Rapor görevi mi?
  bool get isReportTask => type == TaskType.report;

  /// Bakım görevi mi?
  bool get isMaintenanceTask => type == TaskType.maintenance;

  /// Özel görev mi?
  bool get isCustomTask => type == TaskType.custom;

  /// Düşük öncelik mi?
  bool get isLowPriority => priority == TaskPriority.low;

  /// Orta öncelik mi?
  bool get isMediumPriority => priority == TaskPriority.medium;

  /// Yüksek öncelik mi?
  bool get isHighPriority => priority == TaskPriority.high;

  /// Kritik öncelik mi?
  bool get isCriticalPriority => priority == TaskPriority.critical;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Atanan kullanıcı var mı?
  bool get hasAssignedTo => assignedTo != null && assignedTo!.isNotEmpty;

  /// Atanan kullanıcı adı var mı?
  bool get hasAssignedToName =>
      assignedToName != null && assignedToName!.isNotEmpty;

  /// Atanan rol var mı?
  bool get hasAssignedToRole =>
      assignedToRole != null && assignedToRole!.isNotEmpty;

  /// Atanan departman var mı?
  bool get hasAssignedToDepartment =>
      assignedToDepartment != null && assignedToDepartment!.isNotEmpty;

  /// Oluşturan kullanıcı var mı?
  bool get hasCreatedBy => createdBy != null && createdBy!.isNotEmpty;

  /// Oluşturan kullanıcı adı var mı?
  bool get hasCreatedByName =>
      createdByName != null && createdByName!.isNotEmpty;

  /// İlgili belge ID'si var mı?
  bool get hasRelatedDocumentId =>
      relatedDocumentId != null && relatedDocumentId!.isNotEmpty;

  /// İlgili belge türü var mı?
  bool get hasRelatedDocumentType =>
      relatedDocumentType != null && relatedDocumentType!.isNotEmpty;

  /// İlgili belge numarası var mı?
  bool get hasRelatedDocumentNumber =>
      relatedDocumentNumber != null && relatedDocumentNumber!.isNotEmpty;

  /// Tahmini saat var mı?
  bool get hasEstimatedHours => estimatedHours != null && estimatedHours! > 0;

  /// Gerçek saat var mı?
  bool get hasActualHours => actualHours != null && actualHours! > 0;

  /// Başlangıç tarihi var mı?
  bool get hasStartDate => startDate != null;

  /// Son tarih var mı?
  bool get hasDueDate => dueDate != null;

  /// Tamamlanma tarihi var mı?
  bool get hasCompletedDate => completedDate != null;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Yorum var mı?
  bool get hasComments => comments != null && comments!.isNotEmpty;

  /// Ek dosya var mı?
  bool get hasAttachments => attachments.isNotEmpty;

  /// Süresi doldu mu?
  bool get isOverdueCheck {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && !isCompleted;
  }

  /// Başlatılabilir mi?
  bool get canBeStarted {
    return status == TaskStatus.assigned && hasAssignedTo;
  }

  /// Tamamlanabilir mi?
  bool get canBeCompleted {
    return isInProgress;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return !isCompleted && !isCancelled;
  }

  /// Beklemeye alınabilir mi?
  bool get canBePutOnHold {
    return isInProgress;
  }

  /// Beklemeden çıkarılabilir mi?
  bool get canBeResumed {
    return isOnHold;
  }

  /// Süre (gün)
  int? get durationInDays {
    if (startDate == null || completedDate == null) return null;
    return completedDate!.difference(startDate!).inDays;
  }

  /// Kalan süre (gün)
  int? get remainingDays {
    if (dueDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(dueDate!)) return 0;
    return dueDate!.difference(now).inDays;
  }

  /// Gecikme süresi (gün)
  int? get overdueDays {
    if (dueDate == null) return null;
    final now = DateTime.now();
    if (now.isBefore(dueDate!)) return 0;
    return now.difference(dueDate!).inDays;
  }

  /// Verimlilik yüzdesi
  double? get efficiencyPercentage {
    if (estimatedHours == null || actualHours == null) return null;
    if (actualHours == 0) return 0;
    return (estimatedHours! / actualHours!) * 100;
  }

  /// Verimli mi?
  bool? get isEfficient {
    final efficiency = efficiencyPercentage;
    if (efficiency == null) return null;
    return efficiency >= 80;
  }

  /// Verimsiz mi?
  bool? get isInefficient {
    final efficiency = efficiencyPercentage;
    if (efficiency == null) return null;
    return efficiency < 80;
  }

  @override
  String toString() {
    return 'Task(id: $id, taskNumber: $taskNumber, type: $type, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
