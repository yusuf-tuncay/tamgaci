import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/expenses/domain/entities/expense.dart';

/// Expense Firebase Model
class ExpenseModel {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final String categoryId;
  final String categoryName;
  final DateTime expenseDate;
  final String paymentMethod;
  final String? invoiceNumber;
  final String? supplierId;
  final String? supplierName;
  final List<String> attachments;
  final ExpenseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const ExpenseModel({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
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

  /// Domain entity'ye dönüştür
  Expense toDomain() {
    return Expense(
      id: id,
      title: title,
      description: description,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      categoryName: categoryName,
      expenseDate: expenseDate,
      paymentMethod: paymentMethod,
      invoiceNumber: invoiceNumber,
      supplierId: supplierId,
      supplierName: supplierName,
      attachments: attachments,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Domain entity'den oluştur
  factory ExpenseModel.fromDomain(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      description: expense.description,
      amount: expense.amount,
      currency: expense.currency,
      categoryId: expense.categoryId,
      categoryName: expense.categoryName,
      expenseDate: expense.expenseDate,
      paymentMethod: expense.paymentMethod,
      invoiceNumber: expense.invoiceNumber,
      supplierId: expense.supplierId,
      supplierName: expense.supplierName,
      attachments: expense.attachments,
      status: expense.status,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
      createdBy: expense.createdBy,
      updatedBy: expense.updatedBy,
    );
  }

  /// Firestore'dan oluştur
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'TRY',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      expenseDate: (data['expenseDate'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] ?? '',
      invoiceNumber: data['invoiceNumber'],
      supplierId: data['supplierId'],
      supplierName: data['supplierName'],
      attachments: List<String>.from(data['attachments'] ?? []),
      status: ExpenseStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ExpenseStatus.paid,
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
      'expenseDate': Timestamp.fromDate(expenseDate),
      'paymentMethod': paymentMethod,
      'invoiceNumber': invoiceNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'attachments': attachments,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Kopyalama metodu
  ExpenseModel copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? currency,
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
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
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
}
