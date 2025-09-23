// ========== SCHEDULED JOB ENTITY ==========
// lib/features/workflow/domain/entities/scheduled_job.dart

/// Planlı iş türü
enum ScheduledJobType {
  report('Rapor Oluşturma'),
  backup('Yedekleme'),
  cleanup('Temizlik'),
  sync('Senkronizasyon'),
  reminder('Hatırlatma'),
  notification('Bildirim'),
  maintenance('Bakım'),
  custom('Özel İş');

  const ScheduledJobType(this.displayName);
  final String displayName;
}

/// Planlı iş durumu
enum ScheduledJobStatus {
  active('Aktif'),
  inactive('Pasif'),
  running('Çalışıyor'),
  completed('Tamamlandı'),
  failed('Başarısız'),
  cancelled('İptal Edildi'),
  paused('Duraklatıldı');

  const ScheduledJobStatus(this.displayName);
  final String displayName;
}

/// Planlı iş önceliği
enum ScheduledJobPriority {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  critical('Kritik');

  const ScheduledJobPriority(this.displayName);
  final String displayName;
}

/// Planlı iş entity'si
class ScheduledJob {
  final String id;
  final String jobName;
  final String? description;
  final ScheduledJobType type;
  final ScheduledJobStatus status;
  final ScheduledJobPriority priority;
  final String? category;
  final String? tags;
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? assignedTo; // Atanan kullanıcı ID'si
  final String? assignedToName; // Atanan kullanıcı adı
  final String? assignedToRole; // Atanan rol
  final String? assignedToDepartment; // Atanan departman
  final String? cronExpression; // Cron ifadesi
  final DateTime? nextRunDate; // Sonraki çalışma tarihi
  final DateTime? lastRunDate; // Son çalışma tarihi
  final DateTime? lastSuccessDate; // Son başarılı çalışma tarihi
  final DateTime? lastFailureDate; // Son başarısız çalışma tarihi
  final int? runCount; // Çalışma sayısı
  final int? successCount; // Başarılı çalışma sayısı
  final int? failureCount; // Başarısız çalışma sayısı
  final String? lastError; // Son hata mesajı
  final String? lastResult; // Son sonuç
  final double? estimatedDuration; // Tahmini süre (dakika)
  final double? actualDuration; // Gerçek süre (dakika)
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduledJob({
    required this.id,
    required this.jobName,
    this.description,
    required this.type,
    required this.status,
    required this.priority,
    this.category,
    this.tags,
    this.createdBy,
    this.createdByName,
    this.assignedTo,
    this.assignedToName,
    this.assignedToRole,
    this.assignedToDepartment,
    this.cronExpression,
    this.nextRunDate,
    this.lastRunDate,
    this.lastSuccessDate,
    this.lastFailureDate,
    this.runCount,
    this.successCount,
    this.failureCount,
    this.lastError,
    this.lastResult,
    this.estimatedDuration,
    this.actualDuration,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  ScheduledJob copyWith({
    String? id,
    String? jobName,
    String? description,
    ScheduledJobType? type,
    ScheduledJobStatus? status,
    ScheduledJobPriority? priority,
    String? category,
    String? tags,
    String? createdBy,
    String? createdByName,
    String? assignedTo,
    String? assignedToName,
    String? assignedToRole,
    String? assignedToDepartment,
    String? cronExpression,
    DateTime? nextRunDate,
    DateTime? lastRunDate,
    DateTime? lastSuccessDate,
    DateTime? lastFailureDate,
    int? runCount,
    int? successCount,
    int? failureCount,
    String? lastError,
    String? lastResult,
    double? estimatedDuration,
    double? actualDuration,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduledJob(
      id: id ?? this.id,
      jobName: jobName ?? this.jobName,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedToRole: assignedToRole ?? this.assignedToRole,
      assignedToDepartment: assignedToDepartment ?? this.assignedToDepartment,
      cronExpression: cronExpression ?? this.cronExpression,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      lastRunDate: lastRunDate ?? this.lastRunDate,
      lastSuccessDate: lastSuccessDate ?? this.lastSuccessDate,
      lastFailureDate: lastFailureDate ?? this.lastFailureDate,
      runCount: runCount ?? this.runCount,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      lastError: lastError ?? this.lastError,
      lastResult: lastResult ?? this.lastResult,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan ScheduledJob oluştur
  factory ScheduledJob.fromJson(Map<String, dynamic> json) {
    return ScheduledJob(
      id: json['id'] as String,
      jobName: json['jobName'] as String,
      description: json['description'] as String?,
      type: ScheduledJobType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScheduledJobType.report,
      ),
      status: ScheduledJobStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ScheduledJobStatus.active,
      ),
      priority: ScheduledJobPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ScheduledJobPriority.medium,
      ),
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      assignedToRole: json['assignedToRole'] as String?,
      assignedToDepartment: json['assignedToDepartment'] as String?,
      cronExpression: json['cronExpression'] as String?,
      nextRunDate: json['nextRunDate'] != null
          ? DateTime.parse(json['nextRunDate'] as String)
          : null,
      lastRunDate: json['lastRunDate'] != null
          ? DateTime.parse(json['lastRunDate'] as String)
          : null,
      lastSuccessDate: json['lastSuccessDate'] != null
          ? DateTime.parse(json['lastSuccessDate'] as String)
          : null,
      lastFailureDate: json['lastFailureDate'] != null
          ? DateTime.parse(json['lastFailureDate'] as String)
          : null,
      runCount: json['runCount'] as int?,
      successCount: json['successCount'] as int?,
      failureCount: json['failureCount'] as int?,
      lastError: json['lastError'] as String?,
      lastResult: json['lastResult'] as String?,
      estimatedDuration: json['estimatedDuration'] != null
          ? (json['estimatedDuration'] as num).toDouble()
          : null,
      actualDuration: json['actualDuration'] != null
          ? (json['actualDuration'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// ScheduledJob'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobName': jobName,
      'description': description,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'category': category,
      'tags': tags,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'assignedToRole': assignedToRole,
      'assignedToDepartment': assignedToDepartment,
      'cronExpression': cronExpression,
      'nextRunDate': nextRunDate?.toIso8601String(),
      'lastRunDate': lastRunDate?.toIso8601String(),
      'lastSuccessDate': lastSuccessDate?.toIso8601String(),
      'lastFailureDate': lastFailureDate?.toIso8601String(),
      'runCount': runCount,
      'successCount': successCount,
      'failureCount': failureCount,
      'lastError': lastError,
      'lastResult': lastResult,
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Aktif mi?
  bool get isActive => status == ScheduledJobStatus.active;

  /// Pasif mi?
  bool get isInactive => status == ScheduledJobStatus.inactive;

  /// Çalışıyor mu?
  bool get isRunning => status == ScheduledJobStatus.running;

  /// Tamamlandı mı?
  bool get isCompleted => status == ScheduledJobStatus.completed;

  /// Başarısız mı?
  bool get isFailed => status == ScheduledJobStatus.failed;

  /// İptal edildi mi?
  bool get isCancelled => status == ScheduledJobStatus.cancelled;

  /// Duraklatıldı mı?
  bool get isPaused => status == ScheduledJobStatus.paused;

  /// Rapor oluşturma işi mi?
  bool get isReportJob => type == ScheduledJobType.report;

  /// Yedekleme işi mi?
  bool get isBackupJob => type == ScheduledJobType.backup;

  /// Temizlik işi mi?
  bool get isCleanupJob => type == ScheduledJobType.cleanup;

  /// Senkronizasyon işi mi?
  bool get isSyncJob => type == ScheduledJobType.sync;

  /// Hatırlatma işi mi?
  bool get isReminderJob => type == ScheduledJobType.reminder;

  /// Bildirim işi mi?
  bool get isNotificationJob => type == ScheduledJobType.notification;

  /// Bakım işi mi?
  bool get isMaintenanceJob => type == ScheduledJobType.maintenance;

  /// Özel iş mi?
  bool get isCustomJob => type == ScheduledJobType.custom;

  /// Düşük öncelik mi?
  bool get isLowPriority => priority == ScheduledJobPriority.low;

  /// Orta öncelik mi?
  bool get isMediumPriority => priority == ScheduledJobPriority.medium;

  /// Yüksek öncelik mi?
  bool get isHighPriority => priority == ScheduledJobPriority.high;

  /// Kritik öncelik mi?
  bool get isCriticalPriority => priority == ScheduledJobPriority.critical;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Oluşturan kullanıcı var mı?
  bool get hasCreatedBy => createdBy != null && createdBy!.isNotEmpty;

  /// Oluşturan kullanıcı adı var mı?
  bool get hasCreatedByName =>
      createdByName != null && createdByName!.isNotEmpty;

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

  /// Cron ifadesi var mı?
  bool get hasCronExpression =>
      cronExpression != null && cronExpression!.isNotEmpty;

  /// Sonraki çalışma tarihi var mı?
  bool get hasNextRunDate => nextRunDate != null;

  /// Son çalışma tarihi var mı?
  bool get hasLastRunDate => lastRunDate != null;

  /// Son başarılı çalışma tarihi var mı?
  bool get hasLastSuccessDate => lastSuccessDate != null;

  /// Son başarısız çalışma tarihi var mı?
  bool get hasLastFailureDate => lastFailureDate != null;

  /// Çalışma sayısı var mı?
  bool get hasRunCount => runCount != null && runCount! > 0;

  /// Başarılı çalışma sayısı var mı?
  bool get hasSuccessCount => successCount != null && successCount! > 0;

  /// Başarısız çalışma sayısı var mı?
  bool get hasFailureCount => failureCount != null && failureCount! > 0;

  /// Son hata var mı?
  bool get hasLastError => lastError != null && lastError!.isNotEmpty;

  /// Son sonuç var mı?
  bool get hasLastResult => lastResult != null && lastResult!.isNotEmpty;

  /// Tahmini süre var mı?
  bool get hasEstimatedDuration =>
      estimatedDuration != null && estimatedDuration! > 0;

  /// Gerçek süre var mı?
  bool get hasActualDuration => actualDuration != null && actualDuration! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Başlatılabilir mi?
  bool get canBeStarted {
    return isActive &&
        hasCronExpression &&
        (!hasNextRunDate || nextRunDate!.isBefore(DateTime.now()));
  }

  /// Durdurulabilir mi?
  bool get canBeStopped {
    return isRunning;
  }

  /// Duraklatılabilir mi?
  bool get canBePaused {
    return isActive;
  }

  /// Devam ettirilebilir mi?
  bool get canBeResumed {
    return isPaused;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return isActive || isPaused;
  }

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return !isRunning;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return !isRunning;
  }

  /// Başarı oranı
  double? get successRate {
    if (runCount == null || runCount == 0) return null;
    if (successCount == null) return 0;
    return (successCount! / runCount!) * 100;
  }

  /// Başarısızlık oranı
  double? get failureRate {
    if (runCount == null || runCount == 0) return null;
    if (failureCount == null) return 0;
    return (failureCount! / runCount!) * 100;
  }

  /// Verimlilik yüzdesi
  double? get efficiencyPercentage {
    if (estimatedDuration == null || actualDuration == null) return null;
    if (actualDuration == 0) return 0;
    return (estimatedDuration! / actualDuration!) * 100;
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

  /// Sağlıklı mı?
  bool get isHealthy {
    if (successRate == null) return true;
    return successRate! >= 80;
  }

  /// Sağlıksız mı?
  bool get isUnhealthy {
    if (successRate == null) return false;
    return successRate! < 80;
  }

  /// Kalan süre (dakika)
  int? get remainingMinutes {
    if (nextRunDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(nextRunDate!)) return 0;
    return nextRunDate!.difference(now).inMinutes;
  }

  /// Gecikme süresi (dakika)
  int? get overdueMinutes {
    if (nextRunDate == null) return null;
    final now = DateTime.now();
    if (now.isBefore(nextRunDate!)) return 0;
    return now.difference(nextRunDate!).inMinutes;
  }

  /// Gecikmiş mi?
  bool get isOverdue {
    if (nextRunDate == null) return false;
    return DateTime.now().isAfter(nextRunDate!) && isActive;
  }

  /// Acil mi?
  bool get isUrgent => isCriticalPriority || isOverdue;

  /// Önemli mi?
  bool get isImportant => isHighPriority || isCriticalPriority;

  /// Normal mi?
  bool get isNormal => isMediumPriority || isLowPriority;

  @override
  String toString() {
    return 'ScheduledJob(id: $id, jobName: $jobName, type: $type, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduledJob && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
