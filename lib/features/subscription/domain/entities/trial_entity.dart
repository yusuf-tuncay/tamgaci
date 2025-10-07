// ========== TRIAL ENTITY ==========
// lib/features/subscription/domain/entities/trial_entity.dart

/// Deneme süresi durumu
enum TrialStatus {
  active,    // Aktif deneme
  expired,   // Süresi dolmuş
  converted, // Ücretli plana geçmiş
  canceled,  // İptal edilmiş
}

/// Deneme süresi entity'si
class TrialEntity {
  /// Trial ID'si
  final String id;

  /// Kullanıcı ID'si
  final String userId;

  /// Başlangıç tarihi
  final DateTime startDate;

  /// Bitiş tarihi
  final DateTime endDate;

  /// Durum
  final TrialStatus status;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const TrialEntity({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deneme süresi aktif mi?
  bool get isActive => status == TrialStatus.active && DateTime.now().isBefore(endDate);

  /// Süresi dolmuş mu?
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Kalan gün sayısı
  int get remainingDays {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Kalan saat sayısı
  int get remainingHours {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inHours;
  }

  /// Geri sayım bilgisi
  String get countdownText {
    if (isExpired) return 'Süresi dolmuş';
    
    final remaining = endDate.difference(DateTime.now());
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    
    if (days > 0) {
      return '$days gün $hours saat';
    } else if (hours > 0) {
      return '$hours saat';
    } else {
      final minutes = remaining.inMinutes % 60;
      return '$minutes dakika';
    }
  }

  /// JSON'dan oluştur
  factory TrialEntity.fromJson(Map<String, dynamic> json) {
    return TrialEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: TrialStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TrialStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Kopyala
  TrialEntity copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    TrialStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrialEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'TrialEntity(id: $id, userId: $userId, remainingDays: $remainingDays)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrialEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
