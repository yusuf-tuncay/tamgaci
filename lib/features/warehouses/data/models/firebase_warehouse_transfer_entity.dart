import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/warehouse_transfer.dart';

/// Firebase Warehouse Transfer Entity
class FirebaseWarehouseTransferEntity {
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
  final String status;

  const FirebaseWarehouseTransferEntity({
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

  factory FirebaseWarehouseTransferEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FirebaseWarehouseTransferEntity(
      id: doc.id,
      tenantId: data['tenantId'] as String,
      productId: data['productId'] as String,
      productName: data['productName'] as String,
      fromWarehouseId: data['fromWarehouseId'] as String,
      fromWarehouseName: data['fromWarehouseName'] as String,
      toWarehouseId: data['toWarehouseId'] as String,
      toWarehouseName: data['toWarehouseName'] as String,
      quantity: data['quantity'] as int,
      notes: data['notes'] as String?,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      status: data['status'] as String,
    );
  }

  WarehouseTransfer toDomain() {
    return WarehouseTransfer(
      id: id,
      tenantId: tenantId,
      productId: productId,
      productName: productName,
      fromWarehouseId: fromWarehouseId,
      fromWarehouseName: fromWarehouseName,
      toWarehouseId: toWarehouseId,
      toWarehouseName: toWarehouseName,
      quantity: quantity,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
    );
  }

  factory FirebaseWarehouseTransferEntity.fromDomain(
    WarehouseTransfer transfer,
  ) {
    return FirebaseWarehouseTransferEntity(
      id: transfer.id,
      tenantId: transfer.tenantId,
      productId: transfer.productId,
      productName: transfer.productName,
      fromWarehouseId: transfer.fromWarehouseId,
      fromWarehouseName: transfer.fromWarehouseName,
      toWarehouseId: transfer.toWarehouseId,
      toWarehouseName: transfer.toWarehouseName,
      quantity: transfer.quantity,
      notes: transfer.notes,
      createdBy: transfer.createdBy,
      createdAt: transfer.createdAt,
      updatedAt: transfer.updatedAt,
      status: transfer.status,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'status': status,
    };
  }

  FirebaseWarehouseTransferEntity copyWith({
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
    return FirebaseWarehouseTransferEntity(
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
}
