// ========== STOCK MOVEMENT DOMAIN ENTITY ==========
// lib/features/inventory/domain/entities/stock_movement.dart

import 'package:flutter/material.dart';

/// Stok hareketi türleri
enum StockMovementType {
  in_,    // Stok girişi
  out,    // Stok çıkışı
  adjust, // Stok düzeltme
  transfer, // Stok transferi
}

/// Stok hareketi entity'si
class StockMovement {
  final int id;
  final int stockId;
  final StockMovementType type;
  final double quantity;
  final double? previousQuantity;
  final double? newQuantity;
  final String? reason;
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  final String? createdBy;

  const StockMovement({
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

  /// Copy with method
  StockMovement copyWith({
    int? id,
    int? stockId,
    StockMovementType? type,
    double? quantity,
    double? previousQuantity,
    double? newQuantity,
    String? reason,
    String? reference,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return StockMovement(
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

  /// Map'ten StockMovement oluşturur
  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id']?.toInt() ?? 0,
      stockId: map['stockId']?.toInt() ?? 0,
      type: StockMovementType.values.firstWhere(
        (e) => e.toString() == 'StockMovementType.${map['type']}',
        orElse: () => StockMovementType.in_,
      ),
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

  /// StockMovement'u Map'e çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stockId': stockId,
      'type': type.toString().split('.').last,
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

  @override
  String toString() {
    return 'StockMovement(id: $id, stockId: $stockId, type: $type, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockMovement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// StockMovementType için extension
extension StockMovementTypeExtension on StockMovementType {
  String get displayName {
    switch (this) {
      case StockMovementType.in_:
        return 'Stok Girişi';
      case StockMovementType.out:
        return 'Stok Çıkışı';
      case StockMovementType.adjust:
        return 'Stok Düzeltme';
      case StockMovementType.transfer:
        return 'Stok Transferi';
    }
  }

  String get shortName {
    switch (this) {
      case StockMovementType.in_:
        return 'Giriş';
      case StockMovementType.out:
        return 'Çıkış';
      case StockMovementType.adjust:
        return 'Düzeltme';
      case StockMovementType.transfer:
        return 'Transfer';
    }
  }

  IconData get icon {
    switch (this) {
      case StockMovementType.in_:
        return Icons.add_box;
      case StockMovementType.out:
        return Icons.remove_circle;
      case StockMovementType.adjust:
        return Icons.edit;
      case StockMovementType.transfer:
        return Icons.swap_horiz;
    }
  }

  Color get color {
    switch (this) {
      case StockMovementType.in_:
        return Colors.green;
      case StockMovementType.out:
        return Colors.red;
      case StockMovementType.adjust:
        return Colors.blue;
      case StockMovementType.transfer:
        return Colors.orange;
    }
  }
}
