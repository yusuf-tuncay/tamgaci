// ========== USER PERMISSION ENTITY ==========
// lib/features/products/domain/entities/user_permission.dart

/// Kullanıcı yetki seviyeleri
enum PermissionLevel {
  read('Okuma'),
  write('Yazma'),
  admin('Yönetici'),
  owner('Sahip');

  const PermissionLevel(this.displayName);
  final String displayName;
}

/// Ürün işlem yetkileri
class ProductPermissions {
  final bool canCreate;
  final bool canRead;
  final bool canUpdate;
  final bool canDelete;
  final bool canViewPrices;
  final bool canModifyPrices;
  final bool canViewCosts;
  final bool canModifyCosts;
  final bool canExport;
  final bool canImport;

  ProductPermissions({
    required this.canCreate,
    required this.canRead,
    required this.canUpdate,
    required this.canDelete,
    required this.canViewPrices,
    required this.canModifyPrices,
    required this.canViewCosts,
    required this.canModifyCosts,
    required this.canExport,
    required this.canImport,
  });

  /// Yetki seviyesine göre izinler oluştur
  factory ProductPermissions.fromLevel(PermissionLevel level) {
    switch (level) {
      case PermissionLevel.read:
        return ProductPermissions(
          canCreate: false,
          canRead: true,
          canUpdate: false,
          canDelete: false,
          canViewPrices: true,
          canModifyPrices: false,
          canViewCosts: false,
          canModifyCosts: false,
          canExport: true,
          canImport: false,
        );
      case PermissionLevel.write:
        return ProductPermissions(
          canCreate: true,
          canRead: true,
          canUpdate: true,
          canDelete: false,
          canViewPrices: true,
          canModifyPrices: true,
          canViewCosts: true,
          canModifyCosts: true,
          canExport: true,
          canImport: true,
        );
      case PermissionLevel.admin:
        return ProductPermissions(
          canCreate: true,
          canRead: true,
          canUpdate: true,
          canDelete: true,
          canViewPrices: true,
          canModifyPrices: true,
          canViewCosts: true,
          canModifyCosts: true,
          canExport: true,
          canImport: true,
        );
      case PermissionLevel.owner:
        return ProductPermissions(
          canCreate: true,
          canRead: true,
          canUpdate: true,
          canDelete: true,
          canViewPrices: true,
          canModifyPrices: true,
          canViewCosts: true,
          canModifyCosts: true,
          canExport: true,
          canImport: true,
        );
    }
  }
}

/// Kullanıcı yetki kontrolü
class PermissionChecker {
  static bool checkProductPermission(
    ProductPermissions permissions,
    String action,
  ) {
    switch (action) {
      case 'create':
        return permissions.canCreate;
      case 'read':
        return permissions.canRead;
      case 'update':
        return permissions.canUpdate;
      case 'delete':
        return permissions.canDelete;
      case 'view_prices':
        return permissions.canViewPrices;
      case 'modify_prices':
        return permissions.canModifyPrices;
      case 'view_costs':
        return permissions.canViewCosts;
      case 'modify_costs':
        return permissions.canModifyCosts;
      case 'export':
        return permissions.canExport;
      case 'import':
        return permissions.canImport;
      default:
        return false;
    }
  }
}
