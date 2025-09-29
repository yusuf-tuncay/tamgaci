import 'package:equatable/equatable.dart';

/// Depo Transfer Entity
class WarehouseTransfer extends Equatable {
  final String id;
  final String tenantId;
  final String productId;
  final String productName;
  final String fromWarehouseId;
  final String fromWarehouseName;
  final String toWarehouseId;
  final String toWarehouseName;
  final int quantity;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // 'pending', 'completed', 'cancelled'

  const WarehouseTransfer({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.productName,
    required this.fromWarehouseId,
    required this.fromWarehouseName,
    required this.toWarehouseId,
    required this.toWarehouseName,
    required this.quantity,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        productId,
        productName,
        fromWarehouseId,
        fromWarehouseName,
        toWarehouseId,
        toWarehouseName,
        quantity,
        notes,
        createdBy,
        createdAt,
        updatedAt,
        status,
      ];

  WarehouseTransfer copyWith({
    String? id,
    String? tenantId,
    String? productId,
    String? productName,
    String? fromWarehouseId,
    String? fromWarehouseName,
    String? toWarehouseId,
    String? toWarehouseName,
    int? quantity,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return WarehouseTransfer(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      fromWarehouseName: fromWarehouseName ?? this.fromWarehouseName,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      toWarehouseName: toWarehouseName ?? this.toWarehouseName,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'productId': productId,
      'productName': productName,
      'fromWarehouseId': fromWarehouseId,
      'fromWarehouseName': fromWarehouseName,
      'toWarehouseId': toWarehouseId,
      'toWarehouseName': toWarehouseName,
      'quantity': quantity,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
    };
  }

  factory WarehouseTransfer.fromJson(Map<String, dynamic> json) {
    return WarehouseTransfer(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      fromWarehouseId: json['fromWarehouseId'] as String,
      fromWarehouseName: json['fromWarehouseName'] as String,
      toWarehouseId: json['toWarehouseId'] as String,
      toWarehouseName: json['toWarehouseName'] as String,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      status: json['status'] as String,
    );
  }
}
