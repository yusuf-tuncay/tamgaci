// ========== CRASH REPORT ENTITY ==========
// lib/features/operations/domain/entities/crash_report.dart

/// Crash türü
enum CrashType {
  fatal('Ölümcül'),
  nonFatal('Ölümcül Olmayan'),
  anr('ANR'),
  oom('OOM'),
  custom('Özel');

  const CrashType(this.displayName);
  final String displayName;
}

/// Crash durumu
enum CrashStatus {
  newCrash('Yeni'),
  investigating('İnceleniyor'),
  fixed('Düzeltildi'),
  wontFix('Düzeltilmeyecek'),
  duplicate('Tekrar'),
  closed('Kapalı');

  const CrashStatus(this.displayName);
  final String displayName;
}

/// Crash önceliği
enum CrashPriority {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  critical('Kritik');

  const CrashPriority(this.displayName);
  final String displayName;
}

/// Crash raporu entity'si
class CrashReport {
  final String id;
  final String crashId;
  final CrashType type;
  final CrashStatus status;
  final CrashPriority priority;
  final String? title;
  final String? description;
  final String? stackTrace; // Stack trace
  final String? errorMessage; // Hata mesajı
  final String? errorCode; // Hata kodu
  final String? deviceModel; // Cihaz modeli
  final String? deviceBrand; // Cihaz markası
  final String? osVersion; // İşletim sistemi sürümü
  final String? appVersion; // Uygulama sürümü
  final String? buildNumber; // Build numarası
  final String? userId; // Kullanıcı ID'si
  final String? userName; // Kullanıcı adı
  final String? sessionId; // Oturum ID'si
  final String? category; // Kategori
  final String? tags; // Etiketler
  final String? assignedTo; // Atanan kullanıcı ID'si
  final String? assignedToName; // Atanan kullanıcı adı
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final DateTime? crashDate; // Crash tarihi
  final DateTime? firstSeenDate; // İlk görülme tarihi
  final DateTime? lastSeenDate; // Son görülme tarihi
  final DateTime? fixedDate; // Düzeltilme tarihi
  final int? occurrenceCount; // Oluşum sayısı
  final int? affectedUsers; // Etkilenen kullanıcı sayısı
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const CrashReport({
    required this.id,
    required this.crashId,
    required this.type,
    required this.status,
    required this.priority,
    this.title,
    this.description,
    this.stackTrace,
    this.errorMessage,
    this.errorCode,
    this.deviceModel,
    this.deviceBrand,
    this.osVersion,
    this.appVersion,
    this.buildNumber,
    this.userId,
    this.userName,
    this.sessionId,
    this.category,
    this.tags,
    this.assignedTo,
    this.assignedToName,
    this.createdBy,
    this.createdByName,
    this.crashDate,
    this.firstSeenDate,
    this.lastSeenDate,
    this.fixedDate,
    this.occurrenceCount,
    this.affectedUsers,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  CrashReport copyWith({
    String? id,
    String? crashId,
    CrashType? type,
    CrashStatus? status,
    CrashPriority? priority,
    String? title,
    String? description,
    String? stackTrace,
    String? errorMessage,
    String? errorCode,
    String? deviceModel,
    String? deviceBrand,
    String? osVersion,
    String? appVersion,
    String? buildNumber,
    String? userId,
    String? userName,
    String? sessionId,
    String? category,
    String? tags,
    String? assignedTo,
    String? assignedToName,
    String? createdBy,
    String? createdByName,
    DateTime? crashDate,
    DateTime? firstSeenDate,
    DateTime? lastSeenDate,
    DateTime? fixedDate,
    int? occurrenceCount,
    int? affectedUsers,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CrashReport(
      id: id ?? this.id,
      crashId: crashId ?? this.crashId,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      stackTrace: stackTrace ?? this.stackTrace,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      sessionId: sessionId ?? this.sessionId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      crashDate: crashDate ?? this.crashDate,
      firstSeenDate: firstSeenDate ?? this.firstSeenDate,
      lastSeenDate: lastSeenDate ?? this.lastSeenDate,
      fixedDate: fixedDate ?? this.fixedDate,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      affectedUsers: affectedUsers ?? this.affectedUsers,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan CrashReport oluştur
  factory CrashReport.fromJson(Map<String, dynamic> json) {
    return CrashReport(
      id: json['id'] as String,
      crashId: json['crashId'] as String,
      type: CrashType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CrashType.nonFatal,
      ),
      status: CrashStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CrashStatus.newCrash,
      ),
      priority: CrashPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => CrashPriority.medium,
      ),
      title: json['title'] as String?,
      description: json['description'] as String?,
      stackTrace: json['stackTrace'] as String?,
      errorMessage: json['errorMessage'] as String?,
      errorCode: json['errorCode'] as String?,
      deviceModel: json['deviceModel'] as String?,
      deviceBrand: json['deviceBrand'] as String?,
      osVersion: json['osVersion'] as String?,
      appVersion: json['appVersion'] as String?,
      buildNumber: json['buildNumber'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      sessionId: json['sessionId'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      crashDate: json['crashDate'] != null
          ? DateTime.parse(json['crashDate'] as String)
          : null,
      firstSeenDate: json['firstSeenDate'] != null
          ? DateTime.parse(json['firstSeenDate'] as String)
          : null,
      lastSeenDate: json['lastSeenDate'] != null
          ? DateTime.parse(json['lastSeenDate'] as String)
          : null,
      fixedDate: json['fixedDate'] != null
          ? DateTime.parse(json['fixedDate'] as String)
          : null,
      occurrenceCount: json['occurrenceCount'] as int?,
      affectedUsers: json['affectedUsers'] as int?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// CrashReport'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crashId': crashId,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'stackTrace': stackTrace,
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'deviceModel': deviceModel,
      'deviceBrand': deviceBrand,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'userId': userId,
      'userName': userName,
      'sessionId': sessionId,
      'category': category,
      'tags': tags,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'crashDate': crashDate?.toIso8601String(),
      'firstSeenDate': firstSeenDate?.toIso8601String(),
      'lastSeenDate': lastSeenDate?.toIso8601String(),
      'fixedDate': fixedDate?.toIso8601String(),
      'occurrenceCount': occurrenceCount,
      'affectedUsers': affectedUsers,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Ölümcül crash mi?
  bool get isFatal => type == CrashType.fatal;

  /// Ölümcül olmayan crash mi?
  bool get isNonFatal => type == CrashType.nonFatal;

  /// ANR crash mi?
  bool get isAnr => type == CrashType.anr;

  /// OOM crash mi?
  bool get isOom => type == CrashType.oom;

  /// Özel crash mi?
  bool get isCustom => type == CrashType.custom;

  /// Yeni crash mi?
  bool get isNew => status == CrashStatus.newCrash;

  /// İnceleniyor mu?
  bool get isInvestigating => status == CrashStatus.investigating;

  /// Düzeltildi mi?
  bool get isFixed => status == CrashStatus.fixed;

  /// Düzeltilmeyecek mi?
  bool get isWontFix => status == CrashStatus.wontFix;

  /// Tekrar mı?
  bool get isDuplicate => status == CrashStatus.duplicate;

  /// Kapalı mı?
  bool get isClosed => status == CrashStatus.closed;

  /// Düşük öncelik mi?
  bool get isLowPriority => priority == CrashPriority.low;

  /// Orta öncelik mi?
  bool get isMediumPriority => priority == CrashPriority.medium;

  /// Yüksek öncelik mi?
  bool get isHighPriority => priority == CrashPriority.high;

  /// Kritik öncelik mi?
  bool get isCriticalPriority => priority == CrashPriority.critical;

  /// Başlık var mı?
  bool get hasTitle => title != null && title!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Stack trace var mı?
  bool get hasStackTrace => stackTrace != null && stackTrace!.isNotEmpty;

  /// Hata mesajı var mı?
  bool get hasErrorMessage => errorMessage != null && errorMessage!.isNotEmpty;

  /// Hata kodu var mı?
  bool get hasErrorCode => errorCode != null && errorCode!.isNotEmpty;

  /// Cihaz modeli var mı?
  bool get hasDeviceModel => deviceModel != null && deviceModel!.isNotEmpty;

  /// Cihaz markası var mı?
  bool get hasDeviceBrand => deviceBrand != null && deviceBrand!.isNotEmpty;

  /// İşletim sistemi sürümü var mı?
  bool get hasOsVersion => osVersion != null && osVersion!.isNotEmpty;

  /// Uygulama sürümü var mı?
  bool get hasAppVersion => appVersion != null && appVersion!.isNotEmpty;

  /// Build numarası var mı?
  bool get hasBuildNumber => buildNumber != null && buildNumber!.isNotEmpty;

  /// Kullanıcı ID'si var mı?
  bool get hasUserId => userId != null && userId!.isNotEmpty;

  /// Kullanıcı adı var mı?
  bool get hasUserName => userName != null && userName!.isNotEmpty;

  /// Oturum ID'si var mı?
  bool get hasSessionId => sessionId != null && sessionId!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Atanan kullanıcı var mı?
  bool get hasAssignedTo => assignedTo != null && assignedTo!.isNotEmpty;

  /// Atanan kullanıcı adı var mı?
  bool get hasAssignedToName =>
      assignedToName != null && assignedToName!.isNotEmpty;

  /// Oluşturan kullanıcı var mı?
  bool get hasCreatedBy => createdBy != null && createdBy!.isNotEmpty;

  /// Oluşturan kullanıcı adı var mı?
  bool get hasCreatedByName =>
      createdByName != null && createdByName!.isNotEmpty;

  /// Crash tarihi var mı?
  bool get hasCrashDate => crashDate != null;

  /// İlk görülme tarihi var mı?
  bool get hasFirstSeenDate => firstSeenDate != null;

  /// Son görülme tarihi var mı?
  bool get hasLastSeenDate => lastSeenDate != null;

  /// Düzeltilme tarihi var mı?
  bool get hasFixedDate => fixedDate != null;

  /// Oluşum sayısı var mı?
  bool get hasOccurrenceCount =>
      occurrenceCount != null && occurrenceCount! > 0;

  /// Etkilenen kullanıcı sayısı var mı?
  bool get hasAffectedUsers => affectedUsers != null && affectedUsers! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return !isClosed && !isFixed;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isClosed || isFixed;
  }

  /// Atanabilir mi?
  bool get canBeAssigned {
    return !isClosed && !isFixed;
  }

  /// Düzeltilebilir mi?
  bool get canBeFixed {
    return !isClosed && !isFixed;
  }

  /// Kapatılabilir mi?
  bool get canBeClosed {
    return isFixed || isWontFix || isDuplicate;
  }

  /// Oluşum sayısı sıfır mı?
  bool get isZeroOccurrenceCount =>
      occurrenceCount == null || occurrenceCount == 0;

  /// Oluşum sayısı yüksek mi? (100'den fazla)
  bool get isHighOccurrenceCount =>
      occurrenceCount != null && occurrenceCount! > 100;

  /// Oluşum sayısı düşük mi? (5'ten az)
  bool get isLowOccurrenceCount =>
      occurrenceCount != null && occurrenceCount! < 5;

  /// Oluşum sayısı orta mı? (5-100 arası)
  bool get isMediumOccurrenceCount =>
      occurrenceCount != null &&
      occurrenceCount! >= 5 &&
      occurrenceCount! <= 100;

  /// Oluşum sayısı kategorisi
  String get occurrenceCountCategory {
    if (isHighOccurrenceCount) return 'Yüksek';
    if (isLowOccurrenceCount) return 'Düşük';
    return 'Orta';
  }

  /// Etkilenen kullanıcı sayısı sıfır mı?
  bool get isZeroAffectedUsers => affectedUsers == null || affectedUsers == 0;

  /// Etkilenen kullanıcı sayısı yüksek mi? (1000'den fazla)
  bool get isHighAffectedUsers =>
      affectedUsers != null && affectedUsers! > 1000;

  /// Etkilenen kullanıcı sayısı düşük mi? (10'dan az)
  bool get isLowAffectedUsers => affectedUsers != null && affectedUsers! < 10;

  /// Etkilenen kullanıcı sayısı orta mı? (10-1000 arası)
  bool get isMediumAffectedUsers =>
      affectedUsers != null && affectedUsers! >= 10 && affectedUsers! <= 1000;

  /// Etkilenen kullanıcı sayısı kategorisi
  String get affectedUsersCategory {
    if (isHighAffectedUsers) return 'Yüksek';
    if (isLowAffectedUsers) return 'Düşük';
    return 'Orta';
  }

  /// Crash süresi (gün)
  int? get crashDurationInDays {
    if (firstSeenDate == null || fixedDate == null) return null;
    return fixedDate!.difference(firstSeenDate!).inDays;
  }

  /// Son görülme süresi (gün)
  int? get lastSeenDays {
    if (lastSeenDate == null) return null;
    return DateTime.now().difference(lastSeenDate!).inDays;
  }

  /// Son görülme süresi uzun mu? (30 günden fazla)
  bool get isLastSeenLongAgo {
    final days = lastSeenDays;
    return days != null && days > 30;
  }

  /// Son görülme süresi kısa mı? (7 günden az)
  bool get isLastSeenRecently {
    final days = lastSeenDays;
    return days != null && days < 7;
  }

  /// Son görülme süresi orta mı? (7-30 gün arası)
  bool get isLastSeenMedium {
    final days = lastSeenDays;
    return days != null && days >= 7 && days <= 30;
  }

  /// Son görülme süresi kategorisi
  String get lastSeenCategory {
    if (isLastSeenLongAgo) return 'Uzun';
    if (isLastSeenRecently) return 'Kısa';
    return 'Orta';
  }

  /// Aktif crash mi?
  bool get isActive => !isClosed && !isFixed;

  /// Kritik crash mi?
  bool get isCritical => isFatal || isCriticalPriority;

  /// Yaygın crash mi?
  bool get isWidespread => isHighOccurrenceCount || isHighAffectedUsers;

  /// Yeni crash mi?
  bool get isRecent => isLastSeenRecently;

  /// Eski crash mi?
  bool get isOld => isLastSeenLongAgo;

  @override
  String toString() {
    return 'CrashReport(id: $id, crashId: $crashId, type: $type, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrashReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
