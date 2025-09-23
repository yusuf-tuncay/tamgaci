// ========== PRODUCT ATTRIBUTE ENTITY ==========
// lib/features/products/domain/entities/product_attribute.dart

/// Özellik türü
enum AttributeType {
  text('Metin'),
  number('Sayı'),
  boolean('Evet/Hayır'),
  select('Seçim'),
  multiselect('Çoklu Seçim'),
  date('Tarih'),
  color('Renk'),
  size('Boyut'),
  weight('Ağırlık'),
  dimension('Boyut (3D)');

  const AttributeType(this.displayName);
  final String displayName;
}

/// Özellik değeri türü
enum AttributeValueType {
  single('Tek Değer'),
  multiple('Çoklu Değer'),
  range('Aralık');

  const AttributeValueType(this.displayName);
  final String displayName;
}

/// Ürün özelliği entity'si
class ProductAttribute {
  final String id;
  final String name;
  final String? description;
  final AttributeType type;
  final AttributeValueType valueType;
  final bool isRequired;
  final bool isSearchable;
  final bool isFilterable;
  final bool isVisible;
  final List<String> options; // Seçim türü için seçenekler
  final String? defaultValue;
  final String? unit; // Birim (kg, cm, adet vb.)
  final double? minValue; // Minimum değer
  final double? maxValue; // Maksimum değer
  final int? maxLength; // Maksimum karakter uzunluğu
  final String? validationPattern; // Regex pattern
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const ProductAttribute({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.valueType = AttributeValueType.single,
    this.isRequired = false,
    this.isSearchable = true,
    this.isFilterable = true,
    this.isVisible = true,
    this.options = const [],
    this.defaultValue,
    this.unit,
    this.minValue,
    this.maxValue,
    this.maxLength,
    this.validationPattern,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  /// CopyWith metodu
  ProductAttribute copyWith({
    String? id,
    String? name,
    String? description,
    AttributeType? type,
    AttributeValueType? valueType,
    bool? isRequired,
    bool? isSearchable,
    bool? isFilterable,
    bool? isVisible,
    List<String>? options,
    String? defaultValue,
    String? unit,
    double? minValue,
    double? maxValue,
    int? maxLength,
    String? validationPattern,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ProductAttribute(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      valueType: valueType ?? this.valueType,
      isRequired: isRequired ?? this.isRequired,
      isSearchable: isSearchable ?? this.isSearchable,
      isFilterable: isFilterable ?? this.isFilterable,
      isVisible: isVisible ?? this.isVisible,
      options: options ?? this.options,
      defaultValue: defaultValue ?? this.defaultValue,
      unit: unit ?? this.unit,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      maxLength: maxLength ?? this.maxLength,
      validationPattern: validationPattern ?? this.validationPattern,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// JSON'dan ProductAttribute oluştur
  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: AttributeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttributeType.text,
      ),
      valueType: AttributeValueType.values.firstWhere(
        (e) => e.name == json['valueType'],
        orElse: () => AttributeValueType.single,
      ),
      isRequired: json['isRequired'] ?? false,
      isSearchable: json['isSearchable'] ?? true,
      isFilterable: json['isFilterable'] ?? true,
      isVisible: json['isVisible'] ?? true,
      options: List<String>.from(json['options'] ?? []),
      defaultValue: json['defaultValue'] as String?,
      unit: json['unit'] as String?,
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
      maxLength: json['maxLength'] as int?,
      validationPattern: json['validationPattern'] as String?,
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// ProductAttribute'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'valueType': valueType.name,
      'isRequired': isRequired,
      'isSearchable': isSearchable,
      'isFilterable': isFilterable,
      'isVisible': isVisible,
      'options': options,
      'defaultValue': defaultValue,
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
      'maxLength': maxLength,
      'validationPattern': validationPattern,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Değer geçerli mi?
  bool isValidValue(dynamic value) {
    if (value == null && !isRequired) return true;
    if (value == null && isRequired) return false;

    switch (type) {
      case AttributeType.text:
        return _isValidText(value);
      case AttributeType.number:
        return _isValidNumber(value);
      case AttributeType.boolean:
        return value is bool;
      case AttributeType.select:
        return _isValidSelect(value);
      case AttributeType.multiselect:
        return _isValidMultiSelect(value);
      case AttributeType.date:
        return _isValidDate(value);
      case AttributeType.color:
        return _isValidColor(value);
      case AttributeType.size:
      case AttributeType.weight:
      case AttributeType.dimension:
        return _isValidNumber(value);
    }
  }

  bool _isValidText(dynamic value) {
    if (value is! String) return false;
    if (maxLength != null && value.length > maxLength!) return false;
    if (validationPattern != null) {
      final regex = RegExp(validationPattern!);
      return regex.hasMatch(value);
    }
    return true;
  }

  bool _isValidNumber(dynamic value) {
    if (value is num) {
      final numValue = value.toDouble();
      if (minValue != null && numValue < minValue!) return false;
      if (maxValue != null && numValue > maxValue!) return false;
      return true;
    }
    return false;
  }

  bool _isValidSelect(dynamic value) {
    if (value is! String) return false;
    return options.contains(value);
  }

  bool _isValidMultiSelect(dynamic value) {
    if (value is List) {
      return value.every((item) => options.contains(item.toString()));
    }
    return false;
  }

  bool _isValidDate(dynamic value) {
    if (value is DateTime) return true;
    if (value is String) {
      try {
        DateTime.parse(value);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  bool _isValidColor(dynamic value) {
    if (value is! String) return false;
    // Hex color validation
    final hexPattern = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexPattern.hasMatch(value);
  }

  /// Seçim türü mü?
  bool get isSelectType =>
      type == AttributeType.select || type == AttributeType.multiselect;

  /// Sayısal tür mü?
  bool get isNumericType =>
      type == AttributeType.number ||
      type == AttributeType.size ||
      type == AttributeType.weight ||
      type == AttributeType.dimension;

  @override
  String toString() {
    return 'ProductAttribute(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductAttribute && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
