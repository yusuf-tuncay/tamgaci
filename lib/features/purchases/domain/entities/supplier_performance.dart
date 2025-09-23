// ========== SUPPLIER PERFORMANCE ENTITY ==========
// lib/features/purchases/domain/entities/supplier_performance.dart

/// Tedarikçi performans metrik türü
enum SupplierPerformanceMetric {
  deliveryTime('Teslimat Süresi'),
  quality('Kalite'),
  price('Fiyat'),
  service('Hizmet'),
  communication('İletişim'),
  reliability('Güvenilirlik'),
  flexibility('Esneklik'),
  innovation('İnovasyon');

  const SupplierPerformanceMetric(this.displayName);
  final String displayName;
}

/// Tedarikçi performans değerlendirme türü
enum SupplierEvaluationType {
  monthly('Aylık'),
  quarterly('Çeyreklik'),
  yearly('Yıllık'),
  project('Proje Bazlı'),
  order('Sipariş Bazlı'),
  custom('Özel');

  const SupplierEvaluationType(this.displayName);
  final String displayName;
}

/// Tedarikçi performans entity'si
class SupplierPerformance {
  final String id;
  final String supplierId;
  final String? supplierName;
  final SupplierEvaluationType evaluationType;
  final DateTime evaluationDate;
  final DateTime? periodStart; // Değerlendirme dönemi başlangıcı
  final DateTime? periodEnd; // Değerlendirme dönemi bitişi
  final Map<SupplierPerformanceMetric, double> scores; // Metrik skorları (1-10)
  final double overallScore; // Genel skor
  final String? comments; // Yorumlar
  final String? recommendations; // Öneriler
  final String? evaluatedBy; // Değerlendiren kişi
  final List<String> supportingDocuments; // Destekleyici belgeler
  final Map<String, dynamic> metadata; // Ek bilgiler
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const SupplierPerformance({
    required this.id,
    required this.supplierId,
    this.supplierName,
    required this.evaluationType,
    required this.evaluationDate,
    this.periodStart,
    this.periodEnd,
    required this.scores,
    required this.overallScore,
    this.comments,
    this.recommendations,
    this.evaluatedBy,
    this.supportingDocuments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  SupplierPerformance copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    SupplierEvaluationType? evaluationType,
    DateTime? evaluationDate,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<SupplierPerformanceMetric, double>? scores,
    double? overallScore,
    String? comments,
    String? recommendations,
    String? evaluatedBy,
    List<String>? supportingDocuments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return SupplierPerformance(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      evaluationType: evaluationType ?? this.evaluationType,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      scores: scores ?? this.scores,
      overallScore: overallScore ?? this.overallScore,
      comments: comments ?? this.comments,
      recommendations: recommendations ?? this.recommendations,
      evaluatedBy: evaluatedBy ?? this.evaluatedBy,
      supportingDocuments: supportingDocuments ?? this.supportingDocuments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan SupplierPerformance oluştur
  factory SupplierPerformance.fromJson(Map<String, dynamic> json) {
    final scoresMap = <SupplierPerformanceMetric, double>{};
    final scoresJson = json['scores'] as Map<String, dynamic>? ?? {};

    for (final entry in scoresJson.entries) {
      final metric = SupplierPerformanceMetric.values.firstWhere(
        (e) => e.name == entry.key,
        orElse: () => SupplierPerformanceMetric.deliveryTime,
      );
      scoresMap[metric] = (entry.value as num).toDouble();
    }

    return SupplierPerformance(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      evaluationType: SupplierEvaluationType.values.firstWhere(
        (e) => e.name == json['evaluationType'],
        orElse: () => SupplierEvaluationType.monthly,
      ),
      evaluationDate: DateTime.parse(json['evaluationDate'] as String),
      periodStart: json['periodStart'] != null
          ? DateTime.parse(json['periodStart'] as String)
          : null,
      periodEnd: json['periodEnd'] != null
          ? DateTime.parse(json['periodEnd'] as String)
          : null,
      scores: scoresMap,
      overallScore: (json['overallScore'] as num).toDouble(),
      comments: json['comments'] as String?,
      recommendations: json['recommendations'] as String?,
      evaluatedBy: json['evaluatedBy'] as String?,
      supportingDocuments: List<String>.from(json['supportingDocuments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// SupplierPerformance'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    final scoresJson = <String, double>{};
    for (final entry in scores.entries) {
      scoresJson[entry.key.name] = entry.value;
    }

    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'evaluationType': evaluationType.name,
      'evaluationDate': evaluationDate.toIso8601String(),
      'periodStart': periodStart?.toIso8601String(),
      'periodEnd': periodEnd?.toIso8601String(),
      'scores': scoresJson,
      'overallScore': overallScore,
      'comments': comments,
      'recommendations': recommendations,
      'evaluatedBy': evaluatedBy,
      'supportingDocuments': supportingDocuments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Performans seviyesi
  String get performanceLevel {
    if (overallScore >= 9) return 'Mükemmel';
    if (overallScore >= 8) return 'Çok İyi';
    if (overallScore >= 7) return 'İyi';
    if (overallScore >= 6) return 'Orta';
    if (overallScore >= 5) return 'Yetersiz';
    return 'Kötü';
  }

  /// Performans rengi
  String get performanceColor {
    if (overallScore >= 8) return '#4CAF50'; // Yeşil
    if (overallScore >= 6) return '#FF9800'; // Turuncu
    return '#F44336'; // Kırmızı
  }

  /// En iyi performans metrik
  SupplierPerformanceMetric? get bestMetric {
    if (scores.isEmpty) return null;
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// En kötü performans metrik
  SupplierPerformanceMetric? get worstMetric {
    if (scores.isEmpty) return null;
    return scores.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  /// Ortalama skor
  double get averageScore {
    if (scores.isEmpty) return 0;
    return scores.values.reduce((a, b) => a + b) / scores.length;
  }

  /// Değerlendirme dönemi
  String get periodDescription {
    if (periodStart == null || periodEnd == null) {
      return evaluationType.displayName;
    }
    return '${periodStart!.day}/${periodStart!.month}/${periodStart!.year} - ${periodEnd!.day}/${periodEnd!.month}/${periodEnd!.year}';
  }

  /// Destekleyici belge var mı?
  bool get hasSupportingDocuments => supportingDocuments.isNotEmpty;

  /// Yorum var mı?
  bool get hasComments => comments != null && comments!.isNotEmpty;

  /// Öneri var mı?
  bool get hasRecommendations =>
      recommendations != null && recommendations!.isNotEmpty;

  /// Değerlendirme tamamlandı mı?
  bool get isCompleted => scores.isNotEmpty && overallScore > 0;

  /// Kritik performans sorunu var mı?
  bool get hasCriticalIssues => overallScore < 5;

  /// İyileştirme gerekli mi?
  bool get needsImprovement => overallScore < 7;

  @override
  String toString() {
    return 'SupplierPerformance(id: $id, supplierId: $supplierId, overallScore: $overallScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierPerformance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
