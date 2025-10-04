// ========== lib/features/invoices/domain/entities/invoice.dart ==========

// import '../../data/models/invoice_entity.dart'; // Removed - using Firebase only
import '../../data/models/invoice_status.dart';
import '../../../customers/domain/entities/customer.dart';
import 'invoice_item.dart';

/// Fatura domain entity'si - Business logic katmanı için
class Invoice {
  /// Fatura benzersiz ID'si
  final String id;

  /// Fatura numarası
  final String invoiceNumber;

  /// Müşteri ID'si
  final String customerId;

  /// Müşteri adı (hızlı erişim için)
  final String? customerName;

  /// Müşteri adresi (hızlı erişim için)
  final String? customerAddress;

  /// Müşteri bilgisi (lazy loading)
  final Customer? customer;

  /// Fatura tarihi
  final DateTime invoiceDate;

  /// Vade tarihi
  final DateTime? dueDate;

  /// Fatura durumu
  final InvoiceStatus status;

  /// Alt toplam (KDV hariç)
  final double subtotal;

  /// KDV tutarı
  final double taxAmount;

  /// İndirim tutarı
  final double discountAmount;

  /// Toplam tutar (KDV dahil)
  final double totalAmount;

  /// Para birimi kodu
  final String currencyCode;

  /// Ödeme koşulları
  final String? paymentTerms;

  /// Notlar
  final String? notes;

  /// Fatura açıklaması
  final String? description;

  /// Ödeme yapıldı mı?
  final bool isPaid;

  /// Ödeme tarihi
  final DateTime? paidDate;

  /// Fatura kalemleri
  final List<InvoiceItem> items;

  /// Belge yönü (satış/alış) - opsiyonel, geriye dönük uyum için
  final String? direction; // 'sale' | 'purchase'

  /// Belge türü (fatura/irsaliye/proforma) - opsiyonel
  final String? documentType; // 'invoice' | 'waybill' | 'proforma'

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    this.customerName,
    this.customerAddress,
    this.customer,
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
    this.items = const [],
    this.direction,
    this.documentType,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan Invoice oluştur
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      customerAddress: json['customerAddress'] as String?,
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      paymentTerms: json['paymentTerms'] as String?,
      notes: json['notes'] as String?,
      description: json['description'] as String?,
      isPaid: json['isPaid'] as bool,
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      direction: json['direction'] as String?,
      documentType: json['documentType'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Invoice'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customer': customer?.toJson(),
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.name,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currencyCode': currencyCode,
      'paymentTerms': paymentTerms,
      'notes': notes,
      'description': description,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'direction': direction,
      'documentType': documentType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// CopyWith metodu
  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? customerAddress,
    Customer? customer,
    DateTime? invoiceDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? currencyCode,
    String? paymentTerms,
    String? notes,
    String? description,
    bool? isPaid,
    DateTime? paidDate,
    List<InvoiceItem>? items,
    String? direction,
    String? documentType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customer: customer ?? this.customer,
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
      items: items ?? this.items,
      direction: direction ?? this.direction,
      documentType: documentType ?? this.documentType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ========== BUSINESS LOGIC METODLARI ==========

  /// Faturanın görüntülenecek başlığı
  String get displayTitle {
    return '$invoiceNumber${customer != null ? ' - ${customer!.name}' : ''}';
  }

  /// Faturanın kısa özeti
  String get summary {
    final itemCount = items.length;
    final amountText = formattedTotalAmount;
    return '$itemCount kalem • $amountText';
  }

  /// Formatlanmış toplam tutar
  String get formattedTotalAmount {
    return '${totalAmount.toStringAsFixed(2)} $currencySymbol';
  }

  /// Formatlanmış toplam tutar (varsayılan para birimi ile)
  String get formattedTotalAmountWithDefault {
    // TODO: Bu metod varsayılan para birimi provider'ından gelen kurları kullanacak
    return '${totalAmount.toStringAsFixed(2)} $currencySymbol';
  }

  /// Formatlanmış alt toplam
  String get formattedSubtotal {
    return '${subtotal.toStringAsFixed(2)} $currencySymbol';
  }

  /// Formatlanmış KDV tutarı
  String get formattedTaxAmount {
    return '${taxAmount.toStringAsFixed(2)} $currencySymbol';
  }

  /// Para birimi sembolü
  String get currencySymbol {
    switch (currencyCode) {
      case 'TRY':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currencyCode;
    }
  }

  /// Kalan gün sayısı (vade tarihi için)
  int? get remainingDays {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inDays;
  }

  /// Vadesi geçmiş mi?
  bool get isOverdue {
    if (dueDate == null || isPaid) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Durum rengi
  String get statusColor {
    if (isOverdue && !isPaid) {
      return InvoiceStatus.overdue.colorCode;
    }
    return status.colorCode;
  }

  /// Durum adı (overdue kontrolü ile)
  String get statusDisplayName {
    if (isOverdue && !isPaid) {
      return InvoiceStatus.overdue.displayName;
    }
    return status.displayName;
  }

  /// Fatura düzenlenebilir mi?
  bool get canEdit {
    return status == InvoiceStatus.draft;
  }

  /// Fatura gönderilebilir mi?
  bool get canSend {
    return status == InvoiceStatus.draft && items.isNotEmpty;
  }

  /// Fatura ödenebilir mi?
  bool get canMarkAsPaid {
    return (status == InvoiceStatus.sent ||
            status == InvoiceStatus.overdue ||
            status == InvoiceStatus.partiallyPaid) &&
        !isPaid;
  }

  /// Fatura iptal edilebilir mi?
  bool get canCancel {
    return status != InvoiceStatus.paid && status != InvoiceStatus.cancelled;
  }

  /// Kalem sayısı
  int get itemCount {
    return items.length;
  }

  /// Toplam miktar (tüm kalemler)
  double get totalQuantity {
    return items.fold(0.0, (sum, item) => sum + item.quantity);
  }

  /// Ortalama KDV oranı
  double get averageTaxRate {
    if (items.isEmpty) return 0.0;
    final totalTaxRate = items.fold(0.0, (sum, item) => sum + item.taxRate);
    return totalTaxRate / items.length;
  }

  /// Tutarları yeniden hesapla (kalemlerden)
  Invoice recalculateAmounts() {
    if (items.isEmpty) {
      return copyWith(
        subtotal: 0.0,
        taxAmount: 0.0,
        totalAmount: 0.0,
        updatedAt: DateTime.now(),
      );
    }

    final newSubtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);
    final newTaxAmount = items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final newTotalAmount = newSubtotal + newTaxAmount - discountAmount;

    return copyWith(
      subtotal: newSubtotal,
      taxAmount: newTaxAmount,
      totalAmount: newTotalAmount,
      updatedAt: DateTime.now(),
    );
  }

  /// Durumu güncelle
  Invoice updateStatus(InvoiceStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  /// Ödeme yapıldı olarak işaretle
  Invoice markAsPaid({DateTime? paidDate}) {
    return copyWith(
      isPaid: true,
      paidDate: paidDate ?? DateTime.now(),
      status: InvoiceStatus.paid,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Invoice(id: $id, number: $invoiceNumber, customer: $customerId, total: $formattedTotalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
