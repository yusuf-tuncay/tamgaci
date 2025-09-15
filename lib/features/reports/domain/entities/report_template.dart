import 'package:equatable/equatable.dart';

/// Rapor şablonu türü
enum ReportTemplateType {
  standard('Standart'),
  custom('Özel'),
  system('Sistem');

  const ReportTemplateType(this.displayName);
  final String displayName;
}

/// Rapor şablonu entity'si
class ReportTemplate extends Equatable {
  final String id;
  final String name;
  final String? description;
  final ReportTemplateType type;
  final String reportType;
  final Map<String, dynamic> defaultParameters;
  final Map<String, dynamic> defaultFilters;
  final Map<String, dynamic> templateConfig;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const ReportTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.reportType,
    this.defaultParameters = const {},
    this.defaultFilters = const {},
    this.templateConfig = const {},
    this.isActive = true,
    this.isDefault = false,
    this.sortOrder = 0,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  ReportTemplate copyWith({
    String? id,
    String? name,
    String? description,
    ReportTemplateType? type,
    String? reportType,
    Map<String, dynamic>? defaultParameters,
    Map<String, dynamic>? defaultFilters,
    Map<String, dynamic>? templateConfig,
    bool? isActive,
    bool? isDefault,
    int? sortOrder,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ReportTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      reportType: reportType ?? this.reportType,
      defaultParameters: defaultParameters ?? this.defaultParameters,
      defaultFilters: defaultFilters ?? this.defaultFilters,
      templateConfig: templateConfig ?? this.templateConfig,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'reportType': reportType,
      'defaultParameters': defaultParameters,
      'defaultFilters': defaultFilters,
      'templateConfig': templateConfig,
      'isActive': isActive,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    return ReportTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ReportTemplateType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportTemplateType.standard,
      ),
      reportType: json['reportType'] as String,
      defaultParameters:
          Map<String, dynamic>.from(json['defaultParameters'] ?? {}),
      defaultFilters: Map<String, dynamic>.from(json['defaultFilters'] ?? {}),
      templateConfig: Map<String, dynamic>.from(json['templateConfig'] ?? {}),
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        reportType,
        defaultParameters,
        defaultFilters,
        templateConfig,
        isActive,
        isDefault,
        sortOrder,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
