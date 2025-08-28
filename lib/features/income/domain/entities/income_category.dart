// ========== INCOME CATEGORY ENTITY ==========
// lib/features/income/domain/entities/income_category.dart

/// Gelir kategorisi entity'si
class IncomeCategory {
  /// Kategori ID'si
  final String id;

  /// Kategori adı
  final String name;

  /// Kategori açıklaması
  final String? description;

  /// Kategori ikonu
  final String icon;

  /// Kategori rengi (hex)
  final String color;

  /// Kategori aktif mi?
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const IncomeCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// IncomeCategory kopyalama metodu
  IncomeCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncomeCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan IncomeCategory oluştur
  factory IncomeCategory.fromJson(Map<String, dynamic> json) {
    return IncomeCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// IncomeCategory'yi JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IncomeCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'IncomeCategory(id: $id, name: $name, isActive: $isActive)';
  }
}
