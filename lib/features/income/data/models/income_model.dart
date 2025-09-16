import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/income/domain/entities/income.dart';

/// Income Firebase Model
class IncomeModel {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final String categoryId;
  final String categoryName;
  final DateTime incomeDate;
  final String paymentMethod;
  final String? invoiceNumber;
  final String? customerId;
  final String? customerName;
  final List<String> attachments;
  final IncomeStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const IncomeModel({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
    required this.categoryId,
    required this.categoryName,
    required this.incomeDate,
    required this.paymentMethod,
    this.invoiceNumber,
    this.customerId,
    this.customerName,
    this.attachments = const [],
    this.status = IncomeStatus.received,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// Domain entity'ye dönüştür
  Income toDomain() {
    return Income(
      id: id,
      title: title,
      description: description,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      categoryName: categoryName,
      incomeDate: incomeDate,
      paymentMethod: paymentMethod,
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      customerName: customerName,
      attachments: attachments,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Domain entity'den oluştur
  factory IncomeModel.fromDomain(Income income) {
    return IncomeModel(
      id: income.id,
      title: income.title,
      description: income.description,
      amount: income.amount,
      currency: income.currency,
      categoryId: income.categoryId,
      categoryName: income.categoryName,
      incomeDate: income.incomeDate,
      paymentMethod: income.paymentMethod,
      invoiceNumber: income.invoiceNumber,
      customerId: income.customerId,
      customerName: income.customerName,
      attachments: income.attachments,
      status: income.status,
      createdAt: income.createdAt,
      updatedAt: income.updatedAt,
      createdBy: income.createdBy,
      updatedBy: income.updatedBy,
    );
  }

  /// Firestore'dan oluştur
  factory IncomeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncomeModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'TRY',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      incomeDate: (data['incomeDate'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] ?? '',
      invoiceNumber: data['invoiceNumber'],
      customerId: data['customerId'],
      customerName: data['customerName'],
      attachments: List<String>.from(data['attachments'] ?? []),
      status: IncomeStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => IncomeStatus.received,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'],
    );
  }

  /// Firestore'a dönüştür
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'incomeDate': Timestamp.fromDate(incomeDate),
      'paymentMethod': paymentMethod,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'attachments': attachments,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Kopyalama metodu
  IncomeModel copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? currency,
    String? categoryId,
    String? categoryName,
    DateTime? incomeDate,
    String? paymentMethod,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    List<String>? attachments,
    IncomeStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      incomeDate: incomeDate ?? this.incomeDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
