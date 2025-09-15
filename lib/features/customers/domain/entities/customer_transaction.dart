// ========== CUSTOMER TRANSACTION ==========
// lib/features/customers/domain/entities/customer_transaction.dart

/// Müşteri işlem türü enum'u
enum CustomerTransactionType {
  sale,
  purchase,
  payment,
  refund,
  credit,
  debit,
  invoice,
  proforma,
  waybill;

  String get displayName {
    switch (this) {
      case CustomerTransactionType.sale:
        return 'Satış';
      case CustomerTransactionType.purchase:
        return 'Alış';
      case CustomerTransactionType.payment:
        return 'Ödeme';
      case CustomerTransactionType.refund:
        return 'İade';
      case CustomerTransactionType.credit:
        return 'Kredi';
      case CustomerTransactionType.debit:
        return 'Borç';
      case CustomerTransactionType.invoice:
        return 'Fatura';
      case CustomerTransactionType.proforma:
        return 'Proforma';
      case CustomerTransactionType.waybill:
        return 'İrsaliye';
    }
  }
}

/// Müşteri işlem durumu enum'u
enum CustomerTransactionStatus {
  pending,
  completed,
  cancelled,
  overdue,
  paid;

  String get displayName {
    switch (this) {
      case CustomerTransactionStatus.pending:
        return 'Beklemede';
      case CustomerTransactionStatus.completed:
        return 'Tamamlandı';
      case CustomerTransactionStatus.cancelled:
        return 'İptal Edildi';
      case CustomerTransactionStatus.overdue:
        return 'Vadesi Geçti';
      case CustomerTransactionStatus.paid:
        return 'Ödendi';
    }
  }
}

/// Müşteri işlem entity'si
class CustomerTransaction {
  final String id;
  final String customerId;
  final CustomerTransactionType type;
  final double amount;
  final String currency;
  final String? description;
  final String? reference;
  final DateTime transactionDate;
  final String? invoiceId;
  final String? paymentMethod;
  final String? documentNumber;
  final DateTime? dueDate;
  final String? status;
  final String companyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const CustomerTransaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.currency,
    this.description,
    this.reference,
    required this.transactionDate,
    this.invoiceId,
    this.paymentMethod,
    this.documentNumber,
    this.dueDate,
    this.status,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });
}
