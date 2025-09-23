// ========== PERFORMANCE METRIC ENTITY ==========
// lib/features/operations/domain/entities/performance_metric.dart

/// Performans metrik türü
enum PerformanceMetricType {
  responseTime('Yanıt Süresi'),
  throughput('Verim'),
  latency('Gecikme'),
  memory('Bellek'),
  cpu('CPU'),
  disk('Disk'),
  network('Ağ'),
  custom('Özel');

  const PerformanceMetricType(this.displayName);
  final String displayName;
}

/// Performans metrik durumu
enum PerformanceMetricStatus {
  active('Aktif'),
  inactive('Pasif'),
  suspended('Askıya Alındı'),
  deleted('Silindi');

  const PerformanceMetricStatus(this.displayName);
  final String displayName;
}

/// Performans metrik entity'si
class PerformanceMetric {
  final String id;
  final String metricName;
  final String? displayName;
  final String? description;
  final PerformanceMetricType type;
  final PerformanceMetricStatus status;
  final String? resourceType; // Kaynak türü
  final String? resourceId; // Kaynak ID'si
  final String? category; // Kategori
  final String? tags; // Etiketler
  final double? value; // Değer
  final String? unit; // Birim
  final double? threshold; // Eşik
  final String? thresholdType; // Eşik türü (min, max, avg)
  final bool? isAboveThreshold; // Eşiğin üstünde mi?
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? measurementDate; // Ölçüm tarihi
  final DateTime? lastUpdatedDate; // Son güncelleme tarihi
  final int? sampleCount; // Örnek sayısı
  final double? minValue; // Minimum değer
  final double? maxValue; // Maksimum değer
  final double? avgValue; // Ortalama değer
  final double? medianValue; // Medyan değer
  final double? p95Value; // P95 değeri
  final double? p99Value; // P99 değeri
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const PerformanceMetric({
    required this.id,
    required this.metricName,
    this.displayName,
    this.description,
    required this.type,
    required this.status,
    this.resourceType,
    this.resourceId,
    this.category,
    this.tags,
    this.value,
    this.unit,
    this.threshold,
    this.thresholdType,
    this.isAboveThreshold,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.measurementDate,
    this.lastUpdatedDate,
    this.sampleCount,
    this.minValue,
    this.maxValue,
    this.avgValue,
    this.medianValue,
    this.p95Value,
    this.p99Value,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  PerformanceMetric copyWith({
    String? id,
    String? metricName,
    String? displayName,
    String? description,
    PerformanceMetricType? type,
    PerformanceMetricStatus? status,
    String? resourceType,
    String? resourceId,
    String? category,
    String? tags,
    double? value,
    String? unit,
    double? threshold,
    String? thresholdType,
    bool? isAboveThreshold,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? measurementDate,
    DateTime? lastUpdatedDate,
    int? sampleCount,
    double? minValue,
    double? maxValue,
    double? avgValue,
    double? medianValue,
    double? p95Value,
    double? p99Value,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PerformanceMetric(
      id: id ?? this.id,
      metricName: metricName ?? this.metricName,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      threshold: threshold ?? this.threshold,
      thresholdType: thresholdType ?? this.thresholdType,
      isAboveThreshold: isAboveThreshold ?? this.isAboveThreshold,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      measurementDate: measurementDate ?? this.measurementDate,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      sampleCount: sampleCount ?? this.sampleCount,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      avgValue: avgValue ?? this.avgValue,
      medianValue: medianValue ?? this.medianValue,
      p95Value: p95Value ?? this.p95Value,
      p99Value: p99Value ?? this.p99Value,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan PerformanceMetric oluştur
  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      id: json['id'] as String,
      metricName: json['metricName'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      type: PerformanceMetricType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PerformanceMetricType.responseTime,
      ),
      status: PerformanceMetricStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PerformanceMetricStatus.active,
      ),
      resourceType: json['resourceType'] as String?,
      resourceId: json['resourceId'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      unit: json['unit'] as String?,
      threshold: json['threshold'] != null
          ? (json['threshold'] as num).toDouble()
          : null,
      thresholdType: json['thresholdType'] as String?,
      isAboveThreshold: json['isAboveThreshold'] as bool?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      measurementDate: json['measurementDate'] != null
          ? DateTime.parse(json['measurementDate'] as String)
          : null,
      lastUpdatedDate: json['lastUpdatedDate'] != null
          ? DateTime.parse(json['lastUpdatedDate'] as String)
          : null,
      sampleCount: json['sampleCount'] as int?,
      minValue: json['minValue'] != null
          ? (json['minValue'] as num).toDouble()
          : null,
      maxValue: json['maxValue'] != null
          ? (json['maxValue'] as num).toDouble()
          : null,
      avgValue: json['avgValue'] != null
          ? (json['avgValue'] as num).toDouble()
          : null,
      medianValue: json['medianValue'] != null
          ? (json['medianValue'] as num).toDouble()
          : null,
      p95Value: json['p95Value'] != null
          ? (json['p95Value'] as num).toDouble()
          : null,
      p99Value: json['p99Value'] != null
          ? (json['p99Value'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// PerformanceMetric'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metricName': metricName,
      'displayName': displayName,
      'description': description,
      'type': type.name,
      'status': status.name,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'category': category,
      'tags': tags,
      'value': value,
      'unit': unit,
      'threshold': threshold,
      'thresholdType': thresholdType,
      'isAboveThreshold': isAboveThreshold,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'measurementDate': measurementDate?.toIso8601String(),
      'lastUpdatedDate': lastUpdatedDate?.toIso8601String(),
      'sampleCount': sampleCount,
      'minValue': minValue,
      'maxValue': maxValue,
      'avgValue': avgValue,
      'medianValue': medianValue,
      'p95Value': p95Value,
      'p99Value': p99Value,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Yanıt süresi metrik mi?
  bool get isResponseTimeMetric => type == PerformanceMetricType.responseTime;

  /// Verim metrik mi?
  bool get isThroughputMetric => type == PerformanceMetricType.throughput;

  /// Gecikme metrik mi?
  bool get isLatencyMetric => type == PerformanceMetricType.latency;

  /// Bellek metrik mi?
  bool get isMemoryMetric => type == PerformanceMetricType.memory;

  /// CPU metrik mi?
  bool get isCpuMetric => type == PerformanceMetricType.cpu;

  /// Disk metrik mi?
  bool get isDiskMetric => type == PerformanceMetricType.disk;

  /// Ağ metrik mi?
  bool get isNetworkMetric => type == PerformanceMetricType.network;

  /// Özel metrik mi?
  bool get isCustomMetric => type == PerformanceMetricType.custom;

  /// Aktif mi?
  bool get isActive => status == PerformanceMetricStatus.active;

  /// Pasif mi?
  bool get isInactive => status == PerformanceMetricStatus.inactive;

  /// Askıya alındı mı?
  bool get isSuspended => status == PerformanceMetricStatus.suspended;

  /// Silindi mi?
  bool get isDeleted => status == PerformanceMetricStatus.deleted;

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

  /// Değer var mı?
  bool get hasValue => value != null;

  /// Birim var mı?
  bool get hasUnit => unit != null && unit!.isNotEmpty;

  /// Eşik var mı?
  bool get hasThreshold => threshold != null;

  /// Eşik türü var mı?
  bool get hasThresholdType =>
      thresholdType != null && thresholdType!.isNotEmpty;

  /// Eşiğin üstünde mi?
  bool get isAboveThresholdValue => isAboveThreshold == true;

  /// Eşiğin altında mı?
  bool get isBelowThresholdValue => isAboveThreshold == false;

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

  /// Ölçüm tarihi var mı?
  bool get hasMeasurementDate => measurementDate != null;

  /// Son güncelleme tarihi var mı?
  bool get hasLastUpdatedDate => lastUpdatedDate != null;

  /// Örnek sayısı var mı?
  bool get hasSampleCount => sampleCount != null && sampleCount! > 0;

  /// Minimum değer var mı?
  bool get hasMinValue => minValue != null;

  /// Maksimum değer var mı?
  bool get hasMaxValue => maxValue != null;

  /// Ortalama değer var mı?
  bool get hasAvgValue => avgValue != null;

  /// Medyan değer var mı?
  bool get hasMedianValue => medianValue != null;

  /// P95 değeri var mı?
  bool get hasP95Value => p95Value != null;

  /// P99 değeri var mı?
  bool get hasP99Value => p99Value != null;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return isActive && !isDeleted;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isActive && (sampleCount == null || sampleCount == 0);
  }

  /// Askıya alınabilir mi?
  bool get canBeSuspended {
    return isActive;
  }

  /// Aktifleştirilebilir mi?
  bool get canBeActivated {
    return isInactive || isSuspended;
  }

  /// Kullanılabilir mi?
  bool get canBeUsed {
    return isActive && hasValue;
  }

  /// Performanslı mı?
  bool get isPerformant {
    return isActive && hasThreshold && !isAboveThresholdValue;
  }

  /// Performans sorunu var mı?
  bool get hasPerformanceIssue {
    return isActive && hasThreshold && isAboveThresholdValue;
  }

  /// Örnek sayısı sıfır mı?
  bool get isZeroSampleCount => sampleCount == null || sampleCount == 0;

  /// Örnek sayısı yüksek mi? (1000'den fazla)
  bool get isHighSampleCount => sampleCount != null && sampleCount! > 1000;

  /// Örnek sayısı düşük mi? (10'dan az)
  bool get isLowSampleCount => sampleCount != null && sampleCount! < 10;

  /// Örnek sayısı orta mı? (10-1000 arası)
  bool get isMediumSampleCount =>
      sampleCount != null && sampleCount! >= 10 && sampleCount! <= 1000;

  /// Örnek sayısı kategorisi
  String get sampleCountCategory {
    if (isHighSampleCount) return 'Yüksek';
    if (isLowSampleCount) return 'Düşük';
    return 'Orta';
  }

  /// Değer aralığı var mı?
  bool get hasValueRange => hasMinValue && hasMaxValue;

  /// Değer aralığı geniş mi?
  bool get isWideValueRange {
    if (!hasValueRange) return false;
    return (maxValue! - minValue!) > (avgValue ?? 0) * 2;
  }

  /// Değer aralığı dar mı?
  bool get isNarrowValueRange {
    if (!hasValueRange) return false;
    return (maxValue! - minValue!) < (avgValue ?? 0) * 0.5;
  }

  /// Değer aralığı orta mı?
  bool get isMediumValueRange {
    if (!hasValueRange) return false;
    return !isWideValueRange && !isNarrowValueRange;
  }

  /// Değer aralığı kategorisi
  String get valueRangeCategory {
    if (isWideValueRange) return 'Geniş';
    if (isNarrowValueRange) return 'Dar';
    return 'Orta';
  }

  /// Son güncelleme süresi (gün)
  int? get lastUpdatedDays {
    if (lastUpdatedDate == null) return null;
    return DateTime.now().difference(lastUpdatedDate!).inDays;
  }

  /// Son güncelleme süresi uzun mu? (30 günden fazla)
  bool get isLastUpdatedLongAgo {
    final days = lastUpdatedDays;
    return days != null && days > 30;
  }

  /// Son güncelleme süresi kısa mı? (7 günden az)
  bool get isLastUpdatedRecently {
    final days = lastUpdatedDays;
    return days != null && days < 7;
  }

  /// Son güncelleme süresi orta mı? (7-30 gün arası)
  bool get isLastUpdatedMedium {
    final days = lastUpdatedDays;
    return days != null && days >= 7 && days <= 30;
  }

  /// Son güncelleme süresi kategorisi
  String get lastUpdatedCategory {
    if (isLastUpdatedLongAgo) return 'Uzun';
    if (isLastUpdatedRecently) return 'Kısa';
    return 'Orta';
  }

  /// İstatistiksel veri var mı?
  bool get hasStatisticalData {
    return hasMinValue ||
        hasMaxValue ||
        hasAvgValue ||
        hasMedianValue ||
        hasP95Value ||
        hasP99Value;
  }

  /// Kapsamlı istatistik var mı?
  bool get hasComprehensiveStats {
    return hasMinValue &&
        hasMaxValue &&
        hasAvgValue &&
        hasMedianValue &&
        hasP95Value &&
        hasP99Value;
  }

  /// Kısmi istatistik var mı?
  bool get hasPartialStats {
    return hasStatisticalData && !hasComprehensiveStats;
  }

  /// İstatistik kategorisi
  String get statsCategory {
    if (hasComprehensiveStats) return 'Kapsamlı';
    if (hasPartialStats) return 'Kısmi';
    return 'Yok';
  }

  @override
  String toString() {
    return 'PerformanceMetric(id: $id, metricName: $metricName, type: $type, status: $status, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceMetric && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
