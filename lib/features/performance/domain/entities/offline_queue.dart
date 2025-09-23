// ========== OFFLINE QUEUE ENTITY ==========
// lib/features/performance/domain/entities/offline_queue.dart

/// Offline kuyruk türü
enum OfflineQueueType {
  sync('Senkronizasyon'),
  upload('Yükleme'),
  download('İndirme'),
  delete('Silme'),
  update('Güncelleme'),
  create('Oluşturma'),
  custom('Özel');

  const OfflineQueueType(this.displayName);
  final String displayName;
}

/// Offline kuyruk durumu
enum OfflineQueueStatus {
  pending('Beklemede'),
  processing('İşleniyor'),
  completed('Tamamlandı'),
  failed('Başarısız'),
  retrying('Yeniden Deneniyor'),
  cancelled('İptal Edildi'),
  paused('Duraklatıldı');

  const OfflineQueueStatus(this.displayName);
  final String displayName;
}

/// Offline kuyruk önceliği
enum OfflineQueuePriority {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  critical('Kritik');

  const OfflineQueuePriority(this.displayName);
  final String displayName;
}

/// Offline kuyruk entity'si
class OfflineQueue {
  final String id;
  final String queueNumber;
  final OfflineQueueType type;
  final OfflineQueueStatus status;
  final OfflineQueuePriority priority;
  final String? resourceType; // Kaynak türü
  final String? resourceId; // Kaynak ID'si
  final String? resourceName; // Kaynak adı
  final String? operation; // İşlem
  final String? endpoint; // Endpoint
  final String? method; // HTTP metodu
  final Map<String, dynamic>? payload; // Veri
  final Map<String, String>? headers; // Başlıklar
  final String? category; // Kategori
  final String? tags; // Etiketler
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final DateTime? scheduledDate; // Zamanlanmış tarih
  final DateTime? processedDate; // İşlenme tarihi
  final DateTime? completedDate; // Tamamlanma tarihi
  final DateTime? failedDate; // Başarısız olma tarihi
  final int? retryCount; // Yeniden deneme sayısı
  final int? maxRetries; // Maksimum yeniden deneme sayısı
  final String? errorMessage; // Hata mesajı
  final String? errorCode; // Hata kodu
  final String? responseData; // Yanıt verisi
  final int? responseCode; // Yanıt kodu
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const OfflineQueue({
    required this.id,
    required this.queueNumber,
    required this.type,
    required this.status,
    required this.priority,
    this.resourceType,
    this.resourceId,
    this.resourceName,
    this.operation,
    this.endpoint,
    this.method,
    this.payload,
    this.headers,
    this.category,
    this.tags,
    this.createdBy,
    this.createdByName,
    this.scheduledDate,
    this.processedDate,
    this.completedDate,
    this.failedDate,
    this.retryCount,
    this.maxRetries,
    this.errorMessage,
    this.errorCode,
    this.responseData,
    this.responseCode,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  OfflineQueue copyWith({
    String? id,
    String? queueNumber,
    OfflineQueueType? type,
    OfflineQueueStatus? status,
    OfflineQueuePriority? priority,
    String? resourceType,
    String? resourceId,
    String? resourceName,
    String? operation,
    String? endpoint,
    String? method,
    Map<String, dynamic>? payload,
    Map<String, String>? headers,
    String? category,
    String? tags,
    String? createdBy,
    String? createdByName,
    DateTime? scheduledDate,
    DateTime? processedDate,
    DateTime? completedDate,
    DateTime? failedDate,
    int? retryCount,
    int? maxRetries,
    String? errorMessage,
    String? errorCode,
    String? responseData,
    int? responseCode,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfflineQueue(
      id: id ?? this.id,
      queueNumber: queueNumber ?? this.queueNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      operation: operation ?? this.operation,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      payload: payload ?? this.payload,
      headers: headers ?? this.headers,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      processedDate: processedDate ?? this.processedDate,
      completedDate: completedDate ?? this.completedDate,
      failedDate: failedDate ?? this.failedDate,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      responseData: responseData ?? this.responseData,
      responseCode: responseCode ?? this.responseCode,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan OfflineQueue oluştur
  factory OfflineQueue.fromJson(Map<String, dynamic> json) {
    return OfflineQueue(
      id: json['id'] as String,
      queueNumber: json['queueNumber'] as String,
      type: OfflineQueueType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OfflineQueueType.sync,
      ),
      status: OfflineQueueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OfflineQueueStatus.pending,
      ),
      priority: OfflineQueuePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => OfflineQueuePriority.medium,
      ),
      resourceType: json['resourceType'] as String?,
      resourceId: json['resourceId'] as String?,
      resourceName: json['resourceName'] as String?,
      operation: json['operation'] as String?,
      endpoint: json['endpoint'] as String?,
      method: json['method'] as String?,
      payload: json['payload'] != null
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      failedDate: json['failedDate'] != null
          ? DateTime.parse(json['failedDate'] as String)
          : null,
      retryCount: json['retryCount'] as int?,
      maxRetries: json['maxRetries'] as int?,
      errorMessage: json['errorMessage'] as String?,
      errorCode: json['errorCode'] as String?,
      responseData: json['responseData'] as String?,
      responseCode: json['responseCode'] as int?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// OfflineQueue'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queueNumber': queueNumber,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'resourceName': resourceName,
      'operation': operation,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'headers': headers,
      'category': category,
      'tags': tags,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'failedDate': failedDate?.toIso8601String(),
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'responseData': responseData,
      'responseCode': responseCode,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Senkronizasyon kuyruğu mu?
  bool get isSyncQueue => type == OfflineQueueType.sync;

  /// Yükleme kuyruğu mu?
  bool get isUploadQueue => type == OfflineQueueType.upload;

  /// İndirme kuyruğu mu?
  bool get isDownloadQueue => type == OfflineQueueType.download;

  /// Silme kuyruğu mu?
  bool get isDeleteQueue => type == OfflineQueueType.delete;

  /// Güncelleme kuyruğu mu?
  bool get isUpdateQueue => type == OfflineQueueType.update;

  /// Oluşturma kuyruğu mu?
  bool get isCreateQueue => type == OfflineQueueType.create;

  /// Özel kuyruk mu?
  bool get isCustomQueue => type == OfflineQueueType.custom;

  /// Beklemede mi?
  bool get isPending => status == OfflineQueueStatus.pending;

  /// İşleniyor mu?
  bool get isProcessing => status == OfflineQueueStatus.processing;

  /// Tamamlandı mı?
  bool get isCompleted => status == OfflineQueueStatus.completed;

  /// Başarısız mı?
  bool get isFailed => status == OfflineQueueStatus.failed;

  /// Yeniden deneniyor mu?
  bool get isRetrying => status == OfflineQueueStatus.retrying;

  /// İptal edildi mi?
  bool get isCancelled => status == OfflineQueueStatus.cancelled;

  /// Duraklatıldı mı?
  bool get isPaused => status == OfflineQueueStatus.paused;

  /// Düşük öncelik mi?
  bool get isLowPriority => priority == OfflineQueuePriority.low;

  /// Orta öncelik mi?
  bool get isMediumPriority => priority == OfflineQueuePriority.medium;

  /// Yüksek öncelik mi?
  bool get isHighPriority => priority == OfflineQueuePriority.high;

  /// Kritik öncelik mi?
  bool get isCriticalPriority => priority == OfflineQueuePriority.critical;

  /// Kaynak türü var mı?
  bool get hasResourceType => resourceType != null && resourceType!.isNotEmpty;

  /// Kaynak ID'si var mı?
  bool get hasResourceId => resourceId != null && resourceId!.isNotEmpty;

  /// Kaynak adı var mı?
  bool get hasResourceName => resourceName != null && resourceName!.isNotEmpty;

  /// İşlem var mı?
  bool get hasOperation => operation != null && operation!.isNotEmpty;

  /// Endpoint var mı?
  bool get hasEndpoint => endpoint != null && endpoint!.isNotEmpty;

  /// HTTP metodu var mı?
  bool get hasMethod => method != null && method!.isNotEmpty;

  /// Veri var mı?
  bool get hasPayload => payload != null && payload!.isNotEmpty;

  /// Başlık var mı?
  bool get hasHeaders => headers != null && headers!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Oluşturan kullanıcı var mı?
  bool get hasCreatedBy => createdBy != null && createdBy!.isNotEmpty;

  /// Oluşturan kullanıcı adı var mı?
  bool get hasCreatedByName =>
      createdByName != null && createdByName!.isNotEmpty;

  /// Zamanlanmış tarih var mı?
  bool get hasScheduledDate => scheduledDate != null;

  /// İşlenme tarihi var mı?
  bool get hasProcessedDate => processedDate != null;

  /// Tamamlanma tarihi var mı?
  bool get hasCompletedDate => completedDate != null;

  /// Başarısız olma tarihi var mı?
  bool get hasFailedDate => failedDate != null;

  /// Yeniden deneme sayısı var mı?
  bool get hasRetryCount => retryCount != null && retryCount! > 0;

  /// Maksimum yeniden deneme sayısı var mı?
  bool get hasMaxRetries => maxRetries != null && maxRetries! > 0;

  /// Hata mesajı var mı?
  bool get hasErrorMessage => errorMessage != null && errorMessage!.isNotEmpty;

  /// Hata kodu var mı?
  bool get hasErrorCode => errorCode != null && errorCode!.isNotEmpty;

  /// Yanıt verisi var mı?
  bool get hasResponseData => responseData != null && responseData!.isNotEmpty;

  /// Yanıt kodu var mı?
  bool get hasResponseCode => responseCode != null && responseCode! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// İşlenebilir mi?
  bool get canBeProcessed {
    return isPending &&
        hasEndpoint &&
        hasMethod &&
        (!hasScheduledDate || scheduledDate!.isBefore(DateTime.now()));
  }

  /// Yeniden denenebilir mi?
  bool get canBeRetried {
    return isFailed &&
        hasMaxRetries &&
        (retryCount == null || retryCount! < maxRetries!);
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return isPending || isProcessing || isRetrying;
  }

  /// Duraklatılabilir mi?
  bool get canBePaused {
    return isPending || isProcessing;
  }

  /// Devam ettirilebilir mi?
  bool get canBeResumed {
    return isPaused;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isCompleted || isCancelled || isFailed;
  }

  /// Zamanlanmış mı?
  bool get isScheduled {
    return hasScheduledDate && scheduledDate!.isAfter(DateTime.now());
  }

  /// Gecikmiş mi?
  bool get isOverdue {
    return hasScheduledDate &&
        scheduledDate!.isBefore(DateTime.now()) &&
        !isCompleted;
  }

  /// Başarılı mı?
  bool get isSuccessful {
    return isCompleted &&
        hasResponseCode &&
        responseCode! >= 200 &&
        responseCode! < 300;
  }

  /// Başarısız mı?
  bool get isUnsuccessful {
    return isFailed || (isCompleted && hasResponseCode && responseCode! >= 400);
  }

  /// Yeniden deneme sayısı sıfır mı?
  bool get isZeroRetryCount => retryCount == null || retryCount == 0;

  /// Yeniden deneme sayısı yüksek mi? (5'ten fazla)
  bool get isHighRetryCount => retryCount != null && retryCount! > 5;

  /// Yeniden deneme sayısı düşük mi? (2'den az)
  bool get isLowRetryCount => retryCount != null && retryCount! < 2;

  /// Yeniden deneme sayısı orta mı? (2-5 arası)
  bool get isMediumRetryCount =>
      retryCount != null && retryCount! >= 2 && retryCount! <= 5;

  /// Yeniden deneme sayısı kategorisi
  String get retryCountCategory {
    if (isHighRetryCount) return 'Yüksek';
    if (isLowRetryCount) return 'Düşük';
    return 'Orta';
  }

  /// İşlem süresi (dakika)
  int? get processingTimeInMinutes {
    if (processedDate == null || completedDate == null) return null;
    return completedDate!.difference(processedDate!).inMinutes;
  }

  /// Bekleme süresi (dakika)
  int? get waitingTimeInMinutes {
    if (scheduledDate == null || processedDate == null) return null;
    return processedDate!.difference(scheduledDate!).inMinutes;
  }

  /// Toplam süre (dakika)
  int? get totalTimeInMinutes {
    if (completedDate == null) return null;
    return completedDate!.difference(createdAt).inMinutes;
  }

  /// Hızlı işlem mi? (5 dakikadan az)
  bool get isFastProcessing {
    final time = processingTimeInMinutes;
    return time != null && time < 5;
  }

  /// Yavaş işlem mi? (30 dakikadan fazla)
  bool get isSlowProcessing {
    final time = processingTimeInMinutes;
    return time != null && time > 30;
  }

  /// Orta hızlı işlem mi? (5-30 dakika arası)
  bool get isMediumProcessing {
    final time = processingTimeInMinutes;
    return time != null && time >= 5 && time <= 30;
  }

  /// İşlem hızı kategorisi
  String get processingSpeedCategory {
    if (isFastProcessing) return 'Hızlı';
    if (isSlowProcessing) return 'Yavaş';
    return 'Orta';
  }

  @override
  String toString() {
    return 'OfflineQueue(id: $id, queueNumber: $queueNumber, type: $type, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfflineQueue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
