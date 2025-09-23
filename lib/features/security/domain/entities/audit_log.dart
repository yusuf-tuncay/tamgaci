// ========== AUDIT LOG ENTITY ==========
// lib/features/security/domain/entities/audit_log.dart

/// Audit log türü
enum AuditLogType {
  create('Oluşturma'),
  read('Okuma'),
  update('Güncelleme'),
  delete('Silme'),
  login('Giriş'),
  logout('Çıkış'),
  permission('İzin'),
  role('Rol'),
  security('Güvenlik'),
  system('Sistem'),
  custom('Özel');

  const AuditLogType(this.displayName);
  final String displayName;
}

/// Audit log seviyesi
enum AuditLogLevel {
  info('Bilgi'),
  warning('Uyarı'),
  error('Hata'),
  critical('Kritik');

  const AuditLogLevel(this.displayName);
  final String displayName;
}

/// Audit log entity'si
class AuditLog {
  final String id;
  final String eventType;
  final AuditLogType type;
  final AuditLogLevel level;
  final String? userId; // Kullanıcı ID'si
  final String? userName; // Kullanıcı adı
  final String? userRole; // Kullanıcı rolü
  final String? userDepartment; // Kullanıcı departmanı
  final String? resourceType; // Kaynak türü
  final String? resourceId; // Kaynak ID'si
  final String? resourceName; // Kaynak adı
  final String? action; // Aksiyon
  final String? description; // Açıklama
  final String? details; // Detaylar
  final String? ipAddress; // IP adresi
  final String? userAgent; // User agent
  final String? sessionId; // Oturum ID'si
  final String? requestId; // İstek ID'si
  final String? category; // Kategori
  final String? tags; // Etiketler
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime timestamp;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.eventType,
    required this.type,
    required this.level,
    this.userId,
    this.userName,
    this.userRole,
    this.userDepartment,
    this.resourceType,
    this.resourceId,
    this.resourceName,
    this.action,
    this.description,
    this.details,
    this.ipAddress,
    this.userAgent,
    this.sessionId,
    this.requestId,
    this.category,
    this.tags,
    this.metadata = const {},
    required this.timestamp,
    required this.createdAt,
  });

  /// CopyWith metodu
  AuditLog copyWith({
    String? id,
    String? eventType,
    AuditLogType? type,
    AuditLogLevel? level,
    String? userId,
    String? userName,
    String? userRole,
    String? userDepartment,
    String? resourceType,
    String? resourceId,
    String? resourceName,
    String? action,
    String? description,
    String? details,
    String? ipAddress,
    String? userAgent,
    String? sessionId,
    String? requestId,
    String? category,
    String? tags,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return AuditLog(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      type: type ?? this.type,
      level: level ?? this.level,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userDepartment: userDepartment ?? this.userDepartment,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      action: action ?? this.action,
      description: description ?? this.description,
      details: details ?? this.details,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      sessionId: sessionId ?? this.sessionId,
      requestId: requestId ?? this.requestId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// JSON'dan AuditLog oluştur
  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      eventType: json['eventType'] as String,
      type: AuditLogType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AuditLogType.system,
      ),
      level: AuditLogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => AuditLogLevel.info,
      ),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userRole: json['userRole'] as String?,
      userDepartment: json['userDepartment'] as String?,
      resourceType: json['resourceType'] as String?,
      resourceId: json['resourceId'] as String?,
      resourceName: json['resourceName'] as String?,
      action: json['action'] as String?,
      description: json['description'] as String?,
      details: json['details'] as String?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      sessionId: json['sessionId'] as String?,
      requestId: json['requestId'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// AuditLog'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'type': type.name,
      'level': level.name,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'userDepartment': userDepartment,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'resourceName': resourceName,
      'action': action,
      'description': description,
      'details': details,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'sessionId': sessionId,
      'requestId': requestId,
      'category': category,
      'tags': tags,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Oluşturma log'u mu?
  bool get isCreateLog => type == AuditLogType.create;

  /// Okuma log'u mu?
  bool get isReadLog => type == AuditLogType.read;

  /// Güncelleme log'u mu?
  bool get isUpdateLog => type == AuditLogType.update;

  /// Silme log'u mu?
  bool get isDeleteLog => type == AuditLogType.delete;

  /// Giriş log'u mu?
  bool get isLoginLog => type == AuditLogType.login;

  /// Çıkış log'u mu?
  bool get isLogoutLog => type == AuditLogType.logout;

  /// İzin log'u mu?
  bool get isPermissionLog => type == AuditLogType.permission;

  /// Rol log'u mu?
  bool get isRoleLog => type == AuditLogType.role;

  /// Güvenlik log'u mu?
  bool get isSecurityLog => type == AuditLogType.security;

  /// Sistem log'u mu?
  bool get isSystemLog => type == AuditLogType.system;

  /// Özel log mu?
  bool get isCustomLog => type == AuditLogType.custom;

  /// Bilgi seviyesi mi?
  bool get isInfoLevel => level == AuditLogLevel.info;

  /// Uyarı seviyesi mi?
  bool get isWarningLevel => level == AuditLogLevel.warning;

  /// Hata seviyesi mi?
  bool get isErrorLevel => level == AuditLogLevel.error;

  /// Kritik seviye mi?
  bool get isCriticalLevel => level == AuditLogLevel.critical;

  /// Kullanıcı ID'si var mı?
  bool get hasUserId => userId != null && userId!.isNotEmpty;

  /// Kullanıcı adı var mı?
  bool get hasUserName => userName != null && userName!.isNotEmpty;

  /// Kullanıcı rolü var mı?
  bool get hasUserRole => userRole != null && userRole!.isNotEmpty;

  /// Kullanıcı departmanı var mı?
  bool get hasUserDepartment =>
      userDepartment != null && userDepartment!.isNotEmpty;

  /// Kaynak türü var mı?
  bool get hasResourceType => resourceType != null && resourceType!.isNotEmpty;

  /// Kaynak ID'si var mı?
  bool get hasResourceId => resourceId != null && resourceId!.isNotEmpty;

  /// Kaynak adı var mı?
  bool get hasResourceName => resourceName != null && resourceName!.isNotEmpty;

  /// Aksiyon var mı?
  bool get hasAction => action != null && action!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Detay var mı?
  bool get hasDetails => details != null && details!.isNotEmpty;

  /// IP adresi var mı?
  bool get hasIpAddress => ipAddress != null && ipAddress!.isNotEmpty;

  /// User agent var mı?
  bool get hasUserAgent => userAgent != null && userAgent!.isNotEmpty;

  /// Oturum ID'si var mı?
  bool get hasSessionId => sessionId != null && sessionId!.isNotEmpty;

  /// İstek ID'si var mı?
  bool get hasRequestId => requestId != null && requestId!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Kullanıcı bilgisi var mı?
  bool get hasUserInfo => hasUserId && hasUserName;

  /// Kaynak bilgisi var mı?
  bool get hasResourceInfo => hasResourceType && hasResourceId;

  /// Güvenlik bilgisi var mı?
  bool get hasSecurityInfo => hasIpAddress || hasUserAgent || hasSessionId;

  /// Kritik log mu?
  bool get isCritical => isCriticalLevel || isSecurityLog || isDeleteLog;

  /// Önemli log mu?
  bool get isImportant =>
      isErrorLevel || isWarningLevel || isUpdateLog || isCreateLog;

  /// Normal log mu?
  bool get isNormal => isInfoLevel && (isReadLog || isSystemLog);

  /// Güvenlik riski var mı?
  bool get hasSecurityRisk {
    return isSecurityLog ||
        isCriticalLevel ||
        (hasIpAddress && ipAddress!.contains('192.168')) ||
        (hasUserAgent && userAgent!.contains('bot'));
  }

  /// Şüpheli aktivite var mı?
  bool get hasSuspiciousActivity {
    return isCriticalLevel ||
        isSecurityLog ||
        (hasIpAddress && ipAddress!.contains('10.0')) ||
        (hasUserAgent && userAgent!.contains('crawler'));
  }

  /// Başarılı işlem mi?
  bool get isSuccessfulOperation {
    return isInfoLevel && (isCreateLog || isUpdateLog || isReadLog);
  }

  /// Başarısız işlem mi?
  bool get isFailedOperation {
    return isErrorLevel || isCriticalLevel;
  }

  /// Uyarı gerektiren işlem mi?
  bool get isWarningOperation {
    return isWarningLevel;
  }

  /// Yaş (gün)
  int get ageInDays => DateTime.now().difference(timestamp).inDays;

  /// Yeni log mu? (1 günden az)
  bool get isNew => ageInDays < 1;

  /// Eski log mu? (30 günden fazla)
  bool get isOld => ageInDays > 30;

  /// Orta yaş log mu? (1-30 gün arası)
  bool get isMediumAge => ageInDays >= 1 && ageInDays <= 30;

  /// Yaş kategorisi
  String get ageCategory {
    if (isNew) return 'Yeni';
    if (isOld) return 'Eski';
    return 'Orta';
  }

  /// Günlük log mu?
  bool get isDailyLog => ageInDays < 1;

  /// Haftalık log mu?
  bool get isWeeklyLog => ageInDays >= 1 && ageInDays < 7;

  /// Aylık log mu?
  bool get isMonthlyLog => ageInDays >= 7 && ageInDays < 30;

  /// Yıllık log mu?
  bool get isYearlyLog => ageInDays >= 30;

  /// Log türü kategorisi
  String get logTypeCategory {
    if (isCritical) return 'Kritik';
    if (isImportant) return 'Önemli';
    return 'Normal';
  }

  /// Log seviyesi kategorisi
  String get logLevelCategory {
    if (isCriticalLevel) return 'Kritik';
    if (isErrorLevel) return 'Hata';
    if (isWarningLevel) return 'Uyarı';
    return 'Bilgi';
  }

  @override
  String toString() {
    return 'AuditLog(id: $id, eventType: $eventType, type: $type, level: $level, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
