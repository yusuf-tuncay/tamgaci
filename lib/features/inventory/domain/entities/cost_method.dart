// ========== COST METHOD ENTITY ==========
// lib/features/inventory/domain/entities/cost_method.dart

/// Maliyet hesaplama yöntemi
enum CostMethod {
  fifo('FIFO (İlk Giren İlk Çıkar)'),
  lifo('LIFO (Son Giren İlk Çıkar)'),
  average('Ortalama Maliyet'),
  specific('Özel Maliyet'),
  standard('Standart Maliyet');

  const CostMethod(this.displayName);
  final String displayName;
}

/// Maliyet hesaplama yöntemi entity'si
class CostMethodConfig {
  final String id;
  final String name;
  final CostMethod method;
  final String? description;
  final bool isActive;
  final Map<String, dynamic> settings; // Yönteme özel ayarlar
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const CostMethodConfig({
    required this.id,
    required this.name,
    required this.method,
    this.description,
    this.isActive = true,
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  CostMethodConfig copyWith({
    String? id,
    String? name,
    CostMethod? method,
    String? description,
    bool? isActive,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CostMethodConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      method: method ?? this.method,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan CostMethodConfig oluştur
  factory CostMethodConfig.fromJson(Map<String, dynamic> json) {
    return CostMethodConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      method: CostMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => CostMethod.average,
      ),
      description: json['description'] as String?,
      isActive: json['isActive'] ?? true,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// CostMethodConfig'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'method': method.name,
      'description': description,
      'isActive': isActive,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  String toString() {
    return 'CostMethodConfig(id: $id, name: $name, method: $method)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CostMethodConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
