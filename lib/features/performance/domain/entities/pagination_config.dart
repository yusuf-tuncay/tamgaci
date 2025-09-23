// ========== PAGINATION CONFIG ENTITY ==========
// lib/features/performance/domain/entities/pagination_config.dart

/// Sayfalama türü
enum PaginationType {
  offset('Offset'),
  cursor('Cursor'),
  keyset('Keyset'),
  infinite('Sonsuz');

  const PaginationType(this.displayName);
  final String displayName;
}

/// Sayfalama durumu
enum PaginationStatus {
  active('Aktif'),
  inactive('Pasif'),
  suspended('Askıya Alındı'),
  deleted('Silindi');

  const PaginationStatus(this.displayName);
  final String displayName;
}

/// Sayfalama konfigürasyonu entity'si
class PaginationConfig {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final PaginationType type;
  final PaginationStatus status;
  final String? resourceType; // Kaynak türü
  final String? resourceId; // Kaynak ID'si
  final String? category; // Kategori
  final String? tags; // Etiketler
  final int? defaultPageSize; // Varsayılan sayfa boyutu
  final int? maxPageSize; // Maksimum sayfa boyutu
  final int? minPageSize; // Minimum sayfa boyutu
  final List<int>? allowedPageSizes; // İzin verilen sayfa boyutları
  final bool? enableInfiniteScroll; // Sonsuz kaydırma etkin mi?
  final bool? enableVirtualScrolling; // Sanal kaydırma etkin mi?
  final bool? enablePrefetching; // Önceden yükleme etkin mi?
  final int? prefetchThreshold; // Önceden yükleme eşiği
  final String? sortField; // Sıralama alanı
  final String? sortDirection; // Sıralama yönü
  final String? filterField; // Filtre alanı
  final String? filterValue; // Filtre değeri
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? lastUsedDate; // Son kullanım tarihi
  final int? usageCount; // Kullanım sayısı
  final double? averageLoadTime; // Ortalama yükleme süresi (ms)
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaginationConfig({
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
    this.defaultPageSize,
    this.maxPageSize,
    this.minPageSize,
    this.allowedPageSizes,
    this.enableInfiniteScroll,
    this.enableVirtualScrolling,
    this.enablePrefetching,
    this.prefetchThreshold,
    this.sortField,
    this.sortDirection,
    this.filterField,
    this.filterValue,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.lastUsedDate,
    this.usageCount,
    this.averageLoadTime,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  PaginationConfig copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    PaginationType? type,
    PaginationStatus? status,
    String? resourceType,
    String? resourceId,
    String? category,
    String? tags,
    int? defaultPageSize,
    int? maxPageSize,
    int? minPageSize,
    List<int>? allowedPageSizes,
    bool? enableInfiniteScroll,
    bool? enableVirtualScrolling,
    bool? enablePrefetching,
    int? prefetchThreshold,
    String? sortField,
    String? sortDirection,
    String? filterField,
    String? filterValue,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? lastUsedDate,
    int? usageCount,
    double? averageLoadTime,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaginationConfig(
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
      defaultPageSize: defaultPageSize ?? this.defaultPageSize,
      maxPageSize: maxPageSize ?? this.maxPageSize,
      minPageSize: minPageSize ?? this.minPageSize,
      allowedPageSizes: allowedPageSizes ?? this.allowedPageSizes,
      enableInfiniteScroll: enableInfiniteScroll ?? this.enableInfiniteScroll,
      enableVirtualScrolling:
          enableVirtualScrolling ?? this.enableVirtualScrolling,
      enablePrefetching: enablePrefetching ?? this.enablePrefetching,
      prefetchThreshold: prefetchThreshold ?? this.prefetchThreshold,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
      filterField: filterField ?? this.filterField,
      filterValue: filterValue ?? this.filterValue,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      usageCount: usageCount ?? this.usageCount,
      averageLoadTime: averageLoadTime ?? this.averageLoadTime,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan PaginationConfig oluştur
  factory PaginationConfig.fromJson(Map<String, dynamic> json) {
    return PaginationConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      type: PaginationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaginationType.offset,
      ),
      status: PaginationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaginationStatus.active,
      ),
      resourceType: json['resourceType'] as String?,
      resourceId: json['resourceId'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      defaultPageSize: json['defaultPageSize'] as int?,
      maxPageSize: json['maxPageSize'] as int?,
      minPageSize: json['minPageSize'] as int?,
      allowedPageSizes: json['allowedPageSizes'] != null
          ? List<int>.from(json['allowedPageSizes'] as List)
          : null,
      enableInfiniteScroll: json['enableInfiniteScroll'] as bool?,
      enableVirtualScrolling: json['enableVirtualScrolling'] as bool?,
      enablePrefetching: json['enablePrefetching'] as bool?,
      prefetchThreshold: json['prefetchThreshold'] as int?,
      sortField: json['sortField'] as String?,
      sortDirection: json['sortDirection'] as String?,
      filterField: json['filterField'] as String?,
      filterValue: json['filterValue'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      lastUsedDate: json['lastUsedDate'] != null
          ? DateTime.parse(json['lastUsedDate'] as String)
          : null,
      usageCount: json['usageCount'] as int?,
      averageLoadTime: json['averageLoadTime'] != null
          ? (json['averageLoadTime'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// PaginationConfig'ı JSON'a çevir
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
      'defaultPageSize': defaultPageSize,
      'maxPageSize': maxPageSize,
      'minPageSize': minPageSize,
      'allowedPageSizes': allowedPageSizes,
      'enableInfiniteScroll': enableInfiniteScroll,
      'enableVirtualScrolling': enableVirtualScrolling,
      'enablePrefetching': enablePrefetching,
      'prefetchThreshold': prefetchThreshold,
      'sortField': sortField,
      'sortDirection': sortDirection,
      'filterField': filterField,
      'filterValue': filterValue,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'lastUsedDate': lastUsedDate?.toIso8601String(),
      'usageCount': usageCount,
      'averageLoadTime': averageLoadTime,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Offset sayfalama mı?
  bool get isOffsetPagination => type == PaginationType.offset;

  /// Cursor sayfalama mı?
  bool get isCursorPagination => type == PaginationType.cursor;

  /// Keyset sayfalama mı?
  bool get isKeysetPagination => type == PaginationType.keyset;

  /// Sonsuz sayfalama mı?
  bool get isInfinitePagination => type == PaginationType.infinite;

  /// Aktif mi?
  bool get isActive => status == PaginationStatus.active;

  /// Pasif mi?
  bool get isInactive => status == PaginationStatus.inactive;

  /// Askıya alındı mı?
  bool get isSuspended => status == PaginationStatus.suspended;

  /// Silindi mi?
  bool get isDeleted => status == PaginationStatus.deleted;

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

  /// Varsayılan sayfa boyutu var mı?
  bool get hasDefaultPageSize =>
      defaultPageSize != null && defaultPageSize! > 0;

  /// Maksimum sayfa boyutu var mı?
  bool get hasMaxPageSize => maxPageSize != null && maxPageSize! > 0;

  /// Minimum sayfa boyutu var mı?
  bool get hasMinPageSize => minPageSize != null && minPageSize! > 0;

  /// İzin verilen sayfa boyutları var mı?
  bool get hasAllowedPageSizes =>
      allowedPageSizes != null && allowedPageSizes!.isNotEmpty;

  /// Sonsuz kaydırma etkin mi?
  bool get isInfiniteScrollEnabled => enableInfiniteScroll == true;

  /// Sanal kaydırma etkin mi?
  bool get isVirtualScrollingEnabled => enableVirtualScrolling == true;

  /// Önceden yükleme etkin mi?
  bool get isPrefetchingEnabled => enablePrefetching == true;

  /// Önceden yükleme eşiği var mı?
  bool get hasPrefetchThreshold =>
      prefetchThreshold != null && prefetchThreshold! > 0;

  /// Sıralama alanı var mı?
  bool get hasSortField => sortField != null && sortField!.isNotEmpty;

  /// Sıralama yönü var mı?
  bool get hasSortDirection =>
      sortDirection != null && sortDirection!.isNotEmpty;

  /// Filtre alanı var mı?
  bool get hasFilterField => filterField != null && filterField!.isNotEmpty;

  /// Filtre değeri var mı?
  bool get hasFilterValue => filterValue != null && filterValue!.isNotEmpty;

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

  /// Kullanım sayısı var mı?
  bool get hasUsageCount => usageCount != null && usageCount! > 0;

  /// Ortalama yükleme süresi var mı?
  bool get hasAverageLoadTime =>
      averageLoadTime != null && averageLoadTime! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return isActive && !isDeleted;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isActive && (usageCount == null || usageCount == 0);
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
    return isActive && hasDefaultPageSize;
  }

  /// Performanslı mı?
  bool get isPerformant {
    return isActive && hasAverageLoadTime && averageLoadTime! < 1000;
  }

  /// Kullanım sayısı sıfır mı?
  bool get isZeroUsageCount => usageCount == null || usageCount == 0;

  /// Kullanım sayısı yüksek mi? (1000'den fazla)
  bool get isHighUsageCount => usageCount != null && usageCount! > 1000;

  /// Kullanım sayısı düşük mi? (10'dan az)
  bool get isLowUsageCount => usageCount != null && usageCount! < 10;

  /// Kullanım sayısı orta mı? (10-1000 arası)
  bool get isMediumUsageCount =>
      usageCount != null && usageCount! >= 10 && usageCount! <= 1000;

  /// Kullanım sayısı kategorisi
  String get usageCountCategory {
    if (isHighUsageCount) return 'Yüksek';
    if (isLowUsageCount) return 'Düşük';
    return 'Orta';
  }

  /// Ortalama yükleme süresi hızlı mı? (500ms'den az)
  bool get isFastLoadTime => averageLoadTime != null && averageLoadTime! < 500;

  /// Ortalama yükleme süresi yavaş mı? (2000ms'den fazla)
  bool get isSlowLoadTime => averageLoadTime != null && averageLoadTime! > 2000;

  /// Ortalama yükleme süresi orta mı? (500-2000ms arası)
  bool get isMediumLoadTime =>
      averageLoadTime != null &&
      averageLoadTime! >= 500 &&
      averageLoadTime! <= 2000;

  /// Ortalama yükleme süresi kategorisi
  String get loadTimeCategory {
    if (isFastLoadTime) return 'Hızlı';
    if (isSlowLoadTime) return 'Yavaş';
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

  /// Toplam izin verilen sayfa boyutu sayısı
  int get totalAllowedPageSizesCount => allowedPageSizes?.length ?? 0;

  /// Belirli sayfa boyutuna izin veriliyor mu?
  bool isPageSizeAllowed(int pageSize) {
    if (allowedPageSizes == null) return true;
    return allowedPageSizes!.contains(pageSize);
  }

  /// Sayfa boyutu geçerli mi?
  bool isPageSizeValid(int pageSize) {
    if (hasMinPageSize && pageSize < minPageSize!) return false;
    if (hasMaxPageSize && pageSize > maxPageSize!) return false;
    if (hasAllowedPageSizes && !isPageSizeAllowed(pageSize)) return false;
    return true;
  }

  /// Sıralama bilgisi var mı?
  bool get hasSortingInfo => hasSortField && hasSortDirection;

  /// Filtre bilgisi var mı?
  bool get hasFilteringInfo => hasFilterField && hasFilterValue;

  /// Gelişmiş özellikler etkin mi?
  bool get hasAdvancedFeatures {
    return isInfiniteScrollEnabled ||
        isVirtualScrollingEnabled ||
        isPrefetchingEnabled;
  }

  @override
  String toString() {
    return 'PaginationConfig(id: $id, name: $name, type: $type, status: $status, defaultPageSize: $defaultPageSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
