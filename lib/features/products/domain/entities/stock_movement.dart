// ========== STOCK MOVEMENT ENTITY ==========
// lib/features/products/domain/entities/stock_movement.dart

import 'accounting_enums.dart';

/// Stok hareket entity'si - Muhasebe takibi için
class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final StockMovementType type;
  final StockMovementDirection direction;
  final StockMovementStatus status;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String? referenceDocument;
  final String? referenceNumber;
  final DateTime movementDate;
  final String? warehouseId;
  final String? warehouseName;
  final String? locationId;
  final String? locationName;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? serialNumber;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.direction,
    required this.status,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.referenceDocument,
    this.referenceNumber,
    required this.movementDate,
    this.warehouseId,
    this.warehouseName,
    this.locationId,
    this.locationName,
    this.batchNumber,
    this.expiryDate,
    this.serialNumber,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
  });

  /// Stok hareketi oluştur
  factory StockMovement.create({
    required String productId,
    required String productName,
    required StockMovementType type,
    required StockMovementDirection direction,
    required int quantity,
    required double unitPrice,
    required String createdBy,
    String? referenceDocument,
    String? referenceNumber,
    String? warehouseId,
    String? warehouseName,
    String? locationId,
    String? locationName,
    String? batchNumber,
    DateTime? expiryDate,
    String? serialNumber,
    String? notes,
  }) {
    return StockMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: productId,
      productName: productName,
      type: type,
      direction: direction,
      status: StockMovementStatus.pending,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: quantity * unitPrice,
      referenceDocument: referenceDocument,
      referenceNumber: referenceNumber,
      movementDate: DateTime.now(),
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      locationId: locationId,
      locationName: locationName,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      serialNumber: serialNumber,
      notes: notes,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
  }

  /// Stok hareketini onayla
  StockMovement approve(String approvedBy) {
    return copyWith(
      status: StockMovementStatus.approved,
      approvedBy: approvedBy,
      approvedAt: DateTime.now(),
    );
  }

  /// Stok hareketini reddet
  StockMovement reject(String rejectedBy, String rejectionReason) {
    return copyWith(
      status: StockMovementStatus.rejected,
      rejectedBy: rejectedBy,
      rejectedAt: DateTime.now(),
      rejectionReason: rejectionReason,
    );
  }

  /// Stok hareketini iptal et
  StockMovement cancel() {
    return copyWith(
      status: StockMovementStatus.cancelled,
    );
  }

  /// Stok hareketini kopyala ve güncelle
  StockMovement copyWith({
    String? id,
    String? productId,
    String? productName,
    StockMovementType? type,
    StockMovementDirection? direction,
    StockMovementStatus? status,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    String? referenceDocument,
    String? referenceNumber,
    DateTime? movementDate,
    String? warehouseId,
    String? warehouseName,
    String? locationId,
    String? locationName,
    String? batchNumber,
    DateTime? expiryDate,
    String? serialNumber,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectedBy,
    DateTime? rejectedAt,
    String? rejectionReason,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      referenceDocument: referenceDocument ?? this.referenceDocument,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      movementDate: movementDate ?? this.movementDate,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      serialNumber: serialNumber ?? this.serialNumber,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type.name,
      'direction': direction.name,
      'status': status.name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'referenceDocument': referenceDocument,
      'referenceNumber': referenceNumber,
      'movementDate': movementDate.toIso8601String(),
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'locationId': locationId,
      'locationName': locationName,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'serialNumber': serialNumber,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  /// JSON'dan oluştur
  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      type: StockMovementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StockMovementType.purchase,
      ),
      direction: StockMovementDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => StockMovementDirection.stockIn,
      ),
      status: StockMovementStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockMovementStatus.pending,
      ),
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      referenceDocument: json['referenceDocument'],
      referenceNumber: json['referenceNumber'],
      movementDate: DateTime.parse(json['movementDate']),
      warehouseId: json['warehouseId'],
      warehouseName: json['warehouseName'],
      locationId: json['locationId'],
      locationName: json['locationName'],
      batchNumber: json['batchNumber'],
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      serialNumber: json['serialNumber'],
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      rejectedBy: json['rejectedBy'],
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
    );
  }
}
