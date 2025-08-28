import 'package:floor/floor.dart';
import '../../domain/entities/income_category.dart';

/// Gelir kategorisi veritabanı entity'si
@Entity(tableName: 'income_categories')
class IncomeCategoryEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'description')
  final String? description;

  @ColumnInfo(name: 'color')
  final String? color;

  @ColumnInfo(name: 'icon')
  final String? icon;

  @ColumnInfo(name: 'is_active')
  final bool isActive;

  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  IncomeCategoryEntity({
    this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Entity'den domain model'e dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Domain model'den entity'ye dönüştürme
  factory IncomeCategoryEntity.fromJson(Map<String, dynamic> json) {
    return IncomeCategoryEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      icon: json['icon'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Entity kopyalama metodu
  IncomeCategoryEntity copyWith({
    int? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncomeCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Domain model'e dönüştürme
  IncomeCategory toDomain() {
    return IncomeCategory(
      id: id?.toString() ?? '',
      name: name,
      description: description,
      color: color ?? '#2196F3',
      icon: icon ?? 'category',
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Domain model'den entity'ye dönüştürme
  static IncomeCategoryEntity fromDomain(IncomeCategory category) {
    return IncomeCategoryEntity(
      id: category.id.isNotEmpty ? int.tryParse(category.id) : null,
      name: category.name,
      description: category.description,
      color: category.color,
      icon: category.icon,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}
