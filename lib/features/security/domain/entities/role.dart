// ========== ROLE ENTITY ==========
// lib/features/security/domain/entities/role.dart

/// Rol türü
enum RoleType {
  system('Sistem Rolü'),
  business('İş Rolü'),
  custom('Özel Rol');

  const RoleType(this.displayName);
  final String displayName;
}

/// Rol durumu
enum RoleStatus {
  active('Aktif'),
  inactive('Pasif'),
  suspended('Askıya Alındı'),
  deleted('Silindi');

  const RoleStatus(this.displayName);
  final String displayName;
}

/// Rol entity'si
class Role {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final RoleType type;
  final RoleStatus status;
  final String? category;
  final String? tags;
  final List<String> permissions; // İzinler
  final List<String> parentRoles; // Üst roller
  final List<String> childRoles; // Alt roller
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final String? updatedBy; // Güncelleyen kullanıcı ID'si
  final String? updatedByName; // Güncelleyen kullanıcı adı
  final DateTime? lastUsedDate; // Son kullanım tarihi
  final int? userCount; // Kullanıcı sayısı
  final String? notes; // Notlar
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const Role({
    required this.id,
    required this.name,
    this.displayName,
    this.description,
    required this.type,
    required this.status,
    this.category,
    this.tags,
    this.permissions = const [],
    this.parentRoles = const [],
    this.childRoles = const [],
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
    this.lastUsedDate,
    this.userCount,
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  Role copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    RoleType? type,
    RoleStatus? status,
    String? category,
    String? tags,
    List<String>? permissions,
    List<String>? parentRoles,
    List<String>? childRoles,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? updatedByName,
    DateTime? lastUsedDate,
    int? userCount,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      permissions: permissions ?? this.permissions,
      parentRoles: parentRoles ?? this.parentRoles,
      childRoles: childRoles ?? this.childRoles,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      userCount: userCount ?? this.userCount,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan Role oluştur
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      type: RoleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoleType.business,
      ),
      status: RoleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoleStatus.active,
      ),
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      permissions: List<String>.from(json['permissions'] ?? []),
      parentRoles: List<String>.from(json['parentRoles'] ?? []),
      childRoles: List<String>.from(json['childRoles'] ?? []),
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedByName: json['updatedByName'] as String?,
      lastUsedDate: json['lastUsedDate'] != null
          ? DateTime.parse(json['lastUsedDate'] as String)
          : null,
      userCount: json['userCount'] as int?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Role'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'type': type.name,
      'status': status.name,
      'category': category,
      'tags': tags,
      'permissions': permissions,
      'parentRoles': parentRoles,
      'childRoles': childRoles,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'lastUsedDate': lastUsedDate?.toIso8601String(),
      'userCount': userCount,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Sistem rolü mü?
  bool get isSystemRole => type == RoleType.system;

  /// İş rolü mü?
  bool get isBusinessRole => type == RoleType.business;

  /// Özel rol mü?
  bool get isCustomRole => type == RoleType.custom;

  /// Aktif mi?
  bool get isActive => status == RoleStatus.active;

  /// Pasif mi?
  bool get isInactive => status == RoleStatus.inactive;

  /// Askıya alındı mı?
  bool get isSuspended => status == RoleStatus.suspended;

  /// Silindi mi?
  bool get isDeleted => status == RoleStatus.deleted;

  /// Görünen ad var mı?
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// İzin var mı?
  bool get hasPermissions => permissions.isNotEmpty;

  /// Üst rol var mı?
  bool get hasParentRoles => parentRoles.isNotEmpty;

  /// Alt rol var mı?
  bool get hasChildRoles => childRoles.isNotEmpty;

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

  /// Kullanıcı sayısı var mı?
  bool get hasUserCount => userCount != null && userCount! > 0;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Düzenlenebilir mi?
  bool get canBeEdited {
    return isActive && !isSystemRole;
  }

  /// Silinebilir mi?
  bool get canBeDeleted {
    return isActive && !isSystemRole && (userCount == null || userCount == 0);
  }

  /// Askıya alınabilir mi?
  bool get canBeSuspended {
    return isActive;
  }

  /// Aktifleştirilebilir mi?
  bool get canBeActivated {
    return isInactive || isSuspended;
  }

  /// İzin eklenebilir mi?
  bool get canAddPermission {
    return isActive;
  }

  /// İzin kaldırılabilir mi?
  bool get canRemovePermission {
    return isActive;
  }

  /// Toplam izin sayısı
  int get totalPermissionsCount => permissions.length;

  /// Toplam üst rol sayısı
  int get totalParentRolesCount => parentRoles.length;

  /// Toplam alt rol sayısı
  int get totalChildRolesCount => childRoles.length;

  /// Belirli izne sahip mi?
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Belirli izinlere sahip mi?
  bool hasAllPermissions(List<String> requiredPermissions) {
    return requiredPermissions
        .every((permission) => permissions.contains(permission));
  }

  /// Belirli izinlerden herhangi birine sahip mi?
  bool hasAnyPermission(List<String> requiredPermissions) {
    return requiredPermissions
        .any((permission) => permissions.contains(permission));
  }

  /// Belirli üst role sahip mi?
  bool hasParentRole(String roleId) {
    return parentRoles.contains(roleId);
  }

  /// Belirli alt role sahip mi?
  bool hasChildRole(String roleId) {
    return childRoles.contains(roleId);
  }

  /// Kullanıcı sayısı sıfır mı?
  bool get isZeroUserCount => userCount == null || userCount == 0;

  /// Kullanıcı sayısı yüksek mi? (100'den fazla)
  bool get isHighUserCount => userCount != null && userCount! > 100;

  /// Kullanıcı sayısı düşük mi? (10'dan az)
  bool get isLowUserCount => userCount != null && userCount! < 10;

  /// Kullanıcı sayısı orta mı? (10-100 arası)
  bool get isMediumUserCount =>
      userCount != null && userCount! >= 10 && userCount! <= 100;

  /// Kullanıcı sayısı kategorisi
  String get userCountCategory {
    if (isHighUserCount) return 'Yüksek';
    if (isLowUserCount) return 'Düşük';
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

  @override
  String toString() {
    return 'Role(id: $id, name: $name, type: $type, status: $status, permissionsCount: $totalPermissionsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
