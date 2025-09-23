// ========== BACKUP CONFIG ENTITY ==========
// lib/features/operations/domain/entities/backup_config.dart

/// Yedekleme türü
enum BackupType {
  full('Tam Yedekleme'),
  incremental('Artımlı Yedekleme'),
  differential('Fark Yedekleme'),
  snapshot('Anlık Görüntü'),
  custom('Özel Yedekleme');

  const BackupType(this.displayName);
  final String displayName;
}

/// Yedekleme durumu
enum BackupStatus {
  active('Aktif'),
  inactive('Pasif'),
  suspended('Askıya Alındı'),
  deleted('Silindi');

  const BackupStatus(this.displayName);
  final String displayName;
}

/// Yedekleme konfigürasyonu entity'si
class BackupConfig {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final BackupType type;
  final BackupStatus status;
  final String? resourceType; // Kaynak türü
  final String? resourceId; // Kaynak ID'si
  final String? category; // Kategori
  final String? tags; // Etiketler
  final String? sourcePath; // Kaynak yol
  final String? destinationPath; // Hedef yol
  final String? schedule; // Zamanlama (cron)
  final bool? enableCompression; // Sıkıştırma etkin mi?
  final bool? enableEncryption; // Şifreleme etkin mi?
  final String? encryptionKey; // Şifreleme anahtarı
  final String? compressionAlgorithm; // Sıkıştırma algoritması
  final int? retentionDays; // Saklama süresi (gün)
  final int? maxBackups; // Maksimum yedek sayısı
  final bool? enableVerification; // Doğrulama etkin mi?
  final bool? enableNotification; // Bildirim etkin mi?
  final String? notificationEmail; // Bildirim e-postası
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? lastBackupDate; // Son yedekleme tarihi
  final DateTime? nextBackupDate; // Sonraki yedekleme tarihi
  final int? backupCount; // Yedekleme sayısı
  final double? lastBackupSize; // Son yedekleme boyutu (MB)
  final double? totalBackupSize; // Toplam yedekleme boyutu (MB)
  final String? lastBackupStatus; // Son yedekleme durumu
  final String? lastBackupError; // Son yedekleme hatası
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const BackupConfig({
    required this.id,
    required this.name,
    this.displayName,
    this.description,
    required this.type,
    required this.status,
    this.resourceType,
    this.resourceId,
    this.category,
    this.tags,
    this.sourcePath,
    this.destinationPath,
    this.schedule,
    this.enableCompression,
    this.enableEncryption,
    this.encryptionKey,
    this.compressionAlgorithm,
    this.retentionDays,
    this.maxBackups,
    this.enableVerification,
    this.enableNotification,
    this.notificationEmail,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.lastBackupDate,
    this.nextBackupDate,
    this.backupCount,
    this.lastBackupSize,
    this.totalBackupSize,
    this.lastBackupStatus,
    this.lastBackupError,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  BackupConfig copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    BackupType? type,
    BackupStatus? status,
    String? resourceType,
    String? resourceId,
    String? category,
    String? tags,
    String? sourcePath,
    String? destinationPath,
    String? schedule,
    bool? enableCompression,
    bool? enableEncryption,
    String? encryptionKey,
    String? compressionAlgorithm,
    int? retentionDays,
    int? maxBackups,
    bool? enableVerification,
    bool? enableNotification,
    String? notificationEmail,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? lastBackupDate,
    DateTime? nextBackupDate,
    int? backupCount,
    double? lastBackupSize,
    double? totalBackupSize,
    String? lastBackupStatus,
    String? lastBackupError,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BackupConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      sourcePath: sourcePath ?? this.sourcePath,
      destinationPath: destinationPath ?? this.destinationPath,
      schedule: schedule ?? this.schedule,
      enableCompression: enableCompression ?? this.enableCompression,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      compressionAlgorithm: compressionAlgorithm ?? this.compressionAlgorithm,
      retentionDays: retentionDays ?? this.retentionDays,
      maxBackups: maxBackups ?? this.maxBackups,
      enableVerification: enableVerification ?? this.enableVerification,
      enableNotification: enableNotification ?? this.enableNotification,
      notificationEmail: notificationEmail ?? this.notificationEmail,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      nextBackupDate: nextBackupDate ?? this.nextBackupDate,
      backupCount: backupCount ?? this.backupCount,
      lastBackupSize: lastBackupSize ?? this.lastBackupSize,
      totalBackupSize: totalBackupSize ?? this.totalBackupSize,
      lastBackupStatus: lastBackupStatus ?? this.lastBackupStatus,
      lastBackupError: lastBackupError ?? this.lastBackupError,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan BackupConfig oluştur
  factory BackupConfig.fromJson(Map<String, dynamic> json) {
    return BackupConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      type: BackupType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BackupType.full,
      ),
      status: BackupStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BackupStatus.active,
      ),
      resourceType: json['resourceType'] as String?,
      resourceId: json['resourceId'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      sourcePath: json['sourcePath'] as String?,
      destinationPath: json['destinationPath'] as String?,
      schedule: json['schedule'] as String?,
      enableCompression: json['enableCompression'] as bool?,
      enableEncryption: json['enableEncryption'] as bool?,
      encryptionKey: json['encryptionKey'] as String?,
      compressionAlgorithm: json['compressionAlgorithm'] as String?,
      retentionDays: json['retentionDays'] as int?,
      maxBackups: json['maxBackups'] as int?,
      enableVerification: json['enableVerification'] as bool?,
      enableNotification: json['enableNotification'] as bool?,
      notificationEmail: json['notificationEmail'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
      nextBackupDate: json['nextBackupDate'] != null
          ? DateTime.parse(json['nextBackupDate'] as String)
          : null,
      backupCount: json['backupCount'] as int?,
      lastBackupSize: json['lastBackupSize'] != null
          ? (json['lastBackupSize'] as num).toDouble()
          : null,
      totalBackupSize: json['totalBackupSize'] != null
          ? (json['totalBackupSize'] as num).toDouble()
          : null,
      lastBackupStatus: json['lastBackupStatus'] as String?,
      lastBackupError: json['lastBackupError'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// BackupConfig'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'type': type.name,
      'status': status.name,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'category': category,
      'tags': tags,
      'sourcePath': sourcePath,
      'destinationPath': destinationPath,
      'schedule': schedule,
      'enableCompression': enableCompression,
      'enableEncryption': enableEncryption,
      'encryptionKey': encryptionKey,
      'compressionAlgorithm': compressionAlgorithm,
      'retentionDays': retentionDays,
      'maxBackups': maxBackups,
      'enableVerification': enableVerification,
      'enableNotification': enableNotification,
      'notificationEmail': notificationEmail,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'nextBackupDate': nextBackupDate?.toIso8601String(),
      'backupCount': backupCount,
      'lastBackupSize': lastBackupSize,
      'totalBackupSize': totalBackupSize,
      'lastBackupStatus': lastBackupStatus,
      'lastBackupError': lastBackupError,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Tam yedekleme mi?
  bool get isFullBackup => type == BackupType.full;

  /// Artımlı yedekleme mi?
  bool get isIncrementalBackup => type == BackupType.incremental;

  /// Fark yedekleme mi?
  bool get isDifferentialBackup => type == BackupType.differential;

  /// Anlık görüntü mü?
  bool get isSnapshotBackup => type == BackupType.snapshot;

  /// Özel yedekleme mi?
  bool get isCustomBackup => type == BackupType.custom;

  /// Aktif mi?
  bool get isActive => status == BackupStatus.active;

  /// Pasif mi?
  bool get isInactive => status == BackupStatus.inactive;

  /// Askıya alındı mı?
  bool get isSuspended => status == BackupStatus.suspended;

  /// Silindi mi?
  bool get isDeleted => status == BackupStatus.deleted;

  /// Görünen ad var mı?
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Kaynak türü var mı?
  bool get hasResourceType => resourceType != null && resourceType!.isNotEmpty;

  /// Kaynak ID'si var mı?
  bool get hasResourceId => resourceId != null && resourceId!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Kaynak yol var mı?
  bool get hasSourcePath => sourcePath != null && sourcePath!.isNotEmpty;

  /// Hedef yol var mı?
  bool get hasDestinationPath =>
      destinationPath != null && destinationPath!.isNotEmpty;

  /// Zamanlama var mı?
  bool get hasSchedule => schedule != null && schedule!.isNotEmpty;

  /// Sıkıştırma etkin mi?
  bool get isCompressionEnabled => enableCompression == true;

  /// Şifreleme etkin mi?
  bool get isEncryptionEnabled => enableEncryption == true;

  /// Şifreleme anahtarı var mı?
  bool get hasEncryptionKey =>
      encryptionKey != null && encryptionKey!.isNotEmpty;

  /// Sıkıştırma algoritması var mı?
  bool get hasCompressionAlgorithm =>
      compressionAlgorithm != null && compressionAlgorithm!.isNotEmpty;

  /// Saklama süresi var mı?
  bool get hasRetentionDays => retentionDays != null && retentionDays! > 0;

  /// Maksimum yedek sayısı var mı?
  bool get hasMaxBackups => maxBackups != null && maxBackups! > 0;

  /// Doğrulama etkin mi?
  bool get isVerificationEnabled => enableVerification == true;

  /// Bildirim etkin mi?
  bool get isNotificationEnabled => enableNotification == true;

  /// Bildirim e-postası var mı?
  bool get hasNotificationEmail =>
      notificationEmail != null && notificationEmail!.isNotEmpty;

  /// Oluşturan kullanıcı var mı?
  bool get hasCreatedBy => createdBy != null && createdBy!.isNotEmpty;

  /// Oluşturan kullanıcı adı var mı?
  bool get hasCreatedByName =>
      createdByName != null && createdByName!.isNotEmpty;

  /// Güncelleyen kullanıcı var mı?
  bool get hasUpdatedBy => updatedBy != null && updatedBy!.isNotEmpty;

  /// Güncelleyen kullanıcı adı var mı?
  bool get hasUpdatedByName =>
      updatedByName != null && updatedByName!.isNotEmpty;

  /// Son yedekleme tarihi var mı?
  bool get hasLastBackupDate => lastBackupDate != null;

  /// Sonraki yedekleme tarihi var mı?
  bool get hasNextBackupDate => nextBackupDate != null;

  /// Yedekleme sayısı var mı?
  bool get hasBackupCount => backupCount != null && backupCount! > 0;

  /// Son yedekleme boyutu var mı?
  bool get hasLastBackupSize => lastBackupSize != null && lastBackupSize! > 0;

  /// Toplam yedekleme boyutu var mı?
  bool get hasTotalBackupSize =>
      totalBackupSize != null && totalBackupSize! > 0;

  /// Son yedekleme durumu var mı?
  bool get hasLastBackupStatus =>
      lastBackupStatus != null && lastBackupStatus!.isNotEmpty;

  /// Son yedekleme hatası var mı?
  bool get hasLastBackupError =>
      lastBackupError != null && lastBackupError!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return isActive && !isDeleted;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isActive && (backupCount == null || backupCount == 0);
  }

  /// Askıya alınabilir mi?
  bool get canBeSuspended {
    return isActive;
  }

  /// Aktifleştirilebilir mi?
  bool get canBeActivated {
    return isInactive || isSuspended;
  }

  /// Çalıştırılabilir mi?
  bool get canBeExecuted {
    return isActive &&
        hasSourcePath &&
        hasDestinationPath &&
        (!hasNextBackupDate || nextBackupDate!.isBefore(DateTime.now()));
  }

  /// Güvenli mi?
  bool get isSecure {
    return isActive &&
        (isEncryptionEnabled || isCompressionEnabled) &&
        hasEncryptionKey;
  }

  /// Yedekleme sayısı sıfır mı?
  bool get isZeroBackupCount => backupCount == null || backupCount == 0;

  /// Yedekleme sayısı yüksek mi? (100'den fazla)
  bool get isHighBackupCount => backupCount != null && backupCount! > 100;

  /// Yedekleme sayısı düşük mi? (5'ten az)
  bool get isLowBackupCount => backupCount != null && backupCount! < 5;

  /// Yedekleme sayısı orta mı? (5-100 arası)
  bool get isMediumBackupCount =>
      backupCount != null && backupCount! >= 5 && backupCount! <= 100;

  /// Yedekleme sayısı kategorisi
  String get backupCountCategory {
    if (isHighBackupCount) return 'Yüksek';
    if (isLowBackupCount) return 'Düşük';
    return 'Orta';
  }

  /// Son yedekleme süresi (gün)
  int? get lastBackupDays {
    if (lastBackupDate == null) return null;
    return DateTime.now().difference(lastBackupDate!).inDays;
  }

  /// Son yedekleme süresi uzun mu? (30 günden fazla)
  bool get isLastBackupLongAgo {
    final days = lastBackupDays;
    return days != null && days > 30;
  }

  /// Son yedekleme süresi kısa mı? (7 günden az)
  bool get isLastBackupRecently {
    final days = lastBackupDays;
    return days != null && days < 7;
  }

  /// Son yedekleme süresi orta mı? (7-30 gün arası)
  bool get isLastBackupMedium {
    final days = lastBackupDays;
    return days != null && days >= 7 && days <= 30;
  }

  /// Son yedekleme süresi kategorisi
  String get lastBackupCategory {
    if (isLastBackupLongAgo) return 'Uzun';
    if (isLastBackupRecently) return 'Kısa';
    return 'Orta';
  }

  /// Sonraki yedekleme süresi (gün)
  int? get nextBackupDays {
    if (nextBackupDate == null) return null;
    return nextBackupDate!.difference(DateTime.now()).inDays;
  }

  /// Sonraki yedekleme yakın mı? (1 günden az)
  bool get isNextBackupSoon {
    final days = nextBackupDays;
    return days != null && days < 1;
  }

  /// Sonraki yedekleme uzak mı? (7 günden fazla)
  bool get isNextBackupFar {
    final days = nextBackupDays;
    return days != null && days > 7;
  }

  /// Sonraki yedekleme orta mı? (1-7 gün arası)
  bool get isNextBackupMedium {
    final days = nextBackupDays;
    return days != null && days >= 1 && days <= 7;
  }

  /// Sonraki yedekleme kategorisi
  String get nextBackupCategory {
    if (isNextBackupSoon) return 'Yakın';
    if (isNextBackupFar) return 'Uzak';
    return 'Orta';
  }

  /// Başarılı son yedekleme mi?
  bool get isLastBackupSuccessful {
    return hasLastBackupStatus &&
        (lastBackupStatus == 'success' || lastBackupStatus == 'completed');
  }

  /// Başarısız son yedekleme mi?
  bool get isLastBackupFailed {
    return hasLastBackupStatus &&
        (lastBackupStatus == 'failed' || lastBackupStatus == 'error');
  }

  /// Son yedekleme durumu kategorisi
  String get lastBackupStatusCategory {
    if (isLastBackupSuccessful) return 'Başarılı';
    if (isLastBackupFailed) return 'Başarısız';
    return 'Bilinmiyor';
  }

  /// Yedekleme boyutu büyük mü? (1GB'dan fazla)
  bool get isLargeBackupSize {
    return hasLastBackupSize && lastBackupSize! > 1024;
  }

  /// Yedekleme boyutu küçük mü? (100MB'dan az)
  bool get isSmallBackupSize {
    return hasLastBackupSize && lastBackupSize! < 100;
  }

  /// Yedekleme boyutu orta mı? (100MB-1GB arası)
  bool get isMediumBackupSize {
    return hasLastBackupSize &&
        lastBackupSize! >= 100 &&
        lastBackupSize! <= 1024;
  }

  /// Yedekleme boyutu kategorisi
  String get backupSizeCategory {
    if (isLargeBackupSize) return 'Büyük';
    if (isSmallBackupSize) return 'Küçük';
    return 'Orta';
  }

  /// Zamanlanmış mı?
  bool get isScheduled => hasSchedule;

  /// Manuel mi?
  bool get isManual => !hasSchedule;

  /// Gecikmiş mi?
  bool get isOverdue {
    return hasNextBackupDate &&
        nextBackupDate!.isBefore(DateTime.now()) &&
        !isLastBackupSuccessful;
  }

  /// Kritik mi?
  bool get isCritical => isOverdue || isLastBackupFailed;

  /// Sağlıklı mı?
  bool get isHealthy => isLastBackupSuccessful && !isOverdue;

  @override
  String toString() {
    return 'BackupConfig(id: $id, name: $name, type: $type, status: $status, lastBackupDate: $lastBackupDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackupConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
