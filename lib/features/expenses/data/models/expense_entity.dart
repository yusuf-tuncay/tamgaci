// ========== EXPENSE ENTITY ==========
// lib/features/expenses/data/models/expense_entity.dart

import 'package:floor/floor.dart';

@Entity(tableName: 'expenses')
class ExpenseEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'title')
  final String title;

  @ColumnInfo(name: 'description')
  final String? description;

  @ColumnInfo(name: 'amount')
  final double amount;

  @ColumnInfo(name: 'categoryId')
  final int categoryId;

  @ColumnInfo(name: 'date')
  final DateTime date;

  @ColumnInfo(name: 'status')
  final String status; // 'active', 'cancelled', 'pending'

  @ColumnInfo(name: 'paymentMethod')
  final String? paymentMethod;

  @ColumnInfo(name: 'receiptPath')
  final String? receiptPath;

  @ColumnInfo(name: 'notes')
  final String? notes;

  @ColumnInfo(name: 'createdAt')
  final DateTime createdAt;

  @ColumnInfo(name: 'updatedAt')
  final DateTime updatedAt;

  ExpenseEntity({
    this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.status,
    this.paymentMethod,
    this.receiptPath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Kopyalama metodu
  ExpenseEntity copyWith({
    int? id,
    String? title,
    String? description,
    double? amount,
    int? categoryId,
    DateTime? date,
    String? status,
    String? paymentMethod,
    String? receiptPath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptPath: receiptPath ?? this.receiptPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON'dan dönüştürme
  factory ExpenseEntity.fromJson(Map<String, dynamic> json) {
    return ExpenseEntity(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as int,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      receiptPath: json['receiptPath'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'receiptPath': receiptPath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseEntity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.amount == amount &&
        other.categoryId == categoryId &&
        other.date == date &&
        other.status == status &&
        other.paymentMethod == paymentMethod &&
        other.receiptPath == receiptPath &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        categoryId.hashCode ^
        date.hashCode ^
        status.hashCode ^
        paymentMethod.hashCode ^
        receiptPath.hashCode ^
        notes.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ExpenseEntity(id: $id, title: $title, amount: $amount, categoryId: $categoryId, date: $date, status: $status)';
  }
}
