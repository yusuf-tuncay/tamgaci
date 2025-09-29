// ========== FIREBASE PAYMENT ENTITY ==========
// lib/features/payments/data/models/firebase_payment_entity.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/entities/payment_status.dart';

/// Firebase için optimize edilmiş tahsilat entity'si
class FirebasePaymentEntity {
  final String id;
  final String tenantId; // Multi-tenant güvenlik için zorunlu
  final String customerId;
  final String customerName;
  final String type; // PaymentType enum değeri
  final String status; // PaymentStatus enum değeri
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

  const FirebasePaymentEntity({
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

  /// Domain entity'den Firebase entity'ye dönüştürme
  factory FirebasePaymentEntity.fromDomain(Payment payment) {
    return FirebasePaymentEntity(
      id: payment.id,
      tenantId: payment.tenantId,
      customerId: payment.customerId,
      customerName: payment.customerName,
      type: payment.type.name,
      status: payment.status.name,
      amount: payment.amount,
      currency: payment.currency,
      description: payment.description,
      paymentDate: payment.paymentDate,
      dueDate: payment.dueDate,
      reference: payment.reference,
      bankAccount: payment.bankAccount,
      checkNumber: payment.checkNumber,
      promissoryNoteNumber: payment.promissoryNoteNumber,
      createdAt: payment.createdAt,
      updatedAt: payment.updatedAt,
      createdBy: payment.createdBy,
      updatedBy: payment.updatedBy,
    );
  }

  /// Firebase'den domain entity'ye dönüştürme
  Payment toDomain() {
    return Payment(
      id: id,
      tenantId: tenantId,
      customerId: customerId,
      customerName: customerName,
      type: PaymentType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => PaymentType.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => PaymentStatus.pending,
      ),
      amount: amount,
      currency: currency,
      description: description,
      paymentDate: paymentDate,
      dueDate: dueDate,
      reference: reference,
      bankAccount: bankAccount,
      checkNumber: checkNumber,
      promissoryNoteNumber: promissoryNoteNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Firebase Firestore'dan entity oluşturma
  factory FirebasePaymentEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebasePaymentEntity(
      id: doc.id,
      tenantId: data['tenantId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      type: data['type'] ?? 'cash',
      status: data['status'] ?? 'pending',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      description: data['description'],
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      reference: data['reference'],
      bankAccount: data['bankAccount'],
      checkNumber: data['checkNumber'],
      promissoryNoteNumber: data['promissoryNoteNumber'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'],
    );
  }

  /// Firebase Firestore'a gönderme için Map dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'tenantId': tenantId,
      'customerId': customerId,
      'customerName': customerName,
      'type': type,
      'status': status,
      'amount': amount,
      'currency': currency,
      'description': description,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'reference': reference,
      'bankAccount': bankAccount,
      'checkNumber': checkNumber,
      'promissoryNoteNumber': promissoryNoteNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Entity kopyalama
  FirebasePaymentEntity copyWith({
    String? id,
    String? tenantId,
    String? customerId,
    String? customerName,
    String? type,
    String? status,
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
    return FirebasePaymentEntity(
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
