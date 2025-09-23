// ========== TRANSLATION ENTITY ==========
// lib/features/i18n/domain/entities/translation.dart

/// Çeviri türü
enum TranslationType {
  text('Metin'),
  html('HTML'),
  markdown('Markdown'),
  json('JSON'),
  xml('XML'),
  custom('Özel');

  const TranslationType(this.displayName);
  final String displayName;
}

/// Çeviri durumu
enum TranslationStatus {
  draft('Taslak'),
  pending('Beklemede'),
  inProgress('Devam Ediyor'),
  completed('Tamamlandı'),
  reviewed('İncelendi'),
  approved('Onaylandı'),
  rejected('Reddedildi'),
  archived('Arşivlendi');

  const TranslationStatus(this.displayName);
  final String displayName;
}

/// Çeviri önceliği
enum TranslationPriority {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  critical('Kritik');

  const TranslationPriority(this.displayName);
  final String displayName;
}

/// Çeviri entity'si
class Translation {
  final String id;
  final String key; // Çeviri anahtarı
  final String? sourceText; // Kaynak metin
  final String? translatedText; // Çevrilmiş metin
  final String? sourceLanguage; // Kaynak dil
  final String? targetLanguage; // Hedef dil
  final TranslationType type;
  final TranslationStatus status;
  final TranslationPriority priority;
  final String? context; // Bağlam
  final String? description; // Açıklama
  final String? category; // Kategori
  final String? tags; // Etiketler
  final String? translatorId; // Çevirmen ID'si
  final String? translatorName; // Çevirmen adı
  final String? reviewerId; // İnceleyen ID'si
  final String? reviewerName; // İnceleyen adı
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? assignedDate; // Atanma tarihi
  final DateTime? completedDate; // Tamamlanma tarihi
  final DateTime? reviewedDate; // İncelenme tarihi
  final DateTime? approvedDate; // Onaylanma tarihi
  final int? wordCount; // Kelime sayısı
  final int? characterCount; // Karakter sayısı
  final double? confidence; // Güven skoru (0-1)
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const Translation({
    required this.id,
    required this.key,
    this.sourceText,
    this.translatedText,
    this.sourceLanguage,
    this.targetLanguage,
    required this.type,
    required this.status,
    required this.priority,
    this.context,
    this.description,
    this.category,
    this.tags,
    this.translatorId,
    this.translatorName,
    this.reviewerId,
    this.reviewerName,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.assignedDate,
    this.completedDate,
    this.reviewedDate,
    this.approvedDate,
    this.wordCount,
    this.characterCount,
    this.confidence,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  Translation copyWith({
    String? id,
    String? key,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    TranslationType? type,
    TranslationStatus? status,
    TranslationPriority? priority,
    String? context,
    String? description,
    String? category,
    String? tags,
    String? translatorId,
    String? translatorName,
    String? reviewerId,
    String? reviewerName,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? assignedDate,
    DateTime? completedDate,
    DateTime? reviewedDate,
    DateTime? approvedDate,
    int? wordCount,
    int? characterCount,
    double? confidence,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Translation(
      id: id ?? this.id,
      key: key ?? this.key,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      context: context ?? this.context,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      translatorId: translatorId ?? this.translatorId,
      translatorName: translatorName ?? this.translatorName,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      assignedDate: assignedDate ?? this.assignedDate,
      completedDate: completedDate ?? this.completedDate,
      reviewedDate: reviewedDate ?? this.reviewedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      wordCount: wordCount ?? this.wordCount,
      characterCount: characterCount ?? this.characterCount,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Translation oluştur
  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'] as String,
      key: json['key'] as String,
      sourceText: json['sourceText'] as String?,
      translatedText: json['translatedText'] as String?,
      sourceLanguage: json['sourceLanguage'] as String?,
      targetLanguage: json['targetLanguage'] as String?,
      type: TranslationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TranslationType.text,
      ),
      status: TranslationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TranslationStatus.draft,
      ),
      priority: TranslationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TranslationPriority.medium,
      ),
      context: json['context'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      translatorId: json['translatorId'] as String?,
      translatorName: json['translatorName'] as String?,
      reviewerId: json['reviewerId'] as String?,
      reviewerName: json['reviewerName'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      assignedDate: json['assignedDate'] != null
          ? DateTime.parse(json['assignedDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      reviewedDate: json['reviewedDate'] != null
          ? DateTime.parse(json['reviewedDate'] as String)
          : null,
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'] as String)
          : null,
      wordCount: json['wordCount'] as int?,
      characterCount: json['characterCount'] as int?,
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Translation'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'context': context,
      'description': description,
      'category': category,
      'tags': tags,
      'translatorId': translatorId,
      'translatorName': translatorName,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'assignedDate': assignedDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'reviewedDate': reviewedDate?.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'wordCount': wordCount,
      'characterCount': characterCount,
      'confidence': confidence,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Metin çevirisi mi?
  bool get isTextTranslation => type == TranslationType.text;

  /// HTML çevirisi mi?
  bool get isHtmlTranslation => type == TranslationType.html;

  /// Markdown çevirisi mi?
  bool get isMarkdownTranslation => type == TranslationType.markdown;

  /// JSON çevirisi mi?
  bool get isJsonTranslation => type == TranslationType.json;

  /// XML çevirisi mi?
  bool get isXmlTranslation => type == TranslationType.xml;

  /// Özel çeviri mi?
  bool get isCustomTranslation => type == TranslationType.custom;

  /// Taslak mı?
  bool get isDraft => status == TranslationStatus.draft;

  /// Beklemede mi?
  bool get isPending => status == TranslationStatus.pending;

  /// Devam ediyor mu?
  bool get isInProgress => status == TranslationStatus.inProgress;

  /// Tamamlandı mı?
  bool get isCompleted => status == TranslationStatus.completed;

  /// İncelendi mi?
  bool get isReviewed => status == TranslationStatus.reviewed;

  /// Onaylandı mı?
  bool get isApproved => status == TranslationStatus.approved;

  /// Reddedildi mi?
  bool get isRejected => status == TranslationStatus.rejected;

  /// Arşivlendi mi?
  bool get isArchived => status == TranslationStatus.archived;

  /// Düşük öncelik mi?
  bool get isLowPriority => priority == TranslationPriority.low;

  /// Orta öncelik mi?
  bool get isMediumPriority => priority == TranslationPriority.medium;

  /// Yüksek öncelik mi?
  bool get isHighPriority => priority == TranslationPriority.high;

  /// Kritik öncelik mi?
  bool get isCriticalPriority => priority == TranslationPriority.critical;

  /// Kaynak metin var mı?
  bool get hasSourceText => sourceText != null && sourceText!.isNotEmpty;

  /// Çevrilmiş metin var mı?
  bool get hasTranslatedText =>
      translatedText != null && translatedText!.isNotEmpty;

  /// Kaynak dil var mı?
  bool get hasSourceLanguage =>
      sourceLanguage != null && sourceLanguage!.isNotEmpty;

  /// Hedef dil var mı?
  bool get hasTargetLanguage =>
      targetLanguage != null && targetLanguage!.isNotEmpty;

  /// Bağlam var mı?
  bool get hasContext => context != null && context!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Çevirmen ID'si var mı?
  bool get hasTranslatorId => translatorId != null && translatorId!.isNotEmpty;

  /// Çevirmen adı var mı?
  bool get hasTranslatorName =>
      translatorName != null && translatorName!.isNotEmpty;

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

  /// Atanma tarihi var mı?
  bool get hasAssignedDate => assignedDate != null;

  /// Tamamlanma tarihi var mı?
  bool get hasCompletedDate => completedDate != null;

  /// İncelenme tarihi var mı?
  bool get hasReviewedDate => reviewedDate != null;

  /// Onaylanma tarihi var mı?
  bool get hasApprovedDate => approvedDate != null;

  /// Kelime sayısı var mı?
  bool get hasWordCount => wordCount != null && wordCount! > 0;

  /// Karakter sayısı var mı?
  bool get hasCharacterCount => characterCount != null && characterCount! > 0;

  /// Güven skoru var mı?
  bool get hasConfidence => confidence != null && confidence! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return !isArchived && !isApproved;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isDraft || isRejected;
  }

  /// Atanabilir mi?
  bool get canBeAssigned {
    return isDraft || isPending;
  }

  /// Tamamlanabilir mi?
  bool get canBeCompleted {
    return isInProgress && hasTranslatedText;
  }

  /// İncelenebilir mi?
  bool get canBeReviewed {
    return isCompleted;
  }

  /// Onaylanabilir mi?
  bool get canBeApproved {
    return isReviewed;
  }

  /// Reddedilebilir mi?
  bool get canBeRejected {
    return isCompleted || isReviewed;
  }

  /// Arşivlenebilir mi?
  bool get canBeArchived {
    return isApproved || isRejected;
  }

  /// Çeviri yapılabilir mi?
  bool get canBeTranslated {
    return isPending || isInProgress;
  }

  /// İnceleme yapılabilir mi?
  bool get canBeReviewedForApproval {
    return isCompleted;
  }

  /// Onay yapılabilir mi?
  bool get canBeApprovedForPublish {
    return isReviewed;
  }

  /// Kelime sayısı sıfır mı?
  bool get isZeroWordCount => wordCount == null || wordCount == 0;

  /// Kelime sayısı yüksek mi? (100'den fazla)
  bool get isHighWordCount => wordCount != null && wordCount! > 100;

  /// Kelime sayısı düşük mi? (10'dan az)
  bool get isLowWordCount => wordCount != null && wordCount! < 10;

  /// Kelime sayısı orta mı? (10-100 arası)
  bool get isMediumWordCount =>
      wordCount != null && wordCount! >= 10 && wordCount! <= 100;

  /// Kelime sayısı kategorisi
  String get wordCountCategory {
    if (isHighWordCount) return 'Yüksek';
    if (isLowWordCount) return 'Düşük';
    return 'Orta';
  }

  /// Karakter sayısı sıfır mı?
  bool get isZeroCharacterCount =>
      characterCount == null || characterCount == 0;

  /// Karakter sayısı yüksek mi? (500'den fazla)
  bool get isHighCharacterCount =>
      characterCount != null && characterCount! > 500;

  /// Karakter sayısı düşük mi? (50'den az)
  bool get isLowCharacterCount =>
      characterCount != null && characterCount! < 50;

  /// Karakter sayısı orta mı? (50-500 arası)
  bool get isMediumCharacterCount =>
      characterCount != null && characterCount! >= 50 && characterCount! <= 500;

  /// Karakter sayısı kategorisi
  String get characterCountCategory {
    if (isHighCharacterCount) return 'Yüksek';
    if (isLowCharacterCount) return 'Düşük';
    return 'Orta';
  }

  /// Güven skoru yüksek mi? (%80'den fazla)
  bool get isHighConfidence => confidence != null && confidence! > 0.8;

  /// Güven skoru düşük mi? (%20'den az)
  bool get isLowConfidence => confidence != null && confidence! < 0.2;

  /// Güven skoru orta mı? (%20-80 arası)
  bool get isMediumConfidence =>
      confidence != null && confidence! >= 0.2 && confidence! <= 0.8;

  /// Güven skoru kategorisi
  String get confidenceCategory {
    if (isHighConfidence) return 'Yüksek';
    if (isLowConfidence) return 'Düşük';
    return 'Orta';
  }

  /// Atanma süresi (gün)
  int? get assignmentDurationInDays {
    if (assignedDate == null || completedDate == null) return null;
    return completedDate!.difference(assignedDate!).inDays;
  }

  /// İnceleme süresi (gün)
  int? get reviewDurationInDays {
    if (completedDate == null || reviewedDate == null) return null;
    return reviewedDate!.difference(completedDate!).inDays;
  }

  /// Onay süresi (gün)
  int? get approvalDurationInDays {
    if (reviewedDate == null || approvedDate == null) return null;
    return approvedDate!.difference(reviewedDate!).inDays;
  }

  /// Toplam süre (gün)
  int? get totalDurationInDays {
    if (assignedDate == null || approvedDate == null) return null;
    return approvedDate!.difference(assignedDate!).inDays;
  }

  /// Hızlı çeviri mi? (1 günden az)
  bool get isFastTranslation {
    final duration = assignmentDurationInDays;
    return duration != null && duration < 1;
  }

  /// Yavaş çeviri mi? (7 günden fazla)
  bool get isSlowTranslation {
    final duration = assignmentDurationInDays;
    return duration != null && duration > 7;
  }

  /// Orta hızlı çeviri mi? (1-7 gün arası)
  bool get isMediumTranslation {
    final duration = assignmentDurationInDays;
    return duration != null && duration >= 1 && duration <= 7;
  }

  /// Çeviri hızı kategorisi
  String get translationSpeedCategory {
    if (isFastTranslation) return 'Hızlı';
    if (isSlowTranslation) return 'Yavaş';
    return 'Orta';
  }

  /// Çeviri dili çifti
  String get languagePair {
    if (hasSourceLanguage && hasTargetLanguage) {
      return '$sourceLanguage → $targetLanguage';
    }
    return 'Bilinmiyor';
  }

  /// Çeviri durumu kategorisi
  String get statusCategory {
    if (isApproved) return 'Onaylandı';
    if (isReviewed) return 'İncelendi';
    if (isCompleted) return 'Tamamlandı';
    if (isInProgress) return 'Devam Ediyor';
    if (isPending) return 'Beklemede';
    if (isDraft) return 'Taslak';
    if (isRejected) return 'Reddedildi';
    if (isArchived) return 'Arşivlendi';
    return 'Bilinmiyor';
  }

  /// Aktif çeviri mi?
  bool get isActive => !isArchived && !isApproved;

  /// Tamamlanmış çeviri mi?
  bool get isFinished => isApproved || isArchived;

  /// Bekleyen çeviri mi?
  bool get isWaiting => isDraft || isPending;

  /// İşlenen çeviri mi?
  bool get isProcessing => isInProgress || isCompleted || isReviewed;

  /// Kritik çeviri mi?
  bool get isCritical => isCriticalPriority;

  /// Yüksek öncelikli çeviri mi?
  bool get isHighPriorityTranslation => isHighPriority || isCriticalPriority;

  /// Normal öncelikli çeviri mi?
  bool get isNormalPriority => isMediumPriority || isLowPriority;

  @override
  String toString() {
    return 'Translation(id: $id, key: $key, type: $type, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Translation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
