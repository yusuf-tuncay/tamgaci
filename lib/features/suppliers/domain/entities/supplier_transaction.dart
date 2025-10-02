// ========== SUPPLIER TRANSACTION ENTITY ==========
// lib/features/suppliers/domain/entities/supplier_transaction.dart

import 'package:flutter/material.dart';
import 'supplier_enums.dart';

/// Tedarikçi işlem türü enum'u
enum SupplierTransactionType {
  /// Alış faturası
  purchase,

  /// Ödeme
  payment,

  /// İade
  refund,

  /// İndirim
  discount,

  /// Fatura
  invoice,

  /// Kredi
  credit,

  /// Borç
  debit,

  /// İade
  return_,

  /// Diğer
  other;

  String get displayName {
    switch (this) {
      case SupplierTransactionType.purchase:
        return 'Alış Faturası';
      case SupplierTransactionType.payment:
        return 'Ödeme';
      case SupplierTransactionType.refund:
        return 'İade';
      case SupplierTransactionType.discount:
        return 'İndirim';
      case SupplierTransactionType.invoice:
        return 'Fatura';
      case SupplierTransactionType.credit:
        return 'Kredi';
      case SupplierTransactionType.debit:
        return 'Borç';
      case SupplierTransactionType.return_:
        return 'İade';
      case SupplierTransactionType.other:
        return 'Diğer';
    }
  }

  String get shortName {
    switch (this) {
      case SupplierTransactionType.purchase:
        return 'Alış';
      case SupplierTransactionType.payment:
        return 'Ödeme';
      case SupplierTransactionType.refund:
        return 'İade';
      case SupplierTransactionType.discount:
        return 'İndirim';
      case SupplierTransactionType.invoice:
        return 'Fatura';
      case SupplierTransactionType.credit:
        return 'Kredi';
      case SupplierTransactionType.debit:
        return 'Borç';
      case SupplierTransactionType.return_:
        return 'İade';
      case SupplierTransactionType.other:
        return 'Diğer';
    }
  }

  IconData get icon {
    switch (this) {
      case SupplierTransactionType.purchase:
        return Icons.shopping_cart;
      case SupplierTransactionType.payment:
        return Icons.payment;
      case SupplierTransactionType.refund:
        return Icons.keyboard_return;
      case SupplierTransactionType.discount:
        return Icons.discount;
      case SupplierTransactionType.invoice:
        return Icons.receipt;
      case SupplierTransactionType.credit:
        return Icons.add_circle;
      case SupplierTransactionType.debit:
        return Icons.remove_circle;
      case SupplierTransactionType.return_:
        return Icons.keyboard_return;
      case SupplierTransactionType.other:
        return Icons.more_horiz;
    }
  }

  static SupplierTransactionType fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'purchase':
        return SupplierTransactionType.purchase;
      case 'payment':
        return SupplierTransactionType.payment;
      case 'refund':
        return SupplierTransactionType.refund;
      case 'discount':
        return SupplierTransactionType.discount;
      case 'invoice':
        return SupplierTransactionType.invoice;
      case 'credit':
        return SupplierTransactionType.credit;
      case 'debit':
        return SupplierTransactionType.debit;
      case 'return_':
        return SupplierTransactionType.return_;
      case 'other':
        return SupplierTransactionType.other;
      default:
        return SupplierTransactionType.other;
    }
  }
}

/// Tedarikçi işlem durumu enum'u
enum SupplierTransactionStatus {
  /// Beklemede
  pending,

  /// Tamamlandı
  completed,

  /// İptal Edildi
  cancelled,

  /// Tersine Çevrildi
  reversed;

  String get displayName {
    switch (this) {
      case SupplierTransactionStatus.pending:
        return 'Beklemede';
      case SupplierTransactionStatus.completed:
        return 'Tamamlandı';
      case SupplierTransactionStatus.cancelled:
        return 'İptal Edildi';
      case SupplierTransactionStatus.reversed:
        return 'Tersine Çevrildi';
    }
  }

  Color get color {
    switch (this) {
      case SupplierTransactionStatus.pending:
        return Colors.orange;
      case SupplierTransactionStatus.completed:
        return Colors.green;
      case SupplierTransactionStatus.cancelled:
        return Colors.red;
      case SupplierTransactionStatus.reversed:
        return Colors.grey;
    }
  }

