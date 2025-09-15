// ========== WAREHOUSE ENUMS ==========
// lib/features/products/domain/entities/warehouse_enums.dart

/// Depo türü enum'u
enum WarehouseType {
  main,
  branch,
  temporary,
  cold,
  hazardous,
  warehouse;

  String get displayName {
    switch (this) {
      case WarehouseType.main:
        return 'Ana Depo';
      case WarehouseType.branch:
        return 'Şube Deposu';
      case WarehouseType.temporary:
        return 'Geçici Depo';
      case WarehouseType.cold:
        return 'Soğuk Depo';
      case WarehouseType.hazardous:
        return 'Tehlikeli Madde Deposu';
      case WarehouseType.warehouse:
        return 'Depo';
    }
  }
}

/// Depo durumu enum'u
enum WarehouseStatus {
  active,
  inactive,
  maintenance,
  full;

  String get displayName {
    switch (this) {
      case WarehouseStatus.active:
        return 'Aktif';
      case WarehouseStatus.inactive:
        return 'Pasif';
      case WarehouseStatus.maintenance:
        return 'Bakımda';
      case WarehouseStatus.full:
        return 'Dolu';
    }
  }
}
