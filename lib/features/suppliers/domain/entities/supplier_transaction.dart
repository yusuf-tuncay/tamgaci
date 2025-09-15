// ========== SUPPLIER TRANSACTION DOMAIN ENTITY ==========
// lib/features/suppliers/domain/entities/supplier_transaction.dart

import 'package:flutter/material.dart';
import 'supplier.dart';

/// Tedarikçi işlem türü enum'u
enum SupplierTransactionType {
  purchase('Alış', 'ALIŞ', Icons.shopping_cart),
  invoice('Fatura', 'FAT', Icons.receipt),
  payment('Ödeme', 'ODEME', Icons.payment),
  credit('Kredi', 'KREDI', Icons.add_circle),
  debit('Borç', 'BORC', Icons.remove_circle),
  return_('İade', 'IADE', Icons.keyboard_return);

  const SupplierTransactionType(this.displayName, this.shortName, this.icon);
  final String displayName;
  final String shortName;
  final IconData icon;
}

/// Tedarikçi işlem durumu enum'u
enum SupplierTransactionStatus {
  pending('Beklemede'),
  paid('Ödendi'),
  overdue('Vadesi Geçmiş'),
  cancelled('İptal'),
  partial('Kısmi');

  const SupplierTransactionStatus(this.displayName);
  final String displayName;
}

/// Tedarikçi işlem geçmişi entity'si
class SupplierTransaction {
  final String id;
  final String supplierId;
  final SupplierTransactionType type;
  final String documentNumber; // Fatura, irsaliye, proforma numarası
  final double amount;
  final String currency;
  final DateTime transactionDate;
  final DateTime dueDate;
  final SupplierTransactionStatus status;
  final String? description;
  final DateTime createdAt;
  final String? createdBy;

  // Navigation properties (optional, for UI purposes)
  final Supplier? supplier;

  const SupplierTransaction({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.documentNumber,
    required this.amount,
    required this.currency,
    required this.transactionDate,
    required this.dueDate,
    required this.status,
    this.description,
    required this.createdAt,
    this.createdBy,
    this.supplier,
  });

  /// Vade günü hesaplama
  int get daysUntilDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference;
  }

  /// Copy with method
  SupplierTransaction copyWith({
    String? id,
    String? supplierId,
    SupplierTransactionType? type,
    String? documentNumber,
    double? amount,
    String? currency,
    DateTime? transactionDate,
    DateTime? dueDate,
    SupplierTransactionStatus? status,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    Supplier? supplier,
  }) {
    return SupplierTransaction(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      type: type ?? this.type,
      documentNumber: documentNumber ?? this.documentNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      supplier: supplier ?? this.supplier,
    );
  }

  /// Map'ten SupplierTransaction oluşturur
  factory SupplierTransaction.fromMap(Map<String, dynamic> map) {
    return SupplierTransaction(
      id: (map['id']?.toString()) ?? '',
      supplierId: (map['supplierId']?.toString()) ?? '',
      type: SupplierTransactionType.values[map['type'] ?? 0],
      documentNumber: map['documentNumber'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'TRY',
      transactionDate: DateTime.parse(map['transactionDate']),
      dueDate: DateTime.parse(map['dueDate']),
      status: SupplierTransactionStatus.values[map['status'] ?? 0],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
    );
  }

  /// Map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'type': type.index,
      'documentNumber': documentNumber,
      'amount': amount,
      'currency': currency,
      'transactionDate': transactionDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.index,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SupplierTransaction(id: $id, type: $type, amount: $amount)';
  }
}