  static SupplierTransactionStatus fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return SupplierTransactionStatus.pending;
      case 'completed':
        return SupplierTransactionStatus.completed;
      case 'cancelled':
        return SupplierTransactionStatus.cancelled;
      case 'reversed':
        return SupplierTransactionStatus.reversed;
      default:
        return SupplierTransactionStatus.pending;
    }
  }
}

/// Tedarikçi işlem entity'si
class SupplierTransaction {
  /// İşlem benzersiz ID'si
  final String id;

  /// Tedarikçi ID'si
  final String supplierId;

  /// İşlem türü
  final SupplierTransactionType type;

  /// İşlem durumu
  final SupplierTransactionStatus status;

  /// İşlem tutarı
  final double amount;

  /// Para birimi
  final String currency;

  /// İşlem açıklaması
  final String? description;

  /// Referans numarası (fatura no, çek no vb.)
  final String? referenceNumber;

  /// Belge numarası
  final String? documentNumber;

  /// İşlem tarihi
  final DateTime transactionDate;

  /// Vade tarihi (ödeme için)
  final DateTime? dueDate;

  /// Ödeme durumu
  final SupplierPaymentStatus paymentStatus;

  /// Risk seviyesi
  final SupplierRiskLevel riskLevel;

  /// Şirket ID'si
  final String companyId;

  /// Tenant ID'si (multi-tenant güvenlik için)
  final String tenantId;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  /// Oluşturan kullanıcı
  final String createdBy;

  /// Güncelleyen kullanıcı
  final String? updatedBy;

  const SupplierTransaction({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.status,
    required this.amount,
    this.currency = 'TRY',
    this.description,
    this.referenceNumber,
    this.documentNumber,
    required this.transactionDate,
    this.dueDate,
    this.paymentStatus = SupplierPaymentStatus.pending,
    this.riskLevel = SupplierRiskLevel.low,
    required this.companyId,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  SupplierTransaction copyWith({
    String? id,
    String? supplierId,
    SupplierTransactionType? type,
    SupplierTransactionStatus? status,
    double? amount,
    String? currency,
    String? description,
    String? referenceNumber,
    String? documentNumber,
    DateTime? transactionDate,
    DateTime? dueDate,
    SupplierPaymentStatus? paymentStatus,
    SupplierRiskLevel? riskLevel,
    String? companyId,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return SupplierTransaction(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      documentNumber: documentNumber ?? this.documentNumber,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      riskLevel: riskLevel ?? this.riskLevel,
      companyId: companyId ?? this.companyId,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan SupplierTransaction oluştur
  factory SupplierTransaction.fromJson(Map<String, dynamic> json) {
    return SupplierTransaction(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      type: SupplierTransactionType.fromValue(json['type'] as String),
      status: SupplierTransactionStatus.fromValue(
          json['status'] as String? ?? 'pending'),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      description: json['description'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      documentNumber: json['documentNumber'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      paymentStatus:
          SupplierPaymentStatus.fromValue(json['paymentStatus'] as String),
      riskLevel: SupplierRiskLevel.fromValue(json['riskLevel'] as String),
      companyId: json['companyId'] as String,
      tenantId: json['tenantId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// SupplierTransaction'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'description': description,
      'referenceNumber': referenceNumber,
      'documentNumber': documentNumber,
      'transactionDate': transactionDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'paymentStatus': paymentStatus.name,
      'riskLevel': riskLevel.name,
      'companyId': companyId,
      'tenantId': tenantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// İşlem gecikmiş mi?
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) &&
        paymentStatus != SupplierPaymentStatus.paid;
  }

  /// İşlem tutarı formatlanmış
  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  /// Görünen açıklama
  String get displayDescription {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return type.displayName;
  }

  /// Referans bilgisi
  String get referenceInfo {
    if (referenceNumber != null && referenceNumber!.isNotEmpty) {
      return 'Ref: $referenceNumber';
    }
    return '';
  }

  @override
  String toString() {
    return 'SupplierTransaction(id: $id, type: $type, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
