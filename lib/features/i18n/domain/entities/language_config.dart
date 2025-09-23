// ========== LANGUAGE CONFIG ENTITY ==========
// lib/features/i18n/domain/entities/language_config.dart

/// Dil türü
enum LanguageType {
  system('Sistem Dili'),
  user('Kullanıcı Dili'),
  content('İçerik Dili'),
  custom('Özel Dil');

  const LanguageType(this.displayName);
  final String displayName;
}

/// Dil durumu
enum LanguageStatus {
  active('Aktif'),
  inactive('Pasif'),
  deprecated('Kullanımdan Kaldırıldı'),
  deleted('Silindi');

  const LanguageStatus(this.displayName);
  final String displayName;
}

/// Dil konfigürasyonu entity'si
class LanguageConfig {
  final String id;
  final String languageCode; // ISO 639-1 kod (tr, en, de, etc.)
  final String? languageName; // Dil adı (Türkçe, English, Deutsch)
  final String? nativeName; // Yerel dil adı (Türkçe, English, Deutsch)
  final String? displayName; // Görünen ad
  final String? description; // Açıklama
  final LanguageType type;
  final LanguageStatus status;
  final String? regionCode; // Bölge kodu (TR, US, DE, etc.)
  final String? script; // Yazı sistemi (Latn, Cyrl, Arab, etc.)
  final String? direction; // Yazı yönü (ltr, rtl)
  final String? category; // Kategori
  final String? tags; // Etiketler
  final bool? isRtl; // Sağdan sola mı?
  final bool? isDefault; // Varsayılan dil mi?
  final bool? isSystemLanguage; // Sistem dili mi?
  final bool? isUserLanguage; // Kullanıcı dili mi?
  final bool? isContentLanguage; // İçerik dili mi?
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? lastUsedDate; // Son kullanım tarihi
  final int? usageCount; // Kullanım sayısı
  final int? translationCount; // Çeviri sayısı
  final double? translationProgress; // Çeviri ilerlemesi (%)
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const LanguageConfig({
    required this.id,
    required this.languageCode,
    this.languageName,
    this.nativeName,
    this.displayName,
    this.description,
    required this.type,
    required this.status,
    this.regionCode,
    this.script,
    this.direction,
    this.category,
    this.tags,
    this.isRtl,
    this.isDefault,
    this.isSystemLanguage,
    this.isUserLanguage,
    this.isContentLanguage,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.lastUsedDate,
    this.usageCount,
    this.translationCount,
    this.translationProgress,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  LanguageConfig copyWith({
    String? id,
    String? languageCode,
    String? languageName,
    String? nativeName,
    String? displayName,
    String? description,
    LanguageType? type,
    LanguageStatus? status,
    String? regionCode,
    String? script,
    String? direction,
    String? category,
    String? tags,
    bool? isRtl,
    bool? isDefault,
    bool? isSystemLanguage,
    bool? isUserLanguage,
    bool? isContentLanguage,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? lastUsedDate,
    int? usageCount,
    int? translationCount,
    double? translationProgress,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LanguageConfig(
      id: id ?? this.id,
      languageCode: languageCode ?? this.languageCode,
      languageName: languageName ?? this.languageName,
      nativeName: nativeName ?? this.nativeName,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      regionCode: regionCode ?? this.regionCode,
      script: script ?? this.script,
      direction: direction ?? this.direction,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isRtl: isRtl ?? this.isRtl,
      isDefault: isDefault ?? this.isDefault,
      isSystemLanguage: isSystemLanguage ?? this.isSystemLanguage,
      isUserLanguage: isUserLanguage ?? this.isUserLanguage,
      isContentLanguage: isContentLanguage ?? this.isContentLanguage,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      usageCount: usageCount ?? this.usageCount,
      translationCount: translationCount ?? this.translationCount,
      translationProgress: translationProgress ?? this.translationProgress,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan LanguageConfig oluştur
  factory LanguageConfig.fromJson(Map<String, dynamic> json) {
    return LanguageConfig(
      id: json['id'] as String,
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String?,
      nativeName: json['nativeName'] as String?,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      type: LanguageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LanguageType.user,
      ),
      status: LanguageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LanguageStatus.active,
      ),
      regionCode: json['regionCode'] as String?,
      script: json['script'] as String?,
      direction: json['direction'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      isRtl: json['isRtl'] as bool?,
      isDefault: json['isDefault'] as bool?,
      isSystemLanguage: json['isSystemLanguage'] as bool?,
      isUserLanguage: json['isUserLanguage'] as bool?,
      isContentLanguage: json['isContentLanguage'] as bool?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      lastUsedDate: json['lastUsedDate'] != null
          ? DateTime.parse(json['lastUsedDate'] as String)
          : null,
      usageCount: json['usageCount'] as int?,
      translationCount: json['translationCount'] as int?,
      translationProgress: json['translationProgress'] != null
          ? (json['translationProgress'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// LanguageConfig'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageCode': languageCode,
      'languageName': languageName,
      'nativeName': nativeName,
      'displayName': displayName,
      'description': description,
      'type': type.name,
      'status': status.name,
      'regionCode': regionCode,
      'script': script,
      'direction': direction,
      'category': category,
      'tags': tags,
      'isRtl': isRtl,
      'isDefault': isDefault,
      'isSystemLanguage': isSystemLanguage,
      'isUserLanguage': isUserLanguage,
      'isContentLanguage': isContentLanguage,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'lastUsedDate': lastUsedDate?.toIso8601String(),
      'usageCount': usageCount,
      'translationCount': translationCount,
      'translationProgress': translationProgress,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Sistem dili mi?
  bool get isSystemLanguageType => type == LanguageType.system;

  /// Kullanıcı dili mi?
  bool get isUserLanguageType => type == LanguageType.user;

  /// İçerik dili mi?
  bool get isContentLanguageType => type == LanguageType.content;

  /// Özel dil mi?
  bool get isCustomLanguageType => type == LanguageType.custom;

  /// Aktif mi?
  bool get isActive => status == LanguageStatus.active;

  /// Pasif mi?
  bool get isInactive => status == LanguageStatus.inactive;

  /// Kullanımdan kaldırıldı mı?
  bool get isDeprecated => status == LanguageStatus.deprecated;

  /// Silindi mi?
  bool get isDeleted => status == LanguageStatus.deleted;

  /// Dil adı var mı?
  bool get hasLanguageName => languageName != null && languageName!.isNotEmpty;

  /// Yerel dil adı var mı?
  bool get hasNativeName => nativeName != null && nativeName!.isNotEmpty;

  /// Görünen ad var mı?
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Bölge kodu var mı?
  bool get hasRegionCode => regionCode != null && regionCode!.isNotEmpty;

  /// Yazı sistemi var mı?
  bool get hasScript => script != null && script!.isNotEmpty;

  /// Yazı yönü var mı?
  bool get hasDirection => direction != null && direction!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Sağdan sola mı?
  bool get isRightToLeft => isRtl == true;

  /// Soldan sağa mı?
  bool get isLeftToRight => isRtl == false;

  /// Varsayılan dil mi?
  bool get isDefaultLanguage => isDefault == true;

  /// Sistem dili mi?
  bool get isSystemLanguageFlag => isSystemLanguage == true;

  /// Kullanıcı dili mi?
  bool get isUserLanguageFlag => isUserLanguage == true;

  /// İçerik dili mi?
  bool get isContentLanguageFlag => isContentLanguage == true;

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

  /// Çeviri sayısı var mı?
  bool get hasTranslationCount =>
      translationCount != null && translationCount! > 0;

  /// Çeviri ilerlemesi var mı?
  bool get hasTranslationProgress =>
      translationProgress != null && translationProgress! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return isActive && !isDeleted;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isActive &&
        !isDefaultLanguage &&
        (usageCount == null || usageCount == 0);
  }

  /// Askıya alınabilir mi?
  bool get canBeSuspended {
    return isActive && !isDefaultLanguage;
  }

  /// Aktifleştirilebilir mi?
  bool get canBeActivated {
    return isInactive || isDeprecated;
  }

  /// Kullanılabilir mi?
  bool get canBeUsed {
    return isActive && hasLanguageName;
  }

  /// Varsayılan yapılabilir mi?
  bool get canBeSetAsDefault {
    return isActive && !isDefaultLanguage;
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

  /// Çeviri sayısı sıfır mı?
  bool get isZeroTranslationCount =>
      translationCount == null || translationCount == 0;

  /// Çeviri sayısı yüksek mi? (1000'den fazla)
  bool get isHighTranslationCount =>
      translationCount != null && translationCount! > 1000;

  /// Çeviri sayısı düşük mi? (10'dan az)
  bool get isLowTranslationCount =>
      translationCount != null && translationCount! < 10;

  /// Çeviri sayısı orta mı? (10-1000 arası)
  bool get isMediumTranslationCount =>
      translationCount != null &&
      translationCount! >= 10 &&
      translationCount! <= 1000;

  /// Çeviri sayısı kategorisi
  String get translationCountCategory {
    if (isHighTranslationCount) return 'Yüksek';
    if (isLowTranslationCount) return 'Düşük';
    return 'Orta';
  }

  /// Çeviri ilerlemesi yüksek mi? (%80'den fazla)
  bool get isHighTranslationProgress =>
      translationProgress != null && translationProgress! > 80;

  /// Çeviri ilerlemesi düşük mi? (%20'den az)
  bool get isLowTranslationProgress =>
      translationProgress != null && translationProgress! < 20;

  /// Çeviri ilerlemesi orta mı? (%20-80 arası)
  bool get isMediumTranslationProgress =>
      translationProgress != null &&
      translationProgress! >= 20 &&
      translationProgress! <= 80;

  /// Çeviri ilerlemesi kategorisi
  String get translationProgressCategory {
    if (isHighTranslationProgress) return 'Yüksek';
    if (isLowTranslationProgress) return 'Düşük';
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

  /// Tam dil kodu (languageCode + regionCode)
  String get fullLanguageCode {
    if (hasRegionCode) {
      return '$languageCode-$regionCode';
    }
    return languageCode;
  }

  /// Görünen dil adı
  String get effectiveDisplayName {
    if (hasDisplayName) return displayName!;
    if (hasNativeName) return nativeName!;
    if (hasLanguageName) return languageName!;
    return languageCode.toUpperCase();
  }

  /// Görünen dil adı (yerel)
  String get effectiveNativeName {
    if (hasNativeName) return nativeName!;
    if (hasLanguageName) return languageName!;
    return languageCode.toUpperCase();
  }

  /// Yazı yönü
  String get effectiveDirection {
    if (hasDirection) return direction!;
    return isRightToLeft ? 'rtl' : 'ltr';
  }

  /// Yazı sistemi
  String get effectiveScript {
    if (hasScript) return script!;
    return 'Latn'; // Varsayılan Latin
  }

  /// Çeviri tamamlandı mı?
  bool get isTranslationComplete {
    return hasTranslationProgress && translationProgress! >= 100;
  }

  /// Çeviri devam ediyor mu?
  bool get isTranslationInProgress {
    return hasTranslationProgress &&
        translationProgress! > 0 &&
        translationProgress! < 100;
  }

  /// Çeviri başlamadı mı?
  bool get isTranslationNotStarted {
    return !hasTranslationProgress || translationProgress == 0;
  }

  /// Çeviri durumu kategorisi
  String get translationStatusCategory {
    if (isTranslationComplete) return 'Tamamlandı';
    if (isTranslationInProgress) return 'Devam Ediyor';
    return 'Başlamadı';
  }

  /// Popüler dil mi?
  bool get isPopularLanguage {
    return isHighUsageCount || isDefaultLanguage;
  }

  /// Az kullanılan dil mi?
  bool get isUnpopularLanguage {
    return isLowUsageCount && !isDefaultLanguage;
  }

  /// Orta kullanılan dil mi?
  bool get isMediumPopularLanguage {
    return isMediumUsageCount && !isDefaultLanguage;
  }

  /// Popülerlik kategorisi
  String get popularityCategory {
    if (isPopularLanguage) return 'Popüler';
    if (isUnpopularLanguage) return 'Az Kullanılan';
    return 'Orta';
  }

  @override
  String toString() {
    return 'LanguageConfig(id: $id, languageCode: $languageCode, type: $type, status: $status, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
