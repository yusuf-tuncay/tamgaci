import 'package:equatable/equatable.dart';

/// Envanter hareket türü
enum InventoryMovementType {
  incoming('Giriş'),
  outgoing('Çıkış'),
  transfer('Transfer'),
  adjustment('Düzeltme'),
  returnIn('İade Giriş'),
  returnOut('İade Çıkış'),
  loss('Kayıp'),
  found('Buluntu');

  const InventoryMovementType(this.displayName);
  final String displayName;
}

/// Envanter hareket durumu
enum InventoryMovementStatus {
  pending('Beklemede'),
  completed('Tamamlandı'),
  cancelled('İptal'),
  failed('Başarısız');

  const InventoryMovementStatus(this.displayName);
  final String displayName;
}

/// Envanter hareket entity'si
class InventoryMovement extends Equatable {
  final String id;
  final String movementNumber;
  final InventoryMovementType type;
  final InventoryMovementStatus status;
  final String itemId;
  final String? itemName;
  final String? itemSku;
  final double quantity;
  final String unit;
  final double unitCost;
  final double totalCost;
  final String? fromLocation;
  final String? toLocation;
  final String? reference;
  final String? referenceId;
  final String? referenceType;
  final String? description;
  final String? notes;
  final DateTime movementDate;
  final DateTime? processedDate;
  final String? processedBy;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const InventoryMovement({
    required this.id,
    required this.movementNumber,
    required this.type,
    required this.status,
    required this.itemId,
    this.itemName,
    this.itemSku,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.totalCost,
    this.fromLocation,
    this.toLocation,
    this.reference,
    this.referenceId,
    this.referenceType,
    this.description,
    this.notes,
    required this.movementDate,
    this.processedDate,
    this.processedBy,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  InventoryMovement copyWith({
    String? id,
    String? movementNumber,
    InventoryMovementType? type,
    InventoryMovementStatus? status,
    String? itemId,
    String? itemName,
    String? itemSku,
    double? quantity,
    String? unit,
    double? unitCost,
    double? totalCost,
    String? fromLocation,
    String? toLocation,
    String? reference,
    String? referenceId,
    String? referenceType,
    String? description,
    String? notes,
    DateTime? movementDate,
    DateTime? processedDate,
    String? processedBy,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return InventoryMovement(
      id: id ?? this.id,
      movementNumber: movementNumber ?? this.movementNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemSku: itemSku ?? this.itemSku,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      reference: reference ?? this.reference,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      movementDate: movementDate ?? this.movementDate,
      processedDate: processedDate ?? this.processedDate,
      processedBy: processedBy ?? this.processedBy,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movementNumber': movementNumber,
      'type': type.name,
      'status': status.name,
      'itemId': itemId,
      'itemName': itemName,
      'itemSku': itemSku,
      'quantity': quantity,
      'unit': unit,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'reference': reference,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'description': description,
      'notes': notes,
      'movementDate': movementDate.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'processedBy': processedBy,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
      id: json['id'] as String,
      movementNumber: json['movementNumber'] as String,
      type: InventoryMovementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InventoryMovementType.incoming,
      ),
      status: InventoryMovementStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InventoryMovementStatus.pending,
      ),
      itemId: json['itemId'] as String,
      itemName: json['itemName'] as String?,
      itemSku: json['itemSku'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitCost: (json['unitCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      fromLocation: json['fromLocation'] as String?,
      toLocation: json['toLocation'] as String?,
      reference: json['reference'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      movementDate: DateTime.parse(json['movementDate'] as String),
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'] as String)
          : null,
      processedBy: json['processedBy'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        movementNumber,
        type,
        status,
        itemId,
        itemName,
        itemSku,
        quantity,
        unit,
        unitCost,
        totalCost,
        fromLocation,
        toLocation,
        reference,
        referenceId,
        referenceType,
        description,
        notes,
        movementDate,
        processedDate,
        processedBy,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
