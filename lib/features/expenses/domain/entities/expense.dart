// ========== EXPENSE ENTITY ==========
// lib/features/expenses/domain/entities/expense.dart

/// Gider entity'si
class Expense {
  /// Gider ID'si
  final String id;

  /// Gider başlığı
  final String title;

  /// Gider açıklaması
  final String? description;

  /// Gider tutarı
  final double amount;

  /// Gider kategorisi
  final String categoryId;

  /// Gider kategorisi adı
  final String categoryName;

  /// Gider tarihi
  final DateTime expenseDate;

  /// Ödeme yöntemi
  final String paymentMethod;

  /// Fatura numarası (varsa)
  final String? invoiceNumber;

  /// Tedarikçi ID'si (varsa)
  final String? supplierId;

  /// Tedarikçi adı (varsa)
  final String? supplierName;

  /// Dosya ekleri (varsa)
  final List<String> attachments;

  /// Gider durumu
  final ExpenseStatus status;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  /// Oluşturan kullanıcı ID'si
  final String createdBy;

  /// Güncelleyen kullanıcı ID'si
  final String? updatedBy;

  const Expense({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.expenseDate,
    required this.paymentMethod,
    this.invoiceNumber,
    this.supplierId,
    this.supplierName,
    this.attachments = const [],
    this.status = ExpenseStatus.paid,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// Expense kopyalama metodu
  Expense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? categoryId,
    String? categoryName,
    DateTime? expenseDate,
    String? paymentMethod,
    String? invoiceNumber,
    String? supplierId,
    String? supplierName,
    List<String>? attachments,
    ExpenseStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, category: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Gider durumu enum'u
enum ExpenseStatus {
  /// Ödendi
  paid,

  /// Beklemede
  pending,

  /// İptal edildi
  cancelled,
}

/// Gider durumu extension'ı
extension ExpenseStatusExtension on ExpenseStatus {
  /// Durum adını döndürür
  String get name {
    switch (this) {
      case ExpenseStatus.paid:
        return 'Ödendi';
      case ExpenseStatus.pending:
        return 'Beklemede';
      case ExpenseStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  /// Durum rengini döndürür
  String get color {
    switch (this) {
      case ExpenseStatus.paid:
        return '#4CAF50'; // Yeşil
      case ExpenseStatus.pending:
        return '#FF9800'; // Turuncu
      case ExpenseStatus.cancelled:
        return '#F44336'; // Kırmızı
    }
  }

  /// Durum ikonunu döndürür
  String get icon {
    switch (this) {
      case ExpenseStatus.paid:
        return 'check_circle';
      case ExpenseStatus.pending:
        return 'pending';
      case ExpenseStatus.cancelled:
        return 'cancel';
    }
  }
}
