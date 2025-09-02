// ========== STOCK MOVEMENT DATA MODEL ==========
// lib/features/inventory/data/models/stock_movement_entity.dart

import 'package:floor/floor.dart';

/// Stok hareket entity modeli
@Entity(tableName: 'stock_movements')
class StockMovementEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;

  @ColumnInfo(name: 'stockId')
  final int stockId;

  @ColumnInfo(name: 'type')
  final String type;

  @ColumnInfo(name: 'quantity')
  final double quantity;

  @ColumnInfo(name: 'previousQuantity')
  final double? previousQuantity;

  @ColumnInfo(name: 'newQuantity')
  final double? newQuantity;

  @ColumnInfo(name: 'reason')
  final String? reason;

  @ColumnInfo(name: 'reference')
  final String? reference;

  @ColumnInfo(name: 'notes')
  final String? notes;

  @ColumnInfo(name: 'createdAt')
  final DateTime createdAt;

  @ColumnInfo(name: 'createdBy')
  final String? createdBy;

  const StockMovementEntity({
    required this.id,
    required this.stockId,
    required this.type,
    required this.quantity,
    this.previousQuantity,
    this.newQuantity,
    this.reason,
    this.reference,
    this.notes,
    required this.createdAt,
    this.createdBy,
  });

  /// Map'ten StockMovementEntity oluşturur
  factory StockMovementEntity.fromMap(Map<String, dynamic> map) {
    return StockMovementEntity(
      id: map['id']?.toInt() ?? 0,
      stockId: map['stockId']?.toInt() ?? 0,
      type: map['type'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      previousQuantity: map['previousQuantity']?.toDouble(),
      newQuantity: map['newQuantity']?.toDouble(),
      reason: map['reason'],
      reference: map['reference'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
    );
  }

  /// StockMovementEntity'yi Map'e çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stockId': stockId,
      'type': type,
      'quantity': quantity,
      'previousQuantity': previousQuantity,
      'newQuantity': newQuantity,
      'reason': reason,
      'reference': reference,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  /// Copy with method
  StockMovementEntity copyWith({
    int? id,
    int? stockId,
    String? type,
    double? quantity,
    double? previousQuantity,
    double? newQuantity,
    String? reason,
    String? reference,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return StockMovementEntity(
      id: id ?? this.id,
      stockId: stockId ?? this.stockId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      previousQuantity: previousQuantity ?? this.previousQuantity,
      newQuantity: newQuantity ?? this.newQuantity,
      reason: reason ?? this.reason,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'StockMovementEntity(id: $id, stockId: $stockId, type: $type, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockMovementEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
