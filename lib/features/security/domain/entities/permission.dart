// ========== PERMISSION ENTITY ==========
// lib/features/security/domain/entities/permission.dart

/// İzin türü
enum PermissionType {
  read('Okuma'),
  write('Yazma'),
  delete('Silme'),
  execute('Çalıştırma'),
  admin('Yönetici'),
  custom('Özel');

  const PermissionType(this.displayName);
  final String displayName;
}

/// İzin durumu
enum PermissionStatus {
  active('Aktif'),
  inactive('Pasif'),
  deprecated('Kullanımdan Kaldırıldı');

  const PermissionStatus(this.displayName);
  final String displayName;
}

/// İzin entity'si
class Permission {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final PermissionType type;
  final PermissionStatus status;
  final String? resource; // Kaynak (users, products, sales, etc.)
  final String? action; // Aksiyon (create, read, update, delete, etc.)
  final String? category; // Kategori
  final String? tags; // Etiketler
  final List<String> dependencies; // Bağımlılıklar
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? lastUsedDate; // Son kullanım tarihi
  final int? roleCount; // Rol sayısı
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const Permission({
    required this.id,
    required this.name,
    this.displayName,
    this.description,
    required this.type,
    required this.status,
    this.resource,
    this.action,
    this.category,
    this.tags,
    this.dependencies = const [],
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.lastUsedDate,
    this.roleCount,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  Permission copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    PermissionType? type,
    PermissionStatus? status,
    String? resource,
    String? action,
    String? category,
    String? tags,
    List<String>? dependencies,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? lastUsedDate,
    int? roleCount,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Permission(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      resource: resource ?? this.resource,
      action: action ?? this.action,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      dependencies: dependencies ?? this.dependencies,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      roleCount: roleCount ?? this.roleCount,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Permission oluştur
  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      type: PermissionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PermissionType.read,
      ),
      status: PermissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PermissionStatus.active,
      ),
      resource: json['resource'] as String?,
      action: json['action'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      dependencies: List<String>.from(json['dependencies'] ?? []),
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      lastUsedDate: json['lastUsedDate'] != null
          ? DateTime.parse(json['lastUsedDate'] as String)
          : null,
      roleCount: json['roleCount'] as int?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Permission'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'type': type.name,
      'status': status.name,
      'resource': resource,
      'action': action,
      'category': category,
      'tags': tags,
      'dependencies': dependencies,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'lastUsedDate': lastUsedDate?.toIso8601String(),
      'roleCount': roleCount,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Okuma izni mi?
  bool get isReadPermission => type == PermissionType.read;

  /// Yazma izni mi?
  bool get isWritePermission => type == PermissionType.write;

  /// Silme izni mi?
  bool get isDeletePermission => type == PermissionType.delete;

  /// Çalıştırma izni mi?
  bool get isExecutePermission => type == PermissionType.execute;

  /// Yönetici izni mi?
  bool get isAdminPermission => type == PermissionType.admin;

  /// Özel izin mi?
  bool get isCustomPermission => type == PermissionType.custom;

  /// Aktif mi?
  bool get isActive => status == PermissionStatus.active;

  /// Pasif mi?
  bool get isInactive => status == PermissionStatus.inactive;

  /// Kullanımdan kaldırıldı mı?
  bool get isDeprecated => status == PermissionStatus.deprecated;

  /// Görünen ad var mı?
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Kaynak var mı?
  bool get hasResource => resource != null && resource!.isNotEmpty;

  /// Aksiyon var mı?
  bool get hasAction => action != null && action!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Bağımlılık var mı?
  bool get hasDependencies => dependencies.isNotEmpty;

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

  /// Rol sayısı var mı?
  bool get hasRoleCount => roleCount != null && roleCount! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return isActive && !isDeprecated;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isActive && (roleCount == null || roleCount == 0);
  }

  /// Kullanımdan kaldırılabilir mi?
  bool get canBeDeprecated {
    return isActive;
  }

  /// Aktifleştirilebilir mi?
  bool get canBeActivated {
    return isInactive;
  }

  /// Bağımlılık eklenebilir mi?
  bool get canAddDependency {
    return isActive;
  }

  /// Bağımlılık kaldırılabilir mi?
  bool get canRemoveDependency {
    return isActive;
  }

  /// Toplam bağımlılık sayısı
  int get totalDependenciesCount => dependencies.length;

  /// Belirli bağımlılığa sahip mi?
  bool hasDependency(String dependencyId) {
    return dependencies.contains(dependencyId);
  }

  /// Belirli bağımlılıklara sahip mi?
  bool hasAllDependencies(List<String> requiredDependencies) {
    return requiredDependencies
        .every((dependency) => dependencies.contains(dependency));
  }

  /// Belirli bağımlılıklardan herhangi birine sahip mi?
  bool hasAnyDependency(List<String> requiredDependencies) {
    return requiredDependencies
        .any((dependency) => dependencies.contains(dependency));
  }

  /// Rol sayısı sıfır mı?
  bool get isZeroRoleCount => roleCount == null || roleCount == 0;

  /// Rol sayısı yüksek mi? (50'den fazla)
  bool get isHighRoleCount => roleCount != null && roleCount! > 50;

  /// Rol sayısı düşük mi? (5'ten az)
  bool get isLowRoleCount => roleCount != null && roleCount! < 5;

  /// Rol sayısı orta mı? (5-50 arası)
  bool get isMediumRoleCount =>
      roleCount != null && roleCount! >= 5 && roleCount! <= 50;

  /// Rol sayısı kategorisi
  String get roleCountCategory {
    if (isHighRoleCount) return 'Yüksek';
    if (isLowRoleCount) return 'Düşük';
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

  /// Kritik izin mi?
  bool get isCriticalPermission {
    return isAdminPermission ||
        (hasResource && hasAction && (action == 'delete' || action == 'admin'));
  }

  /// Güvenli izin mi?
  bool get isSafePermission {
    return isReadPermission ||
        (hasResource && hasAction && (action == 'read' || action == 'view'));
  }

  /// Riskli izin mi?
  bool get isRiskyPermission {
    return isDeletePermission ||
        (hasResource &&
            hasAction &&
            (action == 'delete' || action == 'admin' || action == 'execute'));
  }

  @override
  String toString() {
    return 'Permission(id: $id, name: $name, type: $type, status: $status, resource: $resource, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
