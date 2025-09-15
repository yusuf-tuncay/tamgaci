import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/reports/domain/entities/report_template.dart';

/// ReportTemplate model for Firebase integration
class ReportTemplateModel extends ReportTemplate {
  const ReportTemplateModel({
    required super.id,
    required super.name,
    super.description,
    required super.type,
    required super.reportType,
    super.defaultParameters,
    super.defaultFilters,
    super.templateConfig,
    super.isActive,
    super.isDefault,
    super.sortOrder,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  @override
  ReportTemplateModel copyWith({
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
    return ReportTemplateModel(
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

  /// Firestore DocumentSnapshot'tan ReportTemplateModel oluşturur
  factory ReportTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportTemplateModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      type: ReportTemplateType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ReportTemplateType.standard,
      ),
      reportType: data['reportType'] as String,
      defaultParameters:
          Map<String, dynamic>.from(data['defaultParameters'] ?? {}),
      defaultFilters: Map<String, dynamic>.from(data['defaultFilters'] ?? {}),
      templateConfig: Map<String, dynamic>.from(data['templateConfig'] ?? {}),
      isActive: data['isActive'] as bool? ?? true,
      isDefault: data['isDefault'] as bool? ?? false,
      sortOrder: data['sortOrder'] as int? ?? 0,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  /// ReportTemplateModel'i Firestore'a uygun Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// ReportTemplateModel'i ReportTemplate entity'sine dönüştürür
  ReportTemplate toEntity() {
    return ReportTemplate(
      id: id,
      name: name,
      description: description,
      type: type,
      reportType: reportType,
      defaultParameters: defaultParameters,
      defaultFilters: defaultFilters,
      templateConfig: templateConfig,
      isActive: isActive,
      isDefault: isDefault,
      sortOrder: sortOrder,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// ReportTemplate entity'sinden ReportTemplateModel oluşturur
  factory ReportTemplateModel.fromEntity(ReportTemplate reportTemplate) {
    return ReportTemplateModel(
      id: reportTemplate.id,
      name: reportTemplate.name,
      description: reportTemplate.description,
      type: reportTemplate.type,
      reportType: reportTemplate.reportType,
      defaultParameters: reportTemplate.defaultParameters,
      defaultFilters: reportTemplate.defaultFilters,
      templateConfig: reportTemplate.templateConfig,
      isActive: reportTemplate.isActive,
      isDefault: reportTemplate.isDefault,
      sortOrder: reportTemplate.sortOrder,
      metadata: reportTemplate.metadata,
      createdAt: reportTemplate.createdAt,
      updatedAt: reportTemplate.updatedAt,
      createdBy: reportTemplate.createdBy,
      updatedBy: reportTemplate.updatedBy,
    );
  }
}
