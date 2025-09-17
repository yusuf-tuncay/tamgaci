// ========== CUSTOMER CATEGORY ENTITY ==========
// lib/features/customers/domain/entities/customer_category.dart

/// Müşteri kategorisi entity'si
class CustomerCategory {
  /// Kategori benzersiz ID'si
  final String id;

  /// Kategori adı
  final String name;

  /// Kategori açıklaması
  final String? description;

  /// Kategori seviyesi (1 veya 2)
  final int level;

  /// Üst kategori ID'si (level 2 için)
  final String? parentCategoryId;

  /// Şirket ID'si
  final String companyId;

  /// Aktif/Pasif durumu
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  /// Oluşturan kullanıcı
  final String createdBy;

  /// Güncelleyen kullanıcı
  final String? updatedBy;

  const CustomerCategory({
    required this.id,
    required this.name,
    this.description,
    required this.level,
    this.parentCategoryId,
    required this.companyId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  CustomerCategory copyWith({
    String? id,
    String? name,
    String? description,
    int? level,
    String? parentCategoryId,
    String? companyId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CustomerCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      companyId: companyId ?? this.companyId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan CustomerCategory oluştur
  factory CustomerCategory.fromJson(Map<String, dynamic> json) {
    return CustomerCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      level: json['level'] as int,
      parentCategoryId: json['parentCategoryId'] as String?,
      companyId: json['companyId'] as String,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// CustomerCategory'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      'parentCategoryId': parentCategoryId,
      'companyId': companyId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  String toString() {
    return 'CustomerCategory(id: $id, name: $name, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
