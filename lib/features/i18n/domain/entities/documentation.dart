// ========== DOCUMENTATION ENTITY ==========
// lib/features/i18n/domain/entities/documentation.dart

/// Dokümantasyon türü
enum DocumentationType {
  user('Kullanıcı Dokümantasyonu'),
  technical('Teknik Dokümantasyon'),
  api('API Dokümantasyonu'),
  developer('Geliştirici Dokümantasyonu'),
  admin('Yönetici Dokümantasyonu'),
  faq('SSS'),
  tutorial('Eğitim'),
  guide('Rehber'),
  custom('Özel Dokümantasyon');

  const DocumentationType(this.displayName);
  final String displayName;
}

/// Dokümantasyon durumu
enum DocumentationStatus {
  draft('Taslak'),
  review('İnceleme'),
  published('Yayınlandı'),
  archived('Arşivlendi'),
  deleted('Silindi');

  const DocumentationStatus(this.displayName);
  final String displayName;
}

/// Dokümantasyon önceliği
enum DocumentationPriority {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  critical('Kritik');

  const DocumentationPriority(this.displayName);
  final String displayName;
}

/// Dokümantasyon entity'si
class Documentation {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final DocumentationType type;
  final DocumentationStatus status;
  final DocumentationPriority priority;
  final String? content; // İçerik
  final String? summary; // Özet
  final String? language; // Dil
  final String? version; // Sürüm
  final String? category; // Kategori
  final String? tags; // Etiketler
  final String? authorId; // Yazar ID'si
  final String? authorName; // Yazar adı
  final String? reviewerId; // İnceleyen ID'si
  final String? reviewerName; // İnceleyen adı
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? publishedDate; // Yayınlanma tarihi
  final DateTime? lastModifiedDate; // Son değiştirilme tarihi
  final DateTime? reviewDate; // İnceleme tarihi
  final int? viewCount; // Görüntülenme sayısı
  final int? wordCount; // Kelime sayısı
  final int? characterCount; // Karakter sayısı
  final double? readingTime; // Okuma süresi (dakika)
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const Documentation({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.type,
    required this.status,
    required this.priority,
    this.content,
    this.summary,
    this.language,
    this.version,
    this.category,
    this.tags,
    this.authorId,
    this.authorName,
    this.reviewerId,
    this.reviewerName,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.publishedDate,
    this.lastModifiedDate,
    this.reviewDate,
    this.viewCount,
    this.wordCount,
    this.characterCount,
    this.readingTime,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  Documentation copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    DocumentationType? type,
    DocumentationStatus? status,
    DocumentationPriority? priority,
    String? content,
    String? summary,
    String? language,
    String? version,
    String? category,
    String? tags,
    String? authorId,
    String? authorName,
    String? reviewerId,
    String? reviewerName,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? publishedDate,
    DateTime? lastModifiedDate,
    DateTime? reviewDate,
    int? viewCount,
    int? wordCount,
    int? characterCount,
    double? readingTime,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Documentation(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      language: language ?? this.language,
      version: version ?? this.version,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      publishedDate: publishedDate ?? this.publishedDate,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      reviewDate: reviewDate ?? this.reviewDate,
      viewCount: viewCount ?? this.viewCount,
      wordCount: wordCount ?? this.wordCount,
      characterCount: characterCount ?? this.characterCount,
      readingTime: readingTime ?? this.readingTime,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Documentation oluştur
  factory Documentation.fromJson(Map<String, dynamic> json) {
    return Documentation(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      type: DocumentationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentationType.user,
      ),
      status: DocumentationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DocumentationStatus.draft,
      ),
      priority: DocumentationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => DocumentationPriority.medium,
      ),
      content: json['content'] as String?,
      summary: json['summary'] as String?,
      language: json['language'] as String?,
      version: json['version'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      reviewerId: json['reviewerId'] as String?,
      reviewerName: json['reviewerName'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      publishedDate: json['publishedDate'] != null
          ? DateTime.parse(json['publishedDate'] as String)
          : null,
      lastModifiedDate: json['lastModifiedDate'] != null
          ? DateTime.parse(json['lastModifiedDate'] as String)
          : null,
      reviewDate: json['reviewDate'] != null
          ? DateTime.parse(json['reviewDate'] as String)
          : null,
      viewCount: json['viewCount'] as int?,
      wordCount: json['wordCount'] as int?,
      characterCount: json['characterCount'] as int?,
      readingTime: json['readingTime'] != null
          ? (json['readingTime'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Documentation'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'content': content,
      'summary': summary,
      'language': language,
      'version': version,
      'category': category,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'publishedDate': publishedDate?.toIso8601String(),
      'lastModifiedDate': lastModifiedDate?.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
      'viewCount': viewCount,
      'wordCount': wordCount,
      'characterCount': characterCount,
      'readingTime': readingTime,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Kullanıcı dokümantasyonu mu?
  bool get isUserDocumentation => type == DocumentationType.user;

  /// Teknik dokümantasyon mu?
  bool get isTechnicalDocumentation => type == DocumentationType.technical;

  /// API dokümantasyonu mu?
  bool get isApiDocumentation => type == DocumentationType.api;

  /// Geliştirici dokümantasyonu mu?
  bool get isDeveloperDocumentation => type == DocumentationType.developer;

  /// Yönetici dokümantasyonu mu?
  bool get isAdminDocumentation => type == DocumentationType.admin;

  /// SSS mi?
  bool get isFaq => type == DocumentationType.faq;

  /// Eğitim mi?
  bool get isTutorial => type == DocumentationType.tutorial;

  /// Rehber mi?
  bool get isGuide => type == DocumentationType.guide;

  /// Özel dokümantasyon mu?
  bool get isCustomDocumentation => type == DocumentationType.custom;

  /// Taslak mı?
  bool get isDraft => status == DocumentationStatus.draft;

  /// İncelemede mi?
  bool get isReview => status == DocumentationStatus.review;

  /// Yayınlandı mı?
  bool get isPublished => status == DocumentationStatus.published;

  /// Arşivlendi mi?
  bool get isArchived => status == DocumentationStatus.archived;

  /// Silindi mi?
  bool get isDeleted => status == DocumentationStatus.deleted;

  /// Düşük öncelik mi?
  bool get isLowPriority => priority == DocumentationPriority.low;

  /// Orta öncelik mi?
  bool get isMediumPriority => priority == DocumentationPriority.medium;

  /// Yüksek öncelik mi?
  bool get isHighPriority => priority == DocumentationPriority.high;

  /// Kritik öncelik mi?
  bool get isCriticalPriority => priority == DocumentationPriority.critical;

  /// Alt başlık var mı?
  bool get hasSubtitle => subtitle != null && subtitle!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// İçerik var mı?
  bool get hasContent => content != null && content!.isNotEmpty;

  /// Özet var mı?
  bool get hasSummary => summary != null && summary!.isNotEmpty;

  /// Dil var mı?
  bool get hasLanguage => language != null && language!.isNotEmpty;

  /// Sürüm var mı?
  bool get hasVersion => version != null && version!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Yazar ID'si var mı?
  bool get hasAuthorId => authorId != null && authorId!.isNotEmpty;

  /// Yazar adı var mı?
  bool get hasAuthorName => authorName != null && authorName!.isNotEmpty;

  /// İnceleyen ID'si var mı?
  bool get hasReviewerId => reviewerId != null && reviewerId!.isNotEmpty;

  /// İnceleyen adı var mı?
  bool get hasReviewerName => reviewerName != null && reviewerName!.isNotEmpty;

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

  /// Yayınlanma tarihi var mı?
  bool get hasPublishedDate => publishedDate != null;

  /// Son değiştirilme tarihi var mı?
  bool get hasLastModifiedDate => lastModifiedDate != null;

  /// İnceleme tarihi var mı?
  bool get hasReviewDate => reviewDate != null;

  /// Görüntülenme sayısı var mı?
  bool get hasViewCount => viewCount != null && viewCount! > 0;

  /// Kelime sayısı var mı?
  bool get hasWordCount => wordCount != null && wordCount! > 0;

  /// Karakter sayısı var mı?
  bool get hasCharacterCount => characterCount != null && characterCount! > 0;

  /// Okuma süresi var mı?
  bool get hasReadingTime => readingTime != null && readingTime! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return !isArchived && !isDeleted;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isDraft || isArchived;
  }

  /// Yayınlanabilir mi?
  bool get canBePublished {
    return isReview && hasContent;
  }

  /// İncelemeye gönderilebilir mi?
  bool get canBeSentToReview {
    return isDraft && hasContent;
  }

  /// Arşivlenebilir mi?
  bool get canBeArchived {
    return isPublished;
  }

  /// Görüntülenebilir mi?
  bool get canBeViewed {
    return isPublished;
  }

  /// Görüntülenme sayısı sıfır mı?
  bool get isZeroViewCount => viewCount == null || viewCount == 0;

  /// Görüntülenme sayısı yüksek mi? (1000'den fazla)
  bool get isHighViewCount => viewCount != null && viewCount! > 1000;

  /// Görüntülenme sayısı düşük mi? (10'dan az)
  bool get isLowViewCount => viewCount != null && viewCount! < 10;

  /// Görüntülenme sayısı orta mı? (10-1000 arası)
  bool get isMediumViewCount =>
      viewCount != null && viewCount! >= 10 && viewCount! <= 1000;

  /// Görüntülenme sayısı kategorisi
  String get viewCountCategory {
    if (isHighViewCount) return 'Yüksek';
    if (isLowViewCount) return 'Düşük';
    return 'Orta';
  }

  /// Kelime sayısı sıfır mı?
  bool get isZeroWordCount => wordCount == null || wordCount == 0;

  /// Kelime sayısı yüksek mi? (1000'den fazla)
  bool get isHighWordCount => wordCount != null && wordCount! > 1000;

  /// Kelime sayısı düşük mi? (100'den az)
  bool get isLowWordCount => wordCount != null && wordCount! < 100;

  /// Kelime sayısı orta mı? (100-1000 arası)
  bool get isMediumWordCount =>
      wordCount != null && wordCount! >= 100 && wordCount! <= 1000;

  /// Kelime sayısı kategorisi
  String get wordCountCategory {
    if (isHighWordCount) return 'Yüksek';
    if (isLowWordCount) return 'Düşük';
    return 'Orta';
  }

  /// Karakter sayısı sıfır mı?
  bool get isZeroCharacterCount =>
      characterCount == null || characterCount == 0;

  /// Karakter sayısı yüksek mi? (5000'den fazla)
  bool get isHighCharacterCount =>
      characterCount != null && characterCount! > 5000;

  /// Karakter sayısı düşük mi? (500'den az)
  bool get isLowCharacterCount =>
      characterCount != null && characterCount! < 500;

  /// Karakter sayısı orta mı? (500-5000 arası)
  bool get isMediumCharacterCount =>
      characterCount != null &&
      characterCount! >= 500 &&
      characterCount! <= 5000;

  /// Karakter sayısı kategorisi
  String get characterCountCategory {
    if (isHighCharacterCount) return 'Yüksek';
    if (isLowCharacterCount) return 'Düşük';
    return 'Orta';
  }

  /// Okuma süresi sıfır mı?
  bool get isZeroReadingTime => readingTime == null || readingTime == 0;

  /// Okuma süresi yüksek mi? (30 dakikadan fazla)
  bool get isHighReadingTime => readingTime != null && readingTime! > 30;

  /// Okuma süresi düşük mi? (5 dakikadan az)
  bool get isLowReadingTime => readingTime != null && readingTime! < 5;

  /// Okuma süresi orta mı? (5-30 dakika arası)
  bool get isMediumReadingTime =>
      readingTime != null && readingTime! >= 5 && readingTime! <= 30;

  /// Okuma süresi kategorisi
  String get readingTimeCategory {
    if (isHighReadingTime) return 'Yüksek';
    if (isLowReadingTime) return 'Düşük';
    return 'Orta';
  }

  /// Yayınlanma süresi (gün)
  int? get publishedDays {
    if (publishedDate == null) return null;
    return DateTime.now().difference(publishedDate!).inDays;
  }

  /// Yayınlanma süresi uzun mu? (30 günden fazla)
  bool get isPublishedLongAgo {
    final days = publishedDays;
    return days != null && days > 30;
  }

  /// Yayınlanma süresi kısa mı? (7 günden az)
  bool get isPublishedRecently {
    final days = publishedDays;
    return days != null && days < 7;
  }

  /// Yayınlanma süresi orta mı? (7-30 gün arası)
  bool get isPublishedMedium {
    final days = publishedDays;
    return days != null && days >= 7 && days <= 30;
  }

  /// Yayınlanma süresi kategorisi
  String get publishedCategory {
    if (isPublishedLongAgo) return 'Uzun';
    if (isPublishedRecently) return 'Kısa';
    return 'Orta';
  }

  /// Son değiştirilme süresi (gün)
  int? get lastModifiedDays {
    if (lastModifiedDate == null) return null;
    return DateTime.now().difference(lastModifiedDate!).inDays;
  }

  /// Son değiştirilme süresi uzun mu? (30 günden fazla)
  bool get isLastModifiedLongAgo {
    final days = lastModifiedDays;
    return days != null && days > 30;
  }

  /// Son değiştirilme süresi kısa mı? (7 günden az)
  bool get isLastModifiedRecently {
    final days = lastModifiedDays;
    return days != null && days < 7;
  }

  /// Son değiştirilme süresi orta mı? (7-30 gün arası)
  bool get isLastModifiedMedium {
    final days = lastModifiedDays;
    return days != null && days >= 7 && days <= 30;
  }

  /// Son değiştirilme süresi kategorisi
  String get lastModifiedCategory {
    if (isLastModifiedLongAgo) return 'Uzun';
    if (isLastModifiedRecently) return 'Kısa';
    return 'Orta';
  }

  /// İnceleme süresi (gün)
  int? get reviewDurationInDays {
    if (reviewDate == null || publishedDate == null) return null;
    return publishedDate!.difference(reviewDate!).inDays;
  }

  /// Hızlı inceleme mi? (1 günden az)
  bool get isFastReview {
    final duration = reviewDurationInDays;
    return duration != null && duration < 1;
  }

  /// Yavaş inceleme mi? (7 günden fazla)
  bool get isSlowReview {
    final duration = reviewDurationInDays;
    return duration != null && duration > 7;
  }

  /// Orta hızlı inceleme mi? (1-7 gün arası)
  bool get isMediumReview {
    final duration = reviewDurationInDays;
    return duration != null && duration >= 1 && duration <= 7;
  }

  /// İnceleme hızı kategorisi
  String get reviewSpeedCategory {
    if (isFastReview) return 'Hızlı';
    if (isSlowReview) return 'Yavaş';
    return 'Orta';
  }

  /// Görünen başlık
  String get effectiveTitle {
    if (hasSubtitle) {
      return '$title: $subtitle';
    }
    return title;
  }

  /// Görünen özet
  String get effectiveSummary {
    if (hasSummary) return summary!;
    if (hasDescription) return description!;
    return 'Özet bulunmuyor';
  }

  /// Görünen dil
  String get effectiveLanguage {
    if (hasLanguage) return language!;
    return 'tr'; // Varsayılan Türkçe
  }

  /// Görünen sürüm
  String get effectiveVersion {
    if (hasVersion) return version!;
    return '1.0'; // Varsayılan sürüm
  }

  /// Görünen yazar
  String get effectiveAuthor {
    if (hasAuthorName) return authorName!;
    if (hasCreatedByName) return createdByName!;
    return 'Bilinmiyor';
  }

  /// Görünen inceleyen
  String get effectiveReviewer {
    if (hasReviewerName) return reviewerName!;
    return 'Bilinmiyor';
  }

  /// Popüler dokümantasyon mu?
  bool get isPopular => isHighViewCount;

  /// Az görüntülenen dokümantasyon mu?
  bool get isUnpopular => isLowViewCount;

  /// Orta görüntülenen dokümantasyon mu?
  bool get isMediumPopular => isMediumViewCount;

  /// Popülerlik kategorisi
  String get popularityCategory {
    if (isPopular) return 'Popüler';
    if (isUnpopular) return 'Az Görüntülenen';
    return 'Orta';
  }

  /// Uzun dokümantasyon mu?
  bool get isLongDocumentation => isHighWordCount;

  /// Kısa dokümantasyon mu?
  bool get isShortDocumentation => isLowWordCount;

  /// Orta uzunlukta dokümantasyon mu?
  bool get isMediumDocumentation => isMediumWordCount;

  /// Uzunluk kategorisi
  String get lengthCategory {
    if (isLongDocumentation) return 'Uzun';
    if (isShortDocumentation) return 'Kısa';
    return 'Orta';
  }

  /// Aktif dokümantasyon mu?
  bool get isActive => !isArchived && !isDeleted;

  /// Tamamlanmış dokümantasyon mu?
  bool get isFinished => isPublished || isArchived;

  /// Bekleyen dokümantasyon mu?
  bool get isWaiting => isDraft || isReview;

  /// İşlenen dokümantasyon mu?
  bool get isProcessing => isReview;

  /// Kritik dokümantasyon mu?
  bool get isCritical => isCriticalPriority;

  /// Yüksek öncelikli dokümantasyon mu?
  bool get isHighPriorityDocumentation => isHighPriority || isCriticalPriority;

  /// Normal öncelikli dokümantasyon mu?
  bool get isNormalPriority => isMediumPriority || isLowPriority;

  @override
  String toString() {
    return 'Documentation(id: $id, title: $title, type: $type, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Documentation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
