import 'package:floor/floor.dart';
import '../../domain/entities/income.dart';

/// Gelir veritabanı entity'si
@Entity(tableName: 'incomes')
class IncomeEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'title')
  final String title;

  @ColumnInfo(name: 'description')
  final String? description;

  @ColumnInfo(name: 'amount')
  final double amount;

  @ColumnInfo(name: 'category_id')
  final String categoryId;

  @ColumnInfo(name: 'category_name')
  final String categoryName;

  @ColumnInfo(name: 'income_date')
  final DateTime incomeDate;

  @ColumnInfo(name: 'customer_id')
  final String? customerId;

  @ColumnInfo(name: 'customer_name')
  final String? customerName;

  @ColumnInfo(name: 'payment_method')
  final String paymentMethod;

  @ColumnInfo(name: 'invoice_number')
  final String? invoiceNumber;

  @ColumnInfo(name: 'status')
  final String status;

  @ColumnInfo(name: 'notes')
  final String? notes;

  @ColumnInfo(name: 'attachments')
  final String? attachments; // JSON string olarak saklanacak

  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  IncomeEntity({
    this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.incomeDate,
    this.customerId,
    this.customerName,
    required this.paymentMethod,
    this.invoiceNumber,
    required this.status,
    this.notes,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Entity'den domain model'e dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString() ?? '',
      'title': title,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'incomeDate': incomeDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'paymentMethod': paymentMethod,
      'invoiceNumber': invoiceNumber,
      'status': status,
      'notes': notes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Domain model'den entity'ye dönüştürme
  factory IncomeEntity.fromJson(Map<String, dynamic> json) {
    return IncomeEntity(
      id: json['id'] != null ? int.tryParse(json['id']) : null,
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      incomeDate: DateTime.parse(json['incomeDate']),
      customerId: json['customerId'],
      customerName: json['customerName'],
      paymentMethod: json['paymentMethod'],
      invoiceNumber: json['invoiceNumber'],
      status: json['status'],
      notes: json['notes'],
      attachments: json['attachments'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Entity kopyalama metodu
  IncomeEntity copyWith({
    int? id,
    String? title,
    String? description,
    double? amount,
    String? categoryId,
    String? categoryName,
    DateTime? incomeDate,
    String? customerId,
    String? customerName,
    String? paymentMethod,
    String? invoiceNumber,
    String? status,
    String? notes,
    String? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncomeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
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
    );
  }

  /// Domain model'e dönüştürme
  Income toDomain() {
    return Income(
      id: id?.toString() ?? '',
      title: title,
      description: description,
      amount: amount,
      categoryId: categoryId,
      categoryName: categoryName,
      incomeDate: incomeDate,
      customerId: customerId,
      customerName: customerName,
      paymentMethod: paymentMethod,
      invoiceNumber: invoiceNumber,
      status: IncomeStatus.fromString(status),
      notes: notes,
      attachments: attachments != null
          ? List<String>.from(
              attachments!.split(',').where((e) => e.isNotEmpty),
            )
          : [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Domain model'den entity'ye dönüştürme
  static IncomeEntity fromDomain(Income income) {
    return IncomeEntity(
      id: income.id.isNotEmpty ? int.tryParse(income.id) : null,
      title: income.title,
      description: income.description,
      amount: income.amount,
      categoryId: income.categoryId,
      categoryName: income.categoryName,
      incomeDate: income.incomeDate,
      customerId: income.customerId,
      customerName: income.customerName,
      paymentMethod: income.paymentMethod,
      invoiceNumber: income.invoiceNumber,
      status: income.status.value,
      notes: income.notes,
      attachments: income.attachments.isNotEmpty
          ? income.attachments.join(',')
          : null,
      createdAt: income.createdAt,
      updatedAt: income.updatedAt,
    );
  }
}
