// ========== CACHE CONFIG ENTITY ==========
// lib/features/performance/domain/entities/cache_config.dart

/// Cache türü
enum CacheType {
  memory('Bellek'),
  disk('Disk'),
  network('Ağ'),
  hybrid('Hibrit');

  const CacheType(this.displayName);
  final String displayName;
}

/// Cache durumu
enum CacheStatus {
  active('Aktif'),
  inactive('Pasif'),
  suspended('Askıya Alındı'),
  deleted('Silindi');

  const CacheStatus(this.displayName);
  final String displayName;
}

/// Cache konfigürasyonu entity'si
class CacheConfig {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final CacheType type;
  final CacheStatus status;
  final String? resourceType; // Kaynak türü
  final String? resourceId; // Kaynak ID'si
  final String? category; // Kategori
  final String? tags; // Etiketler
  final int? maxSize; // Maksimum boyut (MB)
  final int? maxAge; // Maksimum yaş (dakika)
  final int? maxEntries; // Maksimum giriş sayısı
  final String? evictionPolicy; // Çıkarma politikası
  final bool? enableCompression; // Sıkıştırma etkin mi?
  final bool? enableEncryption; // Şifreleme etkin mi?
  final String? encryptionKey; // Şifreleme anahtarı
  final String? compressionAlgorithm; // Sıkıştırma algoritması
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? lastUsedDate; // Son kullanım tarihi
  final int? hitCount; // İsabet sayısı
  final int? missCount; // Kaçırma sayısı
  final double? hitRate; // İsabet oranı
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const CacheConfig({
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
    this.maxSize,
    this.maxAge,
    this.maxEntries,
    this.evictionPolicy,
    this.enableCompression,
    this.enableEncryption,
    this.encryptionKey,
    this.compressionAlgorithm,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.lastUsedDate,
    this.hitCount,
    this.missCount,
    this.hitRate,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  CacheConfig copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    CacheType? type,
    CacheStatus? status,
    String? resourceType,
    String? resourceId,
    String? category,
    String? tags,
    int? maxSize,
    int? maxAge,
    int? maxEntries,
    String? evictionPolicy,
    bool? enableCompression,
    bool? enableEncryption,
    String? encryptionKey,
    String? compressionAlgorithm,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? lastUsedDate,
    int? hitCount,
    int? missCount,
    double? hitRate,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CacheConfig(
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
      maxSize: maxSize ?? this.maxSize,
      maxAge: maxAge ?? this.maxAge,
      maxEntries: maxEntries ?? this.maxEntries,
      evictionPolicy: evictionPolicy ?? this.evictionPolicy,
      enableCompression: enableCompression ?? this.enableCompression,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      compressionAlgorithm: compressionAlgorithm ?? this.compressionAlgorithm,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      hitCount: hitCount ?? this.hitCount,
      missCount: missCount ?? this.missCount,
      hitRate: hitRate ?? this.hitRate,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan CacheConfig oluştur
  factory CacheConfig.fromJson(Map<String, dynamic> json) {
    return CacheConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      type: CacheType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CacheType.memory,
      ),
      status: CacheStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CacheStatus.active,
      ),
      resourceType: json['resourceType'] as String?,
      resourceId: json['resourceId'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      maxSize: json['maxSize'] as int?,
      maxAge: json['maxAge'] as int?,
      maxEntries: json['maxEntries'] as int?,
      evictionPolicy: json['evictionPolicy'] as String?,
      enableCompression: json['enableCompression'] as bool?,
      enableEncryption: json['enableEncryption'] as bool?,
      encryptionKey: json['encryptionKey'] as String?,
      compressionAlgorithm: json['compressionAlgorithm'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      lastUsedDate: json['lastUsedDate'] != null
          ? DateTime.parse(json['lastUsedDate'] as String)
          : null,
      hitCount: json['hitCount'] as int?,
      missCount: json['missCount'] as int?,
      hitRate:
          json['hitRate'] != null ? (json['hitRate'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// CacheConfig'ı JSON'a çevir
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
      'maxSize': maxSize,
      'maxAge': maxAge,
      'maxEntries': maxEntries,
      'evictionPolicy': evictionPolicy,
      'enableCompression': enableCompression,
      'enableEncryption': enableEncryption,
      'encryptionKey': encryptionKey,
      'compressionAlgorithm': compressionAlgorithm,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'lastUsedDate': lastUsedDate?.toIso8601String(),
      'hitCount': hitCount,
      'missCount': missCount,
      'hitRate': hitRate,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Bellek cache mi?
  bool get isMemoryCache => type == CacheType.memory;

  /// Disk cache mi?
  bool get isDiskCache => type == CacheType.disk;

  /// Ağ cache mi?
  bool get isNetworkCache => type == CacheType.network;

  /// Hibrit cache mi?
  bool get isHybridCache => type == CacheType.hybrid;

  /// Aktif mi?
  bool get isActive => status == CacheStatus.active;

  /// Pasif mi?
  bool get isInactive => status == CacheStatus.inactive;

  /// Askıya alındı mı?
  bool get isSuspended => status == CacheStatus.suspended;

  /// Silindi mi?
  bool get isDeleted => status == CacheStatus.deleted;

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

  /// Maksimum boyut var mı?
  bool get hasMaxSize => maxSize != null && maxSize! > 0;

  /// Maksimum yaş var mı?
  bool get hasMaxAge => maxAge != null && maxAge! > 0;

  /// Maksimum giriş sayısı var mı?
  bool get hasMaxEntries => maxEntries != null && maxEntries! > 0;

  /// Çıkarma politikası var mı?
  bool get hasEvictionPolicy =>
      evictionPolicy != null && evictionPolicy!.isNotEmpty;

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

  /// Son kullanım tarihi var mı?
  bool get hasLastUsedDate => lastUsedDate != null;

  /// İsabet sayısı var mı?
  bool get hasHitCount => hitCount != null && hitCount! > 0;

  /// Kaçırma sayısı var mı?
  bool get hasMissCount => missCount != null && missCount! > 0;

  /// İsabet oranı var mı?
  bool get hasHitRate => hitRate != null && hitRate! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return isActive && !isDeleted;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isActive && (hitCount == null || hitCount == 0);
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
    return isActive && hasMaxSize;
  }

  /// Güvenli mi?
  bool get isSecure {
    return isActive &&
        (isEncryptionEnabled || isCompressionEnabled) &&
        hasEncryptionKey;
  }

  /// Performanslı mı?
  bool get isPerformant {
    return isActive && hasHitRate && hitRate! > 0.8;
  }

  /// İsabet sayısı sıfır mı?
  bool get isZeroHitCount => hitCount == null || hitCount == 0;

  /// İsabet sayısı yüksek mi? (1000'den fazla)
  bool get isHighHitCount => hitCount != null && hitCount! > 1000;

  /// İsabet sayısı düşük mi? (10'dan az)
  bool get isLowHitCount => hitCount != null && hitCount! < 10;

  /// İsabet sayısı orta mı? (10-1000 arası)
  bool get isMediumHitCount =>
      hitCount != null && hitCount! >= 10 && hitCount! <= 1000;

  /// İsabet sayısı kategorisi
  String get hitCountCategory {
    if (isHighHitCount) return 'Yüksek';
    if (isLowHitCount) return 'Düşük';
    return 'Orta';
  }

  /// İsabet oranı yüksek mi? (%80'den fazla)
  bool get isHighHitRate => hitRate != null && hitRate! > 0.8;

  /// İsabet oranı düşük mi? (%20'den az)
  bool get isLowHitRate => hitRate != null && hitRate! < 0.2;

  /// İsabet oranı orta mı? (%20-80 arası)
  bool get isMediumHitRate =>
      hitRate != null && hitRate! >= 0.2 && hitRate! <= 0.8;

  /// İsabet oranı kategorisi
  String get hitRateCategory {
    if (isHighHitRate) return 'Yüksek';
    if (isLowHitRate) return 'Düşük';
    return 'Orta';
  }

  /// Son kullanım süresi (gün)
  int? get lastUsedDays {
    if (lastUsedDate == null) return null;
    return DateTime.now().difference(lastUsedDate!).inDays;
  }

  /// Son kullanım süresi uzun mu? (30 günden fazla)
  bool get isLastUsedLongAgo {
    final days = lastUsedDays;
    return days != null && days > 30;
  }

  /// Son kullanım süresi kısa mı? (7 günden az)
  bool get isLastUsedRecently {
    final days = lastUsedDays;
    return days != null && days < 7;
  }

  /// Son kullanım süresi orta mı? (7-30 gün arası)
  bool get isLastUsedMedium {
    final days = lastUsedDays;
    return days != null && days >= 7 && days <= 30;
  }

  /// Son kullanım süresi kategorisi
  String get lastUsedCategory {
    if (isLastUsedLongAgo) return 'Uzun';
    if (isLastUsedRecently) return 'Kısa';
    return 'Orta';
  }

  /// Toplam istek sayısı
  int? get totalRequests {
    if (hitCount == null || missCount == null) return null;
    return hitCount! + missCount!;
  }

  /// Kaçırma oranı
  double? get missRate {
    final total = totalRequests;
    if (total == null || total == 0) return null;
    if (missCount == null) return 0;
    return (missCount! / total) * 100;
  }

  /// Kaçırma oranı yüksek mi? (%50'den fazla)
  bool get isHighMissRate {
    final rate = missRate;
    return rate != null && rate > 50;
  }

  /// Kaçırma oranı düşük mi? (%20'den az)
  bool get isLowMissRate {
    final rate = missRate;
    return rate != null && rate < 20;
  }

  /// Kaçırma oranı orta mı? (%20-50 arası)
  bool get isMediumMissRate {
    final rate = missRate;
    return rate != null && rate >= 20 && rate <= 50;
  }

  /// Kaçırma oranı kategorisi
  String get missRateCategory {
    if (isHighMissRate) return 'Yüksek';
    if (isLowMissRate) return 'Düşük';
    return 'Orta';
  }

  @override
  String toString() {
    return 'CacheConfig(id: $id, name: $name, type: $type, status: $status, hitRate: $hitRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
