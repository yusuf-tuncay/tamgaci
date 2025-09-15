// ========== STOCK MOVEMENT ==========
// lib/features/inventory/domain/entities/stock_movement.dart

/// Stok hareket tipi enum'u
enum StockMovementType {
  in_('Giriş'),
  out('Çıkış'),
  transfer('Transfer'),
  adjustment('Düzeltme'),
  return_('İade');

  const StockMovementType(this.displayName);
  final String displayName;
}

/// Stok hareket entity'si
class StockMovement {
  final String id;
  final String productId;
  final String warehouseId;
  final StockMovementType type;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime movementDate;
  final String? reference;
  final String? notes;
  final String companyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.movementDate,
    this.reference,
    this.notes,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });
}
