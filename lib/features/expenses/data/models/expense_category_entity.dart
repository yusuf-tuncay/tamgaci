// ========== EXPENSE CATEGORY ENTITY ==========
// lib/features/expenses/data/models/expense_category_entity.dart

import 'package:floor/floor.dart';

@Entity(tableName: 'expense_categories')
class ExpenseCategoryEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'description')
  final String? description;

  @ColumnInfo(name: 'color')
  final String? color; // Hex color code

  @ColumnInfo(name: 'icon')
  final String? icon; // Icon name

  @ColumnInfo(name: 'isActive')
  final bool isActive;

  @ColumnInfo(name: 'isDefault')
  final bool isDefault;

  @ColumnInfo(name: 'sortOrder')
  final int sortOrder;

  @ColumnInfo(name: 'createdAt')
  final DateTime createdAt;

  @ColumnInfo(name: 'updatedAt')
  final DateTime updatedAt;

  ExpenseCategoryEntity({
    this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    required this.isActive,
    required this.isDefault,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  // Kopyalama metodu
  ExpenseCategoryEntity copyWith({
    int? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON'dan dönüştürme
  factory ExpenseCategoryEntity.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryEntity(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool,
      isDefault: json['isDefault'] as bool,
      sortOrder: json['sortOrder'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseCategoryEntity &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.color == color &&
        other.icon == icon &&
        other.isActive == isActive &&
        other.isDefault == isDefault &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        color.hashCode ^
        icon.hashCode ^
        isActive.hashCode ^
        isDefault.hashCode ^
        sortOrder.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ExpenseCategoryEntity(id: $id, name: $name, isActive: $isActive, isDefault: $isDefault)';
  }
}
