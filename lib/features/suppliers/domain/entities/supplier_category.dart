// ========== SUPPLIER CATEGORY ENTITY ==========
// lib/features/suppliers/domain/entities/supplier_category.dart

/// Tedarikçi kategorisi entity'si
class SupplierCategory {
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

  /// Tenant ID'si (multi-tenant güvenlik için)
  final String tenantId;

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

  const SupplierCategory({
    required this.id,
    required this.name,
    this.description,
    required this.level,
    this.parentCategoryId,
    required this.companyId,
    required this.tenantId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  SupplierCategory copyWith({
    String? id,
    String? name,
    String? description,
    int? level,
    String? parentCategoryId,
    String? companyId,
    String? tenantId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return SupplierCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      companyId: companyId ?? this.companyId,
      tenantId: tenantId ?? this.tenantId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan SupplierCategory oluştur
  factory SupplierCategory.fromJson(Map<String, dynamic> json) {
    return SupplierCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      level: json['level'] as int,
      parentCategoryId: json['parentCategoryId'] as String?,
      companyId: json['companyId'] as String,
      tenantId: json['tenantId'] as String,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// SupplierCategory'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      'parentCategoryId': parentCategoryId,
      'companyId': companyId,
      'tenantId': tenantId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Kategori hiyerarşisi
  String get hierarchyName {
    if (level == 1) {
      return name;
    } else {
      return '$name (Alt Kategori)';
    }
  }

  /// Görünen ad
  String get displayName {
    if (description != null && description!.isNotEmpty) {
      return '$name - $description';
    }
    return name;
  }

  @override
  String toString() {
    return 'SupplierCategory(id: $id, name: $name, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
