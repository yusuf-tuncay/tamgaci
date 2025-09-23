// ========== DATA MASKING ENTITY ==========
// lib/features/security/domain/entities/data_masking.dart

/// Veri maskeleme türü
enum DataMaskingType {
  full('Tam Maskeleme'),
  partial('Kısmi Maskeleme'),
  hash('Hash Maskeleme'),
  encryption('Şifreleme'),
  tokenization('Tokenizasyon'),
  anonymization('Anonimleştirme');

  const DataMaskingType(this.displayName);
  final String displayName;
}

/// Veri maskeleme durumu
enum DataMaskingStatus {
  active('Aktif'),
  inactive('Pasif'),
  suspended('Askıya Alındı'),
  deleted('Silindi');

  const DataMaskingStatus(this.displayName);
  final String displayName;
}

/// Veri maskeleme entity'si
class DataMasking {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final DataMaskingType type;
  final DataMaskingStatus status;
  final String? resourceType; // Kaynak türü
  final String? fieldName; // Alan adı
  final String? fieldType; // Alan türü
  final String? category; // Kategori
  final String? tags; // Etiketler
  final String? maskPattern; // Maskeleme deseni
  final String? maskCharacter; // Maskeleme karakteri
  final int? visibleStart; // Görünür başlangıç
  final int? visibleEnd; // Görünür bitiş
  final String? encryptionKey; // Şifreleme anahtarı
  final String? hashAlgorithm; // Hash algoritması
  final String? tokenPrefix; // Token öneki
  final String? tokenSuffix; // Token soneki
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? lastUsedDate; // Son kullanım tarihi
  final int? usageCount; // Kullanım sayısı
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const DataMasking({
    required this.id,
    required this.name,
    this.displayName,
    this.description,
    required this.type,
    required this.status,
    this.resourceType,
    this.fieldName,
    this.fieldType,
    this.category,
    this.tags,
    this.maskPattern,
    this.maskCharacter,
    this.visibleStart,
    this.visibleEnd,
    this.encryptionKey,
    this.hashAlgorithm,
    this.tokenPrefix,
    this.tokenSuffix,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.lastUsedDate,
    this.usageCount,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  DataMasking copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    DataMaskingType? type,
    DataMaskingStatus? status,
    String? resourceType,
    String? fieldName,
    String? fieldType,
    String? category,
    String? tags,
    String? maskPattern,
    String? maskCharacter,
    int? visibleStart,
    int? visibleEnd,
    String? encryptionKey,
    String? hashAlgorithm,
    String? tokenPrefix,
    String? tokenSuffix,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? lastUsedDate,
    int? usageCount,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataMasking(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      resourceType: resourceType ?? this.resourceType,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      maskPattern: maskPattern ?? this.maskPattern,
      maskCharacter: maskCharacter ?? this.maskCharacter,
      visibleStart: visibleStart ?? this.visibleStart,
      visibleEnd: visibleEnd ?? this.visibleEnd,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      hashAlgorithm: hashAlgorithm ?? this.hashAlgorithm,
      tokenPrefix: tokenPrefix ?? this.tokenPrefix,
      tokenSuffix: tokenSuffix ?? this.tokenSuffix,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      usageCount: usageCount ?? this.usageCount,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan DataMasking oluştur
  factory DataMasking.fromJson(Map<String, dynamic> json) {
    return DataMasking(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      type: DataMaskingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DataMaskingType.partial,
      ),
      status: DataMaskingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DataMaskingStatus.active,
      ),
      resourceType: json['resourceType'] as String?,
      fieldName: json['fieldName'] as String?,
      fieldType: json['fieldType'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      maskPattern: json['maskPattern'] as String?,
      maskCharacter: json['maskCharacter'] as String?,
      visibleStart: json['visibleStart'] as int?,
      visibleEnd: json['visibleEnd'] as int?,
      encryptionKey: json['encryptionKey'] as String?,
      hashAlgorithm: json['hashAlgorithm'] as String?,
      tokenPrefix: json['tokenPrefix'] as String?,
      tokenSuffix: json['tokenSuffix'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      lastUsedDate: json['lastUsedDate'] != null
          ? DateTime.parse(json['lastUsedDate'] as String)
          : null,
      usageCount: json['usageCount'] as int?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// DataMasking'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'type': type.name,
      'status': status.name,
      'resourceType': resourceType,
      'fieldName': fieldName,
      'fieldType': fieldType,
      'category': category,
      'tags': tags,
      'maskPattern': maskPattern,
      'maskCharacter': maskCharacter,
      'visibleStart': visibleStart,
      'visibleEnd': visibleEnd,
      'encryptionKey': encryptionKey,
      'hashAlgorithm': hashAlgorithm,
      'tokenPrefix': tokenPrefix,
      'tokenSuffix': tokenSuffix,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'lastUsedDate': lastUsedDate?.toIso8601String(),
      'usageCount': usageCount,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Tam maskeleme mi?
  bool get isFullMasking => type == DataMaskingType.full;

  /// Kısmi maskeleme mi?
  bool get isPartialMasking => type == DataMaskingType.partial;

  /// Hash maskeleme mi?
  bool get isHashMasking => type == DataMaskingType.hash;

  /// Şifreleme mi?
  bool get isEncryption => type == DataMaskingType.encryption;

  /// Tokenizasyon mu?
  bool get isTokenization => type == DataMaskingType.tokenization;

  /// Anonimleştirme mi?
  bool get isAnonymization => type == DataMaskingType.anonymization;

  /// Aktif mi?
  bool get isActive => status == DataMaskingStatus.active;

  /// Pasif mi?
  bool get isInactive => status == DataMaskingStatus.inactive;

  /// Askıya alındı mı?
  bool get isSuspended => status == DataMaskingStatus.suspended;

  /// Silindi mi?
  bool get isDeleted => status == DataMaskingStatus.deleted;

  /// Görünen ad var mı?
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Kaynak türü var mı?
  bool get hasResourceType => resourceType != null && resourceType!.isNotEmpty;

  /// Alan adı var mı?
  bool get hasFieldName => fieldName != null && fieldName!.isNotEmpty;

  /// Alan türü var mı?
  bool get hasFieldType => fieldType != null && fieldType!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Maskeleme deseni var mı?
  bool get hasMaskPattern => maskPattern != null && maskPattern!.isNotEmpty;

  /// Maskeleme karakteri var mı?
  bool get hasMaskCharacter =>
      maskCharacter != null && maskCharacter!.isNotEmpty;

  /// Görünür başlangıç var mı?
  bool get hasVisibleStart => visibleStart != null && visibleStart! >= 0;

  /// Görünür bitiş var mı?
  bool get hasVisibleEnd => visibleEnd != null && visibleEnd! >= 0;

  /// Şifreleme anahtarı var mı?
  bool get hasEncryptionKey =>
      encryptionKey != null && encryptionKey!.isNotEmpty;

  /// Hash algoritması var mı?
  bool get hasHashAlgorithm =>
      hashAlgorithm != null && hashAlgorithm!.isNotEmpty;

  /// Token öneki var mı?
  bool get hasTokenPrefix => tokenPrefix != null && tokenPrefix!.isNotEmpty;

  /// Token soneki var mı?
  bool get hasTokenSuffix => tokenSuffix != null && tokenSuffix!.isNotEmpty;

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
    return isActive && hasMaskPattern;
  }

  /// Güvenli mi?
  bool get isSecure {
    return isActive &&
        (isEncryption || isHashMasking || isTokenization || isAnonymization);
  }

  /// Riskli mi?
  bool get isRisky {
    return isActive && (isFullMasking || isPartialMasking) && !hasMaskPattern;
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

  /// Görünür karakter sayısı
  int? get visibleCharacterCount {
    if (visibleStart == null || visibleEnd == null) return null;
    return visibleEnd! - visibleStart!;
  }

  /// Görünür karakter yüzdesi
  double? get visibleCharacterPercentage {
    if (visibleCharacterCount == null) return null;
    return (visibleCharacterCount! / 100) * 100;
  }

  /// Yüksek görünürlük mi? (%50'den fazla)
  bool get isHighVisibility {
    final percentage = visibleCharacterPercentage;
    return percentage != null && percentage > 50;
  }

  /// Düşük görünürlük mi? (%20'den az)
  bool get isLowVisibility {
    final percentage = visibleCharacterPercentage;
    return percentage != null && percentage < 20;
  }

  /// Orta görünürlük mi? (%20-50 arası)
  bool get isMediumVisibility {
    final percentage = visibleCharacterPercentage;
    return percentage != null && percentage >= 20 && percentage <= 50;
  }

  /// Görünürlük kategorisi
  String get visibilityCategory {
    if (isHighVisibility) return 'Yüksek';
    if (isLowVisibility) return 'Düşük';
    return 'Orta';
  }

  @override
  String toString() {
    return 'DataMasking(id: $id, name: $name, type: $type, status: $status, resourceType: $resourceType, fieldName: $fieldName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataMasking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
