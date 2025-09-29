// ========== PAYMENT ENTITY ==========
// lib/features/payments/domain/entities/payment.dart

import 'payment_type.dart';
import 'payment_status.dart';

class Payment {
  final String id;
  final String tenantId; // Multi-tenant güvenlik için zorunlu
  final String customerId;
  final String customerName;
  final PaymentType type;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String? description;
  final DateTime paymentDate;
  final DateTime? dueDate;
  final String? reference;
  final String? bankAccount;
  final String? checkNumber;
  final String? promissoryNoteNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const Payment({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.description,
    required this.paymentDate,
    this.dueDate,
    this.reference,
    this.bankAccount,
    this.checkNumber,
    this.promissoryNoteNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  Payment copyWith({
    String? id,
    String? tenantId,
    String? customerId,
    String? customerName,
    PaymentType? type,
    PaymentStatus? status,
    double? amount,
    String? currency,
    String? description,
    DateTime? paymentDate,
    DateTime? dueDate,
    String? reference,
    String? bankAccount,
    String? checkNumber,
    String? promissoryNoteNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Payment(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      paymentDate: paymentDate ?? this.paymentDate,
      dueDate: dueDate ?? this.dueDate,
      reference: reference ?? this.reference,
      bankAccount: bankAccount ?? this.bankAccount,
      checkNumber: checkNumber ?? this.checkNumber,
      promissoryNoteNumber: promissoryNoteNumber ?? this.promissoryNoteNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
