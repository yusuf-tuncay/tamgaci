// ========== INCOME ENTITY ==========
// lib/features/income/domain/entities/income.dart

/// Gelir durumu enum'u
enum IncomeStatus {
  received('received', 'Tahsil Edildi'),
  pending('pending', 'Beklemede'),
  cancelled('cancelled', 'İptal Edildi');

  const IncomeStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static IncomeStatus fromString(String value) {
    return IncomeStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => IncomeStatus.pending,
    );
  }
}

/// Gelir entity'si
class Income {
  /// Gelir ID'si
  final String id;

  /// Gelir başlığı
  final String title;

  /// Gelir açıklaması
  final String? description;

  /// Gelir tutarı
  final double amount;

  /// Gelir para birimi
  final String currency;

  /// Gelir kategorisi ID'si
  final String categoryId;

  /// Gelir kategorisi adı
  final String categoryName;

  /// Gelir tarihi
  final DateTime incomeDate;

  /// Müşteri ID'si (varsa)
  final String? customerId;

  /// Müşteri adı (varsa)
  final String? customerName;

  /// Tahsilat yöntemi
  final String paymentMethod;

  /// Fatura numarası (varsa)
  final String? invoiceNumber;

  /// Gelir durumu
  final IncomeStatus status;

  /// Ek notlar
  final String? notes;

  /// Ek dosyalar
  final List<String> attachments;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  /// Oluşturan kullanıcı ID'si
  final String createdBy;

  /// Güncelleyen kullanıcı ID'si
  final String? updatedBy;

  const Income({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    this.currency = 'TRY',
    required this.categoryId,
    required this.categoryName,
    required this.incomeDate,
    this.customerId,
    this.customerName,
    required this.paymentMethod,
    this.invoiceNumber,
    required this.status,
    this.notes,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// Income kopyalama metodu
  Income copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? currency,
    String? categoryId,
    String? categoryName,
    DateTime? incomeDate,
    String? customerId,
    String? customerName,
    String? paymentMethod,
    String? invoiceNumber,
    IncomeStatus? status,
    String? notes,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Income(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      incomeDate: incomeDate ?? this.incomeDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan Income oluştur
  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      incomeDate: DateTime.parse(json['incomeDate'] as String),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      invoiceNumber: json['invoiceNumber'] as String?,
      status: IncomeStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// Income'u JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'incomeDate': incomeDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'paymentMethod': paymentMethod,
      'invoiceNumber': invoiceNumber,
      'status': status.value,
      'notes': notes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Income && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Income(id: $id, title: $title, amount: $amount, status: $status)';
  }
}
