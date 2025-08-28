// ========== lib/features/invoices/data/models/invoice_entity.dart ==========

import 'package:floor/floor.dart';
import 'package:tamgaci/features/customers/data/models/customer_entity.dart';


/// Fatura varlığı - Database entity sınıfı
@Entity(
  tableName: 'invoices',
  foreignKeys: [
    ForeignKey(
      childColumns: ['customer_id'],
      parentColumns: ['id'],
      entity: CustomerEntity,
      onDelete: ForeignKeyAction.restrict,
    ),
  ],
  indices: [
    Index(value: ['customer_id']),
    Index(value: ['invoice_number'], unique: true),
    Index(value: ['status']),
    Index(value: ['created_at']),
  ],
)
class InvoiceEntity {
  /// Fatura benzersiz ID'si (Primary Key)
  @PrimaryKey()
  final String id;

  /// Fatura numarası (Unique)
  @ColumnInfo(name: 'invoice_number')
  final String invoiceNumber;

  /// Müşteri ID'si (Foreign Key)
  @ColumnInfo(name: 'customer_id')
  final String customerId;

  /// Fatura tarihi (milisaniye cinsinden)
  @ColumnInfo(name: 'invoice_date')
  final int invoiceDate;

  /// Vade tarihi (milisaniye cinsinden)
  @ColumnInfo(name: 'due_date')
  final int? dueDate;

  /// Fatura durumu (draft, sent, paid, overdue, cancelled)
  @ColumnInfo(name: 'status')
  final String status;

  /// Alt toplam (KDV hariç) - kuruş cinsinden
  @ColumnInfo(name: 'subtotal')
  final int subtotal;

  /// KDV tutarı - kuruş cinsinden
  @ColumnInfo(name: 'tax_amount')
  final int taxAmount;

  /// İndirim tutarı - kuruş cinsinden
  @ColumnInfo(name: 'discount_amount')
  final int discountAmount;

  /// Toplam tutar (KDV dahil) - kuruş cinsinden
  @ColumnInfo(name: 'total_amount')
  final int totalAmount;

  /// Para birimi kodu (TRY, USD, EUR)
  @ColumnInfo(name: 'currency_code')
  final String currencyCode;

  /// Ödeme koşulları
  @ColumnInfo(name: 'payment_terms')
  final String? paymentTerms;

  /// Notlar
  @ColumnInfo(name: 'notes')
  final String? notes;

  /// Fatura açıklaması
  @ColumnInfo(name: 'description')
  final String? description;

  /// Ödeme yapıldı mı?
  @ColumnInfo(name: 'is_paid')
  final bool isPaid;

  /// Ödeme tarihi (milisaniye cinsinden)
  @ColumnInfo(name: 'paid_date')
  final int? paidDate;

  /// Oluşturulma tarihi (milisaniye cinsinden)
  @ColumnInfo(name: 'created_at')
  final int createdAt;

  /// Güncellenme tarihi (milisaniye cinsinden)
  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  /// InvoiceEntity constructor
  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.invoiceDate,
    this.dueDate,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currencyCode,
    this.paymentTerms,
    this.notes,
    this.description,
    required this.isPaid,
    this.paidDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    int? invoiceDate,
    int? dueDate,
    String? status,
    int? subtotal,
    int? taxAmount,
    int? discountAmount,
    int? totalAmount,
    String? currencyCode,
    String? paymentTerms,
    String? notes,
    String? description,
    bool? isPaid,
    int? paidDate,
    int? createdAt,
    int? updatedAt,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'InvoiceEntity(id: $id, invoiceNumber: $invoiceNumber, customerId: $customerId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}